#!/bin/sh

if [ -z "$AGENT_HOST" ]; then
    AGENT_HOST="0.0.0.0:9000"
fi

if [ -z "$NOTIFY_HOST" ]; then
    NOTIFY_HOST="notify.asia.aleopool.cysic.xyz:38883"
fi

echo
echo
echo "Parameters: \`-l ${AGENT_HOST} -notify ${NOTIFY_HOST} $@\`"
echo
echo
echo "- Telegram: https://t.me/blockchain_minter"
echo "- Github: https://github.com/whoami39/blockchain-tools/tree/main/cysic/aleo-miner"
echo

exec /cysic-prover-agent -l "${AGENT_HOST}" -notify "${NOTIFY_HOST}" "$@"
