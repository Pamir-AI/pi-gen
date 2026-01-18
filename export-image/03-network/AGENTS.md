<!-- Parent: ../AGENTS.md -->
# 03-network

## Purpose
Installs default DNS resolver configuration for the image. Sets Google DNS (8.8.8.8) as nameserver to ensure connectivity on first boot before network manager configures DNS.

## Key Files
- `01-run.sh` - Installs `files/resolv.conf` to `/etc/resolv.conf` with mode 644
- `files/resolv.conf` - Contains single line: `nameserver 8.8.8.8`

## For AI Agents
- This is a fallback DNS configuration - network manager will override on first boot
- Using Google DNS (8.8.8.8) ensures immediate connectivity without local DNS infrastructure
- Mode 644 (rw-r--r--) is standard for `/etc/resolv.conf`
- If modifying: consider privacy implications of hardcoded DNS, consider adding secondary nameserver
- Alternative nameservers: Cloudflare (1.1.1.1), Quad9 (9.9.9.9)
