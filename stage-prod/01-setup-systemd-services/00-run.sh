#!/bin/bash -e

echo "Configuring Distiller prod systemd services..."

# Enable services on boot (deb packages should have installed the service files)
on_chroot << EOF
systemctl daemon-reload

if [ -f /lib/systemd/system/distiller-wifi.service ]; then
    systemctl enable distiller-wifi.service
    echo "Enabled distiller-wifi service"
fi
EOF

echo "Distiller prod systemd services configured successfully" 
