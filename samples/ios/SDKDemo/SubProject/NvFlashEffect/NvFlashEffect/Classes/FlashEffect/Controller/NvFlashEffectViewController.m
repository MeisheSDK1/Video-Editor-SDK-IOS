//
//  NvFlashEffectViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2019/10/15.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvFlashEffectViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <NvBaseCommon/NvBaseUtils.h>
#import "NvRecordingView.h"
#import "NvFlashGraphicBtn.h"
#import "NvEffectPickCell.h"
#import "NvEffectModel.h"
#import "NvsCaptureVideoFx.h"
#import "NvCapturePopupView.h"
#import <NvBaseCommon/UIView+Dimension.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import "NvToast.h"
#import <NvStreamingSdkCore/NvStreamingSdkCore.h>

@interface NvFlashEffectViewController ()<NvsStreamingContextDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) NvsLiveWindow *liveWindow;
//摄像头的能力
// camera capabilities
@property (nonatomic, strong) NvsCaptureDeviceCapability *capability;
@property (nonatomic, assign) int currentDeviceIndex;

//界面按钮
// Interface button
@property (nonatomic, strong) UIButton *backBtn;         //关闭 close
@property (nonatomic, strong) UIButton *deviceBtn;       //切换摄像头 switch camera
@property (nonatomic, strong) UIButton *exposureBtn;     //曝光 exposure
//曝光弹窗视图
// Expose the popover view
@property (nonatomic, strong) NvCapturePopupView *exposureView;

//手动对焦视图
// Manually focus the view
@property (nonatomic, strong) UIImageView *focusView;

@property (nonatomic, strong) NvRecordingView *recordingView;//录制按钮 recording button
@property (nonatomic, assign) BOOL isRecord;
@property (nonatomic, strong) NvFlashGraphicBtn *propsBtn;        //样式 style
@property (nonatomic, strong) NvFlashGraphicBtn *intensityBtn;
@property (nonatomic, strong) UILabel *timeLabel;            //时间label timelabel
@property (nonatomic, strong) NSString *recordingPath;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NvsCaptureVideoFx *glitterEffect;
@property (nonatomic, strong) UIView *intensityView;
@property (nonatomic, strong) UISlider *intensitySlider;
@property (nonatomic, strong) UILabel *minLabel,*maxLabel;

@end

@implementation NvFlashEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addObservers];
    // 初始化美摄SDK
    self.streamingContext = [NvsStreamingContext sharedInstance];
    if (!_streamingContext) {
        return;
    }

    _streamingContext.delegate = self;

    if ([_streamingContext captureDeviceCount] == 0) {
    }
    _liveWindow = [[NvsLiveWindow alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [self.view addSubview:_liveWindow];
    
    if (![_streamingContext connectCapturePreviewWithLiveWindow:self.liveWindow]) {
    }
    
    self.glitterEffect = [self.streamingContext appendBuiltinCaptureVideoFx:@"Glitter"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    tap.numberOfTapsRequired = 1;
    [_liveWindow addGestureRecognizer:tap];
    
    [self initUI];
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
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf startupCapture];
                                [weakSelf presentPermissions];
                            });
                        }
                    }];
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf presentPermissions];
                });
            }
        }];
    } else if (authStatus == AVAuthorizationStatusDenied) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf presentPermissions];
        });
    } else {
        authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (authStatus == AVAuthorizationStatusDenied) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf presentPermissions];
            });
        }
        [weakSelf startupCapture];
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([_streamingContext getStreamingEngineState] != NvsStreamingEngineState_CapturePreview) {
        [self startCapturePreview];
        _streamingContext.delegate = self;
    }

    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)startupCapture{
    self.currentDeviceIndex = [self frontCameraDeviceIndex];
    if (![self startCapturePreview]) {
    }
    
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (!self.collectionView.hidden) {
        self.collectionView.hidden = YES;
        [self hiddenAllButton:NO];
    } else if (!self.intensityView.hidden) {
        self.intensityView.hidden = YES;
        [self hiddenAllButton:NO];
    } else if (!self.exposureView.hidden) {
        self.exposureView.hidden = YES;
        [self hiddenAllButton:NO];
    } else {
        CGPoint point = [tap locationInView:self.liveWindow];
        if (self.capability.supportAutoFocus) {
            [_streamingContext startAutoFocus:point];
            [self animateFocusView:point];
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayaf) object:nil];
        [self performSelector:@selector(delayaf) withObject:nil afterDelay:3.0];
    }
}

