#!/bin/bash -e

echo "Configuring SD card automounting..."

install -d "${ROOTFS_DIR}/etc/polkit-1/localauthority/50-local.d"
install -m 644 files/50-udisks2-automount.pkla \
    "${ROOTFS_DIR}/etc/polkit-1/localauthority/50-local.d/50-udisks2-automount.pkla"
install -m 644 files/90-sdcard-notify.rules \
    "${ROOTFS_DIR}/etc/udev/rules.d/90-sdcard-notify.rules"
install -d -m 755 "${ROOTFS_DIR}/media"

echo "Ensuring udisks2 service is enabled..."
on_chroot << EOF
systemctl enable udisks2 || true
EOF

echo "SD card automounting configuration completed successfully"
