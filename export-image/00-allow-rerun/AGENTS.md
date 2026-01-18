<!-- Parent: ../AGENTS.md -->
# 00-allow-rerun

## Purpose
Disables ARM-specific preload library to allow build scripts to run in QEMU environment. Moves `/etc/ld.so.preload` to `.disabled` suffix, preventing ARM library loading errors during cross-architecture builds.

## Key Files
- `00-run.sh` - Renames `/etc/ld.so.preload` to `/etc/ld.so.preload.disabled` if it exists

## For AI Agents
- This is the first step in export-image finalization - must run before chroot operations
- The preload file is restored in `05-finalise/01-run.sh` for native ARM systems
- If `USE_QEMU != 1`, the restoration happens; otherwise preload stays disabled
- Do not modify - this is critical for cross-compilation workflow
