FROM golang:1.25 AS builder

WORKDIR /app


# Clone the loadgen repository and checkout the custom branch
ARG GIT_BRANCH
RUN git clone https://github.com/streamfold/otel-loadgen /loadgen-src
WORKDIR /loadgen-src
RUN git checkout $GIT_BRANCH

RUN make build

FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /loadgen-src/dist/otel-loadgen .

ENTRYPOINT ["./otel-loadgen"]
