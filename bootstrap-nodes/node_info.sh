#!/bin/bash
set -euo pipefail

# Nodes to query
nodes=(controlplane worker01 worker02 worker03 worker04 worker05)

get_node_info() {
    local node=$1
    echo -e "\n===== $node ====="

    ssh "$node@$node" "bash -s" <<'ENDSSH'
# ---- Manufacturer & Model ----
manufacturer=$(sudo dmidecode -s system-manufacturer 2>/dev/null || echo "Unknown")
model=$(sudo dmidecode -s system-product-name 2>/dev/null || echo "Unknown")

# ---- CPU Info ----
cpu=$(lscpu | awk -F: '/Model name/ {gsub(/^ +| +$/,"",$2); print $2}')

# ---- Number of CPU Cores ----
cores=$(nproc)

# ---- Total Memory ----
mem=$(free -h | awk '/^Mem:/ {print $2}')

# ---- Total Disk (round to TB if >900GB) ----
disk_gb=$(lsblk -d -b -o SIZE,NAME | awk 'NR>1 {total+=$1} END {printf "%d", total/1024/1024/1024}')
if (( disk_gb > 900 )); then
    # round to nearest TB
    disk_tb=$(( (disk_gb + 512)/1024 ))
    disk="${disk_tb}T"
else
    disk="${disk_gb}G"
fi

# ---- Print ----
echo "Manufacturer: $manufacturer"
echo "Model: $model"
echo "CPU: $cpu"
echo "CPU Cores: $cores"
echo "Memory: $mem"
echo "Total Disk: $disk"
ENDSSH
}

# Loop through all nodes
for node in "${nodes[@]}"; do
    get_node_info "$node"
done
