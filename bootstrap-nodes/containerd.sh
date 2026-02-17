#!/bin/bash
set -euo pipefail

containerd_install=$(cat <<EOF
  sudo apt install -y containerd
  sudo systemctl enable containerd
EOF
)

echo -e "\033[0;33mInstalling containerd on all homelab nodes...\033[0m\n"

for node in controlplane worker01 worker02 worker03 worker04 worker05; do
    echo -e "\033[0;36mInstalling containerd on $node...\033[0;32m\n"
    ssh -o BatchMode=yes -o ConnectTimeout=5 "$node@$node" "$containerd_install"
    echo -e "\033[0m"
done
