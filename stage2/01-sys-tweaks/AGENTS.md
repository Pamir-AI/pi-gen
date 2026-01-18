<!-- Parent: ../AGENTS.md -->
# 01-sys-tweaks

## Purpose
System-level tweaks and configuration for Raspberry Pi OS Lite. Installs essential packages (SSH, development tools, GPIO libraries, system utilities), configures keyboard/console, sets up user permissions, and applies system defaults via quilt patches.

## Key Files

### Package Management
- `00-packages` - Core system packages (ssh, build tools, GPIO libs, system utilities)
- `00-packages-nr` - Packages installed without recommends (cifs-utils, rpicam-apps-lite, mkvtoolnix)
- `00-debconf` - Debconf preseeds for console-setup and keyboard-configuration

### Configuration Script
- `01-run.sh` - Main setup script that:
  - Configures SSH (public key auth, enable/disable service)
  - Installs QEMU udev rules if USE_QEMU=1
  - Creates system groups (input, spi, i2c, gpio)
  - Adds FIRST_USER_NAME to required groups
  - Sets up keyboard/console via setupcon
  - Locks root password
  - Regenerates SSH host keys
  - Configures avahi workstation publishing

### Patches (00-patches/)
- `series` - Quilt patch application order
- `01-useradd.diff` - Changes default shell to bash, enables /etc/skel
- `04-inputrc.diff` - Input configuration tweaks
- `05-path.diff` - PATH environment modifications

### Files
- `files/90-qemu.rules` - QEMU device symlinks (sda -> mmcblk0)

## For AI Agents
- Patches are applied via quilt during build; modify patch files, not target files directly
- FIRST_USER_NAME is substituted from config (not hardcoded 'pi')
- SSH configuration respects ENABLE_SSH, PUBKEY_SSH_FIRST_USER, PUBKEY_ONLY_SSH variables
- Group membership for GPIO/SPI/I2C hardware access is critical for maker functionality
- Keyboard layout/console encoding use KEYBOARD_KEYMAP and KEYBOARD_LAYOUT from config
- QEMU mode (USE_QEMU=1) enables device symlinks for emulated builds
