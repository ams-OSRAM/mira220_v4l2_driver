# ams-mira220 Linux driver

## Installation

### Prerequisites

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

