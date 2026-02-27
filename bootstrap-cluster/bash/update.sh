#!/bin/bash
set -euo pipefail

echo -e "Updating all homelab nodes...\n"

for node in controlplane worker01 worker02 worker03 worker04 worker05; do
    echo "Updating $node..."
    ssh -o BatchMode=yes -o ConnectTimeout=5 "$node@$node" "sudo apt update && sudo apt upgrade"
done
