#!/bin/bash
set -euo pipefail

echo -e "Rebooting all homelab nodes...\n"

for node in controlplane worker01 worker02 worker03 worker04 worker05; do
    echo "Rebooting $node..."
    ssh -o BatchMode=yes -o ConnectTimeout=5 "$node@$node" "sudo reboot"
done