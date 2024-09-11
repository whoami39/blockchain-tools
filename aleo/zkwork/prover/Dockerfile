FROM ubuntu:22.04 AS dl

ARG VERSION=v0.1.1
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y ca-certificates tzdata wget \
    && rm -rf /var/lib/apt/lists/*
RUN wget https://github.com/6block/zkwork_aleo_gpu_worker/releases/download/${VERSION}/aleo_prover-${VERSION}.tar.gz \
    && tar -zxf aleo_prover-*.tar.gz \
    && mv ./aleo_prover/aleo_prover ./zkwork-aleo-prover \
    && chmod +x zkwork-aleo-prover

FROM ubuntu:22.04

WORKDIR /app
COPY --from=dl /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=dl /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=dl /zkwork-aleo-prover ./
COPY entrypoint.sh ./

ENTRYPOINT [ "/app/entrypoint.sh" ]
