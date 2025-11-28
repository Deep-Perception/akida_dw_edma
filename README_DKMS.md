# Akida PCIe Driver - DKMS Installation

## What is DKMS?

DKMS (Dynamic Kernel Module Support) automatically rebuilds and reinstalls kernel modules when you update your Linux kernel. This means you won't need to manually rebuild the akida-pcie driver after kernel updates.

## Prerequisites

- Ubuntu/Debian-based system (for other distros, install the equivalent DKMS package)
- Build tools and kernel headers already installed

## Installation

### 1. Install using DKMS (Recommended)

Run the DKMS installation script:

```bash
sudo ./install_dkms.sh
```

This script will:
- Install DKMS if not already installed
- Copy the driver source to `/usr/src/akida-pcie-1.0/`
- Register the module with DKMS
- Build and install the module for your current kernel
- Configure the module to load at boot
- Install udev rules

### 2. Verify Installation

Check DKMS status:

```bash
dkms status
```

You should see output like:
```
akida-pcie/1.0, 5.15.0-91-generic, x86_64: installed
```

Check if the module is loaded:

```bash
lsmod | grep akida
```

Check for device nodes:

```bash
ls -l /dev/akida* /dev/akd1500_*
```

## Manual Installation (Alternative)

If you prefer the original method without DKMS:

```bash
sudo ./install.sh
```

**Note:** With this method, you'll need to run `./install.sh` again after every kernel update.

## Uninstallation

### Remove DKMS installation:

```bash
sudo ./uninstall_dkms.sh
```

### Or remove manual installation:

```bash
sudo rmmod akida_pcie
sudo rm -f /lib/modules/$(uname -r)/kernel/drivers/akida-pcie.ko
sudo sed -i '/^akida_pcie$/d' /etc/modules
sudo rm -f /etc/udev/rules.d/99-akida-pcie.rules
```

## After Kernel Updates

### With DKMS:
The driver will automatically rebuild and install when you update your kernel. No action needed!

### Without DKMS:
You must manually run:
```bash
sudo ./install.sh
```

## Troubleshooting

### Module not loading after kernel update

Check DKMS build status:
```bash
dkms status
```

If it shows "added" but not "installed", manually trigger build:
```bash
sudo dkms install akida-pcie/1.0
```

### Check build logs

DKMS logs are in:
```bash
/var/lib/dkms/akida-pcie/1.0/build/make.log
```

### Rebuild for all installed kernels

```bash
sudo dkms install akida-pcie/1.0 --all
```

### Remove and reinstall

```bash
sudo ./uninstall_dkms.sh
sudo ./install_dkms.sh
```

## Advanced Usage

### Build for specific kernel version

```bash
sudo dkms build -m akida-pcie -v 1.0 -k 5.15.0-91-generic
sudo dkms install -m akida-pcie -v 1.0 -k 5.15.0-91-generic
```

### Uninstall from specific kernel

```bash
sudo dkms uninstall -m akida-pcie -v 1.0 -k 5.15.0-91-generic
```

## File Locations

- Source files: `/usr/src/akida-pcie-1.0/`
- Built modules: `/lib/modules/<kernel-version>/updates/dkms/`
- DKMS configuration: `/var/lib/dkms/akida-pcie/1.0/`

## Support

For issues with:
- Driver functionality: See main README.md
- DKMS installation: Check `/var/lib/dkms/akida-pcie/1.0/build/make.log`
- Kernel compatibility: See kernel_versions.txt
