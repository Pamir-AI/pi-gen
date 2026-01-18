<!-- Parent: ../AGENTS.md -->
# stage3

## Purpose

Adds desktop environment to the Raspberry Pi OS Lite system from stage2. Installs Raspberry Pi Desktop (rpd) with X11 and Wayland display server core packages, desktop preferences, theming, and printing support. This transforms the minimal Lite system into a GUI-enabled desktop environment.

## Subdirectories

- **00-install-packages/** - Installs Raspberry Pi Desktop core components
  - `00-packages-nr` - Core display server packages (X11, Wayland) installed without recommends
  - `00-packages` - Desktop preferences and theme packages with recommends
- **01-print-support/** - Configures printing capabilities
  - `00-run.sh` - Adds first user to lpadmin group for printer administration

## Key Files

- `prerun.sh` - Copies stage2 rootfs if not present (standard stage initialization)
- No `SKIP` or `EXPORT_IMAGE` files - stage runs but doesn't generate image output

## For AI Agents

When modifying this stage:

1. **Desktop Environment Changes** - Edit `00-install-packages/00-packages` or `00-packages-nr` to add/remove desktop components
2. **Package Installation Strategy** - Use `00-packages-nr` for critical packages where recommends cause bloat, `00-packages` for user-facing features where recommends improve UX
3. **User Permissions** - Add additional groups for first user in `01-print-support/00-run.sh` using `adduser "$FIRST_USER_NAME" groupname`
4. **Testing** - No image generated at this stage, test by building through stage4 or manually inspect work/stage3/rootfs/
5. **Skip Control** - Create `SKIP` file to bypass this stage if desktop environment not needed

## Dependencies

- **Input**: stage2 rootfs (Raspberry Pi OS Lite with bootloader, networking, cloud-init)
- **Output**: stage2 rootfs + Raspberry Pi Desktop (X11/Wayland, LXDE-based UI, printing)
- **Next Stage**: stage4 adds full Raspberry Pi OS applications and tools
- **Build System**: Uses `copy_previous()` from scripts/common to rsync stage2 rootfs
