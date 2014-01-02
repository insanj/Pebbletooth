THEOS_PACKAGE_DIR_NAME = debs
TARGET =: clang
ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = Pebbletooth
Pebbletooth_FILES = Pebbletooth.xm
Pebbletooth_FRAMEWORKS = Foundation
Pebbletooth_PRIVATE_FRAMEWORKS = AppSupport BluetoothManager

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += PTUIKit
include $(THEOS_MAKE_PATH)/aggregate.mk