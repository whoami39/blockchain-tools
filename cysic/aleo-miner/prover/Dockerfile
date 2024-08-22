FROM ubuntu:22.04 AS dl

ARG VERSION=v0.1.17
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y ca-certificates tzdata wget tar \
    && rm -rf /var/lib/apt/lists/*
RUN wget https://github.com/cysic-labs/aleo-miner/releases/download/${VERSION}/cysic-aleo-prover-${VERSION}.tgz \
    && tar -xf cysic-aleo-prover-${VERSION}.tgz \
    && mv cysic-aleo-prover-${VERSION} app \
    && rm -f cysic-aleo-prover-${VERSION}.tgz

FROM ubuntu:22.04

WORKDIR /app
COPY --from=dl /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=dl /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=dl /app/*.so ./
COPY --from=dl /app/cysic-aleo-prover ./
COPY entrypoint.sh ./

ENTRYPOINT [ "/app/entrypoint.sh" ]
