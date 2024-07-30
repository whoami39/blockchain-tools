# Cysic Verifier

**简体中文** | [English](./README.md)

> 对 [官方教程](https://medium.com/@cysic/join-the-cysic-testnet-as-a-verifier-7b9f31674b41) 的补充：**使用 Docker 运行 Verifier**，参与 Cysic 测试网，**持续更新...**

- 镜像构建完全开源，无任何风险
- 自动重启，不用担心掉线

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
    volumes:
      - ./data:/app/data
    network_mode: "host"
    restart: unless-stopped
```

执行 `docker compose up -d` 即可后台启动

你可以通过 `docker compose logs -f` 命令查看当前容器的运行日志
