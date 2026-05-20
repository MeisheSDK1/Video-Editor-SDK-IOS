//
//  NvCaptureViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvCaptureViewController.h"
#import "NvsStreamingContext.h"
#import "NvsLiveWindow.h"
#import "NvsAssetPackageManager.h"
#import "NvsCaptureVideoFx.h"
#import "NvsFxDescription.h"
#import <CoreMotion/CoreMotion.h>
#import "NvMoreFilterViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NvTipsView.h"
#import <NvBaseCommon/NvCapturePopupView.h>
#import "YWISOSlider.h"
#import "NvBeautyView.h"
#import "NvBeautyShapeModuler.h"
#import "NvMakeupView.h"
#import "NvEditViewController.h"
#import <Photos/PHPhotoLibrary.h>
#import "NvPsTitleCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreMedia/CoreMedia.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import <NvSDKCommon/NvAssetManager.h>
#import "NvFilterDataSource.h"
#import "NvCapturePropsModel.h"
#import "NvGraphicBtn.h"
#import "NvMakeupModel.h"
#import "NvTimelineUtils.h"
#import "NvChangeVoiceBottomView.h"
#import "NvAssetCellModel.h"
#import "NvCaptureStickerStyleView.h"
#import "NvRectView.h"
#import "NvCaptionStyleItem.h"
#import "NvCaptureCompoundCaptionStyleView.h"
#import "NvModifyCompoundCaptionViewController.h"
#import "NvCaptionCompoundCaptionView.h"
#import "NvCaptureStickerCaptionUtils.h"
#import <NvAlbum/NvAlbumViewController.h>
#import "NvCaptureFilterModel.h"
#import <NvSDKCommon/NvBaseNavigationController.h>
#import "NvInitArScence.h"
#import "NvCafCreator.h"
#import "NvCustomStickerShapeViewController.h"
#import "NvMakeupToolManager.h"
#import "NvMakeupModel.h"
#import "NvTitleListViewController.h"
#import "BLItemSlider.h"
#import "NvEffectsStyleModel.h"
#import "NvCaptureModularVM.h"
#import "NvAdjustFxParamView.h"
#import "UIImage+Clip.h"
#import "NvCaptureNoiseSuppressionViewController.h"
#import <CallKit/CallKit.h>
#import <CallKit/CXCall.h>
#import "NvScrollLabel.h"
#import "NvSelectMusicViewController.h"
#import "NvAudioPlayer.h"
#import "AFNetworkReachabilityManager.h"
#ifdef ARSCENE_AVATAR_TEST
#import "NvFaceActionView.h"
#endif

@interface NvCaptureViewController ()
<NvsStreamingContextDelegate,
 UICollectionViewDelegate,
 UICollectionViewDataSource,
 YWISOSliderDelegate,
 NvMakeupViewDelegate,
 NvCafCreatorDelegate,
 NvTitleListViewControllerDelegate,
 BLItemSliderDelegate,
 NvMakeupToolManagerDelegate,
 NvCaptureModularVMUIDelegate,
 NvAdjustFxParamViewDelegate,
 NvSelectMusicViewControllerDelegate,
 CXCallObserverDelegate>

@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) NvCaptureModularVM *captureVM;
@property (nonatomic, strong) UIView *liveWindowBGView;
@property (nonatomic, strong) NvsLiveWindow *liveWindow;
@property (nonatomic, strong) NvsLiveWindow *liveWindowBack;
@property (nonatomic, strong) NvsLiveWindow *curLiveWindow;
@property (nonatomic, assign) int currentDeviceIndex;
//视频路径数组
//Video path array
@property (nonatomic, strong) NSMutableArray *videoPathArray;
//拍照、拍摄title数组
// Shoot the title array
@property (nonatomic, strong) NSMutableArray *psTitleArray;
//当前拍照、拍摄对应的current
// current Take pictures and shoot corresponding current
@property (nonatomic, assign) NSInteger currentInteger;
//断点拍摄每段视频的时长数组
// Breakpoint shot each video length array
@property (nonatomic, strong) NSMutableArray *durationArray;
//拍照的图片路径
// Photo path to take the photo
@property (nonatomic, strong) NSString *pngPath;
//总拍摄时长
// Total shooting time
@property (nonatomic, assign) int64_t duration;
//断点拍摄每次停止录制的时长，duration和durationArray需要用到
// Breakpoint captures the duration for which recording stops. Duration and durationArray are required
@property (nonatomic, assign) int64_t lastDuration;
//底部弹窗视图出现和消失
// Bottom popover view appears and disappears
@property (nonatomic, assign) BOOL clickState;
//底部当前弹窗视图
// Current popover view at the bottom
@property (nonatomic, strong) UIView *currentView;
//人脸特效
// Facial effects
@property (nonatomic, strong) NvsCaptureVideoFx *fxARFace;
//防止出现一次拍照出现多张照片
// Prevent multiple photos from appearing in one photo
@property (nonatomic, assign) BOOL isHaveImage;
//是否包含人脸
// Whether a face is included
@property (nonatomic, assign) BOOL isContentAI;
@property (nonatomic, weak) NvAlbumViewController *stickerAlbumVC;
@property (nonatomic, strong) NvCafCreator *cafCreator;
@property (nonatomic, copy) NSString *cafFileString;
@property (nonatomic, copy) NSString *cafUuidString;
@property (nonatomic, copy) NSString *cafGifString;

//界面按钮
// Interface button

//关闭
// Close
@property (nonatomic, strong) UIButton *backBtn;
//顶部中间按钮
// Top middle button
@property (nonatomic, strong) UIButton *moreBtn;
//变声
// The voice changes
@property (nonatomic, strong) NvGraphicBtn *voiceBtn;
@property (nonatomic, strong) UILabel *voicelab;

//音乐
//music
@property (nonatomic, strong) UIButton *musicBtn;
@property (nonatomic, strong) NvScrollLabel *musicLabel;
@property (nonatomic, strong) NvAudioPlayer *audioPlayer;

//切换摄像头
// Switch the camera
@property (nonatomic, strong) NvGraphicBtn *deviceBtn;
//闪光灯
// flash lamp
@property (nonatomic, strong) NvGraphicBtn *flashBtn;
//变焦
// Zoom
@property (nonatomic, strong) NvGraphicBtn *zoomBtn;
//曝光
// Exposure
@property (nonatomic, strong) NvGraphicBtn *exposureBtn;
@property (nonatomic, strong) NvGraphicBtn *FPSBtn;
//更多按钮背景界面
// More button background interface
@property (nonatomic, strong) UIView *propMoreBgView;
//道具
// Props
@property (nonatomic, strong) NvGraphicBtn *propBtn;
//贴纸
// Sticker
@property (nonatomic, strong) NvGraphicBtn *stickerBtn;
@property (nonatomic, strong) NvGraphicBtn *backgroundMattingBtn;
//抠象背景选照片按钮
// Click the photo button on the image background
@property (nonatomic, strong) NvGraphicBtn *bgSelectImgBtn;
//音频降噪按钮
// Audio noise reduction button
@property (nonatomic, strong) NvGraphicBtn *noiseSuppressionBtn;
//组合字幕
// Combine subtitles
@property (nonatomic, strong) NvGraphicBtn *captionBtn;
//美颜
//beauty
@property (nonatomic, strong) NvGraphicBtn *beautyBtn;
//美妆
//Beauty makeup
@property (nonatomic, strong) NvGraphicBtn *makeupBtn;
//滤镜
//filter
@property (nonatomic, strong) NvGraphicBtn *filterBtn;
//拍照、拍摄切换视图
//Take a photo, shoot switch view
@property (nonatomic, strong) UICollectionView *psTitleCollectionView;
//拍摄、拍照
//Shoot, photograph
@property (nonatomic, strong) UIButton *shootingBtn;
//完成
//complete
@property (nonatomic, strong) UIButton *finishBtn;
//录制时蓝色指示界面
//Blue indicates the interface during recording
@property (nonatomic, strong) UIView *timeIndicator;
//录制时长
//Recording duration
@property (nonatomic, strong) UILabel  *timeLabel;
//删除视频
//Delete video
@property (nonatomic, strong) UIButton *deleteBtn;
//视频个数
//Number of videos
@property (nonatomic, strong) UILabel  *videoCount;
//更多按钮背景界面
//More button background interface
@property (nonatomic, strong) UIImageView *moreBgView;
//当前道具
//Current item
@property (nonatomic, strong) NvCapturePropsModel *currentPropsModel;
//权限视图
//Permission view
@property (nonatomic, strong) NvTipsView *permissions;
//相册权限视图
//Album permission view
@property (nonatomic, strong) NvTipsView *photoView;
//手动对焦视图
//Manually focus the view
@property (nonatomic, strong) UIImageView *focusView;
//变焦弹窗视图
//Zoom popover view
@property (nonatomic, strong) NvCapturePopupView *zoomView;
//曝光弹窗视图
//Exposure popover view
@property (nonatomic, strong) NvCapturePopupView *exposureView;
@property (nonatomic, strong) YWISOSlider *zoomSlider;
@property (nonatomic, strong) YWISOSlider *exposureSlider;

//美妆视图
//Beauty view
@property (nonatomic, strong) NvMakeupView *makeupView;
//提示
//prompt
@property (nonatomic, strong) NvTipsView *tipAIView;
//锐化、美颜滤镜开启提示
//Sharpen and beauty filter open tips
@property (nonatomic, strong) UILabel *tipLabel;
//照片预览视图
//Photo preview view
@property (nonatomic, strong) UIImageView *picturePreview;
//外层view
//Outer view
@property (nonatomic, strong) UIView *picturePanelView;
//摄像头的能力
//Camera capability
@property (nonatomic, strong) NvsCaptureDeviceCapability *capability;

@property (nonatomic, strong) NvChangeVoiceBottomView *voiceBottomView;
@property (nonatomic, strong) NSArray *topVoiceImages;
@property (nonatomic, strong) NvsCaptureAudioFx *currentVoiceFx;

@property (nonatomic, assign) BOOL ifShowVoiceBtn;
@property (nonatomic, strong) NvsCaptureAnimatedSticker *currentAnimatedSticker;
@property (nonatomic, strong) NvRectView *rectView;
@property (nonatomic, strong) NvsCaptureCompoundCaption *currentCompoundCaption;

@property (nonatomic, strong) NvCaptionCompoundCaptionView *inputCompoundView;
@property (nonatomic, strong) NSMutableArray <NvStickerInfoModel *> *stickerInfoArray;
@property (nonatomic, strong) NvStickerInfoModel *currentStickerInfoModel;
@property (nonatomic, strong) NSMutableArray <NvCompoundCaptionInfoModel *>*captionInfoArray;
@property (nonatomic, strong) NvCompoundCaptionInfoModel *currentCompoundCaptionModel;
@property (nonatomic, assign) BOOL isSelecteCompound;
@property (nonatomic, strong) NvsCaptureCompoundCaption *selectCompoundCaption;
//帧率获取
//Frame rate acquisition
@property (nonatomic, strong) NSTimer *timer;
//帧率数值
//Frame rate value
@property (nonatomic, strong) UILabel  *fpsValueLab;
//抠像背景特效
//Background effects
@property (nonatomic, strong) NvsCaptureVideoFx *backgroundMattingFx;
@property (nonatomic, strong) NSMutableArray *albumSandBoxs;//
/// 拍照时间 Photo time
@property (nonatomic, assign) int64_t takePhotoTime;
/// 开启预览时间 Open preview time
@property (nonatomic, strong) NSDate *startPreviewTime;

/// 滤镜面板 Filter panel
@property (nonatomic, strong) NvTitleListViewController *filterListViewController;
/// 道具面板 Prop panel
@property (nonatomic, strong) NvTitleListViewController *propsListViewController;
/// 贴纸面板 Sticker panel
@property (nonatomic, strong) NvTitleListViewController *stickersListViewController;
/// 字幕面板 Subtitle panel
@property (nonatomic, strong) NvTitleListViewController *captionsListViewController;
/// 音频降噪面板 Audio noise reduction panel
@property (nonatomic, strong) NvCaptureNoiseSuppressionViewController *noiseSuppressionViewController;
/// 键盘遮挡视图 Keyboard occlusion view
@property (nonatomic, strong) UIView *keybordMaskView;
/// 当前面板 Current panel
@property (nonatomic, strong) NvTitleListViewController *currentTitleListVC;

/// 滤镜滑杆视图 Filter slider view
@property (nonatomic, strong) BLItemSlider *filterSlider;
@property (nonatomic, assign) BOOL appliedMakeup;
@property (nonatomic, assign) BOOL filterCanReplace;
//当前应用的整妆数据（处理整妆与美颜及滤镜模块的联动）
//Current application of makeup data (dealing with makeup and beauty and filter module interaction)
@property (nonatomic, strong) NvMakeupToolModel *currentMakeupVariableModel;
@property (nonatomic, strong) NvMakeupToolManager *makeupManager;
@property (nonatomic, assign) BOOL startupCaptureValue;
@property (nonatomic, strong) NvAdjustFxParamView *filterPrmView;
@property (nonatomic, assign) BOOL currentPropsContainFaceMesh;
@property (nonatomic, assign) BOOL currentPropsContainWarp;
@property (nonatomic, assign) NvAudioInterruptionState audioInterruption;
@property (nonatomic, assign) BOOL needReStartCapturePreview;
@property (nonatomic, strong) NSMutableString *capturescenePackageId;

@property (nonatomic, strong) CXCallObserver *callObserver;

@property (nonatomic, strong) NvMusicInfoModel *musicInfo;
@property (nonatomic, assign) int64_t effectDuration;
@end

@implementation NvCaptureViewController {
    dispatch_group_t _group;
    NvBeautyView *_beautyView;
    BOOL _isFirstAdvancedBeautyType;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        _currentPropsContainWarp = NO;
        _currentPropsContainFaceMesh = NO;
    }
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     初始化美摄SDK
     Initialize the meiyang SDK
     */
    self.streamingContext = [NvSDKUtils getSDKContext];
    if (!_streamingContext) {
        return;
    }
    self.effectDuration = 300000000000;
    self.audioInterruption = NvAudioInterruptionStateNone;
    self.callObserver = [[CXCallObserver alloc]init];
    [self.callObserver setDelegate:self queue:dispatch_get_main_queue()];
    
    for (CXCall *call in self.callObserver.calls) {
        if (call.outgoing || call.hasConnected){
            self.audioInterruption = NvAudioInterruptionStateAffecting;
        }
    }
    
    NSString *backgroundPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Asset/BackgroundMatting"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:backgroundPath isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:backgroundPath withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        [[NSFileManager defaultManager] removeItemAtPath:backgroundPath error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:backgroundPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    self.startupCaptureValue = NO;
    self.captureVM = [NvCaptureModularVM new];
    self.captureVM.uiDelegate = self;
    [self addObservers];
    self.view.backgroundColor = [UIColor whiteColor];
    self.videoPathArray = [NSMutableArray array];
    self.durationArray = [NSMutableArray array];

    self.psTitleArray = [NSMutableArray array];
    self.stickerInfoArray = [NSMutableArray array];
    self.captionInfoArray = [NSMutableArray array];
    self.albumSandBoxs = [NSMutableArray array];
    
    self.needReStartCapturePreview = NO;
    [self.captureVM installFilterAndPropsAsset];
    [self.captureVM getFontDatas];
    self.appliedMakeup = NO;
    self.filterCanReplace = YES;
    self.makeupManager = [NvMakeupToolManager new];
    self.makeupManager.delegate = self;
    self.makeupManager.mode = NvMakeupModulerModeCapture;
    
    self.captureVM.makeupManager = self.makeupManager;
    
    _currentInteger = 0;
    NvPsTitleModel *psTitleModel_1 = [NvPsTitleModel new];
    psTitleModel_1.name = NvLocalString(@"photo", @"拍摄");
    psTitleModel_1.selected = YES;
    NvPsTitleModel *psTitleModel_2 = [NvPsTitleModel new];
    psTitleModel_2.name = NvLocalString(@"shoot", @"视频");
    psTitleModel_2.selected = NO;
    [self.psTitleArray addObject:psTitleModel_1];
    [self.psTitleArray addObject:psTitleModel_2];
    
    /*
     检查摄像头权限
     Check camera permissions
     */
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
                            /*
                             提示麦克风权限未获得
                             Prompt microphone permission not obtained
                             */
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf startupCapture];
                                [weakSelf.view addSubview:weakSelf.permissions];
                            });
                        }
                    }];
                }
            } else {
                /*
                 提示摄像头权限未获得
                 Prompt that the camera permission is not obtained
                 */
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view addSubview:weakSelf.permissions];
                });
            }
        }];
    } else if (authStatus == AVAuthorizationStatusDenied) {
        /*
         提示摄像头权限未获得
         Prompt that the camera permission is not obtained
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view addSubview:weakSelf.permissions];
        });
    } else {
        authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (authStatus == AVAuthorizationStatusDenied) {
            /*
             提示麦克风权限未获得
             Prompt microphone permission not obtained
             */
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view addSubview:weakSelf.permissions];
            });
        }
        [weakSelf startupCapture];
    }
    
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {

        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([_streamingContext getStreamingEngineState] != NvsStreamingEngineState_CapturePreview) {
        [self startCapturePreview];
        _streamingContext.delegate = self;
    }

    self.navigationController.navigationBar.hidden = YES;
    [self selectCaptureMode];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /*
     防止锁屏
     Prevent screen lock
     */
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

#pragma mark - 初始化美摄sdk、创建界面ui，配置数据
/*
 初始化美摄sdk、创建界面ui，配置数据
 Initialize the meiyang SDK, create interface UI, and configure data
 */
- (void)startupCapture{

    /*
     设置回调接口
     Set callback interface
     */
    _streamingContext.delegate = self;

    /*
     检查可用采集设备的数量
     Check the number of available collection devices
     */
    if ([_streamingContext captureDeviceCount] == 0) {
        NSLog(@"没有可用于采集的设备！ There is no equipment available for collection!");
    }

    /*
     创建采集预览窗口并连接到摄像头采集次输出
     Create a capture preview window and connect to the camera to capture secondary output
     */
    self.liveWindowBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width*16/9)];
    _liveWindowBack = [[NvsLiveWindow alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width*16/9)];
    _liveWindow = [[NvsLiveWindow alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width*16/9)];

    [self.view addSubview:self.liveWindowBGView];
    
    _liveWindowBack.fillMode = NvsLiveWindowFillModePreserveAspectFit;
    [self.liveWindowBGView addSubview:_liveWindowBack];
    _liveWindow.fillMode = NvsLiveWindowFillModePreserveAspectFit;
    [self.liveWindowBGView addSubview:_liveWindow];
    _curLiveWindow = _liveWindowBack;
    if (![_streamingContext connectCapturePreviewWithLiveWindow:_curLiveWindow]) {
        NSLog(@"连接预览窗口失败！Failed to connect to preview window!");
    }
    _curLiveWindow = _liveWindow;
    if (![_streamingContext connectCapturePreviewWithLiveWindow:_curLiveWindow]) {
        NSLog(@"连接预览窗口失败！Failed to connect to preview window!");
    }

    self.currentDeviceIndex = [self frontCameraDeviceIndex];
    if (![self startCapturePreview]) {
        NSLog(@"启动摄像头采集预览失败！Failed to start camera capture preview!");
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    tap.numberOfTapsRequired = 1;
    [_liveWindow addGestureRecognizer:tap];

    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    tap.numberOfTapsRequired = 1;
    [_liveWindowBack addGestureRecognizer:tap1];
    
    [self initARFace];
    [self addSubViews];
    [self addVoiceView];
    [self addZoomView];
    [self addExposureView];
    [self initFocusView];
    [self addBeauty];
    [self addMakeup];
    [self configParameter];
    [self addPicturePreview];
    [self initRectView];
    
    NSNumber * beautyNum = NV_UserInfo(@"DefaultFilterBeautyEffect");
    if ((beautyNum && beautyNum.intValue == 1) || !beautyNum) {
        
        self.startupCaptureValue = YES;
        [self applyDefaultFilter];
        [self.captureVM applyBeautyEffectsStyleWith:YES];
    }else{
        
        [self.captureVM applyBeautyEffectsStyleWith:NO];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self collectionView:self.psTitleCollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    });
    
}

