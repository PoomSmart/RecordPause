#define UNRESTRICTED_AVAILABILITY
#import <PSHeader/CameraApp/CameraApp.h>
#import <PSHeader/CameraMacros.h>

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

@interface CAMFullscreenViewfinder : UIView
- (CAMViewfinderViewController *)delegate;
@end

typedef struct CAMShutterColor {
    CGFloat r;
    CGFloat g;
    CGFloat b;
    CGFloat a;
} CAMShutterColor;

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

NSString *NSTimerPauseDate = @"NSTimerPauseDate";
NSString *NSTimerPreviousFireDate = @"NSTimerPreviousFireDate";
