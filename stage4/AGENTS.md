<!-- Parent: ../AGENTS.md -->
# stage4

## Purpose
Creates full Raspberry Pi OS with complete desktop environment and additional application suites. Extends stage3 (desktop base) with productivity applications, development tools, graphics software, and utilities to produce the standard Raspberry Pi OS distribution.

This stage generates an exportable image (`EXPORT_IMAGE` present).

## Subdirectories

### 00-install-packages
Installs Raspberry Pi Desktop meta-packages:
- `rpd-applications` - Productivity apps (LibreOffice, media players)
- `rpd-developer` - Development tools and IDEs
- `rpd-graphics` - Graphics and imaging software
- `rpd-utilities` - System utilities and tools
- `rpd-wayland-extras` - Additional Wayland compositor support
- `rpd-x-extras` - Additional X11 tools

### 01-disable-wayvnc
Disables VNC server via raspi-config. Runs `raspi-config nonint do_vnc 1` to turn off VNC functionality.

## Key Files

- **prerun.sh** - Copies stage3 rootfs via `copy_previous()` if ROOTFS_DIR doesn't exist
- **EXPORT_IMAGE** - Triggers image generation after this stage completes
- **00-install-packages/00-packages** - List of RPD meta-packages to install with apt-get
- **01-disable-wayvnc/00-run.sh** - Disables VNC via raspi-config in chroot

## For AI Agents

When modifying stage4:

1. **Adding packages**: Append to `00-install-packages/00-packages` or create new subdirectory with `XX-packages` file
2. **Configuration changes**: Add new `XX-run.sh` or `XX-run-chroot.sh` scripts in existing or new subdirectories
3. **Execution order**: Subdirectories execute alphabetically (00-, 01-, etc.)
4. **Testing changes**:
   - Add `SKIP` to stage0-stage3 to use cached work
   - Run `sudo CLEAN=1 ./build.sh` to rebuild only this stage
   - Add `SKIP_IMAGES` if you don't need the exported image during iteration
5. **Script requirements**: All `XX-run.sh` files must be executable (`chmod +x`)
6. **Chroot context**: Use `XX-run-chroot.sh` for commands that need to run inside the target filesystem

## Dependencies

- **stage3 rootfs** - Requires completed stage3 with X11 and LXDE desktop environment
- **Meta-packages** - Depends on `rpd-*` packages from Raspberry Pi OS repositories
- **raspi-config** - Uses raspi-config tool from earlier stages for VNC configuration

## Output

Generates complete Raspberry Pi OS image in `deploy/` directory with all desktop applications and tools.
