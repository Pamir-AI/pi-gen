<!-- Parent: ../AGENTS.md -->
# 01-sys-tweaks

## Purpose
Applies system-level configuration tweaks including filesystem table setup, user account creation, and shell customization via quilt patches.

## Key Files
- `00-packages` - Installs `raspi-config` package for system configuration utility
- `00-run.sh` - Installs `/etc/fstab`, creates first user account (`FIRST_USER_NAME`), sets passwords (first user + root)
- `files/fstab` - Filesystem mount table with placeholders:
  - `proc` on `/proc`
  - `BOOTDEV` on `/boot/firmware` (vfat)
  - `ROOTDEV` on `/` (ext4, noatime)
- `00-patches/` - Quilt patch directory:
  - `series` - Patch application order
  - `01-bashrc.diff` - Bash shell customization (enables colored prompt, colored grep aliases)

## For AI Agents
- User creation uses config variables: `FIRST_USER_NAME`, `FIRST_USER_PASS`
- Root password hardcoded to "root" (line 13 of `00-run.sh`) - security implication for production
- `BOOTDEV`/`ROOTDEV` placeholders replaced during image finalization
- Quilt patches modify `/etc/skel/.bashrc` to enhance default shell experience
- If patches need interactive editing, create `EDIT` file in `00-patches/`
- `on_chroot` executes commands inside the build rootfs via capsh
