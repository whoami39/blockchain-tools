# syntax=docker/dockerfile:1
FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY . .
RUN apk add --no-cache gcc musl-dev
RUN --mount=type=cache,target=/go --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=1 GOOS=linux go build -a --trimpath --ldflags='-linkmode external -extldflags "-static"' -o cysic-verifier-db-cli .

FROM alpine:latest
WORKDIR /app
COPY --from=builder /src/cysic-verifier-db-cli ./

ENTRYPOINT ["/app/cysic-verifier-db-cli"]
