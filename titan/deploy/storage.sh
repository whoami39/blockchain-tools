#!/bin/bash

storage=$1
if [ -z "$storage" ]; then
    storage="5GB"
fi

container_ids=$(docker ps --format '{{.Names}}' | grep titan-node)

for id in $container_ids
do
    echo "Container: $id, Setting storage size to $storage"
    docker exec $id titan-edge config set --storage-size $storage
done

echo "Done"
