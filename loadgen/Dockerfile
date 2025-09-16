FROM golang:1.25-alpine AS builder

WORKDIR /app

RUN go install github.com/streamfold/otel-loadgen@latest

FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /go/bin/otel-loadgen .

ENTRYPOINT ["./otel-loadgen"]