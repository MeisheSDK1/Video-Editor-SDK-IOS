//
//  NvShortVideoCaptureViewController.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/8/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvShortVideoCaptureViewController.h"
#import "NvShortVideoCaptureView.h"
#import "NVHeader.h"
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import "NVDefineConfig.h"
#import "UIView+Dimension.h"
#import "NvShortVideoEditViewController.h"
#import "NvTimelineDataModel.h"
#import "NvTimelineData.h"
#import "NvAudioPlayer.h"
#import "NvRecordingInfo.h"
#import "NvsCaptureVideoFx.h"
#import "NvMoreFilterViewController.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import <NvSDKCommon/NvAssetManager.h>
#import <UIImageView+YYWebImage.h>
#import "NvTimelineUtils.h"

#import "NvBeautyLogic.h"
#import "NvShortVideoBeautyView.h"
#import "NvAlbumViewController.h"
#import "NvTrimVideoViewController.h"
#import "NvSelectMusicViewController.h"
#import <NvSDKCommon/NvBaseNavigationController.h>
#import "NvCountDownView.h"
#import "NvCountDownAnimationView.h"
#import "NvsStreamingContext.h"
#import "NvCaptureFilterView.h"
#import "NvCaptureFilterModel.h"
#import "NvCapturePropsModel.h"
#import "NvFilterUsageUtil.h"
@interface NvShortVideoCaptureViewController ()<NvsStreamingContextDelegate, NvShortVideoCaptureViewDelegate, NvShortVideoCaptureViewDelegate,NvSelectMusicViewControllerDelegate,NvCountDownAnimationViewDelegate,NvCaptureFilterViewDelegate>

@property (nonatomic, assign) float trimIn;
@property (nonatomic, assign) float trimOut;
@property (nonatomic, assign) BOOL isNoMusic;

@property (nonatomic, strong) NvCaptureFilterView *filterView;
@property (nonatomic, strong) NvAssetManager *assetManager;
///滤镜数组
///Filter array
@property (nonatomic, strong) NSMutableArray *filterDataSource;
///滤镜
///filter
@property (nonatomic, strong) NvsCaptureVideoFx *currentFilter;

///道具视图
///Prop view
@property (nonatomic, strong) NvCaptureFilterView  *propsView;
///当前道具
///Current item
@property (nonatomic, strong) NvCapturePropsModel *currentPropsModel;
///道具数组
///Current item item array
@property (nonatomic, strong) NSMutableArray *propsDataSource;

///摄像头的能力
///Camera capability
@property (nonatomic, strong) NvsCaptureDeviceCapability *capability;

@property (nonatomic, assign) BOOL isNeedGopSize;

@property (nonatomic, strong) NvAudioPlayer *player;

@property (nonatomic, strong) NvBeautyLogic *beautyLogic;
@property (nonatomic, strong) NvShortVideoBeautyView *beautyView;

@property (nonatomic, strong) NvCountDownView *countDownView;

@property (nonatomic, strong) NvCountDownAnimationView *animationView;

@property (nonatomic, assign) int64_t countDownTime;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation NvShortVideoCaptureViewController {
    NvShortVideoCaptureView *captureView;
    NvsStreamingContext *streamingContext;
    NvsLiveWindow *liveWindow;
    int currentDeviceIndex;
    NSMutableArray *videoPathArray;
    NSString *musicPath;
    float recordingSpeed;
}

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
    [streamingContext removeAllCaptureVideoFx];
    [captureView removeObserver:self forKeyPath:@"recordingProgress.getCount"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    streamingContext = [NvsStreamingContext sharedInstance];
    self.propsDataSource = [NSMutableArray array];
    self.beautyLogic = [[NvBeautyLogic alloc] init];
    ///初始化数据
    ///Initialize data
    [self initData];
    ///初始化播放器
    ///Initialize the player
    [self initPlayer];
    ///初始化滤镜视图
    ///Initializes the filter view
    [self initFilterView];
    ///请求权限
    ///Request permission
    [self checkAuth];
    [self prefersStatusBarHidden];
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    self.beautyView = [[NvShortVideoBeautyView alloc] init];
    self.beautyView.delegate = self;
    [self.view addSubview:self.beautyView];
    [self.beautyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    self.beautyView.hidden = YES;
    self.countDownView = [[NvCountDownView alloc] initWithFrame:CGRectZero];
    self.countDownView.delegate = self;
    [self.view addSubview:self.countDownView];
    [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
    }];
    self.countDownView.hidden = YES;
    [self addPropsView];
}

