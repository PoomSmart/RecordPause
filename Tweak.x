#import "Common.h"
#import <UIKit/UIColor+Private.h>
#import <UIKit/UIImage+Private.h>

static void layoutPauseResumeDuringVideoButton(UIView *view, CUShutterButton *button, UIView *shutterButton, CGFloat displayScale, BOOL fixedPosition) {
    CGSize size = [button intrinsicContentSize];
    CGRect rect = UIRectIntegralWithScale(CGRectMake(0, 0, size.width, size.height), displayScale);
    CGRect alignmentRect = [shutterButton alignmentRectForFrame:shutterButton.frame];
    CGFloat midY = CGRectGetMidY(alignmentRect);
    CGFloat y = UIRoundToViewScale(midY - (size.height / 2), view);
    CGFloat x;
    CGRect bounds = view.bounds;
    if ([view _shouldReverseLayoutDirection] || fixedPosition)
        x = CGRectGetMinX(bounds) + 15;
    else
        x = CGRectGetMaxX(bounds) - size.width - 15;
    button.tappableEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    button.frame = [button frameForAlignmentRect:CGRectMake(x, y, rect.size.width, rect.size.height)];
}

static BOOL shouldHidePauseResumeDuringVideoButton(CAMViewfinderViewController *self) {
    CAMCaptureGraphConfiguration *configuration = [self _currentGraphConfiguration];
    if ([self respondsToSelector:@selector(_isSpatialVideoInVideoModeActiveForMode:devicePosition:)] && [self _isSpatialVideoInVideoModeActiveForMode:configuration.mode devicePosition:configuration.devicePosition])
        return YES;
    if (configuration.videoEncodingBehavior > 1)
        return YES;
    if ([[self _captureController] isCapturingCTMVideo])
        return YES;
    return [self _shouldHideStillDuringVideoButtonForGraphConfiguration:configuration];
}

%hook CAMDynamicShutterControl

%property (nonatomic, retain) CUShutterButton *pauseResumeDuringVideoButton;
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

- (void)layoutSubviews {
    %orig;
    layoutPauseResumeDuringVideoButton(self, self.pauseResumeDuringVideoButton, [self _centerOuterView], self.traitCollection.displayScale, YES);
}

%end

%hook CAMElapsedTimeView

