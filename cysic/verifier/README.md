# Cysic Verifier

**English** | [简体中文](./README.zh-CN.md)

Supplement to the [official tutorial](https://medium.com/@cysic/join-the-cysic-testnet-as-a-verifier-7b9f31674b41): **Run Verifier using Docker**, participate in the Cysic testnet, **continuously updated updated...**

- Fully open-source image building, with no risks involved
- Automatic restart, no need to worry about disconnections

## Docker

```bash
docker run -e EVM_ADDR="<your-evm-address>" -d -v ./data:/app/data --network host whoami39/cysic-verifier:latest
```

## Docker Compose

Edit `docker-compose.yml` and run `docker compose up -d`

```yaml
services:
  verifier:
    image: whoami39/cysic-verifier:latest
    environment:
      - EVM_ADDR="<your-evm-address>"
    volumes:
      - ./data:/app/data
    network_mode: "host"
    restart: unless-stopped
```

You can view logs using `docker compose logs -f`
