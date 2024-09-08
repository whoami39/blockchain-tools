FROM ubuntu:22.04 AS dl

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y ca-certificates tzdata wget unzip \
    && rm -rf /var/lib/apt/lists/*
RUN wget https://public-download-ase1.s3.ap-southeast-1.amazonaws.com/aleo-miner/aleominer+2.11.47.zip \
    && unzip aleominer*.zip \
    && mv aleominer f2pool-aleo-prover \
    && chmod +x f2pool-aleo-prover

FROM ubuntu:22.04

WORKDIR /app
COPY --from=dl /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=dl /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=dl /f2pool-aleo-prover ./
COPY entrypoint.sh ./

ENTRYPOINT [ "/app/entrypoint.sh" ]