%new(v@:)
- (void)pauseTimer {
    NSTimer *timer = [self valueForKey:@"__updateTimer"];
    if (timer == nil) return;
    objc_setAssociatedObject(timer, (__bridge const void *)(NSTimerPauseDate), [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(timer, (__bridge const void *)(NSTimerPreviousFireDate), timer.fireDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    timer.fireDate = [NSDate distantFuture];
}

%new(v@:)
- (void)resumeTimer {
    NSTimer *timer = [self valueForKey:@"__updateTimer"];
    NSDate *pauseDate = objc_getAssociatedObject(timer, (__bridge const void *)NSTimerPauseDate);
    NSDate *previousFireDate = objc_getAssociatedObject(timer, (__bridge const void *)NSTimerPreviousFireDate);
    const NSTimeInterval pauseTime = -[pauseDate timeIntervalSinceNow];
    timer.fireDate = [NSDate dateWithTimeInterval:pauseTime sinceDate:previousFireDate];
    NSDate *newStartDate = [NSDate dateWithTimeInterval:pauseTime sinceDate:[self valueForKey:@"__startTime"]];
    [self setValue:newStartDate forKey:@"__startTime"];
}

%new(v@:cc)
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
    if (timer == nil) return;
    objc_setAssociatedObject(timer, (__bridge const void *)(NSTimerPauseDate), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(timer, (__bridge const void *)(NSTimerPreviousFireDate), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateUI:NO recording:NO];
    %orig;
}

%end

#define BUTTON_SIZE 47.0
%hook CAMBottomBar

%property (nonatomic, retain) CUShutterButton *pauseResumeDuringVideoButton;

%new(v@:l)
- (void)_layoutPauseResumeDuringVideoButtonForLayoutStyle:(NSInteger)layoutStyle {
    if (![[self class] wantsVerticalBarForLayoutStyle:layoutStyle])
        layoutPauseResumeDuringVideoButton(self, self.pauseResumeDuringVideoButton, self.shutterButton, self.traitCollection.displayScale, NO);
    else {
        CGRect frame = self.frame;
        CGFloat maxY = CGRectGetMaxY(frame) - (2 * (BUTTON_SIZE + 16.0));
        CGFloat midX = CGRectGetWidth(frame) / 2 - (BUTTON_SIZE / 2);
        self.pauseResumeDuringVideoButton.frame = CGRectMake(midX, maxY, BUTTON_SIZE, BUTTON_SIZE);
    }
}

- (void)layoutSubviews {
    %orig;
    [self _layoutPauseResumeDuringVideoButtonForLayoutStyle:[self layoutStyle]];
}

%end

%hook CAMViewfinderViewController

%property (nonatomic, retain) CUShutterButton *_pauseResumeDuringVideoButton;

- (void)_createVideoControlsIfNecessary {
    %orig;
    [self _createPauseResumeDuringVideoButtonIfNecessary];
}

%new(v@:c)
- (void)_updatePauseResumeDuringVideoButton:(BOOL)paused {
    CUShutterButton *button = self._pauseResumeDuringVideoButton;
    UIView *innerView = button._innerView;
    UIImageView *pauseIcon = [button viewWithTag:2024];
    innerView.hidden = !paused;
    pauseIcon.hidden = paused;
}

%new(v@:)
- (void)_createPauseResumeDuringVideoButtonIfNecessary {
    if (self._pauseResumeDuringVideoButton) return;
    NSInteger layoutStyle = self._layoutStyle;
    CUShutterButton *button = [%c(CUShutterButton) smallShutterButtonWithLayoutStyle:layoutStyle];
    UIView *innerView = button._innerView;
    UIImage *pauseImage = [UIImage systemImageNamed:@"pause.fill" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:24]];
    UIImageView *pauseIcon = [[UIImageView alloc] initWithImage:pauseImage];
    pauseIcon.tintColor = UIColor.whiteColor;
    pauseIcon.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    pauseIcon.contentMode = UIViewContentModeCenter;
    pauseIcon.frame = innerView.bounds;
    pauseIcon.tag = 2024;
    [button addSubview:pauseIcon];
    innerView.hidden = YES;
    self._pauseResumeDuringVideoButton = button;
    [button addTarget:self action:@selector(handlePauseResumeDuringVideoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.mode = 1;
    button.exclusiveTouch = YES;
    [self _embedPauseResumeDuringVideoButtonWithLayoutStyle:layoutStyle];
}

%new(v@:l)
- (void)_embedPauseResumeDuringVideoButtonWithLayoutStyle:(NSInteger)layoutStyle {
    CUShutterButton *button = self._pauseResumeDuringVideoButton;
    BOOL shouldNotEmbed = layoutStyle == 2 ? YES : [self isEmulatingImagePicker];
    if ([self _shouldCreateAndEmbedControls]) {
        CAMBottomBar *bottomBar = self.viewfinderView.bottomBar;
        if (!shouldNotEmbed) {
            CUShutterButton *existingButton = bottomBar.pauseResumeDuringVideoButton;
            if (existingButton != button) {
                [existingButton removeFromSuperview];
                bottomBar.pauseResumeDuringVideoButton = button;
                [bottomBar addSubview:button];
            }
        } else
            bottomBar.pauseResumeDuringVideoButton = nil;
    } else {
        CAMDynamicShutterControl *shutterControl = [self valueForKey:@"_dynamicShutterControl"];
        if (!shouldNotEmbed) {
            CUShutterButton *existingButton = shutterControl.pauseResumeDuringVideoButton;
            if (existingButton != button) {
                [existingButton removeFromSuperview];
                shutterControl.pauseResumeDuringVideoButton = button;
                [shutterControl addSubview:button];
            }
        } else
            shutterControl.pauseResumeDuringVideoButton = nil;
    }
}

%new(v@:@)
- (void)handlePauseResumeDuringVideoButtonPressed:(CUShutterButton *)button {
    CUCaptureController *cuc = [self _captureController];
    if ([cuc respondsToSelector:@selector(isCapturingCTMVideo)] && [cuc isCapturingCTMVideo]) return;
    if (![cuc isCapturingVideo]) return;
    CAMCaptureEngine *engine = [cuc _captureEngine];
    CAMCaptureMovieFileOutput *movieOutput = [engine movieFileOutput];
    if (movieOutput == nil) return;
    BOOL pause = ![movieOutput isRecordingPaused];
    CAMElapsedTimeView *elapsedTimeView = self._elapsedTimeView;
    if (elapsedTimeView == nil)
        elapsedTimeView = [self.view valueForKey:@"_elapsedTimeView"];
    [elapsedTimeView updateUI:pause recording:YES];
    CUShutterButton *shutterButton = self._shutterButton;
    if (shutterButton) {
        UIColor *shutterColor = pause ? UIColor.systemYellowColor : ([shutterButton respondsToSelector:@selector(_innerCircleColorForMode:spinning:)] ? [shutterButton _innerCircleColorForMode:shutterButton.mode spinning:NO] : [shutterButton _colorForMode:shutterButton.mode]);
        shutterButton._innerView.layer.backgroundColor = shutterColor.CGColor;
    }
    CAMDynamicShutterControl *shutterControl = [self valueForKey:@"_dynamicShutterControl"];
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
    [self _updatePauseResumeDuringVideoButton:pause];
    if (pause) {
        [elapsedTimeView pauseTimer];
        [movieOutput pauseRecording];
    } else {
        [elapsedTimeView resumeTimer];
        [movieOutput resumeRecording];
    }
}

- (void)updateControlVisibilityAnimated:(BOOL)animated {
    %orig;
    BOOL shouldHide = shouldHidePauseResumeDuringVideoButton(self);
    self._pauseResumeDuringVideoButton.alpha = shouldHide ? 0 : 1;
    if (!shouldHide)
        [self _updatePauseResumeDuringVideoButton:NO];
}

- (void)_showControlsForGraphConfiguration:(CAMCaptureGraphConfiguration *)graphConfiguration animated:(BOOL)animated {
    %orig;
    BOOL shouldHide = shouldHidePauseResumeDuringVideoButton(self);
    self._pauseResumeDuringVideoButton.alpha = shouldHide ? 0 : 1;
    if (!shouldHide)
        [self _updatePauseResumeDuringVideoButton:NO];
}

- (void)_hideControlsForGraphConfiguration:(CAMCaptureGraphConfiguration *)graphConfiguration animated:(BOOL)animated {
    %orig;
    BOOL shouldHide = shouldHidePauseResumeDuringVideoButton(self);
    self._pauseResumeDuringVideoButton.alpha = shouldHide ? 0 : 1;
}

%end

%ctor {
    openCamera10();
    %init;
}
