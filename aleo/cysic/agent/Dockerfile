FROM ubuntu:22.04 AS dl

ARG VERSION=v0.1.12
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y ca-certificates tzdata wget tar \
    && rm -rf /var/lib/apt/lists/*
RUN wget https://release.47s3rx.org/prover-agent-${VERSION}.tgz \
    && ls -al \
    && tar -xf prover-agent-${VERSION}.tgz \
    && mv prover-agent-${VERSION} app \
    && rm -f prover-agent-${VERSION}.tgz

FROM ubuntu:22.04

COPY --from=dl /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=dl /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=dl /app/prover-agent .
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
