#!/bin/bash -e

echo "Finalizing prod configuration..."

# Append packages installed to distiller platform info file
cat > "${ROOTFS_DIR}/etc/distiller-platform-info" << EOF
DISTILLER_PACKAGES_INSTALLED=distiller-cm5-sdk,distiller-cm5-services,vibe-code-distiller-ui
EOF

# Create distiller SDK eink configuration file
cat > "${ROOTFS_DIR}/opt/distiller-cm5-sdk/eink.conf" << EOF
firmware=EPD128x250
EOF

# Expose environment variables for distiller SDK and Python
echo "PYTHONPATH=/opt/distiller-cm5-sdk/src:/opt/claude-code-web-manager:\$PYTHONPATH" >> "${ROOTFS_DIR}/etc/environment"
echo "LD_LIBRARY_PATH=/opt/distiller-cm5-sdk/lib:\$LD_LIBRARY_PATH" >> "${ROOTFS_DIR}/etc/environment"
echo "PATH=\$HOME/.local/bin:\$PATH" >> "${ROOTFS_DIR}/etc/environment"

# Create distiller eink stash directory with proper permissions
echo "Creating /opt/distiller-eink-stash directory..."
mkdir -p "${ROOTFS_DIR}/opt/distiller-eink-stash"
chmod 755 "${ROOTFS_DIR}/opt/distiller-eink-stash"

# Copy sleep screen image to eink stash
echo "Copying sleep-image.png to /opt/distiller-eink-stash..."
cp "${PWD}/sleep-image.png" "${ROOTFS_DIR}/opt/distiller-eink-stash/"

# Set ownership inside the target filesystem where distiller user exists
echo "Setting ownership of /opt/distiller-eink-stash to distiller user..."
on_chroot << EOF
chown ${FIRST_USER_NAME}:${FIRST_USER_NAME} /opt/distiller-eink-stash
chown ${FIRST_USER_NAME}:${FIRST_USER_NAME} /opt/distiller-eink-stash/sleep-image.png
EOF

echo "Distiller prod configuration completed successfully" 
