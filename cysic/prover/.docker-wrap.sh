#!/bin/bash

# Fake by h3110w0r1d ( Telegram: https://t.me/blockchain_minter )

SERVER_BIN="/usr/local/bin/moongate-server"
SERVER_PID=""
SERVER_PID_FILE=".moongate_server.pid"

docker_wrap() {
  case "$1" in
    "run")
        shift

        RUST_LOG_VAL=""
        CONTAINER_NAME=""

        if [[ -f "$SERVER_PID_FILE" ]]; then
            EXISTING_PID=$(cat "$SERVER_PID_FILE")
            if kill -0 "$EXISTING_PID" 2>/dev/null; then
                echo "Error: moongate-server is already running (PID: $EXISTING_PID)"
                exit 1
            else
                rm -f "$SERVER_PID_FILE"
            fi
        fi
        
        while [[ $# -gt 0 ]]; do
            case $1 in
                "-e")
                    shift
                    if [[ $1 == RUST_LOG=* ]]; then
                        RUST_LOG_VAL="${1#RUST_LOG=}"
                        export RUST_LOG="$RUST_LOG_VAL"
                    fi
                    shift
                    ;;
                "--name")
                    shift
                    CONTAINER_NAME="$1"
                    shift
                    ;;
                "-p"|"--rm"|"--gpus")
                    shift
                    if [[ $1 != "-"* ]] && [[ $1 != "--"* ]]; then
                        shift
                    fi
                    ;;
                *)
                    shift
                    ;;
            esac
        done
        
        echo "Starting moongate-server locally..."
        echo "RUST_LOG=$RUST_LOG"
        echo "Container name: $CONTAINER_NAME"

        if [[ ! -f "$SERVER_BIN" ]]; then
            echo "Error: $SERVER_BIN not found"
            exit 1
        fi

        trap 'cleanup_current_process' EXIT INT TERM

        command $SERVER_BIN &
        SERVER_PID=$!

        sleep 0.5
        if ! kill -0 "$SERVER_PID" 2>/dev/null; then
            echo "Error: Failed to start moongate-server"
            exit 1
        fi
        
        echo $SERVER_PID > "$SERVER_PID_FILE"
        echo "Server started with PID: $SERVER_PID"

        wait $SERVER_PID
        ;;
        
    "rm"|"stop"|"kill")
        shift
        CONTAINER_NAME="$1"
        
        if [[ -f "$SERVER_PID_FILE" ]]; then
            SERVER_PID=$(cat "$SERVER_PID_FILE")
            if kill -0 "$SERVER_PID" 2>/dev/null; then
                echo "Stopping moongate-server (PID: $SERVER_PID)..."
                kill "$SERVER_PID"

                for i in {1..5}; do
                    if ! kill -0 "$SERVER_PID" 2>/dev/null; then
                        break
                    fi
                    sleep 1
                done

                if kill -0 "$SERVER_PID" 2>/dev/null; then
                    echo "Force killing moongate-server..."
                    kill -9 "$SERVER_PID"
                    sleep 1
                fi
                
                rm -f "$SERVER_PID_FILE"
                echo "Container '$CONTAINER_NAME' stopped"
            else
                echo "Process $SERVER_PID not found"
                rm -f "$SERVER_PID_FILE"
            fi
        else
            echo "No running server found"
        fi
        ;;
        
    "ps")
        if [[ -f "$SERVER_PID_FILE" ]]; then
            SERVER_PID=$(cat "$SERVER_PID_FILE")
            if kill -0 "$SERVER_PID" 2>/dev/null; then
                printf "%-15s %-15s %-15s %-15s %-15s %-30s %s\n" "CONTAINER ID" "IMAGE" "COMMAND" "CREATED" "STATUS" "PORTS" "NAMES"
                printf "%-15s %-15s %-15s %-15s %-15s %-30s %s\n" "fake_$(echo $SERVER_PID)" "moongate:v4.1.0" "moongate-server" "2 minutes ago" "Up 2 minutes" "0.0.0.0:3000->3000/tcp" "moongate-container"
            else
                echo "CONTAINER ID   IMAGE   COMMAND   CREATED   STATUS   PORTS   NAMES"
                rm -f "$SERVER_PID_FILE"
            fi
        else
            echo "CONTAINER ID   IMAGE   COMMAND   CREATED   STATUS   PORTS   NAMES"
        fi
        ;;
        
    *)
        echo "Fake by h3110w0r1d ( Telegram: https://t.me/blockchain_minter )"
        ;;
  esac
}

cleanup_current_process() {
    if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
        echo "Cleaning up server process (PID: $SERVER_PID)..."
        kill "$SERVER_PID"
        if [[ -f "$SERVER_PID_FILE" ]]; then
            STORED_PID=$(cat "$SERVER_PID_FILE")
            if [[ "$STORED_PID" == "$SERVER_PID" ]]; then
                rm -f "$SERVER_PID_FILE"
            fi
        fi
    fi
}

docker_wrap "$@"
