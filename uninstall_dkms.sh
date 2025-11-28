#!/usr/bin/env bash
set -e

DRIVER_NAME="akida-pcie"
DRIVER_VERSION="1.0"

echo "Uninstalling ${DRIVER_NAME} DKMS module..."

# Unload module if loaded
if lsmod | grep -q "^akida_pcie"; then
    echo "Unloading module..."
    sudo rmmod akida_pcie || true
fi

# Remove from DKMS
if dkms status | grep -q "${DRIVER_NAME}"; then
    echo "Removing from DKMS..."
    sudo dkms remove -m ${DRIVER_NAME} -v ${DRIVER_VERSION} --all || true
fi

# Remove source directory
if [ -d "/usr/src/${DRIVER_NAME}-${DRIVER_VERSION}" ]; then
    echo "Removing source directory..."
    sudo rm -rf "/usr/src/${DRIVER_NAME}-${DRIVER_VERSION}"
fi

# Remove udev rules
if [ -f "/etc/udev/rules.d/99-akida-pcie.rules" ]; then
    echo "Removing udev rules..."
    sudo rm -f /etc/udev/rules.d/99-akida-pcie.rules
    sudo udevadm control --reload-rules
fi

# Remove from /etc/modules
echo "Removing from /etc/modules..."
sudo sed -i '/^akida_pcie$/d' /etc/modules

echo ""
echo "DKMS uninstallation complete!"
echo ""
