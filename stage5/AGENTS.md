<!-- Parent: ../AGENTS.md -->
# stage5

## Purpose
Extends stage4 (full desktop) with development tools, LibreOffice office suite, and educational/creative applications. Produces the "full" variant image with `-full` suffix (or `-full-qemu` when USE_QEMU=1).

This stage creates the most complete Raspberry Pi OS image with professional and educational software.

## Subdirectories

### 00-install-extras
Installs development and creative applications:
- `scratch3` - Visual programming environment
- `claws-mail` - Email client
- `code-the-classics`, `code-the-classics-2` - Educational game development books
- `kicad` - PCB design software

### 00-install-libreoffice
Installs LibreOffice suite with UK English localization:
- `libreoffice-pi` - Raspberry Pi optimized LibreOffice build
- `openjdk-11-jre-` - Java runtime (note: minus suffix indicates package exclusion/removal)
- `libreoffice-help-en-gb` - British English help files
- `libreoffice-l10n-en-gb` - British English localization

## Key Files

- `prerun.sh` - Copies stage4 rootfs if not present via `copy_previous`
- `EXPORT_IMAGE` - Triggers image generation with `-full` suffix after stage completion
- `00-install-extras/00-packages` - Package list for development/creative tools
- `00-install-libreoffice/00-packages` - Package list for LibreOffice suite

## For AI Agents

When modifying this stage:

1. **Adding packages**: Append to `00-packages` files in respective subdirectories. Create new numbered directories (01-*, 02-*) for distinct functionality groups.

2. **Skipping this stage**: Create `SKIP` file to bypass. Create `SKIP_IMAGES` to prevent image generation but still run installation.

3. **Custom configuration**: Add `XX-run.sh` or `XX-run-chroot.sh` scripts for post-install configuration of LibreOffice or development tools.

4. **Image suffix**: Modify `EXPORT_IMAGE` to change `IMG_SUFFIX` if you need a different naming convention.

5. **Package selection**: This is the heaviest stage. Remove unwanted packages to reduce image size. Consider splitting into multiple stages for modular builds.

6. **Localization**: Change `en-gb` to other locale codes for different language support.

## Dependencies

- **stage4 rootfs** - Full desktop environment (LXDE, X11, Chromium, audio/video)
- **Network connectivity** - Downloads large packages (LibreOffice, KiCad)
- **Adequate disk space** - This stage adds ~1GB+ to the image

## Notes

- LibreOffice package uses `openjdk-11-jre-` with trailing hyphen, likely indicating package removal or conflict resolution
- This stage is optional for minimal deployments - most custom builds skip to custom stages after stage2 or stage4
- Execution order: 00-install-extras runs before 00-install-libreoffice (alphabetical)
