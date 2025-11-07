#!/bin/bash
#

# Install depencencies do build rotel on AWS Linux 2023

set -e


sudo dnf install -y \
    cmake \
    openssl-devel \
    protobuf-compiler \
    libzstd-devel \
    perl-FindBin.noarch \
    perl-base \
    perl-IPC-Cmd.noarch \
    perl-File-Compare.noarch \
    perl-File-Copy.noarch \
    clang-devel

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
