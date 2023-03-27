ROOTLESS ?= 0

ifeq ($(ROOTLESS),1)
	TARGET = iphone:clang:latest:14.0
	ARCHS = arm64 arm64e
	THEOS_LAYOUT_DIR_NAME = layout-rootless
	THEOS_PACKAGE_SCHEME = rootless
else
	TARGET = iphone:clang:latest:9.0
endif
PACKAGE_VERSION = 1.4.0

INSTALL_TARGET_PROCESSES = Camera

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RecordPause
$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
