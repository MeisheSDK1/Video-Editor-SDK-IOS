//
//  NvLiveWindowPanelView.m
//  SDKDemo
//
//  Created by meishe01 on 2018/5/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvLiveWindowPanelView.h"
#import "NvsLiveWindow.h"
#import "NvWeakTimer.h"
#import "NvSDKUtils.h"
#import <Masonry/Masonry.h>
#import <NvBaseCommon/UIColor+NvColor.h>
#import "NvUtils.h"
#import <NvBaseCommon/UIView+Dimension.h>
#import "NvHDRManager.h"
#import <YYImage/YYImage.h>

@interface NvLiveWindowPanelView () <NvsStreamingContextWebDelegate> {
    NvsTimeline *_timeline;
    UIButton *_playbackBtn;
    UILabel *_currentTimeLabel;
    UIButton *_volumnBtn;
    UILabel *_durationLabel;
    NvWeakTimer *_timer;
    UITapGestureRecognizer *_tap,*_tapScreen;
    int64_t every;
    ///是否是用户自己点击的暂停
    ///Whether the user clicked the pause
    BOOL userPause;
    BOOL _noEndToTimeline;
}

@property (nonatomic, strong) NvsStreamingContext *streamingContext;
/**
 * @brief 单独播放其中的一个clip, clip的入点
 * Play one of the clips alone, the entry point of the clip
 */
@property (nonatomic, assign) int64_t clipInpoint;

@property (nonatomic, strong) YYAnimatedImageView *loadingView;

@property (nonatomic, assign) BOOL isChange;

@end

@implementation NvLiveWindowPanelView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.streamingContext = [NvsStreamingContext sharedInstance];
        _noEndToTimeline = NO;
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    CGRect rect = self.bounds;
    self.dontNeedSeekCtl = NO;
    userPause = YES;
    _liveWindow = [[NvsLiveWindow alloc] initWithFrame:rect];
    if ([NvHDRManager isSupportLivewindow]) {
        _liveWindow.hdrDisplayMode = [NvSDKUtils liveWindowModelSetting];
    }
    [self addSubview:_liveWindow];
    _controlPanelView = [UIView new];
    _controlPanelView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#80000000"];
    [self addSubview:_controlPanelView];
    [_controlPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.bottom.equalTo(self->_liveWindow);
        make.height.equalTo(@(40 * SCREENSCALE));
    }];
    _playbackBtn = [UIButton new];
    [_playbackBtn setImage:NvImageNamedForBundle(@"NvPlayback", NvCurrentBundle) forState:UIControlStateNormal];
    [_controlPanelView addSubview:_playbackBtn];
    [_playbackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(@0);
        make.width.equalTo(self->_controlPanelView.mas_height);
    }];
    _currentTimeLabel = [UILabel new];
    _currentTimeLabel.text = @"00:00";
    _currentTimeLabel.textColor = [UIColor whiteColor];
    _currentTimeLabel.font = [NvUtils fontWithSize:10];
    CGSize size = [_currentTimeLabel sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    [_controlPanelView addSubview:_currentTimeLabel];
    [_currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_playbackBtn.mas_right);
        make.centerY.equalTo(self->_controlPanelView);
        make.width.equalTo(@(size.width + 3));
    }];
    _volumnBtn = [UIButton new];
    [_volumnBtn setImage:NvImageNamedForBundle(@"NvVolumn",NvCurrentBundle) forState:UIControlStateNormal];
    [_controlPanelView addSubview:_volumnBtn];
    [_volumnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(@0);
        make.width.equalTo(self->_controlPanelView.mas_height);
    }];
    _durationLabel = [UILabel new];
    _durationLabel.text = @"00:00";
    _durationLabel.textColor = [UIColor whiteColor];
    _durationLabel.font = [NvUtils fontWithSize:10];
    [_controlPanelView addSubview:_durationLabel];
    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self->_volumnBtn.mas_left);
        make.centerY.equalTo(self->_controlPanelView);
        make.width.equalTo(@(size.width));
    }];
    _progressSlider = [UISlider new];
    [_progressSlider setThumbImage:NvImageNamedForBundle(@"NvSliderHandle",NvCurrentBundle) forState:UIControlStateNormal];
    [_progressSlider setMinimumTrackTintColor:[UIColor nv_colorWithHexARGB:@"#FF4A90E2"]];
    [_progressSlider setMaximumTrackTintColor:[UIColor nv_colorWithHexARGB:@"#FF979797"]];
    [_controlPanelView addSubview:_progressSlider];
    [_progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_currentTimeLabel.mas_right).offset(7 * SCREENSCALE);
        make.right.equalTo(self->_durationLabel.mas_left).offset(-7 * SCREENSCALE);
        make.centerY.equalTo(self->_controlPanelView);
        make.height.offset(rect.size.height);
    }];
    
    [_playbackBtn addTarget:self action:@selector(playbackBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [_volumnBtn addTarget:self action:@selector(volumnBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [_progressSlider addTarget:self action:@selector(progressSliderValueChanged) forControlEvents:(UIControlEventValueChanged)];
    
    [_progressSlider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchDragExit];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [_liveWindow addGestureRecognizer:_tap];
    
    [self addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.offset(30 * SCREENSCALE);
    }];
}

- (void)setHiddenPanelTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    if (self.alwaysShowControlPanel) {
        return;
    }
    _timer = [NvWeakTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideControlPanel:) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
}

- (void)addTapScreenPause {
    if (_tapScreen) {
        return;
    }
    _tapScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapScreen:)];
    [_liveWindow addGestureRecognizer:_tapScreen];
}