#pragma mark 初始化数据
//Initialization data
- (void)initData {
    self.filterDataSource = [NSMutableArray array];
    self.assetManager = [NvAssetManager sharedInstance];
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"filter" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_FILTER bundlePath:itemPath];
    musicPath = @"";
    self.isNoMusic = YES;
    recordingSpeed = 1;
    self.countDownTime = 15*NV_TIME_BASE;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"recordingProgress.getCount"]) {
        NSUInteger count = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        if (count == 0) {
            //如果录制的没有有数据
            //count is zero
            captureView->deleteBtn.hidden = YES;
            captureView->nextBtn.hidden = YES;
            captureView.album.hidden = NO;
            captureView.selectMusic.userInteractionEnabled = YES;
            [captureView.selectMusic setTitleColor:[UIColor nv_colorWithHexRGB:@"#FFFFFF"] forState:UIControlStateNormal];
            [captureView.selectMusic setImage:NvImageNamed(@"NvSelectMusic") forState:UIControlStateNormal];
        } else {
            //如果录制的有数据
            //count is not zero
            captureView->deleteBtn.hidden = NO;
            captureView->nextBtn.hidden = NO;
            captureView.album.hidden = YES;
            captureView.selectMusic.userInteractionEnabled = NO;
            if (musicPath == nil || [musicPath isEqualToString:@""]) {
                [captureView.selectMusic setTitleColor:[UIColor nv_colorWithHexRGB:@"#FFFFFF"] forState:UIControlStateNormal];
                [captureView.selectMusic setImage:NvImageNamed(@"NvSelectMusic") forState:UIControlStateNormal];
            } else {
                [captureView.selectMusic setImage:NvImageNamed(@"NvMusicRecorded") forState:UIControlStateNormal];
                [captureView.selectMusic setTitleColor:[UIColor nv_colorWithHexRGB:@"#F8E71C"] forState:UIControlStateNormal];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    streamingContext.delegate = self;
    if ([streamingContext getStreamingEngineState] != NvsStreamingEngineState_CapturePreview)
        [self startCapturePreview];

    [self updateFilters];
    if (!self.propsView.hidden) {
        [self updateFaceStickers];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
   
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark 请求权限
//check and requst the permission of capture
- (void)checkAuth {
    __weak typeof(self)weakSelf = self;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
                if (audioAuthStatus == AVAuthorizationStatusNotDetermined) {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                        if (granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf startupCapture];
                            });
                        } else {
                            // 提示麦克风权限未获得
                            // Prompt microphone permission not obtained
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf startupCapture];
                                [weakSelf presentPermissions];
                            });
                        }
                    }];
                }
            } else {
                // 提示摄像头权限未获得
                // prompt that the camera permission is not obtained
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf presentPermissions];
                });
            }
        }];
    } else if (authStatus == AVAuthorizationStatusDenied) {
        // 提示摄像头权限未获得
        // prompt that the camera permission is not obtained
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf presentPermissions];
        });
    } else {
        // 检查麦克风权限
        // Check microphone permissions
        authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (authStatus == AVAuthorizationStatusDenied) {
            // 提示麦克风权限未获得
            // Prompt microphone permission not obtained
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf presentPermissions];
            });
        }
        [weakSelf startupCapture];
    }
}

#pragma mark 初始化音乐播放器
//Initialize audio player
- (void)initPlayer {
    self.player = [NvAudioPlayer new];
    self.player.delegate = self;
    [self.player setUrlString:musicPath];
    self.trimOut = self.player.duration;
    
    NvEditSelectMusicItem *item = NvEditSelectMusicItem.new;
    item.musicName = @"";
    item.musicPath = musicPath;
    item.duration = self.player.duration;
}

#pragma mark 初始化滤镜视图
//Initialize filter view
- (void)initFilterView {
    
    CGRect frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, KScale6s(200) + INDICATOR);
    self.filterView = [[NvCaptureFilterView alloc] initWithFrame:frame HaveTopView:YES WithTopViewHeight:50 * SCREENSCALE withMore:YES withlayout:nil];
    self.filterView.delegate = self;
    [self.view addSubview:self.filterView];
    NSArray *videoFxArray = @[@"NvsFilterNone"];
    NSArray *videoFxDisplayArray = @[NvLocalString(@"None", @"无")];
    for (int i = 0; i<videoFxArray.count; i++) {
        NvCaptureFilterModel *model = [[NvCaptureFilterModel alloc]init];
        model.selected = NO;
        model.displayName = videoFxDisplayArray[i];
        model.coverName = videoFxArray[i];
        [self.filterDataSource addObject:model];
    }
    [self updateFilters];
    
}

/*
 更新滤镜界面数据
 update the data of filterView
 */
- (void)updateFilters {
    NSArray *array = [self.assetManager getUsableAssets:ASSET_FILTER aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    for (NvAsset *asset in array) {
        if ([self isFilterExist:asset.uuid]){
            continue;
        }
        if ([asset isReserved] && [asset isSupportCapture]) {
            NvCaptureFilterModel *filter = [[NvCaptureFilterModel alloc]init];
            [self initReservedAssetName:asset];
            if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
                filter.displayName = asset.displayNamezhCN;
            }else{
                filter.displayName = asset.displayName;
            }
            filter.coverName = asset.coverUrl;
            filter.size = [NvSDKUtils getAssetPackageSizeString:asset.packageSize];
            filter.draw = [NvSDKUtils getAssetAspectRatioString:asset.aspectRatio];
            filter.packageId = asset.uuid;
            [_filterDataSource insertObject:filter atIndex:1];
        }
    }
    for (NvAsset *asset in array) {
        if ([self isFilterExist:asset.uuid]){
            continue;
        }
        if (![asset isReserved] && [asset isSupportCapture]                  ) {
            NvCaptureFilterModel *filter = [[NvCaptureFilterModel alloc]init];
            if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
                filter.displayName = asset.displayNamezhCN;
                    }else{
                        filter.displayName = asset.displayName;
                    }
            filter.coverName = asset.coverUrl;
            filter.size = [NvSDKUtils getAssetPackageSizeString:asset.packageSize];
            filter.draw = [NvSDKUtils getAssetAspectRatioString:asset.aspectRatio];
            filter.packageId = asset.uuid;
            [_filterDataSource insertObject:filter atIndex:1];
        }
    }
    
    [self.filterView configDataSource:self.filterDataSource];
}

