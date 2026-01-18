<!-- Parent: ../AGENTS.md -->
# 00-boot-files

## Purpose
Configures boot partition and firmware files for Raspberry Pi. Sets up bootloader configuration, kernel command line parameters, and creates the `/boot/firmware` structure required for modern Raspberry Pi OS images.

## Key Files
- `00-run.sh` - Creates `/boot/firmware` directory, symlinks `/boot/overlays`, installs boot configuration files, adds migration notices to old boot file locations
- `files/cmdline.txt` - Kernel command line parameters (console output, root device placeholder `ROOTDEV`, filesystem type, auto-resize)
- `files/config.txt` - Raspberry Pi firmware configuration:
  - Audio/camera/display detection
  - 64-bit mode (`arm_64bit=1`)
  - VC4 V3D driver for graphics
  - CM4/CM5 specific USB configurations (`otg_mode=1` for CM4, `dwc2,dr_mode=host` for CM5)

## For AI Agents
- `ROOTDEV` and `BOOTDEV` are placeholders replaced during image finalization
- `config.txt` uses conditional sections (`[cm4]`, `[cm5]`, `[all]`) for hardware-specific settings
- Boot files moved from `/boot/` to `/boot/firmware/` in modern Pi OS; migration notices guide users
- Scripts must be executable (`chmod +x`)
- All changes here affect boot behavior; test thoroughly on target hardware
