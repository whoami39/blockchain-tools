FROM ubuntu:22.04 as dl

ARG VERSION=v0.1.15
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y ca-certificates tzdata wget tar \
    && rm -rf /var/lib/apt/lists/*
RUN wget https://github.com/cysic-labs/aleo-miner/releases/download/${VERSION}/cysic-prover-agent-${VERSION}.tgz \
    && tar -xf cysic-prover-agent-${VERSION}.tgz \
    && mv cysic-prover-agent-${VERSION} app \
    && rm -f cysic-prover-agent-${VERSION}.tgz

FROM scratch

COPY --from=dl /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=dl /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=dl /app/cysic-prover-agent .

ENV AGENT_HOST=0.0.0.0:9000
ENV NOTIFY_HOST=notify.asia.aleopool.cysic.xyz:38883
ENTRYPOINT [ "/cysic-prover-agent", "-l", "${AGENT_HOST}", "-notify", "${NOTIFY_HOST}" ]
