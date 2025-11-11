#!/bin/bash
#

set -e

sudo mkdir -p /kafka

sudo mkfs.ext4 /dev/nvme0n1

sudo mount -o noatime /dev/nvme0n1 /kafka

sudo mkdir /kafka/data

sudo chmod 777 /kafka/data
