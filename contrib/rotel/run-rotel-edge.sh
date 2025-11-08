#!/bin/bash
#

if [ -z "$ROTEL_BIN" ]; then
    echo "Must set ROTEL_BIN"
    exit 1
fi

exec $ROTEL_BIN start \
    --exporter=kafka \
    --kafka-exporter-brokers ${KAFKA_HOST:-kafka}:9092 \
    --kafka-exporter-max-message-bytes 5242880 \
    --kafka-exporter-compression zstd
