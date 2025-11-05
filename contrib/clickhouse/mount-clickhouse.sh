#!/bin/bash

# Format, mount and configure Clickhouse data drive

set -e

sudo mkfs.ext4 /dev/nvme0n1

sudo mkdir -p /clickhouse

sudo mount -o noatime /dev/nvme0n1 /clickhouse

sudo mkdir -p /clickhouse/log
sudo mkdir -p /clickhouse/lib

sudo chmod 777 /clickhouse/log
sudo chmod 777 /clickhouse/lib