#pragma mark - NvCaptureFilterViewDelegate
- (void)NvCaptureFilterView:(NvCaptureFilterView *)view withFilterModel:(NvBaseModel *)model{
    if ([view isEqual:self.filterView]) {
        if (model.builtinName) {
            if ([self.currentFilter.bultinCaptureVideoFxName isEqualToString:model.builtinName]) {
                return;
            }
            if (self.currentFilter) {
                [streamingContext removeCaptureVideoFx:self.currentFilter.index];
                self.currentFilter = nil;
            }
            self.currentFilter = [streamingContext appendBuiltinCaptureVideoFx:model.builtinName];
        } else if (model.packageId) {
            if ([self.currentFilter.captureVideoFxPackageId isEqualToString:model.packageId]) {
                return;
            }
            if (self.currentFilter) {
                [streamingContext removeCaptureVideoFx:self.currentFilter.index];
                self.currentFilter = nil;
            }
            self.currentFilter = [NvFilterUsageUtil appendPackagedCaptureVideoFx:model.packageId];
        } else {
            if (self.currentFilter) {
                [streamingContext removeCaptureVideoFx:self.currentFilter.index];
                self.currentFilter = nil;
            }
        }
    }else if([view isEqual:self.propsView]){
        self.currentPropsModel = (NvCapturePropsModel *)model;
        NSString *tipString = [streamingContext.assetPackageManager getARSceneAssetPackagePrompt:model.packageId];
        if (tipString.length>0) {
            [NvToast showInfoWithMessage:tipString];
        }
        [self.beautyLogic setFaceOrnament:model.packageId];
    }
}

- (void)NvCaptureFilterView:(NvCaptureFilterView *)view sliderValueChanged:(UISlider *)slider{
    [self.currentFilter setFilterIntensity:slider.value];
}

- (void)NvCaptureFilterView:(NvCaptureFilterView *)view moreClick:(UIButton *)sender{
    if ([view isEqual:self.filterView]) {
        NvMoreFilterViewController *vc = [[NvMoreFilterViewController alloc]init];
        vc.type = ASSET_FILTER;
        vc.categoryId = 2;
        vc.kind = NV_KIND_ID_ALL;
        vc.isCapture = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([view isEqual:self.propsView]){
        NvMoreFilterViewController *vc = [[NvMoreFilterViewController alloc]init];
        vc.type = ASSET_ARSCENE;
        vc.categoryId = NV_CATEGORY_ID_ALL;
        vc.kind = NV_KIND_ID_ALL;
        vc.isCapture = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadArsenceFinish) name:DOLOADPACKAGEFINISH object:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/*
 下载道具完成
 the downloading of arscene asset is done
 */
-(void)downLoadArsenceFinish{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateFaceStickers];
    });
}

/*
 判断是否已存在该滤镜
 check whether the filterDataSource already contain the filter asset or not
 
 @param uuid 滤镜的uuid
 the uuid of filter asset
 */
- (BOOL)isFilterExist:(NSString *)uuid {
    for (NvCaptureFilterModel *item in _filterDataSource) {
        if ([item.packageId isEqualToString:uuid])
            return YES;
    }
    return NO;
}

/*
 初始化预装素材
 Initialize pre installed asset
 
 @param asset 预装素材
 the pre installed asset
 */
- (void)initReservedAssetName:(NvAsset *)asset {
    if ([asset isReserved]) {
        
        if ([asset.uuid isEqualToString:@"0FBCC8A1-C16E-4FEB-BBDE-D04B91D98A40"]) {
            asset.displayName = NvLocalString(@"Fair",@"白皙");
        }
        if ([asset.uuid isEqualToString:@"6439CF7E-42D5-4239-8187-358323292FF4"]) {
            asset.displayName = NvLocalString(@"Ice Cream",@"冰激凌");
        }
        if ([asset.uuid isEqualToString:@"FAE50247-F14C-40CE-AD43-29CA3E604838"]) {
            asset.displayName = NvLocalString(@"Morning Sunlight LUT",@"晨曦");
        }
        if ([asset.uuid isEqualToString:@"BD9D5DA9-581E-4B80-95D4-218D95FC78F2"]) {
            asset.displayName = NvLocalString(@"Wind Whispers",@"风语");
        }
        if ([asset.uuid isEqualToString:@"394EB525-1B7A-4AA1-BBAD-3FD75527A60C"]) {
            asset.displayName = NvLocalString(@"B&W 2",@"黑白");
        }
        if ([asset.uuid isEqualToString:@"D1C01CF7-CA73-4CB7-A6B7-630B5FF9EC74"]) {
            asset.displayName = NvLocalString(@"ziran",@"自然");
        }
        if ([asset.uuid isEqualToString:@"12FCD2E7-1F80-4DFC-A8FD-C820CF754855"]) {
            asset.displayName = NvLocalString(@"ins Reyes LUT",@"雷耶斯");
        }
        if ([asset.uuid isEqualToString:@"D65436B7-D19F-47E0-9A2A-28CECC73D4F2"]) {
            asset.displayName = NvLocalString(@"Honey peach",@"蜜桃");
        }
        if ([asset.uuid isEqualToString:@"B7F1F498-B310-4E2D-9A75-7D8AFBBC71D8"]) {
            asset.displayName = NvLocalString(@"Chelsea LUT",@"切尔西");
        }
        if ([asset.uuid isEqualToString:@"C9CE10F1-7C77-423C-BB7F-7F090C33D5C5"]) {
            asset.displayName = NvLocalString(@"Youth",@"青春");
        }
        if ([asset.uuid isEqualToString:@"F7204261-41D8-454A-99DC-3522444739EB"]) {
            asset.displayName = NvLocalString(@"ins Jaipur",@"斋普尔");
        }
        if ([asset.uuid isEqualToString:@"E1202F90-F2C8-4A14-BFCB-8F62BBD72F56"]) {
            asset.displayName = NvLocalString(@"Tsukiji",@"筑地");
        }
    }
}

