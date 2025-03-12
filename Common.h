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

@interface CAMLiquidShutterRenderer : NSObject
- (void)renderIfNecessary;
@end

@interface UIView (Private)
@property (nonatomic, assign, setter=_setShouldReverseLayoutDirection:) BOOL _shouldReverseLayoutDirection;
@end

extern CGRect UIRectIntegralWithScale(CGRect rect, CGFloat scale);
extern CGFloat UIRoundToViewScale(CGFloat value, UIView *view);

@interface CAMViewfinderViewController (Addition)
@property (retain, nonatomic) UILongPressGestureRecognizer *rpGesture;
@property (nonatomic, retain) CUShutterButton *_pauseResumeDuringVideoButton;
- (void)_createPauseResumeDuringVideoButtonIfNecessary;
- (void)_embedPauseResumeDuringVideoButtonWithLayoutStyle:(NSInteger)layoutStyle;
- (void)_updatePauseResumeDuringVideoButton:(BOOL)paused;
@end

@interface CAMDynamicShutterControl (Addition)
@property (nonatomic, retain) CUShutterButton *pauseResumeDuringVideoButton;
@property (nonatomic, assign) BOOL overrideShutterButtonColor;
@end

@interface CAMBottomBar (Addition)
@property (nonatomic, retain) CUShutterButton *pauseResumeDuringVideoButton;
- (void)_layoutPauseResumeDuringVideoButtonForLayoutStyle:(NSInteger)layoutStyle;
- (void)_layoutPauseResumeDuringVideoButtonForTraitCollection:(UITraitCollection *)traitCollection;
@end

NSString *NSTimerPauseDate = @"NSTimerPauseDate";
NSString *NSTimerPreviousFireDate = @"NSTimerPreviousFireDate";
