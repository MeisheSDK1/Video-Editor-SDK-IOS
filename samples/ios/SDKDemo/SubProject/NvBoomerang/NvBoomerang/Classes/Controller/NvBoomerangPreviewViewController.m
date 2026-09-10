//
//  NvBoomerangPreviewViewController.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/12/19.
//  Copyright © 2018 meishe. All rights reserved.
//

#import "NvBoomerangPreviewViewController.h"
#import "NvBoomerangPreviewView.h"
#import <NvBaseCommon/NvBaseUtils.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvStreamingSdkCore/NvsStreamingContext.h>
#import <NvStreamingSdkCore/NvsVideoTrack.h>
#import <NvStreamingSdkCore/NvsAudioTrack.h>
#import "NvBoomerang.h"
#import <NvSDKCommon/NvCompileViewController.h>

@interface NvBoomerangPreviewViewController ()<NvBoomerangPreviewViewDelegate, NvsStreamingContextDelegate, NvCompileViewControllerDelegate>
// Generate path
@property (nonatomic, strong) NSString *compileFilePath;//生成路径

@end

@implementation NvBoomerangPreviewViewController {
    NvBoomerangPreviewView *contentView;
    NvsStreamingContext *context;
    NvsTimeline *timeline;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    
    context = [NvsStreamingContext sharedInstance];
    context.delegate = self;
    timeline = [NvBoomerang createTimeline:self.videoPath];
    [context connectTimeline:timeline withLiveWindow:contentView.liveWindow];
    [context playbackTimeline:timeline startTime:0 endTime:timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    [videoTrack setVolumeGain:0 rightVolumeGain:0];
    NvsAudioTrack *audioTrack = [timeline getAudioTrackByIndex:0];
    [audioTrack setVolumeGain:0 rightVolumeGain:0];
    [self addObservers];
}
//Register application foreground and background notification events
#pragma mark 注册应用前台后台通知事件
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification*)notification {
    if (self.navigationController.topViewController == self) {
        [context stopRecording];
        [context stop];
    }
}

- (void)applicationDidBecomeActive:(NSNotification*)notification {
    if (self.navigationController.topViewController == self) {
        [context playbackTimeline:timeline startTime:0 endTime:timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initView {
    contentView = [[NvBoomerangPreviewView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    [self.view addSubview:contentView];
    contentView.delegate = self;
}

- (void)backBtnClick {
    [context stop];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    [context playbackTimeline:timeline startTime:0 endTime:timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}

- (void)exportBtnClick {
    NSLog(@"=====>%lld",timeline.duration);
    self.compileFilePath = [VIDEO_PATH(@"Boomerang") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvBaseUtils currentDateAndTime]]];
    NvCompileViewController *compileViewController = [NvCompileViewController new];
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compileTimeline:timeline outputPath:self.compileFilePath];

}

- (void)compileFinished:(BOOL)needDelete {
    [context connectTimeline:timeline withLiveWindow:contentView.liveWindow];
    [context playbackTimeline:timeline startTime:0 endTime:timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
    if (needDelete) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:self.compileFilePath error:nil];
        });
    } else {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
            [self tipView];
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            UISaveVideoAtPathToSavedPhotosAlbum(self.compileFilePath, self, nil, nil);
        });
    }
    
}

- (void)didCompileProgress:(NvsTimeline *)timeline progress:(int)progress {
    contentView.status = NV_GENERATING;
}

- (void)didCompileFinished:(NvsTimeline *)timeline {
    contentView.status = NV_GENERATED;
    [context playbackTimeline:timeline startTime:0 endTime:timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}

- (void)didCompileFailed:(NvsTimeline *)timeline {
    contentView.status = NV_NOT_BEGIN;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)tipView{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NvLocalStringFromTable([self class], @"Save failed", @"保存失败") message:NvLocalStringFromTable([self class], @"Album permissions", @"您还没有允许相册访问权限") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *skipAction = [UIAlertAction actionWithTitle:NvLocalStringFromTable([self class], @"Know", @"知道了") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
      
    }];
    
    [alertVC addAction:skipAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
    
}

@end
