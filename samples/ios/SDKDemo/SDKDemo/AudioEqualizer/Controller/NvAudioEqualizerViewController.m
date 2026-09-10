//
//  NvAudioEqualizerViewController.m
//  SDKDemo
//
//  Created by 董凌晓 on 2021/6/23.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvAudioEqualizerViewController.h"
#import "NvTimelineUtils.h"
#import "NvAudioEqualizerView.h"
#import "NvCompileViewController.h"
@interface NvAudioEqualizerViewController ()<NvAudioEqualizerViewDelegate,NvCompileViewControllerDelegate>
@property (nonatomic, strong) NvsAudioFx *audioFx;
@property (nonatomic, copy) NSArray *frequenceArr;
@property (nonatomic, strong) NSMutableArray *audioFxArr;
@property (nonatomic, strong) NSString *compileFilePath;
@end

@implementation NvAudioEqualizerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NvLocalString(@"Audio equalizer", @"音频均衡器");
    self.audioFxArr = [NSMutableArray array];
    [self initTimeline];
    [self addAudioEqualizerView];
    
    self.liveWindowPanel.liveWindow.hdrDisplayMode = NvsLiveWindowHDRDisplayMode_SDR;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:NvLocalString(@"Compile", @"生成") style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnClicked)];
    [rightButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NvUtils fontWithSize:16], NSFontAttributeName, [UIColor nv_colorWithHexRGB:@"#4A90E2"], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)leftNavButtonClick:(UIButton *)button {
    self.timeline = nil;
    [self.streamingContext clearCachedResources:NO];
    [self.streamingContext stop];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBtnClicked {
    _compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NvCompileViewController *compileViewController = [NvCompileViewController new];
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compileTimeline:self.timeline outputPath:_compileFilePath];
}

- (void)initTimeline {
    self.timeline = [NvTimelineUtils createTimelineOrdinary:self.editMode];
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    if (!track){
        track = [self.timeline appendVideoTrack];
    }
    for (NvAlbumAsset *asset in self.selectAssets){
        if (asset.asset.mediaType == PHAssetMediaTypeVideo) {
            NvsVideoClip *clip = [track appendClip:asset.asset.localIdentifier];
            [clip setVolumeGain:0 rightVolumeGain:0];
            if (!clip) {
                NSLog(@"添加视频素材失败");
            }
        }
    }

    NvsAudioTrack *audioTrack = [self.timeline getAudioTrackByIndex:0];
    if (!audioTrack){
        audioTrack = [self.timeline appendAudioTrack];
    }
    for (NvAlbumAsset *asset in self.selectAssets){
        if (asset.asset.mediaType == PHAssetMediaTypeVideo) {
            NvsAudioClip *clip = [audioTrack appendClip:asset.asset.localIdentifier];
            NvsAudioFx *audioFx = [clip appendFx:@"Audio EQ"];
            [self.audioFxArr addObject:audioFx];
            if (!clip) {
                NSLog(@"添加视频素材失败");
                
            }
        }
    }
}

- (void)addAudioEqualizerView {
    CGFloat yValue = CGRectGetMaxY(self.liveWindowPanel.frame);
    
    NvAudioEqualizerView *view = [[NvAudioEqualizerView alloc] initWithFrame:CGRectMake(0, yValue, SCREENWIDTH, SCREENHEIGHT - yValue - NV_NAV_BAR_HEIGHT - NV_STATUSBARHEIGHT)];
    self.frequenceArr = @[@[@"31", @"40", @"50", @"63", @"80", @"100", @"125"],@[@"160", @"200", @"250", @"315", @"400", @"500"],@[@"630", @"800", @"1000", @"1250", @"1600", @"2000", @"2500", @"3200", @"4000"],@[@"5000", @"6300", @"8000", @"10k", @"12.5k", @"16k", @"20k", @"25k"]];

    NSArray *valArr = @[@[@0, @0, @0, @0, @0, @0, @0],@[@0, @0, @0, @0, @0, @0],@[@0, @0, @0, @0, @0, @0, @0, @0, @0],@[@0, @0, @0, @0, @0, @0, @0, @0]];
    [view configData:self.frequenceArr valueArr:valArr];
    view.delegate = self;
    [self.view addSubview:view];
    
}

- (void)audioEqualizerView:(NvAudioEqualizerView *)audioEqualizerView page:(NSInteger)pageNum index:(NSInteger)index endValue:(double)value {
    NSInteger item = [self itemOfPage:pageNum index:index];
    NSString *paramStr = [NSString stringWithFormat:@"%ld Band Gain",(long)item];
    NSLog(@"输入参数%@ val:%f",paramStr,value);
    for (NvsAudioFx *fx in self.audioFxArr) {
        [fx setFloatVal:paramStr val:value];
    }
    [self.streamingContext stop];

    if (![self.streamingContext playbackTimeline:self.timeline startTime:[self.streamingContext getTimelineCurrentPosition:self.timeline] endTime:self.timeline.duration videoSizeMode:NvsVideoPreviewSizeModeFullSize preload:YES flags:0]) {
        NSLog(@"播放时间线失败！");
        return;
    }
}

- (NSInteger)itemOfPage:(NSInteger)pageNum index:(NSInteger)index {
    NSInteger item = 0;
    if(pageNum>0){
        for (NSInteger i=0; i<pageNum; i++) {
            NSArray *tmp = self.frequenceArr[i];
            item += tmp.count;
        }
    }
    item += index;
    item += 1;
    return item;
}

#pragma mark - NvCompileViewControllerDelegate
- (void)compileFinished:(BOOL)needDelete {
    [self.liveWindowPanel connectTimeline:self.timeline];
    if (needDelete) {
        [[NSFileManager defaultManager] removeItemAtPath:_compileFilePath error:nil];
    } else {
        UISaveVideoAtPathToSavedPhotosAlbum(_compileFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}

//保存相册的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"保存成功！");

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
