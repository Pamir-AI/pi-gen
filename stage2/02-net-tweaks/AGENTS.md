<!-- Parent: ../AGENTS.md -->
# 02-net-tweaks

## Purpose
Network configuration for wireless and bluetooth support. Installs WiFi firmware, wpasupplicant, NetworkManager, and configures rfkill whitelist for on-board Bluetooth adapters.

## Key Files

### Package Management
- `00-packages` - Network packages:
  - wpasupplicant, wireless-tools
  - Firmware: atheros, brcm80211, libertas, realtek, mediatek, marvell-prestera (excluded)
  - raspberrypi-net-mods
  - network-manager
  - net-tools

### Configuration Script
- `01-run.sh` - Network setup:
  - Whitelists Bluetooth adapters in systemd rfkill (prevents 5GHz WLAN regulatory block from disabling BT)
  - Configures WiFi country code via raspi-config if WPA_COUNTRY set
  - Disables NetworkManager wireless by default if WPA_COUNTRY not set

## For AI Agents
- Bluetooth whitelist addresses multiple hardware variants (5, 4, Zero, other)
- WLAN regulatory domain (WPA_COUNTRY) controls 5GHz radio transmission legality
- NetworkManager wireless is disabled by default to prevent auto-enabling WLAN before regulatory domain is set
- rfkill whitelist prevents raspberrypi-sys-mods from blocking bluetooth when WLAN is blocked
- firmware-marvell-prestera is explicitly excluded (minus sign) to avoid unnecessary driver
