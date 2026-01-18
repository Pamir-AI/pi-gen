<!-- Parent: ../AGENTS.md -->
# 01-user-rename

## Purpose
Configures first-boot user rename functionality. Either enables the rename wizard for first boot or disables it based on `DISABLE_FIRST_BOOT_USER_RENAME` config variable.

## Key Files
- `00-packages` - Installs `userconf-pi` package for user rename functionality
- `01-run.sh` - Conditionally runs `rename-user -f -s` in chroot or removes `piwiz.desktop` autostart

## For AI Agents
- If `DISABLE_FIRST_BOOT_USER_RENAME == 0`: Sets up staged rename for user `${FIRST_USER_NAME}` on first boot
- If disabled: Removes `/etc/xdg/autostart/piwiz.desktop` to skip rename wizard
- The `-f` flag forces rename, `-s` stages it for next boot
- This affects user experience on first boot - handle `FIRST_USER_NAME` variable carefully