#pragma mark - 添加子视图
/*
 添加子视图
 Add subview
 */
- (void)addSubViews{
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setImage:NvImageNamed(@"Nvback") forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreBtn setImage:NvImageNamed(@"Nvmore") forState:UIControlStateNormal];
    [self.moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.musicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.musicBtn addTarget:self action:@selector(musicBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.musicBtn];
    UIImageView *musicImage = [[UIImageView alloc] init];
    musicImage.image = NvImageNamed(@"NvSelectMusic");
    [self.musicBtn addSubview:musicImage];
    [musicImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.musicBtn);
        make.centerY.equalTo(self.musicBtn);
        make.width.height.offset(15*SCREENSCALE);
    }];
    self.musicLabel = [[NvScrollLabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.musicLabel.numberOfLines = 1;
    self.musicLabel.textColor = UIColor.whiteColor;
    self.musicLabel.text = NvLocalString(@"selectMusic", @"选择音乐");
    [self.musicBtn addSubview:self.musicLabel];
    [self.musicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(musicImage.mas_right).offset(5*SCREENSCALE);
        make.right.equalTo(self.musicBtn).offset(-5*SCREENSCALE);
        make.centerY.equalTo(self.musicBtn);
    }];
    
    self.fpsValueLab = [[UILabel alloc] init];
    self.fpsValueLab.textAlignment = NSTextAlignmentCenter;
    self.fpsValueLab.font = [UIFont systemFontOfSize:15];
    self.fpsValueLab.textColor = [UIColor whiteColor];
    [self.view addSubview:self.fpsValueLab];
    self.fpsValueLab.hidden = YES;
    
    self.moreBgView = [[UIImageView alloc] init];
    [self.view addSubview:self.moreBgView];
    self.moreBgView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#66000000"];
    self.moreBgView.userInteractionEnabled = YES;
    
    self.propMoreBgView = [[UIView alloc] init];
    self.propMoreBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
    [self.view addSubview:self.propMoreBgView];
    
    self.deviceBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Turning", @"翻转") withImageNormal:@"Nvdevice" withImageSelected:nil];
    [self.deviceBtn setCustomFontSize:10*SCREENSCALE];
    [self.deviceBtn setCustomLabelTextRightAligent];
    [self.deviceBtn addTarget:self action:@selector(deviceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.propMoreBgView addSubview:self.deviceBtn];
    
    self.stickerBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Sticker", @"贴纸") withImageNormal:@"capture_sticker_image" withImageSelected:nil];
    [self.stickerBtn setCustomFontSize:10*SCREENSCALE];
    [self.stickerBtn setCustomLabelTextRightAligent];
    [self.stickerBtn addTarget:self action:@selector(stickerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.propMoreBgView addSubview:self.stickerBtn];
    
    self.captionBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"CompoundCaption", @"组合字幕") withImageNormal:@"capture_caption_image" withImageSelected:nil];
    [self.captionBtn setCustomFontSize:10*SCREENSCALE];
    [self.captionBtn setCustomLabelTextRightAligent];
    [self.captionBtn addTarget:self action:@selector(captionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.propMoreBgView addSubview:self.captionBtn];
    
    self.backgroundMattingBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Matting", @"抠像") withImageNormal:@"capture_background_matting_image" withImageSelected:nil];
    [self.backgroundMattingBtn setCustomFontSize:10*SCREENSCALE];
    [self.backgroundMattingBtn setCustomLabelTextRightAligent];
    [self.backgroundMattingBtn addTarget:self action:@selector(backgroundMattingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.propMoreBgView addSubview:self.backgroundMattingBtn];
    
    self.bgSelectImgBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Matting background", @"抠像背景") withImageNormal:@"capture_background_select_image" withImageSelected:nil];
    [self.bgSelectImgBtn setCustomFontSize:10*SCREENSCALE];
    [self.bgSelectImgBtn setCustomLabelTextRightAligent];
    [self.bgSelectImgBtn addTarget:self action:@selector(backgroundMattingSelectImgBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.propMoreBgView addSubview:self.bgSelectImgBtn];
    
    self.noiseSuppressionBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Capture noise suppression", @"音频降噪") withImageNormal:@"NvCaptureNoiseSuppression" withImageSelected:nil];
    [self.noiseSuppressionBtn setCustomFontSize:10*SCREENSCALE];
    [self.noiseSuppressionBtn setCustomLabelTextRightAligent];
    [self.noiseSuppressionBtn addTarget:self action:@selector(noiseSuppressionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.propMoreBgView addSubview:self.noiseSuppressionBtn];
    self.noiseSuppressionBtn.hidden = YES;
    
    self.voiceBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:@"" withImageNormal:@"NvChangeVoiceRect" withImageSelected:nil];
    [self.voiceBtn setCustomFontSize:10*SCREENSCALE];
    [self.voiceBtn addTarget:self action:@selector(voiceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.propMoreBgView addSubview:self.voiceBtn];
    
    self.voicelab = [[UILabel alloc] init];
    self.voicelab.textAlignment = NSTextAlignmentCenter;
    self.voicelab.text = NvLocalString(@"Change Voice", @"变声");
    self.voicelab.font = [UIFont systemFontOfSize:8*SCREENSCALE];
    self.voicelab.textColor = [UIColor whiteColor];
    [self.voiceBtn addSubview:self.voicelab];
    
    [self.voiceBtn setCustomImageSize:CGSizeMake(26*SCREENSCALE, 26*SCREENSCALE) offset:0];
    
    self.zoomBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"zoom", @"变焦") withImageNormal:@"Nvzoom" withImageSelected:nil];
    [self.zoomBtn setCustomFontSize:11*SCREENSCALE];
    [self.zoomBtn addTarget:self action:@selector(zoomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.exposureBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"exposure", @"曝光") withImageNormal:@"Nvexposure" withImageSelected:nil];
    [self.exposureBtn setCustomFontSize:11*SCREENSCALE];
    [self.exposureBtn addTarget:self action:@selector(exposureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.flashBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"flash", @"补光灯") withImageNormal:@"Nvflash_off" withImageSelected:@"Nvflash_on"];
    [self.flashBtn setCustomFontSize:11*SCREENSCALE];
    [self.flashBtn addTarget:self action:@selector(flashBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.FPSBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Frame rate", @"帧率") withImageNormal:@"capture_frame_rate_off" withImageSelected:@"capture_frame_rate_on"];
    [self.FPSBtn setCustomFontSize:11*SCREENSCALE];
    self.FPSBtn.btnLabel.numberOfLines = 2;
    [self.FPSBtn addTarget:self action:@selector(fpsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.makeupBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"capture.makeup", @"美妆") withImageNormal:@"Nvmakeup" withImageSelected:nil];
    [self.makeupBtn setCustomFontSize:11*SCREENSCALE];
    [self.makeupBtn addTarget:self action:@selector(makeupBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.beautyBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"capture.beauty", @"美颜") withImageNormal:@"Nvbeauty" withImageSelected:nil];
    [self.beautyBtn setCustomFontSize:11*SCREENSCALE];
    [self.beautyBtn addTarget:self action:@selector(beautyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.filterBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Filter", @"滤镜") withImageNormal:@"Nvfilter" withImageSelected:nil];
    [self.filterBtn setCustomFontSize:11*SCREENSCALE];
    [self.filterBtn addTarget:self action:@selector(filterBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.propBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Props", @"道具") withImageNormal:@"capture_prop_image" withImageSelected:nil];
    [self.propBtn setCustomFontSize:11*SCREENSCALE];
    [self.propBtn addTarget:self action:@selector(propBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(60*SCREENSCALE, 30*SCREENSCALE);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 60*SCREENSCALE, 0, 0);
    self.psTitleCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
    self.psTitleCollectionView.backgroundColor = UIColor.clearColor;
    self.psTitleCollectionView.delegate = self;
    self.psTitleCollectionView.dataSource = self;
    [self.psTitleCollectionView registerClass:[NvPsTitleCollectionViewCell class] forCellWithReuseIdentifier:@"NvpsTitleCell"];
    
    self.shootingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shootingBtn setImage:NvImageNamed(@"Nv_capture_recording") forState:UIControlStateNormal];
    [self.shootingBtn setImage:NvImageNamed(@"Nv_capture_suspend") forState:UIControlStateSelected];
    [self.shootingBtn addTarget:self action:@selector(shootingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteBtn setImage:NvImageNamed(@"Nv_capture_delete") forState:UIControlStateNormal];
    [self.deleteBtn addTarget:self action:@selector(deleteBtnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.finishBtn setImage:NvImageNamed(@"Nv_capture_finish") forState:UIControlStateNormal];
    [self.finishBtn addTarget:self action:@selector(finishBtnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.timeLabel = [UILabel new];
    self.timeLabel.text = @"00:00";
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = [NvUtils fontWithSize:12];
    
    self.timeIndicator = [[UIView alloc] init];
    self.timeIndicator.layer.cornerRadius = 2.5*SCREENSCALE;
    self.timeIndicator.layer.masksToBounds = YES;
    self.timeIndicator.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    
    self.videoCount = [UILabel new];
    self.videoCount.userInteractionEnabled = NO;
    self.videoCount.font = [UIFont systemFontOfSize:34.5*SCREENSCALE];
    self.videoCount.textColor = [UIColor whiteColor];
    
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.moreBtn];
    [self.view addSubview:self.voiceBtn];
    [self.view addSubview:self.musicBtn];
    self.voiceBtn.hidden = YES;
    [self.moreBgView addSubview:self.flashBtn];
    [self.moreBgView addSubview:self.zoomBtn];
    [self.moreBgView addSubview:self.exposureBtn];
    [self.moreBgView addSubview:self.FPSBtn];
    
    [self.view addSubview:self.makeupBtn];
    [self.view addSubview:self.beautyBtn];
    [self.view addSubview:self.filterBtn];
    [self.view addSubview:self.propBtn];
    [self.view addSubview:self.shootingBtn];
    [self.view addSubview:self.psTitleCollectionView];
    [self.view addSubview:self.deleteBtn];
    [self.view addSubview:self.finishBtn];
    [self.view addSubview:self.timeIndicator];
    [self.view addSubview:self.timeLabel];
    [self.shootingBtn addSubview:self.videoCount];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NV_STATUSBARHEIGHT);
        make.left.equalTo(self.view).offset(13 * SCREENSCALE);
        make.width.offset(33 * SCREENSCALE);
        make.height.offset(33 * SCREENSCALE);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-20*SCREENSCALE);
        make.centerY.equalTo(self.backBtn);
        make.width.offset(34 * SCREENSCALE);
        make.height.offset(34 * SCREENSCALE);
    }];
    
    [self.musicLabel sizeToFit];
    [self.musicBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.backBtn);
        make.width.offset(15 * SCREENSCALE + 10 * SCREENSCALE + self.musicLabel.width);
        make.height.offset(50 * SCREENSCALE);
    }];
    
    [self.fpsValueLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.deviceBtn.mas_bottom).offset(5.0f);
        make.centerX.mas_equalTo(self.deviceBtn.mas_centerX);
        make.width.offset(50 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    
    [self.moreBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.moreBtn.mas_bottom);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(260*SCREENSCALE);
        make.height.mas_equalTo(60*SCREENSCALE);
    }];
    
    [self.zoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.moreBgView.mas_centerY);
        make.left.mas_equalTo(KScale6s(10));
        make.width.mas_equalTo(60*SCREENSCALE);
        make.height.mas_equalTo(50*SCREENSCALE);
    }];
    
    [self.exposureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.zoomBtn.mas_right).offset(0);
        make.centerY.equalTo(self.moreBgView.mas_centerY);
        make.size.equalTo(self.zoomBtn);
    }];
    
    [self.flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.exposureBtn.mas_right).offset(0);
        make.centerY.equalTo(self.moreBgView.mas_centerY);
        make.size.equalTo(self.zoomBtn);
    }];
    [self.FPSBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.flashBtn.mas_right).offset(0);
        make.centerY.equalTo(self.moreBgView.mas_centerY);
        make.size.equalTo(self.zoomBtn);
    }];
    
    [self.zoomBtn setCustomImageSize:CGSizeMake(28*SCREENSCALE, 28*SCREENSCALE) offset:0];
    [self.exposureBtn setCustomImageSize:CGSizeMake(28*SCREENSCALE, 28*SCREENSCALE) offset:0];
    [self.FPSBtn setCustomImageSize:CGSizeMake(28*SCREENSCALE, 28*SCREENSCALE) offset:0];
    [self.flashBtn setCustomImageSize:CGSizeMake(28*SCREENSCALE, 28*SCREENSCALE) offset:0];
    [self.zoomBtn setCustomFontSize:11*SCREENSCALE];
    [self.exposureBtn  setCustomFontSize:11*SCREENSCALE];
    [self.flashBtn setCustomFontSize:11*SCREENSCALE];
    [self.FPSBtn setCustomFontSize:11*SCREENSCALE];
    self.moreBgView.hidden = YES;
    
    CGFloat btnWidth = KScale6s(60);
    CGFloat btnHeight = KScale6s(75);
    [self.shootingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-50 * SCREENSCALE);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.offset(btnHeight);
        make.height.offset(btnHeight);
    }];
    
    [self.beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
        make.right.equalTo(self.shootingBtn.mas_left).offset(-10*SCREENSCALE);
        make.width.mas_equalTo(btnWidth);
        make.height.mas_equalTo(btnHeight);
    }];
    
    [self.makeupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
        make.left.equalTo(self.view.mas_left).offset(15*SCREENSCALE);
        make.width.mas_equalTo(btnWidth);
        make.height.mas_equalTo(btnHeight);
    }];

    [self.filterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
        make.left.equalTo(self.shootingBtn.mas_right).offset(10*SCREENSCALE);
        make.width.mas_equalTo(btnWidth);
        make.height.mas_equalTo(btnHeight);
    }];
    
    [self.propBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
        make.right.equalTo(self.view.mas_right).offset(-15*SCREENSCALE);
        make.width.mas_equalTo(btnWidth);
        make.height.mas_equalTo(btnHeight);
    }];

    [self.propMoreBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.moreBtn.mas_bottom).offset(26*SCREENSCALE);
        make.right.mas_equalTo(self.moreBtn);
        make.width.offset(34 * SCREENSCALE);
    }];
    
    [self.deviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.propMoreBgView);
        make.centerX.mas_equalTo(self.propMoreBgView);
        make.width.mas_equalTo(50.0);
        make.height.mas_equalTo(40.0);
    }];
    
    [self.stickerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deviceBtn.mas_bottom).offset(20*SCREENSCALE);
        make.centerX.mas_equalTo(self.propMoreBgView);
        make.width.mas_equalTo(50.0);
        make.height.mas_equalTo(40.0);
    }];
    
    [self.captionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.stickerBtn.mas_bottom).offset(20*SCREENSCALE);
        make.centerX.mas_equalTo(self.propMoreBgView);
        make.width.mas_equalTo(50.0);
        make.height.mas_equalTo(40.0);
    }];
    [self.backgroundMattingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.captionBtn.mas_bottom).offset(20*SCREENSCALE);
        make.centerX.mas_equalTo(self.propMoreBgView);
        make.width.mas_equalTo(50.0);
        make.height.mas_equalTo(40.0);
    }];
    
    [self.bgSelectImgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.backgroundMattingBtn.mas_bottom).offset(30*SCREENSCALE);
        make.centerX.mas_equalTo(self.propMoreBgView);
        make.width.mas_equalTo(50.0);
        make.height.mas_equalTo(40.0);
    }];
    
    [self.noiseSuppressionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgSelectImgBtn.mas_bottom).offset(-40*SCREENSCALE);
        make.centerX.mas_equalTo(self.propMoreBgView);
        make.width.mas_equalTo(50.0);
        make.height.mas_equalTo(40.0);
    }];
    
    [self.voiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgSelectImgBtn.mas_bottom).offset(-40*SCREENSCALE);
        make.centerX.mas_equalTo(self.propMoreBgView);
        make.width.mas_equalTo(50.0);
        make.height.mas_equalTo(40.0);
    }];
    
    [self.voicelab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.voiceBtn.mas_centerX);
        make.centerY.mas_equalTo(self.voiceBtn.btnImageView.mas_centerY);
    }];
    
    [self.propMoreBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.voiceBtn.mas_bottom);
    }];
    
    [self.psTitleCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shootingBtn.mas_bottom).offset(7*SCREENSCALE);
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.offset(35 * SCREENSCALE);
        make.width.offset(180 * SCREENSCALE);
    }];
    
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.shootingBtn.mas_left).offset(-56 * SCREENSCALE);
        make.bottom.equalTo(self.shootingBtn.mas_top).offset(-22 * SCREENSCALE);
        make.width.offset(35 * SCREENSCALE);
        make.height.offset(35 * SCREENSCALE);
    }];

    [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.shootingBtn.mas_right).offset(56 * SCREENSCALE);
        make.centerY.equalTo(self.deleteBtn.mas_centerY);
        make.width.offset(40 * SCREENSCALE);
        make.height.offset(40 * SCREENSCALE);
    }];

    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.deleteBtn.mas_centerY);
    }];
    
    [self.timeIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.timeLabel.mas_left).offset(-5*SCREENSCALE);
        make.centerY.equalTo(self.timeLabel.mas_centerY);
        make.width.mas_equalTo(5*SCREENSCALE);
        make.height.mas_equalTo(5*SCREENSCALE);
    }];

    [self.videoCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.shootingBtn.mas_centerX);
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
    }];
    self.timeIndicator.hidden = YES;
    self.bgSelectImgBtn.hidden = YES;
    [self makeSubviewsUnderBiggerRatio];
}

