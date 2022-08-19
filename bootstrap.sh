#!/bin/bash
set -euo pipefail
MINTFILE=/usr/local/bin/mint
if [ -f "$MINTFILE" ]; then
    echo "No need to install mint, already installed"
else
    rm -rf Mint
    git clone https://github.com/yonaskolb/Mint.git
    cd Mint || exit
    make
    cd .. || exit
    rm -rf Mint
fi

mint bootstrap
