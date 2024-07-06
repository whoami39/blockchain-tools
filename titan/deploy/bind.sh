#!/bin/bash

# - - - - - - - - - - - - - - - - - - - - - - - #
#                                               #
# Join Telegram: https://t.me/+ZOQ2jcLKI3hkNjFl #
#                                               #
# - - - - - - - - - - - - - - - - - - - - - - - #

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root, use: sudo ./bind.sh"
    exit 1
fi

sysctl -w net.core.rmem_max=2500000
sysctl -w net.core.wmem_max=2500000
sysctl -p

hash=$1
if [ -z "$hash" ]; then
    hash="8D47E8B6-AC25-4472-BB81-40ADB9AF41F6"
fi

container_ids=$(docker ps --format '{{.Names}}' | grep titan-node)
for id in $container_ids
do
    echo "Container: $id"
    docker exec $id titan-edge bind --hash=$hash https://api-test1.container1.titannet.io/api/v2/device/binding
done

echo "Done"