#pragma mark  添加变焦视图
/*
 添加变焦视图
 Add zoom view
 */
- (void)addZoomView{
    [self.view addSubview:self.zoomSlider];
    self.zoomSlider.hidden = YES;
}

#pragma mark  添加曝光视图
/*
 添加曝光视图
 Add Exposure view
 */
- (void)addExposureView {
    [self.view addSubview:self.exposureSlider];
    self.exposureSlider.hidden = YES;
}

#pragma mark  添加拍照预览视图
/*
 添加拍照预览视图
 Add photo preview view
 */
- (void)addPicturePreview{
    _picturePanelView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, SCREENHEIGHT)];
    _picturePanelView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:_picturePanelView];
    
    _picturePreview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _picturePanelView.frame.size.width, _picturePanelView.frame.size.height)];
    _picturePreview.contentMode = UIViewContentModeScaleAspectFit;
    [_picturePanelView addSubview:_picturePreview];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn addTarget:self action:@selector(cancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setImage:NvImageNamed(@"Nvback") forState:UIControlStateNormal];
    [_picturePanelView addSubview:cancelBtn];
    
    UIButton *determineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [determineBtn addTarget:self action:@selector(determineBtn:) forControlEvents:UIControlEventTouchUpInside];
    [determineBtn setImage:NvImageNamed(@"NvCaptureDetermine") forState:UIControlStateNormal];
    [_picturePanelView addSubview:determineBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.picturePanelView.mas_top).offset(NV_STATUSBARHEIGHT);
        make.left.equalTo(self.picturePanelView.mas_left).offset(13 * SCREENSCALE);
    }];
    
    [determineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.picturePanelView.mas_top).offset(NV_STATUSBARHEIGHT);
        make.right.equalTo(self.picturePanelView.mas_right).offset(-13 * SCREENSCALE);
    }];
}

/*
 添加贴纸视图
 Add caption view
 */
- (void)addIputCompoundView {
    if (!self.inputCompoundView) {
        self.inputCompoundView = [[NvCaptionCompoundCaptionView  alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, SCREENHEIGHT) ];
        [self.view addSubview:self.inputCompoundView];
    }
}

#pragma mark 添加变声视图
/*
 添加变声视图
 Add voice change view
 */
- (void)addVoiceView {
    self.topVoiceImages = @[NvLocalString(@"None", @"无"),NvLocalString(@"Male", @"男声"),NvLocalString(@"Reverb", @"混响"),NvLocalString(@"Wahwah", @"电子"),NvLocalString(@"Hall", @"礼堂"),NvLocalString(@"Female", @"女声"),NvLocalString(@"Catoon", @"卡通"),NvLocalString(@"Echo", @"回声"),NvLocalString(@"Monster", @"怪兽")];
    __weak typeof(self)weakSelf = self;
    self.voiceBottomView = [[NvChangeVoiceBottomView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 160 * SCREENSCALE + INDICATOR) ];
    self.voiceBottomView.backgroundColor = [UIColor whiteColor];
    self.voiceBottomView.selectItemClick = ^(ChangeVoiceType type, NSString * _Nonnull fx) {
        if (weakSelf.currentVoiceFx) {
            [weakSelf.streamingContext removeCaptureAudioFx:weakSelf.currentVoiceFx.index];
            weakSelf.currentVoiceFx = nil;
        }
        weakSelf.currentVoiceFx = [weakSelf.streamingContext appendBuiltinCaptureAudioFx:fx];

        weakSelf.voicelab.text = weakSelf.topVoiceImages[type];
    };
    [self.view addSubview:self.voiceBottomView];
    
}


#pragma mark 添加美颜视图
/*
 添加美颜视图
 Add beauty view
 */
- (void)addBeauty {
    
    self.beautyView = [[NvBeautyView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 628 * SCREENSCALE)];
    self.beautyView.captureVM = self.captureVM;
    self.beautyView.viewCategory = NvBeautyBeautyTemplate;
    [self.view addSubview:self.beautyView];
}

#pragma mark 添加美妆视图
/*
 添加美妆视图
 Add beauty view
 */
- (void)addMakeup{
    self.makeupView = [[NvMakeupView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 604 * SCREENSCALE)];
    self.makeupView.delegate = self;
    [self.view addSubview:self.makeupView];
}

#pragma mark 添加手动对焦视图
/*
 添加手动对焦视图
 Add manual focus view
 */
- (void)initFocusView{
    self.focusView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.focusView.alpha = 0;
    [_focusView setImage:NvImageNamed(@"NvsCaptureFocus")];
    [self.view addSubview:self.focusView];
}

#pragma mark 相册权限视图
/*
 相册权限视图
 Album permissions view
 */
- (void)tipView{
    self.photoView = [[NvTipsView alloc]initWithFrame:self.view.frame withPrompt:NvLocalString(@"Save failed", @"保存失败") describeTitle:NvLocalString(@"Album permissions", @"您还没有允许相册访问权限") describeContent:nil buttonText:NvLocalString(@"Know", @"知道了") withCenter:YES];
    [_photoView.clickBtn addTarget:self action:@selector(knowClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_photoView];
}

/**
 初始化字幕选中框
 Initialize caption check box
 */
- (void)initRectView {
    self.rectView = [[NvRectView alloc] initWithFrame:CGRectZero type:NV_ANIMATED_STICKER];
    self.rectView.layer.masksToBounds = YES;
    [self.liveWindowBGView addSubview:self.rectView];
    [self.rectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    self.rectView.delegate = self;
    self.rectView.backgroundColor = [UIColor clearColor];
    [self.rectView hideVoiceButton:YES];
    self.rectView.hidden = YES;
}

#pragma mark - 给手动对焦视图添加动画
/*
 给手动对焦视图添加动画
 Animating a manual focus view
 
 @param currentPoint 当前触摸的点
 Current touch point
 */
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

#pragma mark - 没有购买权限人脸的提示
/*
 没有购买权限人脸的提示
 No purchase permission
 
 */
- (void)switchActionShowToast{
    [self showTip];
}

#pragma mark 没有购买权限人脸的提示视图
/*
 没有购买权限人脸的提示视图
 Prompt view of faces without permission to purchase
 
 */
- (void)showTip {
    if (!self.tipAIView) {
        self.tipAIView = [[NvTipsView alloc]initWithFrame:self.view.frame withPrompt:NvLocalString(@"Tips", @"提示") describeTitle:NvLocalString(@"authorization", @"请移步官网，联系商务人员索要有人脸识别授权") describeContent:nil buttonText:NvLocalString(@"Know", @"知道了") withCenter:YES];
        [self.tipAIView.clickBtn addTarget:self action:@selector(removeTip) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.tipAIView];
    }
}

#pragma mark 移除没有购买权限人脸的提示
/*
 移除没有购买权限人脸的提示
 Remove the prompt without purchasing permission
 
 */
- (void)removeTip {
    [self.tipAIView removeFromSuperview];
    self.tipAIView = nil;
}

- (void)presentMakeupUnReplaceableAlertController {
    
    [UIAlertController presentAlertFromVC:self
                                    title:nil
                                  message:NvLocalString(@"forbidden to modify this item", @"此整妆不支持修改此项")
                        buttonTitleColors:nil
                        cancelButtonTitle:nil
                         otherButtonTitle:NvLocalString(@"Sure", @"确定")
                       cancelButtonAction:nil
                        otherButtonAction:nil];

}

- (void)presentBeautyTypeForbiddenAppledAlertController {
    
    [UIAlertController presentAlertFromVC:self
                                    title:nil
                                  message:NvLocalString(@"forbidden to apply this beauty type item", @"不可与当前道具内美型叠加")
                        buttonTitleColors:nil
                        cancelButtonTitle:nil
                         otherButtonTitle:NvLocalString(@"Sure", @"确定")
                       cancelButtonAction:nil
                        otherButtonAction:nil];

}

#pragma mark  关闭退出
/*
 关闭退出
 Close exit
 */
- (void)backBtnClick:(UIButton *)sender{
    if(_currentInteger>0 && _videoPathArray.count > 0){
        
        NVWeakSelf
        [UIAlertController presentAlertFromVC:self
                                        title:nil
                                      message:NvLocalString(@"Discard saving all captured videos",@"放弃保存当前所有拍摄内容")
                            buttonTitleColors:nil
                            cancelButtonTitle:NvLocalString(@"Cancel",@"取消")
                             otherButtonTitle:NvLocalString(@"Sure", @"确定")
                           cancelButtonAction:nil
                            otherButtonAction:^(UIAlertAction * _Nonnull action) {
            
            [weakSelf popToLastController];
        }];
    }else{
        
        [self popToLastController];
    }
}

-(void)backgroundMattingBtnClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self.voiceBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bgSelectImgBtn.mas_bottom).offset(30*SCREENSCALE);
        }];
        self.bgSelectImgBtn.hidden = NO;
        self.backgroundMattingBtn.btnLabel.text = NvLocalString(@"Cancel matting" , @"取消抠象");
        
        [self checkExistBackgroundMattingFx];
        if (!self.backgroundMattingFx) {
            self.backgroundMattingFx = [self.streamingContext insertBuiltinCaptureVideoFx:@"Segmentation Background Fill" withInsertPosition:0];
        }
        
        [self.backgroundMattingFx setMenuVal:@"Segment Type" val:@"Background"];
        
        [self.backgroundMattingFx setColorVal:@"Background Color" val:&(NvsColor){0,0,0,0}];
    }else {
        [self.voiceBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bgSelectImgBtn.mas_bottom).offset(-40*SCREENSCALE);
        }];
        self.bgSelectImgBtn.hidden = YES;
        self.backgroundMattingBtn.btnLabel.text = NvLocalString(@"Matting" , @"抠像");
        
        if(self.backgroundMattingFx) {
            [self.streamingContext removeCaptureVideoFx:self.backgroundMattingFx.index];
            self.backgroundMattingFx = nil;
        }
        
        [self.streamingContext removeCurrentCaptureScene];
    }
}

- (void)backgroundMattingSelectImgBtnClick:(UIButton *)btn {
    [self installCapturescene];
    NvAlbumViewController *album = [NvAlbumViewController new];
    album.delegate = self;
    album.mutableSelect = NO;
    album.showMattingView = YES;
    [album customSelectAssetButtonText:NvLocalString(@"Start making", @"开始制作")];
    NvBaseNavigationController *nav = [[NvBaseNavigationController alloc] initWithRootViewController:album];
    nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)installCapturescene{
    self.capturescenePackageId = [NSMutableString string];
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] bundlePath];
    NSString *string = [bundlePath stringByAppendingPathComponent:@"capturescene.bundle"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *contents = [fm contentsOfDirectoryAtPath:string error:nil];
    string = [string stringByAppendingPathComponent:contents.firstObject];
    NSString * licensePath = [NSString convertFilePathToNewPath:string WithExtension:@"lic"];
    [self.streamingContext.assetPackageManager installAssetPackage:string license:licensePath type:NvsAssetPackageType_CaptureScene sync:YES assetPackageId:self.capturescenePackageId];
}

#pragma mark - 音频降噪按钮点击 Audio noise reduction button click
- (void)noiseSuppressionBtnClick:(UIButton *)btn {
    CGRect rect = CGRectZero;
    if (NV_STATUSBARHEIGHT>20){
        rect = CGRectMake(0, CGRectGetMaxY(self.liveWindow.frame), SCREENWIDTH,SCREENHEIGHT-  CGRectGetMaxY(self.liveWindow.frame));
    }else{
        rect = CGRectMake(0, SCREENHEIGHT-120*SCREENSCALE, SCREENWIDTH,120*SCREENSCALE);
    }
    
    if (!self.noiseSuppressionViewController) {
        self.noiseSuppressionViewController = [[NvCaptureNoiseSuppressionViewController alloc]init];
    }
    
    [self jumpVC:self.noiseSuppressionViewController withRect:rect];
}

#pragma mark 切换摄像头方法
/*
 切换摄像头方法
 Switch camera method
 */
- (void)deviceBtnClick:(UIButton *)sender{
    UIView *fromView;
    UIView *toView;
    if ([_curLiveWindow isEqual:_liveWindow]) {
        fromView = _liveWindow;
        toView = _liveWindowBack;
    } else {
        fromView = _liveWindowBack;
        toView = _liveWindow;
    }
    _curLiveWindow = (NvsLiveWindow *)toView;
    
    if (![_streamingContext connectCapturePreviewWithLiveWindow:_curLiveWindow]) {
        NSLog(@"连接预览窗口失败！Failed to connect to preview window!");
    }
    
    if (_currentDeviceIndex == 0) {
        _currentDeviceIndex = 1;
    } else {
        _currentDeviceIndex = 0;
    }
    
    if (_currentDeviceIndex == [self frontCameraDeviceIndex]) {
        _flashBtn.alpha = 0.7;
        _flashBtn.userInteractionEnabled = NO;
        _flashBtn.selected = NO;
    } else {
        _flashBtn.alpha = 1;
        _flashBtn.userInteractionEnabled = YES;
    }
     [self.fxARFace setStringVal:@"Scene Id" val:@""];
    
    [UIView transitionFromView:fromView toView:toView duration:0.3 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
        [self.liveWindowBGView sendSubviewToBack:self.curLiveWindow];
    }];
    if ([self startCapturePreview]) {
        if (self.backgroundMattingFx) {
            
            [self.backgroundMattingFx setMenuVal:@"Segment Type" val:@"Background"];
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.currentPropsModel) {
                NvsARSceneCameraPreset preset;
                BOOL cameraPreset = [self.streamingContext.assetPackageManager getARSceneAssetPackage:self.currentPropsModel.packageId cameraPreset:&preset];
                if (cameraPreset) {
                    [self.fxARFace setFloatVal:@"Face Camera Fovy" val:preset.fovy];
                } else {
                    [self.fxARFace setFloatVal:@"Face Camera Fovy" val:45];
                }
                [self.fxARFace setStringVal:@"Scene Id" val:self.currentPropsModel.packageId];
            }
        });
    }
}

#pragma mark 预览照片视图取消点击事件处理
/*
 预览照片视图取消点击事件处理
 Preview photo view cancel click event processing
 */
- (void)cancelBtn:(UIButton *)sender{
    self.shootingBtn.enabled = YES;
    NSString *filePath = (NSString *)[self.videoPathArray lastObject];
    NSError *error;
    if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]){
        NSLog(@"%@", error);
    }
    [self.videoPathArray removeLastObject];
    if (self.musicInfo && self.videoPathArray.count == 0) {
        [self.audioPlayer seekToTime:self.musicInfo.trimIn/NV_TIME_BASE];
        self.musicBtn.hidden = NO;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.picturePanelView.frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, SCREENHEIGHT);
    }];
}

#pragma mark 预览照片视图确定点击事件处理
/*
 预览照片视图确定点击事件处理
 Preview photo view to confirm click event handling
 */
- (void)determineBtn:(UIButton *)sender{
    self.shootingBtn.enabled = YES;
    self.videoCount.hidden = NO;
    self.timeLabel.hidden = NO;
    self.finishBtn.hidden = NO;
    self.deleteBtn.hidden = NO;
    UIImageWriteToSavedPhotosAlbum(self.picturePreview.image, self, nil, nil);
    self.lastDuration = 4 * NV_TIME_BASE;
    self.duration = self.duration + self.lastDuration;
    self.videoCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)_videoPathArray.count];
    self.timeLabel.text = [NvUtils convertTimecode:self.duration];
    self.timeLabel.textColor = UIColor.whiteColor;
    [self.durationArray addObject:[NSNumber numberWithLongLong:self.lastDuration]];
    [UIView animateWithDuration:0.3 animations:^{
        self.picturePanelView.frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, SCREENHEIGHT);
    }];
    
    CGFloat tempDuration = self.audioPlayer.currentTime+4;
    if ((tempDuration*NV_TIME_BASE) > self.musicInfo.duration && self.musicInfo) {
        tempDuration = ((tempDuration*NV_TIME_BASE) - self.musicInfo.duration);
        tempDuration = tempDuration/NV_TIME_BASE;
    }
    [self.audioPlayer seekToTime:tempDuration];
}

#pragma mark 闪光灯开关
/*
 闪光灯开关
 Flash switch
 */
- (void)flashBtnClick:(UIButton *)sender{
    if ([_streamingContext getCaptureDeviceCapability:_currentDeviceIndex].supportFlash) {
        [_streamingContext toggleFlash:![_streamingContext isFlashOn]];
        _flashBtn.selected = sender.isSelected ? NO : YES;
    }
}

//帧率开关  Frame rate switch
- (void)fpsBtnClick:(UIButton *)sender{
    if (!self.FPSBtn.selected) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(getFps:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        self.fpsValueLab.hidden = NO;
    }else{
        [self.timer invalidate];
        self.timer = nil;
        self.fpsValueLab.hidden = YES;
    }
    self.FPSBtn.selected = !self.FPSBtn.selected;
}

- (void)getFps:(NSTimer *)timer {
    float fpsValue = [self.streamingContext detectEngineRenderFramePerSecond];
    self.fpsValueLab.text = [NSString stringWithFormat:@"%.0f fps", fpsValue];
}


#pragma mark 变焦按钮点击
/*
 变焦按钮点击
 Zoom button click
 */
- (void)zoomBtnClick:(UIButton *)sender{
    self.zoomSlider.hidden = NO;
    self.exposureSlider.hidden = YES;
    [self.view bringSubviewToFront:self.zoomSlider];
}

#pragma mark 曝光按钮点击
/*
 曝光按钮点击
 Exposure button click
 */
