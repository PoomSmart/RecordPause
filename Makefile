PACKAGE_VERSION = 1.3.3
TARGET = iphone:latest:9.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RecordPause
RecordPause_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk
