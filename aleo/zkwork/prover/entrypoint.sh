#!/bin/bash

set -e

WORKSPACE=/app

while [[ $# -gt 0 ]]; do
    case "$1" in
        --address) ADDRESS=$2; shift 2 ;;
        --pool) POOL=$2; shift 2 ;;
        --name) WORKER_NAME=$2; shift 2 ;;
        --network) NETWORK=$2; shift 2 ;;
        *) REST_ARGS="$REST_ARGS $1"; shift ;;
    esac
done

POOL=${POOL:-"aleo.hk.zk.work:10003"}
ADDRESS=${ADDRESS:-"aleo1lk4klsu09ekv4gd0q4ql2wkn7a0hkfcwamlsw9n79dmlyr9esu9qwra6cc"}
WORKER_NAME=${WORKER_NAME:-"$(hostname | md5sum | cut -c1-8)"}


PROVER_PARAMS="--pool $POOL --address $ADDRESS --custom_name $WORKER_NAME"

echo
echo
echo "Parameters: \`$PROVER_PARAMS $REST_ARGS\`"
echo
echo "- Telegram: https://t.me/blockchain_minter"
echo "- Github: https://github.com/whoami39"
echo
echo

exec $WORKSPACE/zkwork-aleo-prover $PROVER_PARAMS $REST_ARGS