- (void)hiddenVolumeButton {
    _volumnBtn.hidden = YES;
    [_durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-13*SCREENSCALE));
        make.centerY.equalTo(self->_controlPanelView);
        make.width.equalTo(@(35*SCREENSCALE));
    }];
}

- (void)singleTapScreen:(UITapGestureRecognizer *)recognizer {
    if (_controlPanelView.hidden) {
        if (_forceHiddenControlPanel) {
            ///如果强制隐藏则直接播放
            ///If forced to hide, play directly
            if (self.streamingContext.getStreamingEngineState != NvsStreamingEngineState_Playback) {
                [self playAtTime:self.currentTime];
                if ([self.delegate respondsToSelector:@selector(playback)]) {
                    [self.delegate playback];
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(didTapLiveWindowAtTime:)]) {
                    [self.delegate didTapLiveWindowAtTime: [self.streamingContext getTimelineCurrentPosition:_timeline]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(didTapLiveWindowStop)]) {
                    [self.delegate didTapLiveWindowStop];
                }
                [self.streamingContext stop];
                
            }
        } else {
            ///如果不是强制隐藏则显示并添加定时器
            ///Display and add timer if not forced hiding
            [self showControllPanel];
        }
    } else {
        if (self.streamingContext.getStreamingEngineState != NvsStreamingEngineState_Playback) {
            [self playAtTime:self.currentTime];
            if ([self.delegate respondsToSelector:@selector(playback)]) {
                [self.delegate playback];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(didTapLiveWindowAtTime:)]) {
                [self.delegate didTapLiveWindowAtTime: [self.streamingContext getTimelineCurrentPosition:_timeline]];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(didTapLiveWindowStop)]) {
                [self.delegate didTapLiveWindowStop];
            }
            [self.streamingContext stop];
        }
        [self setHiddenPanelTimer];
    }
}

- (void)removeTapScreenPause {
    if (_tapScreen) {
        [_liveWindow removeGestureRecognizer:_tapScreen];
        _tapScreen = nil;
    }
}

- (void)singleTap:(UITapGestureRecognizer *)recognizer {
    if (_controlPanelView.hidden == YES) {
        _controlPanelView.hidden = NO;
        [self setHiddenPanelTimer];
    } else {
        [self playbackBtnClicked];
    }
}

- (void)showControllPanel {
    if (_forceHiddenControlPanel) {
        return;
    }
    _controlPanelView.hidden = NO;
    [self setHiddenPanelTimer];
}

