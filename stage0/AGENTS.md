<!-- Parent: ../AGENTS.md -->
# stage0

## Purpose

Bootstrap the initial Debian filesystem using debootstrap. This is the foundation stage that creates a minimal bootable Debian system with Raspberry Pi firmware and kernel.

## Subdirectories

- **00-configure-apt**: Configures APT sources for Debian and Raspberry Pi repositories, sets up multi-arch support (armhf/arm64), installs archive keyrings, and performs initial system update/upgrade
- **01-locale**: Installs and configures system locales via debconf
- **02-firmware**: Installs Raspberry Pi firmware, kernel (linux-image-rpi-2712), headers, and initramfs-tools. Disables automatic initramfs updates and kernel symlinks

## Key Files

- **prerun.sh**: Invokes `bootstrap()` function to create initial rootfs via debootstrap from http://deb.debian.org/debian/ if ROOTFS_DIR doesn't exist. Validates RELEASE matches "trixie"
- **00-configure-apt/files/debian.sources**: DEB822 format APT sources for Debian main/contrib/non-free repositories
- **00-configure-apt/files/raspi.sources**: DEB822 format APT sources for Raspberry Pi-specific packages
- **00-configure-apt/files/raspberrypi-archive-keyring.pgp**: GPG keyring for Raspberry Pi repository
- **00-configure-apt/files/51cache**: APT proxy configuration (conditionally installed if APT_PROXY is set)
- **SKIP**: Present - this stage is skipped during builds (uses cached work/)

## For AI Agents

### When modifying this stage

1. **Debootstrap changes**: Modify `prerun.sh` if you need to change the bootstrap source URL, release, or add custom bootstrap arguments
2. **Repository changes**: Edit `files/debian.sources` or `files/raspi.sources` to add/remove APT repositories or components
3. **Package additions**: Add packages to `XX-packages` files in subdirectories. Packages here establish baseline system dependencies
4. **Locale configuration**: Modify `01-locale/00-debconf` to change default locale (currently uses ${LOCALE_DEFAULT} variable)
5. **Firmware/kernel version**: Edit `02-firmware/01-packages` to pin specific kernel versions (currently uses linux-image-rpi-2712)

### Critical constraints

- **NEVER modify BASE_DIR** - breaks entire build system
- **RELEASE must be "trixie"** - prerun.sh validates this
- **Scripts must be executable** - chmod +x on all `XX-run.sh` files
- **Multi-arch support**: 00-configure-apt enables both armhf and arm64 architectures
- **Bootstrap must complete** - all later stages depend on successful ROOTFS_DIR creation

### Testing changes

1. Remove SKIP file to rebuild this stage
2. Delete work/stage0 directory to force clean bootstrap
3. Run `sudo CLEAN=1 ./build.sh` to rebuild from scratch
4. Verify APT sources with: `on_chroot apt-cache policy`
5. Check installed firmware: `ls work/stage0/rootfs/boot/firmware/`

## Dependencies

**External:**
- debootstrap (host system)
- Debian archive at http://deb.debian.org/debian/
- Raspberry Pi archive at http://archive.raspberrypi.com/debian/

**Build variables:**
- ${RELEASE} - Debian release codename (must be "trixie")
- ${ROOTFS_DIR} - Target filesystem directory (typically work/stage0/rootfs)
- ${LOCALE_DEFAULT} - Default locale setting
- ${APT_PROXY} - Optional APT caching proxy
- ${TEMP_REPO} - Optional temporary repository

**Provides foundation for:**
- All subsequent stages (stage1-stage5, stage-distiller, stage-prod)
- Base filesystem used by copy_previous() in later stages
