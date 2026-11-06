# Default to the running kernel's build directory

KERNELRELEASE ?= $(shell uname -r)
KDIR ?= /lib/modules/$(KERNELRELEASE)/build
SRC  := $(shell pwd)

# Device tree overlays: dts/rpi/<name>-overlay.dts -> dts/rpi/<name>.dtbo
OVERLAY_DIR ?= /boot/firmware/overlays
DTC ?= dtc
DTS  := $(wildcard dts/rpi/*-overlay.dts)
DTBO := $(DTS:%-overlay.dts=%.dtbo)

all:
	# Build the kernel module (.ko)
	$(MAKE) -C $(KDIR) M=$(SRC) modules
modules_install:
	$(MAKE) -C $(KDIR) M=$(SRC) modules_install

dtbo: $(DTBO)

%.dtbo: %-overlay.dts
	$(DTC) -@ -Wno-unit_address_vs_reg -I dts -O dtb -o $@ $<

install_dtbo: $(DTBO)
	install -m 0644 $(DTBO) $(OVERLAY_DIR)/

clean:
	$(MAKE) -C $(KDIR) M=$(SRC) clean
	rm -f $(DTBO)

.PHONY: all modules_install dtbo install_dtbo clean
