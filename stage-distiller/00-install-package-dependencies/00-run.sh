#!/bin/bash -e

# Create distiller user and group first
echo "Creating distiller user and group..."
on_chroot << EOF
# Create distiller group and user
groupadd -r distiller 2>/dev/null || true
useradd -r -s /bin/false -d /opt -g distiller distiller 2>/dev/null || true
EOF

echo "Installing uv, claude-code and code-server..."
on_chroot << EOF
echo "Installing astral uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh

sudo cp /root/.local/bin/uv /usr/local/bin/uv
sudo chown distiller:distiller /usr/local/bin/uv
sudo chmod +x /usr/local/bin/uv

echo "Installing claude-code CLI..."
npm install -g @anthropic-ai/claude-code@1.0.81

echo "Installing VS Code server..."
curl -fsSL https://code-server.dev/install.sh | sh
EOF
echo "Package dependencies installed successfully"

# Setup Pamir AI APT Repository
echo "Setting up Pamir AI APT repository..."

on_chroot << EOF
echo "Adding Pamir AI GPG key and APT repository..."
wget -qO - https://apt.pamir.ai/pamir-ai.gpg | gpg --dearmor -o /usr/share/keyrings/pamir-ai-archive-keyring.gpg

echo "Adding Pamir AI APT repository to sources list..."
echo "deb [arch=arm64 signed-by=/usr/share/keyrings/pamir-ai-archive-keyring.gpg] https://apt.pamir.ai/ unstable main" | tee /etc/apt/sources.list.d/pamir-ai.list

echo "Updating package lists..."
apt-get update
EOF

echo "Pamir AI APT repository configured successfully"
