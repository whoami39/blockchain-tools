#!/bin/bash

set -e

PKG_DIR=/app

while [[ $# -gt 0 ]]; do
    case "$1" in
        --address) ADDRESS=$2; shift 2 ;;
        --pool) POOL_HOST=$2; shift 2 ;;
        --socks) SOCKS_HOST=$2; shift 2 ;;
        --agent) AGENT_HOST=$2; shift 2 ;;
        --name) WORKER_NAME=$2; shift 2 ;;
        *) REST_ARGS="$REST_ARGS $1"; shift ;;
    esac
done

if [ -z "$ADDRESS" ]; then
    echo "--address param empty"
    exit 1
fi

if [ -z "$AGENT_HOST" ]; then
    AGENT_HOST="host.docker.internal:9000"
fi

if [ -z "$POOL_HOST" ]; then
    POOL_HOST="tls://asia.aleopool.cysic.xyz:16699"
fi

if [ -z "$WORKER_NAME" ]; then
    WORKER_NAME=$(hostname)
fi

ADDRESS_WORKER=$ADDRESS.$WORKER_NAME
PROVER_PARAMS=" -l $PKG_DIR/log/prover.log -a $AGENT_HOST -w $ADDRESS_WORKER " 

if [[ $POOL_HOST == tcp://* ]]; then
    #tcp
    POOL_HOST=${POOL_HOST#tcp://}
    PROVER_PARAMS=$PROVER_PARAMS" -p $POOL_HOST "
elif [[ $POOL_HOST == tls://* ]]; then
    #tls
    POOL_HOST=${POOL_HOST#tls://}
    PROVER_PARAMS=$PROVER_PARAMS" -tls=true -p $POOL_HOST "
else
    echo "--pool param err"
    exit 1
fi

if [[ -n "$SOCKS_HOST" ]]; then
    PROVER_PARAMS=$PROVER_PARAMS" -sock $SOCKS_HOST"
fi

echo
echo
echo "Parameters: \`$PROVER_PARAMS\`"
echo
echo
echo "- Telegram: https://t.me/blockchain_minter"
echo "- Github: https://github.com/whoami39/blockchain-tools/tree/main/cysic/aleo-miner"
echo

mkdir -p $PKG_DIR/log
export LD_LIBRARY_PATH=$PKG_DIR:$LD_LIBRARY_PATH
exec $PKG_DIR/cysic-aleo-prover $PROVER_PARAMS $REST_ARGS
