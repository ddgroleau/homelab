#!/bin/bash
set -euo pipefail

echo -e "Shutting down all homelab nodes...\n"

for node in controlplane worker01 worker02 worker03 worker04 worker05; do
    echo "Shutting down $node..."
    ssh -o BatchMode=yes -o ConnectTimeout=5 "$node@$node" "sudo shutdown"
done