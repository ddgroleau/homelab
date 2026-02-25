#!/bin/bash
set -euo pipefail

echo -e "Testing SSH connectivity for all homelab nodes...\n"

for node in controlplane worker01 worker02 worker03 worker04 worker05; do
    echo "Testing $node..."

    if ssh -o BatchMode=yes -o ConnectTimeout=5 "$node@$node" "echo connected" >/dev/null 2>&1; then
        echo "✅ $node is reachable via SSH"
    else
        echo "❌ $node SSH failed"
    fi

    echo
done