#!/bin/bash -e

echo "Installing development tools..."

# Install curl if not present
apt-get update
apt-get install -y curl

# NVM installation
TARGET_USER="${FIRST_USER_NAME:-pi}"
NODE_VERSION="20.19.5"
NVM_VERSION="v0.40.1"
NVM_URL="https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh"

echo "Installing NVM for user: $TARGET_USER"

# Install NVM for the target user
su - "$TARGET_USER" -c "curl -o- $NVM_URL | bash"

# Install Node.js via NVM
install_cmd='export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install '"$NODE_VERSION"' && nvm alias default '"$NODE_VERSION"

su - "$TARGET_USER" -c "$install_cmd"

# Create system-wide NVM profile script
mkdir -p /etc/profile.d
cat > /etc/profile.d/nvm.sh << 'EOF'
# NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
chmod 644 /etc/profile.d/nvm.sh

echo "NVM and Node.js $NODE_VERSION installed successfully"

# Install Claude Code CLI for target user
echo "Installing Claude Code CLI for $TARGET_USER..."
su - "$TARGET_USER" -c 'curl -fsSL https://claude.ai/install.sh | bash'

# Verify installation
if su - "$TARGET_USER" -c 'command -v claude' &>/dev/null; then
    echo "Claude Code CLI installed successfully"
else
    echo "Warning: Claude Code CLI verification failed"
fi

# Install code-server
echo "Installing code-server..."
curl -fsSL https://code-server.dev/install.sh | sh
echo "code-server installed and configured successfully"

echo "Development tools installation completed"