#pragma mark - 拍摄准备工作
/*
 拍摄准备工作
 Preparations for capture
 */
- (void)startupCapture {
    if (!streamingContext) {
        return;
    }
    
    streamingContext.delegate = self;
    
    if ([streamingContext captureDeviceCount] == 0) {
    }
    
    liveWindow = [[NvsLiveWindow alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [self.view addSubview:liveWindow];

    if (![streamingContext connectCapturePreviewWithLiveWindow:liveWindow]) {
    }
    
    currentDeviceIndex = [self frontCameraDeviceIndex];
    if (![self startCapturePreview]) {
    }
    
    captureView = [[NvShortVideoCaptureView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:captureView];
    captureView.delegate = self;
    [liveWindow addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLiveWindow:)]];
    //有录制视频时不能点击裁剪音乐
    //can not click the button of cutting music while recording video
    [captureView addObserver:self forKeyPath:@"recordingProgress.getCount" options:NSKeyValueObservingOptionNew context:nil];
    captureView->deleteBtn.hidden = YES;
    captureView->nextBtn.hidden = YES;
    
    [self.beautyLogic startBeauty];
}

- (void)presentPermissions {
    
    NVWeakSelf
    [UIAlertController presentAlertFromVC:self
                                    title:NvLocalString(@"Tips", @"提示")
                                  message:NvLocalString(@"camera.microphone.permissions", @"需要打开摄像头和麦克风权限 请在手机设置中进行允许")
                        buttonTitleColors:nil
                        cancelButtonTitle:nil
                         otherButtonTitle:NvLocalString(@"Know", @"知道了")
                       cancelButtonAction:nil
                        otherButtonAction:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

/*
 点击livewindow 手势方法
 the method of tap gesture on livewindow
 */
- (void)tapLiveWindow:(UITapGestureRecognizer *)ges {
    if(self.animationView != nil) {
        return;
    }
    
    captureView.hidden = NO;
    //隐藏滤镜
    //hide the filter view
    [UIView animateWithDuration:0.2 animations:^{
        self.filterView.frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 200 * SCREENSCALE + INDICATOR);
    } completion:NULL];
    //隐藏美颜控制板
    //hide the beauty view
    if (self.beautyView.hidden == NO) {
        self.beautyView.hidden = YES;
    }
    //隐藏倒计时控制板
    //hide the count down view
    if (self.countDownView.hidden == NO) {
        self.countDownView.hidden = YES;
    }
    if (!self.propsView.hidden) {
        captureView.hidden = NO;
        [UIView animateWithDuration:0.1 animations:^{
            self.propsView.frame = CGRectMake(0, SCREENHEIGHT - self.propsView.frame.size.height, SCREENWIDTH, self.propsView.frame.size.height);
            self.propsView.hidden = YES;
        }];
    }
}

#pragma mark NvShortVideoBeautyViewDelegate

/**
 @param type type 0为磨皮，1为大眼，2为瘦脸
 type 0 means "Beauty Strength", 1 means "Eye Size Warp Degree", 2 means "Face Size Warp Degree"
 */
- (void)slider:(int)type valueChanged:(float)value {
    if (type == 0) {
        self.beautyLogic.strength = value;
    } else if (type == 1) {
        self.beautyLogic.eyeEnlarging = value;
    } else if (type == 2) {
        self.beautyLogic.cheekThinning = value;
    }
}

#pragma mark 启动摄像头采集预览
/*
 启动摄像头采集预览
 startCapturePreview
 */
- (BOOL)startCapturePreview {
    NSNumber *num = NV_UserInfo(@"NvRecordResolution");
    NvsVideoCaptureResolutionGrade captureResGrade = [num intValue] == 1080? NvsVideoCaptureResolutionGradeHigh:NvsVideoCaptureResolutionGradeMedium;
    if (![streamingContext isCaptureDeviceBackFacing:currentDeviceIndex]){
        captureResGrade = NvsVideoCaptureResolutionGradeHigh;
    }
    CGPoint point = CGPointMake(0.49*SCREENWIDTH, 0.49*SCREENHEIGHT);
    if (self.capability.supportAutoFocus) {
        [streamingContext startAutoFocus:point];
    }
    
    if (self.capability.supportAutoExposure) {
        [streamingContext startAutoExposure:point];
    }
    
    return [streamingContext startCapturePreview:currentDeviceIndex
                                   videoResGrade:captureResGrade
                                           flags:NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame | NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize
                                     aspectRatio:nil];
}

#pragma mark 选择音乐点击
/*
 选择音乐点击
 click the button to select music
 */
- (void)selectMusicClick {
    NvSelectMusicViewController *selectMusic = NvSelectMusicViewController.new;
    selectMusic.delegate = self;
    selectMusic.hiddenTrimButton = YES;
    [selectMusic showCutHandleImage];
    [self.navigationController pushViewController:selectMusic animated:YES];
}

#pragma mark 道具点击
/*
 道具点击
 click the button of props
 */
- (void)propsBtnClicked {
    if (self.beautyLogic.enAbleAI) {
        [self updateFaceStickers];
        captureView.hidden = YES;
        self.propsView.hidden = NO;
        [self.view bringSubviewToFront:self.propsView];
        [UIView animateWithDuration:0.1 animations:^{
            self.propsView.frame = CGRectMake(0, SCREENHEIGHT - self.propsView.frame.size.height, SCREENWIDTH, self.propsView.frame.size.height);
        }];
    } else {
        [self showTip];
    }
}

/*
 提示没有人脸授权
 Prompt no face authorization
 */
- (void)showTip {
    [self presentAlertInfo:NvLocalString(@"authorization", @"请移步官网，联系商务人员索要有人脸识别授权")];
}

#pragma mark 获取前置摄像头
/*
 get the index of front camera device
 */
- (unsigned int)frontCameraDeviceIndex {
    for (unsigned int i = 0; i < streamingContext.captureDeviceCount; i++) {
        if (![streamingContext isCaptureDeviceBackFacing:i])
            return i;
    }
    return streamingContext.captureDeviceCount - 1;
}

#pragma mark 获取后置摄像头
/*
 get the index of back camera device
 */
- (unsigned int)backCameraDeviceIndex {
    for (unsigned int i = 0; i < streamingContext.captureDeviceCount; i++) {
        if ([streamingContext isCaptureDeviceBackFacing:i])
            return i;
    }
    return 0;
}

#pragma mark 添加道具视图
/*
 add the props view
 */
- (void)addPropsView{
    CGRect frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 123 * SCREENSCALE + INDICATOR);
    if (![NvUtils currentLanguagesIsChinese]) {
        frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 148 * SCREENSCALE + INDICATOR);
    }
    self.propsView = [[NvCaptureFilterView alloc] initWithFrame:frame HaveTopView:NO WithTopViewHeight:0 withMore:YES withlayout:nil];
    self.propsView.type = ASSET_ARSCENE;
    self.propsView.delegate = self;
    [self.view addSubview:self.propsView];
    
    //MARK:初始化道具数据
    //initials the data of props
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"face1sticker" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_ARSCENE bundlePath:itemPath];
    [self.assetManager searchLocalAssets:ASSET_ARSCENE];
    
    NvCapturePropsModel *propsModel = [NvCapturePropsModel new];
    propsModel.selected = NO;
    propsModel.coverName = @"NvsFilterNone";
    [self.propsDataSource addObject:propsModel];
    
    [self updateFaceStickers];
}

