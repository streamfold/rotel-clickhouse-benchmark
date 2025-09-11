FROM golang:1.25-alpine AS builder

WORKDIR /app

RUN go install github.com/open-telemetry/opentelemetry-collector-contrib/cmd/telemetrygen@latest

FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /go/bin/telemetrygen .

ENTRYPOINT ["./telemetrygen"]