#!/bin/bash -e
# Copy local .deb files to rootfs for installation

FILES_DIR="${BASH_SOURCE%/*}/files"

if ls "${FILES_DIR}/"*.deb >/dev/null 2>&1; then
    echo "Copying local .deb files to rootfs..."
    mkdir -p "${ROOTFS_DIR}/tmp/local-debs"
    cp "${FILES_DIR}/"*.deb "${ROOTFS_DIR}/tmp/local-debs/"
    echo "Copied: $(ls -1 "${FILES_DIR}/"*.deb | xargs -n1 basename)"
else
    echo "No local .deb files found in ${FILES_DIR}/"
fi
