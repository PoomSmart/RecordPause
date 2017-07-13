DEBUG = 0
PACKAGE_VERSION = 1.2.2

ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest
	ARCHS = x86_64 i386
endif

include $(THEOS)/makefiles/common.mk

AGGREGATE_NAME = RecordPause
SUBPROJECTS = RecordPauseiOS8 RecordPauseiOS910

include $(THEOS_MAKE_PATH)/aggregate.mk

TWEAK_NAME = RecordPause
RecordPause_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp -R Resources $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/RecordPause$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store | xargs rm -rf$(ECHO_END)

SIM_TARGET = RecordPauseiOS910
all::
ifeq ($(SIMULATOR),1)
	@rm -f /opt/simject/$(SIM_TARGET).dylib
	@cp -v $(THEOS_OBJ_DIR)/$(SIM_TARGET).dylib /opt/simject
	@cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject/$(SIM_TARGET).plist
endif
