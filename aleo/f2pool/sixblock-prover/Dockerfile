FROM ubuntu:22.04 AS dl

ARG VERSION=v0.1.0
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y ca-certificates tzdata wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/6block/f2pool_prover/releases/download/${VERSION}/f2pool_prover-${VERSION}.tar.gz \
    && tar -zxf f2pool_prover-*.tar.gz \
    && mv ./f2pool_prover/f2pool_prover ./f2pool-aleo-prover \
    && chmod +x f2pool-aleo-prover

FROM ubuntu:22.04

WORKDIR /app
COPY --from=dl /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=dl /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=dl /f2pool-aleo-prover ./
COPY entrypoint.sh ./

ENTRYPOINT [ "/app/entrypoint.sh" ]
