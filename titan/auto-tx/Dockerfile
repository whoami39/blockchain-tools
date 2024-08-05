# syntax=docker/dockerfile:1

FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

FROM node:20-alpine
WORKDIR /app
COPY package*.json ./

RUN npm ci --only=production
COPY --from=builder /app/src ./src
COPY --from=builder /app/index.js .

CMD ["node", "index.js"]
