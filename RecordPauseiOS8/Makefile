TARGET = iphone:clang:latest:8.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = RecordPauseiOS8
RecordPauseiOS8_FILES = Tweak.xm
RecordPauseiOS8_EXTRA_FRAMEWORKS = Cephei CydiaSubstrate
RecordPauseiOS8_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/RecordPause

include $(THEOS_MAKE_PATH)/library.mk
