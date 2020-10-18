MODULE_NAME=i2c-ch341-usb
MODULE_VERSION=1.0.0

DKMS       := $(shell which dkms)
PWD        := $(shell pwd) 
KVERSION   := $(shell uname -r)
KERNEL_DIR  = /usr/src/linux-headers-$(KVERSION)/
MODULE_DIR  = /lib/modules/$(KVERSION)

ifneq ($(DKMS),)
MODULE_INSTALLED := $(shell dkms status $(MODULE_NAME))
else
MODULE_INSTALLED =
endif

MODULE_NAME  = i2c-ch341-usb
obj-m       := $(MODULE_NAME).o   

$(MODULE_NAME).ko: $(MODULE_NAME).c Makefile
	make -C $(KERNEL_DIR) M=$(PWD) modules

all:
	make -C $(KERNEL_DIR) M=$(PWD) modules

clean:
	make -C $(KERNEL_DIR) M=$(PWD) clean
	rm -f examples/gpio_input examples/gpio_output

ifeq ($(DKMS),)  # if DKMS is not installed

install: $(MODULE_NAME).ko
	cp $(MODULE_NAME).ko $(MODULE_DIR)/kernel/drivers/i2c/busses
	depmod
	
uninstall:
	modprobe -r $(MODULE_NAME)
	rm -f $(MODULE_DIR)/kernel/drivers/i2c/busses/$(MODULE_NAME).ko
	depmod

else  # if DKMS is installed

install: $(MODULE_NAME).ko
ifneq ($(MODULE_INSTALLED),)
	@echo Module $(MODULE_NAME) is installed ... uninstall it first
	@make uninstall
endif
	@dkms install .
	
uninstall:
	modprobe -r $(MODULE_NAME)
ifneq ($(MODULE_INSTALLED),)
	dkms remove -m $(MODULE_NAME) -v $(MODULE_VERSION) --all
	rm -rf /usr/src/$(MODULE_NAME)-$(MODULE_VERSION)
endif

endif  # ifeq ($(DKMS),)

