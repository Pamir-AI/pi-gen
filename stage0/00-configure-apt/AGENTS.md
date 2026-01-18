<!-- Parent: ../AGENTS.md -->
# 00-configure-apt

## Purpose
Configures APT package sources for Debian and Raspberry Pi repositories. Sets up dual-architecture support (armhf/arm64) and performs initial system update.

## Key Files
- `00-run.sh` - Installs source files, configures APT proxy/temp repo if set, adds cross-architecture, runs dist-upgrade
- `01-packages` - Installs raspberrypi-archive-keyring package
- `files/debian.sources` - Debian repository configuration (main, security, updates)
- `files/raspi.sources` - Raspberry Pi archive repository configuration
- `files/raspberrypi-archive-keyring.pgp` - GPG key for Raspberry Pi packages
- `files/51cache` - APT proxy configuration template (optional)

## For AI Agents
- RELEASE variable gets substituted in .sources files (e.g., bookworm)
- Adds opposite architecture for cross-compilation (armhf images get arm64, vice versa)
- First apt-get update and dist-upgrade happens here
- APT_PROXY and TEMP_REPO are optional config variables
