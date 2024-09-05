#!/bin/bash

set -e

WORKSPACE=/app

get_available_gpus() {
    if ! command -v nvidia-smi &> /dev/null; then
        echo ""
        return
    fi

    local gpu_info
    local gpu_count=0
    local gpu_str=""

    gpu_info=$(nvidia-smi -L)

    while read -r line; do
        if [ $gpu_count -eq 0 ]; then
            gpu_str="${gpu_count}"
        else
            gpu_str="${gpu_str},${gpu_count}"
        fi
        ((gpu_count++))
    done <<< "$gpu_info"

    echo "$gpu_str"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -u) POOL=$2; shift 2 ;;
        -w) WORKER=$2; shift 2 ;;
        -d) GPU=$2; shift 2 ;;
        *) REST_ARGS="$REST_ARGS $1"; shift ;;
    esac
done

POOL=${POOL:-"stratum+tcp://aleo-asia.f2pool.com:4400"}
WORKER=${WORKER:-"whoami39.$(hostname | md5sum | cut -c1-8))"}
GPU=${GPU:-"$(get_available_gpus)"}

PROVER_PARAMS="-u $POOL -w $WORKER -d $GPU"

echo
echo
echo "Parameters: \`$PROVER_PARAMS\`"
echo
echo "- Telegram: https://t.me/blockchain_minter"
echo "- Github: https://github.com/whoami39/blockchain-tools/tree/main/cysic/aleo-miner"
echo
echo

exec $WORKSPACE/f2pool-aleo-prover $PROVER_PARAMS $REST_ARGS
