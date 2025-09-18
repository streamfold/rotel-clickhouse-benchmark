#!/bin/bash
set -e

clickhouse client -n <<-EOSQL
    CREATE DATABASE otel;
    CREATE DATABASE otelnull;
EOSQL
