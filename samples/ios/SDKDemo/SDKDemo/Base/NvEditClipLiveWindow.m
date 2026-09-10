//
//  NvEditClipLiveWindow.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/8/7.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvEditClipLiveWindow.h"
#import <NvStreamingSdkCore/NvsLiveWindow.h>
#import "NvsVideoTrack.h"
#import <NvSDKCommon/NvWeakTimer.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvTimelineUtils.h"
#import <YYImage/YYImage.h>

@interface NvEditClipLiveWindow() <NvsStreamingContextDelegate, NvsStreamingContextWebDelegate> {
    int64_t _rangeIn,_rangeOut;
    int64_t _currentTime;
}
@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIView *controlPanelView;
@property (nonatomic, strong) UIButton *playbackBtn;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UIButton *volumnBtn;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) NvsStreamingContext *context;
@property (nonatomic, strong) NvWeakTimer *timer;

@property (nonatomic, strong) YYAnimatedImageView *loadingView;
@property (nonatomic, assign) BOOL isChange;
@end
@implementation NvEditClipLiveWindow

- (void)dealloc {
    NSLog(@"%s",__func__);
    [self pause];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.context = [NvSDKUtils getSDKContext];
        [self addSubviews:frame];
        
    }
    return self;
}

- (void)addSubviews:(CGRect)rect {
    self.liveWindow = [[NvsLiveWindow alloc] initWithFrame:rect];
    if ([NvHDRManager isSupportLivewindow]) {
        self.liveWindow.hdrDisplayMode = [NvSDKUtils liveWindowModelSetting];
    }
    [self addSubview:_liveWindow];
    _controlPanelView = [UIView new];
    _controlPanelView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#80000000"];
    [self addSubview:_controlPanelView];
    [_controlPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.bottom.equalTo(self.liveWindow);
        make.height.equalTo(@(40 * SCREENSCALE));
    }];
    _playbackBtn = [UIButton new];
    [_playbackBtn setImage:NvImageNamed(@"NvPlayback") forState:UIControlStateNormal];
    [_playbackBtn setImage:NvImageNamed(@"NvPause") forState:UIControlStateSelected];
    [_controlPanelView addSubview:_playbackBtn];
    [_playbackBtn addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_playbackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(@0);
        make.width.equalTo(self.controlPanelView.mas_height);
    }];
    
    _currentTimeLabel = [UILabel new];
    _currentTimeLabel.text = @"00:00";
    _currentTimeLabel.textColor = [UIColor whiteColor];
    _currentTimeLabel.font = [NvUtils fontWithSize:10];
    CGSize size = [_currentTimeLabel sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    [_controlPanelView addSubview:_currentTimeLabel];
    [_currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playbackBtn.mas_right);
        make.centerY.equalTo(self.controlPanelView);
        make.width.equalTo(@(size.width));
    }];
    
    _durationLabel = [UILabel new];
    _durationLabel.text = @"00:00";
    _durationLabel.textColor = [UIColor whiteColor];
    _durationLabel.font = [NvUtils fontWithSize:10];
    [_controlPanelView addSubview:_durationLabel];
    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-13);
        make.centerY.equalTo(self.controlPanelView);
        make.width.equalTo(@(size.width));
    }];
    _progressSlider = [UISlider new];
    [_progressSlider setThumbImage:NvImageNamed(@"NvSliderHandle") forState:UIControlStateNormal];
    [_progressSlider setMinimumTrackTintColor:[UIColor nv_colorWithHexARGB:@"#FF4A90E2"]];
    [_progressSlider setMaximumTrackTintColor:[UIColor nv_colorWithHexARGB:@"#FF979797"]];
    [_controlPanelView addSubview:_progressSlider];
    [_progressSlider addTarget:self action:@selector(progressSliderClick:) forControlEvents:UIControlEventValueChanged];
    [_progressSlider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchDragExit];
    [_progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel.mas_right).offset(7 * SCREENSCALE);
        make.right.equalTo(self.durationLabel.mas_left).offset(-7 * SCREENSCALE);
        make.centerY.equalTo(self.controlPanelView);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLiveWindow:)];
    [self.liveWindow addGestureRecognizer:tap];
    
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
    _timer = [NvWeakTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideControlPanel:) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
}

- (void)hideControlPanel:(NSTimer *)timer {
    if (!_controlPanelView.hidden)
        _controlPanelView.hidden = YES;
}

- (void)showControllPanel {
    _controlPanelView.hidden = NO;
    [self setHiddenPanelTimer];
}