- (void)setEditMode:(NvEditMode)editMode {
    _editMode = editMode;
    float liveWindowWidth = self.bounds.size.width;
    float liveWindowHeight = self.bounds.size.height;
    BOOL isScale = [[NvUtils iphoneType] isEqualToString:@"iPhone 6 Plus"] || [[NvUtils iphoneType] isEqualToString:@"iPhone 6s Plus"] || [[NvUtils iphoneType] isEqualToString:@"iPhone 7 Plus"] || [[NvUtils iphoneType] isEqualToString:@"iPhone 8 Plus"];
    isScale = NO;
    if (isScale) {
        liveWindowWidth = liveWindowWidth * 0.8;
        liveWindowHeight = liveWindowHeight * 0.8;
    }

    if (_editMode == NvEditMode16v9) {
        liveWindowHeight = liveWindowWidth * 9 / 16;
    } else if (_editMode == NvEditMode1v1) {
        liveWindowHeight = liveWindowWidth;
    } else if (_editMode == NvEditMode9v16) {
        liveWindowWidth = liveWindowHeight * 9 / 16;
    } else if (_editMode == NvEditMode4v3) {
        liveWindowHeight = liveWindowWidth * 3 / 4;
    } else if (_editMode == NvEditMode3v4) {
        liveWindowWidth = liveWindowHeight * 3 / 4;
    }else if (editMode == NvEditMode21v9){
        liveWindowHeight = liveWindowWidth * 9 / 21;
    } else if (editMode == NvEditMode9v21) {
        liveWindowWidth = liveWindowHeight * 9 / 21;
    } else if (editMode == NvEditMode18v9) {
        liveWindowHeight = liveWindowWidth * 9 / 18;
    } else if (editMode == NvEditMode9v18) {
        liveWindowWidth = liveWindowHeight * 9 / 18;
    }else if (editMode == NvEditMode7v6) {
        liveWindowHeight = liveWindowWidth * 6 / 7;
    } else if (editMode == NvEditMode6v7) {
        liveWindowWidth = liveWindowHeight * 6 / 7;
    }
    _liveWindow.width = (int)liveWindowWidth;
    _liveWindow.height = (int)liveWindowHeight;
    if (isScale) {
        _liveWindow.centerX = self.bounds.size.width / 2;
        _liveWindow.centerY = self.bounds.size.height * 0.8 / 2;
    }else{
        _liveWindow.centerX = self.bounds.size.width/2;
        _liveWindow.centerY = self.bounds.size.height/2;
    }
    CGFloat scale = [UIScreen mainScreen].scale;
    if(scale == 3.0){
       CGRect rect = CGRectMake(0, 0, _liveWindow.width, _liveWindow.height);
       CALayer *layer = [CALayer layer];
       layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
       layer.frame = rect;
       _liveWindow.layer.mask = layer;
   }

}

- (void)setCurrentTime:(int64_t)currentTime {
    _currentTime = currentTime;
    _currentTimeLabel.text = [NvUtils convertTimecode:_currentTime];
    [self.progressSlider setValue:(float)currentTime / _duration animated:YES];
}

- (void)setDuration:(int64_t)duration {
    _duration = duration;
    _durationLabel.text = [NvUtils convertTimecode:duration];
}

- (void)connectTimeline:(NvsTimeline *)timeline {
    if (!timeline) {
        return;
    }
    if (![self.streamingContext connectTimeline:timeline withLiveWindow:_liveWindow]) {
        NSLog(@"连接预览窗口失败！ Failed to connect to preview window!");
        return;
    }
    _timeline = timeline;
    self.streamingContext.delegate = self;
    self.streamingContext.webDelegate = self;
    self.duration = timeline.duration;
}

