#!/bin/bash
set -euo pipefail

echo -e "Disabling swap on all homelab nodes...\n"

for node in controlplane worker01 worker02 worker03 worker04 worker05; do
    echo "Disabling swap on $node..."
    ssh -o BatchMode=yes -o ConnectTimeout=5 "$node@$node" "sudo swapoff -a && sudo sed -i '/ swap / s/^/#/' /etc/fstab"
done
