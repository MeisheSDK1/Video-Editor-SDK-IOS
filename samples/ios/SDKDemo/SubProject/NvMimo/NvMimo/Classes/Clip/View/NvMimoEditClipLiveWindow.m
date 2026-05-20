//
//  NvEditClipLiveWindow.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/8/7.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMimoEditClipLiveWindow.h"
#import "NvsVideoTrack.h"
#import "NvMimoWeakTimer.h"
#import "NvMimoSDKUtils.h"
#import "NvMimoTimelineUtils.h"

@interface NvMimoEditClipLiveWindow() <NvsStreamingContextDelegate> {
    int64_t _rangeIn,_rangeOut;
    int64_t _currentTime;//当前播放的时间// currently playing time
}
@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIView *controlPanelView;
@property (nonatomic, strong) UIButton *playbackBtn;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UIButton *volumnBtn;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) NvsStreamingContext *context;
@property (nonatomic, strong) NvMimoWeakTimer *timer;
@property (nonatomic, assign) CGFloat desiredDuration;
@property (nonatomic, assign) BOOL isChange;
@property (nonatomic, assign) CGFloat scaleForSeek;
@end
@implementation NvMimoEditClipLiveWindow

- (void)dealloc {
    DLog(@"%s",__func__);
    [self pause];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.context = [NvMimoSDKUtils getSDKContext];
        [self addSubviews:frame];
        
    }
    return self;
}

- (void)addSubviews:(CGRect)rect {
    self.liveWindow = [[NvsLiveWindow alloc] initWithFrame:rect];
    [self addSubview:_liveWindow];
    _controlPanelView = [UIView new];
    _controlPanelView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#80000000"];
    [self addSubview:_controlPanelView];
    [_controlPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.top.equalTo(self.liveWindow.mas_bottom);
        make.height.equalTo(@(40 * SCREANSCALE));
    }];
    _playbackBtn = [UIButton new];
    [_playbackBtn setImage:[NvMimoUtils imageWithName:@"NvPlayback"] forState:UIControlStateNormal];
    [_playbackBtn setImage:[NvMimoUtils imageWithName:@"NvPause"] forState:UIControlStateSelected];
    [_controlPanelView addSubview:_playbackBtn];
    [_playbackBtn addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_playbackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(@0);
        make.width.equalTo(self.controlPanelView.mas_height);
    }];
    
    _currentTimeLabel = [UILabel new];
    _currentTimeLabel.text = @"00:00";
    _currentTimeLabel.textColor = [UIColor whiteColor];
    _currentTimeLabel.font = [NvMimoUtils fontWithSize:10];
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
    _durationLabel.font = [NvMimoUtils fontWithSize:10];
    [_controlPanelView addSubview:_durationLabel];
    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-13);
        make.centerY.equalTo(self.controlPanelView);
        make.width.equalTo(@(size.width));
    }];
    _progressSlider = [UISlider new];
    [_progressSlider setThumbImage:[NvMimoUtils imageWithName:@"NvSliderHandle"] forState:UIControlStateNormal];
    [_progressSlider setMinimumTrackTintColor:[UIColor nv_colorWithHexARGB:@"#FF2A7DFF"]];
    [_progressSlider setMaximumTrackTintColor:[UIColor nv_colorWithHexARGB:@"#FF979797"]];
    [_controlPanelView addSubview:_progressSlider];
    [_progressSlider addTarget:self action:@selector(progressSliderClick:) forControlEvents:UIControlEventValueChanged];
    [_progressSlider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpInside];
    [_progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel.mas_right).offset(7 * SCREANSCALE);
        make.right.equalTo(self.durationLabel.mas_left).offset(-7 * SCREANSCALE);
        make.centerY.equalTo(self.controlPanelView);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLiveWindow:)];
    [self.liveWindow addGestureRecognizer:tap];
}

- (void)setHiddenPanelTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NvMimoWeakTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideControlPanel:) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
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
            [self.context playbackTimeline:self.timeline startTime:0 endTime:self.model.trimOut - self.model.trimIn videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
        } else {
            [self.context stop];
        }
        [self setHiddenPanelTimer];
    }
}

