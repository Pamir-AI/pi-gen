#!/bin/bash -e

# Configure default WiFi network for Pamir AI lab/office
# NetworkManager reads .nmconnection files from system-connections/ on startup

mkdir -p "${ROOTFS_DIR}/etc/NetworkManager/system-connections"

cat > "${ROOTFS_DIR}/etc/NetworkManager/system-connections/Pamir_EXT.nmconnection" <<- 'EOF'
[connection]
id=Pamir_EXT
uuid=f6a6a3d8-2c4b-4e8f-9a1d-7b3e5f0c8d2a
type=wifi
autoconnect=true
autoconnect-priority=100

[wifi]
ssid=Pamir_EXT
mode=infrastructure

[wifi-security]
key-mgmt=wpa-psk
psk=build00!

[ipv4]
method=auto

[ipv6]
method=auto
EOF

chmod 600 "${ROOTFS_DIR}/etc/NetworkManager/system-connections/Pamir_EXT.nmconnection"
