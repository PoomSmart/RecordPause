PACKAGE_VERSION = 1.2.3
TARGET = iphone:clang:latest:8.0

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
