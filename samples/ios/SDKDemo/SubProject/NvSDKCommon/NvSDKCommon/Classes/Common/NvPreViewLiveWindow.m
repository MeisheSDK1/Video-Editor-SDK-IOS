//
//  NvPreViewLiveWindow.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/9/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvPreViewLiveWindow.h"
#import "NvsLiveWindow.h"
//#import "NvTimelineUtils.h"
#import <NvSDKCommon/NvWeakTimer.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import <NvSDKCommon/NvUtils.h>
#import <NvBaseCommon/UIView+Dimension.h>
#import <NvSDKCommon/NvHDRManager.h>

#define UnSupport4kLength 1920

@interface NvPreViewLiveWindow ()<NvsStreamingContextDelegate>

@property (nonatomic, strong) NvsLiveWindow *livewindow;
@property (nonatomic, strong) NvsStreamingContext *context;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *compileButton;
@property (nonatomic, strong) UIImageView *playImageView;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, strong) NvWeakTimer *timer;

@end

@implementation NvPreViewLiveWindow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.blackColor;
        self.context = [NvsStreamingContext sharedInstanceWithFlags:NvsStreamingContextFlag_Support4KEdit | NvsStreamingContextFlag_InterruptStopForInternalStop ];
        self.context.delegate = self;
        self.livewindow = [[NvsLiveWindow alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        self.livewindow.center = self.center;
        [self addSubview:self.livewindow];
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeButton.frame = CGRectMake(13*SCREENSCALE, NV_STATUSBARHEIGHT, 37*SCREENSCALE, 37*SCREENSCALE);
        [self.closeButton setImage:NvImageNamed(@"Nvback") forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton];
        
        self.compileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.compileButton.frame = CGRectMake(SCREENWIDTH - 50*SCREENSCALE, NV_STATUSBARHEIGHT, 37*SCREENSCALE, 37*SCREENSCALE);
        [self.compileButton setImage:NvImageNamed(@"NvCompile") forState:UIControlStateNormal];
        [self.compileButton addTarget:self action:@selector(compileClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.compileButton];
        
        self.playImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64*SCREENSCALE, 64*SCREENSCALE)];
        self.playImageView.image = NvImageNamed(@"NvParticlePreviewPlay");
        self.playImageView.center = self.center;
        self.playImageView.userInteractionEnabled = YES;
        [self.playImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playOrStop:)]];
        [self addSubview:self.playImageView];
        
        self.slider = [[UISlider alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT - INDICATOR - 95 * SCREENSCALE, SCREENWIDTH, 20)];
        [_slider setThumbImage:NvImageNamed(@"Nvslider") forState:UIControlStateNormal];
        _slider.minimumValue = 0;
        _slider.maximumValue = 1;
        [_slider setMinimumTrackTintColor:UIColor.whiteColor];
        [_slider setMaximumTrackTintColor:UIColor.whiteColor];
        [_slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:(UIControlEventValueChanged)];
        [_slider addTarget:self action:@selector(progressSliderValueDidEnd:) forControlEvents:UIControlEventTouchUpInside];
        [_slider addTarget:self action:@selector(progressSliderValueDidEnd:) forControlEvents:UIControlEventTouchUpOutside];
        [self addSubview:self.slider];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self.livewindow addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)singleTap:(UITapGestureRecognizer *)gesture{
    if (self.playImageView.hidden == YES) {
        self.playImageView.hidden = NO;
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        _timer = [NvWeakTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideControlPanel:) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
    } else {
        if (_context.getStreamingEngineState == NvsStreamingEngineState_Playback) {
            [self pause];
        }else{
            [self play];
        }
    }
}

- (void)hideControlPanel:(NvWeakTimer *)timer{
    if (!_playImageView.hidden){
        _playImageView.hidden = YES;
    }
}

