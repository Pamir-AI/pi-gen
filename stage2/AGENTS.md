<!-- Parent: ../AGENTS.md -->
# stage2

## Purpose

Builds Raspberry Pi OS Lite - the minimal bootable system with networking, wireless, bluetooth, and cloud-init support. This is the first stage that produces an exported image (with `-lite` suffix).

Stage2 extends stage1's bootable system by adding:
- System utilities (ssh, rsync, htop, build tools, Python 3)
- Hardware support (GPIO, SPI, I2C, USB, video4linux)
- Wireless networking (wpasupplicant, firmware, NetworkManager)
- Bluetooth (bluez, firmware, rfkill whitelist)
- Cloud-init (optional, controlled by ENABLE_CLOUD_INIT)
- User environment configuration (timezone, keyboard, locale)
- SSH key management (PUBKEY_SSH_FIRST_USER, PUBKEY_ONLY_SSH)

## Subdirectories

Executed in numerical order:

1. **01-sys-tweaks** - Core system configuration
   - Installs 40+ packages: ssh, build-essential, python3, GPIO libraries, bluetooth, USB tools, compression utilities
   - Configures SSH (enables/disables based on ENABLE_SSH, sets up authorized_keys)
   - Creates user groups (input, spi, i2c, gpio) and adds FIRST_USER_NAME to relevant groups
   - Disables root password login
   - Configures keyboard and console via debconf
   - Enables rpi-resize service for first boot expansion
   - Applies 3 patches via quilt (useradd, inputrc, path)
   - QEMU mode: installs udev rules if USE_QEMU=1

2. **02-net-tweaks** - Wireless and networking setup
   - Installs wpasupplicant, wireless-tools, firmware packages (atheros, brcm80211, realtek, etc.)
   - Installs NetworkManager and net-tools
   - Configures WLAN regulatory domain if WPA_COUNTRY is set
   - Whitelists on-board bluetooth adapters to prevent rfkill blocking (workaround for 5GHz regulation)
   - If WPA_COUNTRY not set: disables wireless in NetworkManager to prevent 5GHz violations

3. **03-set-timezone** - Timezone configuration
   - Sets timezone to TIMEZONE_DEFAULT
   - Runs dpkg-reconfigure tzdata

4. **03-accept-mathematica-eula** - Wolfram license
   - Preseeds acceptance of Wolfram Engine EULA via debconf

5. **04-cloud-init** - Cloud-init support (conditional)
   - Only runs if ENABLE_CLOUD_INIT=1
   - Installs cloud-init and rpi-cloud-init-mods
   - Copies template files to /boot/firmware/ (meta-data, user-data, network-config)
   - Templates are placeholders for Raspberry Pi Imager or manual cloud-init configuration

## Key Files

- **EXPORT_IMAGE** - Triggers image generation after this stage
  - Sets IMG_SUFFIX="-lite" (output: *-lite.img.xz)
  - If USE_QEMU=1, sets IMG_SUFFIX="-lite-qemu"

- **SKIP** - Prevents stage execution (currently present, used for iterative development)

- **prerun.sh** - Copies stage1 rootfs if ROOTFS_DIR doesn't exist (standard copy_previous pattern)

- **01-sys-tweaks/00-patches/** - Quilt patch series:
  - 01-useradd.diff
  - 04-inputrc.diff
  - 05-path.diff

- **04-cloud-init/README.txt** - Documents cloud-init file requirements and Raspberry Pi Imager compatibility

## For AI Agents

### When to Modify This Stage

- Adding packages to the Lite image baseline
- Configuring wireless/bluetooth behavior
- Changing default user permissions and groups
- Modifying SSH security settings
- Adding system utilities or development tools
- Customizing cloud-init templates

### Modification Guidelines

1. **Package Installation**
   - Add to `01-sys-tweaks/00-packages` (with recommends) or `00-packages-nr` (without recommends)
   - Wireless firmware: add to `02-net-tweaks/00-packages`
   - Check package availability in Debian repos for target release

2. **User/Group Configuration**
   - Modify `01-sys-tweaks/01-run.sh` group creation/assignment section
   - User is FIRST_USER_NAME (from config), not hardcoded 'pi'

3. **SSH Configuration**
   - PUBKEY_SSH_FIRST_USER: public key for authorized_keys
   - PUBKEY_ONLY_SSH=1: disables password auth, requires pubkey
   - ENABLE_SSH: controls systemd service enable/disable

4. **Wireless Regulatory**
   - WPA_COUNTRY: must be set to enable wireless, prevents 5GHz violations
   - Without WPA_COUNTRY: wireless disabled by default in NetworkManager

5. **Cloud-Init**
   - Gate modifications with `if [ "${ENABLE_CLOUD_INIT}" != "1" ]; then exit 0; fi`
   - Template files in `04-cloud-init/files/` must remain valid YAML
   - See cloud-init docs: https://cloudinit.readthedocs.io/

6. **Scripts Must Be Executable**
   - All `XX-run.sh` and `XX-run-chroot.sh` files need chmod +x
   - build.sh will fail silently if scripts aren't executable

7. **Quilt Patches**
   - Patches in `01-sys-tweaks/00-patches/` applied via series file
   - To modify: create EDIT file in patches directory, edit interactively

### Variable Dependencies

From config file:
- FIRST_USER_NAME - default user (replaces legacy 'pi')
- ENABLE_SSH - enable SSH server
- PUBKEY_SSH_FIRST_USER - SSH public key for authorized_keys
- PUBKEY_ONLY_SSH - disable password auth
- WPA_COUNTRY - WLAN regulatory domain (required for wireless)
- TIMEZONE_DEFAULT - system timezone
- KEYBOARD_KEYMAP - keyboard layout
- KEYBOARD_LAYOUT - keyboard variant
- ENABLE_CLOUD_INIT - install cloud-init
- USE_QEMU - QEMU mode for emulation

### Testing Notes

- This stage takes significant time (40+ packages, firmware)
- To skip on rebuild: `touch stage2/SKIP`
- To prevent image export: `touch stage2/SKIP_IMAGES`
- Verify wireless works by checking WPA_COUNTRY is set
- Test SSH access matches ENABLE_SSH and pubkey settings
- Bluetooth may be rfkill-blocked until regulatory domain is set

### Common Pitfalls

1. Adding wireless-dependent packages without WPA_COUNTRY will fail at runtime
2. Forgetting to add FIRST_USER_NAME to new groups breaks hardware access
3. Cloud-init files must be valid even if ENABLE_CLOUD_INIT=0 (Imager parses them)
4. Bluetooth firmware loads but may be rfkill-blocked until first boot Wi-Fi config
5. Scripts in on_chroot blocks use $FIRST_USER_NAME, not ${FIRST_USER_NAME} (shell escaping)

## Dependencies

- **stage1** - Provides bootable Raspberry Pi OS foundation with kernel, bootloader, raspi-config
- **stage0** - Provides base Debian system via debootstrap

### Runtime Dependencies

This stage's packages depend on:
- Kernel modules from stage1 (wireless drivers, bluetooth)
- systemd from stage0/stage1
- dpkg/apt from stage0
- Raspberry Pi firmware from stage1

### Config Variables Required

Critical variables that must be set in config file:
- FIRST_USER_NAME (user creation)
- TIMEZONE_DEFAULT (timezone setup)
- KEYBOARD_KEYMAP, KEYBOARD_LAYOUT (keyboard config)

Optional but recommended:
- WPA_COUNTRY (enables wireless)
- ENABLE_SSH (security)
- PUBKEY_SSH_FIRST_USER (SSH access)
