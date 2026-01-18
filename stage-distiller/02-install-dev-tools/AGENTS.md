<!-- Parent: ../AGENTS.md -->
# 02-install-dev-tools

## Purpose
Installs development environment for Distiller platform including Node.js runtime, AI coding assistant, and web-based IDE. This subdirectory provisions:
- NVM (Node Version Manager) for user-level Node.js installation
- Node.js 20.19.5 via NVM
- Claude Code CLI (official Anthropic AI coding assistant)
- code-server (VS Code in the browser)

## Key Files

### 00-run-chroot.sh
Chroot script that installs all development tools. Executes:

**1. NVM Installation (lines 9-23)**
- Installs NVM v0.40.1 for `$FIRST_USER_NAME` user
- Downloads via curl from nvm-sh/nvm GitHub
- Runs as target user with `su - "$TARGET_USER" -c`
- Installs Node.js 20.19.5 and sets as default

**2. System-wide NVM Profile (lines 25-33)**
- Creates `/etc/profile.d/nvm.sh` for all users
- Exports `$NVM_DIR` and sources nvm.sh + bash_completion

**3. Claude Code CLI (lines 37-47)**
- Sources NVM to make npm available
- Downloads official installer from claude.ai/install.sh
- Copies binary from `~/.local/bin/claude` to `/usr/local/bin/claude` for system-wide access

**4. code-server (lines 49-52)**
- Downloads installer from code-server.dev/install.sh
- Installs web-based VS Code IDE

## For AI Agents

**Critical Variables:**
- `$FIRST_USER_NAME` - Target user for NVM installation (defaults to "pi" if unset)
- `NODE_VERSION` - Pinned to 20.19.5 (LTS)
- `NVM_VERSION` - Pinned to v0.40.1
- `$NVM_DIR` - Computed as `$HOME/.nvm` (user-specific)

**Installation Paths:**
- NVM: `/home/$FIRST_USER_NAME/.nvm/`
- Node.js: `/home/$FIRST_USER_NAME/.nvm/versions/node/v20.19.5/`
- Claude CLI (user): `~/.local/bin/claude`
- Claude CLI (system): `/usr/local/bin/claude`
- code-server: System-wide via official installer
- NVM profile: `/etc/profile.d/nvm.sh`

**User Context Switching:**
- Lines 18, 23: `su - "$TARGET_USER" -c` to run commands as target user (required for NVM)
- Lines 41-42: Sources NVM in root context for system-level operations
- Line 47: Copies from root's `$HOME/.local/bin/` to `/usr/local/bin/`

**Network Dependencies:**
- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh
- https://nodejs.org (via NVM for Node.js downloads)
- https://claude.ai/install.sh
- https://code-server.dev/install.sh

**Modification Guidelines:**
- **Node.js version**: Update `NODE_VERSION` variable (use LTS releases)
- **NVM version**: Update `NVM_VERSION` and `NVM_URL` together
- **Claude CLI location**: Line 47 assumes root installation to `$HOME/.local/bin/` - may need adjustment if installer changes
- **code-server config**: Post-install configuration would require additional steps (systemd service, password setup, etc.)

**Known Issues:**
- Line 47 check `[ -f "$HOME/.local/bin/claude" ]` may fail if Claude installer changes location
- NVM profile script uses `$HOME`, which is user-specific (correct for /etc/profile.d/ context)
- No error handling for failed downloads or installations

**Verification:**
After build, target system should have:
```bash
# As $FIRST_USER_NAME:
node --version  # v20.19.5
nvm --version   # 0.40.1
claude --version
code-server --version

# As root:
/usr/local/bin/claude --version
```

**PATH Configuration:**
- NVM adds Node.js to PATH via `/etc/profile.d/nvm.sh`
- Claude CLI available system-wide via `/usr/local/bin/claude`
- code-server installer handles PATH setup
