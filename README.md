# ams-mira220 Linux driver

## Installation

### Prerequisites

Install git and the kernel headers for the running kernel, then clone this repository.

```
sudo apt update
sudo apt install -y git linux-headers-$(uname -r)
git clone https://github.com/ams-OSRAM/mira220_v4l2_driver.git
cd mira220_v4l2_driver
```

### Driver

Compile the driver using the Makefile

```
make
```

Place it in the kernel modules folder.

```
sudo mkdir -p /lib/modules/$(uname -r)/updates && sudo cp mira220.ko /lib/modules/$(uname -r)/updates/
```

Resolve modules dependencies.

```
sudo depmod -a
```

### Device tree

Compile the device tree overlay matching your platform and plugin board from the `dts` folder.

```
cd dts/rpi
sudo dtc mira220-overlay.dts -o /boot/firmware/overlays/mira220.dtbo
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

