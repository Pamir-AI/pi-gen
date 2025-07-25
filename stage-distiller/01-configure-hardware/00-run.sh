#!/bin/bash -e

# Add distiller user to hardware groups
on_chroot << EOF
# Add distiller user to hardware access groups
usermod -a -G netdev,input,i2c,spi,dialout,gpio,audio,video distiller 2>/dev/null || true

# Add pi user to distiller group for easy access
usermod -a -G distiller ${FIRST_USER_NAME} 2>/dev/null || true
EOF

echo "Hardware configuration completed" 