- (void)exposureBtnClick:(UIButton *)sender{
    self.zoomSlider.hidden = YES;
    self.exposureSlider.hidden = NO;
    [self.view bringSubviewToFront:self.exposureSlider];
}

#pragma mark tipView按钮点击事件
/*
 tipView按钮点击事件
 Tipview button click event
 */
- (void)knowClick:(UIButton *)sender{
    _photoView.hidden = YES;
}

#pragma mark 变声按钮点击事件
/*
 变声按钮点击事件
 Click event of voice change button
 
 @param btn 变声按钮
 Voice change button
 */
-(void)voiceBtnClick:(UIButton *)btn{
    self.clickState = YES;
    self.currentView = self.voiceBottomView;
    [UIView animateWithDuration:0.1 animations:^{
        self.voiceBottomView.frame = CGRectMake(0, SCREENHEIGHT - self.voiceBottomView.frame.size.height, SCREENWIDTH, self.voiceBottomView.frame.size.height);
    }];
}

#pragma mark 权限按钮点击事件
/*
 权限按钮点击事件
 Permission button click event
 */
- (void)knowClick{
    [_permissions removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 道具按钮点击
/*
 道具按钮点击
 Click the prop button
 */
- (void)propBtnClick:(UIButton *)sender{
    if (self.isContentAI) {
        CGFloat bottomSafeDistance = (NV_STATUSBARHEIGHT>20)?10:0;
        CGRect rect = CGRectMake(0, SCREENHEIGHT - 295*SCREENSCALE-bottomSafeDistance, SCREENWIDTH, 295*SCREENSCALE+bottomSafeDistance);

        if (!self.propsListViewController) {
            self.propsListViewController = [[NvTitleListViewController alloc]init];
            self.propsListViewController.delegate = self;
            self.propsListViewController.type = ASSET_ARSCENE;
        }

        [self jumpListCategoryVC:self.propsListViewController withRect:rect];


    }else{
         [self showTip];
    }
}

/*
 贴纸按钮点击
 Click the sticker button
 */
-(void)stickerBtnClick:(UIButton *)button{
    CGFloat bottomSafeDistance = (NV_STATUSBARHEIGHT>20)?10:0;
    CGRect rect = CGRectMake(0, SCREENHEIGHT - 220*SCREENSCALE-bottomSafeDistance, SCREENWIDTH, 220*SCREENSCALE+bottomSafeDistance);
    
    if (!self.stickersListViewController) {
        self.stickersListViewController = [[NvTitleListViewController alloc]init];
        self.stickersListViewController.delegate = self;
        self.stickersListViewController.type = ASSET_ANIMATED_STICKER;
        self.stickersListViewController.view.tag = 3001;
    }
    [self jumpListCategoryVC:self.stickersListViewController withRect:rect];

}

#pragma mark 字幕按钮点击 Subtitle button click
-(void)captionBtnClick:(UIButton *)button{
    CGFloat bottomSafeDistance = (NV_STATUSBARHEIGHT>20)?10:0;
    CGRect rect = CGRectMake(0, SCREENHEIGHT - 295*SCREENSCALE-bottomSafeDistance, SCREENWIDTH, 295*SCREENSCALE+bottomSafeDistance);
    
    if (!self.captionsListViewController) {
        self.captionsListViewController = [[NvTitleListViewController alloc]init];
        self.captionsListViewController.delegate = self;
        self.captionsListViewController.type = ASSET_COMPOUND_CAPTION;
        self.captionsListViewController.view.tag = 3000;
    }
    
    [self jumpListCategoryVC:self.captionsListViewController withRect:rect];
}

#pragma mark 美颜开关
/*
 美颜开关
 Beauty switch
 */
- (void)beautyBtnClick:(UIButton *)sender{
    _beautyBtn.selected = _beautyBtn.selected?NO:YES;
    self.clickState = YES;
    [self faceHiddenBtn:YES];
    self.currentView = self.beautyView;
    int count = [self.beautyView getBeautyTemplateCount];
    if (count == 0) {
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN || [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
            [self.captureVM configBeautyTemplateArray];
        }else{
            // 网络状态改变的回调 Callbacks of network state changes
            [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                switch (status) {
                    case AFNetworkReachabilityStatusReachableViaWWAN:{
                        [self.captureVM configBeautyTemplateArray];
                    }
                        break;
                    case AFNetworkReachabilityStatusReachableViaWiFi:{
                        [self.captureVM configBeautyTemplateArray];
                    }
                    default:{

                    }
                    break;
                }
            }];
        }
    }
    [UIView animateWithDuration:0.1 animations:^{
        if (NV_STATUSBARHEIGHT > 20) {
            self.beautyView.frame = CGRectMake(0, SCREENHEIGHT - 628*SCREENSCALE - 34, SCREENWIDTH, 628 * SCREENSCALE + 34);
        }else{
            self.beautyView.frame = CGRectMake(0, SCREENHEIGHT - 628*SCREENSCALE, SCREENWIDTH, 628 * SCREENSCALE);
        }
        
    }];
}

#pragma mark 美妆开关
/*
 美妆开关
 Make up switch
 */
- (void)makeupBtnClick:(UIButton *)sender {
    if (!self.isContentAI) {
        [self showTip];
        return;
    }
    _makeupBtn.selected = _makeupBtn.selected?NO:YES;
    self.clickState = YES;
    [self faceHiddenBtn:YES];
    self.currentView = self.makeupView;
    [UIView animateWithDuration:0.1 animations:^{
        if (NV_STATUSBARHEIGHT > 20) {
            self.makeupView.frame = CGRectMake(0, SCREENHEIGHT - 604 * SCREENSCALE - 34, SCREENWIDTH, 604 * SCREENSCALE + 34);
        }else{
            self.makeupView.frame = CGRectMake(0, SCREENHEIGHT - 604 * SCREENSCALE, SCREENWIDTH, 604 * SCREENSCALE);
        }
        
    } completion:^(BOOL finished) {
        [self.makeupView showMakeupSliderInCondition];
    }];
}

#pragma mark 滤镜按钮点击
/*
 滤镜按钮点击
 Filter button click
 */
- (void)filterBtnClick:(UIButton *)sender{
    if (self.appliedMakeup && !self.filterCanReplace) {
        [self presentMakeupUnReplaceableAlertController];
        return;
    }
    
    CGFloat bottomSafeDistance = (NV_STATUSBARHEIGHT>20)?10:0;
    CGRect rect = CGRectMake(0, SCREENHEIGHT - 200*SCREENSCALE-bottomSafeDistance, SCREENWIDTH, 200*SCREENSCALE+bottomSafeDistance);
    
    if (!self.filterSlider) {
        self.filterSlider = [[BLItemSlider alloc] initWithFrame:CGRectMake(45*SCREENSCALE, rect.origin.y - 50*SCREENSCALE, SCREENWIDTH - 90*SCREENSCALE, 50*SCREENSCALE)];
        self.filterSlider.delegate = self;
        self.filterSlider.maximumTrackTintColor = [UIColor whiteColor];
        self.filterSlider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#80FFFFFF"];
        self.filterSlider.thumbTintColor = [UIColor whiteColor];
        self.filterSlider.thumbSeletedTintColor = [UIColor whiteColor];
        self.filterSlider.minValue = 0;
        self.filterSlider.maxValue = 1;
        self.filterSlider.value = DefaultFilterStrength;
        [self.filterSlider modifyStylevalueLabel];
        [self.view addSubview:self.filterSlider];
        
        [self.filterSlider adsorb:YES adsorbValue:DefaultFilterStrength];
    }
    
    if (!self.filterPrmView) {
        CGFloat height = 200 * SCREENSCALE;
        CGFloat y = CGRectGetMinY(rect) - height;
        self.filterPrmView = [[NvAdjustFxParamView alloc] initWithFrame:CGRectMake(0, y, SCREENWIDTH, height) fxParams:nil translation:nil];
        self.filterPrmView.delegate = self;
        self.filterPrmView.newStyle = YES;
        self.filterPrmView.hidden = YES;
        [self.view addSubview:self.filterPrmView];
    }
    
    if (self.captureVM.currentFilterModel && ![self.captureVM containExpParam:self.captureVM.currentFilterModel]) {
        self.filterSlider.hidden = NO;
        if (self.captureVM.currentFilterModel) {
            if (self.captureVM.currentFilterModel.categoryId == 2 && (self.captureVM.currentFilterModel.kindId == 8||self.captureVM.currentFilterModel.kindId == 9)){
                self.filterSlider.hidden = YES;
            }
        }
    }else{
        self.filterSlider.hidden = YES;
    }

    if (self.captureVM.currentFilterModel) {
        [self checkAssetExpValueList:self.captureVM.currentFilterModel type:NvsAssetPackageType_VideoFx];
    }
    [self jumpListCategoryVC:self.filterListViewController withRect:rect];
}

#pragma mark 更多按钮点击
/*
 更多按钮点击
 Click more buttons
 */
- (void)moreBtnClick:(UIButton *)sender {
    if(!_moreBgView) {
        
    }
    _moreBgView.hidden = !_moreBgView.hidden;
    if (!_moreBgView.hidden) {
        [self delayHiddenMoreBgView];
    }else{
        [self hiddenMoreBgView];
    }
}

#pragma mark 删除按钮点击
/*
 删除按钮点击
 Delete button click
 */
- (void)deleteBtnBtnClick:(UIButton *)sender{
    NSString *filePath = (NSString *)[_videoPathArray lastObject];
    [_videoPathArray removeLastObject];
    NSError *error;
    if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]){
         NSLog(@"%@", error);
    }
    if (_videoPathArray.count == 0) {
        self.videoCount.text = @"";
        self.timeLabel.text = @"00:00";
        self.timeLabel.hidden = YES;
        self.deleteBtn.hidden = YES;
        self.finishBtn.hidden = YES;
        self.duration = 0;
        if (self.musicInfo) {
            [self.audioPlayer seekToTime:self.musicInfo.trimIn/NV_TIME_BASE];
        }
        self.musicBtn.hidden = NO;
    }else{
        self.videoCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)_videoPathArray.count];
        self.duration = self.duration - [[_durationArray lastObject] longLongValue];
        self.timeLabel.text = [NvUtils convertTimecode:self.duration];
        if (self.musicInfo) {
            [self.audioPlayer seekToTime:self.duration/NV_TIME_BASE];
        }
    }
    [self setShootingBtnImage];
    
}

/*
 音乐点击
 music Click
 */
- (void)musicBtnClick{
    NvSelectMusicViewController *selectMusic = NvSelectMusicViewController.new;
    selectMusic.delegate = self;
    
    [self.navigationController pushViewController:selectMusic animated:YES];
}

#pragma mark 完成按钮点击
/*
 完成按钮点击
 Click the finish button
 */
- (void)finishBtnBtnClick:(UIButton *)sender{
    if (_currentDeviceIndex != [self frontCameraDeviceIndex]) {
        _flashBtn.alpha = 1;
        _flashBtn.userInteractionEnabled = YES;
        _flashBtn.selected = NO;
    }
    
    NvEditViewController *vc  = [[NvEditViewController alloc]init];
    CGSize dimensions = [NvTimelineUtils getAVFileSize:self.videoPathArray[0]] ;
    if (dimensions.width > dimensions.height) {
        vc.editMode = NvEditMode16v9;
    }else{
        vc.editMode = NvEditMode9v16;
    }
    vc.selectPath = self.videoPathArray;
    if (self.musicInfo){
        vc.musicInfo = [self.musicInfo copy];
    }
    vc.isFromAlbum = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 拍摄按钮点击
/*
 拍摄按钮点击
 Shoot button click
 */
- (void)shootingBtnClick:(UIButton *)sender{
    self.musicBtn.hidden = YES;
    self.zoomSlider.hidden = YES;
    self.exposureSlider.hidden = YES;
    if (_currentInteger == 0) {
        self.takePhotoTime = [[NSDate date] timeIntervalSinceDate:self.startPreviewTime]*NV_TIME_BASE;
        self.shootingBtn.enabled = NO;
        self.isHaveImage = YES;
        
        NSNumber * pictureModeNum = NV_UserInfo(@"NvSwitchPictureMode");
        if (pictureModeNum && pictureModeNum.intValue == 1) {
            [self.streamingContext toggleFlashMode:[self.streamingContext isFlashOn]?NvsCameraFlashMode_FlashOn:NvsCameraFlashMode_FlashOff];
            [self.streamingContext takePicture:0];
        }else{
            [self takeScreenShot];
        }
    }else{
        if (sender.selected) {
            if (self.needReStartCapturePreview) {
                [self startCapturePreview];
            }
            sender.selected = NO;
            [self faceHiddenBtn:NO];
            [self stopRecording];
            [self setShootingBtnImage];
            self.videoCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)_videoPathArray.count];
            self.timeIndicator.hidden = YES;
            self.videoCount.hidden = NO;
            self.duration = self.duration + self.lastDuration;
            [self.durationArray addObject:[NSNumber numberWithLongLong:self.lastDuration]];
        }else{
            self.timeIndicator.hidden = NO;
            self.videoCount.hidden = YES;
            sender.selected = YES;
            [self faceHiddenBtn:YES];
            self.shootingBtn.hidden = NO;
            self.timeLabel.hidden = NO;
            self.shootingBtn.enabled = NO;
            [self startRecording];
        }
    }
}

- (void)takeScreenShot {
    self.pngPath = [VIDEO_PATH(@"Record") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [NvUtils currentDateAndTime]]];
    UIImage *image = [self.curLiveWindow takeScreenShot];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIImage *saveImage = image;
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        saveImage = [image rotateWithOrientation:UIImageOrientationLeft];
    }else if (orientation == UIDeviceOrientationLandscapeRight) {
        saveImage = [image rotateWithOrientation:UIImageOrientationRight];
    }
    NSData *data = UIImagePNGRepresentation(saveImage);
    [data writeToFile:self.pngPath atomically:YES];
    [self.videoPathArray addObject:self.pngPath];
    self.isHaveImage = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.picturePreview.image = saveImage;
        [UIView animateWithDuration:0.3 animations:^{
            self.picturePanelView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
        }];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.shootingBtn.enabled = YES;
    });
}


//设备方向改变的处理 Handling of device direction change

- (void)handleDeviceOrientationChange:(NSNotification *)notification{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationFaceUp:
            break;
        case UIDeviceOrientationFaceDown:
            break;
        case UIDeviceOrientationUnknown:
            break;
        case UIDeviceOrientationLandscapeLeft:
            break;
        case UIDeviceOrientationLandscapeRight:
            break;
        case UIDeviceOrientationPortrait:
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        default:
            break;

    }

}

#pragma mark - 让动态特效重新动起来
- (void)resetAllCompoundCaptionStartTime {
    int count = [self.streamingContext getCaptureCompoundCaptionCount];
    for (int i = 0; i < count; i++) {
        NvsCaptureCompoundCaption *caption = [self.streamingContext getCaptureCompoundCaptionByIndex:i];
        [caption resetStartTime];
    }
}

#pragma mark - 开始录制
/*
 开始录制
 startRecording
 */
- (void)startRecording{
    [self resetAllCompoundCaptionStartTime];
    NSString *path = [VIDEO_PATH(@"Record") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
    
    
    if ([NvHDRManager isSupportExporter] && [NvSDKUtils hevcModelSetting].length > 0) {
        [config setValue:[NvSDKUtils hevcModelSetting] forKey:NVS_RECORD_VIDEO_ENCODEC_NAME];
        [config setValue:[NvSDKUtils exportModelSetting] forKey:NVS_RECORD_HDR_VIDEO_COLOR_TRANSFER];
    }
    
    [_streamingContext startRecordingWithFx:path withFlags:0 withRecordConfigurations:config];
    [self.videoPathArray addObject:path];
    [self.audioPlayer play];
}

#pragma mark 关闭录制
/*
 关闭录制
 stopRecording
 */
- (void)stopRecording{
    [self.audioPlayer pause];
    [_streamingContext stopRecording];
    if (_currentInteger != 0) {
        [self saveVideoToAlbum:self.videoPathArray.lastObject];
    }
}

#pragma mark 保存视频到相册
/*
 保存视频到相册
 Save video to album
 
 @param videoPath 保存的视频路径
 Saved video path
 */
-(void)saveVideoToAlbum:(NSString*)videoPath{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied)
    {
        if (!self.photoView) {
            [self tipView];
        }
        return;
    }else if(status == PHAuthorizationStatusNotDetermined) {
        __weak typeof(self) wself = self;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself saveVideoToAlbum:videoPath];
                });
            }
        }];
    }else{
        if (self.photoView) {
            [self.photoView removeFromSuperview];
        }
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, nil, nil);
    }
}

#pragma mark - 初始化人脸授权
/*
 初始化人脸授权
 Initialize face authorization
 */
- (void)initARFace {
    [self.captureVM initARFace];
    self.fxARFace = self.captureVM.fxARFace;
    self.isContentAI = self.captureVM.isContentAI;
#ifdef ARSCENE_AVATAR_TEST
    NvsARSceneManipulate * manipulate = [self.fxARFace getARSceneManipulate];
    NvFaceActionView* _actionView = [NvFaceActionView createFaceActionView];
    [self.view addSubview:_actionView];
    manipulate.delegate = _actionView;
#endif
}

#pragma mark - 启动采集之后，初始化效果采集参数
/*
 启动采集之后，初始化效果采集参数
 After starting the acquisition, initialize the effect acquisition parameters
 */
- (void)configParameter{
    self.timeLabel.hidden = YES;
    self.deleteBtn.hidden = YES;
    self.finishBtn.hidden = YES;
    
    if (_currentDeviceIndex == [self frontCameraDeviceIndex]) {
        self.flashBtn.userInteractionEnabled = NO;
        self.flashBtn.alpha = 0.7;
    } else {
        self.flashBtn.userInteractionEnabled = YES;
        self.flashBtn.alpha = 1;
    }
    
    if (!self.fxARFace) {
        self.fxARFace = [self.streamingContext appendBeautyCaptureVideoFx];
    }
    
    [self.captureVM configBeautyTemplateArray];
    [self.captureVM configBeautifulSkinParameter];
    [self.captureVM setBeautyTypeDefaultValues];
    [self.captureVM configMicroShapingTypeParameter];
    [self.captureVM configAdjustArray];
    [self.captureVM configContouringArray];
    if (self.isContentAI) {
        [self.fxARFace setFloatVal:@"Beauty Strength" val:0];
    }else{
        [self.streamingContext removeAllCaptureVideoFx];
        self.fxARFace = nil;
    }
    
}

