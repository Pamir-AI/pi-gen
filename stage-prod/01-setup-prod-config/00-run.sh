#!/bin/bash -e

echo "Finalizing prod configuration..."

# Expose environment variables for distiller SDK and Python
{
	echo "# Environment variables for Distiller"
	echo "PYTHONPATH=/opt/distiller-cm5-sdk/src:\$PYTHONPATH"
	echo "LD_LIBRARY_PATH=/opt/distiller-cm5-sdk/lib:\$LD_LIBRARY_PATH"
	echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/${FIRST_USER_NAME}/.local/bin:\$PATH"
} > "${ROOTFS_DIR}/etc/environment"

echo "Distiller prod configuration completed successfully"
