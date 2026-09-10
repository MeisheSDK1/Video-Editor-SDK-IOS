//
//  NvLiveWindowPanelView.m
//  SDKDemo
//
//  Created by meishe01 on 2018/5/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMimoLiveWindowPanelView.h"
#import "NVHeader.h"
#import "NvsLiveWindow.h"
#import "NvMimoWeakTimer.h"
#import "NvMimoSDKUtils.h"
#import <UIColor+NvColor.h>
#import "NvMimoUtils.h"
#import <UIView+Dimension.h>

@interface NvMimoLiveWindowPanelView () <NvsStreamingContextDelegate> {
    NvsTimeline *_timeline;
    UIButton *_playbackBtn;
    UILabel *_currentTimeLabel;
    UIButton *_volumnBtn;
    UILabel *_durationLabel;
    NvMimoWeakTimer *_timer;
    UITapGestureRecognizer *_tap,*_tapScreen;
    int64_t every;
    // Is it a pause for the user's own click
    BOOL userPause;//是否是用户自己点击的暂停
}

@property (nonatomic, assign) int64_t duration;
// Whether to display the prompt information interface of modifying compound subtitles
@property (nonatomic, assign) BOOL isShowCaptionInfo; //是否显示修改复合字幕提示信息界面
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, assign) BOOL isChange;
@property (nonatomic, assign) CGFloat scaleForSeek;
@end

@implementation NvMimoLiveWindowPanelView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.streamingContext = [NvsStreamingContext sharedInstance];
        [self addSubviews:frame];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame isShowCaptionInfo:(BOOL)isShowCaptionInfo {
    self = [super initWithFrame:frame];
    self.isShowCaptionInfo = isShowCaptionInfo;
    if (self) {
        self.streamingContext = [NvsStreamingContext sharedInstance];
        [self addSubviews:frame];
    }
    return self;
}

- (void)addSubviews:(CGRect)rect {
    userPause = YES;
    _liveWindow = [[NvsLiveWindow alloc] initWithFrame:rect];
    [self addSubview:_liveWindow];
    if(self.isShowCaptionInfo) {
        UILabel *captionInfoLabel = [[UILabel alloc] init];
        [self addSubview:captionInfoLabel];
        captionInfoLabel.textAlignment = NSTextAlignmentCenter;
        captionInfoLabel.textColor = [UIColor nv_colorWithHexARGB:@"#80FFFFFF"];
        captionInfoLabel.font = [UIFont systemFontOfSize:12*SCREANSCALE];
        captionInfoLabel.backgroundColor = [UIColor clearColor];
        [captionInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.top.equalTo(self->_liveWindow.mas_bottom).offset(15*SCREANSCALE);
            make.height.equalTo(@(25*SCREANSCALE));
        }];
    }
    _controlPanelView = [UIView new];
    _controlPanelView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#80000000"];
    [self addSubview:_controlPanelView];
    [_controlPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(@(40 * SCREANSCALE));
    }];
    _playbackBtn = [UIButton new];
    [_playbackBtn setImage:[UIImage imageNamed:@"NvPlayback"] forState:UIControlStateNormal];
    [_controlPanelView addSubview:_playbackBtn];
    [_playbackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(@0);
        make.width.equalTo(self->_controlPanelView.mas_height);
    }];
    _currentTimeLabel = [UILabel new];
    _currentTimeLabel.text = @"00:00";
    _currentTimeLabel.textColor = [UIColor whiteColor];
    _currentTimeLabel.font = [UIFont systemFontOfSize:10];
    CGSize size = [_currentTimeLabel sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    [_controlPanelView addSubview:_currentTimeLabel];
    [_currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_playbackBtn.mas_right);
        make.centerY.equalTo(self->_controlPanelView);
        make.width.equalTo(@(size.width));
    }];
    _volumnBtn = [UIButton new];
    [_volumnBtn setImage:[UIImage imageNamed:@"NvVolumn"] forState:UIControlStateNormal];
    [_controlPanelView addSubview:_volumnBtn];
    [_volumnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(@0);
        make.width.equalTo(self->_controlPanelView.mas_height);
    }];
    _durationLabel = [UILabel new];
    _durationLabel.text = @"00:00";
    _durationLabel.textColor = [UIColor whiteColor];
    _durationLabel.font = [UIFont systemFontOfSize:10];
    [_controlPanelView addSubview:_durationLabel];
    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self->_volumnBtn.mas_left);
        make.centerY.equalTo(self->_controlPanelView);
        make.width.equalTo(@(size.width));
    }];
    _progressSlider = [UISlider new];
    [_progressSlider setThumbImage:[UIImage imageNamed:@"NvSliderHandle"] forState:UIControlStateNormal];
    [_progressSlider setMinimumTrackTintColor:[UIColor nv_colorWithHexARGB:@"#FF2A7DFF"]];
    [_progressSlider setMaximumTrackTintColor:[UIColor nv_colorWithHexARGB:@"#FF979797"]];
    [_controlPanelView addSubview:_progressSlider];
    [_progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_currentTimeLabel.mas_right).offset(7 * SCREANSCALE);
        make.right.equalTo(self->_durationLabel.mas_left).offset(-7 * SCREANSCALE);
        make.centerY.equalTo(self->_controlPanelView);
    }];
    
    [_playbackBtn addTarget:self action:@selector(playbackBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [_volumnBtn addTarget:self action:@selector(volumnBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [_progressSlider addTarget:self action:@selector(progressSliderValueChanged) forControlEvents:(UIControlEventValueChanged)];
    
    [_progressSlider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpInside];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [_liveWindow addGestureRecognizer:_tap];
}

- (void)setHiddenPanelTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NvMimoWeakTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideControlPanel:) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
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
        make.right.equalTo(@(-13*SCREANSCALE));
        make.centerY.equalTo(self->_controlPanelView);
        make.width.equalTo(@(35*SCREANSCALE));
    }];
}

