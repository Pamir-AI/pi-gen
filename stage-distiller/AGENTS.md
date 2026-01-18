<!-- Parent: ../AGENTS.md -->
# stage-distiller

## Purpose

Custom Distiller platform setup stage for CM5 hardware. Configures APT repositories (Pamir AI, Griffo.io), installs development tools (nvm, Node.js 20.x, Claude CLI, code-server), and sets up platform branding/welcome messages.

This stage prepares the base platform environment before installing Distiller-specific packages in stage-prod.

## Subdirectories

- **00-install-package-dependencies/** - Configures APT repos and installs base packages
  - `00-packages` - Package list (toilet, git)
  - `00-run-chroot.sh` - Adds Pamir AI and Griffo.io APT repositories, installs `uv` Python package manager

- **01-setup-distiller-config/** - Platform branding and welcome message
  - `00-run.sh` - Creates `/opt/distiller-post-boot-setup.sh` with PamirAI ASCII banner, adds to user/root bashrc

- **02-install-dev-tools/** - Development environment setup
  - `00-run-chroot.sh` - Installs nvm v0.40.1, Node.js 20.19.5, Claude CLI, code-server

## Key Files

- **prerun.sh** - Standard stage prerun that copies previous stage rootfs
- **SKIP** - Currently active (stage skipped in default builds, built from cached work/)

## For AI Agents

When modifying this stage:

1. **APT Repository Changes** - Edit `00-install-package-dependencies/00-run-chroot.sh`
   - Repository URLs and GPG keys for Pamir AI and Griffo.io
   - Verify RELEASE variable is correct for target distribution

2. **Package Dependencies** - Edit `00-install-package-dependencies/00-packages`
   - Basic packages needed before chroot scripts run
   - Keep minimal (toilet for branding, git for dev)

3. **Platform Branding** - Edit `01-setup-distiller-config/00-run.sh`
   - Modify `/opt/distiller-post-boot-setup.sh` content
   - Currently uses `toilet` to display "PamirAI" banner
   - Automatically added to FIRST_USER_NAME and root bashrc

4. **Development Tools** - Edit `02-install-dev-tools/00-run-chroot.sh`
   - NVM version: NVM_VERSION variable
   - Node.js version: NODE_VERSION variable
   - Claude CLI installed via official installer (copies to /usr/local/bin)
   - code-server installed via official installer
   - NVM profile script created in /etc/profile.d/

5. **Execution Order** - Subdirectories execute 00 -> 01 -> 02
   - 00 must complete first (APT repos needed for later packages)
   - 01 can run independently
   - 02 requires curl (installed in 00)

6. **Testing Changes**
   - Remove SKIP file to enable stage
   - Add SKIP to earlier stages (stage0-stage2 already have SKIP)
   - Run `sudo CLEAN=1 ./build.sh` to rebuild from this stage
   - Check logs in work/stage-distiller/

## Dependencies

**Requires from previous stages:**
- stage2 (Lite system) - Base bootable Raspberry Pi OS with network, systemd
- curl (installed in 02 if missing)
- systemd (for code-server service)

**Provides to next stages:**
- APT repositories: Pamir AI, Griffo.io
- Python package manager: uv
- Node.js environment: nvm, Node.js 20.19.5
- Development tools: Claude CLI (/usr/local/bin/claude), code-server
- Platform branding: PamirAI welcome banner

**External dependencies:**
- https://debian.griffo.io (APT repo + GPG key)
- https://apt.pamir.ai (APT repo + GPG key)
- https://raw.githubusercontent.com/nvm-sh/nvm/ (nvm installer)
- https://claude.ai/install.sh (Claude CLI installer)
- https://code-server.dev/install.sh (code-server installer)