#pragma mark 添加手动对焦视图
//Add a manual focus view
- (void)initFocusView{
    self.focusView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.focusView.alpha = 0;
    [_focusView setImage:NvImageNamed(@"NvsCaptureFocus")];
    [self.view addSubview:self.focusView];
}

#pragma mark 给手动对焦视图添加动画
//Animate the manual focus view
- (void)animateFocusView:(CGPoint)currentPoint{
    self.focusView.center = currentPoint;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.8;
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue   = @1;
    alphaAnimation.repeatCount = 1;
    alphaAnimation.duration = .8;
    
    CABasicAnimation *focusAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    focusAnimation.fromValue = @1.7;
    focusAnimation.toValue   = @1;
    focusAnimation.repeatCount = 1;
    focusAnimation.duration = .3;
    
    CABasicAnimation *focusAnimation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    focusAnimation1.fromValue = @1;
    focusAnimation1.toValue   = @1;
    focusAnimation1.repeatCount = 1;
    focusAnimation1.beginTime = 0.3;
    focusAnimation1.duration = 0.5;
    
    [group setAnimations:@[alphaAnimation,focusAnimation,focusAnimation1]];
    [self.focusView.layer addAnimation:group forKey:@"transform.scale"];
}

#pragma mark 对焦延迟执行
//Focus delay execution
- (void)delayaf{
    [self.streamingContext startContinuousFocus];
}

#pragma mark 关闭退出
//Close exit
- (void)backBtnClick:(UIButton *)sender{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayaf) object:nil];
    [self.streamingContext removeAllCaptureVideoFx];
    [self.streamingContext setExposureBias:0.0];
    [self.streamingContext stop];
    [self.streamingContext clearCachedResources:NO];
    //    [NvsStreamingContext destroyInstance];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 切换摄像头
//Switching cameras
- (void)deviceBtnClick:(UIButton *)sender{
    if (_currentDeviceIndex == 0) {
        _currentDeviceIndex = 1;
    } else {
        _currentDeviceIndex = 0;
    }
    
    [self startCapturePreview];
}


#pragma mark 闪光灯开关
//Flash light switch
- (void)exposureBtnClick:(UIButton *)sender{
    self.exposureView.hidden = NO;
    [self hiddenAllButton:YES];
    self.timeLabel.hidden = YES;
    self.exposureView.defaultValue = self.streamingContext.getExposureBias;
}

- (void)propsBtnClick:(NvFlashGraphicBtn *)button {
    self.collectionView.hidden = NO;
    [self hiddenAllButton:YES];
    self.timeLabel.hidden = YES;
}

- (void)intensityBtnClick:(NvFlashGraphicBtn *)button {
    self.intensityView.hidden = NO;
    [self hiddenAllButton:YES];
    self.timeLabel.hidden = YES;
    float value = [self.glitterEffect getFloatVal:@"Quantity"];
    self.intensitySlider.value = value;
}

- (void)intensityValueChanged:(UISlider *)slider {
    [self.glitterEffect setFloatVal:@"Quantity" val:slider.value];
}

#pragma mark 获取前置摄像头设备索引
//Get the front-facing camera device index
- (unsigned int)frontCameraDeviceIndex {
    for (unsigned int i = 0; i < _streamingContext.captureDeviceCount; i++) {
        if (![_streamingContext isCaptureDeviceBackFacing:i])
            return i;
    }
    return _streamingContext.captureDeviceCount - 1;
}

#pragma mark 启动摄像头采集预览
//Start the camera to capture the preview
- (BOOL)startCapturePreview {
    NSNumber *num = NV_UserInfo(@"NvRecordResolution");
    NvsVideoCaptureResolutionGrade captureResGrade = [num intValue] == 1080? NvsVideoCaptureResolutionGradeHigh:NvsVideoCaptureResolutionGradeMedium;
    if (![_streamingContext isCaptureDeviceBackFacing:_currentDeviceIndex]){
        captureResGrade = [num intValue] == 1080?NvsVideoCaptureResolutionGradeSupperHigh:NvsVideoCaptureResolutionGradeHigh;
    }
    return [_streamingContext startCapturePreview:_currentDeviceIndex videoResGrade:captureResGrade flags:NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame | NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize aspectRatio:nil];
}

