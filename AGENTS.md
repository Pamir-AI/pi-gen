# pi-gen

Raspberry Pi OS image builder - customized fork for Distiller CM5 platform.

## Purpose

Build arm64 Raspberry Pi OS images with Pamir AI packages, development tools, and platform-specific configuration. Creates bootable SD card images through a staged build process using debootstrap, chroot, and rsync.

## Key Files

- `build.sh` - Main build orchestration script; sources config, iterates `STAGE_LIST`, executes stages in order
- `build-docker.sh` - Docker-based build wrapper for isolated builds
- `gen-image.sh` - Post-stage image generation utility (creates .img files)
- `config` - Default dev configuration (distiller-os_alpha)
- `config-distiller-prod` - Production configuration with full stage list

## Directories

- `scripts/` - Build infrastructure and shared functions (see scripts/AGENTS.md)
- `stage0/` - Bootstrap via debootstrap (see stage0/AGENTS.md)
- `stage1/` - Bootable system foundation (see stage1/AGENTS.md)
- `stage2/` - Lite system with networking (see stage2/AGENTS.md)
- `stage3/` - Desktop environment (see stage3/AGENTS.md)
- `stage4/` - Full Raspberry Pi OS (see stage4/AGENTS.md)
- `stage5/` - Development tools (see stage5/AGENTS.md)
- `stage-distiller/` - Custom Distiller platform setup (see stage-distiller/AGENTS.md)
- `stage-prod/` - Production Pamir AI packages (see stage-prod/AGENTS.md)
- `export-image/` - Image finalization pipeline (see export-image/AGENTS.md)
- `export-noobs/` - Legacy NOOBS format export (see export-noobs/AGENTS.md)
- `deploy/` - Output directory for built images
- `work/` - Build artifacts and cached rootfs (root-owned)

## For AI Agents

### Build Flow

1. `build.sh` sources `config`, validates environment, iterates `STAGE_LIST`
2. Each stage's `prerun.sh` copies previous rootfs via `rsync` (except stage0 which bootstraps)
3. Subdirectories (00-*, 01-*) execute in numerical order
4. Stages with `EXPORT_IMAGE` file trigger `export-image/` pipeline
5. Final images written to `deploy/` with configured compression

### Execution Order in Subdirectories

For each numbered subdirectory (00-XX, 01-XX, etc.):
1. `XX-debconf` - debconf selections applied first
2. `XX-packages-nr` - Packages installed without recommends
3. `XX-packages` - Packages installed with recommends
4. `XX-patches/` - Quilt patches applied
5. `XX-run.sh` - Shell script executed (must be executable)
6. `XX-run-chroot.sh` - Script piped to `on_chroot`

### Stage Control Files

- `SKIP` - Skip entire stage
- `SKIP_IMAGES` - Don't generate image at this stage
- `EXPORT_IMAGE` - Generate image after this stage completes

### Critical Constraints

- Never change `BASE_DIR` - breaks build.sh path resolution
- `WORK_DIR` must be on Linux filesystem (NTFS fails)
- No spaces in repository path (debootstrap limitation)
- All `XX-run.sh` scripts must be executable (chmod +x)
- Requires privileged mode for chroot/loop devices/binfmt

### Common Development Tasks

- Skip stages: Create `SKIP` file in stage directory
- Avoid image generation: Create `SKIP_IMAGES` in stages with `EXPORT_IMAGE`
- Clean rebuild: `CLEAN=1 ./build.sh`
- Debug Docker build: `docker run -it --privileged --volumes-from=pigen_work pi-gen /bin/bash`

## Dependencies

- debootstrap, qemu-user-static (binfmt), quilt
- rsync for rootfs copying between stages
- capsh for capability-aware chroot execution
- Docker (optional, for containerized builds)
