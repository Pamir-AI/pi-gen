#!/bin/bash -e

echo "Finalizing Distiller CM5 configuration..."

# Create a post-boot setup script
cat > "${ROOTFS_DIR}/opt/distiller-post-boot-setup.sh" << 'EOF'
#!/bin/bash
toilet -t -F border "PamirAI" -f "smblock"
EOF

chmod +x "${ROOTFS_DIR}/opt/distiller-post-boot-setup.sh"

# Add welcome message to bashrc
cat >> "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bashrc" << 'EOF'

# Distiller CM5 Platform welcome message
if [ -f /opt/distiller-post-boot-setup.sh ]; then
    /opt/distiller-post-boot-setup.sh
fi
EOF

# Add welcome message to root's bashrc
cat >> "${ROOTFS_DIR}/root/.bashrc" << 'EOF'
# Distiller CM5 Platform welcome message
if [ -f /opt/distiller-post-boot-setup.sh ]; then
	/opt/distiller-post-boot-setup.sh
fi
EOF

# Set up logrotate for distiller logs
cat > "${ROOTFS_DIR}/etc/logrotate.d/distiller" << 'EOF'
/var/log/distiller/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    create 644 distiller distiller
}
EOF

# Create distiller platform info file
cat > "${ROOTFS_DIR}/etc/distiller-platform-info" << EOF
DISTILLER_PLATFORM_VERSION=1.0.0
DISTILLER_INSTALL_DATE=$(date)
DISTILLER_PI_GEN_VERSION=${IMG_NAME}
DISTILLER_INSTALL_METHOD=deb_packages
EOF

# depmod to ensure kernel modules are updated
sudo depmod -a

echo "Distiller CM5 platform configuration completed successfully" 
