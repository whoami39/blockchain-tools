#!/bin/bash

set -e

while [[ $# -gt 0 ]]; do
    case "$1" in
        --account) ACCOUNT=$2; shift 2 ;;
        --pool) POOL=$2; shift 2 ;;
        --name) WORKER_NAME=$2; shift 2 ;;
        *) REST_ARGS="$REST_ARGS $1"; shift ;;
    esac
done

if [ -z "$ACCOUNT" ]; then
    echo "--account param empty"
    exit 1
fi

if [ -z "$POOL" ]; then
    POOL="wss://aleo.oula.network:6666"
fi

if [ -z "$WORKER_NAME" ]; then
    WORKER_NAME=$(hostname)
fi

PROVER_PARAMS=" --pool $POOL --account $ACCOUNT --worker-name $WORKER_NAME"

echo
echo
echo "Parameters: \`$PROVER_PARAMS\`"
echo
echo
echo "- Telegram: https://t.me/blockchain_minter"
echo "- Github: https://github.com/whoami39/blockchain-tools/tree/main/aleo/oula/prover"
echo

/app/oula-aleo-prover $PROVER_PARAMS $REST_ARGS
