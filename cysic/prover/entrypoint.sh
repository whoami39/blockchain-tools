#!/bin/bash

workspace=$(cd $(dirname $0) && pwd)

args=("$@")
if [ ${#args[@]} -eq 0 ]; then
    if [ -z "${EVM_ADDR}" ]; then
        echo "Error: EVM_ADDR environment variable is not set or is empty"
        exit 1
    fi

    rm -f $workspace/config.yaml
    cp $workspace/.template.yaml $workspace/config.yaml 

    sed -i "s|__EVM_ADDRESS__|$EVM_ADDR|g" $workspace/config.yaml
    if [ $? -ne 0 ]; then
        echo "Error: Failed to replace __EVM_ADDRESS__ in config.yaml"
        exit 1
    fi

    echo
    echo
    echo "[Testnet Phase 2] EVM_ADDR: \`$EVM_ADDR\`, CHAIN_ID: $CHAIN_ID"
    echo
    echo "- Telegram: https://t.me/blockchain_minter"
    echo "- Github: https://github.com/whoami39"
    echo
    echo

    exec $workspace/prover
else
    exec $workspace/auto.sh "$@"
fi
