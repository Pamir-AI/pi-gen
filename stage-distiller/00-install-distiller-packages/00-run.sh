#!/bin/bash -e

echo "Installing Distiller CM5 Common deb packages..."

# Create distiller user and group first
on_chroot << EOF
# Create distiller group and user
groupadd -r distiller 2>/dev/null || true
useradd -r -s /bin/false -d /opt -g distiller distiller 2>/dev/null || true
EOF

# Install the deb packages in dependency order
install -d "${ROOTFS_DIR}/tmp/distiller-debs"
cp "${STAGE_DIR}/deb-packages/"*.deb "${ROOTFS_DIR}/tmp/distiller-debs/"

on_chroot << EOF
# Install DKMS kernel modules first
echo "Installing DKMS kernel modules..."
# dpkg -i /tmp/distiller-debs/pamir-ai-keyinput-dkms_*.deb || true
dpkg -i /tmp/distiller-debs/pamir-ai-sam-dkms_*.deb || true
dpkg -i /tmp/distiller-debs/pamir-ai-soundcard-dkms_*.deb || true

# Install distiller platform packages in dependency order
echo "Installing distiller-cm5-sdk..."
dpkg -i /tmp/distiller-debs/distiller-cm5-sdk_*.deb || true

# echo "Installing distiller-cm5-services..."
# dpkg -i /tmp/distiller-debs/distiller-cm5-services_*.deb || true

# echo "Installing distiller-mcp-hub (depends on distiller-cm5-sdk)..."
# dpkg -i /tmp/distiller-debs/distiller-mcp-hub_*.deb || true

# Fix any remaining dependency issues
apt-get -f install -y

# Clean up
rm -rf /tmp/distiller-debs
EOF

echo "Distiller CM5 deb packages installed successfully" 
