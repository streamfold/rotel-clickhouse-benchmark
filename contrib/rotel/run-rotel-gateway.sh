#!/bin/bash
#

if [ -z "$ROTEL_BIN" ]; then
    echo "Must set ROTEL_BIN"
    exit 1
fi

export ROTEL_MAX_CONCURRENT_ENCODERS=20
export ROTEL_MAX_CONCURRENT_REQUESTS=40

exec $ROTEL_BIN \
      --exporter clickhouse \
      --clickhouse-exporter-endpoint "http://${CLICKHOUSE_HOST:-clickhouse}:8123" \
      --clickhouse-exporter-enable-json \
      --clickhouse-exporter-database "${CLICKHOUSE_DATABASE:-otel}" \
      --receiver kafka \
      --kafka-receiver-brokers "${KAFKA_HOST:-kafka}:9092" \
      --kafka-receiver-traces
