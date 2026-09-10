//
//  NvTrimVideoViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/12.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvTrimVideoViewController.h"
#import "NvsTimelineEditor.h"
#import "NvsTimelineTimeSpan.h"
#import "NvsVideoTrack.h"
#import "NvsVideoClip.h"
#import "NvVideoSlider.h"
#import "NvShortVideoEditViewController.h"
#import "NvShortVideoCaptureViewController.h"
#import "NvRecordingInfo.h"
#import <NvSDKCommon/NvUtils.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvBaseCommon/UIView+Dimension.h>
#import <Masonry/Masonry.h>
#import "NvTimelineUtils.h"

@interface NvTrimVideoViewController ()<NvLiveWindowPanelViewDelegate, NvVideoSliderDelegate, NvsStreamingContextDelegate>

///所有模块统一控件
///All modules unified control
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIButton *rotationButton;
@property (nonatomic, assign) int64_t trimIn;
@property (nonatomic, assign) int64_t trimOut;

@property (nonatomic, strong) NvVideoSlider *videoSlider;
@property (nonatomic, strong) NSString *compilePath;

@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) UIView *line;


@end

@implementation NvTrimVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.liveWindowPanel.liveWindow.hdrDisplayMode = NvsLiveWindowHDRDisplayMode_SDR;
    
    // Do any additional setup after loading the view.
    self.title = NvLocalString(@"Crop", @"裁剪");
    self.trimIn = 0;
    self.trimOut = self.timeline.duration > 15*NV_TIME_BASE ? 15*NV_TIME_BASE : self.timeline.duration;
    self.liveWindowPanel.delegate = self;
    [self.liveWindowPanel setForceHiddenControlPanel:YES];
    [self.liveWindowPanel addTapScreenPause];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setImage:NvImageNamed(@"play - FontAwesome Copy") forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.liveWindowPanel);
        make.width.equalTo(@(50*SCREENSCALE));
        make.height.equalTo(@(50*SCREENSCALE));
    }];
    
    self.textLabel = [UILabel new];
    self.textLabel.textColor = UIColor.whiteColor;
    self.textLabel.font = [NvUtils fontWithSize:10];
    
    self.textLabel.text = [NSString stringWithFormat:NvLocalString(@"croppingTime", @"裁剪后总时长为%@"),[NvUtils convertTimecode:self.trimOut - self.trimIn]];
    [self.view addSubview:_textLabel];
    [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.liveWindowPanel.mas_bottom).offset(12 * SCREENSCALE);
        make.left.equalTo(self.liveWindowPanel.mas_left).offset(12*SCREENSCALE);
    }];
    self.rotationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rotationButton setImage:NvImageNamed(@"NvRotation") forState:UIControlStateNormal];
    [self.rotationButton addTarget:self action:@selector(rotationCLick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rotationButton];
    [self.rotationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.textLabel);
        make.right.equalTo(self.view).offset(-13*SCREENSCALE);
        make.width.equalTo(@(28*SCREENSCALE));
        make.height.equalTo(@(28*SCREENSCALE));
    }];
    [self.view layoutIfNeeded];
    self.videoSlider = [[NvVideoSlider alloc] initWithFrame:CGRectMake(0, self.textLabel.bottom + 12*SCREENSCALE, self.view.frame.size.width, 67*SCREENSCALE)];
    self.videoSlider.delegate = self;
    self.videoSlider.caneditTimeSpan = true;
    self.videoSlider.canOverlapTimeSpan = false;
    self.videoSlider.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.videoSlider];
    self.videoSlider.maximumDuration = 15*NV_TIME_BASE;
    NSMutableArray *descArray = [NSMutableArray array];
    NvVideoSliderInfo* desc = [[NvVideoSliderInfo alloc] init];
    desc.stillImageHint = NO;
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    NvsVideoClip *clip = [videoTrack getClipWithIndex:0];
    self.info.rotaion = [clip getExtraVideoRotation];
    desc.mediaFilePath = clip.filePath;
    desc.trimIn = clip.trimIn;
    desc.trimOut = clip.trimOut;
    desc.inPoint = clip.inPoint;
    desc.outPoint = clip.outPoint;
    [descArray addObject:desc];

    [self.videoSlider initTimelineEditor:descArray timelineDuration:self.timeline.duration];
    
    UIButton *finshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [finshBtn setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    finshBtn.frame = CGRectMake(175 * SCREENSCALE, 102 *SCREENSCALE, 25 * SCREENSCALE, 20 * SCREENSCALE);
    [finshBtn addTarget:self action:@selector(finshClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finshBtn];
    [finshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(25*SCREENSCALE));
        make.height.equalTo(@(20*SCREENSCALE));
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(self.view.mas_bottom).offset(-15*SCREENSCALE);
        }
    }];
    
    self.line = [UIView new];
    self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.view addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(finshBtn.mas_top).offset(-12*SCREENSCALE);
    }];
}

/*
 点击返回按钮
 click the back button
 */
