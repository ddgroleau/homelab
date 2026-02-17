#!/bin/bash
set -euo pipefail

nodes=(controlplane worker01 worker02 worker03 worker04 worker05)

declare -A mac_map
declare -A uuid_map

echo -e "Checking uniqueness of nodes...\n"

for node in "${nodes[@]}"; do
    echo "=== $node ==="

    # SSH and gather info
    read -r mac uuid <<< "$(ssh "$node@$node" bash -s 2>/dev/null <<'ENDSSH'
# ---- Get Wi-Fi MAC (first interface starting with "w") ----
mac_addr=$(ip link | awk '
/^[0-9]+: w/ {iface=$2; getline; if ($1=="link/ether") {print $2; exit}}
' | tr -d ":")

# ---- Get product UUID ----
uuid=$(sudo cat /sys/class/dmi/id/product_uuid 2>/dev/null || echo "UNKNOWN")

# ---- Output both ----
echo "$mac_addr $uuid"
ENDSSH
)"

    # Skip node if SSH failed or MAC/UUID is empty
    if [[ -z "$mac" || -z "$uuid" || "$mac" == "UNKNOWN" ]]; then
        echo "⚠️ Could not reach $node or retrieve data, skipping..."
        continue
    fi

    echo "MAC Address: $mac"
    echo "Product UUID: $uuid"

    # Check duplicates
    if [[ -n "${mac_map[$mac]:-}" ]]; then
        echo "⚠️ Duplicate MAC detected! Previously seen on node: ${mac_map[$mac]}"
    else
        mac_map[$mac]=$node
    fi

    if [[ -n "${uuid_map[$uuid]:-}" ]]; then
        echo "⚠️ Duplicate UUID detected! Previously seen on node: ${uuid_map[$uuid]}"
    else
        uuid_map[$uuid]=$node
    fi

    echo ""
done

echo "Node uniqueness check complete."
