#!/bin/bash

# Format, mount and configure Clickhouse data drive

set -e

mkfs.ext4 /dev/nvme0n1

mkdir -p /clickhouse

mount -o noatime /dev/nvme0n1 /clickhouse

mkdir -p /clickhouse/log
mkdir -p /clickhouse/lib

chmod 777 /clickhouse/log
chmod 777 /clickhouse/lib
