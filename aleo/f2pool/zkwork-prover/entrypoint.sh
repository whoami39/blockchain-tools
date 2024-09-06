#!/bin/bash

set -e

WORKSPACE=/app

while [[ $# -gt 0 ]]; do
    case "$1" in
        --account) ACCOUNT=$2; shift 2 ;;
        --pool) POOL=$2; shift 2 ;;
        --name) WORKER_NAME=$2; shift 2 ;;
        *) REST_ARGS="$REST_ARGS $1"; shift ;;
    esac
done

POOL=${POOL:-"aleo-asia.f2pool.com:4400"}
ACCOUNT=${ACCOUNT:-"whoami39"}
WORKER_NAME=${WORKER_NAME:-"$(hostname | md5sum | cut -c1-8)"}

PROVER_PARAMS="--pool $POOL --account $ACCOUNT --custom_name $WORKER_NAME"

echo
echo
echo "Parameters: \`$PROVER_PARAMS $REST_ARGS\`"
echo
echo "- Telegram: https://t.me/blockchain_minter"
echo "- Github: https://github.com/whoami39"
echo
echo

exec $WORKSPACE/f2pool-aleo-prover $PROVER_PARAMS $REST_ARGS
