# Build stage
FROM rust:1.89 as builder

# Install git and other build dependencies
RUN apt-get update && \
    apt-get install -y git cmake openssl protobuf-compiler libzstd-dev libclang-dev && \
    apt-get clean

# Clone the rotel repository and checkout the perf branch
RUN git clone https://github.com/streamfold/rotel.git /rotel-src
WORKDIR /rotel-src
RUN git checkout ch-perf-improvements

# Build rotel in release mode
RUN cargo build --release

# Runtime stage
FROM ubuntu:24.04

ARG TARGETARCH

RUN apt-get update && apt-get install -y ca-certificates && apt-get clean

# Copy the compiled rotel binary from the builder stage
COPY --from=builder /rotel-src/target/release/rotel /rotel
RUN chmod 0755 /rotel

EXPOSE 4317
EXPOSE 4318

ENTRYPOINT ["/rotel", "start", "--otlp-grpc-endpoint", "0.0.0.0:4317", "--otlp-http-endpoint", "0.0.0.0:4318"]
