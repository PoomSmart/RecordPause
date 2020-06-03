#define UNRESTRICTED_AVAILABILITY
#import "../PS.h"

@interface CAMElapsedTimeView (Private)
- (BOOL)usingBadgeAppearance;
- (UIColor *)_backgroundRedColor;
@end

@interface CAMElapsedTimeView (Addition)
- (void)pauseTimer;
- (void)resumeTimer;
- (void)updateUI:(BOOL)pause recording:(BOOL)recording;
@end

@interface AVCaptureMovieFileOutput (Private)
- (BOOL)isRecordingPaused;
- (void)pauseRecording;
- (void)resumeRecording;
@end

@interface CUCaptureController (Addition)
- (BOOL)isCapturingCTMVideo;
- (BOOL)isCapturingStandardVideo;
@end

@interface CAMFullscreenViewfinder : UIView
- (CAMViewfinderViewController *)delegate;
@end

struct CAMShutterColor {
    CGFloat r;
    CGFloat g;
    CGFloat b;
    CGFloat a;
};

@interface CAMLiquidShutterRenderer : NSObject
- (void)renderIfNecessary;
@end

@interface CAMDynamicShutterControl : UIControl
- (CAMShutterColor)_innerShapeColor;
- (void)_updateRendererShapes;
@end

@interface CAMMetalView : UIView
- (CAMetalLayer *)metalLayer;
@end

#ifdef TWEAK

NSString *NSTimerPauseDate = @"NSTimerPauseDate";
NSString *NSTimerPreviousFireDate = @"NSTimerPreviousFireDate";

#endif
