<!-- Parent: ../AGENTS.md -->
# 01-setup-distiller-config

## Purpose
Creates and configures the Distiller platform welcome message system. This subdirectory sets up a post-boot welcome banner that displays the "PamirAI" ASCII art logo when users log in. The script:
- Creates `/opt/distiller-post-boot-setup.sh` with toilet ASCII banner
- Adds banner invocation to user's `.bashrc`
- Adds banner invocation to root's `.bashrc`

## Key Files

### 00-run.sh
**Not a chroot script** - runs on build host with access to `$ROOTFS_DIR`. Executes:
1. Creates `/opt/distiller-post-boot-setup.sh` containing toilet command for "PamirAI" banner
2. Makes script executable (chmod +x)
3. Conditionally appends banner invocation to `$FIRST_USER_NAME`'s .bashrc (if not present)
4. Conditionally appends banner invocation to root's .bashrc (if not present)

Uses heredoc to write both the banner script and bashrc additions.

## For AI Agents

**Critical Variables:**
- `$ROOTFS_DIR` - Path to target root filesystem (e.g., `/home/utsav/pi-gen/work/2025-01-05-distiller-os/stage-distiller/rootfs`)
- `$FIRST_USER_NAME` - Default user account name (typically "pi" or "distiller")

**File Locations in Target System:**
- Banner script: `/opt/distiller-post-boot-setup.sh`
- User bashrc: `/home/$FIRST_USER_NAME/.bashrc`
- Root bashrc: `/root/.bashrc`

**Idempotency:**
- Script checks for existing banner invocation with `grep -q` before appending
- Safe to run multiple times without duplicating entries

**Banner Command:**
```bash
toilet -t -F border "PamirAI" -f "smblock"
```
Flags: `-t` (terminfo), `-F border` (border filter), `-f smblock` (font)

**Modification Guidelines:**
- To change banner text, modify the string "PamirAI" in heredoc
- To add additional login messages, append commands to distiller-post-boot-setup.sh heredoc
- Banner script location `/opt/` is FHS-compliant for optional application software
- Always preserve conditional check to avoid duplicate bashrc entries
- toilet package must be installed (handled by 00-install-package-dependencies/00-packages)

**Execution Context:**
- Runs on build host, NOT in chroot
- Must use `$ROOTFS_DIR` prefix for all target filesystem paths
- Cannot execute target system binaries (toilet runs at login time, not build time)
