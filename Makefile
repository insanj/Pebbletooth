THEOS_PACKAGE_DIR_NAME = debs
TARGET =: clang
ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = Pebbletooth
Pebbletooth_FILES = $(wildcard *.xm)
Pebbletooth_FRAMEWORKS = UIKit
Pebbletooth_PRIVATE_FRAMEWORKS = AppSupport BluetoothManager

include $(THEOS_MAKE_PATH)/tweak.mk

clean:: 
	rm -f ./*.deb
	
ifneq ($(THEOS_DEVICE_IP),)
	@install.exec "rm -rf *.deb"
endif