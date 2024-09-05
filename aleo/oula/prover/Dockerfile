FROM ubuntu:22.04 AS dl

ARG VERSION=v1.8.1
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y ca-certificates tzdata wget \
    && rm -rf /var/lib/apt/lists/*
RUN wget https://github.com/oula-network/aleo/releases/download/${VERSION}/oula-pool-prover \
    && mv oula-pool-prover oula-aleo-prover \
    && chmod +x oula-aleo-prover

FROM ubuntu:22.04

WORKDIR /app
COPY --from=dl /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=dl /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=dl /oula-aleo-prover ./
COPY entrypoint.sh ./

ENTRYPOINT [ "/app/entrypoint.sh" ]
