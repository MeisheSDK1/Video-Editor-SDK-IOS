//
//  NvCutVideoViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/21.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvCutVideoViewController.h"
#import "NvsVideoTrack.h"
#import "NvsVideoClip.h"
#import <NvSDKCommon/NvUtils.h>
#import "NvsTimelineEditor.h"
#import "NvsTimelineTimeSpan.h"
#import <Masonry/Masonry.h>

@interface NvCutVideoViewController ()<NvsTimelineEditorDelegate, NvLiveWindowPanelViewDelegate>

///所有模块统一控件
///All modules unified control
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) NvsTimelineEditor *timeLineEdit;
@property (nonatomic, strong) NvsTimelineTimeSpan *timeSpan;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIView *line;

@end

@implementation NvCutVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.liveWindowPanel.liveWindow.hdrDisplayMode = NvsLiveWindowHDRDisplayMode_SDR;
    
    // Do any additional setup after loading the view.
    self.title = NvLocalString(@"Crop", @"裁剪");
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
    self.textLabel.font = [NvUtils fontWithSize:10 * SCREENSCALE];
    
    self.textLabel.text = [NSString stringWithFormat:NvLocalString(@"croppingTime", @"裁剪后总时长为%@"),[NvUtils convertTimecodePrecision:self.trimOut - self.trimIn]];
    [self.view addSubview:_textLabel];
    [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.liveWindowPanel.mas_bottom).offset(12 * SCREENSCALE);
        make.centerX.equalTo(self.liveWindowPanel);
    }];

    [self.view layoutIfNeeded];

    self.timeLineEdit = [[NvsTimelineEditor alloc] initWithFrame:CGRectMake(13 * SCREENSCALE,426 * SCREENSCALE, 350 * SCREENSCALE,90 * SCREENSCALE)];
    self.timeLineEdit.caneditTimeSpan = YES;
    self.timeLineEdit.canOverlapTimeSpan = YES;
    self.timeLineEdit.timelinePosition = self.timeline.duration;
    [self.view addSubview:self.timeLineEdit];
    NvsTimelineEditorInfo *info = [[NvsTimelineEditorInfo alloc] init];
    
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    NvsVideoClip *clip = [videoTrack getClipWithIndex:0];
    
    info.mediaFilePath = clip.filePath;
    info.inPoint = 0;
    info.outPoint = self.timeline.duration;
    info.trimIn = 0;
    info.trimOut = self.timeline.duration;
    info.stillImageHint = false;
    [self.timeLineEdit initTimelineEditor:@[info] timelineDuration:self.timeline.duration];
    self.timeLineEdit.delegate = self;
    self.timeLineEdit.type = 0;
    ///添加两边滑块
    ///Add sliders on both sides
    self.timeSpan = [self.timeLineEdit addTimeSpan:0 outPoint:self.timeline.duration];
    self.timeSpan.inPoint = self.trimIn;
    self.timeSpan.outPoint = self.trimOut;
    [self.timeLineEdit updateTrimIn:self.trimIn trimOut:self.trimOut];
    
    [self.timeSpan setSelected:YES];
    self.timeSpan.editable = YES;
    
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

- (void)playButtonClick {
    [self.liveWindowPanel playAtTime:self.trimIn];
}

- (void)finshClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(cutVideoViewController:trimIn:trimOut:)]) {
        [self.delegate cutVideoViewController:self trimIn:self.trimIn trimOut:self.trimOut];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    if (position > self.trimOut) {
        [self seekTimeline:self.trimIn];
    }
}

- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state {
    if (state == NvsStreamingEngineState_Playback) {
        self.playButton.hidden = YES;
    } else {
        self.playButton.hidden = NO;
    }
}
#pragma mark - NvsTimelineEditorDelegate
- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint {
    self.isChange = YES;
    self.scaleForSeek = self.timeline.duration / 1000000 /  [self.timeLineEdit getTimelineEditorWidth] / UIScreen.mainScreen.scale;
    if (isInPoint) {
        self.trimIn = timestamp;
        [self seekTimeline:self.trimIn];
    } else {
        self.trimOut = timestamp;
        [self seekTimeline:self.trimOut];
    }
    self.textLabel.text = [NSString stringWithFormat:NvLocalString(@"croppingTime", @"裁剪后总时长为%@"),[NvUtils convertTimecodePrecision:self.trimOut - self.trimIn]];
}

- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)timestamp isInPoint:(bool)isInPoint {
    self.isChange = NO;
    if (isInPoint) {
        self.trimIn = timestamp;
        [self seekTimeline:self.trimIn];
    } else {
        self.trimOut = timestamp;
        [self seekTimeline:self.trimOut];
    }
    self.textLabel.text = [NSString stringWithFormat:NvLocalString(@"croppingTime", @"裁剪后总时长为%@"),[NvUtils convertTimecodePrecision:self.trimOut - self.trimIn]];
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
