#!/bin/bash -e
# Install local .deb packages (overrides APT versions)

if [ -d /tmp/local-debs ] && ls /tmp/local-debs/*.deb >/dev/null 2>&1; then
    echo "Installing local .deb packages..."
    apt-get install --reinstall --allow-downgrades -y /tmp/local-debs/*.deb
    rm -rf /tmp/local-debs
    echo "Local packages installed successfully"
fi
