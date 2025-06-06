FROM golang:1.23-alpine3.20 AS builder

RUN apk update && apk add --no-cache gcc musl-dev gcompat

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
ENV CGO_ENABLED=1
RUN go build -o wuzapi

FROM alpine:3.20

RUN apk update && apk add --no-cache \
    ca-certificates \
    netcat-openbsd \
    postgresql-client \
    openssl \
    curl \
    ffmpeg \
    tzdata

ENV TZ="America/Sao_Paulo"
WORKDIR /app

COPY --from=builder /app/wuzapi         /app/
COPY --from=builder /app/static         /app/static/
COPY --from=builder /app/wuzapi.service /app/wuzapi.service
COPY .env                               /app/.env

RUN chmod +x /app/wuzapi
RUN chmod -R 755 /app
RUN chown -R root:root /app

ENTRYPOINT ["/app/wuzapi", "--logtype=console", "--color=true"]