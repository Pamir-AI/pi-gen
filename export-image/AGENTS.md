<!-- Parent: ../AGENTS.md -->
# export-image

## Purpose

Image finalization pipeline that runs after each stage with EXPORT_IMAGE. Creates bootable disk images from the built rootfs, applies final configuration, and packages images for deployment with optional compression.

## Subdirectories

- **00-allow-rerun/** - Disables `/etc/ld.so.preload` to allow image to be remounted and modified during export
- **01-user-rename/** - Configures first-boot user rename wizard (installs `userconf-pi` package) or disables it if `DISABLE_FIRST_BOOT_USER_RENAME=1`
- **02-set-sources/** - Cleans temporary APT configuration, performs final `apt-get update && dist-upgrade`, removes cached packages
- **03-network/** - Installs static DNS resolver config (`8.8.8.8`)
- **04-set-partuuid/** - Extracts disk ID from image, updates `/etc/fstab` and `/boot/firmware/cmdline.txt` to use PARTUUIDs instead of placeholder device names
- **05-finalise/** - Final image processing: generates initramfs, cleans temporary files, zeroes free space, creates SBOM, compresses image per `DEPLOY_COMPRESSION`, writes to `deploy/`

## Key Files

- **prerun.sh** - Creates disk image with partition table, formats boot (FAT32) and root (ext4) partitions, mounts via loop device, rsyncs `EXPORT_ROOTFS_DIR` to `ROOTFS_DIR`
  - Calculates image size: 512MB boot + (rootfs size * 1.2 + 200MB margin)
  - Creates msdos partition table with 8MB alignment
  - Uses `losetup --partscan` for partition access

## For AI Agents

Working with export-image:

1. **Image Creation Flow**
   - `prerun.sh` creates fresh `.img` file with partitions and copies rootfs
   - Subdirectories (00-05) execute in order to finalize rootfs content
   - `05-finalise/01-run.sh` unmounts, zeroes free space, compresses to `deploy/`

2. **Critical Variables**
   - `IMG_FILE` - Path to raw `.img` file in `STAGE_WORK_DIR`
   - `EXPORT_ROOTFS_DIR` - Source rootfs from previous stage
   - `ROOTFS_DIR` - Mounted image rootfs (loop device)
   - `DEPLOY_COMPRESSION` - Output format: `xz` (default), `zip`, `gz`, or `none`
   - `DEPLOY_DIR` - Final output directory (typically `deploy/`)

3. **Partition Layout**
   - p1: Boot partition (FAT32, 512MB, labeled `bootfs`)
   - p2: Root partition (ext4, auto-sized, labeled `rootfs`)
   - Mounted as `ROOTFS_DIR/boot/firmware` and `ROOTFS_DIR/`

4. **Finalization Steps (05-finalise)**
   - Rebuilds initramfs for all kernels
   - Hardlinks duplicate files in `/usr/share/doc`
   - Clears logs, machine-id, temporary files
   - Runs `zerofree` on root partition to reduce compressed size
   - Generates `.info` file with package list and kernel versions
   - Optionally generates SBOM (`.sbom.xz`) via `syft`
   - Optionally generates block map (`.bmap`) via `bmaptool`
   - Compresses image to `deploy/` as `.img.xz`, `.img.gz`, or `.zip`

5. **Common Modifications**
   - Add pre-finalization cleanup: new subdirectory between 04 and 05
   - Change compression: set `DEPLOY_COMPRESSION` in config
   - Skip compression: `DEPLOY_COMPRESSION=none`
   - Custom network config: modify `03-network/files/resolv.conf`

6. **Debugging**
   - Image file persists in `STAGE_WORK_DIR` until next export
   - Mount manually: `sudo losetup -Pf image.img && sudo mount /dev/loop0p2 /mnt`
   - Check partition UUIDs: `blkid` on loop devices
   - Examine `.info` file for package inventory

## Dependencies

- **Input**: `EXPORT_ROOTFS_DIR` from previous stage's final rootfs
- **Tools**: `parted`, `losetup`, `mkdosfs`, `mkfs.ext4`, `rsync`, `zerofree`, `xz/pigz/zip` (compression)
- **Optional**: `syft` (SBOM generation), `bmaptool` (block map), `hardlink` (deduplication)
- **Output**: Compressed bootable image in `deploy/`, `.info` file, optional `.sbom.xz` and `.bmap` files
