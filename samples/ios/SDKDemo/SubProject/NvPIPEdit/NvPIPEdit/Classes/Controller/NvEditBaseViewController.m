//
//  NvEditBaseViewController.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/30.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvEditBaseViewController.h"
#import "NvSDKUtils.h"
#import "NvUtils.h"

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

// 定位某一时间戳的图像
- (void)seekTimeline {
    int flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster;
    int64_t currentTime = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    if (![self.streamingContext seekTimeline:self.timeline timestamp:currentTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag]) {
        NSLog(@"Failed to seek timeline!");
    }
}

- (void)seekTimelineWithoutFlag {
    int flag = 0;
    int64_t currentTime = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    
    if (![self.streamingContext seekTimeline:self.timeline timestamp:currentTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag]) {
        NSLog(@"Failed to seek timeline!");
    }
}

// 定位某一时间戳的图像
- (void)seekTimeline:(int64_t)postion {
    int flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster;
    if (![_streamingContext seekTimeline:_timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag])
        NSLog(@"定位时间线失败！");
    
    _liveWindowPanel.progressSlider.value = 1.0*postion/self.timeline.duration;
    _liveWindowPanel.currentTime = postion;
}

- (void)seekTimelineWithoutFlag:(int64_t)postion {
    int flag = 0;
    if (![_streamingContext seekTimeline:_timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag])
        NSLog(@"定位时间线失败！");
    
    _liveWindowPanel.progressSlider.value = 1.0*postion/self.timeline.duration;
    _liveWindowPanel.currentTime = postion;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
