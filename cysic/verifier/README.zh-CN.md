# Cysic Verifier

**简体中文** | [English](./README.md)

> 对 [官方教程](https://medium.com/@cysic/join-the-cysic-testnet-as-a-verifier-7b9f31674b41) 的补充：**使用 Docker 运行 Cysic Verifier**，参与 Cysic 测试网，**持续更新...**

- 隐私性：Docker 镜像基于官方提供二进制文件构建，构建过程完全开源，无任何风险
- 稳定性：自动重启，不用担心掉线
- 隔离性：基于容器，理论上支持多开

## Docker

```bash
docker run -e EVM_ADDR="<your-evm-address>" -d -v ./data:/app/data --network host whoami39/cysic-verifier:latest
```

## Docker Compose

新建 `docker-compose.yml` 文件（填写你的 EVM 地址）

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

执行 `docker compose up -d` 即可后台启动

你可以通过 `docker compose logs -f` 命令查看当前容器的运行日志
