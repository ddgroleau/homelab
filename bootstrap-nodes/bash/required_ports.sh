#!/bin/bash
set -euo pipefail

# Nodes
controlplane_nodes=(controlplane)
worker_nodes=(worker01 worker02 worker03 worker04 worker05)

# Control plane TCP ports
controlplane_ports=(6443 2379 2380 10250 10259 10257)

# Worker node TCP ports
worker_ports=(10250 10256)

# NodePort range
nodeport_start=30000
nodeport_end=32767

# Function to add nftables rule if it doesn't exist
add_nft_rule() {
    local node=$1
    local proto=$2
    local port=$3

    ssh "$node@$node" bash -s 2>/dev/null <<ENDSSH
sudo nft list ruleset | grep -q "$proto dport $port" || \
sudo nft add rule inet filter input $proto dport $port accept
ENDSSH
    echo "$port/$proto opened on $node"
}

# Function to open a range of ports
add_nft_range() {
    local node=$1
    local proto=$2
    local start=$3
    local end=$4

    ssh "$node@$node" bash -s 2>/dev/null <<ENDSSH
sudo nft list ruleset | grep -q "$proto dport $start-$end" || \
sudo nft add rule inet filter input $proto dport $start-$end accept
ENDSSH
    echo "$start-$end/$proto opened on $node"
}

# Ensure filter table and input chain exist
for node in "${controlplane_nodes[@]}" "${worker_nodes[@]}"; do
    ssh "$node@$node" bash -s 2>/dev/null <<'ENDSSH'
sudo nft list table inet filter >/dev/null 2>&1 || sudo nft add table inet filter
sudo nft list chain inet filter input >/dev/null 2>&1 || sudo nft add chain inet filter input { type filter hook input priority 0 \; policy accept \; }
ENDSSH
done

# Configure control plane nodes
for node in "${controlplane_nodes[@]}"; do
    echo -e "\n=== Configuring control plane node: $node ==="
    for port in "${controlplane_ports[@]}"; do
        add_nft_rule "$node" tcp "$port"
    done
done

# Configure worker nodes
for node in "${worker_nodes[@]}"; do
    echo -e "\n=== Configuring worker node: $node ==="
    for port in "${worker_ports[@]}"; do
        add_nft_rule "$node" tcp "$port"
    done
    add_nft_range "$node" tcp "$nodeport_start" "$nodeport_end"
    add_nft_range "$node" udp "$nodeport_start" "$nodeport_end"
done

save_rules=$(cat <<EOF
    sudo apt update && sudo apt install -y nftables
    sudo systemctl enable nftables
    sudo nft list ruleset | sudo tee /etc/nftables.conf > /dev/null
EOF
)

# Persist rules
for node in "${controlplane_nodes[@]}" "${worker_nodes[@]}"; do
    ssh -o BatchMode=yes -o ConnectTimeout=5 "$node@$node" "$save_rules"
    echo "Rules saved and persistent on $node"
done

echo -e "\nAll Kubernetes-required ports are now open and persistent using nftables."
