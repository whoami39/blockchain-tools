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
echo "Successfully updated config.yaml with EVM_ADDR: \`$EVM_ADDR\`"
echo

exec "$@"
