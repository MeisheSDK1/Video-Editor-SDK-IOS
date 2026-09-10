//
//  NvAudioEqualizerViewController.m
//  SDKDemo
//
//  Created by MS on 2021/6/23.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvAudioEqualizerViewController.h"
#import "NvSDKUtils.h"
#import "NvBaseUtils.h"
#import "NvAudioEqualizerView.h"
#import "NvCompileViewController.h"
#import "UIColor+NvColor.h"
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvStreamingSdkCore/NvStreamingSdkCore.h>
@interface NvAudioEqualizerViewController ()<NvAudioEqualizerViewDelegate,NvCompileViewControllerDelegate>

/// 音频频段数组
/// audio frequence array
@property (nonatomic, copy) NSArray *frequenceArr;

/// 音频频段数组
/// audio frequence array
@property (nonatomic, copy) NSArray *frequenceContentArr;

/// 音频频段数组
/// audio frequence array
@property (nonatomic, copy) NSArray *customFrequenceContentArr;

/// 音频特效数组
/// audio fx array
@property (nonatomic, strong) NSMutableArray *audioFxArr;


/// 生成视频路径
/// the compile file path
@property (nonatomic, strong) NSString *compileFilePath;
@property (nonatomic, strong) UIButton *compileButton;
@end

@implementation NvAudioEqualizerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NvLocalStringFromTable([self class],@"Audio equalizer", @"音频均衡器");
    self.audioFxArr = [NSMutableArray array];
    [self initTimeline];
    [self addAudioEqualizerView];
    ///add the right item of navigation bar
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)leftNavButtonClick:(UIButton *)button {
    self.timeline = nil;
    [self.streamingContext clearCachedResources:NO];
    [self.streamingContext stop];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)rightNavigationBarItemView {
    self.compileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.compileButton setTitle:NvLocalStringFromTable([self class],@"Compile", @"生成") forState:UIControlStateNormal];
    [self.compileButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
    if (font) {
        self.compileButton.titleLabel.font = font;
    } else {
        UIFont *font = [UIFont systemFontOfSize:16];
        self.compileButton.titleLabel.font = font;
    }
    self.compileButton.frame = CGRectMake(0, 0, 30, 44);
    self.compileButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15*SCREENSCALE);
    [self.compileButton addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.compileButton.exclusiveTouch = YES;
    return self.compileButton;
}

- (void)rightBtnClicked {
    _compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvBaseUtils currentDateAndTime]]];
    NvCompileViewController *compileViewController = [NvCompileViewController new];
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compileTimeline:self.timeline outputPath:_compileFilePath];
}


/// 初始化时间线方法
/// initialize the timeline
- (void)initTimeline {
    self.timeline = [NvSDKUtils createTimeline:self.editMode];
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    if (!track){
        track = [self.timeline appendVideoTrack];
    }
    for (NvAlbumAsset *asset in self.selectAssets){
        if (asset.asset.mediaType == PHAssetMediaTypeVideo) {
            NvsVideoClip *clip = [track appendClip:asset.asset.localIdentifier];
            NvsAudioFx *audioFx = [clip appendAudioFx:@"Audio EQ"];
            if (audioFx) {
                [self.audioFxArr addObject:audioFx];
            }
            if (!clip) {
                NSLog(@"添加视频素材失败 Failed to add video material. Procedure");
            }
        }
    }
    
}

/// 添加音频调节界面
/// add the audio equalizer view
- (void)addAudioEqualizerView {
    CGFloat yValue = CGRectGetMaxY(self.liveWindowPanel.frame);
    
    NvAudioEqualizerView *view = [[NvAudioEqualizerView alloc] initWithFrame:CGRectMake(0, yValue, SCREENWIDTH, SCREENHEIGHT - yValue - NV_NAV_BAR_HEIGHT - NV_STATUSBARHEIGHT)];
    self.frequenceArr = @[@[@"31", @"40", @"50", @"63", @"80", @"100", @"125"],@[@"160", @"200", @"250", @"315", @"400", @"500"],@[@"630", @"800", @"1000", @"1250", @"1600", @"2000", @"2500", @"3200", @"4000"],@[@"5000", @"6300", @"8000", @"10k", @"12.5k", @"16k", @"20k", @"25k"]];
    
    self.customFrequenceContentArr = @[@"31", @"63", @"125", @"250", @"500", @"1000", @"2000", @"4000", @"8000", @"16k"];
    
    self.frequenceContentArr = @[@"31", @"40", @"50", @"63", @"80", @"100", @"125",@"160", @"200", @"250", @"315", @"400", @"500",@"630", @"800", @"1000", @"1250", @"1600", @"2000", @"2500", @"3200", @"4000",@"5000", @"6300", @"8000", @"10k", @"12.5k", @"16k", @"20k", @"25k"];

    NSArray *valArr = @[@[@0, @0, @0, @0, @0, @0, @0],@[@0, @0, @0, @0, @0, @0],@[@0, @0, @0, @0, @0, @0, @0, @0, @0],@[@0, @0, @0, @0, @0, @0, @0, @0]];
    [view configData:self.frequenceArr valueArr:valArr];
    view.delegate = self;
    [self.view addSubview:view];
    [self.liveWindowPanel hiddenVolumeButton];
}

#pragma mark - NvAudioEqualizerViewDelegate
- (void)audioEqualizerView:(NvAudioEqualizerView *)audioEqualizerView page:(NSInteger)pageNum index:(NSInteger)index endValue:(double)value {
    NSInteger item;
    if (pageNum == 4) {
        item = [self.frequenceContentArr indexOfObject:self.customFrequenceContentArr[index]];
    }else{
        item = [self itemOfPage:pageNum index:index];
    }
    
    NSString *paramStr = [NSString stringWithFormat:@"%ld Band Gain",(long)item];
    NSLog(@"输入参数 Input parameter%@ val:%f",paramStr,value);
    for (NvsAudioFx *fx in self.audioFxArr) {
        [fx setFloatVal:paramStr val:value];
    }
    [self.streamingContext stop];

    if (![self.streamingContext playbackTimeline:self.timeline startTime:[self.streamingContext getTimelineCurrentPosition:self.timeline] endTime:self.timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
        return;
    }
}

- (void)audioEqualizerViewSelectData:(NvAudioEqualizerView *)rectView contents:(NSArray *)contents values:(NSArray *)values{
    for (int i = 0; i < contents.count; i ++) {
        NSString *num = contents[i];
        NSUInteger index = [self.frequenceContentArr indexOfObject:num];
        NSString *paramStr = [NSString stringWithFormat:@"%ld Band Gain",(long)index];
        
        for (NvsAudioFx *fx in self.audioFxArr) {
            [fx setFloatVal:paramStr val:[values[i] floatValue]];
        }
        [self.streamingContext stop];

        if (![self.streamingContext playbackTimeline:self.timeline startTime:[self.streamingContext getTimelineCurrentPosition:self.timeline] endTime:self.timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
            return;
        }
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            [[NSFileManager defaultManager] removeItemAtPath:self->_compileFilePath error:nil];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            UISaveVideoAtPathToSavedPhotosAlbum(self->_compileFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        });
    }
}

//保存相册的回调
// save video callback
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"保存成功！ Save successfully");

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
