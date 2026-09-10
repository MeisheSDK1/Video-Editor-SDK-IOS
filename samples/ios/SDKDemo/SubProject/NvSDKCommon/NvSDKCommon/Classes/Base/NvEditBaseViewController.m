//
//  NvEditBaseViewController.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/30.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvEditBaseViewController.h"
#import "NvSDKUtils.h"

#import <NvBaseCommon/UIView+Dimension.h>

@interface NvEditBaseViewController ()

@end

@implementation NvEditBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.streamingContext = [NvSDKUtils getSDKContext];
    [self addBaseLiveWindowPanal];
    [_liveWindowPanel connectTimeline:_timeline];
    [self seekTimeline];
}

- (void)setTimeline:(NvsTimeline *)timeline {
    _timeline = timeline;
    NSLog(@"%lld",_timeline.duration);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self connectLiveWindow];
}

- (void)connectLiveWindow {
    [self.liveWindowPanel connectTimeline:_timeline];
    [self seekTimeline];
}

- (void)addBaseLiveWindowPanal {
    self.liveWindowPanel = [[NvLiveWindowPanelView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width)];
    _liveWindowPanel.editMode = self.editMode;
    [self.view addSubview:_liveWindowPanel];
}

- (void)seekTimeline {
    int flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (self.isChange) {
        flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing;
        [self.streamingContext setTimeline:_timeline scaleForSeek:self.scaleForSeek];
    }
    
    int64_t currentTime = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    NSNumber * OResolutionNum = NV_UserInfo(@"NvCompileResolution");
    if (OResolutionNum.intValue >= 2160) {
        NvsRational rational = {1,4};
        if (![_streamingContext seekTimeline:_timeline timestamp:currentTime proxyScale:&rational flags:flag]) {
            NSLog(@"定位时间线失败！Failed to seek timeline!");
        }
    }else {
        if (![self.streamingContext seekTimeline:self.timeline timestamp:currentTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag]) {
            NSLog(@"定位时间线失败！Failed to seek timeline!");
        }
    }
    
}

- (void)seekTimelineWithoutFlag {
    int flag = NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (self.isChange) {
        flag = NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing;
        [self.streamingContext setTimeline:_timeline scaleForSeek:self.scaleForSeek];
    }
    int64_t currentTime = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    NSNumber * OResolutionNum = NV_UserInfo(@"NvCompileResolution");
    if (OResolutionNum.intValue >= 2160) {
        NvsRational rational = {1,4};
        if (![_streamingContext seekTimeline:_timeline timestamp:currentTime proxyScale:&rational flags:flag]) {
            NSLog(@"定位时间线失败！Failed to seek timeline!");
        }
    }else {
        if (![self.streamingContext seekTimeline:self.timeline timestamp:currentTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag]) {
            NSLog(@"定位时间线失败！Failed to seek timeline!");
        }
    }
    
}

- (void)seekTimeline:(int64_t)postion {
    int flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (self.isChange) {
        flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing;
        [self.streamingContext setTimeline:_timeline scaleForSeek:self.scaleForSeek];
    }
    
    NSNumber * OResolutionNum = NV_UserInfo(@"NvCompileResolution");
    if (OResolutionNum.intValue >= 2160) {
        NvsRational rational = {1,4};
        if (![_streamingContext seekTimeline:_timeline timestamp:postion proxyScale:&rational flags:flag]) {
            NSLog(@"定位时间线失败！Failed to seek timeline!");
        }
    }else {
        if (![_streamingContext seekTimeline:_timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag])
            NSLog(@"定位时间线失败！Failed to seek timeline!");
    }
    
    _liveWindowPanel.progressSlider.value = 1.0*postion/self.timeline.duration;
    _liveWindowPanel.currentTime = postion;
}

- (void)seekTimelineWithoutFlag:(int64_t)postion {
    int flag = NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (self.isChange) {
        flag = NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing;
        [self.streamingContext setTimeline:_timeline scaleForSeek:self.scaleForSeek];
    }
    
    NSNumber * OResolutionNum = NV_UserInfo(@"NvCompileResolution");
    if (OResolutionNum.intValue >= 2160) {
        NvsRational rational = {1,4};
        if (![_streamingContext seekTimeline:_timeline timestamp:postion proxyScale:&rational flags:flag]) {
            NSLog(@"定位时间线失败！Failed to seek timeline!");
        }
    }else {
        if (![_streamingContext seekTimeline:_timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag])
            NSLog(@"定位时间线失败！Failed to seek timeline!");
    }
    
    _liveWindowPanel.progressSlider.value = 1.0*postion/self.timeline.duration;
    _liveWindowPanel.currentTime = postion;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
