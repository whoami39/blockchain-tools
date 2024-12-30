#!/bin/bash

set -e

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
    exec $workspace/prover
    exit 1
fi

for arg in "${args[@]}"; do
    if [[ ! $arg =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        echo "err: $arg is not a valid evm address"
        exit 0
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

is_single=0
if [ ${#args[@]} -eq 1 ]; then
    log "single mode"
    is_single=1
fi

if ! command -v supervisorctl &> /dev/null; then
    apt-get update && apt-get install supervisor -y
fi

if [ ! -f /etc/supervisor/conf.d/prover.conf ]; then
    bash -c "cat <<EOF > /etc/supervisor/conf.d/prover.conf
[program:prover]
command=$workspace/auto.sh
directory=$workspace
environment=LD_LIBRARY_PATH=/app,CHAIN_ID=534352
autostart=false
autorestart=true
stdout_logfile=$runtime_log
stderr_logfile=NONE
redirect_stderr=true
user=root
stopasgroup=true
killasgroup=true
stdout_logfile_maxbytes=0
stdout_logfile_backups=0

EOF"
    supervisorctl reread
    supervisorctl update
fi

if ! pgrep -x "supervisord" &> /dev/null; then
    service supervisor start
fi

_run_next () {
    local arg=$1

    if supervisorctl status prover | grep -q "RUNNING"; then
        supervisorctl stop prover
    fi

    rm -f $workspace/config.yaml
    cp $workspace/.template.yaml $workspace/config.yaml
    sed -i "s|__EVM_ADDRESS__|$arg|g" $workspace/config.yaml

    mkdir -p $workspace/data/bak
    mv -f $workspace/data/*.db $workspace/data/bak/ &> /dev/null

    echo -e > $runtime_log
    supervisorctl start prover
}

current_index=0
next() {
    local arg="${args[$current_index]}"

    _run_next $arg
    log "current work address: $arg"

    local message="prover [$arg] started"
    send_feishu_message "$message"
}

check() {
    if [ ! -f $runtime_log ]; then
        return 1
    fi

    if [ $is_single -eq 1 ]; then
        return 1
    fi

    if [ $(grep -c "resp: code: 0" $runtime_log) -ge 4 ]; then
        return 0
    fi
    return 1
}

trap 'echo "Received SIGTERM/SIGINT signal, exiting..."; supervisorctl stop prover; exit 143' SIGTERM SIGINT

next
while true
do
    if check; then
        sleep 180 &
        wait $!

        current_evm="${args[$current_index]}"
        message="prover [$current_evm] finished task"
        send_feishu_message "$message"

        sleep 3 &
        wait $!

        current_index=$(( (current_index + 1) % ${#args[@]} ))
        next
    fi
    sleep 60 &
    wait $!
done
