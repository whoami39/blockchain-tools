# Cysic Verifier

**English** | [简体中文](./README.zh-CN.md)

Supplement to the [official tutorial](https://medium.com/@cysic/join-the-cysic-testnet-as-a-verifier-7b9f31674b41): **Run Cysic Verifier using Docker**, participate in the Cysic testnet, **continuously updated...**

- Privacy: Docker image is built based on the officially provided binary files. The build process is completely open-source, with no risks.
- Stability: Automatic restart, no need to worry about disconnections.
- Isolation: Container-based, theoretically supports multiple instances.

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
      - CHAIN_ID=534352
    volumes:
      - ./data/data:/app/data
      - ./data/cysic/:/root/.cysic/
      - ./data/scroll_prover:/root/.scroll_prover
    network_mode: "host"
    restart: unless-stopped
```

You can view logs using `docker compose logs -f`
