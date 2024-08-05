#!/bin/bash

# - - - - - - - - - - - - - - - - - - - - - - - #
#                                               #
# Join Telegram: https://t.me/+ZOQ2jcLKI3hkNjFl #
#                                               #
# - - - - - - - - - - - - - - - - - - - - - - - #


if docker --version &> /dev/null
then
    echo "✅ Docker installed"
else
    echo "❌ Docker not installed, See: https://mirrors.tuna.tsinghua.edu.cn/help/docker-ce/"
fi

if docker compose version &> /dev/null
then
    echo "✅ Docker Compose installed"
else
    echo "❌ Docker Compose not installed, See: https://docs.docker.com/compose/install/"
fi

docker compose up -d

echo "You can:"
echo "    ./bind.sh <your-id-hash>  => to bind your device to the titan test network"
echo "    docker compose logs -f    => to see the logs"
echo "    docker compose down       => to stop the test service"
