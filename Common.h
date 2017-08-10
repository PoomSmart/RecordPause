#define UNRESTRICTED_AVAILABILITY
#import "../PS.h"

@interface CAMElapsedTimeView (Addition)
- (void)pauseTimer;
- (void)resumeTimer;
- (void)updateUI:(BOOL)pause;
@end

@interface AVCaptureMovieFileOutput (Private)
- (BOOL)isRecordingPaused;
- (void)pauseRecording;
- (void)resumeRecording;
@end

CFStringRef PreferencesNotification = CFSTR("com.PS.RecordPause.prefs");
NSString *PREF_PATH = @"/var/mobile/Library/Preferences/com.PS.RecordPause.plist";

#ifdef TWEAK

NSString *NSTimerPauseDate = @"NSTimerPauseDate";
NSString *NSTimerPreviousFireDate = @"NSTimerPreviousFireDate";

static BOOL dimScreen;

static void reloadSettings2() {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    id temp = prefs[@"dimScreen"];
    dimScreen = temp ? [temp boolValue] : YES;
}

#endif
