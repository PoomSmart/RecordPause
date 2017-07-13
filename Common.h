#import <UIKit/UIKit.h>
#import <substrate.h>

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

@interface CAMViewfinderViewController (Addition)
@property(retain, nonatomic) UILongPressGestureRecognizer *rpGesture;
@end

@interface CAMCameraView (Addition)
@property(retain, nonatomic) UILongPressGestureRecognizer *rpGesture;
@end

CFStringRef PreferencesNotification = CFSTR("com.PS.RecordPause.prefs");
NSString *PREF_PATH = @"/var/mobile/Library/Preferences/com.PS.RecordPause.plist";

#ifdef TWEAK

NSString *NSTimerPauseDate = @"NSTimerPauseDate";
NSString *NSTimerPreviousFireDate = @"NSTimerPreviousFireDate";

static BOOL dimScreen;

static void reloadSettings2(){
    #ifdef SIMULATOR
    dimScreen = YES;
    #else
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    id temp = prefs[@"dimScreen"];
    dimScreen = temp ? [temp boolValue] : YES;
    #endif
}

#endif
