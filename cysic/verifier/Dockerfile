FROM ubuntu:22.04 AS dl

WORKDIR /app
RUN apt-get update && apt-get install -y curl ca-certificates
RUN curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/verifier_linux > verifier \
    && chmod +x ./verifier
RUN curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/libdarwin_verifier.so > libdarwin_verifier.so
COPY . .

FROM ubuntu:22.04 AS final
WORKDIR /app
COPY --from=dl /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=dl /app/ /app/

ENV LD_LIBRARY_PATH=/app CHAIN_ID=534352
ENTRYPOINT ["/app/entrypoint.sh", "/app/verifier"]