- (void)setEditMode:(NvMimoEditMode)editMode {
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
    } else if (_editMode == NvEditMode2d39v1) {
        liveWindowHeight = liveWindowWidth / 2.39;
    } else if (_editMode == NvEditMode2d55v1) {
        liveWindowHeight = liveWindowWidth / 2.55;
    }
    _liveWindow.width = liveWindowWidth;
    _liveWindow.height = liveWindowHeight;
    _liveWindow.centerX = self.centerX;
    _liveWindow.centerY = self.centerY;
}

- (void)setModel:(NvShotModel *)model {
    _model = model;
    CGFloat duration;
    if (model.speed.count>0) {
        duration = [NvMimoTimelineUtils requiredDurationForShotModel:model];
    }else{
        duration = model.duration;
    }
    self.desiredDuration = duration;
    
}

- (void)seekTimeline:(int64_t)pos {
    _currentTime = pos;
    _playbackBtn.selected = NO;
    int flags = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (self.isChange) {
        self.scaleForSeek = _timeline.duration / 1000000 /  self.progressSlider.frame.size.width / UIScreen.mainScreen.scale;
        [self.context setTimeline:_timeline scaleForSeek:self.scaleForSeek];
        flags = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing;
    }
    if (![self.context seekTimeline:self.timeline timestamp:pos videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flags])
    {
        DLog(@"定位失败+++%lld+++%lld+++%lld",pos,self.model.trimIn,self.model.trimOut);
    }
    
    _progressSlider.value = (pos - _rangeIn)*1.0/self.desiredDuration;
    _durationLabel.text = [NvMimoUtils convertTimecode:self.desiredDuration];
    
}

- (void)setPlayRangeIn:(int64_t)rangeIn rangeOut:(int64_t)rangeOut {
    _rangeIn = rangeIn;
    _rangeOut = rangeOut;
    _currentTime = rangeIn;
    [self play];
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
    [self.context playbackTimeline:self.timeline startTime:_currentTime endTime:_rangeOut videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
    [self setHiddenPanelTimer];
}

- (void)pause {
    _isPause = YES;
    [self seekTimeline:_currentTime];
}

- (void)updateUI:(int64_t)timestamp{
    int64_t duration = self.timeline.duration;
    _progressSlider.value = timestamp*1.0/duration;
}

- (void)connectTimeline:(NvsTimeline *)timeline {
    if (![self.context connectTimeline:timeline withLiveWindow:_liveWindow]) {
        DLog(@"连接预览窗口失败！");
        return;
    }
    _timeline = timeline;
    [self seekTimeline:self.model.trimIn];
    self.context.delegate = self;
}

- (void)progressSliderClick:(UISlider *)slider {
    self.isChange = YES;
    [self seekTimeline:slider.value*self.desiredDuration];
}

- (void)sliderValueEnd:(UISlider *)slider {
    self.isChange = NO;
    [self seekTimeline:slider.value*self.desiredDuration];
}

// MARK: Context回调
- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    _currentTime = position;
    self.playbackBtn.selected = YES;
    //在播放过程中滑动右边rangeOut当前播放会播到out值外面
    //做如下判断
    // Sliding the right rangeOut during playback will play out of the out value
    // Do the following
    if (_currentTime - self.model.trimIn>=self.timeline.duration) {
        _currentTime = _rangeIn;
        [self seekTimeline:_currentTime];
        [self play];
    }

    int64_t duration = self.timeline.duration;
    self.progressSlider.value = (position - _rangeIn)*1.0/self.desiredDuration;
    self.currentTimeLabel.text = [NvMimoUtils convertTimecode:position - _rangeIn];
}

- (void)didPlaybackStopped:(NvsTimeline *)timeline {
    self.playbackBtn.selected = NO;
    if ([self.delegate respondsToSelector:@selector(didPlaybackStopped:)]) {
        [self.delegate didPlaybackStopped:timeline];
    }
}

- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    [self setHiddenPanelTimer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_currentTime = self->_rangeIn+1;
        [self seekTimeline:self->_rangeIn+1];
        [self play];
        if ([self.delegate respondsToSelector:@selector(didPlaybackEOF:)]) {
            [self.delegate didPlaybackEOF:timeline];
        }
    });
}


@end
