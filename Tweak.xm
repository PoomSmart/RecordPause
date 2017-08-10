#import "../PS.h"
#import <dlfcn.h>
#import "Common.h"

static BOOL tweakEnabled;

static void reloadSettings() {
    CFPreferencesAppSynchronize(CFSTR("com.PS.RecordPause"));
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    id temp = prefs[@"tweakEnabled"];
    tweakEnabled = temp ? [temp boolValue] : YES;
}

static void post(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
    reloadSettings();
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &post, PreferencesNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
    reloadSettings();
    if (tweakEnabled) {
        if (isiOS9Up)
            dlopen("/Library/MobileSubstrate/DynamicLibraries/RecordPause/RecordPauseiOS910.dylib", RTLD_LAZY);
        else
            dlopen("/Library/MobileSubstrate/DynamicLibraries/RecordPause/RecordPauseiOS8.dylib", RTLD_LAZY);
    }
}