- (void)applyDefaultFilter {
    [self replaceMakeupFilters];
    [self.captureVM applyFilter:nil];
    [self.captureVM applyDefaultFilter];
    [self.filterListViewController selecteMaterial:DEFAULT_FILTER];
    [self.filterListViewController changeAsset:DEFAULT_FILTER withDestinationIndex:0];
}

#pragma mark - 替换美妆滤镜
/// Replace your Beauty makeup filters
- (void)replaceMakeupFilters{
    int count = self.streamingContext.getCaptureVideoFxCount;
    for (NvMakeupToolEffectModel *model in self.currentMakeupVariableModel.effectContent.filter) {
        for (int i = 0; i < count; i++) {
            NvsCaptureVideoFx *fx = [self.streamingContext getCaptureVideoFxByIndex:i];
            if (model.uuid.length > 0 && fx.captureVideoFxPackageId.length > 0) {
                if ([model.uuid isEqualToString:fx.captureVideoFxPackageId]){
                    [self.streamingContext removeCaptureVideoFx:fx.index];
                }
            }
        }
    }
}

-(BOOL)showStickerRectview{
    if (self.currentView && self.currentView.tag == 3001) {
        if (self.currentView.viewY < SCREENHEIGHT - 10 && self.stickerInfoArray.count) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)showCompoundCaptionRectview{
    if (self.currentView && self.currentView.tag == 3000) {
        if (self.currentView.viewY < SCREENHEIGHT - 10 && self.captionInfoArray.count) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 重现显示字幕及选中框
- (void)showCaption {
    if (self.currentCompoundCaption == nil) {
        self.rectView.hidden = YES;
        return;
    }
    self.rectView.hidden = NO;
    [self updateCaptionView:self.currentCompoundCaption];
}

//获取字幕对应的infoModel对象 Obtain the infoModel object corresponding to the subtitle
- (NvCompoundCaptionInfoModel *)getCaptionInfoModel:(NvsCaptureCompoundCaption *) nextCaption {
    return (NvCompoundCaptionInfoModel *)[nextCaption getAttachment:@"compoundInfoModel"];
}

- (void)removeCaptureAnimatedSticker:(NvStickerInfoModel *)stickerModel {
    int count = [self.streamingContext getCaptureAnimatedStickerCount];
    for (int i = 0; i < count; i++) {
        NvsCaptureAnimatedSticker *fx = [self.streamingContext getCaptureAnimatedStickerByIndex:i];
        NvStickerInfoModel *model = (NvStickerInfoModel *)[fx getAttachment:@"stickerInfoModel"];
        if ([stickerModel.uuid isEqualToString:model.uuid]) {
            [self.streamingContext removeCaptureAnimatedSticker:i];
            break;
        }
    }
}

- (void)removeCaptureCompoundCaption:(NvCompoundCaptionInfoModel *)compoundInfo {
    int count = [self.streamingContext getCaptureCompoundCaptionCount];
    for (int i = 0; i < count; i++) {
        NvsCaptureCompoundCaption *fx = [self.streamingContext getCaptureCompoundCaptionByIndex:i];
        NvCompoundCaptionInfoModel *model = (NvCompoundCaptionInfoModel *)[fx getAttachment:@"compoundInfoModel"];
        if ([model.uuid isEqualToString:compoundInfo.uuid]) {
            [self.streamingContext removeCaptureCompoundCaption:i];
            break;
        }
    }
}

- (void)rectView:(NvRectView *)rectView horizontalFlip:(UIButton *)horizontalFlip {
    if (self.currentView.tag == 3001) {
        BOOL isFlip = [self.currentAnimatedSticker getHorizontalFlip];
        isFlip = !isFlip;
        [self.currentAnimatedSticker setHorizontalFlip:isFlip];
        NvStickerInfoModel *modelInfo = [self getStickerInfoModel:self.currentAnimatedSticker];
        modelInfo.isHorizontalFlip = isFlip;
    }
}

- (void)rectView:(NvRectView*)rectView close:(UIButton*)close {
    if (self.currentView.tag == 3001) {
        [self removeCaptureAnimatedSticker:(NvStickerInfoModel *)[self.currentAnimatedSticker getAttachment:@"stickerInfoModel"]];
        if (self.stickerInfoArray.count) {
            [self.stickerInfoArray removeObject:(NvStickerInfoModel *)[self.currentAnimatedSticker getAttachment:@"stickerInfoModel"]];
        }
        if (self.stickerInfoArray.count) {
            self.currentStickerInfoModel = self.stickerInfoArray.lastObject;
            self.currentAnimatedSticker = [NvCaptureStickerCaptionUtils findStickerObjectWithStickerInfo:self.currentStickerInfoModel];
            
        }
        if ([self showStickerRectview] && self.stickerInfoArray.count) {
            [self showStickerBoundingView];
            [self.stickersListViewController selecteMaterial:self.currentAnimatedSticker.getAnimatedStickerPackageId];
        }else{
            [self.rectView removeSublayer];
            self.rectView.hidden = YES;
            [self.stickersListViewController selecteMaterial:@""];
        }
    }else{
        NvCompoundCaptionInfoModel *currentModel = [self getCaptionInfoModel:self.currentCompoundCaption];
        
        [self removeCaptureCompoundCaption:(NvCompoundCaptionInfoModel *)[self.currentCompoundCaption getAttachment:@"compoundInfoModel"]];
        if (self.captionInfoArray.count) {
            [self.captionInfoArray removeObject:currentModel];
        }
        if (self.captionInfoArray.count) {
            self.currentCompoundCaptionModel = self.captionInfoArray.lastObject;
            self.currentCompoundCaption = [NvCaptureStickerCaptionUtils findCompoundCaptionObjectWithStickerInfo: self.currentCompoundCaptionModel];
            
        }
        if ([self showCompoundCaptionRectview] && self.captionInfoArray.count) {
            [self showCaption];
            [self.captionsListViewController selecteMaterial:self.currentCompoundCaption.captionStylePackageId];
        }else{
            [self.rectView removeSublayer];
            self.rectView.hidden = YES;
            [self.captionsListViewController selecteMaterial:@""];
        }
    }
}


- (void)rectView:(NvRectView*)rectView currentPoint:(CGPoint)currentPoint previousPoint:(CGPoint)previousPoint {

    if (self.currentView.tag == 3001)  {
        CGPoint p1 = [self.curLiveWindow mapViewToCanonical:currentPoint];
        CGPoint p2 = [self.curLiveWindow mapViewToCanonical:previousPoint];
        CGPoint newPoint = CGPointMake(p1.x-p2.x, p1.y-p2.y);
        [self.currentAnimatedSticker translateAnimatedSticker:newPoint];
        [self showStickerBoundingView];
        
        NvStickerInfoModel *modelInfo = [self getStickerInfoModel:self.currentAnimatedSticker];
        modelInfo.translation = [self.currentAnimatedSticker getTransltion];
    }else{
        CGPoint p1 = [self.curLiveWindow mapViewToCanonical:currentPoint];
        CGPoint p2 = [self.curLiveWindow mapViewToCanonical:previousPoint];
        CGPoint newPoint = CGPointMake(p1.x-p2.x, p1.y-p2.y);
        [self.currentCompoundCaption translateCaption:newPoint];
        
        [self updateCaptionView:self.currentCompoundCaption];
        
        NvCompoundCaptionInfoModel *model = [self getCaptionInfoModel:self.currentCompoundCaption];
        model.translationOffset = [self.currentCompoundCaption getCaptionTranslation];
    }
}


- (void)rectView:(NvRectView*)rectView rotate:(float)rotate scale:(float)scale {
    if (self.currentView.tag == 3001) {
        NSArray *array = [self.currentAnimatedSticker getBoundingRectangleVertices];
        CGPoint center = [self getCenterWithArray:array];
        
        [self.currentAnimatedSticker scaleAnimatedSticker:scale anchor:center];
        [self.currentAnimatedSticker rotateAnimatedSticker:rotate anchor:center];
        
        [self showStickerBoundingView];
        NvStickerInfoModel *modelInfo = [self getStickerInfoModel:self.currentAnimatedSticker];
        modelInfo.rotation = [self.currentAnimatedSticker getRotationZ];
        modelInfo.scale = [self.currentAnimatedSticker getScale];
    }else{
        NSArray *vertices = [self.currentCompoundCaption getCompoundBoundingVertices:NvsBoundingType_Text];
        CGPoint center = [self getCenterWithArray:vertices];
        //字幕缩放大于5倍则不允许再放大
        //Subtitle zooming greater than 5x is not allowed
        if (scale > 1 && [self.currentCompoundCaption getScaleX] > 5) {
            return;
        }
        [self.currentCompoundCaption scaleCaption:scale anchor:center];
        [self.currentCompoundCaption rotateCaption:rotate anchor:center];
        [self updateCaptionView:self.currentCompoundCaption];
        CGFloat rotationValue = [self.currentCompoundCaption getRotationZ];
        CGFloat scaleValue = [self.currentCompoundCaption getScaleX];
        CGPoint anchorValue = [self.currentCompoundCaption getAnchorPoint];
        NvCompoundCaptionInfoModel *model = [self getCaptionInfoModel:self.currentCompoundCaption];
        model.scale = scaleValue;
        model.rotation = rotationValue;
        model.anchorPoint = anchorValue;
    }
}

- (void)rectView:(NvRectView *)rectView toggleVolume:(UIButton *)toggleVolume {
    if (self.currentView.tag == 3001) {
        float currentVolume;
        [self.currentAnimatedSticker getVolumeGain:&currentVolume rightVolumeGain:&currentVolume];
        [self.currentAnimatedSticker setVolumeGain:1-currentVolume rightVolumeGain:1-currentVolume];
        NvStickerInfoModel *modelInfo = [self getStickerInfoModel:self.currentAnimatedSticker];
        modelInfo.volume = 1 - currentVolume;
        
        [self.rectView setVolume:modelInfo.volume > 0];
    }
}

- (void)rectView:(NvRectView *)rectView touchBeganPoint:(CGPoint)point {
    if (self.currentView.tag == 3001) {
        NvStickerInfoModel *info = [NvCaptureStickerCaptionUtils getStickerByPointWithliveWindow:self.curLiveWindow point:point];
        if (info == nil) {
            self.rectView.hidden = YES;
            return;
        }
        self.currentAnimatedSticker = [NvCaptureStickerCaptionUtils findStickerObjectWithStickerInfo:info];
        
        [self showStickerBoundingView];
    }else{
        [self compoundCaptionInPointWithPoint:point];
    }
}


- (void)rectView:(NvRectView *)rectView touchUpInside:(CGPoint)point {
    if (self.currentView.tag == 3001) {
    
        NSArray *array = [self.currentAnimatedSticker getBoundingRectangleVertices];
        NSValue *leftTopValue = array[0];
        NSValue *leftBottomValue = array[1];
        NSValue *rightBottomValue = array[2];
        NSValue *rightTopValue = array[3];
        CGPoint topLeftCorner = [leftTopValue CGPointValue];
        CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
        CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
        CGPoint rightTopCorner = [rightTopValue CGPointValue];
        
        topLeftCorner = [self.curLiveWindow mapCanonicalToView:topLeftCorner];
        rightBottomCorner = [self.curLiveWindow mapCanonicalToView:rightBottomCorner];
        bottomLeftCorner = [self.curLiveWindow mapCanonicalToView:bottomLeftCorner];
        rightTopCorner = [self.curLiveWindow mapCanonicalToView:rightTopCorner];
        
        CGMutablePathRef pathRef=CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, topLeftCorner.x, topLeftCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, bottomLeftCorner.x, bottomLeftCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, rightBottomCorner.x, rightBottomCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, rightTopCorner.x, rightTopCorner.y);
        CGPathCloseSubpath(pathRef);
        bool isIn = CGPathContainsPoint(pathRef, nil, point, false);
        CGPathRelease(pathRef);
        if(isIn){
            [self.rectView removeSublayer];
            [self.rectView setPoints:@[[NSValue valueWithCGPoint:[self.curLiveWindow convertPoint:topLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.curLiveWindow convertPoint:bottomLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.curLiveWindow convertPoint:rightBottomCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.curLiveWindow convertPoint:rightTopCorner toView:self.rectView]]]];
        }
    }else{
        [self compoundCaptionTouchUpinsideWithPoint:point];
    }
}

//更新字幕框的位置 Update the location of the subtitle box
- (void)updateCaptionView: (NvsCaptureCompoundCaption*) caption {
    NSArray *array = [caption getCompoundBoundingVertices:NvsBoundingType_Text];
 
    NSArray *captionArr = [NvCaptureStickerCaptionUtils changeModifiableInternalCaptionsWithCaption:caption liveWindow:self.curLiveWindow rectView:self.rectView];
    [self.rectView changeModifiableInternalCaptionsWithPoints:captionArr];

    //将外围边框变大 Make the perimeter border larger
    [NvCaptureStickerCaptionUtils enlargeVerticesWithArray:array liveWindow:self.curLiveWindow rectView:self.rectView];
}

- (CGPoint)getCenterWithArray:(NSArray*)array {
    NSValue *leftTopValue = array[0];
    NSValue *rightBottomValue = array[2];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    return CGPointMake((topLeftCorner.x+rightBottomCorner.x)/2, (topLeftCorner.y+rightBottomCorner.y)/2);
}


- (void)showStickerBoundingView {
    if (self.currentAnimatedSticker == nil) {
        self.rectView.hidden = YES;
        return;
    }
    
    self.rectView.hidden = NO;
    BOOL flip = [self.currentAnimatedSticker getHorizontalFlip];
    if (flip)
        [self.currentAnimatedSticker setHorizontalFlip:!flip];
    
    [self.rectView setPoints:[self getStickerBoundingPoints]];
    [self.currentAnimatedSticker setHorizontalFlip:flip];
}

/**
 添加sticker
 add sticker

 @param stickerInfo 素材信息
 material info
 */
- (void)addSticker:(NvAssetCellModel *)stickerInfo {
    NvStickerInfoModel *info = NvStickerInfoModel.new;
    info.packageId = stickerInfo.templateId != nil ? stickerInfo.templateId : stickerInfo.package;
    info.isCustomSticer = stickerInfo.templateId != nil;
    info.customImagePath = stickerInfo.cover;
    info.uuid = [NvUtils uuidString];
    info.packagePath = stickerInfo.packPath;
    info.isSlient = stickerInfo.categoryId == ANIMATED_STICKER_SILENT;
    [self.stickerInfoArray addObject:info];
    
    if (info.isCustomSticer) {
        self.currentAnimatedSticker = [self.streamingContext addCustomCaptureAnimatedSticker:0 duration:self.effectDuration animatedStickerPackageId:info.packageId customImagePath:info.customImagePath];
        [self.currentAnimatedSticker setScale:0.33];
        
    }else{
        self.currentAnimatedSticker = [self.streamingContext appendCaptureAnimatedSticker:0 duration:self.effectDuration animatedStickerPackageId:stickerInfo.package];
    }
    
    [self.currentAnimatedSticker setAttachment:info forKey:@"stickerInfoModel"];
}
//添加复合字幕(预览) Add composite subtitles (Preview)
- (void)addCompoundCaption:(NvCaptionStyleItem *)item {
    NvsCaptureCompoundCaption *caption = [self.streamingContext appendCaptureCompoundCaption:0 duration:self.effectDuration compoundCaptionPackageId:item.packageId];

    //添加复合字幕信息 Add compound subtitle information
    NvCompoundCaptionInfoModel *captionModel = [NvCompoundCaptionInfoModel new];
    captionModel.captionCount = caption.captionCount;
    captionModel.translationOffset = [caption getCaptionTranslation];
    captionModel.rotation = [caption getRotationZ];
    captionModel.scale = [caption getScaleX];
    captionModel.packageId = item.packageId;
    captionModel.packagePath = item.packagePath;
    captionModel.uuid = [NvUtils uuidString];
    captionModel.captionArr = [NSMutableArray array];
    for (int i=0; i<caption.captionCount; i++) {
        NvInnerCompoundCaptionModel *innerModel = [NvInnerCompoundCaptionModel new];
        innerModel.text = [caption getText:i];
        innerModel.index = i;
        [captionModel.captionArr addObject:innerModel];
    }
    [caption setAttachment:captionModel forKey:@"compoundInfoModel"];
    [self.captionInfoArray addObject:captionModel];
    self.currentCompoundCaption = caption;
}

-(void)compoundCaptionTouchUpinsideWithPoint:(CGPoint)point{

    NSArray *array = [self.currentCompoundCaption getCompoundBoundingVertices:NvsBoundingType_Text];
    NSValue *leftTopValue = array[0];
    NSValue *leftBottomValue = array[1];
    NSValue *rightBottomValue = array[2];
    NSValue *rightTopValue = array[3];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    CGPoint rightTopCorner = [rightTopValue CGPointValue];

    topLeftCorner = [self.curLiveWindow mapCanonicalToView:topLeftCorner];
    rightBottomCorner = [self.curLiveWindow mapCanonicalToView:rightBottomCorner];
    bottomLeftCorner = [self.curLiveWindow mapCanonicalToView:bottomLeftCorner];
    rightTopCorner = [self.curLiveWindow mapCanonicalToView:rightTopCorner];

    CGMutablePathRef pathRef=CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, NULL, topLeftCorner.x, topLeftCorner.y);
    CGPathAddLineToPoint(pathRef, NULL, bottomLeftCorner.x, bottomLeftCorner.y);
    CGPathAddLineToPoint(pathRef, NULL, rightBottomCorner.x, rightBottomCorner.y);
    CGPathAddLineToPoint(pathRef, NULL, rightTopCorner.x, rightTopCorner.y);
    CGPathCloseSubpath(pathRef);
    bool isIn = CGPathContainsPoint(pathRef, nil, point, false);
    CGPathRelease(pathRef);
    if(isIn){
        
        if (!self.isSelecteCompound) {
            return;
        }
        
        CGPoint pointInRectView = [self.curLiveWindow convertPoint:point toView:self.rectView];
        NSArray *captionArr = [NvCaptureStickerCaptionUtils changeModifiableInternalCaptionsWithCaption:self.currentCompoundCaption liveWindow:self.curLiveWindow rectView:self.rectView];
        //处理两个字幕重合部分，选中index靠后的子字幕进行处理
        //To deal with the overlapped parts of two subtitles, select the subtitle next to index for processing
        int toPushIndex = 0;
        bool isInCompoundCaption = false;
        for (int i=0; i<captionArr.count; i++) {
            NSArray *compoundArr = captionArr[i];
            bool inCompoundCaption = [NvCaptureStickerCaptionUtils pointIsInFrame:pointInRectView vertices:compoundArr];
            if (inCompoundCaption) {
                toPushIndex = i;
                isInCompoundCaption = true;
            }
            
        }

        if (isInCompoundCaption) {

            [self addIputCompoundView];
            self.clickState = YES;
            [self faceHiddenBtn:YES];
            self.inputCompoundView.fontDataArr = self.captureVM.fontDataSource;
            self.inputCompoundView.caption = self.currentCompoundCaption;
            self.inputCompoundView.selectedIndex = toPushIndex;
            __weak typeof(self)weakSelf = self;
            self.inputCompoundView.selectItemClick = ^(NvCompoundCaptionModel * _Nonnull model, NSInteger seletIndex, BOOL disappear) {
                [weakSelf setCompoundCaptionModel:model seletIndex:seletIndex];
                if (disappear) {
                    [weakSelf.inputCompoundView removeFromSuperview];
                    weakSelf.inputCompoundView = nil;
                }
               
            };
            [UIView animateWithDuration:0.1 animations:^{
                self.inputCompoundView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
            }];
        }
    }
}

#pragma mark - 修改单个字幕方法 Modify a single subtitle method
- (void)setCompoundCaptionModel:(NvCompoundCaptionModel *)compoundCaptionModel seletIndex:(NSInteger)seletIndex{
    UIColor *cl = [UIColor nv_colorWithHexARGB:compoundCaptionModel.colorString];
    CGFloat r,g,b,a;
    [cl getRed:&r green:&g blue:&b alpha:&a];
    NvsColor color;
    color.r = r;
    color.g = g;
    color.b = b;
    color.a = a;
    [self.currentCompoundCaption setTextColor:seletIndex textColor:&color];
    [self.currentCompoundCaption setText:seletIndex text:compoundCaptionModel.text];
    if(compoundCaptionModel.isSelected){
        [self.currentCompoundCaption setFontFamily:seletIndex family:compoundCaptionModel.fontName ? : @""];
    }
    [self showCaption];
}


-(void)compoundCaptionInPointWithPoint:(CGPoint)point{
    int count = [self.streamingContext getCaptureCompoundCaptionCount];
    
    BOOL isClickEmpty = YES;
    for (int i = 0; i < count; i++) {
        NvsCaptureCompoundCaption *cap = [self.streamingContext getCaptureCompoundCaptionByIndex:i];
        NSArray *array = [cap getCompoundBoundingVertices:NvsBoundingType_Text];
        NSValue *leftTopValue = array[0];
        NSValue *leftBottomValue = array[1];
        NSValue *rightBottomValue = array[2];
        NSValue *rightTopValue = array[3];
        CGPoint topLeftCorner = [leftTopValue CGPointValue];
        CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
        CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
        CGPoint rightTopCorner = [rightTopValue CGPointValue];

        topLeftCorner = [self.curLiveWindow mapCanonicalToView:topLeftCorner];
        rightBottomCorner = [self.curLiveWindow mapCanonicalToView:rightBottomCorner];
        bottomLeftCorner = [self.curLiveWindow mapCanonicalToView:bottomLeftCorner];
        rightTopCorner = [self.curLiveWindow mapCanonicalToView:rightTopCorner];

        CGMutablePathRef pathRef=CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, topLeftCorner.x, topLeftCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, bottomLeftCorner.x, bottomLeftCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, rightBottomCorner.x, rightBottomCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, rightTopCorner.x, rightTopCorner.y);
        CGPathCloseSubpath(pathRef);
        bool isIn = CGPathContainsPoint(pathRef, nil, point, false);
        CGPathRelease(pathRef);
        if(isIn){
            
            if ([self.selectCompoundCaption isEqual:cap]) {
                self.isSelecteCompound = YES;
            }else{
                self.isSelecteCompound = NO;
            }
            
            isClickEmpty = NO;
            [self prepareCompoundCaptionDrawRect];
            //将外围边框变大 Make the perimeter border larger
            [NvCaptureStickerCaptionUtils enlargeVerticesWithArray:array liveWindow:self.curLiveWindow rectView:self.rectView];
            //设为当前字幕 Set to the current subtitles
            self.currentCompoundCaption = cap;
            self.selectCompoundCaption = cap;
            NSArray *captionArr = [NvCaptureStickerCaptionUtils changeModifiableInternalCaptionsWithCaption:cap liveWindow:self.curLiveWindow rectView:self.rectView];
            [self.rectView changeModifiableInternalCaptionsWithPoints:captionArr];
        }
    }
    
    if (isClickEmpty) {
        if ([self.rectView isEnableDecorate]) {
            [self.rectView hiddenAllDecorates];
        } else {
            [self prepareCompoundCaptionDrawRect];
            self.rectView.hidden = YES;
            [self recoverDefaultViewLayout];
        }
       
        self.isSelecteCompound = NO;
    }
}

