# syntax=docker/dockerfile:1
FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY . .
RUN --mount=type=cache,target=/go --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 go build -a --trimpath --ldflags='-s -w' -o main .

FROM scratch
WORKDIR /app
COPY --from=builder /src/main ./

ENTRYPOINT ["/app/main"]
