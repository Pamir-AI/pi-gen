<!-- Parent: ../AGENTS.md -->
# 02-net-tweaks

## Purpose
Configures network-related system settings including hostname and network interface naming scheme.

## Key Files
- `00-packages` - Installs `netbase` package (provides `/etc/services`, `/etc/protocols`, basic network database)
- `00-run.sh` - Network configuration script:
  - Sets system hostname from `TARGET_HOSTNAME` config variable
  - Adds hostname to `/etc/hosts` as `127.0.1.1`
  - Disables predictable network interface names via `raspi-config nonint do_net_names 1` (keeps traditional `eth0`, `wlan0` naming)

## For AI Agents
- `TARGET_HOSTNAME` sourced from main config file
- `raspi-config nonint do_net_names 1` disables systemd predictable naming (prevents `enp0s3` style names)
- Traditional interface names (`eth0`, `wlan0`) preferred for consistency with Raspberry Pi documentation
- `FIRST_USER_NAME` used as `SUDO_USER` context when running raspi-config
- Hostname changes require reboot to take full effect
