<!-- Parent: ../AGENTS.md -->
# 05-finalise

## Purpose
Final image cleanup, optimization, and packaging. Generates initramfs, removes build artifacts, zeroes free space, creates SBOM/bmap files, and compresses image for deployment.

## Key Files
- `01-run.sh` - Multi-phase finalization: initramfs generation, cleanup, zerofree, compression, deployment

## For AI Agents

### Phase 1: Initramfs and System Finalization (lines 8-36)
- `update-initramfs -k all -c` - Generate initramfs for all installed kernels
- `hardlink -t /usr/share/doc` - Deduplicate documentation files
- `apt-listchanges.populate_database` - Populate changelog database, disable timer
- Creates systemd-timesync directories with correct ownership
- Sets `update_initramfs=yes` and `MODULES=dep` in initramfs config
- Removes QEMU static binary: `/usr/bin/qemu-arm-static`
- Restores `/etc/ld.so.preload` if not using QEMU (reverses 00-allow-rerun)

### Phase 2: Cleanup (lines 38-67)
Removes build artifacts and resets system state:
- Network config backups: `interfaces.dpkg-old`
- APT caches: `sources.list~`, `trusted.gpg~`
- User database backups: `passwd-`, `group-`, `shadow-`, `gshadow-`, `subuid-`, `subgid-`
- Package manager caches: `debconf/*-old`, `dpkg/*-old`, `apt/archives/*`
- Icon theme caches
- **Machine ID**: Deletes `/var/lib/dbus/machine-id`, writes "uninitialized" to `/etc/machine-id`
- Symlinks `/etc/mtab` to `/proc/mounts`
- **Zeroes all log files**: `cp /dev/null` to each file in `/var/log/`
- VNC private keys: `~/.vnc/private.key`, `/etc/vnc/updateid`

### Phase 3: Issue File and Metadata (lines 68-92)
- Calls `update_issue` function with export directory name
- Copies `/etc/rpi-issue` to `/boot/firmware/issue.txt` and creates symlink
- Copies `rpi-issue` to `.info` file
- Extracts firmware/kernel versions from changelog if available
- Fetches git hashes from GitHub for firmware and kernel
- Appends full package list via `dpkg -l` to info file

### Phase 4: SBOM Generation (lines 94-100)
- If `syft` available: generates SPDX JSON SBOM with:
  - Source name: `${IMG_NAME}${IMG_SUFFIX}`
  - Source version: `${IMG_DATE}`
  - Base path: `${ROOTFS_DIR}`

### Phase 5: Filesystem Optimization (lines 102-107)
- Unmounts rootfs
- **Runs `zerofree` on root device** - zeroes unused blocks for better compression
- Unmounts entire image

### Phase 6: Bmap Creation (lines 109-113)
- If `bmaptool` available: creates block map file (`.bmap`) for faster flashing

### Phase 7: Deployment (lines 115-146)
- Creates `${DEPLOY_DIR}`
- Removes previous deployment artifacts
- Compresses based on `${DEPLOY_COMPRESSION}`:
  - `zip`: Creates ZIP archive with compression level
  - `gz`: Uses `pigz` (parallel gzip) with threads
  - `xz`: Multi-threaded XZ with 50% memory limit
  - `none`: Direct copy
- Copies SBOM (xz compressed), bmap, and info files to deploy directory

### Critical Variables
- `IMG_FILE`: `${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.img`
- `INFO_FILE`: `${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.info`
- `SBOM_FILE`: `${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.sbom`
- `BMAP_FILE`: `${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.bmap`
- `DEPLOY_DIR`: Final output directory
- `ARCHIVE_FILENAME`: Name for compressed output
- `COMPRESSION_LEVEL`: 1-9 for compression algorithms

### Dependencies
- `zerofree` - Required for free space zeroing
- `syft` - Optional for SBOM generation
- `bmaptool` - Optional for block map creation
- `pigz` - For parallel gzip compression
- `xz` - For XZ compression

### Common Issues
- If initramfs generation fails: check kernel package installation
- If zerofree hangs: ensure filesystem is cleanly unmounted
- If compression runs out of memory: adjust `--memlimit-compress` for XZ
- Machine ID reset ensures unique IDs on each boot - critical for distributed systems
