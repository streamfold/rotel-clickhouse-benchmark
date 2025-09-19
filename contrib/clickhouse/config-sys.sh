#!/bin/bash
# 
# Config necessary system properties for recommended Clickhouse operation

set -e

echo tsc | sudo tee /sys/devices/system/clocksource/clocksource0/current_clocksource

sudo sh -c 'echo 1 > /proc/sys/kernel/task_delayacct'