- (void)presentPermissions {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NvLocalStringFromTable([self class],@"Tips" , @"提示") message:NvLocalStringFromTable([self class],@"camera.microphone.permissions", @"需要打开摄像头和麦克风权限 请在手机设置中进行允许") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *skipAction = [UIAlertAction actionWithTitle:NvLocalStringFromTable([self class], @"Know", @"知道了") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertVC addAction:skipAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - NvRecordingViewDelegate
- (BOOL)recordingViewAllowStartRecording:(NvRecordingView *_Nullable)recordingView {
    return YES;
}

- (void)startRecording {
    self.isRecord = YES;
    self.recordingPath = [VIDEO_PATH(@"Record") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvBaseUtils currentDateAndTime]]];
    [_streamingContext startRecordingWithFx:self.recordingPath];
    
}

- (void)stopRecording {
    self.isRecord = NO;
    [_streamingContext stopRecording];
    [self hiddenAllButton:YES];
}

- (void)hiddenAllButton:(BOOL)isHidden {
    self.backBtn.hidden      = isHidden;
    self.exposureBtn.hidden  = isHidden;
    self.deviceBtn.hidden    = isHidden;
    self.propsBtn.hidden     = isHidden;
    self.intensityBtn.hidden = isHidden;
    self.timeLabel.hidden    = !isHidden;
}

#pragma mark 注册应用前台后台通知事件
//Register application foreground and background notification events
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

// 应用进入后台，停止采集
// app goes into background and stops ingest
- (void)applicationWillResignActive:(NSNotification*)notification {
    self.isRecord = NO;
    if ([_streamingContext getStreamingEngineState] == NvsStreamingEngineState_CaptureRecording) {
        [self.recordingView callbackAndStopAnimation];
    }
    
    if ([_streamingContext getStreamingEngineState] == NvsStreamingEngineState_CapturePreview) {
        [self.recordingView callbackAndStopAnimation];
    }
    
    if (!self.collectionView.hidden) {
        self.collectionView.hidden = YES;
    } else if (!self.intensityView.hidden) {
        self.intensityView.hidden = YES;
    } else if (!self.exposureView.hidden) {
        self.exposureView.hidden = YES;
    }
    [self hiddenAllButton:NO];
}

// 应用进入前台，开始采集
// App comes to the foreground and starts collecting
- (void)applicationDidBecomeActive:(NSNotification*)notification {
    
    if ([_streamingContext getStreamingEngineState] == NvsStreamingEngineState_Stopped) {
        [self startCapturePreview];
    }
}


#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvEffectPickCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvEffectPickCell" forIndexPath:indexPath];
    [cell setModel:self.dataSource[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.dataSource enumerateObjectsUsingBlock:^(NvEffectModel *  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        model.isSelect = NO;
    }];
    NvEffectModel *model = self.dataSource[indexPath.item];
    model.isSelect = YES;
    [collectionView reloadData];
    [self.glitterEffect setStringVal:@"Source Path" val:model.imageUrl];
    [self.glitterEffect setFloatVal:@"Quantity" val:1];
    self.intensitySlider.value = 1;
}

#pragma mark - NvsStreamingContextDelegate
- (void)didCaptureDeviceCapsReady:(unsigned int)captureDeviceIndex{
    // 获取采集设备的能力描述
    // Get the capability description of the capture device
    self.capability = [_streamingContext getCaptureDeviceCapability:captureDeviceIndex];
    if (!self.capability){
        return;
    }
    
    CGPoint point = CGPointMake(0.49*self.liveWindow.width, self.liveWindow.height / 2);
    [self performSelector:@selector(delayaf) withObject:nil afterDelay:3.0];
    if (self.capability.supportAutoFocus) {
        [_streamingContext startAutoFocus:point];
    }
    // If auto-exposure is supported
    if (self.capability.supportAutoExposure) {  // 支持自动曝光则自动曝光
        [_streamingContext startAutoExposure:point];
    }
}
- (void)didCaptureRecordingStarted:(unsigned int)captureDeviceIndex {
    [self hiddenAllButton:YES];
}

- (void)didCaptureRecordingDurationUpdated:(int)captureDeviceIndex duration:(int64_t)duration {
    if (self.isRecord) {
        self.timeLabel.text = [NvBaseUtils convertTimecode:duration];
    }
}

