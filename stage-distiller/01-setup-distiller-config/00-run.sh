#!/bin/bash -e

echo "Finalizing Distiller CM5 configuration..."

# Create a post-boot setup script
cat > "${ROOTFS_DIR}/opt/distiller-post-boot-setup.sh" << 'EOF'
#!/bin/bash
toilet -t -F border "PamirAI" -f "smblock"
EOF

chmod +x "${ROOTFS_DIR}/opt/distiller-post-boot-setup.sh"

# Add welcome message to bashrc if not already present
if ! grep -q "distiller-post-boot-setup.sh" "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bashrc" 2>/dev/null; then
    cat >> "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bashrc" << 'EOF'

# Distiller CM5 Platform welcome message
if [ -f /opt/distiller-post-boot-setup.sh ]; then
    /opt/distiller-post-boot-setup.sh
fi
EOF
fi

# Add welcome message to root's bashrc if not already present
if ! grep -q "distiller-post-boot-setup.sh" "${ROOTFS_DIR}/root/.bashrc" 2>/dev/null; then
    cat >> "${ROOTFS_DIR}/root/.bashrc" << 'EOF'
# Distiller CM5 Platform welcome message
if [ -f /opt/distiller-post-boot-setup.sh ]; then
	/opt/distiller-post-boot-setup.sh
fi
EOF
fi

# Copy welcome image to distiller user home directory
install -m 644 -o 1000 -g 1000 \
    "$(dirname "$0")/../files/welcome.png" \
    "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/welcome.png"

echo "Distiller platform welcome message configured successfully"
