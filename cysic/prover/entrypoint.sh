#!/bin/bash

workspace=$(cd $(dirname $0) && pwd)

ETH_PROOF_ENDPOINT=${ETH_PROOF_ENDPOINT:-https://ethereum-rpc.publicnode.com}

args=("$@")
if [ ${#args[@]} -le 1 ]; then

    EVM_ADDR=${1:-$EVM_ADDR}

    if [ -z "$EVM_ADDR" ]; then
        echo "Error: EVM_ADDR environment variable is not set or is empty"
        exit 1
    fi

    rm -f $workspace/config.yaml
    cp $workspace/.template.yaml $workspace/config.yaml 

    sed -i "s|__EVM_ADDRESS__|$EVM_ADDR|g" $workspace/config.yaml
    sed -i "s|__ETH_PROOF_ENDPOINT__|$ETH_PROOF_ENDPOINT|g" $workspace/config.yaml

    echo
    echo -e "\033[1;32m"
    echo "[Testnet Phase 3] EVM_ADDR: \`$EVM_ADDR\`, ETH_PROOF_ENDPOINT: \`$ETH_PROOF_ENDPOINT\`"
    echo -e "\033[3;36m"
    echo "- Telegram Group: https://t.me/blockchain_minter"
    echo "- Github: https://github.com/whoami39"
    echo -e "\033[0m"
    echo

    exec $workspace/prover
else
    exec $workspace/auto.sh "$@"
fi
