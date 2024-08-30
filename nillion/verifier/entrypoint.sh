#!/bin/bash

set -e

RPC_ENDPOINT=${RPC_ENDPOINT:-"testnet-nillion-rpc.lavenderfive.com"}
BLOCK_OFFSET=${BLOCK_OFFSET:-10000}

rpc_status=""
latest_block_height=$BLOCK_OFFSET
while true
do
    rpc_status=$(curl -s https://$RPC_ENDPOINT/status)
    catching_up=$(echo $rpc_status | jq -r '.result.sync_info.catching_up')
    latest_block_height=$(echo $rpc_status | jq -r '.result.sync_info.latest_block_height')
    if [ "$catching_up" = "false" ]; then
        break
    fi
    echo "[`date`] Remote RPC node is still syncing, please wait... Current block height: \`$latest_block_height\`"
    sleep 60
done

if [ -z "$BLOCK_START" ]; then
    BLOCK_START=$(($latest_block_height - $BLOCK_OFFSET))
fi

echo
echo
echo "RPC_ENDPOINT: \`$RPC_ENDPOINT\`, BLOCK_START: \`$BLOCK_START\`"
echo
echo "- Telegram: https://t.me/blockchain_minter"
echo "- Github: https://github.com/whoami39"
echo
echo

/home/accuseruser/local/bin/accuser accuse --rpc-endpoint "https://$RPC_ENDPOINT" --block-start $BLOCK_START
