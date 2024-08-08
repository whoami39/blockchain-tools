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
	"strings"

	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/client"
	_ "github.com/joho/godotenv/autoload"
)

func monitorContainerLogs(ctx context.Context, cli *client.Client, containerName, webhookURL string) {
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
			message := fmt.Sprintf("Container `%s` has completed a task: txhash is: `%s`", containerName, txHash)
			sendFeishuMessage(message, webhookURL)
		}
	}

	if err := scanner.Err(); err != nil {
		log.Printf("Error reading logs for container %s: %v\n", containerName, err)
	}
}

// Send a message to Feishu
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

func main() {
	ctx := context.Background()
	cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
	if err != nil {
		log.Fatal("Error creating Docker client:", err)
	}

	containers := strings.Split(os.Getenv("CONTAINERS"), ",")
	webhookURL := os.Getenv("FEISHU_WEBHOOK")

	fmt.Printf("\nContainers: %s\n", os.Getenv("CONTAINERS"))
	fmt.Printf("Feishu Webhook: %s\n\n", webhookURL)
	fmt.Println("- Telegram: https://t.me/blockchain_minter")
	fmt.Println("- Github: https://github.com/whoami39\n")

	for _, containerName := range containers {
		go monitorContainerLogs(ctx, cli, containerName, webhookURL)
	}

	select {}
}
