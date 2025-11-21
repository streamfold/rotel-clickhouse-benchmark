#!/bin/bash

# Load the starting DDL

set -e

docker compose run --rm clickhouse-ddl create --endpoint http://clickhouse:8123 --enable-json --traces --metrics --logs
docker compose run --rm clickhouse-ddl create --endpoint http://clickhouse:8123 --database otelnull --engine Null --enable-json --traces --metrics --logs