/*
 是否已存在该人脸贴纸
 check whether the propsDatasource already containe the sticker asset
 
 @param uuid 该人脸贴纸素材的uuid
 the uuid of sticker asset
 */
- (BOOL)isFaceStickerExist:(NSString *)uuid {
    for (NvCapturePropsModel *item in _propsDataSource) {
        if ([item.packageId isEqualToString:uuid])
            return YES;
    }
    return NO;
}

/*
 更新人脸贴纸
 update the elements of propsDataSource
 */
- (void)updateFaceStickers {
    NSArray *array = [self.assetManager getUsableAssets:ASSET_ARSCENE aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    for (NvAsset *asset in array) {
        if ([self isFaceStickerExist:asset.uuid])
            continue;
        NvCapturePropsModel *filter = NvCapturePropsModel.new;
        filter.coverName = asset.coverUrl;
        filter.size = [NvSDKUtils getAssetPackageSizeString:asset.packageSize];
        filter.draw = [NvSDKUtils getAssetAspectRatioString:asset.aspectRatio];
        filter.packageId = asset.uuid;
        filter.categoryId = asset.category;
        if (asset.isReserved) {
            ///先加预装素材,放在后面
            ///Add the preloaded material first, put it in the back
            [_propsDataSource insertObject:filter atIndex:_propsDataSource.count];
            if ([filter.packageId isEqualToString:@"00C96B57-3E1E-4E3D-A4D8-D1E3BB3589BA"]) {
                filter.categoryId = 2;//3D
            } else if ([filter.packageId isEqualToString:@"233C8731-7D9E-4D6D-85B6-87D104FC3CCF"]) {
                filter.categoryId = 2;//3D
            } else if ([filter.packageId isEqualToString:@"7269C2C7-6249-4ABF-9329-325898DAD9E6"]) {
                filter.categoryId = 1;//2D
            } else if ([filter.packageId isEqualToString:@"11526CF9-BFA0-4A19-B7B2-1A879CF58FF1"]) {
                filter.categoryId = 2;//3D
            } else if ([filter.packageId isEqualToString:@"B2187FB5-A8B3-4E87-A5CD-F8EA6B3456D4"]) {
                filter.categoryId = 2;//3D
            } else if ([filter.packageId isEqualToString:@"7242B80E-A804-4CB5-B7DD-DFACC1B6BF6F"]) {
                filter.categoryId = 2;//3D
            } else if ([filter.packageId isEqualToString:@"DD133FD6-75F4-4584-8206-BBF257D92D44"]) {
                filter.categoryId = 2;//3D
            } else if ([filter.packageId isEqualToString:@"3A66960A-E129-4040-B523-1C87544FB008"]) {
                filter.categoryId = 2;//3D
            } else if ([filter.packageId isEqualToString:@"289829A7-EA10-423E-96EA-5BBB23A1B86D"]) {
                filter.categoryId = 1;//2D
            } else if ([filter.packageId isEqualToString:@"084A6EC1-43AB-40EF-BBD5-D83F692B011B"]) {
                filter.categoryId = 1;//2D
            } else if ([filter.packageId isEqualToString:@"B6B1BD95-B495-404A-A450-0C306A3338E4"]) {
                filter.categoryId = 2;//3D
                
            }
        } else {
            ///再加下载素材,放在前面
            ///Plus download material, put it in front
            [_propsDataSource insertObject:filter atIndex:1];
        }
    }
    
    [self.propsView configDataSource:self.propsDataSource];
}

#pragma mark 界面响应函数
//click the count down button
- (void)countDownBtnClick {
    captureView.hidden = YES;
    self.countDownView.hidden = NO;
    [self.view bringSubviewToFront:self.countDownView];
    float progress = [captureView->recordingProgress value]*1.0/TotalTime;
    self.countDownView.progress = progress;
    self.countDownView.currentValue = 1;
}

- (void)countDownView:(NvCountDownView *)countDownView didClickCountDownValue:(float)value {
    self.countDownTime = (int64_t)(15*NV_TIME_BASE * value);
    
    if (self.countDownView.hidden == NO) {
        self.countDownView.hidden = YES;
    }
    
    self.animationView = [[NvCountDownAnimationView alloc] initWithFrame:CGRectMake(30, 50, SCREENWIDTH - 2*30, SCREENHEIGHT - 2*50)];
    self.animationView.delegate = self;
    [self.view addSubview:self.animationView];
    [self.animationView startAnimation];
}

- (void)countDownAnimationStopAnimationView:(NvCountDownAnimationView *)countDownAnimationView {
    [self.animationView removeFromSuperview];
    self.animationView = nil;
    captureView.hidden = NO;
    [captureView hiddenAllButtonExceptRecordingButton];
    [captureView countDownStartRecording];
}

#pragma mark 对焦
//focus
- (void)focusOnPoint:(CGPoint)point {
    [streamingContext startAutoFocus:point];
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(continuousFoucs:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
#pragma mark 曝光
//exposure
- (void)exposureOnPoint:(CGPoint)point {
    [streamingContext startAutoExposure:point];
}

#pragma mark 点击美颜
// click the beauty button
- (void)faceBtnClicked {
    self.beautyView.hidden = NO;
    [self.view bringSubviewToFront:self.beautyView];
    captureView.hidden = YES;
    self.beautyView.containtAR = self.beautyLogic.enAbleAI;
    [self.beautyView setStrength:self.beautyLogic.strength eyeEnlarging:self.beautyLogic.eyeEnlarging cheekThinning:self.beautyLogic.cheekThinning*-1];
    
}

#pragma mark 点击切换摄像头
//click the switch camera button
- (void)cameraButtonClicked {
    if ([streamingContext isCaptureDeviceBackFacing:currentDeviceIndex]) {
        //前置摄像头
        //front camera
        currentDeviceIndex = [self frontCameraDeviceIndex];
        [captureView->flashBtn setImage:NvImageNamed(@"Nvflash_off") forState:UIControlStateNormal];
        [captureView->flashBtn setEnabled:NO];
    } else {
        //后置摄像头
        //back camera
        currentDeviceIndex = [self backCameraDeviceIndex];
        [captureView->flashBtn setImage:NvImageNamed(@"Nvflash_off") forState:UIControlStateNormal];
        [captureView->flashBtn setEnabled:YES];
    }
    
    [self startCapturePreview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.currentPropsModel) {
            [self.beautyLogic.arfaceVideoFx setStringVal:@"Scene Id" val:self.currentPropsModel.packageId];
        }
    });
}
#pragma mark 点击返回
//click the back button
- (void)backButtonClicked {
    [streamingContext removeAllCaptureVideoFx];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [streamingContext stop];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 点击删除
//click the delete button
- (void)deleteBtnClicked {
    NvRecordingInfo *info = [videoPathArray lastObject];
    float musicStartPos = info.musicStartPos;
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:info.recordingPath error:nil];
    [videoPathArray removeLastObject];
    NvRecordingInfo *infolast = [videoPathArray lastObject];
    if (infolast == nil) {
        [self.player seekToTime:musicStartPos];
    } else {
        [self.player seekToTime:infolast.musicEndPos];
    }
}
#pragma mark 点击下一步
//click the next step button
- (void)nextBtnClicked {
    NSMutableArray *files = [NSMutableArray array];
    for (NvRecordingInfo *info in videoPathArray) {
        NvsAVFileInfo *fileInfo = [streamingContext getAVFileInfo:info.recordingPath];
        info.trimIn = 0;
        info.trimOut = fileInfo.duration;

        [files addObject:info.recordingPath];
    }
    NvShortVideoEditViewController *vc = NvShortVideoEditViewController.new;
    vc.videoPathArray = videoPathArray;
    if (self.isNoMusic) {
        vc.musicPath = nil;
    } else {
        vc.musicPath = musicPath;
        vc.trimIn = self.trimIn*NV_TIME_BASE;
        vc.trimOut = self.trimOut*NV_TIME_BASE;
    }
    [self.navigationController pushViewController:vc animated:YES];
    
}
#pragma mark 点击相册
//click the album button
- (void)albumClick {
    NvAlbumViewController *album = [[NvAlbumViewController alloc] init];
    album.mutableSelect = NO;
    album.isOnlyVideo = YES;
    album.delegate = self;
    [self.navigationController pushViewController:album animated:YES];
}

#pragma mark 点击滤镜
//click the filter button
- (void)filterBtnClicked {
    captureView.hidden = YES;
    [self.view bringSubviewToFront:self.filterView];
    [UIView animateWithDuration:0.2 animations:^{
        self.filterView.frame = CGRectMake(0, SCREENHEIGHT - self.filterView.frame.size.height, SCREENWIDTH, self.filterView.frame.size.height);
    } completion:NULL];
}

#pragma mark 点击闪光灯
//click the flash button
- (void)flashBtnClicked {
    if ([streamingContext isFlashOn]) {
        [streamingContext toggleFlash:NO];
        [captureView->flashBtn setImage:NvImageNamed(@"Nvflash_off") forState:UIControlStateNormal];
    } else {
        [streamingContext toggleFlash:YES];
        [captureView->flashBtn setImage:NvImageNamed(@"Nvflash_on") forState:UIControlStateNormal];
    }
}

#pragma mark 选择速率
//choose the speed of recording
- (void)shortVideoCaptureView:(NvShortVideoCaptureView *)shortVideoCaptureView selectSpeed:(float)speed {
    recordingSpeed = speed;
}

#pragma mark 选择相册回调
//the protocol method of NvAlbumViewController
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    PHAsset *asset = assets.firstObject.asset;
    NSTimeInterval time = asset.duration;
    if (time < 3.0) {
        
        [UIAlertController presentAlertFromVC:albumViewController
                                        title:NvLocalString(@"Tips" , @"提示")
                                      message:NvLocalString(@"longerthan3", @"请选择长于3秒的视频")
                            buttonTitleColors:nil
                            cancelButtonTitle:nil
                             otherButtonTitle:NvLocalString(@"Know", @"知道了")
                           cancelButtonAction:nil
                            otherButtonAction:nil];

        return;
    }
    
    NvTrimVideoViewController *vc = NvTrimVideoViewController.new;
    NvsTimeline *timeline = [NvTimelineUtils createTimelineOrdinary:NvEditMode9v16];
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    [videoTrack appendClip:assets.firstObject.asset.localIdentifier];
    
    if (self.isNoMusic) {
        vc.musicPath = @"";
    } else {
        vc.musicPath = musicPath;
        vc.musicTrimIn = self.trimIn*NV_TIME_BASE;
        vc.musicTrimOut = self.trimOut*NV_TIME_BASE;
    }
    NvRecordingInfo *info = [NvRecordingInfo new];
    info.asset = assets.firstObject.asset;
    vc.timeline = timeline;
    vc.editMode = NvEditMode9v16;
    vc.info = info;
    vc.isNoMusic = self.isNoMusic;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 选择音乐的回调
//the protocol method of NvSelectMusicViewController
- (void)selectMusicViewController:(NvSelectMusicViewController *)selectMusicViewController withItem:(NvEditSelectMusicItem *)item trimIn:(float)trimIn trimOut:(float)trimOut {
    if (item.duration<15.0) {
        
        [UIAlertController presentAlertFromVC:selectMusicViewController
                                        title:NvLocalString(@"Tips" , @"提示")
                                      message:NvLocalString(@"lessthan15", @"音乐选择不能小于15秒")
                            buttonTitleColors:nil
                            cancelButtonTitle:nil
                             otherButtonTitle:NvLocalString(@"Know", @"知道了")
                           cancelButtonAction:nil
                            otherButtonAction:nil];

        return;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    self.isNoMusic = NO;
    musicPath = item.musicPath;
    
    [self.player setUrlString:musicPath];
    [self.player seekToTime:trimIn];
    self.trimIn = trimIn;
    self.trimOut = trimOut;
    [captureView.selectMusic setTitle:item.musicName forState:UIControlStateNormal];
}

/*
 音乐选择为空
 select none music
 */
- (void)selectNoneMusic {
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.isNoMusic = YES;
    [captureView.selectMusic setTitle:NvLocalString(@"selectMusic", @"选择音乐") forState:UIControlStateNormal];
}

/*
 音乐播放完毕回调方法
 the call back method of the music has been played to the end
 */
- (void)nvAudioPlayerPlayEOF:(NvAudioPlayer *)player {
    [player seekToTime:self.trimIn];
    [player play];
}

#pragma mark 开始录制
/*
 开始录制
 start to record
 */
- (void)startRecord {
    [self startRecording];
    [captureView hiddenAllButtonExceptRecordingButton];
    if (!self.isNoMusic) {
        float rate = 1;
        if (recordingSpeed == 0.5) {
            rate = 2;
        } else if (recordingSpeed == 0.75) {
            rate = 1.5;
        } else if (recordingSpeed == 1) {
            rate = 1;
        } else if (recordingSpeed == 1.5) {
            rate = 0.75;
        } else if (recordingSpeed == 2) {
            rate = 0.5;
        }
        [self.player rate:rate];
    }
}

/*
 结束录制
 end the recording
 */
- (void)endRecord {
    [self stopRecording];
    [self.player pause];
    [captureView showAllButton];
}

/*
 录制超过十五秒
 the sum time of recording has over fifteen secs
 */
- (void)overFifteenSecond {
    [self presentAlertInfo:NvLocalString(@"overFifteenSecond", @"拍满了，删除一段再拍")];
}

/*
 提示框方法
 present alert info
 */
- (void)presentAlertInfo:(NSString *)info {
    
    [UIAlertController presentAlertFromVC:self
                                    title:NvLocalString(@"Tips" , @"提示")
                                  message:info
                        buttonTitleColors:nil
                        cancelButtonTitle:nil
                         otherButtonTitle:NvLocalString(@"Know", @"知道了")
                       cancelButtonAction:nil
                        otherButtonAction:nil];
}

/*
 开始录制
 start to record
 */
- (void)startRecording{
    if (!videoPathArray) {
        videoPathArray = NSMutableArray.new;
    }
    NSString *path = [VIDEO_PATH(@"Record") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
    
    [streamingContext startRecordingWithFx:path withFlags:0 withRecordConfigurations:config];
    NvRecordingInfo *info = [NvRecordingInfo new];
    info.recordingPath = path;
    info.musicStartPos = self.player.currentTime;
    info.speed = recordingSpeed;
    [videoPathArray addObject:info];
}

#pragma mark 停止录制
/*
 停止录制
 stop recording
 */
- (void)stopRecording{
    [streamingContext stopRecording];
    self.countDownTime = 15*NV_TIME_BASE;
    NvRecordingInfo *info = [videoPathArray lastObject];
    info.musicEndPos = self.player.currentTime;
}

#pragma mark - NvsStreamingContextDelegate
- (void)didCaptureRecordingDurationUpdated:(int)captureDeviceIndex duration:(int64_t)duration {
    if (duration > NV_TIME_BASE/2) {
        [captureView enableRecordingButton];
    }
    [captureView updateCaptureClipDuration: duration];
    if ([captureView->recordingProgress value] >= self.countDownTime) {
        [captureView recordingEnd];
        ///录制大于等于15秒倒计时按钮禁止点击
        ///Record more than or equal to 15 seconds countdown button forbidden to click
        if ([captureView->recordingProgress value] >= 15000000) {
            captureView.countDownBtn.enabled = NO;
            [self nextBtnClicked];
        }
    }
}

- (void)didCaptureDeviceCapsReady:(unsigned int)captureDeviceIndex {
    self.capability = [streamingContext getCaptureDeviceCapability:captureDeviceIndex];
    
    CGPoint point = CGPointMake(0.49*liveWindow.width, 0.49*liveWindow.height);
    if (self.capability.supportAutoFocus) {
        [streamingContext startAutoFocus:point];
        [self.timer invalidate];
        self.timer = nil;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(continuousFoucs:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    if (self.capability.supportAutoExposure) {
        /// 支持自动曝光则自动曝光
        /// Automatic exposure if automatic exposure is supported
        [streamingContext startAutoExposure:point];
    }
}

- (void)didCaptureRecordingFinished:(unsigned int)captureDeviceIndex {
}

/*
 聚焦方法
 continuous focus
 */
- (void)continuousFoucs:(NSTimer *)timer {
    [streamingContext startContinuousFocus];
    self.timer = nil;
}

/*
 查看设备是否支持自动聚焦
 check whether the device support auto focus or not
 */
- (BOOL)supportAutoFocus {
    return self.capability.supportAutoFocus;
}

/*
 查看设备是否支持自动曝光
 check whether the device support auto exposure
 */
- (BOOL)supportAutoExposure {
    return self.capability.supportAutoExposure;
}

/*
 记录拍摄数据
 setup the edit data
 */
- (void)setupEditData {
    [[[NvTimelineData sharedInstance] editDataArray] removeAllObjects];
    for (NvRecordingInfo *info in videoPathArray) {
        NvEditDataModel *clipData = NvEditDataModel.new;
        clipData.videoPath = info.recordingPath;
        clipData.trimIn = 0;
        clipData.trimOut = [NvSDKUtils getVideoDuration:info.recordingPath];
        clipData.duration = [NvSDKUtils getVideoDuration:info.recordingPath];
        [[[NvTimelineData sharedInstance] editDataArray] addObject:clipData];
    }
}

- (void)applicationWillResignActive:(NSNotification*)notification {
}

- (void)applicationDidBecomeActive:(NSNotification*)notification {
    if ([streamingContext getStreamingEngineState] != NvsStreamingEngineState_CapturePreview)
        [self startCapturePreview];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return  UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
