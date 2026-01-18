<!-- Parent: ../AGENTS.md -->
# export-noobs

## Purpose

**LEGACY/DEPRECATED**: Exports Raspberry Pi OS image in NOOBS (New Out Of Box Software) format. NOOBS was the official Raspberry Pi installer that allowed users to choose and install operating systems from a GUI during first boot. This export format is largely obsolete, replaced by Raspberry Pi Imager.

Converts standard `.img` file from `export-image` stage into NOOBS-compatible format:
- Compresses boot and root partitions as separate `.tar.xz` archives
- Generates metadata files (os.json, partitions.json) with checksums and size calculations
- Packages marketing materials (slides) for NOOBS installer UI
- Creates partition setup script for NOOBS to configure fstab/cmdline.txt

## Subdirectories

### 00-release
Packages the final NOOBS release bundle with metadata, marketing assets, and compressed filesystem tarballs.

## Key Files

### prerun.sh
- Mounts the `.img` file from `export-image` via loop device
- Enables `apply_noobs_os_config.service` systemd unit
- Extracts kernel version from changelog
- Creates compressed tarballs: `boot.tar.xz` (boot partition), `root.tar.xz` (root filesystem)

### 00-release/00-run.sh
- Installs NOOBS metadata files (os.json, partitions.json, partition_setup.sh)
- Calculates SHA256 checksums for boot/root tarballs
- Computes uncompressed sizes and nominal partition sizes
- Substitutes template variables (BOOT_SIZE, ROOT_SHASUM, NOOBS_NAME, etc.)
- Creates marketing.tar from slide images
- Deploys final NOOBS bundle to `${DEPLOY_DIR}`

### files/os.json (template)
NOOBS OS descriptor with placeholders:
- OS name, description, version, release date
- Kernel version
- Supported Pi models (Zero 2, 3, 4, CM3, CM4)
- Default credentials (pi/raspberry)

### files/partitions.json (template)
Partition layout specification:
- Boot partition: FAT32, 256MB nominal, checksummed
- Root partition: ext4, auto-sized with 20% overhead, want_maximised=true

### files/partition_setup.sh
NOOBS post-install script that:
- Mounts boot and root partitions
- Updates cmdline.txt with correct root partition
- Updates /etc/fstab with partition UUIDs
- Copies SSH/WiFi config from NOOBS settings if present
- Handles resize behavior based on NOOBS flags

### files/marketing/slides_vga/*.png
Marketing slides displayed in NOOBS installer (A.png through G.png).

## For AI Agents

**DO NOT USE THIS EXPORT FORMAT** unless specifically maintaining legacy NOOBS support. Modern workflows should use:
- Direct `.img` file from `export-image` stage
- Raspberry Pi Imager (official tool replacing NOOBS)
- Custom deployment tools for production images

If modifying this stage:
- NOOBS format requires strict adherence to metadata schema (os.json, partitions.json)
- Nominal partition sizes must account for compression ratios (currently 1.2x + 400MB overhead for root)
- partition_setup.sh runs in NOOBS recovery environment, not the target OS
- Marketing slides must be VGA resolution (640x480)
- Kernel version extraction assumes `raspberrypi-kernel` package changelog format

**SKIP this stage** by creating `SKIP` file unless NOOBS export is explicitly required.

## Dependencies

### Build-time
- `bsdtar` - Creates gnutar format archives with numeric owners
- `xz` - Compresses tarballs with -T0 (multithreaded)
- Loop device support - Mounts `.img` file

### Input
- `${WORK_DIR}/export-image/${IMG_FILENAME}${IMG_SUFFIX}.img` - Source image from export-image stage

### Configuration Variables
- `NOOBS_NAME` - Display name in NOOBS UI
- `NOOBS_DESCRIPTION` - OS description text
- `IMG_DATE` - Release date
- `RELEASE` - Version string

### Output
- `${DEPLOY_DIR}/${IMG_NAME}${IMG_SUFFIX}/` - Complete NOOBS bundle ready for SD card deployment
