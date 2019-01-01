#define TWEAK
#import "../Common.h"
#import <UIKit/UIColor+Private.h>
#import <UIKit/UIImage+Private.h>
#import <Cephei/HBPreferences.h>

HBPreferences *preferences;
BOOL tweakEnabled;

@interface CAMViewfinderViewController (Addition)
@property(retain, nonatomic) UILongPressGestureRecognizer *rpGesture;
@end

%hook CAMElapsedTimeView

%new
- (void)pauseTimer {
    NSTimer *timer = [[self valueForKey:@"__updateTimer"] retain];
    if (timer == nil)
        return;
    objc_setAssociatedObject(timer, (__bridge const void *)(NSTimerPauseDate), [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(timer, (__bridge const void *)(NSTimerPreviousFireDate), timer.fireDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    timer.fireDate = [NSDate distantFuture];
    [timer release];
}

%new
- (void)resumeTimer {
    NSTimer *timer = [[self valueForKey:@"__updateTimer"] retain];
    NSDate *pauseDate = objc_getAssociatedObject(timer, (__bridge const void *)NSTimerPauseDate);
    NSDate *previousFireDate = objc_getAssociatedObject(timer, (__bridge const void *)NSTimerPreviousFireDate);
    const NSTimeInterval pauseTime = -[pauseDate timeIntervalSinceNow];
    timer.fireDate = [NSDate dateWithTimeInterval:pauseTime sinceDate:previousFireDate];
    NSDate *newStartDate = [NSDate dateWithTimeInterval:pauseTime sinceDate:[self valueForKey:@"__startTime"]];
    [self setValue:[newStartDate retain] forKey:@"__startTime"];
    [timer release];
}

%new
- (void)updateUI:(BOOL)pause {
    self._timeLabel.textColor = pause ? UIColor.systemYellowColor : UIColor.whiteColor;
    self._recordingImageView.image = [self._recordingImageView.image _flatImageWithColor:pause ? UIColor.systemYellowColor : UIColor.redColor];
}

- (void)endTimer {
    NSTimer *timer = [[self valueForKey:@"__updateTimer"] retain];
    if (timer == nil)
        return;
    objc_setAssociatedObject(timer, (__bridge const void *)(NSTimerPauseDate), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(timer, (__bridge const void *)(NSTimerPreviousFireDate), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateUI:NO];
    [timer release];
    %orig;
}

%end

%hook CAMViewfinderViewController

%property(retain, nonatomic) UILongPressGestureRecognizer *rpGesture;

- (void)_createShutterButtonIfNecessary {
    %orig;
    if (self.rpGesture == nil) {
        self.rpGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(rp_togglePlayPause:)];
        [[self valueForKey:@"__shutterButton"] addGestureRecognizer:self.rpGesture];
    }
}

- (void)_setCurrentGraphConfiguration:(CAMCaptureGraphConfiguration *)configuration {
    %orig;
    self.rpGesture.enabled = configuration.mode == 1 || configuration.mode == 2 || configuration.mode == 6;
}

%new
- (void)rp_togglePlayPause:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CUCaptureController *cuc = [self _captureController];
        if (![cuc isCapturingVideo])
            return;
        CAMCaptureEngine *engine = [cuc _captureEngine];
        CAMCaptureMovieFileOutput *movieOutput = [engine movieFileOutput];
        if (movieOutput == nil)
            return;
        CAMElapsedTimeView *elapsedTimeView = self._elapsedTimeView;
        CUShutterButton *shutterButton = self._shutterButton;
        BOOL pause = ![movieOutput isRecordingPaused];
        [elapsedTimeView updateUI:pause];
        UIColor *shutterColor = pause ? UIColor.systemYellowColor : ([shutterButton respondsToSelector:@selector(_innerCircleColorForMode:spinning:)] ? [shutterButton _innerCircleColorForMode:shutterButton.mode spinning:NO] : [shutterButton _colorForMode:shutterButton.mode]);
        shutterButton._innerView.layer.backgroundColor = shutterColor.CGColor;
        if (pause) {
            [elapsedTimeView pauseTimer];
            [movieOutput pauseRecording];
        } else {
            [elapsedTimeView resumeTimer];
            [movieOutput resumeRecording];
        }
    }
}

- (void)_createElapsedTimeViewIfNecessary {
    %orig;
    UITapGestureRecognizer *togglePlayPause = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rp_togglePlayPause:)];
    togglePlayPause.numberOfTapsRequired = 1;
    [self._elapsedTimeView addGestureRecognizer:togglePlayPause];
    [togglePlayPause release];
}

%end

%ctor {
    openCamera10();
    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.PS.RecordPause"];
    [preferences registerBool:&tweakEnabled default:YES forKey:@"tweakEnabled"];
    %init;
}