- (NvsSize)calculateTimelineSize:(NvEditMode)editMode {
    int compileRes = 1080;
    NvsSize size;
    if (editMode == NvEditMode16v9) {
        size.height = compileRes;
        size.width = compileRes * 16 / 9;
    } else if (editMode == NvEditMode1v1) {
        size.height = compileRes;
        size.width = compileRes;
    } else if (editMode == NvEditMode9v16) {
        size.width = compileRes;
        size.height = compileRes * 16 / 9;
    } else if (editMode == NvEditMode3v4) {
        size.width = compileRes;
        size.height = compileRes * 4 / 3;
    } else if (editMode == NvEditMode4v3) {
        size.width = compileRes * 4 / 3;
        size.height = compileRes;
    } else if (editMode == NvEditMode21v9){
        size.height = compileRes;
        size.width = compileRes * 21 / 9;
        if ([NvUtils isUnSupport4KEdit] && size.width > UnSupport4kLength) {
            size.width = UnSupport4kLength;
            int h = UnSupport4kLength * 9 / 21;
            size.height = (h + 1) & ~1;
        }
    } else if (editMode == NvEditMode9v21) {
        size.width = compileRes;
        size.height = compileRes * 21 / 9;
        if ([NvUtils isUnSupport4KEdit] && size.height > UnSupport4kLength) {
            size.height = UnSupport4kLength;
            int w = UnSupport4kLength * 9 / 21;
            size.width =  (w + 3) & ~3;
        }
    } else if (editMode == NvEditMode18v9) {
        size.height = compileRes;
        size.width = compileRes * 18 / 9;
        if ([NvUtils isUnSupport4KEdit] && size.width > UnSupport4kLength) {
            size.width = UnSupport4kLength;
            int h = UnSupport4kLength * 9 / 18;
            size.height = (h + 1) & ~1;
        }
    } else if (editMode == NvEditMode9v18) {
        size.width = compileRes;
        size.height = compileRes * 18 / 9;
        if ([NvUtils isUnSupport4KEdit] && size.height > UnSupport4kLength) {
            size.height = UnSupport4kLength;
            int w = UnSupport4kLength * 9 / 18;
            size.width =  (w + 3) & ~3;
        }
    }else if (editMode == NvEditMode7v6) {
        size.height = compileRes;
        size.width = compileRes * 7 / 6;
    } else if (editMode == NvEditMode6v7) {
        size.width = compileRes;
        size.height = compileRes * 7 / 6;
    }else {
        size.width = 1280;
        size.height = 720;
    }
    return size;
}


- (NvsTimeline *)createTimelineOrdinary:(NvEditMode)editMode {
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    NvsSize size = [self calculateTimelineSize:editMode];
    NvsVideoResolution videoEditRes;
    videoEditRes.imageWidth = size.width;
    videoEditRes.imageHeight = size.height;
    videoEditRes.imagePAR = (NvsRational){1, 1};
    NvsRational videoFps = {30, 1};
    NvsAudioResolution audioEditRes;
    audioEditRes.sampleRate = 48000;
    audioEditRes.channelCount = 2;
    audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
    NvsTimeline *timeline;
    if ([NvHDRManager isSupportEditing]) {
        timeline = [context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes bitDepth:[NvSDKUtils resolutionModelSetting] flags:0];
    }else{
        timeline = [context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes flags:0];
    }
    [timeline appendVideoTrack];
    ///音乐轨道
    ///Musical track
    [timeline appendAudioTrack];
    ///配音轨道
    ///Dubbing track
    [timeline appendAudioTrack];
    return timeline;
}


- (void)setModel:(NvEditMode)model {
    _model = model;
    if (self.model == NvEditMode16v9) {
        self.livewindow.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH * 9 / 16);
    } else {
        self.livewindow.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    }
    self.livewindow.center = self.center;
    self.timeline = [self createTimelineOrdinary:model];
    [self.context connectTimeline:self.timeline withLiveWindow:self.livewindow];
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    
    if (videoTrack == nil) {
        return;
    }
    
    for (int i = 0; i < self.pathArray.count; i++) {
        [videoTrack appendClip:self.pathArray[i]];
    }
     [_context seekTimeline:_timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}

