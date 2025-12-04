#!/usr/bin/env bash
set -e

DRIVER_NAME="akida-pcie"
DRIVER_VERSION="1.0"
DKMS_DIR="/usr/src/${DRIVER_NAME}-${DRIVER_VERSION}"

echo "Installing ${DRIVER_NAME} DKMS module..."

# Check if kernel headers are installed
if [ ! -d "/lib/modules/$(uname -r)/build" ]; then
    echo "Kernel headers not found. Installing..."
    sudo apt-get install -y linux-headers-$(uname -r)
fi

# Check if DKMS is installed
if ! command -v dkms &> /dev/null; then
    echo "DKMS is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y dkms
fi

# Remove old DKMS module if it exists
if dkms status | grep -q "${DRIVER_NAME}"; then
    echo "Removing old ${DRIVER_NAME} DKMS module..."
    sudo dkms remove -m ${DRIVER_NAME} -v ${DRIVER_VERSION} --all 2>/dev/null || true
fi

# Remove old source directory if it exists
if [ -d "${DKMS_DIR}" ]; then
    echo "Removing old source directory..."
    sudo rm -rf "${DKMS_DIR}"
fi

# Create DKMS source directory
echo "Creating DKMS source directory: ${DKMS_DIR}"
sudo mkdir -p "${DKMS_DIR}"

# Copy all necessary files to DKMS directory
echo "Copying source files..."
sudo cp -r akida-dw-edma "${DKMS_DIR}/"
sudo cp -r kernel "${DKMS_DIR}/"
sudo cp Makefile "${DKMS_DIR}/"
sudo cp akida-pcie-core.c "${DKMS_DIR}/"
sudo cp dkms.conf "${DKMS_DIR}/"
sudo cp 99-akida-pcie.rules "${DKMS_DIR}/"

# Add to DKMS tree
echo "Adding ${DRIVER_NAME} to DKMS tree..."
sudo dkms add -m ${DRIVER_NAME} -v ${DRIVER_VERSION}

# Build and install
echo "Building ${DRIVER_NAME} module..."
sudo dkms build -m ${DRIVER_NAME} -v ${DRIVER_VERSION}

echo "Installing ${DRIVER_NAME} module..."
sudo dkms install -m ${DRIVER_NAME} -v ${DRIVER_VERSION}

# Install udev rules
echo "Installing udev rules..."
sudo cp 99-akida-pcie.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger

# Update /etc/modules to load driver at boot
echo "Configuring module to load at boot..."
if ! grep -q "^akida_pcie$" /etc/modules; then
    echo "akida_pcie" | sudo tee -a /etc/modules
fi

# Remove old pedd_bc references if they exist
sudo sed -i '/^pedd_bc$/d' /etc/modules

# Load the module
echo "Loading module..."
sudo modprobe akida_pcie || echo "Module load failed, will load on next boot"

echo ""
echo "DKMS installation complete!"
echo ""
echo "The driver will now automatically rebuild when you update your kernel."
echo ""
echo "To check DKMS status, run: dkms status"
echo "To manually rebuild for all kernels: sudo dkms install ${DRIVER_NAME}/${DRIVER_VERSION} --all"
echo ""
