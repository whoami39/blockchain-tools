FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

WORKDIR /app
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/prover_linux > prover && \
    curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/libdarwin_prover.so  > libzkp.so && \
    curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/libcysnet_monitor.so  > libcysnet_monitor.so && \
    curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/librsp.so  > librsp.so && \
    chmod +x ./prover

COPY . .

ENV SP1_PROVER=cuda LD_LIBRARY_PATH=/app CHAIN_ID=534352
ENTRYPOINT ["/app/entrypoint.sh"]
