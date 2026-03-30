# Default to the running kernel's build directory
KDIR ?= /lib/modules/$(shell uname -r)/build
SRC  := $(shell pwd)

all:
	# Build the kernel module (.ko)
	$(MAKE) -C $(KDIR) M=$(SRC) modules
	# Build the overlay (.dtbo) using the system compiler inside the dts/rpi folder
	dtc -@ -I dts -O dtb -o mira220.dtbo mira220-overlay.dts
modules_install:
	$(MAKE) -C $(KDIR) M=$(SRC) modules_install

clean:
	$(MAKE) -C $(KDIR) M=$(SRC) clean

