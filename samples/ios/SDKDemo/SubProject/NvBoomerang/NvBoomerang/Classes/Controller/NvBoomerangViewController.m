//
//  NvBoomerangViewController.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/12/19.
//  Copyright © 2018 meishe. All rights reserved.
//

#import "NvBoomerangViewController.h"
#import "NvBoomerangView.h"
#import "NvsStreamingContext.h"
#import "NvBoomerangPreviewViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <NvBaseCommon/UIColor+NvColor.h>
#import <NvBaseCommon/UIView+Dimension.h>
#import <NvBaseCommon/NvBaseUtils.h>
#import <NvBaseCommon/NVDefineConfig.h>

@interface NvBoomerangViewController ()<NvBoomerangViewDelegate,NvsStreamingContextDelegate>

@end

@implementation NvBoomerangViewController {
    NvBoomerangView *contentView;
    NvsStreamingContext *context;
    int cameraIndex;
    BOOL flash;
    NSString *recordPath;
    NSTimer *timer;
    int progress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    dispatch_group_t group = dispatch_group_create();
    
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    /// 检查摄像头权限
    ///Checking camera permissions
    if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {
        dispatch_group_enter(group);
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_group_leave(group);
        }];
    }
    /// 检查麦克风权限
    ///Check microphone permissions
    if (audioAuthStatus == AVAuthorizationStatusNotDetermined) {
        dispatch_group_enter(group);
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_group_leave(group);
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        [weakSelf handlePermissions];
        [weakSelf initView];
    });
}

- (void)handlePermissions {
    
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if (videoAuthStatus != AVAuthorizationStatusAuthorized ||
        audioAuthStatus != AVAuthorizationStatusAuthorized) {
        
        [self presentPermissions];
    }
}

//Register application foreground and background notification events
#pragma mark 注册应用前台后台通知事件
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification*)notification {
    if (self.navigationController.topViewController == self) {
        if ([context isCaptureDeviceBackFacing:cameraIndex]) {
            flash = !flash;
            [contentView toggleFlash:flash];
        }
        [context stopRecording];
        [context stop];
    }
}

- (void)applicationDidBecomeActive:(NSNotification*)notification {
    if (self.navigationController.topViewController == self) {
        [self startCapturePreview];
        flash = false;
        [contentView toggleFlash:flash];
    }
}

- (void)didCaptureDeviceCapsReady:(unsigned int)captureDeviceIndex{
    // 获取采集设备的能力描述
    // Get the capability description of the capture device
    NvsCaptureDeviceCapability *capability = [context getCaptureDeviceCapability:captureDeviceIndex];
    if (!capability){
        return;
    }
    
    CGPoint point = CGPointMake(0.49*contentView.liveWindow.width, contentView.liveWindow.height / 2);
    if (capability.supportAutoFocus) {
        [context startAutoFocus:point];
    }
    // If auto-exposure is supported
    if (capability.supportAutoExposure) {  // 支持自动曝光则自动曝光
        [context startAutoExposure:point];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    [contentView enableRecordBtn:YES];
    [contentView setProgress:0];
    progress = 0;
    [timer invalidate];
    [context connectCapturePreviewWithLiveWindow:contentView.liveWindow];
    context.delegate = self;
    [self startCapturePreview];
    if ([context isCaptureDeviceBackFacing:cameraIndex]) {
        [contentView enableFlash:YES];
    } else {
        [contentView enableFlash:NO];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [timer invalidate];
}

- (void)startCapturePreview {
    [context startCapturePreview:cameraIndex
                   videoResGrade:NvsVideoCaptureResolutionGradeHigh
                           flags:NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame | NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize
                     aspectRatio:nil];
}

- (void)initView {
    contentView = [[NvBoomerangView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    [self.view addSubview:contentView];
    contentView.delegate = self;
    
    cameraIndex = 0;
    flash = NO;
    context = [NvsStreamingContext sharedInstance];
    context.delegate =self;
    [context connectCapturePreviewWithLiveWindow:contentView.liveWindow];
    [context startCapturePreview:cameraIndex videoResGrade:NvsVideoCaptureResolutionGradeMedium flags:0 aspectRatio:nil];
    [contentView enableFlash:[context isCaptureDeviceBackFacing:cameraIndex]];
    progress = 0;
    [self addObservers];
}

- (void)backBtnClick {
    [context stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deviceBtnClick {
    cameraIndex = 1 - cameraIndex;
    [self startCapturePreview];
    [contentView enableFlash:[context isCaptureDeviceBackFacing:cameraIndex]];
}

- (void)flashBtnClick {
    if ([context isCaptureDeviceBackFacing:cameraIndex]) {
        flash = !flash;
        [context toggleFlash:flash];
        [contentView toggleFlash:flash];
    }
}

- (void)shootingBtnClick {
    [self startRecord];
}

- (void)didCaptureRecordingDurationUpdated:(int)captureDeviceIndex duration:(int64_t)duration {
    if (duration > NV_TIME_BASE) {
        NSLog(@"record end");
        [self stopRecord];
    }
}

- (void)startRecord {
    recordPath = [VIDEO_PATH(@"Record") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvBaseUtils currentDateAndTime]]];
    NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
    [config setValue:[NSNumber numberWithInteger:1] forKey:NVS_RECORD_GOP_SIZE];
    [context setRecordVideoBitrateMultiplier:1.5f];
    [context startRecordingWithFx:recordPath withFlags:0 withRecordConfigurations:config];
    
    [contentView enableRecordBtn:NO];
    
    timer = [NSTimer timerWithTimeInterval:.01 target:self selector:@selector(updateRecordProgress:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)stopRecord {
    [context stopRecording];
    [context stop];
    
    [contentView enableRecordBtn:YES];
    
    [contentView setProgress:0];
    progress = 0;
    [timer invalidate];
}

- (void)updateRecordProgress:(NSTimer *)timer {
    progress++;
    NSLog(@"progress: %d", progress);
    [contentView setProgress:progress];
}

- (void)presentPermissions {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NvLocalStringFromTable([self class], @"Tips", @"提示") message:NvLocalStringFromTable([self class], @"camera.microphone.permissions", @"需要打开摄像头和麦克风权限 请在手机设置中进行允许") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *skipAction = [UIAlertAction actionWithTitle:NvLocalStringFromTable([self class], @"Know", @"知道了") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertVC addAction:skipAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)didCaptureRecordingFinished:(unsigned int)captureDeviceIndex {
    if ([context isCaptureDeviceBackFacing:cameraIndex]) {
        flash = false;
    }
    [contentView toggleFlash:flash];
    NvBoomerangPreviewViewController *vc = [NvBoomerangPreviewViewController new];
    vc.videoPath = recordPath;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