- (void)prepareCompoundCaptionDrawRect {
    [self.rectView enableDecorate];
    [self.rectView showAllImage];
    [self.rectView hideVoiceButton:YES];
    [self.rectView hidenAlignImage:YES];
}

- (NSArray *)getStickerBoundingPoints{
    NSArray *array = [self.currentAnimatedSticker getBoundingRectangleVertices];
    NSValue *leftTopValue = array[0];
    NSValue *leftBottomValue = array[1];
    NSValue *rightBottomValue = array[2];
    NSValue *rightTopValue = array[3];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    CGPoint rightTopCorner = [rightTopValue CGPointValue];
    
    topLeftCorner = [self.curLiveWindow mapCanonicalToView:topLeftCorner];
    rightBottomCorner = [self.curLiveWindow mapCanonicalToView:rightBottomCorner];
    bottomLeftCorner = [self.curLiveWindow mapCanonicalToView:bottomLeftCorner];
    rightTopCorner = [self.curLiveWindow mapCanonicalToView:rightTopCorner];
    
    NSMutableArray *newarray = NSMutableArray.new;
    [newarray addObject:[NSValue valueWithCGPoint:topLeftCorner]];
    [newarray addObject:[NSValue valueWithCGPoint:bottomLeftCorner]];
    [newarray addObject:[NSValue valueWithCGPoint:rightBottomCorner]];
    [newarray addObject:[NSValue valueWithCGPoint:rightTopCorner]];
    return newarray;
}

#pragma mark - 返回首页之前，清理预览特效，停止预览，清理sdk内部缓存数据
/*
 返回首页之前，清理预览特效，停止预览，清理sdk内部缓存数据
 Before returning to the home page, clear the preview effects, stop the preview, and clean up the cache data in SDK
 */
- (void)popToLastController {
    if (self.albumSandBoxs.count) {
        NSMutableSet *set = [NSMutableSet setWithArray:self.albumSandBoxs];
        for (NSString *path in set) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
//    [NvInitArScence closeDetect];
    [self.streamingContext removeCurrentCaptureScene];
    [self.streamingContext removeAllCaptureVideoFx];
    [self.streamingContext removeAllCaptureAudioFx];
    [self.streamingContext setExposureBias:0.0];
    [self.streamingContext stop];
    [self.streamingContext clearCachedResources:NO];
    [self.streamingContext removeAllCaptureAnimatedSticker];
    [self.streamingContext removeAllCaptureCompoundCaption];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 跳转新的分类列表 Jump to new category list
- (void)jumpListCategoryVC:(NvTitleListViewController *)vc withRect:(CGRect)rect{
    self.clickState = YES;
    [self faceHiddenBtn:YES];
    
    if (![self.childViewControllers containsObject:vc]) {
        [self addChildViewController:vc];
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        vc.view.frame = rect;
    } completion:^(BOOL finished) {
        if (!vc.view.superview) {
            [self.view addSubview:vc.view];
            [vc didMoveToParentViewController:self];
        }
    }];
    
    self.currentView = vc.view;
    self.currentTitleListVC = vc;
    [vc viewAppearOrDisappear:YES];
    
    if (vc.type == ASSET_ANIMATED_STICKER) {
        [self.rectView hidenAlignImage:NO];
        [self.rectView hideVoiceButton:YES];
        if ([self showStickerRectview]) {
            self.rectView.hidden = NO;
            [self showStickerBoundingView];
        }
    }else if(vc.type == ASSET_COMPOUND_CAPTION){
        [self.rectView hidenAlignImage:YES];
        [self.rectView hideVoiceButton:YES];
        if ([self showCompoundCaptionRectview]) {
            self.rectView.hidden = NO;
            [self showCaption];
        }
    }
}

#pragma mark - 跳转新的页面 Jump to a new page
- (void)jumpVC:(NvBaseViewController *)vc withRect:(CGRect)rect{
    self.clickState = YES;
    [self faceHiddenBtn:YES];
    
    if (![self.childViewControllers containsObject:vc]) {
        [self addChildViewController:vc];
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        vc.view.frame = rect;
    } completion:^(BOOL finished) {
        if (!vc.view.superview) {
            [self.view addSubview:vc.view];
            [vc didMoveToParentViewController:self];
        }
    }];
    
    self.currentView = vc.view;
}

#pragma mark - 设置录制按钮显示的图片
/*
 设置录制按钮显示的图片
 Set the picture displayed by the record button
 */
- (void)setShootingBtnImage {
    if (self.currentInteger == 1) {
        if (_videoPathArray.count>0 ) {
            [self.shootingBtn setImage:NvImageNamed(@"Nv_capture_takePhoto") forState:UIControlStateNormal];
        }else{
            [self.shootingBtn setImage:NvImageNamed(@"Nv_capture_recording") forState:UIControlStateNormal];
        }
    }
}

#pragma mark - 获取前置摄像头设备索引
/*
 获取前置摄像头设备索引
 Get front camera device index
 
 return 返回int值。1表示前置，0表示后置。
 Returns the int value. 1 means front, 0 means back.
 */
- (unsigned int)frontCameraDeviceIndex {
    for (unsigned int i = 0; i < _streamingContext.captureDeviceCount; i++) {
        if (![_streamingContext isCaptureDeviceBackFacing:i])
            return i;
    }
    return _streamingContext.captureDeviceCount - 1;
}

#pragma mark - 启动摄像头采集预览
/*
 启动摄像头采集预览
 Start camera capture Preview
 
 return 返回bool值。yes表示成功，no表示失败。
 Return returns the bool value. Yes means success, no means failure.
 */
- (BOOL)startCapturePreview {
    NvsRational ratio ;
    ratio.num = 9;
    ratio.den = 16;
    
    NSNumber *num = NV_UserInfo(@"NvRecordResolution");
    NvsVideoCaptureResolutionGrade captureResGrade ;
    int recordResolution = [num intValue];
    if (recordResolution == 2160) {
        captureResGrade = NvsVideoCaptureResolutionGradeExtremelyHigh;
    }else if (recordResolution == 1080){
        captureResGrade = NvsVideoCaptureResolutionGradeHigh;
    }else {
        captureResGrade = NvsVideoCaptureResolutionGradeMedium;
    }
    if (![_streamingContext isCaptureDeviceBackFacing:_currentDeviceIndex] && recordResolution != 2160){
        captureResGrade = [num intValue] == 1080?NvsVideoCaptureResolutionGradeSupperHigh:NvsVideoCaptureResolutionGradeHigh;
    }
    
    NSNumber * pictureModeNum = NV_UserInfo(@"NvSwitchPictureMode");
    if (pictureModeNum && pictureModeNum.intValue == 1) {
        int flags = self.audioInterruption == NvAudioInterruptionStateAffecting ? NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame | NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize|NvsStreamingEngineCaptureFlag_DontCaptureAudio : NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame | NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize;
        return [_streamingContext startCapturePreview:_currentDeviceIndex videoResGrade:captureResGrade flags:flags aspectRatio:&ratio];
    }
    int flags = self.audioInterruption == NvAudioInterruptionStateAffecting ? NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame | NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize | NvsStreamingEngineCaptureFlag_DontCaptureAudio : NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame | NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize;
    self.needReStartCapturePreview = NO;
    BOOL result = [_streamingContext startCapturePreview:_currentDeviceIndex videoResGrade:captureResGrade flags:flags aspectRatio:&ratio];
    [_streamingContext setZoomFactor:1.f];
    [self.streamingContext setAECEnabled:self.musicInfo?true:false];
    return result;
}

#pragma mark - 点击隐藏界面按钮
/*
 点击隐藏界面按钮
 Click the hide interface button
 
 @param hidden yes表示隐藏，no表示不隐藏
 Yes means hidden, no means not hidden

 */
- (void)faceHiddenBtn:(BOOL)hidden{
    self.propBtn.hidden = hidden;
    self.filterBtn.hidden = hidden;
    self.deviceBtn.hidden = hidden;
    if (_ifShowVoiceBtn) {
        self.voiceBtn.hidden = hidden;
        self.noiseSuppressionBtn.hidden = YES;
    }
    self.beautyBtn.hidden = hidden;
    self.backBtn.hidden = hidden;
    self.shootingBtn.hidden = hidden;
    self.timeLabel.hidden = hidden;
    self.deleteBtn.hidden = hidden;
    self.finishBtn.hidden = hidden;
    self.psTitleCollectionView.hidden = hidden;
    self.makeupBtn.hidden = hidden;
    self.moreBtn.hidden = hidden;
    self.moreBgView.hidden = YES;
    self.propMoreBgView.hidden = hidden;
}

#pragma mark - 延迟执行对焦效果
/*
 延迟执行对焦效果
 Delay execution of focusing effect
 */
- (void)delayaf{
    [self.streamingContext startContinuousFocus];
}

#pragma mark - 点击空白显示界面按钮
/*
 点击空白显示界面按钮
 Click the blank display interface button
 
 @param recognizer 回调的手势
 Callback gesture
 */
- (void)singleTap:(UITapGestureRecognizer *)recognizer {
    [self hiddenMoreBgView];
    if (self.clickState) {
        [self recoverDefaultViewLayout];
    }else{
        CGPoint point = [recognizer locationInView:_curLiveWindow];
        if (point.x >= SCREENWIDTH - 70 * SCREENSCALE || point.y >= SCREENHEIGHT - 190 * SCREENSCALE){
            return;
        }
        if (self.capability.supportAutoFocus) {
            [_streamingContext startAutoFocus:point];
            [self animateFocusView:point];
        }
        if (self.capability.supportAutoExposure) {
            [_streamingContext startAutoExposure:point];
            [self animateFocusView:point];
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayaf) object:nil];
        [self performSelector:@selector(delayaf) withObject:nil afterDelay:3.0];
    }
}

- (void)recoverDefaultViewLayout {
    self.clickState = NO;
    [self faceHiddenBtn:NO];
    self.filterSlider.hidden = YES;
    self.filterPrmView.hidden = YES;
    if (self.currentView == self.makeupView) {
        [self.makeupView hiddenMakeupSlider];
    }
    [UIView animateWithDuration:0.1 animations:^{
        self.currentView.frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, self.currentView.frame.size.height);
    }];
    
    if (self.currentView) {
        if (self.currentView.tag == 3000) {
            [self.inputCompoundView removeFromSuperview];
            self.inputCompoundView = nil;
        }
    }
    if (self.currentTitleListVC) {
        [self.currentTitleListVC viewAppearOrDisappear:NO];
        self.currentTitleListVC = nil;
        [self.filterPrmView cancelAnimation];
    }
    
    if (_videoPathArray.count == 0) {
        self.timeLabel.hidden = YES;
        self.deleteBtn.hidden = YES;
        self.finishBtn.hidden = YES;
    }else{
        self.timeLabel.hidden = NO;
        self.deleteBtn.hidden = NO;
        self.finishBtn.hidden = NO;
    }
}

#pragma mark - 延迟隐藏更多、曝光、聚焦控件ui
/*
 延迟隐藏更多、曝光、聚焦控件ui
 Delay hide more, exposure, focus controls UI
 */
- (void)delayHiddenMoreBgView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenMoreBgView) object:nil];
    [self performSelector:@selector(hiddenMoreBgView) withObject:nil afterDelay:3.0];
}

#pragma mark - 隐藏更多、曝光、聚焦控件ui
/*
 隐藏更多、曝光、聚焦控件ui
 hide more, exposure, focus controls UI
 */
- (void)hiddenMoreBgView {
    self.moreBgView.hidden = YES;
    self.zoomSlider.hidden = YES;
    self.exposureSlider.hidden = YES;
}

#pragma mark - NvAudioPlayerDelegate
///当前播放的位置
///The current playing position
- (void)nvAudioPlayer:(NvAudioPlayer *)player currentTime:(double)currentTime {
    if ((currentTime*NV_TIME_BASE) > self.musicInfo.trimOut) {
        [self nvAudioPlayerPlayEOF:player];
    }
}
///播放到末尾
///Play to the end
- (void)nvAudioPlayerPlayEOF:(NvAudioPlayer *)player {
    [self.audioPlayer seekToTime:self.musicInfo.trimIn/NV_TIME_BASE];
    [self.audioPlayer play];
}