- (void)didCaptureRecordingFinished:(unsigned int)captureDeviceIndex {
    self.isRecord = NO;
    [self hiddenAllButton:NO];
    UISaveVideoAtPathToSavedPhotosAlbum(self.recordingPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
}

- (void)didCaptureRecordingError:(unsigned int)captureDeviceIndex {
    self.isRecord = NO;
    [self hiddenAllButton:NO];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [NvToast showInfoWithMessage:error.localizedFailureReason];
    } else {
        [NvToast showInfoWithMessage:NvLocalStringFromTable([self class],@"Saved to album", @"已保存至相册")];
    }
}

- (void)initUI {
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backBtn.frame = CGRectMake(13*SCREENSCALE, NV_STATUSBARHEIGHT+10*SCREENSCALE, 30*SCREENSCALE, 30*SCREENSCALE);
    [self.backBtn setImage:[NvBaseUtils imageNamed:@"Nvback" inBundle:NvCurrentBundle] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.backBtn.exclusiveTouch = YES;
    [self.view addSubview:self.backBtn];
    
    self.exposureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.exposureBtn.frame = CGRectMake(13*SCREENSCALE, NV_STATUSBARHEIGHT+10*SCREENSCALE, 30*SCREENSCALE, 30*SCREENSCALE);
    self.exposureBtn.centerX = self.view.centerX;
    [self.exposureBtn setImage:[NvBaseUtils imageNamed:@"Nvexposure" inBundle:NvCurrentBundle] forState:UIControlStateNormal];
    [self.exposureBtn addTarget:self action:@selector(exposureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.exposureBtn.exclusiveTouch = YES;
    [self.view addSubview:self.exposureBtn];
    
    self.deviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deviceBtn.frame = CGRectMake(SCREENWIDTH-13*SCREENSCALE-30*SCREENSCALE, NV_STATUSBARHEIGHT+10*SCREENSCALE, 30*SCREENSCALE, 30*SCREENSCALE);
    [self.deviceBtn setImage:[NvBaseUtils imageNamed:@"Nvdevice" inBundle:NvCurrentBundle] forState:UIControlStateNormal];
    [self.deviceBtn addTarget:self action:@selector(deviceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.deviceBtn.exclusiveTouch = YES;
    [self.view addSubview:self.deviceBtn];
    
    self.recordingView = [[NvRecordingView alloc] initWithFrame:CGRectMake(0, 0, 72*SCREENSCALE, 72*SCREENSCALE)];
    self.recordingView.delegate = self;
    self.recordingView.center = CGPointMake(self.view.centerX, self.view.height-80-INDICATOR);
    [self.view addSubview:self.recordingView];
    self.recordingView.layer.cornerRadius = 72*SCREENSCALE/2;
    self.recordingView.layer.masksToBounds = YES;
    
    self.propsBtn = [NvFlashGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalStringFromTable([self class], @"Style", @"样式") withImageNormal:@"NvPropsButton" withImageSelected:@"NvPropsButton"];
    self.propsBtn.exclusiveTouch = YES;
    self.propsBtn.frame = CGRectMake(0, 0, 40*SCREENSCALE, 60*SCREENSCALE);
    self.propsBtn.right = self.recordingView.left - 48*SCREENSCALE;
    self.propsBtn.centerY = self.recordingView.centerY;
    [self.view addSubview:self.propsBtn];
    [self.propsBtn addTarget:self action:@selector(propsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.intensityBtn = [NvFlashGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalStringFromTable([self class], @"fxStrength", @"强度") withImageNormal:@"NvIntensityBtn" withImageSelected:@"NvIntensityBtn"];
    self.intensityBtn.frame = CGRectMake(0, 0, 140*SCREENSCALE, 60*SCREENSCALE);
    self.intensityBtn.left = self.recordingView.right -2*SCREENSCALE;
    self.intensityBtn.centerY = self.recordingView.centerY;
    self.intensityBtn.exclusiveTouch = YES;
    [self.view addSubview:self.intensityBtn];
    [self.intensityBtn addTarget:self action:@selector(intensityBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100*SCREENSCALE, 30*SCREENSCALE)];
    self.timeLabel.center = self.exposureBtn.center;
    self.timeLabel.textColor = UIColor.redColor;
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.text = @"00:00";
    self.timeLabel.font = [NvBaseUtils mediumFontWithSize:15];
    self.timeLabel.hidden = YES;
    [self.view addSubview:self.timeLabel];
    
    [self initFocusView];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(48*SCREENSCALE, 76*SCREENSCALE);
    layout.minimumLineSpacing = 15*SCREENSCALE;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,SCREENHEIGHT-130*SCREENSCALE-INDICATOR,SCREENWIDTH,130*SCREENSCALE+INDICATOR) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor colorWithRed:29/255.0 green:31/255.0 blue:38/255.0 alpha:1.0];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(33*SCREENSCALE, 13*SCREENSCALE, 20*SCREENSCALE+INDICATOR, 13*SCREENSCALE);
    [self.collectionView registerClass:[NvEffectPickCell class] forCellWithReuseIdentifier:@"NvEffectPickCell"];
    [self.view addSubview:self.collectionView];
    self.collectionView.hidden = YES;
    self.dataSource = [NSMutableArray array];
    NSString *glitterPath = [[NSBundle bundleForClass:[self class]].bundlePath stringByAppendingPathComponent:@"Glitter"];
    NSFileManager *fm = [NSFileManager defaultManager];
    [[fm contentsOfDirectoryAtPath:glitterPath error:nil] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NvEffectModel *model = [NvEffectModel new];
        model.name = obj.stringByDeletingPathExtension;
        model.imageUrl = [glitterPath stringByAppendingPathComponent:obj];
        [self.dataSource addObject:model];
    }];
    NvEffectModel *model = self.dataSource.firstObject;
    model.isSelect = YES;
    [self.collectionView reloadData];
    [self.glitterEffect setStringVal:@"Source Path" val:model.imageUrl];
    [self.glitterEffect setFloatVal:@"Quantity" val:1];
    
    self.intensityView = [[UIView alloc] initWithFrame:CGRectMake(0, self.collectionView.top, SCREENWIDTH, self.collectionView.height)];
    self.intensityView.backgroundColor = self.collectionView.backgroundColor;
    [self.view addSubview:self.intensityView];
    self.intensityView.hidden = YES;
    self.intensitySlider = [[UISlider alloc] initWithFrame:CGRectMake(42*SCREENSCALE, 53*SCREENSCALE, 290*SCREENSCALE, 25*SCREENSCALE)];
    [self.intensityView addSubview:self.intensitySlider];
    self.intensitySlider.value = 1;
    self.intensitySlider.minimumValue = 0;
    self.intensitySlider.maximumValue = 1;
    [self.intensitySlider setThumbImage:[NvBaseUtils imageNamed:@"NvIntensitySlider" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [self.intensitySlider addTarget:self action:@selector(intensityValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.minLabel = [[UILabel alloc] initWithFrame:CGRectMake(23*SCREENSCALE, 53*SCREENSCALE, 10*SCREENSCALE, 25*SCREENSCALE)];
    self.minLabel.textColor = UIColor.whiteColor;
    self.minLabel.textAlignment = NSTextAlignmentCenter;
    self.minLabel.text = @"0";
    self.minLabel.font = [NvBaseUtils mediumFontWithSize:14];
    [self.intensityView addSubview:self.minLabel];
    self.maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.intensitySlider.right+8*SCREENSCALE, 53*SCREENSCALE, 10*SCREENSCALE, 25*SCREENSCALE)];
    self.maxLabel.textColor = UIColor.whiteColor;
    self.maxLabel.textAlignment = NSTextAlignmentCenter;
    self.maxLabel.text = @"1";
    self.maxLabel.font = [NvBaseUtils mediumFontWithSize:14];
    [self.intensityView addSubview:self.maxLabel];
    
    self.exposureView = [[NvCapturePopupView alloc]initWithFrame:CGRectMake(0, self.collectionView.top, SCREENWIDTH, self.collectionView.height) withType:CapturePopupTypeExposure];
    [self.view addSubview:_exposureView];
    self.exposureView.backgroundColor = self.collectionView.backgroundColor;
    __weak typeof(self)weakSelf = self;
    self.exposureView.ValueBlook = ^(float value) {
        [weakSelf.streamingContext setExposureBias:value];
    };
    self.exposureView.hidden = YES;
}

@end
