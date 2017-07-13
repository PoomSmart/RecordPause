ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest
	ARCHS = x86_64 i386
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = RecordPauseiOS910
RecordPauseiOS910_FILES = Tweak.xm
RecordPauseiOS910_LIBRARIES = substrate
RecordPauseiOS910_INSTALL_PATH = /Library/Application Support/RecordPause

include $(THEOS_MAKE_PATH)/library.mk
