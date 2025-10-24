#!/bin/bash -e

# Create distiller user and group first
echo "Creating distiller user and group..."
on_chroot << EOF
groupadd -r distiller 2>/dev/null || true
useradd -r -s /bin/false -d /opt -g distiller distiller 2>/dev/null || true
EOF

on_chroot << EOF
npm install -g @anthropic-ai/claude-code
curl -fsSL https://code-server.dev/install.sh | sh
EOF

on_chroot << EOF
curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg
echo 'deb https://debian.griffo.io/apt ${RELEASE} main' | tee /etc/apt/sources.list.d/debian.griffo.io.list

curl -sS https://apt.pamir.ai/pamir-ai.gpg | gpg --dearmor --yes -o /usr/share/keyrings/pamir-ai-archive-keyring.gpg
echo "deb [arch=arm64 signed-by=/usr/share/keyrings/pamir-ai-archive-keyring.gpg] https://apt.pamir.ai/ testing main" | tee /etc/apt/sources.list.d/pamir-ai.list

apt-get update
apt-get install uv -y
EOF

echo "Pamir AI APT repository configured successfully"
