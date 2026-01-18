<!-- Parent: ../AGENTS.md -->
# 04-cloud-init

## Purpose
Optional cloud-init support for automated first-boot configuration. Installs cloud-init packages and seeds NoCloud datasource templates to /boot/firmware/ for Raspberry Pi Imager compatibility.

## Key Files

### Package Management
- `00-packages` - Cloud-init packages:
  - cloud-init
  - rpi-cloud-init-mods

### Configuration Script
- `01-run.sh` - Conditional setup:
  - Skips entirely if ENABLE_CLOUD_INIT != "1"
  - Installs template files to /boot/firmware/ (mode 755)

### Template Files (files/)
- `meta-data` - Cloud-init instance metadata (minimal config)
- `user-data` - Example user/system configuration (commented examples for hostname, keyboard, users, packages, files, commands)
- `network-config` - Network configuration template (required for Raspberry Pi Imager filesystem creation)

### Documentation
- `README.txt` - Notes on cloud-init module usage and file purposes

## For AI Agents
- ENABLE_CLOUD_INIT flag in config controls whether this stage runs
- NoCloud datasource reads config from /boot/firmware/ (FAT partition accessible before boot)
- user-data is heavily commented with examples; users customize after flashing image
- network-config is required for Raspberry Pi Imager tooling even if not used at runtime
- Reference: https://cloudinit.readthedocs.io/en/latest/reference/modules.html#raspberry-pi-configuration
- Files are templates; actual configuration happens post-flash via user modification or Imager presets
