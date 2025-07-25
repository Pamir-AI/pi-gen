#!/bin/bash -e

echo "Installing Distiller prod deb packages..."

# Install the deb packages in dependency order
install -d "${ROOTFS_DIR}/tmp/distiller-debs"
cp "${STAGE_DIR}/deb-packages/"*.deb "${ROOTFS_DIR}/tmp/distiller-debs/"

on_chroot << EOF
echo "Installing distiller-cm5-services..."
dpkg -i /tmp/distiller-debs/distiller-cm5-services*.deb || true

echo "Installing claude-code-web-manager..."
dpkg -i /tmp/distiller-debs/claude-code-web-manager_*.deb || true

# Fix any remaining dependency issues
apt-get -f install -y

# Clean up
rm -rf /tmp/distiller-debs
EOF

echo "Distiller prod deb packages installed successfully" 
