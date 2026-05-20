//
//  NvLivePhotoViewController.m
//  SDKDemo
//
//  Created by Mac-Mini on 2025/5/7.
//  Copyright © 2025 meishe. All rights reserved.
//

#import "NvLivePhotoViewController.h"
#import "NvLiveWindowPanelView.h"
#import "NvCompileViewController.h"
#import <NvStreamingSdkCore/NvStreamingSdkCore.h>
#import "NvRangeSequenceView.h"
#import "SDKDemo-Swift.h"
#import "NvTimelineImageUtils.h"

@interface NvLivePhotoViewController ()
<NvLiveWindowPanelViewDelegate,
NvCompileViewControllerDelegate,
NvRangeSequenceViewDelegate>

@property (nonatomic, strong) NvLiveWindowPanelView *liveWindowPanelView;
@property (nonatomic, assign) int64_t startTime, endTime;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) NSString *compileFilePath;
@property (nonatomic, strong) NvRangeSequenceView *rangeSequenceView;
@property (nonatomic, strong) UILabel *selectLabel;
@property (nonatomic, strong) UIButton *compileButton;
@end

@implementation NvLivePhotoViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.streamingContext = [NvsStreamingContext sharedInstance];
    _liveWindowPanelView = [[NvLiveWindowPanelView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width)];
    _liveWindowPanelView.editMode = self.editMode;
    _liveWindowPanelView.delegate = self;
    [self.view addSubview:_liveWindowPanelView];
    [self.liveWindowPanelView setForceHiddenControlPanel:true];
    [self.liveWindowPanelView connectTimeline:self.timeline];
    [self.liveWindowPanelView seekTimeline:0];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((self.view.width - 80)/2, self.liveWindowPanelView.bottom + 5, 80, 22);
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitle:NvLocalString(@"LivePhotoPreview", @"实况预览") forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPreviewClick) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 4;
    button.layer.maskedCorners = true;
    [self.view addSubview:button];
    
    self.rangeSequenceView = [[NvRangeSequenceView alloc] initWithFrame:CGRectMake(0, button.bottom + 127, self.view.width, 55)];
    self.rangeSequenceView.videoTrack = [self.timeline getVideoTrackByIndex:0];
    self.rangeSequenceView.minValue = 1 * NV_TIME_BASE;
    [self.view addSubview:self.rangeSequenceView];
    self.rangeSequenceView.delegate = self;
    self.selectLabel = [UILabel new];
    self.selectLabel.textColor = [UIColor whiteColor];
    self.selectLabel.textAlignment = NSTextAlignmentCenter;
    self.selectLabel.text = [NSString stringWithFormat:@"%@3s", NvLocalString(@"SelectTimeDuration", @"已选时长")];
    [self.selectLabel sizeToFit];
    UIFont *font = [UIFont fontWithName:@"PingFang SC-Regular" size:12];
    if (!font) {
        font = [UIFont boldSystemFontOfSize:12];
    }
    self.selectLabel.font = font;
    self.selectLabel.center = CGPointMake(self.rangeSequenceView.center.x, self.rangeSequenceView.bottom + 30);
    [self.view addSubview:self.selectLabel];
    self.startTime = 0;
    self.endTime = self.startTime + 3*NV_TIME_BASE;
}

- (UIView *)rightNavigationBarItemView {
    self.compileButton = [UIButton nv_buttonWithTitle:NvLocalString(@"Compile", @"生成") textColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] fontSize:16 image:nil];
    self.compileButton.frame = CGRectMake(0, 0, 30, 44);
    self.compileButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15*SCREENSCALE);
    [self.compileButton addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.compileButton.exclusiveTouch = YES;
    return self.compileButton;
}

- (void)rightBtnClicked {
    _compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NvCompileViewController *compileViewController = [NvCompileViewController new];
    compileViewController.isHDRSetUp = YES;
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compileTimeline:_timeline startTime:self.startTime endTime:self.endTime outputPath:_compileFilePath];
}

- (void)buttonPreviewClick {
    [self.liveWindowPanelView playBackStart:self.startTime end:self.endTime];
}


#pragma mark - NvRangeSequenceViewDelegate
- (void)onRangeSequenceView:(NvRangeSequenceView *)rangeSequenceView didLeftChange:(int64_t)leftValue isTouchUp:(BOOL)isTouchUp {
    self.startTime = leftValue;
    self.endTime = [rangeSequenceView getRightValue];
    [self.liveWindowPanelView seekTimeline:leftValue];
    self.selectLabel.text = [NSString stringWithFormat:@"%@%.1fs", NvLocalString(@"SelectTimeDuration", @"已选时长"), 1.0*(self.endTime - self.startTime) / NV_TIME_BASE];
    if (isTouchUp) {
        [self.liveWindowPanelView playBackStart:self.startTime end:self.endTime];
    }
}

- (void)onRangeSequenceView:(NvRangeSequenceView *)rangeSequenceView didRightChange:(int64_t)rightValue isTouchUp:(BOOL)isTouchUp {
    self.endTime = rightValue;
    self.startTime = [rangeSequenceView getLeftValue];
    [self.liveWindowPanelView seekTimeline:rightValue];
    self.selectLabel.text = [NSString stringWithFormat:@"%@%.1fs", NvLocalString(@"SelectTimeDuration", @"已选时长"), 1.0*(self.endTime - self.startTime) / NV_TIME_BASE];
    if (isTouchUp) {
        [self.liveWindowPanelView playBackStart:self.startTime end:self.endTime];
    }
}

- (void)onRangeSequenceView:(NvRangeSequenceView *)rangeSequenceView didSeekPosition:(int64_t)position isTouchUp:(BOOL)isTouchUp {
    [self.liveWindowPanelView seekTimeline:position];
}

#pragma mark - NvLiveWindowPanelViewDelegate
- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    [self.rangeSequenceView didPlaybackTimelinePosition:position];
}

- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.liveWindowPanelView playBackStart:self.startTime end:self.endTime];
    });
}

#pragma mark - NvCompileViewControllerDelegate
- (void)compileFinished:(BOOL)needDelete {
    if (!_timeline) {
        return;
    }
    
    [_liveWindowPanelView connectTimeline:_timeline];
    [self.liveWindowPanelView seekTimeline:_liveWindowPanelView.currentTime];
    UIImage *image = [_streamingContext grabImageFromTimeline:_timeline timestamp:self.startTime proxyScale:nil];
    UIImage *primitiveImage = [NvTimelineImageUtils imageWithTransparentPixelsAsBlack:image];
    if (primitiveImage != nil) {
        image = primitiveImage;
    }
    // 生成livephoto
    [NvLivePhotoExport exportLivePhotoWithVideoPath:self->_compileFilePath image:image timeRange:CMTimeRangeMake(CMTimeMake(_liveWindowPanelView.currentTime, NV_TIME_BASE), CMTimeMake(3*NV_TIME_BASE, NV_TIME_BASE))
                                         completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!success) {
                [NvToast showErrorWithMessage:error.localizedDescription];
            }
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            [[NSFileManager defaultManager] removeItemAtPath:self->_compileFilePath error:nil];
        });
    }];
    
}

@end
