#!/bin/bash -e

# Add distiller user to hardware groups
on_chroot << EOF
# Add distiller user to hardware access groups
usermod -a -G netdev,input,i2c,spi,dialout,gpio,audio,video distiller 2>/dev/null || true

# Add pi user to distiller group for easy access
usermod -a -G distiller ${FIRST_USER_NAME} 2>/dev/null || true

cat > /etc/udev/rules.d/99-pico.rules << 'UDEV_RULE'
SUBSYSTEM=="tty", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0005", SYMLINK+="pico", MODE="0660", GROUP="dialout"
UDEV_RULE
EOF

echo "Hardware configuration completed"