#pragma mark 相册回调 Album callback
- (void)nvAlbumViewCancelMattController:(NvAlbumViewController *)albumViewController{
    
    [self.streamingContext removeCurrentCaptureScene];
    [albumViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    
    if (albumViewController == self.stickerAlbumVC) {
        NvAlbumAsset *assetsGif = assets.firstObject;
        self.cafCreator = [[NvCafCreator alloc]init];
         __weak typeof(self)weakself = self;
        [[PHImageManager defaultManager] requestImageDataForAsset:assetsGif.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([dataUTI isEqualToString:@"com.compuserve.gif"]) {
                    [NvToast showLoading];
                    
                    NSString *tempPath = [NvUtils getTempPath];
                    weakself.cafUuidString = [NvUtils uuidString];
                    weakself.cafGifString = [tempPath stringByAppendingPathComponent:[weakself.cafUuidString stringByAppendingString:@".gif"]];
                    weakself.cafFileString = [tempPath stringByAppendingPathComponent:[weakself.cafUuidString stringByAppendingString:@".caf"]];
                    
                    [imageData writeToFile:weakself.cafGifString atomically:YES];
                    
                    SNvRational frameRate = {20,1};
                    SNvRational pixelAsprectRatio = {1,1};
                    
                    weakself.cafCreator.delegate = weakself;
                    [weakself.cafCreator convertFilePath:weakself.cafGifString targetCafFilePath:weakself.cafFileString width:300 height:300 format:NvCafImageFormat_PNG frameRate:frameRate pixelAsprectRatio:pixelAsprectRatio loopMode:NvCafLoopMode_Repeat];
                    
                    dispatch_queue_t queue = dispatch_queue_create("cafCreator", DISPATCH_QUEUE_CONCURRENT);
                    
                    dispatch_async(queue, ^{
                        [weakself.cafCreator start];
                    });
                }else{
                    
                    NvCustomStickerShapeViewController *vc = NvCustomStickerShapeViewController.new;
                    vc.selectedImage = [weakself getImage:assets.firstObject.asset];
                    [weakself.navigationController pushViewController:vc animated:YES];
                }
            });
        }];
        return;
    }
    
    NSString *backgroundPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Asset/BackgroundMatting"];
    if (assets.count == 1) {
        NvAlbumAsset *asset = assets[0];
        if (asset.isLivePhoto) {
            if (!self->_group) {
                self->_group = dispatch_group_create();
            }
            [self.albumSandBoxs insertObject:asset.albumVideoPath atIndex:0];
        } else {
            [self copyImageMaterialWithLocalIdentifier:asset.asset.localIdentifier destinationPath:backgroundPath];
        }
    }
    
    dispatch_group_notify(self->_group, dispatch_get_main_queue(), ^{
        NvsCaptureSceneInfo *sceneInfo = [NvsCaptureSceneInfo new];
        sceneInfo.backgroundClipArray = [NSMutableArray array];
        
        NvsClipData *clipData = [NvsClipData new];
        clipData.mediaPath = self.albumSandBoxs.firstObject;
        NvsAVFileInfo *info = [self.streamingContext getAVFileInfo:clipData.mediaPath];
        if (info.avFileType == NvsAVFileType_AudioVideo) {
            clipData.scan = 1;
        }else{
            clipData.imageFillMode = @"crop";
        }
        
        [sceneInfo.backgroundClipArray addObject:clipData];
        
        [self.streamingContext applyCaptureScene:self.capturescenePackageId captureSceneInfo:sceneInfo];
        [albumViewController dismissViewControllerAnimated:YES completion:nil];
    });
    
}

- (void)checkExistBackgroundMattingFx {
    BOOL exist = NO;
    for (int i=0; i < [_streamingContext getCaptureVideoFxCount]; i++) {
        NvsCaptureVideoFx *fx = [_streamingContext getCaptureVideoFxByIndex:i];
        if ([fx.bultinCaptureVideoFxName isEqualToString:@"Segmentation Background Fill"]) {
            exist = YES;
            break;
        }
    }
    if (!exist) {
        self.backgroundMattingFx = nil;
    }
}

- (UIImage *)getImage:(PHAsset *)asset {
    __block UIImage *resultImage;
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    // this one is key
    requestOptions.synchronous = YES;
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:PHImageManagerMaximumSize
                                              contentMode:PHImageContentModeAspectFit
                                                  options:requestOptions
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                resultImage = result;
                                            }
     ];
    return resultImage;
}


- (void)cafCreator:(NvCafCreator *)creator convertFinished:(BOOL)finished {
    [NvToast dismiss];
    [self.navigationController popViewControllerAnimated:YES];
    if(finished) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:self.cafFileString]) {
            NSString *dir = [NvUtils getCustomAnimatedStickerPicPath];
            NSString *destgifPath = [dir stringByAppendingPathComponent:[self.cafUuidString stringByAppendingString:@".gif"]];
            NSString *destcafPath = [dir stringByAppendingPathComponent:[self.cafUuidString stringByAppendingString:@".caf"]];
            
            [fileManager copyItemAtPath:self.cafFileString toPath:destcafPath error:nil];
            [fileManager copyItemAtPath:self.cafGifString toPath:destgifPath error:nil];
            
            NvCustomStickerInfo *info = NvCustomStickerInfo.new;
            info.uuid = self.cafUuidString;
            info.templateUuid = @"E14FEE65-71A0-4717-9D66-3397B6C11223";
            info.imagePath = destcafPath;
            info.tempImage = destgifPath;
            info.order = (int)self.captureVM.assetManager.customStickerDict.count;
            
            [self.captureVM.assetManager.customStickerDict setObject:info forKey:info.uuid];
            [self.captureVM.assetManager setAssetInfoToUserDefaults:ASSET_ANIMATED_STICKER];
        }
        NSLog(@"%@", @"caf convert success!");
    } else {
        NSLog(@"%@", @"caf convert failed!");
    }
}

//拷贝图片到指定目录 Copy the image to the specified directory
- (void)copyImageMaterialWithLocalIdentifier:(NSString *)localIdentifier destinationPath:(NSString *)destinationPath {
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
    if (result.count>0) {
        if (!self->_group) {
            self->_group = dispatch_group_create();
        }
        __weak typeof(self)weakSelf = self;
        __strong typeof(self) strongSelf = weakSelf;
        dispatch_group_enter(self->_group);
        PHAsset *targetAsset = result.firstObject;
        if (targetAsset.mediaType == PHAssetMediaTypeVideo) {
            PHVideoRequestOptions *requestOptions = [[PHVideoRequestOptions alloc] init];
            requestOptions.version = PHVideoRequestOptionsVersionOriginal;
            requestOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
            requestOptions.networkAccessAllowed = YES;
            
            [[PHImageManager defaultManager] requestAVAssetForVideo:targetAsset options:requestOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                AVURLAsset *videoAsset = (AVURLAsset *)asset;
                [self.albumSandBoxs insertObject:videoAsset.URL.absoluteString atIndex:0];
                dispatch_group_leave(strongSelf->_group);
            }];
        }else{
            PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            requestOptions.synchronous = YES;
            
            [[PHImageManager defaultManager] requestImageForAsset:targetAsset
                                                       targetSize:CGSizeMake(self.curLiveWindow.width,self.curLiveWindow.height)
                                                      contentMode:PHImageContentModeAspectFit
                                                          options:requestOptions
                                                    resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
             {
                NSString *imagePath =[[destinationPath stringByAppendingPathComponent:[localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"_"]] stringByAppendingPathExtension:@"png"];
                BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
                
                if (!isExist) {
                    BOOL success = [UIImagePNGRepresentation(result) writeToFile:imagePath atomically:YES];
                    if (success) {
                        [self.albumSandBoxs insertObject:imagePath atIndex:0];
                    }else{
                        NSLog(@"保存图片失败 Failed to save picture%@",localIdentifier);
                    }
                }else{
                    [self.albumSandBoxs insertObject:imagePath atIndex:0];
                }
                
                dispatch_group_leave(strongSelf->_group);
            }];
        }
    }
}
- (UIImage *)yp_imageWithOriginalImage:(UIImage *)originalImage withScaleSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [originalImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)yp_imagecutWithOriginalImage:(UIImage *)originalImage withCutRect:(CGRect)rect {
    CGImageRef subImageRef = CGImageCreateWithImageInRect(originalImage.CGImage, rect);
    CGRect smallRect = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallRect, subImageRef);
    UIImage * image = [UIImage imageWithCGImage:subImageRef];
    
    UIGraphicsEndImageContext();
    
    CGImageRelease(subImageRef);
    
    return image;
}

#pragma mark - 处理手机屏幕大于9:16 情况下子视图
/*
 处理手机屏幕大于9:16 情况下子视图
 Handle the subview when the screen of mobile phone is larger than 9:16

 */
- (void)makeSubviewsUnderBiggerRatio {
    if(SCREENHEIGHT - self.liveWindowBGView.bottom > 30) {
        [self.makeupBtn setCustomImage:@"Nvmakeup_b" textColor:@"#000000"];
        [self.beautyBtn setCustomImage:@"Nvbeauty_b" textColor:@"#000000"];
        [self.filterBtn setCustomImage:@"Nvfilter_b" textColor:@"#000000"];
        [self.propBtn setCustomImage:@"Nvprop_b" textColor:@"#000000"];
        
        
        for(NvPsTitleModel *model in self.psTitleArray) {
            model.colorStr = @"#000000";
        }
        [self.psTitleCollectionView reloadData];
    }
}

#pragma mark - 键盘遮挡视图点击 Keyboard Occlusion view click
- (void)keybordMaskTap{
    [self.filterListViewController cancelSearchResponder];
    [self.propsListViewController cancelSearchResponder];
    [self.stickersListViewController cancelSearchResponder];
    [self.captionsListViewController cancelSearchResponder];
}

#pragma mark - 应用道具 Application item
- (void)applicationProps:(NvBaseModel *)model{
    self.startPreviewTime = [NSDate date];
    self.currentPropsModel = (NvCapturePropsModel *)model;
    NSString *tipString = [self.streamingContext.assetPackageManager getARSceneAssetPackagePrompt:model.packageId];
    if (tipString.length>0) {
        [NvToast showInfoWithMessage:tipString];
    }
    
    NvsARSceneCameraPreset preset;
    BOOL cameraPreset = [self.streamingContext.assetPackageManager getARSceneAssetPackage:model.packageId cameraPreset:&preset];
    if (cameraPreset) {
        [self.fxARFace setFloatVal:@"Face Camera Fovy" val:preset.fovy];
    } else {
        [self.fxARFace setFloatVal:@"Face Camera Fovy" val:45];
    }
    [self.fxARFace setStringVal:@"Scene Id" val:model.packageId];
}

#pragma mark - 应用贴纸 Apply sticker
- (void)applicationSticker:(NvBaseModel*)model{
    NvAssetCellModel * tmpModel = [[NvAssetCellModel alloc]init];
    tmpModel.builtinName = model.builtinName;
    tmpModel.displayName = model.displayName;
    tmpModel.package = model.packageId;
    tmpModel.cover = model.coverName;
    tmpModel.selected = model.selected;
    tmpModel.size = model.size;
    tmpModel.draw = model.draw;
    tmpModel.state = model.state;
    tmpModel.packID = model.packageId;
    tmpModel.packPath = model.packagePath;
    [self addSticker:tmpModel];

    self.rectView.hidden = NO;
    [self showStickerBoundingView];
}

#pragma mark - 应用字幕 Application captioning
- (void)applicationCaption:(NvBaseModel *)model{
    NvCaptionStyleItem *item = NvCaptionStyleItem.new;
    item.isSelect = model.selected;
    item.imageUrl = model.coverName;
    item.name = model.displayName;
    item.packageId = model.packageId;
    item.packagePath = model.packagePath;
    
    self.startPreviewTime = [NSDate date];
    [self addCompoundCaption:item];
    self.rectView.hidden = NO;
    [self showCaption];
}

#pragma mark - 切换底部录制、拍照按钮
/*
 切换底部录制、拍照按钮
 Switch the bottom record and photo buttons
 */
- (void)selectCaptureMode {
    for (NvPsTitleModel *model in self.psTitleArray) {
        model.selected = NO;
    }
    NvPsTitleModel *seletedModel = self.psTitleArray[_currentInteger];
    seletedModel.selected = YES;
    [_psTitleCollectionView reloadData];
    
    if (_currentInteger == 0) {
        [_psTitleCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
        [self.shootingBtn setImage:NvImageNamed(@"Nv_capture_takePhoto") forState:UIControlStateNormal];
    }else{
        if (self.videoPathArray.count < 1) {
            [self.shootingBtn setImage:NvImageNamed(@"Nv_capture_recording") forState:UIControlStateNormal];
        }
        [_psTitleCollectionView setContentOffset:CGPointMake(60 * SCREENSCALE, 0) animated:YES];
        
    }
}

#pragma mark - 隐藏变声、音频降噪按钮
/*
 隐藏变声按钮
 Hide voice change button
 */
-(void)hidVoice{
    self.voiceBtn.hidden = YES;
    self.noiseSuppressionBtn.hidden = YES;
}

#pragma mark - 显示变声、音频降噪按钮
/*
 显示变声按钮
 Display sound change button
 */
-(void)showVoice{
    self.voiceBtn.hidden = NO;
    self.noiseSuppressionBtn.hidden = YES;
}

- (void)checkAssetExpValueList:(NvBaseModel *)model type:(NvsAssetPackageType)type {
    NvsAssetPackageManager *assetPackageManager = self.streamingContext.assetPackageManager;
    NSArray <NvsExpressionParam *>* expArr = [assetPackageManager getExpValueList:model.packageId type:type];
    NSDictionary<NSString*, NSString*>* translation = [assetPackageManager getTranslationMap:model.packageId type:type];
    NSLog(@"get expValue list");
    if (type == NvsAssetPackageType_VideoFx) {
        self.filterPrmView.hidden = expArr.count > 0 ? NO : YES;
        if(expArr.count > 0){
            if (expArr.count<4) {
                CGRect frame = self.filterPrmView.frame;
                CGFloat minX = CGRectGetMinX(frame);
                CGFloat width = CGRectGetWidth(frame);
                CGFloat maxY = CGRectGetMaxY(frame);
                CGFloat minY = maxY - 12*SCREENSCALE*(expArr.count-1) - 35*SCREENSCALE*expArr.count;
                self.filterPrmView.frame = CGRectMake(minX, minY, width, maxY-minY);
            }else {
                CGFloat bottomSafeDistance = (NV_STATUSBARHEIGHT>20)?10:0;
                CGRect rect = CGRectMake(0, SCREENHEIGHT - 200*SCREENSCALE-bottomSafeDistance, SCREENWIDTH, 200*SCREENSCALE+bottomSafeDistance);
                CGFloat height = 200 * SCREENSCALE;
                CGFloat y = CGRectGetMinY(rect) - height;
                self.filterPrmView.frame = CGRectMake(0, y, SCREENWIDTH, height);
                
            }
            [self.filterPrmView updateFxParams:expArr translation:translation];
        }else{
            [self.filterPrmView cancelAnimation];
        }
    }
}

#pragma mark - NvSelectMusicViewControllerDelegate
- (void)selectMusicViewController:(NvSelectMusicViewController *)selectMusicViewController withItem:(NvEditSelectMusicItem *)item trimIn:(float)trimIn trimOut:(float)trimOut {
    self.musicInfo = [NvMusicInfoModel new];
    self.musicInfo.musicPath = item.musicPath;
    self.musicInfo.trimIn = trimIn*NV_TIME_BASE;
    self.musicInfo.trimOut = trimOut*NV_TIME_BASE;
    self.musicInfo.musicName = item.musicName;
    self.musicInfo.duration = self.musicInfo.trimOut - self.musicInfo.trimIn;
    self.musicInfo.volume = 1;
    self.musicInfo.isBGM = YES;
    
    self.musicLabel.text = self.musicInfo.musicName;
    [self.musicLabel startAnimate];
    [self.musicLabel sizeToFit];
    CGFloat tempWidth = self.musicLabel.width > 100 ? 100 : self.musicLabel.width;
    [self.musicBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.offset(20 * SCREENSCALE + 10 * SCREENSCALE + tempWidth);
    }];
    
    [self.streamingContext setAECEnabled:true];
    if (!self.audioPlayer){
        self.audioPlayer = [[NvAudioPlayer alloc] init];
        self.audioPlayer.delegate = self;
    }
    [self.audioPlayer setUrlString:self.musicInfo.musicPath];
    [self.audioPlayer seekToTime:trimIn];
}

- (void)selectNoneMusic {
    self.musicInfo = nil;
    [self.musicLabel stopAnimate];
    [self.streamingContext setAECEnabled:false];
    self.musicLabel.text = NvLocalString(@"selectMusic", @"选择音乐");
    [self.musicLabel sizeToFit];
    [self.musicBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.offset(20 * SCREENSCALE + 10 * SCREENSCALE + self.musicLabel.width);
    }];
}

- (BOOL)updateNotMusicState{
    return self.musicInfo?true:false;
}

#pragma mark - NvTitleListViewControllerDelegate
- (void)titleListVC:(NvTitleListViewController *)vc withApplyEffects:(NvBaseModel *)model{
    switch (vc.type) {
        case ASSET_FILTER:{
            if (!model) {
                self.filterSlider.hidden = YES;
            }
            [self.filterPrmView delayaf];
            [self checkAssetExpValueList:model type:NvsAssetPackageType_VideoFx];
            [self replaceMakeupFilters];
            [self.captureVM applyFilter:model];
            if (model) {
                if (model.categoryId == 2 && (model.kindId == 8||model.kindId == 9)){
                    self.filterSlider.hidden = YES;
                }
            }
        }
            break;
        case ASSET_ARSCENE:{
            [self applicationProps:model];
        }
            break;
        
        case ASSET_COMPOUND_CAPTION:{
            [self applicationCaption:model];
        }
            break;
            
        default:
            break;
    }
}

- (void)titleListVC:(NvTitleListViewController *)vc withKeyboardShow:(BOOL)show{
    if (show) {
        if (self.keybordMaskView) {
            [self.keybordMaskView removeFromSuperview];
            self.keybordMaskView = nil;
        }
        self.keybordMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - CGRectGetMinY(vc.view.frame))];
        __weak typeof(self)weakSelf = self;
        self.inputCompoundView.keyboardClick = ^(CGFloat height) {
            if (height > CGRectGetMinY(vc.view.frame)) {
                weakSelf.keybordMaskView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - height);
            }
        };
        UITapGestureRecognizer *keybordMaskTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keybordMaskTap)];
        [self.keybordMaskView addGestureRecognizer:keybordMaskTap];
        [self.view addSubview:self.keybordMaskView];
    }else{
        if (self.keybordMaskView) {
            [self.keybordMaskView removeFromSuperview];
            self.keybordMaskView = nil;
        }
    }
}

- (void)titleListVC:(NvTitleListViewController *)vc stickerAddWithBaseModel:(NvBaseModel *)model{
    [self applicationSticker:model];
}

- (void)titleListVC:(NvTitleListViewController *)vc stickerAddWithAssetCellModel:(NvAssetCellModel *)model{
    [self addSticker:model];

    self.rectView.hidden = NO;
    [self showStickerBoundingView];
}

- (void)titleListVC:(NvTitleListViewController *)vc stickerAddCusstom:(NvAssetCellModel *)model{
    NvAlbumViewController *album = [NvAlbumViewController new];
    album.isOnlyImage = YES;
    album.mutableSelect = NO;
    album.delegate = self;
    [album customSelectAssetButtonText:NvLocalString(@"Start making", @"开始制作贴纸")];
    self.stickerAlbumVC = album;
    [self.navigationController pushViewController:album animated:YES];
}

