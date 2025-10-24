#!/bin/bash -e

echo "Finalizing prod configuration..."

# Expose environment variables for distiller SDK and Python
{
	echo "# Environment variables for Distiller"
	echo "DISTILLER_PLATFORM=${DISTILLER_PLATFORM}"
	echo "PYTHONPATH=/opt/distiller-sdk/src:\$PYTHONPATH"
	echo "LD_LIBRARY_PATH=/opt/distiller-sdk/lib:\$LD_LIBRARY_PATH"
	echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/${FIRST_USER_NAME}/.local/bin:\$PATH"
} > "${ROOTFS_DIR}/etc/environment"

echo "Distiller prod configuration completed successfully"
