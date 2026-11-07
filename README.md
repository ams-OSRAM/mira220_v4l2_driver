# ams-mira220 Linux driver

[![CI](https://github.com/ams-OSRAM/mira220_v4l2_driver/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/ams-OSRAM/mira220_v4l2_driver/actions/workflows/ci.yml) [![License: GPL-2.0](https://img.shields.io/badge/license-GPL--2.0-blue.svg)](LICENSE) [![Tested kernel](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.github.com%2Frepos%2Fraspberrypi%2Flinux&query=%24.default_branch&label=tested%20kernel&logo=linux)](#supported-hardware-and-kernels) [![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-3%20%7C%204%20%7C%205%20%7C%20Zero%202%20W-c51a4a?logo=raspberrypi)](#supported-hardware-and-kernels)

## Supported hardware and kernels

| Raspberry Pi | Camera connector | Kernel config tested in CI |
|---|---|---|
| Pi 3, Pi 4 | 15-pin | `bcm2711_defconfig` |
| Zero 2 W | 22-pin | `bcm2711_defconfig` |
| Pi 5 | 22-pin (CAM0 and CAM1) | `bcm2712_defconfig` |

Raspberry Pi OS 64-bit is required. The driver supports only the kernel that Raspberry Pi OS currently ships; the *tested kernel* badge shows that branch of [raspberrypi/linux](https://github.com/raspberrypi/linux).

CI runs on every push and every Monday. It:

- builds the module against that kernel for both configurations above,
- builds the device tree overlays and checks the binding with `dt_binding_check`,
- installs and removes the module with DKMS on Ubuntu 26.04.

Each run's summary lists the exact kernel version. CI does not test on real hardware.

## Installation

### Prerequisites

The driver supports the latest Raspberry Pi OS kernel only (Linux 6.18 or later). Run `sudo apt full-upgrade` and reboot first if `uname -r` shows an older kernel.

Install git and the kernel headers for the running kernel, then clone this repository.

```
sudo apt update
sudo apt install -y git device-tree-compiler linux-headers-$(uname -r)
git clone https://github.com/ams-OSRAM/mira220_v4l2_driver.git
cd mira220_v4l2_driver
```

### Driver (recommended: DKMS)

With [DKMS](https://github.com/dell/dkms) the driver is rebuilt automatically every time Raspberry Pi OS installs a new kernel, so the camera keeps working after `sudo apt full-upgrade`.

```
sudo apt install -y dkms
sudo ./dkms-install.sh
```

This builds `mira220.ko` and installs it under `/lib/modules/<kernel>/updates/dkms/`. Check it with `dkms status`. To remove it again, run `sudo ./dkms-uninstall.sh`.

### Driver (manual build)

Without DKMS you have to repeat these steps after every kernel update.

```
make
sudo mkdir -p /lib/modules/$(uname -r)/updates && sudo cp mira220.ko /lib/modules/$(uname -r)/updates/
sudo depmod -a
```

### Device tree

Build the device tree overlay (`mira220.dtbo`) and copy it to `/boot/firmware/overlays/`:

```
make dtbo
sudo make install_dtbo
```

Set the device tree overlay in your platform. This may differ from platform to platform. Please refer to your platform documentation.

This is how to set the device tree overlay for Raspberry Pi.

```
echo "dtoverlay=mira220" | sudo tee -a /boot/firmware/config.txt
```
alternatively, add the line `dtoverlay=mira220` at the end of the file.

The driver reads from the sensor whether it is a mono or an RGB Mira220, so no extra overlay option is needed.

Raspberry Pi OS (kernel 6.12 and later) already ships a Mira220 driver and overlay. Because this module is installed under `updates/`, it takes precedence over the built-in one.

Finally, run `sudo reboot` to test your changes.


## Register access

The driver has register access controls on the sensor sub-device, with the same IDs as the
Mira050/016 driver (`MIRA_CID_*` in `mira220.c`):

| Control | |
|---------|-|
| `register_address`, `register_width` (1-4 bytes) | the register for the next access |
| `register_value` | reading it reads the register, setting it writes it (big-endian) |

The Mira220 has no register banks; its two contexts are separate registers (`EXP_TIME_A` and
`EXP_TIME_B`, ...). Register access runs under the driver's lock and only works while the sensor
streams (`EBUSY` otherwise). Set the address and width before the value, or list them before it in
the same call:

```
v4l2-ctl -d /dev/v4l-subdev2 -c register_address=0x100c,register_width=2
v4l2-ctl -d /dev/v4l-subdev2 -C register_value
```

The driver does not know about values written this way and may overwrite them at the next stream
start or exposure change.