- (void)seekTimeline:(int64_t)pos {
    if (pos > self.duration-1) {
        pos = self.duration-1;
    }
    
    NSNumber * OResolutionNum = NV_UserInfo(@"NvCompileResolution");
    
    int flags = NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_ShowCaptionPoster;
    if (self.isChange) {
        flags = NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing | NvsStreamingEngineSeekFlag_ShowCaptionPoster;
        [_streamingContext setTimeline:_timeline scaleForSeek:_timeline.duration / 1000000 /  self.progressSlider.frame.size.width / UIScreen.mainScreen.scale];
    }
    if (OResolutionNum.intValue >= 2160) {
        NvsRational rational = {1,4};
        if (![_streamingContext seekTimeline:_timeline timestamp:pos proxyScale:&rational flags:flags]) {
            NSLog(@"定位时间线失败！ Failed to seek timeline!");
        }
    }else {
        if (![_streamingContext seekTimeline:_timeline timestamp:pos videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flags]){
            NSLog(@"定位时间线失败！ Failed to seek timeline!");
        }
    }
}

- (void)playAtTime:(int64_t)pos {
    if (!_timeline)
        return;
    if ([self isPlayback]) {
        [self.streamingContext stop];
    } else {
        int64_t a = _timeline.duration;
        if (_timeline.duration - 40000 < pos) {
            pos = 0;
        }
        NSNumber * OResolutionNum = NV_UserInfo(@"NvCompileResolution");
        if (OResolutionNum.intValue >= 2160) {
            NvsRational rational = {1,4};
            if (![self.streamingContext playbackTimeline:_timeline startTime:pos endTime:_timeline.duration proxyScale:&rational preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
                NSLog(@"播放时间线失败！ Failed to play timeline!");
                return;
            }
        }else if (![self.streamingContext playbackTimeline:_timeline startTime:pos endTime:_timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
            NSLog(@"播放时间线失败！ Failed to play timeline!");
            return;
        }
        if ([self.delegate respondsToSelector:@selector(playback)]) {
            [self.delegate playback];
        }
    }
    [self setHiddenPanelTimer];
}

- (void)playBackStart:(int64_t)start end:(int64_t)end {
    if (end != _timeline.duration) {
        _noEndToTimeline = YES;
    }
    self.duration = _timeline.duration;
    
    NSNumber * OResolutionNum = NV_UserInfo(@"NvCompileResolution");
    if (OResolutionNum.intValue >= 2160) {
        NvsRational rational = {1,4};
        if (![self.streamingContext playbackTimeline:_timeline startTime:start endTime:end proxyScale:&rational preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
            NSLog(@"播放时间线失败！ Failed to play timeline!");
            return;
        }
    }else if (![self.streamingContext playbackTimeline:_timeline startTime:start endTime:end videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
        NSLog(@"播放时间线失败！ Failed to play timeline!");
        return;
    }
    [self setHiddenPanelTimer];
}

- (void)playbackBtnClicked {
    if (!_timeline)
        return;
    if ([self isPlayback]) {
        userPause = YES;
        [self.streamingContext stop];
    } else {
        [self playAtTime:self.currentTime];
        if ([self.delegate respondsToSelector:@selector(playback)]) {
            [self.delegate playback];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapLiveWindowAtTime:)]) {
            [self.delegate didTapLiveWindowAtTime: [self.streamingContext getTimelineCurrentPosition:_timeline]];
        }
    }
    [self setHiddenPanelTimer];
}

- (BOOL)isUserPause{
    return userPause;
}

- (void)hideControlPanel:(NSTimer *)timer {
    if (!_controlPanelView.hidden)
        _controlPanelView.hidden = YES;
}

- (void)volumnBtnClicked {
    if ([self.delegate respondsToSelector:@selector(volumnClicked)]) {
        [self.delegate volumnClicked];
    }
}

- (void)sliderValueEnd:(UISlider*)slider {
    self.isChange = NO;
    if (self.alwaysShowControlPanel) {
        return;
    }

    _timer = [NvWeakTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideControlPanel:) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
}

- (void)progressSliderValueChanged {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _controlPanelView.hidden = NO;
    
    self.currentTime = lround(_progressSlider.value * _duration);
    self.isChange = YES;
    [self seekTimeline:self.currentTime];
    if ([self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [self.delegate sliderValueChanged:self.progressSlider.value];
    }
}

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    userPause = NO;
    self.currentTime = position;
    [self.progressSlider setValue:(float)position / _duration animated:YES];
    if ([self.delegate respondsToSelector:@selector(didPlaybackTimelinePosition:position:)]) {
        [self.delegate didPlaybackTimelinePosition:timeline position:position];
    }
}

- (void)didPlaybackStopped:(NvsTimeline *)timeline {
    [self setHiddenPanelTimer];
    if (_controlPanelView.hidden && !self.forceHiddenControlPanel) {
        _controlPanelView.hidden = NO;
    }
    if ([self.delegate respondsToSelector:@selector(didPlaybackStopped:)]) {
        [self.delegate didPlaybackStopped:timeline];
    }
}

- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    if (_noEndToTimeline) {
        _noEndToTimeline = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(didPlaybackEOF:)]) {
                [self.delegate didPlaybackEOF:timeline];
            }
        });
        return;
    }
    if (!self.isAnimationPlayback) {
        [self.progressSlider setValue:1 animated:YES];
    }
    [self setHiddenPanelTimer];
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([weakSelf.streamingContext getStreamingEngineState] == NvsStreamingEngineState_Playback) {
            return;
        }
        if (!self.isAnimationPlayback) {
            self.currentTime = 0;
            self->_currentTimeLabel.text = [NvUtils convertTimecode:0];
        }
        
        if (!self.dontNeedSeekCtl) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf)self = weakSelf;
                [self seekTimeline:0];
                [self.progressSlider setValue:0 animated:YES];
            });
        }
        
        if ([self.delegate respondsToSelector:@selector(didPlaybackEOF:)]) {
            [self.delegate didPlaybackEOF:timeline];
        }
    });
}

