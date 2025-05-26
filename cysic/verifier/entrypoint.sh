#!/bin/sh

if [ -z "${EVM_ADDR}" ]; then
    echo "Error: EVM_ADDR environment variable is not set or is empty"
    exit 1
fi

sed -i "s|__EVM_ADDRESS__|$EVM_ADDR|g" ./config.yaml

if [ $? -ne 0 ]; then
    echo "Error: Failed to replace __EVM_ADDRESS__ in config.yaml"
    exit 1
fi

echo
echo
echo "[Testnet Phase 3] EVM_ADDR: \`$EVM_ADDR\`, CHAIN_ID: $CHAIN_ID"
echo
echo "- Telegram: https://t.me/blockchain_minter"
echo "- Github: https://github.com/whoami39"
echo
echo

exec "$@"
