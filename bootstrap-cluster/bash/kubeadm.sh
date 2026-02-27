#!/bin/bash
set -euo pipefail

# nodes=(controlplane worker01 worker02 worker03 worker04 worker05)
nodes=(worker04)

install_cmd=$(cat <<'EOF'
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl gpg

    # If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command
    sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    # This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt update
    sudo apt install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    sudo systemctl enable --now kubelet
EOF
)

for node in "${nodes[@]}"; do
    echo -e "\n=== Installing kubeadm on $node ==="
    ssh -o BatchMode=yes -o ConnectTimeout=5 "$node@$node" "$install_cmd"
done