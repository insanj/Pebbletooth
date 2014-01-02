TARGET =: clang
ARCHS = armv7 arm64
include ../theos/makefiles/common.mk

TWEAK_NAME = PTUIKit
PTUIKit_FILES = PTUIKit.xm
PTUIKit_FRAMEWORKS = UIKit Foundation
PTUIKit_PRIVATE_FRAMEWORKS = AppSupport BluetoothManager

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk