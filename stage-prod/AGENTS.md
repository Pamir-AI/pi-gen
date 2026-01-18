<!-- Parent: ../AGENTS.md -->
# stage-prod

## Purpose

Production deployment stage that installs Pamir AI Distiller platform packages. This is the final stage that creates the production-ready Distiller OS image for CM5 hardware. Installs packages from APT repositories with optional local .deb overrides.

Generates final image output: `distiller-PROD-bigPPbuild.img.xz`

## Subdirectories

- **00-install-distiller-packages/** - Install production Pamir AI packages
  - Installs `distiller-platform-update` and `distiller-genesis-cm5` from APT repos
  - Optional: Copies local .deb files from `files/` directory (overrides APT versions)
  - Local debs are installed with `--reinstall --allow-downgrades` for development testing

## Key Files

- **EXPORT_IMAGE** - Triggers image generation (suffix: "-bigPPbuild")
- **prerun.sh** - Copies previous stage rootfs via `copy_previous()`, adds `~/.local/bin` to PATH
- **00-install-distiller-packages/00-packages** - APT packages: `distiller-platform-update`, `distiller-genesis-cm5`
- **00-install-distiller-packages/00-run.sh** - Host script: copies local .deb files to `/tmp/local-debs` in rootfs
- **00-install-distiller-packages/00-run-chroot.sh** - Chroot script: installs local .debs if present
- **00-install-distiller-packages/files/** - Directory for local .deb packages (bypasses APT)

## For AI Agents

**Installation Priority**: Local .deb files in `files/` override APT repository versions. The build flow is:
1. APT packages (00-packages) install first via standard pi-gen flow
2. Local .debs (if present) install second with `--reinstall --allow-downgrades`

**Adding Local Packages**: Place .deb files in `00-install-distiller-packages/files/` for testing unreleased versions. These install AFTER APT packages and override them.

**Production APT Packages**: Edit `00-install-distiller-packages/00-packages` to add/remove packages from Pamir AI repositories.

**Image Naming**: Modify `EXPORT_IMAGE` to change the image suffix (currently "-bigPPbuild").

**Scripts Must Be Executable**: All `XX-run.sh` files require `chmod +x` to execute during build.

**Testing Workflow**:
1. Add local .deb to `files/` directory
2. Run `sudo CLEAN=1 ./build.sh` to rebuild this stage
3. Remove .deb from `files/` once version is in APT repos

## Dependencies

**Previous Stage**: stage-distiller (provides rootfs with APT repos configured, development tools, platform base)

**External Dependencies**:
- Pamir AI APT repository (configured in stage-distiller)
- Griffo.io APT repository (configured in stage-distiller)
- Internet connection for APT package downloads

**Filesystem State Required**:
- `/etc/apt/sources.list.d/pamir.list` configured
- APT cache updated with Pamir AI package metadata
- Bootable Raspberry Pi OS rootfs from earlier stages

**Output**: Final production image with all Distiller platform components installed, ready for CM5 deployment.
