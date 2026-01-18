<!-- Parent: ../AGENTS.md -->
# 03-set-timezone

## Purpose
Sets system timezone from TIMEZONE_DEFAULT config variable.

## Key Files

### Configuration Script
- `02-run.sh` - Timezone setup:
  - Writes TIMEZONE_DEFAULT to /etc/timezone
  - Removes /etc/localtime
  - Runs dpkg-reconfigure tzdata in chroot to regenerate timezone configuration

## For AI Agents
- TIMEZONE_DEFAULT is sourced from config file (e.g., "America/New_York", "Europe/London")
- dpkg-reconfigure with -f noninteractive flag prevents interactive prompts during build
- /etc/localtime is regenerated as symlink to /usr/share/zoneinfo/TIMEZONE_DEFAULT
- Simple, single-purpose subdirectory with no packages or dependencies
