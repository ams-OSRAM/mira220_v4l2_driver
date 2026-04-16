# Default to the running kernel's build directory

KERNELRELEASE ?= $(shell uname -r)
KDIR ?= /lib/modules/$(KERNELRELEASE)/build
SRC  := $(shell pwd)

all:
	# Build the kernel module (.ko)
	$(MAKE) -C $(KDIR) M=$(SRC) modules
modules_install:
	$(MAKE) -C $(KDIR) M=$(SRC) modules_install

clean:
	$(MAKE) -C $(KDIR) M=$(SRC) clean

