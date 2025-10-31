#!/bin/bash

# Remount Kafka from EBS. If this is the initial start up
# it must be manually formatted.

set -e

mkdir -p /kafka

mount -o noatime /dev/sdf /kafka
