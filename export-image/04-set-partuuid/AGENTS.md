<!-- Parent: ../AGENTS.md -->
# 04-set-partuuid

## Purpose
Replaces placeholder device names with actual partition UUIDs in boot configuration. Extracts disk ID from image file and updates `/etc/fstab` and `/boot/firmware/cmdline.txt` with PARTUUIDs for boot and root partitions.

## Key Files
- `00-run.sh` - Extracts IMGID from image, generates PARTUUIDs, updates fstab and cmdline.txt

## For AI Agents
- Operates directly on image file: `${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.img`
- Extracts 4-byte disk ID from offset 440 (MBR signature): `dd if=IMG skip=440 bs=1 count=4`
- Generates UUIDs: `${IMGID}-01` (boot), `${IMGID}-02` (root)
- Replaces placeholders:
  - `BOOTDEV` -> `PARTUUID=${BOOT_PARTUUID}` in `/etc/fstab`
  - `ROOTDEV` -> `PARTUUID=${ROOT_PARTUUID}` in `/etc/fstab` and `/boot/firmware/cmdline.txt`
- Critical for boot: kernel cmdline and fstab must reference same root partition
- If boot fails with "cannot find root", check PARTUUID substitution here
