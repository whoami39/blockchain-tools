FROM ubuntu:22.04 AS dl

ARG VERSION=0.1.14
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y ca-certificates tzdata wget tar \
    && rm -rf /var/lib/apt/lists/*
RUN wget https://release.47s3rx.org/aleo-prover-${VERSION}.tar.gz \
    && tar -xf aleo-prover-${VERSION}.tar.gz \
    && mv aleo-prover app \
    && rm -f aleo-prover-${VERSION}.tar.gz

FROM ubuntu:22.04

WORKDIR /app
COPY --from=dl /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=dl /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=dl /app/*.so ./
COPY --from=dl /app/aleo-prover ./
COPY entrypoint.sh ./

ENTRYPOINT [ "/app/entrypoint.sh" ]
