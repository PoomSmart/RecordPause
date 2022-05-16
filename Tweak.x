#import "Common.h"
#import <UIKit/UIColor+Private.h>
#import <UIKit/UIImage+Private.h>

@interface CAMViewfinderViewController (Addition)
@property (retain, nonatomic) UILongPressGestureRecognizer *rpGesture;
@end

@interface CAMDynamicShutterControl (Addition)
@property (assign) BOOL overrideShutterButtonColor;
@end

%hook CAMDynamicShutterControl

%property (assign) BOOL overrideShutterButtonColor;

- (CAMShutterColor)_innerShapeColor {
    CAMShutterColor color = %orig;
    if (self.overrideShutterButtonColor) {
        CGFloat r, g, b;
        [UIColor.systemYellowColor getRed:&r green:&g blue:&b alpha:nil];
        color.r = r;
        color.g = g;
        color.b = b;
    }
    return color;
}

%end

%hook CAMElapsedTimeView

%new
- (void)pauseTimer {
    NSTimer *timer = [self valueForKey:@"__updateTimer"];
    if (timer == nil)
        return;
    objc_setAssociatedObject(timer, (__bridge const void *)(NSTimerPauseDate), [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(timer, (__bridge const void *)(NSTimerPreviousFireDate), timer.fireDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    timer.fireDate = [NSDate distantFuture];
}

%new
- (void)resumeTimer {
    NSTimer *timer = [self valueForKey:@"__updateTimer"];
    NSDate *pauseDate = objc_getAssociatedObject(timer, (__bridge const void *)NSTimerPauseDate);
    NSDate *previousFireDate = objc_getAssociatedObject(timer, (__bridge const void *)NSTimerPreviousFireDate);
    const NSTimeInterval pauseTime = -[pauseDate timeIntervalSinceNow];
    timer.fireDate = [NSDate dateWithTimeInterval:pauseTime sinceDate:previousFireDate];
    NSDate *newStartDate = [NSDate dateWithTimeInterval:pauseTime sinceDate:[self valueForKey:@"__startTime"]];
    [self setValue:newStartDate forKey:@"__startTime"];
}

%new
- (void)updateUI:(BOOL)pause recording:(BOOL)recording {
    BOOL isBadgeStyle = [self respondsToSelector:@selector(usingBadgeAppearance)] && [self usingBadgeAppearance];
    UIColor *defaultColor = [self respondsToSelector:@selector(_backgroundRedColor)] ? [self _backgroundRedColor] : UIColor.redColor;
    UIImageView *backgroundView = [self valueForKey:@"_backgroundView"];
    if (isBadgeStyle) {
        backgroundView.tintColor = pause ? UIColor.systemYellowColor : (recording ? defaultColor : UIColor.clearColor);
    } else {
        self._timeLabel.textColor = pause ? UIColor.systemYellowColor : UIColor.whiteColor;
        if ([self respondsToSelector:@selector(_recordingImageView)] && self._recordingImageView)
            self._recordingImageView.image = [self._recordingImageView.image _flatImageWithColor:pause ? UIColor.systemYellowColor : defaultColor];
        if (backgroundView)
            backgroundView.image = [backgroundView.image _flatImageWithColor:pause ? UIColor.systemYellowColor : defaultColor];
    }
}

- (void)endTimer {
    NSTimer *timer = [self valueForKey:@"__updateTimer"];
    if (timer == nil)
        return;
    objc_setAssociatedObject(timer, (__bridge const void *)(NSTimerPauseDate), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(timer, (__bridge const void *)(NSTimerPreviousFireDate), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateUI:NO recording:NO];
    %orig;
}

%end

%hook CAMFullscreenViewfinder

- (void)setElapsedTimeViewVisible:(BOOL)visible animated:(BOOL)animated {
    %orig;
    CAMElapsedTimeView *elapsedTimeView = [self valueForKey:@"_elapsedTimeView"];
    if (elapsedTimeView) {
        CAMViewfinderViewController *target = [self delegate];
        UITapGestureRecognizer *togglePlayPause = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(rp_togglePlayPause:)];
        togglePlayPause.numberOfTapsRequired = 1;
        [elapsedTimeView addGestureRecognizer:togglePlayPause];
    }
}

%end

%hook CAMViewfinderViewController

%property (retain, nonatomic) UILongPressGestureRecognizer *rpGesture;

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
        if (![cuc isCapturingVideo]
            && ([cuc respondsToSelector:@selector(isCapturingStandardVideo)] && ![cuc isCapturingStandardVideo])
            && ([cuc respondsToSelector:@selector(isCapturingCTMVideo)] && ![cuc isCapturingCTMVideo]))
            return;
        CAMCaptureEngine *engine = [cuc _captureEngine];
        CAMCaptureMovieFileOutput *movieOutput = [engine movieFileOutput];
        if (movieOutput == nil)
            return;
        CAMElapsedTimeView *elapsedTimeView = self._elapsedTimeView;
        if (elapsedTimeView == nil)
            elapsedTimeView = [(CAMFullscreenViewfinder *)self.view valueForKey:@"_elapsedTimeView"];
        CUShutterButton *shutterButton = self._shutterButton;
        CAMDynamicShutterControl *shutterControl = [self valueForKey:@"_dynamicShutterControl"];
        BOOL pause = ![movieOutput isRecordingPaused];
        [elapsedTimeView updateUI:pause recording:YES];
        if (shutterButton) {
            UIColor *shutterColor = pause ? UIColor.systemYellowColor : ([shutterButton respondsToSelector:@selector(_innerCircleColorForMode:spinning:)] ? [shutterButton _innerCircleColorForMode:shutterButton.mode spinning:NO] : [shutterButton _colorForMode:shutterButton.mode]);
            shutterButton._innerView.layer.backgroundColor = shutterColor.CGColor;
        }
        if (shutterControl) {
            if (pause)
                shutterControl.overrideShutterButtonColor = YES;
            [shutterControl _updateRendererShapes];
            CAMLiquidShutterRenderer *renderer = [shutterControl valueForKey:@"_liquidShutterRenderer"];
            if ([renderer respondsToSelector:@selector(renderIfNecessary)])
                [renderer renderIfNecessary];
            else if ([shutterControl respondsToSelector:@selector(_updateRendererShapes)])
                [shutterControl _updateRendererShapes];
            shutterControl.overrideShutterButtonColor = NO;
        }
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
    if (self._elapsedTimeView == nil) return;
    UITapGestureRecognizer *togglePlayPause = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rp_togglePlayPause:)];
    togglePlayPause.numberOfTapsRequired = 1;
    [self._elapsedTimeView addGestureRecognizer:togglePlayPause];
}

%end

%ctor {
    openCamera10();
    %init;
}
