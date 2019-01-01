PACKAGE_VERSION = 1.3.1

include $(THEOS)/makefiles/common.mk

AGGREGATE_NAME = RecordPause
SUBPROJECTS = RecordPauseiOS8 RecordPauseiOS910 RecordPauseLoader

include $(THEOS_MAKE_PATH)/aggregate.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp -R Resources $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/RecordPause$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store | xargs rm -rf$(ECHO_END)
