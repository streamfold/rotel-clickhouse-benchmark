FROM rust:1.89 as builder

WORKDIR /app

RUN apt-get update && apt-get install -y cmake protobuf-compiler gcc libclang-dev libzstd-dev openssl

RUN git clone --depth=1 https://github.com/streamfold/rotel.git .

RUN cargo build --release --bin clickhouse-ddl

FROM debian:trixie-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/clickhouse-ddl /usr/local/bin/clickhouse-ddl

ENTRYPOINT ["clickhouse-ddl"]
