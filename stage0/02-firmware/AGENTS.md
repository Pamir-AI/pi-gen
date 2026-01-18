<!-- Parent: ../AGENTS.md -->
# 02-firmware

## Purpose
Installs kernel, firmware, and bootloader packages. Configures initramfs and kernel image behavior.

## Key Files
- `01-packages` - Installs initramfs-tools, raspi-firmware, linux-image-rpi-2712, linux-headers-rpi-2712
- `02-run.sh` - Disables initramfs auto-updates, disables kernel symlinks, removes symlinks from rootfs

## For AI Agents
- Targets BCM2712 (Raspberry Pi 5/CM5) with rpi-2712 kernel variant
- update_initramfs=no prevents automatic initramfs rebuilds during package operations
- do_symlinks=0 prevents /vmlinuz and /initrd.img symlinks in root
- Cleanup removes any existing kernel/initrd symlinks from ROOTFS_DIR
