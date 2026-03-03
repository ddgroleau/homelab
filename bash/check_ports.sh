#!/bin/bash
set -euo pipefail

# Nodes
controlplane_nodes=(controlplane)
worker_nodes=(worker01 worker02 worker03 worker04 worker05)

# Control plane TCP ports
controlplane_ports=(6443 2379 2380 10250 10259 10257)

# Worker TCP ports
worker_ports=(10250 10256)

# NodePort range
nodeport_start=30000
nodeport_end=32767

# Function to check if a port is open in nftables
check_port() {
    local node=$1
    local proto=$2
    local port=$3

    ssh "$node@$node" bash -s 2>/dev/null <<ENDSSH
sudo nft list ruleset | grep -q "$proto dport $port"
ENDSSH
}

# Function to check if a port range is open
check_port_range() {
    local node=$1
    local proto=$2
    local start=$3
    local end=$4

    ssh "$node@$node" bash -s 2>/dev/null <<ENDSSH
sudo nft list ruleset | grep -q "$proto dport $start-$end"
ENDSSH
}

echo "=== Checking control plane nodes ==="
for node in "${controlplane_nodes[@]}"; do
    echo -e "\n--- $node ---"
    for port in "${controlplane_ports[@]}"; do
        if check_port "$node" tcp "$port"; then
            echo "TCP $port is open and persisted on $node"
        else
            echo "TCP $port is NOT open on $node"
        fi
    done
done

echo -e "\n=== Checking worker nodes ==="
for node in "${worker_nodes[@]}"; do
    echo -e "\n--- $node ---"
    for port in "${worker_ports[@]}"; do
        if check_port "$node" tcp "$port"; then
            echo "TCP $port is open and persisted on $node"
        else
            echo "TCP $port is NOT open on $node"
        fi
    done
    # NodePort ranges TCP + UDP
    if check_port_range "$node" tcp "$nodeport_start" "$nodeport_end"; then
        echo "TCP NodePort range $nodeport_start-$nodeport_end is open and persisted on $node"
    else
        echo "TCP NodePort range $nodeport_start-$nodeport_end is NOT fully open on $node"
    fi
    if check_port_range "$node" udp "$nodeport_start" "$nodeport_end"; then
        echo "UDP NodePort range $nodeport_start-$nodeport_end is open and persisted on $node"
    else
        echo "UDP NodePort range $nodeport_start-$nodeport_end is NOT fully open on $node"
    fi
done

echo -e "\nAll ports verification complete."
