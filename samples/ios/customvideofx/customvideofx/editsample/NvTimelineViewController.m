//
//  NvTimelineViewController.m
//  customvideofx
//
//  Created by Mac-Mini on 2025/11/19.
//  Copyright © 2025 cdv. All rights reserved.
//

#import "NvTimelineViewController.h"
#import "PhotoPickerController.h"
#import "NvStreamingSdkCore.h"
#import "MyCustomVideoFx.h"

@interface NvTimelineViewController ()

@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) NvsTimeline *timeline;
@property (weak, nonatomic) IBOutlet NvsLiveWindow *livewindow;
@property (weak, nonatomic) IBOutlet UIButton *addPhotosBtn;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UISlider *saturationSlider;
@property (weak, nonatomic) IBOutlet UILabel *saturationLabel;
@property (weak, nonatomic) IBOutlet UIButton *playBackBtn;
@property (nonatomic, weak) MyCustomVideoFx* customFx;

@end

@implementation NvTimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.streamingContext = [NvsStreamingContext sharedInstanceWithFlags:NvsStreamingContextFlag_Support4KEdit];
    NvsStreamingEngineState status = [self.streamingContext getStreamingEngineState];
    self.livewindow.fillMode = NvsLiveWindowFillModePreserveAspectFit;
    self.streamingContext.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.isMovingFromParentViewController) {
        [self.streamingContext removeTimeline:self.timeline];
        [NvsStreamingContext destroyInstance];
    }
}

- (void)initTimeline:(NSArray<PHAsset *> *)assets {
    NvsAVFileInfo *info = [self.streamingContext getAVFileInfo:assets.firstObject.localIdentifier];
    NvsSize size = [info getVideoStreamDimension:0];
    NvsVideoRotation rotation = [info getVideoStreamRotation:0];
    int width = size.width;
    int height = size.height;
    if (rotation == NvsVideoRotation_90 || rotation == NvsVideoRotation_270) {
        width = size.height;
        height = size.height;
    }
    // 将宽高限制在4K内
    if (size.width / size.height > 1) {
        if (width > 3840 || height > 2160) {
            width = 3840;
            height = 2160;
        }
    } else {
        if (height > 3840 || width > 2160) {
            height = 3840;
            width = 2160;
        }
    }
    self.timeline = [self createTimeline:CGSizeMake(width, height)];
    [self.streamingContext connectTimeline:self.timeline withLiveWindow:self.livewindow];
    // 可以加在timeline上也可以加在clip上，demo先加在timeline上，如果需要原始buffer建议加在clip上。
    NvsVideoTrack *videoTrack = [self.timeline appendVideoTrack];
    for (PHAsset *asset in assets) {
        NvsVideoClip *clip = [videoTrack appendClip: asset.localIdentifier];
//        MyCustomVideoFx *customFx = [[MyCustomVideoFx alloc] init];
//        self.customFx = customFx;
//        [clip appendRawCustomFx:customFx];
    }
    MyCustomVideoFx *customFx = [[MyCustomVideoFx alloc] init];
    self.customFx = customFx;
    [self.timeline addCustomTimelineVideoFx:0 duration:self.timeline.duration customVideoFxRender:customFx];
    
    [self.streamingContext seekTimeline:self.timeline timestamp:[self.streamingContext getTimelineCurrentPosition:self.timeline] videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:0];
}

- (IBAction)addPhotos:(id)sender {
    PhotoPickerController *photoPicker = [[PhotoPickerController alloc] init];
    photoPicker.selectionMode = SelectionModeSingle;
    PhotoPickerCompletionHandler *handler = [[PhotoPickerCompletionHandler alloc] init];
    __weak typeof(self)weakSelf = self;
    handler.didFinishPicking = ^(NSArray<PHAsset *> *assets) {
        [weakSelf initTimeline:assets];
        weakSelf.addPhotosBtn.hidden = true;
    };
    handler.didCancel = ^{
        
    };
    photoPicker.completionHandler = handler;
    [self presentViewController:photoPicker animated:true completion:nil];
}

- (IBAction)playBack:(UIButton *)sender {
    if ([self.streamingContext getStreamingEngineState] != NvsStreamingEngineState_Playback) {
        int64_t currentTime = [self.streamingContext getTimelineCurrentPosition:self.timeline];
        [self.streamingContext playbackTimeline:self.timeline startTime:currentTime endTime:self.timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:true flags:0];
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        [self.streamingContext stop];
        [sender setTitle:@"Play" forState:UIControlStateNormal];
    }
}
- (IBAction)sliderChanged:(UISlider *)sender {
    int64_t currentTime = sender.value * self.timeline.duration;
    [self.streamingContext seekTimeline:self.timeline timestamp:currentTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:0];
}

- (IBAction)saturationSliderChanged:(UISlider *)sender {
    float p = [sender value] / [sender maximumValue];
    float minSatGain = [self.customFx getMinSaturationGain];
    float maxSatGain = [self.customFx getMaxSaturationGain];
    float saturationGain = minSatGain + (maxSatGain - minSatGain) * p;
    
    [self.customFx setSaturationGain:saturationGain];
    self.saturationLabel.text = [NSString stringWithFormat:@"%.2f",saturationGain];
    if ([self.streamingContext getStreamingEngineState] != NvsStreamingEngineState_Playback) {
        int64_t currentTime = self.progressSlider.value * self.timeline.duration;
        [self.streamingContext seekTimeline:self.timeline timestamp:currentTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:0];
    }
}

- (NvsTimeline *)createTimeline:(CGSize)size {
    NvsStreamingContext *context = [NvsStreamingContext sharedInstance];
    NvsVideoResolution videoEditRes;
    int width = size.width;
    int height = size.height;
    width = ((int)(width) + 3)&~3;
    height = ((int)(height) + 1)&~1;
    videoEditRes.imageWidth = width;
    videoEditRes.imageHeight = height;
    videoEditRes.imagePAR = (NvsRational){1, 1};
    NvsRational videoFps = {30, 1};
    NvsAudioResolution audioEditRes;
    audioEditRes.sampleRate = 48000;
    audioEditRes.channelCount = 2;
    audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
    NvsTimeline *timeline = [context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes];
    return timeline;
}

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    self.progressSlider.value = 1.0 * position / timeline.duration;
}

- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state {
    if (state != NvsStreamingEngineState_Playback) {
        [self.playBackBtn setTitle:@"Play" forState:UIControlStateNormal];
    } else {
        [self.playBackBtn setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

@end
