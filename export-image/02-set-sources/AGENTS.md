<!-- Parent: ../AGENTS.md -->
# 02-set-sources

## Purpose
Cleans up temporary build APT configuration and performs final system upgrade. Removes build-time APT cache settings and temporary source lists, then updates and upgrades all packages to latest versions.

## Key Files
- `01-run.sh` - Removes `51cache` and `00-temp.list`, clears APT lists, runs `dist-upgrade --auto-remove --purge`

## For AI Agents
- Critical step: ensures final image has latest packages and no build artifacts
- Removed files:
  - `/etc/apt/apt.conf.d/51cache` - build-time cache config
  - `/etc/apt/sources.list.d/00-temp.list` - temporary sources added during build
- Deletes all APT list files before fresh `apt-get update`
- `dist-upgrade` ensures kernel/bootloader updates applied
- `--auto-remove --purge` cleans orphaned packages and config files
- This can significantly increase build time - runs in chroot
