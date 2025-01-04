#!/bin/bash


echo
echo -e "\033[1;32m"
echo "Automatic scheduling program for cysic prover, create by h3110w0r1d"
echo -e "\033[3;36m"
echo "- Telegram Group: https://t.me/blockchain_minter"
echo "- Github: https://github.com/whoami39"
echo -e "\033[0m"
echo


workspace=$(cd $(dirname $0) && pwd)
runtime_log=$workspace/runtime.log
auto_log=$workspace/auto.log

args=("$@")
if [ ${#args[@]} -eq 0 ]; then
    echo "Please provide at least one EVM address"
    exit 1
fi

for arg in "${args[@]}"; do
    if [[ ! $arg =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        echo "err: $arg is not a valid evm address"
        exit 1
    fi
done

log() {
    local message="$1"
    local log_file="${2:-$auto_log}"
    local current_time=$(date +"%Y/%m/%d_%H:%M:%S")
    echo "[$current_time] $message" | tee -a "$log_file"
}

send_feishu_message() {
    local message="$1"
    local webhook_url="$FEISHU_WEBHOOK"

    if [ -z "$FEISHU_WEBHOOK" ]; then
        return
    fi

    payload=$(cat <<EOF
{
    "msg_type": "text",
    "content": {
        "text": "$message"
    }
}
EOF
)
    response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$payload" "$webhook_url")
    http_status=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')
    if [ "$http_status" != "200" ]; then
        log "Error sending message to Feishu, status code: $http_status"
        log "Response: $response_body"
    fi
}

start() {
    local address=$1

    rm -f $workspace/config.yaml
    cp $workspace/.template.yaml $workspace/config.yaml
    sed -i "s|__EVM_ADDRESS__|$address|g" $workspace/config.yaml

    mkdir -p $workspace/data/bak
    mv -f $workspace/data/*.db $workspace/data/bak/ &> /dev/null

    echo -e > $runtime_log
    $workspace/prover &> $runtime_log &
    prover_pid=$!

    log "Started prover for address: $address (PID: $prover_pid)"
    send_feishu_message "Prover [$address] started"
}

stop() {
    if [ ! -z "$prover_pid" ]; then
        log "Attempting to stop prover (PID: $prover_pid)"
        kill $prover_pid 2>/dev/null || true
        wait $prover_pid 2>/dev/null || true
        prover_pid=
        log "Stopped prover"
    else
        log "No prover process to stop"
    fi
}

check() {
    if [ $(grep -c "resp: code: 0" $runtime_log) -ge 4 ]; then
        return 0
    fi
    return 1
}

trap 'echo "Received SIGTERM/SIGINT signal, exiting..."; stop; exit 143' SIGTERM SIGINT

current_index=0
while true
do
    current_address="${args[$current_index]}"
    start $current_address

    while true
    do
        if check; then
            sleep 180 &
            wait $!

            stop
            log "Prover [$current_address] finished task"
            send_feishu_message "Prover [$current_address] finished task"
            break
        fi
        sleep 30 &
        wait $!
    done

    current_index=$(( (current_index + 1) % ${#args[@]} ))
    sleep 30 &
    wait $!
done