- (void)leftNavButtonClick:(UIButton *)button {
    NSArray *viewControllers = self.navigationController.viewControllers;
    UIViewController *viewController = viewControllers[viewControllers.count-1];
    while (viewController.class != [NvShortVideoCaptureViewController class]) {
        viewController = viewControllers[[viewControllers indexOfObject:viewController]-1];
    }
    [self.navigationController popToViewController:viewController animated:YES];
}

/*
 点击播放按钮
 click the play button
 */
- (void)playButtonClick {
    [NvTimelineUtils playbackTimeline:self.timeline startTime:self.trimIn endTime:self.trimOut flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}

/*
 点击旋转按钮
 click the rotate button
 */
- (void)rotationCLick {
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    NvsVideoClip *clip = [videoTrack getClipWithIndex:0];
    if ([clip getExtraVideoRotation] == NvsExtraVideoRotation_0) {
        [clip setExtraVideoRotation:NvsExtraVideoRotation_90];
    } else if ([clip getExtraVideoRotation] == NvsExtraVideoRotation_90) {
        [clip setExtraVideoRotation:NvsExtraVideoRotation_180];
    }  else if ([clip getExtraVideoRotation] == NvsExtraVideoRotation_180) {
        [clip setExtraVideoRotation:NvsExtraVideoRotation_270];
    }  else if ([clip getExtraVideoRotation] == NvsExtraVideoRotation_270) {
        [clip setExtraVideoRotation:NvsExtraVideoRotation_0];
    }
    self.info.rotaion = [clip getExtraVideoRotation];
    [self seekTimeline:0];
}

/*
 点击结束按钮
 click the finish button
 */
- (void)finshClick:(UIButton *)button {
    NSMutableArray *files = [NSMutableArray array];
    self.info.trimIn = self.trimIn;
    self.info.trimOut = self.trimOut;
    self.info.speed = 1;
    self.info.musicEndPos = (self.trimOut - self.trimIn)*1.0/NV_TIME_BASE;
    [files addObject:self.info];
    NvShortVideoEditViewController *editvc = [[NvShortVideoEditViewController alloc] init];
    
    editvc.videoPathArray = [files mutableCopy];
    if (self.isNoMusic) {
        editvc.musicPath = nil;
    } else {
        editvc.musicPath = self.musicPath;
        editvc.trimIn = self.musicTrimIn*NV_TIME_BASE;
        editvc.trimOut = self.musicTrimOut*NV_TIME_BASE;
    }
    [self.navigationController pushViewController:editvc animated:YES];
}

#pragma mark - 播放的回调
//the protocol method of NvsStreamingContextDelegate
- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    [self.videoSlider setTimespanMiddleHandlePosition:position];
    if (position > self.trimOut) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self seekTimeline:self.trimIn];
        });
    }
}

- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state {
    if (state == NvsStreamingEngineState_Playback) {
        self.playButton.hidden = YES;
    } else {
        self.playButton.hidden = NO;
    }
}

#pragma mark - NvLiveWindowPanelViewDelegate
- (void)sliderValueChanged:(float)value {
    [self.videoSlider setTimespanMiddleHandlePosition:self.timeline.duration*value];
}

#pragma mark - NvVideoSliderDelegate
- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)trimin trimOut:(int64_t)trimout {
    NSLog(@"trimIn:%lld ,trimOut:%lld",trimin,trimout);
    self.isChange = YES;
    self.scaleForSeek = self.timeline.duration / 1000000 /  [self.videoSlider getTimelineEditorWidth] / UIScreen.mainScreen.scale;
    if (self.videoSlider.leftSliderView == timelineEditor) {
        [self seekTimeline:trimin];
        self.trimIn = trimin;
    } else {
        [self seekTimeline:trimout];
        self.trimOut = trimout;
    }
    self.textLabel.text = [NSString stringWithFormat:NvLocalString(@"croppingTime", @"裁剪后总时长为%@"),[NvUtils convertTimecode:self.trimOut - self.trimIn]];
}

- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)trimin trimOut:(int64_t)trimout {
    self.isChange = NO;
    if (self.videoSlider.leftSliderView == timelineEditor) {
        [self seekTimeline:trimin];
        self.trimIn = trimin;
    } else {
        [self seekTimeline:trimout];
        self.trimOut = trimout;
    }
    self.textLabel.text = [NSString stringWithFormat:NvLocalString(@"croppingTime", @"裁剪后总时长为%@"),[NvUtils convertTimecode:self.trimOut - self.trimIn]];
}

- (void)timelineEditor:(id)timelineEditor dragScrollingTimeline:(int64_t)timestamp {
    int64_t interval = self.trimOut - self.trimIn;
    self.isChange = YES;
    self.scaleForSeek = self.timeline.duration / 1000000 /  [self.videoSlider getTimelineEditorWidth] / UIScreen.mainScreen.scale;
    [self seekTimeline:timestamp<0?0:timestamp];
    self.trimIn = timestamp;
    self.trimOut = interval + self.trimIn;
}

- (void)timelineEditor:(id)timelineEditor dragScrollTimelineEnded:(int64_t)timestamp {
    int64_t interval = self.trimOut - self.trimIn;
    self.isChange = NO;
    [self seekTimeline:timestamp<0?0:timestamp];
    self.trimIn = timestamp;
    self.trimOut = interval + self.trimIn;
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