- (void)tapLiveWindow:(UITapGestureRecognizer *)tap {
    if (_controlPanelView.hidden) {
        [self showControllPanel];
    } else {
        if (self.context.getStreamingEngineState != NvsStreamingEngineState_Playback) {
            int64_t currentTime = [self.context getTimelineCurrentPosition:self.timeline];
            if (currentTime > _rangeIn && currentTime < _rangeOut) {
                [NvTimelineUtils playbackTimeline:self.timeline startTime:currentTime endTime:_rangeOut flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
            } else {
                [NvTimelineUtils playbackTimeline:self.timeline startTime:_rangeIn endTime:_rangeOut flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
            }
        } else {
            [self.context stop];
        }
        [self setHiddenPanelTimer];
    }
}

- (void)playbackTimeline:(int64_t)timestamp {
    [NvTimelineUtils playbackTimeline:self.timeline startTime:timestamp endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}

- (void)setEditMode:(NvEditMode)editMode {
    _editMode = editMode;
    float liveWindowWidth = self.bounds.size.width;
    float liveWindowHeight = self.bounds.size.height;
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
    }else if (_editMode == NvEditMode21v9) {
        liveWindowHeight = liveWindowWidth * 9 / 21;
    }else if (_editMode == NvEditMode9v21) {
        liveWindowWidth = liveWindowHeight * 9 / 21;
    }else if (_editMode == NvEditMode18v9) {
        liveWindowHeight = liveWindowWidth * 9 / 18;
    }else if (_editMode == NvEditMode9v18) {
        liveWindowWidth = liveWindowHeight * 9 / 18;
    }else if (_editMode == NvEditMode7v6) {
        liveWindowHeight = liveWindowWidth * 6 / 7;
    }else if (_editMode == NvEditMode6v7) {
        liveWindowWidth = liveWindowHeight * 6 / 7;
    }
    _liveWindow.width = liveWindowWidth;
    _liveWindow.height = liveWindowHeight;
    _liveWindow.centerX = self.centerX;
    _liveWindow.centerY = self.centerY;
}

- (void)seekTimeline:(int64_t)pos {
    _currentTime = pos;
    _playbackBtn.selected = NO;
    int flags = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster | NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (self.isChange) {
        flags = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster | NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing;
        [self.context setTimeline:_timeline scaleForSeek:_timeline.duration / 1000000 /  self.progressSlider.frame.size.width / UIScreen.mainScreen.scale];
    }
    if (![self.context seekTimeline:_timeline timestamp:pos videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flags])
        NSLog(@"Failed to seek timeline!");
    
    [self updateUI:pos];
}

- (void)updateUI:(int64_t)timestamp{
    int64_t duration = self.timeline.duration;
    _progressSlider.value = timestamp*1.0/duration;
    
    _currentTimeLabel.text = [NvUtils convertTimecode:timestamp];
    _durationLabel.text = [NvUtils convertTimecode:duration];
}

- (void)setPlayRangeIn:(int64_t)rangeIn rangeOut:(int64_t)rangeOut {
    _rangeIn = rangeIn;
    _rangeOut = rangeOut;
}

- (void)playButtonClick:(UIButton *)button {
    if (button.isSelected) {
        [self pause];
        button.selected = NO;
    } else {
        [self play];
        button.selected = YES;
    }
}

- (void)play {
    _isPause = NO;
    _playbackBtn.selected = YES;
    int64_t startTime = 0;
    //播放的当前位置大于范围的起始位置直接从当前位置播放 The current position of the playback is greater than the start position of the range and plays directly from the current position
    if (_currentTime > _rangeIn && _currentTime < _rangeOut) {
        startTime = _currentTime;
    } else if (_currentTime > _rangeOut) {//当前时间大于out值时从in值开始播放 If the current time is greater than the out value, the player starts from the in value
        startTime = _rangeIn;
    } else {//播放的当前位置小于范围的起始位置直接从播放范围的起始位置播放 The current position of play is less than the start of the range Play directly from the start of the range
        startTime = _rangeIn;
    }
    [NvTimelineUtils playbackTimeline:self.timeline startTime:startTime endTime:_rangeOut flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
    [self setHiddenPanelTimer];
}

- (void)pause {
    _isPause = YES;
    [self seekTimeline:_currentTime];
}

- (void)connectTimeline:(NvsTimeline *)timeline {
    if (![self.context connectTimeline:timeline withLiveWindow:_liveWindow]) {
        NSLog(@"连接预览窗口失败！Failed to connect to preview window!");
        return;
    }
    _timeline = timeline;
    self.context.delegate = self;
    self.context.webDelegate = self;
}
//拖动滑杆 Drag slide
- (void)progressSliderClick:(UISlider *)slider {
    self.isChange = YES;
    [self seekTimeline:slider.value*(self.timeline.duration)];
}

- (void)sliderValueEnd:(UISlider*)slider {
    self.isChange = NO;
    [self seekTimeline:slider.value*(self.timeline.duration)];
}

// MARK: Context回调 Context callback
- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    _currentTime = position;
    self.playbackBtn.selected = YES;
    //在播放过程中滑动右边rangeOut当前播放会播到out值外面 Swipe right rangeOut during playback and the current playback will be played outside the out value
    //做如下判断 Make the following judgment
    if (_currentTime>_rangeOut +1) {
        _currentTime = _rangeIn;
        [self seekTimeline:_currentTime];
        [self play];
    }
    
    int64_t duration = self.timeline.duration;
    self.progressSlider.value = position*1.0/duration;
    self.currentTimeLabel.text = [NvUtils convertTimecode:position];
    if ([self.delegate respondsToSelector:@selector(didPlaybackTimelinePosition:position:)]) {
        [self.delegate didPlaybackTimelinePosition:timeline position:position];
    }
}

- (void)didPlaybackStopped:(NvsTimeline *)timeline {
    self.playbackBtn.selected = NO;
    if ([self.delegate respondsToSelector:@selector(didPlaybackStopped:)]) {
        [self.delegate didPlaybackStopped:timeline];
    }
}

- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    [self setHiddenPanelTimer];
    if (_rangeOut == self.timeline.duration) {
        [self.progressSlider setValue:1 animated:YES];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_currentTime = self->_rangeIn+1;
        [self seekTimeline:self->_rangeIn+1];
        [self play];
        if ([self.delegate respondsToSelector:@selector(didPlaybackEOF:)]) {
            [self.delegate didPlaybackEOF:timeline];
        }
    });
}

- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state{
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
