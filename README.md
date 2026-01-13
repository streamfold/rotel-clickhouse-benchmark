# Rotel ClickHouse Benchmark

A comprehensive benchmarking environment for testing OpenTelemetry data ingestion and processing using ClickHouse as the backend storage, using both [Rotel](https://rotel.dev) and [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/) configurations.

## Architecture Overview

This repository provides a complete observability pipeline with multiple data processing paths for performance comparison:

```
[Load Generator] → [Edge Collector] → [Kafka] → [Gateway Collector] → [ClickHouse] (→ [HyperDX UI])
```

## Services

### Core Infrastructure

#### **kafka**
- **Image**: `apache/kafka:4.1.0`
- **Purpose**: Message broker for telemetry data streaming
- **Ports**: 9092 (Kafka), 9093 (Controller)
- **Configuration**: 12 partitions, 5MB max message size, Zstandard compression support

#### **clickhouse**
- **Image**: `clickhouse/clickhouse-server:latest`
- **Purpose**: High-performance columnar database for telemetry data storage
- **Ports**: 8123 (HTTP), 9000 (Native)
- **Dependencies**: clickhouse-keeper

#### **clickhouse-keeper**
- **Image**: `clickhouse/clickhouse-keeper:latest-alpine`
- **Purpose**: Coordination service for ClickHouse cluster
- **Port**: 9181 (internal)

#### **clickhouse-ddl**
- **Image**: `streamfold/rotel-clickhouse-ddl`
- **Purpose**: Database schema initialization for OpenTelemetry tables

### Data Processors

#### **rotel-edge**
- **Image**: `streamfold/rotel`
- **Purpose**: High-performance edge processor that receives OTLP data and forwards to Kafka
- **Ports**: 4317 (OTLP gRPC), 4318 (OTLP HTTP)
- **Features**: Zstandard compression, configurable message batching

#### **rotel-gateway**
- **Image**: `streamfold/rotel`
- **Purpose**: Gateway processor that consumes from Kafka and writes to ClickHouse
- **Features**: JSON export format, handles traces and logs

#### **otel-coll-edge**
- **Image**: `otel/opentelemetry-collector-contrib`
- **Purpose**: OpenTelemetry Collector configured as edge processor
- **Ports**: 4317 (OTLP gRPC), 4318 (OTLP HTTP), 8888 (Prometheus metrics)

#### **otel-coll-gateway**
- **Image**: `otel/opentelemetry-collector-contrib`
- **Purpose**: OpenTelemetry Collector configured as gateway processor
- **Ports**: 8888 (Prometheus metrics), 13133 (health check)

#### **otel-collector** (Standalone)
- **Image**: `otel/opentelemetry-collector-contrib`
- **Purpose**: Direct processing pipeline (bypasses Kafka)
- **Ports**: 4317 (OTLP gRPC), 4318 (OTLP HTTP), 8888 (Prometheus metrics)

### Data Generation

#### **telemetrygen**
- **Purpose**: Generates synthetic OpenTelemetry traces, metrics, and logs
- **Built from**: `open-telemetry/opentelemetry-collector-contrib/cmd/telemetrygen`

#### **loadgen**
- **Purpose**: Advanced load generation with configurable patterns
- **Built from**: `streamfold/otel-loadgen`

### Visualization

#### **hyper-dx**
- **Image**: `docker.hyperdx.io/hyperdx/hyperdx-local`
- **Purpose**: Web UI for querying and visualizing telemetry data from ClickHouse
- **Port**: 8080

## Usage

This assumes an AWS environment.

### Setup after starting instances from stopped state

#### ClickHouse

If using instance storage, after the first start from stopped state you must reintialize the data
drive and set sysctl's with:

```bash
./contrib/clickhouse/mount-clickhouse.sh

./contrib/clickhouse/config-sys.sh
```

To start Clickhouse:
```bash
docker compose up -d clickhouse
```

Once started, load the default schemas:
```bash
./contrib/clickhouse/load-ddl.sh
```

#### Kafka

To remount the EBS drive after a stopped instance state, run:

```bash
./contrib/kafka/mount-kafka.sh
```

For instance store:

```bash
./contrib/kafka/mount-kafka-nvme.sh
```

To start Kafka:
```bash
docker compose up -d kafka
```

To monitor consumer groups (they must exist first):
```bash
./contrib/kafka/run-kafkatop.sh
```

### Running the pipeline

#### Gateway collector

Rotel:
```bash
CLICKHOUSE_DATABASE=otelnull docker compose up rotel-gateway
```

Or from a particular branch version, make sure to build it first:
```bash
ROTEL_GIT_BRANCH=<branch or sha> docker compose build --no-cache rotel-gateway-branch

ROTEL_GIT_BRANCH=<branch or sha> CLICKHOUSE_DATABASE=otelnull docker compose up rotel-gateway-branch
```

#### Edge collector

Rotel:
```bash
docker compose up rotel-edge
```

#### Load Generator

This will generate 1M trace spans / second, increase worker count by 10 for each additional 100k:

```bash
docker compose run --rm -ti loadgen gen --otlp-endpoint ${ROTEL_HOST_LARGE}:4317 --otlp-resources-per-batch 5 traces --workers 100
```

### Environment Variables

- `CLICKHOUSE_HOST`: (gateway collector) Set to IP of clickhouse host you're using, see `~/.bashrc` for preset options.
- `CLICKHOUSE_DATABASE`: (gateway collector) `otenull` or `otel` (default)

### Monitoring

- **Kafka**: Health check on port 9092
- **ClickHouse**: HTTP interface on port 8123

## Configuration

Service configurations are stored in the `config/` directory:
- `clickhouse-server/`: ClickHouse server configuration
- `clickhouse-keeper/`: ClickHouse keeper configuration  
- `otel-coll-edge/`: Edge collector configuration
- `otel-coll-gateway/`: Gateway collector configuration

Initialization scripts are in `scripts/clickhouse-server/`.

## Development

### Rebuilding an image from source

To force rebuild an image from source, use the following command. Make sure to include
`--no-cache` to avoid reusing a cached docker layer.

```bash
ROTEL_GIT_BRANCH=<branch or sha> docker compose build --no-cache rotel-gateway-branch
```

Then start as normal:

```bash
ROTEL_GIT_BRANCH=<branch or sha> docker compose up -d rotel-gateway-branch
```
