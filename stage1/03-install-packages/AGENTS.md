<!-- Parent: ../AGENTS.md -->
# 03-install-packages

## Purpose
Installs essential system packages. Currently minimal, only adds NTP time synchronization.

## Key Files
- `00-packages` - Package list for `apt-get install`:
  - `systemd-timesyncd` - NTP client for automatic time synchronization

## For AI Agents
- This subdirectory contains only package declarations, no run scripts
- Packages installed automatically during stage processing
- `systemd-timesyncd` lighter alternative to full `ntp` daemon
- Add additional packages here if needed for stage1 (bootable system) baseline
- For packages without recommended dependencies, use `XX-packages-nr` instead
- Files in this directory do not require executable permissions
