<!-- Parent: ../AGENTS.md -->
# stage1

## Purpose

Creates a minimal bootable Raspberry Pi OS system from the stage0 debootstrap rootfs. Installs bootloader files, kernel boot configuration, network basics, user account setup, and raspi-config utility. This stage produces a system that can boot but has no desktop or wireless capabilities.

## Subdirectories

- **00-boot-files** - Installs boot configuration files (config.txt, cmdline.txt) to /boot/firmware/
- **01-sys-tweaks** - Installs raspi-config package, creates first user account, configures fstab, applies bashrc patches for colored prompt
- **02-net-tweaks** - Installs netbase package, sets hostname, disables predictable network interface names via raspi-config
- **03-install-packages** - Installs systemd-timesyncd for time synchronization

## Key Files

- **prerun.sh** - Copies stage0 rootfs via copy_previous() if ROOTFS_DIR doesn't exist
- **00-boot-files/files/config.txt** - Raspberry Pi firmware configuration (64-bit mode, VC4 driver, CM4/CM5 USB modes)
- **00-boot-files/files/cmdline.txt** - Kernel command line parameters (console, root device, rootwait, resize)
- **01-sys-tweaks/files/fstab** - Filesystem mount table (/boot/firmware as vfat, / as ext4)
- **01-sys-tweaks/00-patches/01-bashrc.diff** - Quilt patch enabling colored bash prompt and grep aliases
- **SKIP** - Stage currently skipped (building from cached work/)

## For AI Agents

### Boot Configuration

Modify boot behavior in `00-boot-files/files/`:
- `config.txt` - Hardware interfaces (I2C, SPI, audio), overlays, 64-bit mode, CM4/CM5 USB settings
- `cmdline.txt` - Kernel boot parameters (single line, space-separated)

Scripts install these to `/boot/firmware/` and create redirect files at legacy `/boot/` location.

### User Account Setup

`01-sys-tweaks/00-run.sh` creates first user account via adduser in chroot:
- Username from `FIRST_USER_NAME` variable
- Password from `FIRST_USER_PASS` variable (if set)
- Root password hardcoded to "root"

### Network Configuration

`02-net-tweaks/00-run.sh` configures:
- Hostname from `TARGET_HOSTNAME` variable
- Disables predictable network interface names (uses eth0, wlan0 style)

### Modifying Bashrc

Use quilt patches in `01-sys-tweaks/00-patches/`:
- Add patch files to directory
- Update `series` file with patch filenames
- Current patch enables colored prompt and grep color

### Adding Packages

Add package names to appropriate `00-packages` files:
- `01-sys-tweaks/00-packages` - Currently installs raspi-config
- `02-net-tweaks/00-packages` - Currently installs netbase
- `03-install-packages/00-packages` - Currently installs systemd-timesyncd

### Testing Changes

1. Remove SKIP file: `rm /home/utsav/pi-gen/stage1/SKIP`
2. Add SKIP to stage0 if not already present
3. Run: `sudo CLEAN=1 ./build.sh`
4. Restore SKIP file when satisfied

## Dependencies

- **stage0** - Requires debootstrap rootfs from stage0 (copied via prerun.sh)
- **Config Variables** - FIRST_USER_NAME, FIRST_USER_PASS, TARGET_HOSTNAME from config file
- **Scripts Functions** - copy_previous(), on_chroot(), install from scripts/common