#pragma mark - NvMakeupViewDelegate
- (void)nvMakeupView:(NvMakeupView *)makeupView applyVariableMakeupEffect:(NSString *)path {
    if (path.length > 0) {
        self.appliedMakeup = YES;
        [self.makeupManager applyMakeupEffect:path arsceneFx:self.fxARFace];
    }else{
        self.appliedMakeup = NO;
        self.filterCanReplace = YES;
        [self.makeupManager removeAllMakeupEffects:self.fxARFace];
        [self.beautyView resetAll];
        [self applyDefaultFilter];
    }
    self.currentMakeupVariableModel = [self.makeupManager getEffectModel];
    NSArray <NvMakeupToolEffectModel *>*filterArr = self.currentMakeupVariableModel.effectContent.filter;
    if (filterArr.count > 0) {
        self.filterCanReplace = NO;
        for (int i=0; i<filterArr.count; i++) {
            NvMakeupToolEffectModel *filterModel = filterArr[i];
            if(filterModel.canReplace){
                self.filterCanReplace = YES;
                break;
            }
        }
    }else{
        self.filterCanReplace = YES;
    }
    
    [self.captureVM applyMakeupAndBeautyTemplate:NO];
}

- (void)nvMakeupView:(NvMakeupView *)makeupView changeVariableMakeup:(CGFloat)value with:(BOOL)filter{
    self.currentMakeupVariableModel = [self.makeupManager getEffectModel];
    if (filter){
        if (self.captureVM.fxFilter) {
            [self.captureVM.fxFilter setFilterIntensity:value];
        }else{
            self.currentMakeupVariableModel.filterCurrentValue = value;
            [self.makeupManager changeMakeupFilterArsceneFx:self.fxARFace];
        }
    }else{
        self.currentMakeupVariableModel.currentValue = value;
        [self.makeupManager changeMakeupEffectArsceneFx:self.fxARFace];
    }
}

- (void)nvMakeupView:(NvMakeupView *)makeupView applySingleKindMakeupEffect:(NvMakeupEffectModel *)effectModel {
    self.currentMakeupVariableModel = [self.makeupManager getEffectModel];
    for (NvMakeupToolEffectModel *toolEffectModel in self.currentMakeupVariableModel.effectContent.makeup) {
        if ([effectModel.makeup.firstObject.makeupId isEqualToString:toolEffectModel.type]) {
            toolEffectModel.beReplaced = YES;
            break;
        }
    }
    [self.fxARFace setStringVal:@"Makeup Compound Package Id" val:@""];
    if(effectModel.makeup.count > 0){
        for (NvMakeupEffectContentModel *model in effectModel.makeup) {
            if (model.makeupId) {
                NSString *baseStr = [@"Makeup " stringByAppendingString:model.makeupId];
                NSString *packageId = [baseStr stringByAppendingString:@" Package Id"];
                if ([packageId caseInsensitiveCompare:model.className] == NSOrderedSame && ![model.className isEqualToString:@"Makeup Compound Package Id"]) {
                    [self.fxARFace setStringVal:model.className val:model.uuid];
                    NSString *colorStr = [baseStr stringByAppendingString:@" Color"];
                    NSString *intensityStr = [baseStr stringByAppendingString:@" Intensity"];
                    [self.fxARFace setFloatVal:intensityStr val:model.intensity];
                    
                    if(model.color.length > 0){
                        NvsColor color = [self nvsColorWithValue:model.color];
                        [self.fxARFace setColorVal:colorStr val:&color];
                    }else {
                        NvsColor color;
                        color.r = 0;
                        color.g = 0;
                        color.b = 0;
                        color.a = 0;
                        [self.fxARFace setColorVal:colorStr val:&color];
                    }
                }
            }
            else{
                [self.fxARFace setStringVal:model.className val:model.uuid];
            }
            
        }
    }else {
        /// remove the target effect when it select "none"
        
        if (!effectModel.makeupId) {
            return;
        }
        NSString *baseStr = [@"Makeup " stringByAppendingString:effectModel.makeupId];
        NSString *packageId = [baseStr stringByAppendingString:@" Package Id"];
        [self.fxARFace setStringVal:packageId val:@""];
        NSString *intensityStr = [baseStr stringByAppendingString:@" Intensity"];
        [self.fxARFace setFloatVal:intensityStr val:0];
        
        NvsColor color;
        color.r = 0;
        color.g = 0;
        color.b = 0;
        color.a = 0;
        NSString *colorStr = [baseStr stringByAppendingString:@" Color"];
        [self.fxARFace setColorVal:colorStr val:&color];
    }
    
    [self.fxARFace setFloatVal:@"Makeup Intensity" val:1];
}

- (void)nvMakeupView:(NvMakeupView *)makeupView forbiddenReplaceMakeupEffect:(NvMakeupEffectModel *)makeupModel {
    [self presentMakeupUnReplaceableAlertController];
}

- (NvsColor)nvsColorWithValue:(NSString *)value {
    NSArray *arr = [value componentsSeparatedByString:@","];
    NvsColor color;
    color.r = 0;
    color.g = 0;
    color.b = 0;
    color.a = 0;
    if (arr.count == 4) {
        color.r = [arr[0] floatValue];
        color.g = [arr[1] floatValue];
        color.b = [arr[2] floatValue];
        color.a = [arr[3] floatValue];
    }
    return color;
}

#pragma mark - NvMakeupToolManagerDelegate
- (NSArray <NvMakeupContentModel *> *)getExistSingleMakeupElements:(NvMakeupToolManager *)manager {
    return [self.makeupView getSelectedSingleElements];
}

#pragma mark - NvCaptureModularVMUIDelegate
- (void)showColorCorrectTips:(BOOL)open {
    if (self.tipLabel) {
        [self.tipLabel removeFromSuperview];
        self.tipLabel = nil;
    }
    if(!self.startupCaptureValue){
        self.tipLabel = [[UILabel alloc]init];
        self.tipLabel.backgroundColor = UIColor.clearColor;
        self.tipLabel.textColor = UIColor.whiteColor;
        self.tipLabel.font = [NvUtils fontWithSize:16];
        [self.view addSubview:self.tipLabel];

        if (open) {
            self.tipLabel.text = NvLocalString(@"Beauty filter on", @" • 美颜滤镜开启");
        }
        else{
            self.tipLabel.text = NvLocalString(@"Beauty filter off", @" • 美颜滤镜关闭");
        }
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(231 * SCREENSCALE);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tipLabel removeFromSuperview];
            self.tipLabel = nil;
        });
    }else{
        self.startupCaptureValue = NO;
    }
}

- (void)showSharpenTips:(BOOL)open {
    if (self.tipLabel) {
        [self.tipLabel removeFromSuperview];
        self.tipLabel = nil;
    }
    self.tipLabel = [[UILabel alloc]init];
    self.tipLabel.backgroundColor = UIColor.clearColor;
    self.tipLabel.textColor = UIColor.whiteColor;
    self.tipLabel.font = [NvUtils fontWithSize:16];
    [self.view addSubview:self.tipLabel];
    if (open) {
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"SharpnessOn"] boolValue]) {
            self.tipLabel.text = NvLocalString(@"Sharpness on", @" • 锐度开启");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SharpnessOn"];
        }
    }else{
        self.tipLabel.text = NvLocalString(@"Sharpness off", @" • 锐度关闭");
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SharpnessOn"];
    }
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(231 * SCREENSCALE);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tipLabel removeFromSuperview];
        self.tipLabel = nil;
    });
}

- (void)showNoARScenePermissionAlert {
    [self switchActionShowToast];
}

- (void)showUnReplaceableEffectTips {
    [self presentMakeupUnReplaceableAlertController];
}

- (void)showForbiddenBeautyTypeEffectTips {
    [self presentBeautyTypeForbiddenAppledAlertController];
}

- (void)showAdvacedBeautyThreeOverWeightNegativeToast {
    [NvToast showInfoWithMessage:NvLocalString(@"NegativeAffectDueGANBeauty", @"GAN美颜效果在当前机型上可能会有卡顿")];
}

- (void)updateFilterElementsInBeautyView:(NvCaptureFilterModel *)model {
    if (!model) {
        self.filterSlider.hidden = YES;
        self.filterPrmView.hidden = YES;
        return;
    }
    
    if (![model.displayName isEqualToString:NvLocalString(@"None", @"无")]) {
        
        if (model.builtinName) {
            if ([model.builtinName isEqualToString:@"Cartoon"]) {
                
            }
        } else if (model.packageId) {
            if ([self.captureVM containExpParam:model]) {
                self.filterSlider.hidden = YES;
            }else{
                self.filterSlider.hidden = NO;
                self.filterSlider.value = model.value;
            }
        }
    }
}

- (void)updateFilterView:(NvEffectsStyleModel *)model needReplaceElements:(BOOL)needReplace destinationIndex:(NSInteger)destinationIndex {
    [self.filterListViewController selecteMaterial:model.filterPackageId];
    if (needReplace) {
        [self.filterListViewController changeAsset:model.filterPackageId withDestinationIndex:destinationIndex];
    }
}

#pragma mark - NvAdjustFxParamViewDelegate
- (void)nvAdjustFxParamView:(NvAdjustFxParamView *)view valueChanged:(nonnull NSArray<NvAjustFxParamModel *> *)models {
    if (view == self.filterPrmView) {
        [self.captureVM setFilterExpValue:models];
    }
}

- (void)nvAdjustFxParamView:(NvAdjustFxParamView *)view endChange:(NSArray<NvAjustFxParamModel *> *)models {
    if (view == self.filterPrmView) {
        [self.captureVM applyFilterAndSetExpValue:models];
    }
}

#pragma mark - YWISOSliderDelegate
- (void)YWISOSliderValueChanged:(YWISOSlider *)slider {
    [self delayHiddenMoreBgView];
    if(slider == self.zoomSlider){
        slider.tagLabel.text = [NSString stringWithFormat:@"%.1fx",slider.value];
        [self.streamingContext setZoomFactor:slider.value];
    }else if (slider == self.exposureSlider){
        slider.tagLabel.text = [NSString stringWithFormat:@"%.1f",slider.value];
        [self.streamingContext setExposureBias:slider.value];
    }
    
}

#pragma mark - BLItemSliderDelegate
-(void)itemSlider:(BLItemSlider*)slider valueChanged:(float)value{
    [self.captureVM.fxFilter setFilterIntensity:value];
}

-(void)itemSliderTouchEnd:(BLItemSlider*)slider{
    self.captureVM.currentFilterModel.value = slider.value;
}

#pragma mark - NvsStreamingContextDelegate
- (void)didCaptureRecordingDurationUpdated:(int)captureDeviceIndex duration:(int64_t)duration{
    if (_currentInteger == 0) {
        if (duration >= 40000) {
            if (self.isHaveImage) {
                self.isHaveImage = NO;
                [self stopRecording];
            }
        }
    }else{
        if (self.shootingBtn.isSelected) {
            self.lastDuration = duration;
            self.timeLabel.text = [NvUtils convertTimecode:self.duration + duration];
        }
        if (duration >= NV_TIME_BASE) {
            self.shootingBtn.enabled = YES;
        }
    }
}

- (void)didCaptureDeviceCapsReady:(unsigned int)captureDeviceIndex{
    self.capability = [_streamingContext getCaptureDeviceCapability:captureDeviceIndex];
    if (!self.capability){
        return;
    }
    self.zoomSlider.maximumValue = self.capability.maxZoomFactor > 10 ? 10 : self.capability.maxZoomFactor;
    self.zoomSlider.minimumValue = 1.f;
    self.exposureSlider.minimumValue = -1;
    self.exposureSlider.maximumValue = 1;
    
    self.zoomSlider.value = [_streamingContext getZoomFactor];
    self.exposureSlider.value = [_streamingContext getExposureBias];
    [self.streamingContext setExposureBias:self.exposureSlider.value];
    CGPoint point = CGPointMake(0.49*self.liveWindow.width, self.liveWindow.height / 2);
    [self performSelector:@selector(delayaf) withObject:nil afterDelay:3.0];
    if (self.capability.supportAutoFocus) {
        [_streamingContext startAutoFocus:point];
    }
    if (self.capability.supportAutoExposure) {
        [_streamingContext startAutoExposure:point];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _psTitleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvPsTitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvpsTitleCell" forIndexPath:indexPath];
    [cell renderCellWithString:self.psTitleArray[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _currentInteger = indexPath.item;
    if (indexPath.item == 0) {
        [self hidVoice];
        _ifShowVoiceBtn = NO;
    }else{
        [self showVoice];
        _ifShowVoiceBtn = YES;
    }
    [self selectCaptureMode];
}

#pragma mark - 将拍摄的视频保存到本地相册
/*
 将拍摄的视频保存到本地相册
 Save captured video to local album
 
 @param videoPath 保存的视频路径
 Saved video path
 */
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    [UIAlertController presentAlertFromVC:self
                                    title:NvLocalString(@"Packaged successfully", @"打包成功")
                                  message:NvLocalString(@"Saved to album", @"已保存至相册")
                        buttonTitleColors:nil
                        cancelButtonTitle:nil
                         otherButtonTitle:NvLocalString(@"Sure", @"确定")
                       cancelButtonAction:nil
                        otherButtonAction:nil];

}

#pragma mark - CXCallObserverDelegate
- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.streamingContext.getStreamingEngineState == NvsStreamingEngineState_CaptureRecording){
            self.shootingBtn.enabled = YES;
            self.shootingBtn.selected = NO;
            [self setShootingBtnImage];
            [self faceHiddenBtn:NO];
            [self stopRecording];
            self.videoCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)_videoPathArray.count];
            self.timeLabel.textColor = UIColor.whiteColor;
            self.timeIndicator.hidden = YES;
            self.videoCount.hidden = NO;
            self.duration = self.duration + self.lastDuration;
            [self.durationArray addObject:[NSNumber numberWithLongLong:self.lastDuration]];
        }
        if (call.hasEnded){
            self.audioInterruption = NvAudioInterruptionStateNone;
        }else{
            self.audioInterruption = NvAudioInterruptionStateAffecting;
        }
        [self startCapturePreview];
    });
}

#pragma mark - 注册应用前台后台通知事件
/*
 注册应用前台后台通知事件
 Register application foreground and background notification events
 */
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationChange:)

                                         name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - 应用进入后台，停止采集
/*
 应用进入后台，停止采集
 The application enters the background and stops collecting
 */
- (void)applicationWillResignActive:(NSNotification*)notification {
    if ([_streamingContext getStreamingEngineState] == NvsStreamingEngineState_CaptureRecording) {
        self.shootingBtn.enabled = YES;
        self.shootingBtn.selected = NO;
        [self setShootingBtnImage];
        [self faceHiddenBtn:NO];
        [self stopRecording];
        self.videoCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)_videoPathArray.count];
        self.timeLabel.textColor = UIColor.whiteColor;
        self.timeIndicator.hidden = YES;
        self.videoCount.hidden = NO;
        self.duration = self.duration + self.lastDuration;
        [self.durationArray addObject:[NSNumber numberWithLongLong:self.lastDuration]];
    }
    if (_currentDeviceIndex != [self frontCameraDeviceIndex]) {
        _flashBtn.alpha = 1;
        _flashBtn.userInteractionEnabled = YES;
        _flashBtn.selected = NO;
    }
    if ([_streamingContext getStreamingEngineState] == NvsStreamingEngineState_CapturePreview) {
        [_streamingContext stop];
    }
}


#pragma mark - 应用进入前台，开始采集
- (void)applicationDidBecomeActive:(NSNotification*)notification {
    if (self.isViewLoaded && [self.navigationController.topViewController isEqual:self]) {
        if ([_streamingContext getStreamingEngineState] == NvsStreamingEngineState_Stopped || self.needReStartCapturePreview == YES) {
            [self startCapturePreview];
        }
    }
}

#pragma mark lazyload
- (YWISOSlider *)zoomSlider {
    if(!_zoomSlider) {
        _zoomSlider = [[YWISOSlider alloc] initWithFrame:CGRectMake(10*SCREENSCALE, 156*SCREENSCALE, 30*SCREENSCALE, 224*SCREENSCALE)];
        _zoomSlider.delegate = self;
        _zoomSlider.thumbImage = NvImageNamed(@"capture_zoom");
    }
    return _zoomSlider;
}

- (YWISOSlider *)exposureSlider {
    if(!_exposureSlider) {
        _exposureSlider = [[YWISOSlider alloc] initWithFrame:CGRectMake(10*SCREENSCALE, 156*SCREENSCALE, 30*SCREENSCALE, 224*SCREENSCALE)];
        _exposureSlider.delegate = self;
        _exposureSlider.thumbImage = NvImageNamed(@"capture_exposure");
    }
    return _exposureSlider;
}

/*
 懒加载权限视图
 Loading permissions view
 */
- (NvTipsView *)permissions{
    if (!_permissions)
    {
        _permissions = [[NvTipsView alloc]initWithFrame:self.view.frame withPrompt:NvLocalString(@"Tips", @"提示") describeTitle:NvLocalString(@"camera.microphone.permissions", @"需要打开摄像头和麦克风权限 请在手机设置中进行允许") describeContent:nil buttonText:NvLocalString(@"Know", @"知道了") withCenter:YES];
        [_permissions.clickBtn addTarget:self action:@selector(knowClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _permissions;
}

- (NvTitleListViewController *)filterListViewController {
    if (!_filterListViewController) {
        _filterListViewController = [[NvTitleListViewController alloc] init];
        _filterListViewController.delegate = self;
        _filterListViewController.type = ASSET_FILTER;
    }
    return _filterListViewController;
}

- (void)setBeautyView:(NvBeautyView *)beautyView {
    _beautyView = beautyView;
}

- (NvBeautyView *)beautyView {
    return _beautyView;
}

- (void)setIsFirstAdvancedBeautyType:(BOOL)isFirstAdvancedBeautyType {
    _isFirstAdvancedBeautyType = isFirstAdvancedBeautyType;
}

- (BOOL)isFirstAdvancedBeautyType {
    return _isFirstAdvancedBeautyType;
}

- (void)setCurrentMakeupVariableModel:(NvMakeupToolModel *)currentMakeupVariableModel {
    _currentMakeupVariableModel = currentMakeupVariableModel;
    self.beautyView.currentMakeupVariableModel = currentMakeupVariableModel;
}

//获取字幕对应的infoModel对象 Obtain the infoModel object corresponding to the subtitle
- (NvStickerInfoModel *)getStickerInfoModel:(NvsCaptureAnimatedSticker *) nextSticker {
    return (NvStickerInfoModel *)[nextSticker getAttachment:@"stickerInfoModel"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

