#!/bin/bash
#

RECORD_PID=$1

if [ -z "$RECORD_PID" ]; then
    echo "Usage: record.sh <pid>"
    exit 1
fi

sudo perf record -F99 --call-graph dwarf -p $RECORD_PID