- (void)backClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(backClick)]) {
        [self.context stop];
        [self.delegate backClick];
    }
}

- (void)compileClick:(UIButton *)button {
    [self pause];
    if ([self.delegate respondsToSelector:@selector(compileClick:)]) {
        [self.delegate compileClick:self.timeline];
    }
}

- (void)progressSliderValueDidEnd:(UISlider *)slider{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    self.playImageView.hidden = NO;
}

- (void)progressSliderValueChanged:(UISlider *)slider{
    [self seek:lround(slider.value * self.timeline.duration)];
}

- (void)play {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NvWeakTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideControlPanel:) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
    [self.context playbackTimeline:self.timeline startTime:[self.context getTimelineCurrentPosition:self.timeline] endTime:self.timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}

- (void)pause {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    self.playImageView.hidden = NO;
    [self.context stop];
}

- (void)playOrStop:(UITapGestureRecognizer *)tap {
    if (self.context.getStreamingEngineState == NvsStreamingEngineState_Playback) {
        [self pause];
    }else{
        [self play];
    }
}

- (void)seek:(int64_t)pos {
    [self.context seekTimeline:self.timeline timestamp:pos videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    [self.slider setValue:(float)position / timeline.duration animated:YES];
}

/*!
 *  \brief 播放预先加载完成
 *  Play is preloaded
 *  \param timeline 时间线
 */
- (void)didPlaybackPreloadingCompletion:(NvsTimeline *)timeline{
    [self didStreamingEngineStateChanged:self.context.getStreamingEngineState];
}

/*!
 *  \brief 播放停止
 *  Play stop
 *  \param timeline 时间线
 */
- (void)didPlaybackStopped:(NvsTimeline *)timeline {
    [self didStreamingEngineStateChanged:self.context.getStreamingEngineState];
}

/*!
 *  \brief 播放到结尾
 *  Play to the end
 *  \param timeline 时间线
 */
- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    [self seek:0];
    [self.slider setValue:0 animated:YES];
    [self didStreamingEngineStateChanged:self.context.getStreamingEngineState];
}

- (void)againConnection{
    if (![[NvSDKUtils getSDKContext] connectTimeline:_timeline withLiveWindow:_livewindow]) {
        return;
    }
    [NvsStreamingContext sharedInstance].delegate = self;
    [self seek:[self.context getTimelineCurrentPosition:self.timeline]];
}

/*!
 *  \brief 生成视频文件进度
 *  Progress of generating a video file
 *  \param timeline 时间线
 *  \param progress 进度值
 */
- (void)didCompileProgress:(NvsTimeline *)timeline progress:(int)progress {
    
}


/*!
 *  \brief 生成视频文件完成
 *  The video file is generated
 *  \param timeline 时间线
 *  \param isCanceled 中途取消导致生成完成。注：任何对引擎操作引起的停止生成均视为中途取消
 *  A midstream cancellation causes the build to complete. Note: Any stop generation caused by engine operation is deemed to be cancelled midway
 *  \since 1.6.0
 *  \sa didCompileFinished:
 */
- (void)didCompileCompleted:(NvsTimeline *)timeline isCanceled:(BOOL)isCanceled {
    
}

/*!
 *  \brief 生成视频文件失败
 *  Failed to generate the video file. Procedure
 *  \param timeline 时间线
 */
- (void)didCompileFailed:(NvsTimeline *)timeline {
    
}

/*!
 *  \brief 引擎状态改变
 *  Engine state change
 *  \param state 引擎状态
 */
- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state {
    if (state == NvsStreamingEngineState_Playback) {
        self.playImageView.image = NvImageNamed(@"NvParticlePreviewSuspend");
    } else {
        self.playImageView.image = NvImageNamed(@"NvParticlePreviewPlay");
    }
}

@end
