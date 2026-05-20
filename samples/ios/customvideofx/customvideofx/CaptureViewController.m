//
//  CaptureViewController.m
//  customvideofx
//
//  Created by xuewen on 8/1/17.
//  Copyright © 2017 cdv. All rights reserved.
//

#import "CaptureViewController.h"
#import "NvsStreamingContext.h"
#import "NvsLiveWindow.h"
#import "MyCustomVideoFx.h"

@interface CaptureViewController ()<NvsStreamingContextDelegate>
@property (weak, nonatomic) IBOutlet NvsLiveWindow *liveWindow;

@end

@implementation CaptureViewController
{
    unsigned int _currentDeviceIndex;
    NvsStreamingContext *_context;
    NvsRational _aspectRatio;
    MyCustomVideoFx *_myCustomVideoFx;
    __weak IBOutlet UISlider *HSL_slider;
    __weak IBOutlet UILabel *HSL_label;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _currentDeviceIndex = 0;
    
    _context = [NvsStreamingContext sharedInstance];
    if (!_context)
        return;
    
    if ([_context captureDeviceCount] == 0) {
        return;
    }
    
    if (![_context connectCapturePreviewWithLiveWindow:self.liveWindow]) {
        return;
    }
    
    _aspectRatio.den = 1;
    _aspectRatio.num = 1;
    [self startCapturePreview];
    
    _myCustomVideoFx = [[MyCustomVideoFx alloc] init];
    [_context appendCustomCaptureVideoFx:_myCustomVideoFx];
    
    [self updateSaturationGainSeekBar:[_myCustomVideoFx getSaturationGain]];
    [self updateSaturationGainText:[_myCustomVideoFx getSaturationGain]];
    
    _context.delegate = self;
    
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.isMovingFromParentViewController) {
        [NvsStreamingContext destroyInstance];
    }
}

- (void)appDidBecomeActive {
    NvsStreamingContext *streamingContext = [NvsStreamingContext sharedInstance];
    if (streamingContext) {
        if ([streamingContext getStreamingEngineState] != NvsStreamingEngineState_CapturePreview &&
            [streamingContext getStreamingEngineState] != NvsStreamingEngineState_CaptureRecording)
            [self startCapturePreview];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateSaturationGainSeekBar:(float) saturationGain
{
    NSLog(@"updateSaturationGainSeekBar:%f", saturationGain);
    float minSatGain = [_myCustomVideoFx getMinSaturationGain];
    float maxSatGain = [_myCustomVideoFx getMaxSaturationGain];
    float progress = (saturationGain - minSatGain) / (maxSatGain - minSatGain);
    [HSL_slider setValue:(int)(progress * [HSL_slider maximumValue] + 0.5f)];
}

- (void)updateSaturationGainText:(float) saturationGain
{
    NSLog(@"updateSaturationGainText:%f", saturationGain);
    [HSL_label setText:[NSString stringWithFormat:@"%.2f", saturationGain]];
}

- (IBAction)onSeekBarChanged:(id)sender {
    float p = [HSL_slider value] / [HSL_slider maximumValue];
    float minSatGain = [_myCustomVideoFx getMinSaturationGain];
    float maxSatGain = [_myCustomVideoFx getMaxSaturationGain];
    float saturationGain = minSatGain + (maxSatGain - minSatGain) * p;
    [_myCustomVideoFx setSaturationGain:saturationGain];
    [self updateSaturationGainText:saturationGain];
}

- (void)startCapturePreview
{
    NvsStreamingContext *streamingContext = [NvsStreamingContext sharedInstance];
    // Start the acquisition preview, since our sample program needs to perform the color suction operation on the captured video
    // 启动采集预览，由于我们的示例程序需要对采集的视频进行颜色吸取操作
    // So we need to use NvsStreamingEngineCaptureFlag_GrabCapturedVideoFrame flag
    // 因此我们需要使用NvsStreamingEngineCaptureFlag_GrabCapturedVideoFrame标志
    [streamingContext startCapturePreview:0
                            videoResGrade:NvsVideoCaptureResolutionGradeHigh
                                    flags:NvsStreamingEngineCaptureFlag_GrabCapturedVideoFrame
                              aspectRatio:nil];
}

@end
