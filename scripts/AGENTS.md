<!-- Parent: ../AGENTS.md -->
# scripts

## Purpose
Core build system utilities for pi-gen. Contains shared functions used across all stages for bootstrapping, chroot operations, filesystem manipulation, and dependency validation.

## Key Files

### common
Primary function library sourced by build.sh and stage scripts. Exports critical functions:

- **bootstrap()** - Creates initial Debian filesystem via debootstrap
  - Configures for arm64 architecture
  - Includes gnupg, ca-certificates
  - Uses components: main, contrib, non-free
  - Excludes info, ifupdown packages
  - Returns error if debootstrap fails (leaves log in STAGE_WORK_DIR)

- **copy_previous()** - Copies previous stage rootfs to current stage
  - Uses rsync with archive, hard-links, ACLs, extended attrs (-aHAXx)
  - Excludes var/cache/apt/archives to save space
  - Required for iterative stage builds

- **on_chroot()** - Executes commands inside chroot environment
  - Mounts proc, dev, dev/pts, sys, run, tmp before execution
  - Uses capsh for privilege management
  - Critical for running XX-run-chroot.sh scripts

- **unmount()** - Safely unmounts directory with retries (6 attempts)
- **unmount_image()** - Unmounts loop device partitions
- **update_issue()** - Writes /etc/rpi-issue with build metadata
- **ensure_next_loopdev()** - Creates loop device if missing
- **ensure_loopdev_partitions()** - Creates partition device nodes
- **log()** - Timestamped logging to LOG_FILE

### dependencies_check
Validates required build dependencies are installed.

- Parses dependency files (format: "tool:package" or just "tool")
- Uses remove-comments.sed to strip comments from depends files
- Checks for binfmt_misc kernel module (skips on native arm/aarch64)
- Reports missing packages in Debian package format

### remove-comments.sed
Sed script for cleaning package list files.

- Removes comments (# to end of line)
- Collapses whitespace to single spaces
- Used by dependencies_check for parsing

## For AI Agents

### Critical Constraints
- **Never modify bootstrap() arch** - hardcoded to arm64 for this fork
- **ROOTFS_DIR must exist before on_chroot()** - will fail if missing mounts
- **copy_previous() requires PREV_ROOTFS_DIR** - fails if previous stage skipped
- **All functions use exported vars** - ROOTFS_DIR, STAGE_DIR, STAGE_WORK_DIR, etc.

### Common Patterns
When creating stage scripts:
- Source common functions: `. /scripts/common` (available in stage context)
- Use on_chroot for any command that modifies rootfs packages/config
- Use log() for all output (captures to build log with timestamps)
- Check mount status before manual mount operations

### Debugging
- Bootstrap failures: check STAGE_WORK_DIR/debootstrap.log
- Chroot failures: verify proc/dev/sys mounts exist in ROOTFS_DIR
- Unmount issues: may indicate lingering processes or nested mounts

## Dependencies

### System Requirements
- debootstrap - Debian filesystem bootstrapping
- rsync - Filesystem copying with attributes
- capsh (libcap2-bin) - Capability-based privilege management
- losetup - Loop device management
- binfmt_misc - ARM64 binary format support (x86_64 hosts only)
- udevadm (udev) - Device node management

### Environment Variables
Functions expect these to be set by build.sh:
- ROOTFS_DIR - Current stage rootfs path
- PREV_ROOTFS_DIR - Previous stage rootfs path
- STAGE_DIR - Current stage directory
- STAGE_WORK_DIR - Current stage work directory
- LOG_FILE - Build log file path
- CAPSH_ARG - Capability arguments for capsh
- APT_PROXY - Optional HTTP proxy for apt
