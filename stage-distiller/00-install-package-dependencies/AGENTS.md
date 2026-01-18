<!-- Parent: ../AGENTS.md -->
# 00-install-package-dependencies

## Purpose
Configures APT repositories for Distiller platform packages and installs core Python tooling. This subdirectory establishes the foundation for Distiller platform package installation by:
- Adding Griffo.io Debian repository (Distiller platform packages)
- Adding Pamir AI APT repository (AI/ML packages)
- Installing `uv` (Python package manager)
- Installing `toilet` (ASCII art generator for welcome banner)
- Installing `git` (version control)

## Key Files

### 00-run-chroot.sh
Chroot script that configures APT repositories. Executes:
1. Downloads and installs GPG keys for both repositories
2. Adds debian.griffo.io repository (uses $RELEASE variable from config)
3. Adds apt.pamir.ai repository (arm64 only, stable main)
4. Runs apt-get update
5. Installs `uv` package

### 00-packages
Package list file containing:
- `toilet` - ASCII art text generator (used for "PamirAI" banner in welcome message)
- `git` - Version control system

## For AI Agents

**Repository URLs:**
- Griffo.io: https://debian.griffo.io/apt (GPG: EA0F721D231FDD3A0A17B9AC7808B4DD62C41256)
- Pamir AI: https://apt.pamir.ai/ (GPG keyring: /usr/share/keyrings/pamir-ai-archive-keyring.gpg)

**Critical Variables:**
- `$RELEASE` - Debian/Ubuntu release codename (e.g., "bookworm", "trixie"), sourced from build config
- Repository configs written to `/etc/apt/sources.list.d/`

**Execution Order:**
1. 00-run-chroot.sh runs first (inside chroot)
2. 00-packages processed after (apt-get install)

**Dependencies:**
- Requires working network connection during build
- GPG keys must be accessible from public URLs
- `$RELEASE` must be set in build environment

**Modification Guidelines:**
- Never hardcode release names - always use `$RELEASE`
- GPG keys must be dearmored before saving to `/etc/apt/trusted.gpg.d/` or `/usr/share/keyrings/`
- Test repository accessibility before modifying URLs
- `uv` is critical dependency for Python tooling in later stages