- (BOOL)isPlayback {
    return [self.streamingContext getStreamingEngineState] == NvsStreamingEngineState_Playback;
}

- (void)dealloc {
    /*
     不要在dealloc 中停止引擎，因为dealloc的调用受系统控制，如果在这里停止引擎，可能引发需要播放的画面在莫名其妙的时机被停止播放。
     Do not stop the engine in dealloc, because the call to dealloc is controlled by the system. Stopping the engine here can cause the screen that needs to be played to be stopped at an unexplained time.
     */
}

- (void)setForceHiddenControlPanel:(BOOL)forceHiddenControlPanel {
    _forceHiddenControlPanel = forceHiddenControlPanel;
    if (forceHiddenControlPanel) {
        _controlPanelView.hidden = YES;
        [_liveWindow removeGestureRecognizer:_tap];
    }
}

- (void)setAlwaysShowControlPanel:(BOOL)alwaysShowControlPanel {
    _alwaysShowControlPanel = alwaysShowControlPanel;
    if (alwaysShowControlPanel) {
        _controlPanelView.hidden = false;
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
    }
}

- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state {
    if (state == NvsStreamingEngineState_Playback) {
        [_playbackBtn setImage:NvImageNamedForBundle(@"NvPause",NvCurrentBundle) forState:UIControlStateNormal];
    } else {
        [_playbackBtn setImage:NvImageNamedForBundle(@"NvPlayback",NvCurrentBundle) forState:UIControlStateNormal];
    }
    if ([self.delegate respondsToSelector:@selector(didStreamingEngineStateChanged:)]) {
        [self.delegate didStreamingEngineStateChanged:state];
    }
}

#pragma mark - NvsStreamingContextWebDelegate
- (void)onWebRequestWaitStatusChange:(BOOL)isVideo waiting:(BOOL)waiting {
    if (waiting) {
        _loadingView.hidden = NO;
    } else {
        _loadingView.hidden = YES;
    }
}

- (YYAnimatedImageView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[YYAnimatedImageView alloc] init];
        NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"LocalImages/NvMaterialDownloading.gif"];
        YYImage * image = [YYImage imageWithContentsOfFile:path];
        _loadingView.image = image;
        _loadingView.hidden = YES;
    }
    
    return _loadingView;
}

@end
