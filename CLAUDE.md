# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Customized fork of pi-gen (Raspberry Pi OS image builder) for Distiller CM5 platform images. Builds arm64 Raspberry Pi OS images with Pamir AI packages, development tools, and platform configuration.

## Build Commands

```bash
# Standard build (requires root)
sudo ./build.sh

# Docker build
./build-docker.sh

# Continue after error
CONTINUE=1 ./build-docker.sh

# Preserve container for debugging
PRESERVE_CONTAINER=1 ./build-docker.sh

# Clean rebuild of last stage
sudo CLEAN=1 ./build.sh

# Use alternate config
./build.sh -c config-distiller-prod
```

## Configuration Files

- `config` - Default dev config (distiller-os_alpha)
- `config-distiller-prod` - Production config (distiller-PROD, includes full stage list)

Key variables in config:
- `STAGE_LIST` - Which stages to build (default: stage*, prod uses explicit list)
- `DISTILLER_PLATFORM` - Platform ID (cm5)
- `DEPLOY_COMPRESSION` - Output format (xz)

## Architecture

### Build Flow

1. `build.sh` sources `config`, then iterates through `STAGE_LIST`
2. Each stage's `prerun.sh` copies previous stage's rootfs via `rsync`
3. Subdirectories (00-*, 01-*) execute in order
4. Stages with `EXPORT_IMAGE` file generate output images

### Key Functions (scripts/common)

- `bootstrap()` - Creates initial filesystem via debootstrap
- `copy_previous()` - Copies previous rootfs with rsync
- `on_chroot` - Executes commands in chroot via capsh

### Stage Execution Order

1. **stage0** - Bootstrap via debootstrap
2. **stage1** - Bootable system (bootloader, network, raspi-config)
3. **stage2** - Lite system (cloud-init, bluetooth, wireless) [EXPORT_IMAGE]
4. **stage3** - Desktop (X11, LXDE)
5. **stage4** - Full Raspberry Pi OS [EXPORT_IMAGE]
6. **stage5** - Development tools [EXPORT_IMAGE]
7. **stage-distiller** - Distiller platform setup
8. **stage-prod** - Pamir AI packages [EXPORT_IMAGE]

### Stage Control Files

- `SKIP` - Skip entire stage
- `SKIP_IMAGES` - Don't generate image at this stage
- `EXPORT_IMAGE` - Generate image after this stage

### Subdirectory Files

- `XX-run.sh` - Shell script (must be executable)
- `XX-run-chroot.sh` - Runs inside chroot
- `XX-packages` - Packages to apt-get install
- `XX-packages-nr` - Packages without recommends
- `XX-debconf` - debconf selections
- `XX-patches/` - Quilt patches (add EDIT file for interactive patching)

## Custom Stages

### stage-distiller

- `00-install-package-dependencies/00-run-chroot.sh` - Configures Pamir AI and Griffo.io APT repos, installs `uv`
- `01-setup-distiller-config/00-run.sh` - Creates welcome message script
- `02-install-dev-tools/00-run-chroot.sh` - Installs nvm, Node.js 20.x, Claude CLI, code-server

### stage-prod

- `00-install-distiller-packages/00-packages` - Installs `distiller-platform-update`, `distiller-genesis-cm5`

## Development Workflow

### Iterative Stage Development

1. Add `SKIP_IMAGES` to stages with `EXPORT_IMAGE` you don't need
2. Add `SKIP` to stages you want to bypass
3. Run `sudo ./build.sh`
4. Add `SKIP` to earlier successful stages
5. Modify target stage
6. Rebuild with `sudo CLEAN=1 ./build.sh`

### Current Skip State

stage0, stage1, stage2, stage-distiller have `SKIP` files (building from cached work/).

### Debug Failed Docker Build

```bash
sudo docker run -it --privileged --volumes-from=pigen_work pi-gen /bin/bash
```

## Critical Constraints

- **Never change BASE_DIR** - breaks build.sh
- **WORK_DIR must be Linux filesystem** - NTFS fails
- **No spaces in repository path** - debootstrap limitation
- **Scripts must be executable** - chmod +x on XX-run.sh files
- **Requires privileged mode** - chroot, loop devices, binfmt

## Output

Images written to `deploy/` with compression per `DEPLOY_COMPRESSION`.
