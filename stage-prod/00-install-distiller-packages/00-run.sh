#!/bin/bash -e

echo "Installing Distiller prod deb packages..."

# Install the deb packages in dependency order
install -d "${ROOTFS_DIR}/tmp/distiller-debs"
cp "${STAGE_DIR}/deb-packages/"*.deb "${ROOTFS_DIR}/tmp/distiller-debs/"

# Install claude-code-web-manager from local source
# install -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/vibe-code-distiller-ui"
# rsync -a --delete \
#     --exclude 'node_modules' \
#     --exclude '.git' \
#     /home/utsav/pamir-ai/vibe-code-distiller-ui/ \
#     "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/vibe-code-distiller-ui/"
#
# on_chroot << EOF
# echo "Installing claude-code-web-ui..."
# cd /home/${FIRST_USER_NAME}/vibe-code-distiller-ui
# sudo ./install-service.sh
# chown -R ${FIRST_USER_NAME}:${FIRST_USER_NAME} /home/${FIRST_USER_NAME}/vibe-code-distiller-ui
# cd -
# EOF

on_chroot << EOF
echo "Installing distiller-cm5-services..."
dpkg -i /tmp/distiller-debs/distiller-cm5-services_*.deb || true

echo "Installing distiller-cc..."
dpkg -i /tmp/distiller-debs/distiller-cc_*.deb || true

echo "Installing distiller-telemetry..."
dpkg -i /tmp/distiller-debs/distiller-telemetry_*.deb || true

echo "Installing claude-code-web-manager..."
dpkg -i /tmp/distiller-debs/claude-code-web-manager_*.deb || true

# Fix any remaining dependency issues
apt-get -f install -y

# Clean up
rm -rf /tmp/distiller-debs
EOF

echo "Distiller prod deb packages installed successfully"
