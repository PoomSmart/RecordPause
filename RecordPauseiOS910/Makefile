TARGET = iphone:clang:latest:9.0
ARCHS = armv7 arm64 arm64e

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = RecordPauseiOS910
RecordPauseiOS910_FILES = Tweak.xm
RecordPauseiOS910_EXTRA_FRAMEWORKS = Cephei CydiaSubstrate
RecordPauseiOS910_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/RecordPause

include $(THEOS_MAKE_PATH)/library.mk
