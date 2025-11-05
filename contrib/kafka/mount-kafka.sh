#!/bin/bash

# Remount Kafka from EBS. If this is the initial start up
# it must be manually formatted.

set -e

sudo mkdir -p /kafka

sudo mount -o noatime /dev/sdf /kafka