- (void)singleTapScreen:(UITapGestureRecognizer *)recognizer {
    if (_controlPanelView.hidden) {
        if (_forceHiddenControlPanel) {//如果强制隐藏则直接播放// Play if hidden
            if (self.streamingContext.getStreamingEngineState != NvsStreamingEngineState_Playback) {
                if (![self.streamingContext playbackTimeline:_timeline startTime:self.currentTime endTime:_timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
                    DLog(@"播放时间线失败！");
                    return;
                }
                if ([self.delegate respondsToSelector:@selector(playback)]) {
                    [self.delegate playback];
                }
            } else {
                [self.streamingContext stop];
            }
        } else {//如果不是强制隐藏则显示并添加定时器
            // Show and add a timer if not forced hidden
            [self showControllPanel];
        }
    } else {
        if (self.streamingContext.getStreamingEngineState != NvsStreamingEngineState_Playback) {
            if (![self.streamingContext playbackTimeline:_timeline startTime:self.currentTime endTime:_timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
                DLog(@"播放时间线失败！");
                return;
            }
            if ([self.delegate respondsToSelector:@selector(playback)]) {
                [self.delegate playback];
            }
        } else {
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

- (void)setCurrentTime:(int64_t)currentTime {
    _currentTime = currentTime;
    _currentTimeLabel.text = [NvMimoUtils convertTimecode:_currentTime];
}

- (void)setDuration:(int64_t)duration {
    _duration = duration;
    _durationLabel.text = [NvMimoUtils convertTimecode:duration];
}

- (void)connectTimeline:(NvsTimeline *)timeline {
    if (![self.streamingContext connectTimeline:timeline withLiveWindow:_liveWindow]) {
        DLog(@"连接预览窗口失败！");
        return;
    }
    _timeline = timeline;
    self.streamingContext.delegate = self;
    self.duration = timeline.duration;
}

- (void)seekTimeline:(int64_t)pos {
    if (pos < 0) {
        pos = [self.streamingContext getTimelineCurrentPosition:_timeline];
    }
    int flags = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (self.isChange) {
        flags = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing;
        self.scaleForSeek = _timeline.duration / 1000000 /  self.progressSlider.frame.size.width / UIScreen.mainScreen.scale;
        [self.streamingContext setTimeline:_timeline scaleForSeek:0];
    }
    if (![self.streamingContext seekTimeline:_timeline timestamp:pos videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flags])
        DLog(@"Failed to seek timeline!");
}

- (void)playAtTime:(int64_t)pos {
    if (!_timeline)
        return;
    if ([self isPlayback]) {
        [self.streamingContext stop];
    } else {
        if (![self.streamingContext playbackTimeline:_timeline startTime:pos endTime:_timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
            DLog(@"播放时间线失败！");
            return;
        }
        if ([self.delegate respondsToSelector:@selector(playback)]) {
            [self.delegate playback];
        }
    }
    [self setHiddenPanelTimer];
}

- (void)playBackStart:(int64_t)start end:(int64_t)end {
    if (![self.streamingContext playbackTimeline:_timeline startTime:start endTime:end videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
        DLog(@"播放时间线失败！");
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
        if (![self.streamingContext playbackTimeline:_timeline startTime:self.currentTime endTime:_timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
            DLog(@"播放时间线失败！");
            return;
        }
        if ([self.delegate respondsToSelector:@selector(playback)]) {
            [self.delegate playback];
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
    [self seekTimeline:-1];
    _timer = [NvMimoWeakTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideControlPanel:) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
}

- (void)progressSliderValueChanged {
    self.isChange = YES;
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _controlPanelView.hidden = NO;
    
    self.currentTime = lround(_progressSlider.value * _duration);
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
    [self.progressSlider setValue:1 animated:YES];
    [self setHiddenPanelTimer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.currentTime = 0;
        self->_currentTimeLabel.text = [NvMimoUtils convertTimecode:0];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf)self = weakSelf;
            [self seekTimeline:0];
            [self.progressSlider setValue:0 animated:YES];
        });
        if ([self.delegate respondsToSelector:@selector(didPlaybackEOF:)]) {
            [self.delegate didPlaybackEOF:timeline];
        }
    });
}

- (BOOL)isPlayback {
    return [self.streamingContext getStreamingEngineState] == NvsStreamingEngineState_Playback;
}

- (void)dealloc {
    // 不要在dealloc 中停止引擎，因为dealloc的调用受系统控制，如果在这里停止引擎，可能引发需要播放的画面在莫名其妙的时机被停止播放。
    //Do not stop the engine in dealloc, because dealloc calls are controlled by the system, and stopping the engine here may cause the screen to be stopped at an inexplicable time.
}

- (void)setForceHiddenControlPanel:(BOOL)forceHiddenControlPanel {
    _forceHiddenControlPanel = forceHiddenControlPanel;
    if (forceHiddenControlPanel) {
        _controlPanelView.hidden = YES;
        [_liveWindow removeGestureRecognizer:_tap];
    }
}

- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state {
    if (state == NvsStreamingEngineState_Playback) {
        [_playbackBtn setImage:[NvMimoUtils imageWithName:@"NvPause"] forState:UIControlStateNormal];
    } else {
        [_playbackBtn setImage:[NvMimoUtils imageWithName:@"NvPlayback"] forState:UIControlStateNormal];
    }
    if ([self.delegate respondsToSelector:@selector(didStreamingEngineStateChanged:)]) {
        [self.delegate didStreamingEngineStateChanged:state];
    }
}
@end
