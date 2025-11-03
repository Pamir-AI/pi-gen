#!/bin/bash -e

# APT repository configuration for Distiller platform

echo "Configuring APT repositories..."

curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg
echo "deb https://debian.griffo.io/apt ${RELEASE} main" | tee /etc/apt/sources.list.d/debian.griffo.io.list
curl -sS https://apt.pamir.ai/pamir-ai.gpg | gpg --dearmor --yes -o /usr/share/keyrings/pamir-ai-archive-keyring.gpg
echo "deb [arch=arm64 signed-by=/usr/share/keyrings/pamir-ai-archive-keyring.gpg] https://apt.pamir.ai/ testing main" | tee /etc/apt/sources.list.d/pamir-ai.list
apt-get update
apt-get install uv -y

echo "APT repositories configured successfully"
