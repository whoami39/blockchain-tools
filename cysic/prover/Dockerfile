FROM public.ecr.aws/succinct-labs/moongate:v4.1.0

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates build-essential git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="$PATH:/root/.cargo/bin:/root/.sp1/bin"
RUN mkdir -p /root/.sp1/bin && \
    curl -L https://raw.githubusercontent.com/succinctlabs/sp1/main/sp1up/sp1up -o /root/.sp1/bin/sp1up && \
    chmod +x /root/.sp1/bin/sp1up && \
    sp1up

WORKDIR /app
RUN curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/prover_linux > prover && \
    curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/libdarwin_prover.so  > libzkp.so && \
    curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/libcysnet_monitor.so  > libcysnet_monitor.so && \
    curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/librsp.so  > librsp.so && \
    chmod +x ./prover
COPY .docker-wrap.sh /usr/local/bin/docker
COPY . .

ENV SP1_PROVER=cuda LD_LIBRARY_PATH=/app CHAIN_ID=534352
ENTRYPOINT ["/app/entrypoint.sh"]
