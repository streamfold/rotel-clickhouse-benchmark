#!/bin/bash
#

if [ ! -d $HOME/flamegraph ]; then
    cd $HOME
    git clone https://github.com/brendangregg/FlameGraph.git flamegraph
    cd -
    
    sudo dnf install -y perl-open
fi

if [ ! -e "perf.data" ]; then
    echo "No perf.data found"
    exit 1
fi

sudo perf script -i perf.data > out.perf
sudo chmod +r out.perf

# fold symbols
$HOME/flamegraph/stackcollapse-perf.pl out.perf > out.folded

$HOME/flamegraph/flamegraph.pl out.folded > flamegraph.svg

echo "flamegraph in flamegraph.svg"
