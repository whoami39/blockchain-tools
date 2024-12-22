#!/bin/bash

EVM_ADDR=$1

if [ -z "$EVM_ADDR" ]; then
    echo 
    echo "Usage: $0 <evm_addr>"
    echo
    echo "Create by h3110w0r1d, If you have any questions: https://t.me/blockchain_minter"
    echo
    exit 1
fi

send_feishu_message() {
    local message="$1"
    local webhook_url="$2"

    payload=$(cat <<EOF
{
    "msg_type": "text",
    "content": {
        "text": "$message"
    }
}
EOF
)
    response=$(curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$webhook_url")
    http_status=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "$payload" "$webhook_url")
    if [ "$http_status" != "200" ]; then
        echo "Error sending message to Feishu, status code: $http_status"
        echo "Response: $response"
    fi
}

while true
do
    /app/entrypoint.sh $EVM_ADDR

    exit_status=$?
    if [ $exit_status -eq 130 ]; then
        echo "Received SIGINT, exiting..."
        exit 130
    fi

    message="`$EVM_ADDR` exited with status $exit_status, restarting..."

    if [ -n "$FEISHU_WEBHOOK" ]; then
        send_feishu_message "$message" "$FEISHU_WEBHOOK"
    fi
    echo "\n\n$message\n\n"
    sleep 6
done
