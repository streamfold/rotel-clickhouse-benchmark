# Rotel ClickHouse Benchmark

A comprehensive benchmarking environment for testing OpenTelemetry data ingestion and processing using ClickHouse as the backend storage, with both native rotel processors and OpenTelemetry Collector configurations.

## Architecture Overview

This repository provides a complete observability pipeline with multiple data processing paths for performance comparison:

```
[Data Generators] → [Edge Processors] → [Kafka] → [Gateway Processors] → [ClickHouse] → [HyperDX UI]
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
- **Purpose**: OpenTelemetry Collector configured as edge processor (alternative to rotel-edge)
- **Ports**: 4317 (OTLP gRPC), 4318 (OTLP HTTP), 8888 (Prometheus metrics)

#### **otel-coll-gateway**
- **Image**: `otel/opentelemetry-collector-contrib`
- **Purpose**: OpenTelemetry Collector configured as gateway processor (alternative to rotel-gateway)
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

### Quick Start

1. Start the complete environment:
```bash
docker-compose up -d
```

2. Access HyperDX UI at http://localhost:8080

3. Generate test data using telemetrygen:
```bash
docker-compose exec telemetrygen ./telemetrygen traces --otlp-endpoint http://rotel-edge:4317
```

### Performance Testing Scenarios

#### Scenario 1: Rotel Pipeline
- Data flow: `telemetrygen` → `rotel-edge` → `kafka` → `rotel-gateway` → `clickhouse`
- Start: `rotel-edge`, `rotel-gateway`, `kafka`, `clickhouse`

#### Scenario 2: OpenTelemetry Collector Pipeline  
- Data flow: `telemetrygen` → `otel-coll-edge` → `kafka` → `otel-coll-gateway` → `clickhouse`
- Start: `otel-coll-edge`, `otel-coll-gateway`, `kafka`, `clickhouse`

#### Scenario 3: Direct Processing
- Data flow: `telemetrygen` → `otel-collector` → `clickhouse`
- Start: `otel-collector`, `clickhouse`

### Environment Variables

- `KAFKA_HOST_IP`: External IP for Kafka (default: kafka container)
- `CLICKHOUSE_PASSWORD`: ClickHouse password (optional)
- `CHVER`: ClickHouse server version (default: latest)
- `CHKVER`: ClickHouse keeper version (default: latest-alpine)

### Monitoring

- **Kafka**: Health check on port 9092
- **ClickHouse**: HTTP interface on port 8123
- **Prometheus metrics**: Available on port 8888 for all OTel collectors
- **Health checks**: Port 13133 for OTel collectors

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
docker compose build --no-cache rotel-gateway-branch
```

Then start as normal:

```bash
docker compose up -d rotel-gateway-branch
```