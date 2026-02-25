#!/bin/bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <SSID> <PASSWORD>"
    exit 1
fi

SSID="$1"
PASSWORD="$2"

# Node -> "IP/CIDR:GATEWAY"
declare -A NODE_CONFIG=(
  [controlplane]="192.168.4.35/22:192.168.4.1"
  [worker01]="192.168.7.200/22:192.168.4.1"
  [worker02]="192.168.7.223/22:192.168.4.1"
  [worker03]="192.168.4.55/22:192.168.4.1"
  [worker04]="192.168.7.224/22:192.168.4.1"
  [worker05]="192.168.4.31/22:192.168.4.1"
)

for node in "${!NODE_CONFIG[@]}"; do
    echo "================================================="
    echo "Configuring $node"
    echo "================================================="

    IFS=":" read -r STATIC_IP GATEWAY <<< "${NODE_CONFIG[$node]}"

    ssh "$node@$node" bash -s <<EOF
set -euo pipefail

sudo apt install -y netplan.io
echo "Detecting active interface..."
INTERFACE=\$(ip -o -4 addr show | awk '\$2 !~ /^lo/ {print \$2; exit}')
if [[ -z "\$INTERFACE" ]]; then
  echo "No active interface detected!"
  exit 1
fi
echo "Using interface: \$INTERFACE"

echo "Backing up existing netplan..."
sudo mkdir -p /etc/netplan/backup
sudo cp -v /etc/netplan/*.yaml /etc/netplan/backup/ 2>/dev/null || true

echo "Writing static Netplan configuration..."
sudo tee /etc/netplan/01-static.yaml > /dev/null <<NETPLAN
network:
  version: 2
  renderer: NetworkManager
  wifis:
    \$INTERFACE:
      dhcp4: no
      addresses:
        - $STATIC_IP
      routes:
        - to: default
          via: $GATEWAY
      nameservers:
        addresses:
          - $GATEWAY
          - 8.8.8.8
      access-points:
        "$SSID":
          password: "$PASSWORD"
NETPLAN

echo "Fixing permissions..."
sudo chmod 600 /etc/netplan/01-static.yaml

echo "Applying Netplan..."
sudo netplan generate
sudo netplan apply

echo "Verifying static IP..."
ip -4 addr show \$INTERFACE | grep -q "${STATIC_IP%%/*}" || {
  echo "Static IP did not apply correctly!"
  exit 1
}

echo "Checking gateway connectivity..."
ping -c2 -W2 $GATEWAY >/dev/null || {
  echo "Gateway unreachable!"
  exit 1
}

echo "Checking DNS resolution..."
getent hosts google.com >/dev/null || {
  echo "DNS resolution failed!"
  exit 1
}

echo "$node successfully configured"
EOF

done

echo "All nodes successfully configured."
