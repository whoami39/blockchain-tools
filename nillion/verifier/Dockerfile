FROM nillion/retailtoken-accuser:v1.0.0

RUN apt-get update \
    && apt-get install -y curl jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
