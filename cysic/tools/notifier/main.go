package main

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/client"
	_ "github.com/joho/godotenv/autoload"
)

func monitorContainerLogs(ctx context.Context, cli *client.Client, containerName, webhookURL string, notificationDelay time.Duration) {
	options := container.LogsOptions{
		ShowStdout: true,
		ShowStderr: true,
		Follow:     true,
		Tail:       "0",
	}

	reader, err := cli.ContainerLogs(ctx, containerName, options)
	if err != nil {
		log.Printf("Error reading logs for container %s: %v\n", containerName, err)
		return
	}
	defer reader.Close()

	scanner := bufio.NewScanner(reader)
	pattern := regexp.MustCompile(`txhash:\s+([0-9A-F]{64})`)

	for scanner.Scan() {
		line := scanner.Text()
		matches := pattern.FindStringSubmatch(line)
		if len(matches) == 2 {
			txHash := matches[1]
			log.Printf("Container %s, TxHash: %s", containerName, txHash)
			message := fmt.Sprintf("Container `%s` has completed a task (TxHash: `%s`)", containerName, txHash)
			go sendDelayedFeishuMessage(message, webhookURL, notificationDelay)
		}
	}

	if err := scanner.Err(); err != nil {
		log.Printf("Error reading logs for container %s: %v\n", containerName, err)
	}
}

func sendDelayedFeishuMessage(message, webhookURL string, notificationDelay time.Duration) {
	time.Sleep(notificationDelay)
	sendFeishuMessage(message, webhookURL)
}

func sendFeishuMessage(message, webhookURL string) {
	payload := map[string]interface{}{
		"msg_type": "text",
		"content": map[string]string{
			"text": message,
		},
	}

	jsonPayload, err := json.Marshal(payload)
	if err != nil {
		log.Println("Error marshaling JSON payload:", err)
		return
	}

	resp, err := http.Post(webhookURL, "application/json", bytes.NewBuffer(jsonPayload))
	if err != nil {
		log.Println("Error sending Feishu notification:", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		log.Printf("status code: %d, body: %s\n", resp.StatusCode, body)
	}
}

func parseContainers(input string) []string {
	var containers []string
	inQuote := false
	var current strings.Builder

	for _, char := range input {
		switch char {
		case '"':
			inQuote = !inQuote
		case ',':
			if !inQuote {
				containers = append(containers, strings.TrimSpace(current.String()))
				current.Reset()
			} else {
				current.WriteRune(char)
			}
		default:
			current.WriteRune(char)
		}
	}

	if current.Len() > 0 {
		containers = append(containers, strings.TrimSpace(current.String()))
	}

	return containers
}

func main() {
	ctx := context.Background()
	cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
	if err != nil {
		log.Fatal("Error creating Docker client:", err)
	}

	containers := parseContainers(os.Getenv("CONTAINERS"))
	webhookURL := os.Getenv("FEISHU_WEBHOOK")
    notificationDelaySecStr := os.Getenv("NOTIFICATION_DELAY_SEC")
    var notificationDelaySec int
    if notificationDelaySecStr == "" {
        notificationDelaySec = 0
    } else {
        var err error
        notificationDelaySec, err = strconv.Atoi(notificationDelaySecStr)
        if err != nil {
            log.Printf("Invalid NOTIFICATION_DELAY_SEC value: %s. Using default (0 seconds).", notificationDelaySecStr)
            notificationDelaySec = 0
        }
    }

    fmt.Printf("\nContainers: %v\n", containers)
    fmt.Printf("Feishu Webhook: %s\n", webhookURL)
    fmt.Printf("Notification Delay: %d seconds\n\n", notificationDelaySec)
	fmt.Println("- Telegram: https://t.me/blockchain_minter")
	fmt.Println("- Github: https://github.com/whoami39\n")

	for _, containerName := range containers {
		go monitorContainerLogs(ctx, cli, containerName, webhookURL, time.Duration(notificationDelaySec)*time.Second)
	}

	select {}
}
