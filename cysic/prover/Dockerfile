FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

WORKDIR /app
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/libdarwin_prover.so  > libdarwin_prover.so && \
    curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/libzkp.so  > libzkp.so && \
    curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/libcysnet_monitor.so  > libcysnet_monitor.so && \
    curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/monitor_linux > prover && \
    chmod +x ./prover
COPY . .

ENV LD_LIBRARY_PATH=/app CHAIN_ID=534352
ENTRYPOINT ["/app/entrypoint.sh"]
