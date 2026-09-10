//
//  NvVKeyerViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/10/11.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvVKeyerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <NvStreamingSdkCore/NvsStreamingContext.h>
#import <NvSDKCommon/NvAssetManager.h>
#import "NvsCaptureVideoFx.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import <Photos/Photos.h>
#import <NvSDKCommon/NvCompileViewController.h>
#import "NvPreViewLiveWindow.h"
#import "NvVirtualGraphicBtn.h"
#import "NvVirtualKeyerCell.h"
#import "NvVirtualKeyerModel.h"
#import <Masonry/Masonry.h>
#import <NvBaseCommon/UIColor+NvColor.h>
#import <NvSDKCommon/NvUtils.h>
#import <NvBaseCommon/UIView+Dimension.h>
#import <NvAlbum/NvAlbumViewController.h>
#import <NvBaseCommon/NSString+NvPath.h>

@interface NvVKeyerViewController ()<NvsStreamingContextDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NvCompileViewControllerDelegate,NvAssetManagerDelegate>
///界面按钮
///Interface button
///关闭
///Shut down
@property (nonatomic, strong) UIButton *backBtn;
///切换摄像头
///Switch camera
@property (nonatomic, strong) NvVirtualGraphicBtn *deviceBtn;
///闪光灯
///Flash lamp
@property (nonatomic, strong) NvVirtualGraphicBtn *flashBtn;
///虚拟背景
///Virtual background
@property (nonatomic, strong) NvVirtualGraphicBtn *virtualBgBtn;
///拍摄
///shoot
@property (nonatomic, strong) UIButton *shootingBtn;
@property (nonatomic, strong) UIButton *shootingBtn_1;
///完成
///complete
@property (nonatomic, strong) UIButton *finishBtn;
///录制时长
///Recording duration
@property (nonatomic, strong) UILabel  *timeLabel;
///删除视频
///Delete video
@property (nonatomic, strong) UIButton *deleteBtn;
///视频个数
///Number of videos
@property (nonatomic, strong) UILabel  *videoCount;

///抠像视图
///Keying view
@property (nonatomic, strong) UIView *virtualBgView;

@property (nonatomic, strong) UIButton *picBtn;
@property (nonatomic, strong) UIView *picLine;
@property (nonatomic, strong) UIButton *videoBtn;
@property (nonatomic, strong) UIView *videoLine;
///背景特效滑动视图
///Background effects slide view
@property (nonatomic, strong) UICollectionView *virtualPictureCollectionView;
///背景特效数组
///Background effects array
@property (nonatomic, strong) NSMutableArray *virtualPictureDataSource;
///背景特效滑动视图
///Background effects slide view
@property (nonatomic, strong) UICollectionView *virtualBgCollectionView;
///背景特效数组
///Background effects array
@property (nonatomic, strong) NSMutableArray *virtualBgDataSource;

///预览视图
///Preview view
@property (nonatomic, strong) NvPreViewLiveWindow *preView;

//-----------------逻辑相关  Logical correlation----------------//
///当前设备摄像头索引
///Current device camera index
@property (nonatomic, assign) int currentDeviceIndex;
///当前特效对象索引
///Index of the current effects object
@property (nonatomic, assign) int currentFxIndex;
///底部弹窗视图出现和消失
///Bottom popover view appears and disappears
@property (nonatomic, assign) BOOL clickState;
///当前操作的特效对象
///The effect object of the current operation
@property (nonatomic, strong) NvVirtualKeyerModel *currentModel;
///视频路径数组
///Video path array
@property (nonatomic, strong) NSMutableArray *videoPathArray;
///断点拍摄每段视频的时长数组
///Breakpoint takes an array of the duration of each video
@property (nonatomic, strong) NSMutableArray *durationArray;
///总拍摄时长
///Total shooting duration
@property (nonatomic, assign) int64_t duration;
///断点拍摄每次停止录制的时长，duration和durationArray需要用到
///Breakpoints capture the duration of each stop. Duration and durationArray are used
@property (nonatomic, assign) int64_t lastDuration;
///生成路径
///Generating path
@property (nonatomic, strong) NSString *compileFilePath;

//-----------------sdk相关 SDK-related----------------//
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) NvsLiveWindow *liveWindow;
@property (nonatomic, strong) NvsLiveWindow *liveWindowBack;
///当前窗口
///Current window
@property (nonatomic, strong) NvsLiveWindow *curLiveWindow;
///素材管理
///Material management
@property (nonatomic, strong) NvAssetManager *assetManager;
///背景抠像特效
///Background carryout effect
@property (nonatomic, strong) NvsCaptureVideoFx *keyerFx;
@property (nonatomic, assign) CGSize gradeSize;
@property (nonatomic, strong) NSMutableString *capturescenePackageIdDefault;

@end

@implementation NvVKeyerViewController
{
   dispatch_group_t _group;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s",__func__);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.streamingContext.getStreamingEngineState != NvsStreamingEngineState_CapturePreview) {
        [self startCapturePreview];
        self.streamingContext.delegate = self;
    }
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.virtualBgDataSource = [NSMutableArray array];
    self.virtualPictureDataSource = [NSMutableArray array];
    self.videoPathArray = [NSMutableArray array];
    self.durationArray = [NSMutableArray array];
    NvVirtualKeyerModel *model = [NvVirtualKeyerModel new];
    model.packageId = @"";
    model.categoryId = @"";
    model.displayName = @"";
    model.coverName = @"Nv_edit_bg_style_add";
    model.state = Finish;
    [self.virtualPictureDataSource addObject:model];
    [self addLocalBGImage];
    self.gradeSize = CGSizeMake(1080, 1920);
    self.assetManager = [NvAssetManager sharedInstance];
    self.assetManager.delegate = self;
    
    [self.assetManager searchLocalAssets:ASSET_CAPTURE_SCENE];
    
    NSString *masterKeyerPath = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_COPY_PATH_MASTERKEYER_BACKGROUND_IMAGE];
    if (![[NSFileManager defaultManager] fileExistsAtPath:masterKeyerPath isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:masterKeyerPath withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        [[NSFileManager defaultManager] removeItemAtPath:masterKeyerPath error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:masterKeyerPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [self addObservers];
    ///检查摄像头权限
    ///Checking camera permissions
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
                            ///提示麦克风权限未获得
                            ///A message is displayed indicating that the microphone permission is not obtained
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf startupCapture];
                                [weakSelf presentPermissions];
                            });
                        }
                    }];
                }
            } else {
                ///提示摄像头权限未获得
                ///A message is displayed indicating that the camera permission is not obtained
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf presentPermissions];
                });
            }
        }];
    } else if (authStatus == AVAuthorizationStatusDenied) {
        ///提示摄像头权限未获得
        ///A message is displayed indicating that the camera permission is not obtained
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf presentPermissions];
        });
    } else {
        ///检查麦克风权限
        ///Check microphone permissions
        authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (authStatus == AVAuthorizationStatusDenied) {
            ///提示麦克风权限未获得
            ///A message is displayed indicating that the microphone permission is not obtained
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf presentPermissions];
            });
        }
        [weakSelf startupCapture];
    }
}

- (void)addLocalBGImage {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *basePath = [[NSBundle mainBundle] pathForResource:@"masterKeyer" ofType:@"bundle"];
    NSString *bgImgPath = [basePath stringByAppendingPathComponent:@"BGImage"];
    NSArray *arr = [manager contentsOfDirectoryAtPath:bgImgPath error:nil];
    NSMutableArray *effectDirs = [NSMutableArray array];
    for (NSString *displayName in arr) {
        BOOL isDir = NO;
        BOOL isExist = [manager fileExistsAtPath:[bgImgPath stringByAppendingPathComponent:displayName] isDirectory:&isDir];
        if(isExist && !isDir) {
            NvVirtualKeyerModel *localModel = [NvVirtualKeyerModel  new];
            localModel.coverName = [bgImgPath stringByAppendingPathComponent:displayName];
            localModel.state = Finish;
            [self.virtualPictureDataSource addObject:localModel];
        }
    }
}

#pragma mark 初始化美摄sdk
///Initialize the Beauty sdk
- (void)startupCapture{
    
    self.streamingContext = [NvsStreamingContext sharedInstance];
    if (!_streamingContext) {
        return;
    }
    
    
    _streamingContext.delegate = self;
    
    ///由于本示例程序需要演示虚拟场景，所以需要给拍摄添加一个抠像特技
    ///Because this sample program is demonstrating a virtual scene, you need to add a pickling effect to the shot
    self.keyerFx = [_streamingContext appendBuiltinCaptureVideoFx:@"Master Keyer"];
    if (_keyerFx) {
        ///开启溢色去除
        ///Turn on overflow color removal
        [_keyerFx setBooleanVal:@"Spill Removal" val:YES];
        ///将溢色去除强度设置为最低
        ///Set the overflow removal intensity to the lowest level
        [_keyerFx setFloatVal:@"Spill Removal Intensity" val:0];
        ///设置收缩边界强度
        ///Set the strength of the contraction boundary
        [_keyerFx setFloatVal:@"Shrink Intensity" val:0.4];
        ///抠像方式
        ///Image picking mode
        ///Master Mode、RGB Mode、Hsv Mode
        [_keyerFx setMenuVal:@"Keyer Mode" val:@"Master Mode"];
    }
    
    ///检查可用采集设备的数量
    ///Check the number of available collection devices
    if ([_streamingContext captureDeviceCount] == 0) {
    }
    
    ///创建采集预览窗口并连接到摄像头采集次输出
    ///Create a capture preview window and connect it to the camera capture output
    _liveWindowBack = [[NvsLiveWindow alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [self.view addSubview:_liveWindowBack];
    _liveWindow = [[NvsLiveWindow alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [self.view addSubview:_liveWindow];
    _curLiveWindow = _liveWindowBack;
    if (![_streamingContext connectCapturePreviewWithLiveWindow:_curLiveWindow]) {
    }
    _curLiveWindow = _liveWindow;
    if (![_streamingContext connectCapturePreviewWithLiveWindow:_curLiveWindow]) {
    }
    
    self.currentDeviceIndex = [self frontCameraDeviceIndex];
    if (![self startCapturePreview]) {
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    tap.numberOfTapsRequired = 1;
    [_liveWindow addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    tap.numberOfTapsRequired = 1;
    [_liveWindowBack addGestureRecognizer:tap1];
    
    [self addSubViews];
    [self addVirtualBgView];
    [self addVirtualBgDataSource];
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"NvVKeyerViewController"] boolValue]) {
        [self addTipUserOperation];
    }
    if (_currentDeviceIndex == [self frontCameraDeviceIndex]) {
        self.flashBtn.userInteractionEnabled = NO;
        self.flashBtn.alpha = 0.7;
    } else {
        self.flashBtn.userInteractionEnabled = YES;
        self.flashBtn.alpha = 1;
    }
    
    [self installCapturescene];
}

#pragma mark 添加子视图
///Add subview
- (void)addSubViews{
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setImage:NvImageNamed(@"Nvback") forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *btnView = [[UIView alloc]init];
    [self.view addSubview:btnView];
    [btnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NV_STATUSBARHEIGHT);
        make.right.equalTo(self.view).offset(- 13 * SCREENSCALE);
    }];
    
    self.deviceBtn = [NvVirtualGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"flip", @"切换") withImageNormal:@"Nvdevice" withImageSelected:nil];
    [self.deviceBtn addTarget:self action:@selector(deviceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.flashBtn = [NvVirtualGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"flash", @"补光灯") withImageNormal:@"Nvflash_off" withImageSelected:@"Nvflash_on"];
    [self.flashBtn addTarget:self action:@selector(flashBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.virtualBgBtn = [NvVirtualGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Background", @"背景") withImageNormal:@"NvVirtualKeyerBg" withImageSelected:nil];
    [self.virtualBgBtn addTarget:self action:@selector(virtualBgBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.shootingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shootingBtn setImage:NvImageNamed(@"Nvshooting") forState:UIControlStateNormal];
    [self.shootingBtn setImage:NvImageNamed(@"Nvsuspended") forState:UIControlStateSelected];
    [self.shootingBtn addTarget:self action:@selector(shootingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.shootingBtn_1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shootingBtn_1 setImage:NvImageNamed(@"NvVirtualShooting") forState:UIControlStateNormal];
    [self.shootingBtn_1 addTarget:self action:@selector(shootingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.shootingBtn_1.exclusiveTouch = YES;
    
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteBtn setImage:NvImageNamed(@"Nvdelete") forState:UIControlStateNormal];
    [self.deleteBtn addTarget:self action:@selector(deleteBtnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.finishBtn setImage:NvImageNamed(@"Nvfinish") forState:UIControlStateNormal];
    [self.finishBtn addTarget:self action:@selector(finishBtnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.timeLabel = [UILabel new];
    self.timeLabel.text = @"00:00";
    self.timeLabel.textColor = [UIColor nv_colorWithHexRGB:@"#D0021B"];
    self.timeLabel.font = [NvUtils fontWithSize:12 * SCREENSCALE];
    
    self.videoCount = [UILabel new];
    self.videoCount.userInteractionEnabled = NO;
    self.videoCount.font = [NvUtils fontWithSize:12 * SCREENSCALE];
    self.videoCount.textColor = UIColor.whiteColor;
    
    [self.view addSubview:self.backBtn];
    [btnView addSubview:self.deviceBtn];
    [btnView addSubview:self.flashBtn];
    [btnView addSubview:self.virtualBgBtn];
    [self.view addSubview:self.shootingBtn];
    [self.view addSubview:self.deleteBtn];
    [self.view addSubview:self.finishBtn];
    [self.view addSubview:self.timeLabel];
    [self.shootingBtn addSubview:self.shootingBtn_1];
    [self.shootingBtn addSubview:self.videoCount];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NV_STATUSBARHEIGHT);
        make.left.equalTo(self.view).offset(13 * SCREENSCALE);
        make.width.offset(33 * SCREENSCALE);
        make.height.offset(33 * SCREENSCALE);
    }];
    
    [self.deviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnView);
        make.right.left.equalTo(btnView);
    }];
    
    [self.flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.deviceBtn.mas_bottom).offset(24 * SCREENSCALE);
        make.left.right.equalTo(btnView);
    }];
    
    [self.virtualBgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.flashBtn.mas_bottom).offset(24 * SCREENSCALE);
        make.left.right.equalTo(btnView);
        make.bottom.equalTo(btnView);
    }];
    
    [self.shootingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(- 20 * SCREENSCALE);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.offset(64 * SCREENSCALE);
        make.height.offset(64 * SCREENSCALE);
    }];
    
    [self.shootingBtn_1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shootingBtn);
        make.bottom.equalTo(self.shootingBtn);
        make.left.equalTo(self.shootingBtn);
        make.right.equalTo(self.shootingBtn);
    }];
    
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.shootingBtn.mas_left).offset(- 56 * SCREENSCALE);
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
        make.width.offset(48 * SCREENSCALE);
        make.height.offset(33 * SCREENSCALE);
    }];
    
    [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.shootingBtn.mas_right).offset(56 * SCREENSCALE);
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
        make.width.offset(40 * SCREENSCALE);
        make.height.offset(40 * SCREENSCALE);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.videoCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.shootingBtn.mas_centerX);
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
    }];
    
    self.timeLabel.hidden = YES;
    self.deleteBtn.hidden = YES;
    self.finishBtn.hidden = YES;
}

#pragma mark 添加虚拟背景抠像视图
- (void)addVirtualBgView{
    self.virtualBgView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 153*SCREENSCALE + INDICATOR)];
    _virtualBgView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#99000000"];
    [self.view addSubview:_virtualBgView];
    
    self.picBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.picBtn setTitle:NvLocalStringFromTable([self class], @"Background", @"背景") forState:UIControlStateNormal];
    [self.picBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#656565"] forState:UIControlStateNormal];
    self.picBtn.selected = YES;
    [self.picBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#63ABFF"] forState:UIControlStateSelected];
    self.picBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.picBtn addTarget:self action:@selector(picBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.virtualBgView addSubview:self.picBtn];
    [self.picBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.0 * SCREENSCALE);
        make.top.mas_equalTo(10.0 *SCREENSCALE);
        make.width.mas_lessThanOrEqualTo(100 * SCREENSCALE);
        make.height.mas_equalTo(16.0 * SCREENSCALE);
    }];
    self.picLine = [[UIView alloc] init];
    self.picLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#63ABFF"];
    [self.virtualBgView addSubview:self.picLine];
    [self.picLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.picBtn.mas_bottom).offset(5.0 * SCREENSCALE);
        make.centerX.mas_equalTo(self.picBtn.mas_centerX);
        make.width.mas_equalTo(20.0 * SCREENSCALE);
        make.height.mas_equalTo(1.0 * SCREENSCALE);
    }];
    
    self.videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.videoBtn setTitle:NvLocalStringFromTable([self class], @"Scene", @"场景") forState:UIControlStateNormal];
    [self.videoBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#656565"] forState:UIControlStateNormal];
    [self.videoBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#63ABFF"] forState:UIControlStateSelected];
    self.videoBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.videoBtn addTarget:self action:@selector(videoBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.virtualBgView addSubview:self.videoBtn];
    self.videoBtn.selected = NO;
    [self.videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.picBtn.mas_right).offset(15.0 * SCREENSCALE);
        make.top.mas_equalTo(10.0 *SCREENSCALE);
        make.width.mas_lessThanOrEqualTo(100 * SCREENSCALE);
        make.height.mas_equalTo(16.0 * SCREENSCALE);
    }];
    self.videoLine = [[UIView alloc] init];
    self.videoLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#63ABFF"];
    self.videoLine.hidden = YES;
    [self.virtualBgView addSubview:self.videoLine];
    [self.videoLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.videoBtn.mas_bottom).offset(5.0 * SCREENSCALE);
        make.centerX.mas_equalTo(self.videoBtn.mas_centerX);
        make.width.mas_equalTo(20.0 * SCREENSCALE);
        make.height.mas_equalTo(1.0 * SCREENSCALE);
    }];

    
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    [self.virtualBgView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.picLine.mas_bottom);
        make.width.equalTo(self.virtualBgView.mas_width);
        make.height.offset(0.5);
        make.left.mas_equalTo(self.virtualBgView.mas_left);
    }];
    
    UICollectionViewFlowLayout *picLayout = [[UICollectionViewFlowLayout alloc] init];
    picLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    picLayout.itemSize = CGSizeMake(61 * SCREENSCALE, 55*SCREENSCALE);
    picLayout.minimumLineSpacing = 0;
    picLayout.minimumInteritemSpacing = 0;
    self.virtualPictureCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:picLayout];
    _virtualPictureCollectionView.backgroundColor = UIColor.clearColor;
    _virtualPictureCollectionView.delegate = self;
    _virtualPictureCollectionView.dataSource = self;
    _virtualPictureCollectionView.showsHorizontalScrollIndicator = NO;
    [_virtualBgView addSubview:_virtualPictureCollectionView];
    [_virtualPictureCollectionView registerClass:[NvVirtualKeyerCell class] forCellWithReuseIdentifier:@"NvVirtualKeyerCell"];
    [_virtualPictureCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.picLine.mas_bottom).offset(13 * SCREENSCALE);
        make.left.equalTo(self.virtualBgView);
        make.right.equalTo(self.virtualBgView);
        make.height.offset(55 * SCREENSCALE);
    }];
    
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(61 * SCREENSCALE, 55*SCREENSCALE);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    self.virtualBgCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _virtualBgCollectionView.backgroundColor = UIColor.clearColor;
    _virtualBgCollectionView.delegate = self;
    _virtualBgCollectionView.dataSource = self;
    _virtualBgCollectionView.showsHorizontalScrollIndicator = NO;
    [_virtualBgView addSubview:_virtualBgCollectionView];
    [_virtualBgCollectionView registerClass:[NvVirtualKeyerCell class] forCellWithReuseIdentifier:@"NvVirtualKeyerCell"];
    [_virtualBgCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.picLine.mas_bottom).offset(13 * SCREENSCALE);
        make.left.equalTo(self.virtualBgView);
        make.right.equalTo(self.virtualBgView);
        make.height.offset(55 * SCREENSCALE);
    }];
    _virtualBgCollectionView.hidden = YES;
    

    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetBtn setTitle:NvLocalString(@"Reset", @"重置") forState:UIControlStateNormal];
    [resetBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [resetBtn addTarget:self action:@selector(resetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    resetBtn.titleLabel.font = [NvUtils fontWithSize:11];
    [resetBtn setImage:NvImageNamed(@"NvVirtualReset") forState:UIControlStateNormal];
    resetBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -15 * SCREENSCALE, 0, 0);
    [_virtualBgView addSubview:resetBtn];
    [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.virtualBgView.mas_right).offset(-13 * SCREENSCALE);
        make.bottom.equalTo(self.virtualBgView.mas_bottom).offset(-20 * SCREENSCALE);
    }];
    
    UILabel *tipLabel = [[UILabel alloc]init];
    tipLabel.alpha = 0.8;
    tipLabel.text = NvLocalString(@"VirtualTip", @"点选要去除的画面颜色，再选择一个场景进行录制");
    tipLabel.font = [NvUtils regularFontWithSize:12];
    tipLabel.numberOfLines = 2;
    tipLabel.textColor = UIColor.whiteColor;
    [_virtualBgView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.picBtn.mas_left);
        make.right.equalTo(resetBtn.mas_left).offset(-30.0f * SCREENSCALE);
        make.centerY.equalTo(resetBtn.mas_centerY);
    }];
}

-(void)picBtnClick{
    self.picBtn.selected = YES;
    self.videoBtn.selected = NO;
    self.picLine.hidden = NO;
    self.videoLine.hidden = YES;
    
    self.virtualPictureCollectionView.hidden = NO;
    self.virtualBgCollectionView.hidden = YES;
    [self.virtualPictureCollectionView reloadData];
}

-(void)videoBtnClick{
    self.videoBtn.selected = YES;
    self.videoLine.hidden = NO;
    self.picBtn.selected = NO;
    self.picLine.hidden = YES;
    
    self.virtualPictureCollectionView.hidden = YES;
    self.virtualBgCollectionView.hidden = NO;
    [self.virtualBgCollectionView reloadData];
}

#pragma mark 给virtualBgDataSource添加数据
///Add data to the virtualBgDataSource
- (void)addVirtualBgDataSource{
    [self getVirtualKeyerNetWork];
}

#pragma mark 调用网络接口获取网络粒子数据
///Call the network interface to get network particle data
- (void)getVirtualKeyerNetWork{
    
    [self.assetManager downloadRemoteAssetsInfoForCapture:ASSET_CAPTURE_SCENE categoryId:NV_CATEGORY_ID_ALL page:1 pageSize:20 kind:NV_KIND_ID_ALL ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NvSDKUtils getSdkVersion]];
    
}

#pragma mark - NvAssetManagerDelegate
- (void)onRemoteAssetsChanged:(BOOL)hasNext {
    NSArray *array = [self.assetManager getRemoteAssets:ASSET_CAPTURE_SCENE aspectRatio:AspectRatio_All categoryId:0 kindId:NV_KIND_ID_ALL];
    for (NvAsset *asset in array) {
        NvVirtualKeyerModel *model = [NvVirtualKeyerModel new];
        model.packageId = asset.uuid;
        model.categoryId = asset.category;
        model.displayName = asset.displayName;
        model.coverName = asset.coverUrl;
        if ([self isVirtualKeyerExist:asset.uuid]){
            model.state = Finish;
        }else{
            model.state = NODownload;
        }
        if (asset.category == 1) {//视频
            [self.virtualBgDataSource addObject:model];
        }
    }
    [self.virtualPictureCollectionView reloadData];
    [self.virtualBgCollectionView reloadData];
}

- (BOOL)isVirtualKeyerExist:(NSString *)uuid {
    for (NvAsset *model in [self.assetManager getUsableAssets:ASSET_CAPTURE_SCENE aspectRatio:AspectRatio_All categoryId:0 kindId:NV_KIND_ID_ALL]) {
        if ([model.uuid isEqualToString:uuid])
            return YES;
    }
    return NO;
}

- (void)onGetRemoteAssetsFailed{
    NSArray *temporaryArray = [self.assetManager getUsableAssets:ASSET_CAPTURE_SCENE aspectRatio:AspectRatio_All categoryId:0 kindId:NV_KIND_ID_ALL];
    
    for (NvAsset *asset in temporaryArray) {
        NvVirtualKeyerModel *model = [NvVirtualKeyerModel new];
        model.packageId = asset.uuid;
        model.categoryId = asset.category;
        model.displayName = asset.displayName;
        model.coverName = asset.coverUrl;
        if ([asset isUsable]) {
            model.state = Finish;
        }else{
            model.state = NODownload;
        }
        
        if (asset.category == 1) {
            [self.virtualBgDataSource addObject:model];
        }
    }
    
    [self.virtualBgCollectionView reloadData];
    [self.virtualPictureCollectionView reloadData];
}
- (NSMutableArray *)getDataSourceWithuuid:(NSString *)uuid{
    __block BOOL find = NO;
    [self.virtualPictureDataSource enumerateObjectsUsingBlock:^(NvVirtualKeyerModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.packageId isEqualToString:uuid]) {
            find = YES;
            *stop = YES;
        }
    }];
    return find?self.virtualPictureDataSource:self.virtualBgDataSource;
}

- (void)onDownloadAssetProgress:(NSString *)uuid progress:(int)progress{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray * tmp = [self getDataSourceWithuuid:uuid];
        for (int i = 0; i < tmp.count; i++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            NvVirtualKeyerModel *model = tmp[i];

            NvVirtualKeyerCell *cell ;
            if (model.categoryId == 2) {
                cell = (NvVirtualKeyerCell *)[self.virtualPictureCollectionView cellForItemAtIndexPath:indexPath];
            }else{
                cell =  (NvVirtualKeyerCell *)[self.virtualBgCollectionView cellForItemAtIndexPath:indexPath];
            }
            if ([model.packageId isEqualToString:uuid]) {
                cell.downloadButton.progress = progress/100.f;
            }
        }
        [UIView performWithoutAnimation:^{
            [self.virtualBgCollectionView reloadData];
            [self.virtualPictureCollectionView reloadData];
        }];
    });
}

- (void)onDonwloadAssetSuccess:(NSString *)uuid{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray * tmp = [self getDataSourceWithuuid:uuid];
        for (int i = 0; i < tmp.count; i++) {
            NvVirtualKeyerModel *model = tmp[i];
            if ([model.packageId isEqualToString:uuid]) {
                model.state = Finish;
                if ([self.currentModel isEqual:model]) {
                    model.selected = YES;
                    [self applyCaptureScene:model.packageId];
                }
                
                [UIView performWithoutAnimation:^{
                    [self.virtualBgCollectionView reloadData];
                }];
            }
        }
    });
}

- (void)onDonwloadAssetFailed:(NSString *)uuid{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray * tmp = [self getDataSourceWithuuid:uuid];
        for (int i = 0; i < tmp.count; i++) {
            NvVirtualKeyerModel *model = tmp[i];
            if ([model.packageId isEqualToString:uuid]) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                NSMutableArray *array = NSMutableArray.new;
                [array addObject:indexPath];
                model.state = NODownload;
                [UIView performWithoutAnimation:^{
                    [self.virtualBgCollectionView reloadData];
                    [self.virtualPictureCollectionView reloadData];
                }];
            }
        }
    });
}

#pragma mark 提示——用户虚拟背景抠像的引导视图
///Tip - A bootstrap view of the user's virtual background
- (void)addTipUserOperation{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NvLocalString(@"Tips" , @"提示") message:NvLocalString(@"VirtualSuggest", @"建议拍摄背景为单一颜色") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *skipAction = [UIAlertAction actionWithTitle:NvLocalString(@"Know", @"知道了") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NvVKeyerViewController"];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NvLocalString(@"Don't Tip", @"不再提醒") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NvVKeyerViewController"];
    }];

    [alertVC addAction:skipAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - 重置按钮点击事件
///Reset button click event
- (void)resetBtnClick:(UIButton *)sender{
    [self.streamingContext removeCurrentCaptureScene];
    [self.streamingContext removeAllCaptureVideoFx];
    self.keyerFx = [_streamingContext appendBuiltinCaptureVideoFx:@"Master Keyer"];
    if (_keyerFx) {
        ///开启溢色去除
        ///Turn on overflow color removal
        [_keyerFx setBooleanVal:@"Spill Removal" val:YES];
        ///将溢色去除强度设置为最低
        ///Set the overflow removal intensity to the lowest level
        [_keyerFx setFloatVal:@"Spill Removal Intensity" val:0];
        ///设置收缩边界强度
        ///Set the strength of the contraction boundary
        [_keyerFx setFloatVal:@"Shrink Intensity" val:0.4];
        ///抠像方式
        ///Image picking mode
        ///Master Mode、RGB Mode、Hsv Mode
        [_keyerFx setMenuVal:@"Keyer Mode" val:@"Master Mode"];
    }
    
    for (NvVirtualKeyerModel *model in self.virtualPictureDataSource) {
        model.selected = NO;
    }
    for (NvVirtualKeyerModel *model in self.virtualBgDataSource) {
        model.selected = NO;
    }
    self.currentModel = nil;
    [self.virtualPictureCollectionView reloadData];
    [self.virtualBgCollectionView reloadData];
}

#pragma mark 相册权限提示
///Photo album permission prompt
- (void)popUpTip{
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NvLocalString(@"Save Succecs!", @"保存失败") message:NvLocalString(@"Album permissions", @"您还没有允许相册访问权限") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *skipAction = [UIAlertAction actionWithTitle:NvLocalString(@"Know", @"知道了") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertVC addAction:skipAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark 切换摄像头
///Switch camera
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
    
    [UIView transitionFromView:fromView toView:toView duration:0.3 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
        [self.view sendSubviewToBack:self.curLiveWindow];
    }];
    [self startCapturePreview];
}

#pragma mark 闪光灯开关
///Flash switch
- (void)flashBtnClick:(UIButton *)sender{
    if ([_streamingContext getCaptureDeviceCapability:_currentDeviceIndex].supportFlash) {
        [_streamingContext toggleFlash:![_streamingContext isFlashOn]];
        _flashBtn.selected = sender.selected ? NO : YES;
    }
}

#pragma mark 关闭退出
///Close exit
- (void)backBtnClick:(UIButton *)sender{
    [_streamingContext removeCurrentCaptureScene];
    [_streamingContext removeAllCaptureVideoFx];
    [_streamingContext stop];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 背景按钮点击事件
///Background button click event
- (void)virtualBgBtnClick:(UIButton *)sender{
    self.clickState = YES;
    [self faceHiddenBtn:YES];
    [UIView animateWithDuration:0.1 animations:^{
         self.virtualBgView.frame = CGRectMake(0, SCREENHEIGHT - self.virtualBgView.frame.size.height, SCREENWIDTH, self.virtualBgView.frame.size.height);
    }];
}

#pragma mark 拍摄按钮点击
///Shoot button click
- (void)shootingBtnClick:(UIButton *)sender{
    if ([sender isEqual:self.shootingBtn_1]) {
        self.shootingBtn_1.hidden = YES;
        self.shootingBtn.selected = YES;
        self.timeLabel.textColor = UIColor.redColor;
        self.videoCount.hidden = YES;
        [self faceHiddenBtn:YES];
        self.shootingBtn.hidden = NO;
        self.timeLabel.hidden = NO;
        self.shootingBtn.enabled = NO;
        [self startRecording];
    }else{
        if (sender.selected) {
            sender.selected = NO;
            [self faceHiddenBtn:NO];
            [self stopRecording];
            self.videoCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)_videoPathArray.count];
            self.timeLabel.textColor = UIColor.whiteColor;
            self.videoCount.hidden = NO;
            self.duration = self.duration + self.lastDuration;
            [self.durationArray addObject:[NSNumber numberWithLongLong:self.lastDuration]];
        }else{
            self.timeLabel.textColor = UIColor.redColor;
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

#pragma mark 开始录制
///Start recording
- (void)startRecording{
    NSString *path = [VIDEO_PATH(@"Virtual") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
    
    [_streamingContext startRecordingWithFx:path withFlags:0 withRecordConfigurations:config];
    [self.videoPathArray addObject:path];
}

#pragma mark 关闭录制
///Close recording
- (void)stopRecording{
    [_streamingContext stopRecording];
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied)
    {
        [self popUpTip];
        return;
    }

    UISaveVideoAtPathToSavedPhotosAlbum(self.videoPathArray.lastObject, self, nil, nil);
}

#pragma mark 删除按钮点击
///Delete button click
- (void)deleteBtnBtnClick:(UIButton *)sender{
    NSString *filePath = (NSString *)[_videoPathArray lastObject];
    [_videoPathArray removeLastObject];
    NSError *error;
    if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]){
    }
    if (_videoPathArray.count == 0) {
        self.videoCount.text = @"";
        self.timeLabel.text = @"00:00";
        self.timeLabel.hidden = YES;
        self.deleteBtn.hidden = YES;
        self.finishBtn.hidden = YES;
        self.duration = 0;
        self.shootingBtn_1.hidden = NO;
    }else{
        self.videoCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)_videoPathArray.count];
        int64_t subResult = self.duration - [[_durationArray lastObject] longLongValue];
        self.duration = fmax(subResult, 0) ;
        self.timeLabel.text = [NvUtils convertTimecode:self.duration];
    }
}

#pragma mark 完成按钮点击
///Finish button click
- (void)finishBtnBtnClick:(UIButton *)sender{
    if (_currentDeviceIndex != [self frontCameraDeviceIndex]) {
        _flashBtn.alpha = 1;
        _flashBtn.userInteractionEnabled = YES;
        _flashBtn.selected = NO;
    }
    
    AVURLAsset*audioAsset=[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.videoPathArray.firstObject] options:nil];
    AVAssetTrack *track = [[audioAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize dimensions = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
    if (dimensions.width > dimensions.height) {
        // NvEditMode16v9;
        [self addPreviewView:NvEditMode16v9 withPathArray:self.videoPathArray];
    }else{
        // NvEditMode9v16;
        [self addPreviewView:NvEditMode9v16 withPathArray:self.videoPathArray];
    }
}

#pragma mark 应用场景
///Application scenario
- (void)applyCaptureScene:(NSString *)uuid {
    [self.streamingContext removeCurrentCaptureScene];
    [self.streamingContext applyCaptureScene:uuid];
}

#pragma mark 应用背景
///Application background
- (void)applyBackgroundEffect:(NSString *)path sceneWidth:(int)sceneWidth sceneHeight:(int)sceneHeight {
    [self.streamingContext removeCurrentCaptureScene];
    
    for (NvVirtualKeyerModel *model in self.virtualBgDataSource) {
        model.selected = NO;
    }
    
    if (self.capturescenePackageIdDefault && self.capturescenePackageIdDefault.length > 0) {
        NvsCaptureSceneInfo *sceneInfo = [NvsCaptureSceneInfo new];
        sceneInfo.backgroundClipArray = [NSMutableArray array];
        
        NvsClipData *clipData = [NvsClipData new];
        clipData.mediaPath = path;
        NvsAVFileInfo *info = [self.streamingContext getAVFileInfo:path];
        if (info.avFileType == NvsAVFileType_AudioVideo) {
            clipData.scan = 1;
        }else{
            clipData.imageFillMode = @"crop";
        }
        [sceneInfo.backgroundClipArray addObject:clipData];
        
        [self.streamingContext applyCaptureScene:self.capturescenePackageIdDefault captureSceneInfo:sceneInfo];
    }
}

#pragma mark 将拍摄的视频保存到本地相册
///Save the video you shot to your local album
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {

}

#pragma mark 预览视图
///Preview view
- (void)addPreviewView:(NvEditMode)editMode withPathArray:(NSMutableArray *)path{
    self.preView = [[NvPreViewLiveWindow alloc]initWithFrame:self.view.frame];
    self.preView.delegate = self;
    self.preView.pathArray = path;
    self.preView.model = editMode;
    [self.view addSubview:self.preView];
}

#pragma mark NvPreViewLiveWindowDelegate
///退出关闭预览视图
///Exit the Close preview view
- (void)backClick{
    [self.preView removeFromSuperview];
    self.preView = nil;
    [self.streamingContext connectCapturePreviewWithLiveWindow:self.curLiveWindow];
    self.streamingContext.delegate = self;
    [self startCapturePreview];
}

///生成按钮点击事件
///Generate button click events
- (void)compileClick:(NvsTimeline *)timeline{
    self.compileFilePath = [VIDEO_PATH(@"Virtual") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NvCompileViewController *compileViewController = [NvCompileViewController new];
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compileTimeline:timeline outputPath:self.compileFilePath];
}

#pragma mark - NvCompileViewControllerDelegate
- (void)compileFinished:(BOOL)needDelete {
    [self.preView againConnection];
    if (needDelete) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            [[NSFileManager defaultManager] removeItemAtPath:self.compileFilePath error:nil];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            UISaveVideoAtPathToSavedPhotosAlbum(self.compileFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        });
    }
}
 
#pragma mark 获取前置摄像头设备索引
///Gets the front camera device index
- (unsigned int)frontCameraDeviceIndex {
    for (unsigned int i = 0; i < _streamingContext.captureDeviceCount; i++) {
        if (![_streamingContext isCaptureDeviceBackFacing:i])
            return i;
    }
    
    return _streamingContext.captureDeviceCount - 1;
}

#pragma mark 启动摄像头采集预览
///Start the camera capture preview
- (BOOL)startCapturePreview {
    NSNumber *num = NV_UserInfo(@"NvRecordResolution");
    NvsVideoCaptureResolutionGrade captureResGrade;
    if (num == 2160) {
        captureResGrade = NvsVideoCaptureResolutionGradeExtremelyHigh;
    }else if (num == 1080){
        captureResGrade = NvsVideoCaptureResolutionGradeHigh;
    }else {
        captureResGrade = NvsVideoCaptureResolutionGradeMedium;
    }
    return [_streamingContext startCapturePreview:_currentDeviceIndex videoResGrade:captureResGrade flags: NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame |NvsStreamingEngineCaptureFlag_GrabCapturedVideoFrame | NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize | NvsStreamingEngineCaptureFlag_LowPipelineSize aspectRatio:nil];
}


#pragma mark NvsStreamingContextDelegate
- (void)didCaptureRecordingDurationUpdated:(int)captureDeviceIndex duration:(int64_t)duration{
    if (self.shootingBtn.isSelected) {
        self.lastDuration = duration;
        self.timeLabel.text = [NvUtils convertTimecode:self.duration + duration];
    }
    if (duration >= NV_TIME_BASE) {
        self.shootingBtn.enabled = YES;
    }
}

- (void)didCaptureDeviceCapsReady:(unsigned int)captureDeviceIndex{
    NvsCaptureDeviceCapability *capability = [_streamingContext getCaptureDeviceCapability:captureDeviceIndex];
    if (!capability){
        return;
    }
    NvsSize previewSize = [_streamingContext getCapturePreviewVideoSize:captureDeviceIndex];
    self.gradeSize = CGSizeMake(previewSize.width, previewSize.height);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isEqual:self.virtualBgCollectionView]) {
        return self.virtualBgDataSource.count;
    }else{
        return self.virtualPictureDataSource.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvVirtualKeyerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvVirtualKeyerCell" forIndexPath:indexPath];
    if ([collectionView isEqual:self.virtualBgCollectionView]) {
        [cell renderCellWithModel:self.virtualBgDataSource[indexPath.item]];
    }else{
        [cell renderCellWithModel:self.virtualPictureDataSource[indexPath.item]];
    }
    return cell;
   
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NvVirtualKeyerModel *model ;
    if ([collectionView isEqual:self.virtualBgCollectionView]) {
        model = self.virtualBgDataSource[indexPath.item];
    }else{
        model = self.virtualPictureDataSource[indexPath.item];
    }
    if (model.state == NvDownloading || model.state == NoUser || model.state == Update || model.state == DownloadError) {
        return;
    }
    
    if ([collectionView isEqual:self.virtualPictureCollectionView]) {
        if (indexPath.item == 0) {
            NvAlbumViewController *vc = [NvAlbumViewController new];
            vc.delegate = self;
            vc.mutableSelect = YES;
            vc.minSelectCount = 1;
            vc.maxSelectCount = 1;
            vc.hiddenSelectAll = YES;
            vc.alwaysShowCustomBottom = NO;
            [self.navigationController pushViewController:vc animated:YES];
        }else {
            for (NvVirtualKeyerModel *localModel in self.virtualPictureDataSource) {
                localModel.selected = NO;
            }
            NvVirtualKeyerModel *localModel = self.virtualPictureDataSource[indexPath.item];
            localModel.selected = YES;
            self.currentModel = localModel;
            if (localModel.coverName && localModel.coverName.length > 0) {
                [self applyBackgroundEffect:localModel.coverName sceneWidth:self.gradeSize.width sceneHeight:self.gradeSize.height];
            }else if (localModel.packagePath && localModel.packagePath.length > 0){
                [self applyBackgroundEffect:localModel.packagePath sceneWidth:self.gradeSize.width sceneHeight:self.gradeSize.height];
            }
            
            [collectionView reloadData];
        }
        return;
    }
    
    for (NvVirtualKeyerModel *model in self.virtualBgDataSource) {
        model.selected = NO;
    }
    for (NvVirtualKeyerModel *model in self.virtualPictureDataSource) {
        model.selected = NO;
    }
    self.currentModel = model;
    
    if (model.state == NvNoDownload) {
        model.state = Downloading;
        [self.assetManager downloadAsset:model.packageId];
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }else if(model.state == Finish){
        model.selected = YES;
        [self applyCaptureScene:model.packageId];
        [collectionView reloadData];
    }
}

#pragma mark 相册回调
///Album callback
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    NSString *masterKeyerPath = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_COPY_PATH_MASTERKEYER_BACKGROUND_IMAGE];
    
    if (assets.count == 1) {
        NvAlbumAsset *asset = assets[0];
        if (asset.isLivePhoto) {
            if (!self->_group) {
                self->_group = dispatch_group_create();
            }
            for (NvVirtualKeyerModel *styleModel in self.virtualPictureDataSource) {
                styleModel.selected = NO;
            }
            NvVirtualKeyerModel *model = [NvVirtualKeyerModel new];
            model.packageId = @"";
            model.categoryId = @"";
            model.displayName = @"";
            model.coverName = @"";
            model.packagePath = asset.albumVideoPath;
            model.pictureObject = [self thumbnailImageForVideo:[NSURL fileURLWithPath:asset.albumVideoPath] atTime:0];
            model.state = Finish;
            model.selected = YES;
            [self.virtualPictureDataSource insertObject:model atIndex:1];
        } else {
            [self copyImageMaterialWithLocalIdentifier:asset.asset.localIdentifier destinationPath:masterKeyerPath];
        }
    }
    __weak typeof(self)weakSelf = self;
    dispatch_group_notify(self->_group, dispatch_get_main_queue(), ^{
        [weakSelf.virtualPictureCollectionView reloadData];
        for (NvVirtualKeyerModel *styleModel in weakSelf.virtualPictureDataSource) {
            if (styleModel.selected) {
                if (styleModel.coverName && styleModel.coverName.length > 0) {
                    [weakSelf applyBackgroundEffect:styleModel.coverName sceneWidth:self.gradeSize.width sceneHeight:self.gradeSize.height];
                }else if (styleModel.packagePath && styleModel.packagePath.length > 0){
                    [weakSelf applyBackgroundEffect:styleModel.packagePath sceneWidth:self.gradeSize.width sceneHeight:self.gradeSize.height];
                }
                
                weakSelf.currentModel = styleModel;
                break;
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    });
    
}

///拷贝图片到指定目录
///Copy the image to the specified directory
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
        if (targetAsset.mediaType == PHAssetMediaTypeImage) {
            [[PHImageManager defaultManager] requestImageDataForAsset:targetAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                NSString *imagePath =[[destinationPath stringByAppendingPathComponent:[localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"_"]] stringByAppendingPathExtension:@"png"];
                BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
                if (isExist) {
                    for (NvVirtualKeyerModel *styleModel in weakSelf.virtualPictureDataSource) {
                        if ([styleModel.coverName isEqualToString:imagePath]) {
                           styleModel.selected = YES;
                        }else{
                           styleModel.selected = NO;
                        }

                    }
                }else{
                    BOOL result = [imageData writeToFile:imagePath atomically:YES];
                    if (result) {
                        for (NvVirtualKeyerModel *styleModel in weakSelf.virtualPictureDataSource) {
                            styleModel.selected = NO;
                        }
                        NvVirtualKeyerModel *model = [NvVirtualKeyerModel new];
                        model.packageId = @"";
                        model.categoryId = @"";
                        model.displayName = @"";
                        model.coverName = imagePath;
                        model.state = Finish;
                        model.selected = YES;
                        [weakSelf.virtualPictureDataSource insertObject:model atIndex:1];
                    }else{
                        NSLog(@"保存图片失败 Failed to save picture%@",localIdentifier);
                    }
                }

                dispatch_group_leave(strongSelf->_group);
            }];
        }else if (targetAsset.mediaType == PHAssetMediaTypeVideo){
            PHVideoRequestOptions *requestOptions = [[PHVideoRequestOptions alloc] init];
            requestOptions.version = PHVideoRequestOptionsVersionOriginal;
            requestOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
            requestOptions.networkAccessAllowed = YES;
            
            [[PHImageManager defaultManager] requestAVAssetForVideo:targetAsset options:requestOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                AVURLAsset *videoAsset = (AVURLAsset *)asset;
                if (videoAsset.URL.absoluteString.length > 0) {
                    for (NvVirtualKeyerModel *styleModel in weakSelf.virtualPictureDataSource) {
                        styleModel.selected = NO;
                    }
                    NvVirtualKeyerModel *model = [NvVirtualKeyerModel new];
                    model.packageId = @"";
                    model.categoryId = @"";
                    model.displayName = @"";
                    model.coverName = @"";
                    model.packagePath = videoAsset.URL.absoluteString;
                    model.pictureObject = [self thumbnailImageForVideo:videoAsset.URL atTime:0];
                    model.state = Finish;
                    model.selected = YES;
                    [weakSelf.virtualPictureDataSource insertObject:model atIndex:1];
                }
                dispatch_group_leave(strongSelf->_group);
            }];
        }
    }
}
#pragma mark 点击隐藏界面按钮
///Click the Hide Interface button
- (void)faceHiddenBtn:(BOOL)hidden{
    self.deviceBtn.hidden = hidden;
    self.flashBtn.hidden = hidden;
    self.backBtn.hidden = hidden;
    self.virtualBgBtn.hidden = hidden;
    self.shootingBtn.hidden = hidden;
    self.timeLabel.hidden = hidden;
    self.deleteBtn.hidden = hidden;
    self.finishBtn.hidden = hidden;
}

#pragma mark 点击空白显示界面按钮
///Click the blank display button
- (void)singleTap:(UITapGestureRecognizer *)recognizer {
    if (self.clickState) {
        self.clickState = NO;
        [self faceHiddenBtn:NO];
        [UIView animateWithDuration:0.1 animations:^{
            self.virtualBgView.frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, self.virtualBgView.frame.size.height);
        }];
        if (_videoPathArray.count == 0) {
            self.timeLabel.hidden = YES;
            self.deleteBtn.hidden = YES;
            self.finishBtn.hidden = YES;
        }else{
            self.timeLabel.hidden = NO;
            self.deleteBtn.hidden = NO;
            self.finishBtn.hidden = NO;
        }
    }else{
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            if (self.streamingContext.getStreamingEngineState == NvsStreamingEngineState_CapturePreview) {
                const CGPoint pos = [recognizer locationInView:self.curLiveWindow];
                static const int sampleWidth = 20, sampleHeight = 20;
                CGRect sampleRect;
                
                sampleRect.origin.x = pos.x - sampleWidth / 2;
                if (sampleRect.origin.x < 0)
                    sampleRect.origin.x = 0;
                else if (sampleRect.origin.x + sampleWidth > self.curLiveWindow.bounds.size.width)
                    sampleRect.origin.x = self.curLiveWindow.bounds.size.width - sampleWidth;
                
                sampleRect.origin.y = pos.y - sampleHeight / 2;
                if (sampleRect.origin.y < 0)
                    sampleRect.origin.y = 0;
                else if (sampleRect.origin.y + sampleHeight > self.curLiveWindow.bounds.size.height)
                    sampleRect.origin.y = self.curLiveWindow.bounds.size.height - sampleHeight;
                
                sampleRect.size.width = sampleWidth;
                sampleRect.size.height = sampleHeight;
                
                NvsColor sampledColor = [_streamingContext sampleColorFromCapturedVideoFrame:sampleRect];
                
                ///将吸取下来的背景画面颜色值设置给抠像特技
                ///Set the background color value to the image picking effect
                if (self.keyerFx){
                    [self.keyerFx setColorVal:@"Key Color" val:&sampledColor];
                }
            }
        }
    }
}

- (void)presentPermissions {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NvLocalString(@"Tips" , @"提示") message:NvLocalString(@"camera.microphone.permissions", @"需要打开摄像头和麦克风权限 请在手机设置中进行允许") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *skipAction = [UIAlertAction actionWithTitle:NvLocalString(@"Know", @"知道了") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertVC addAction:skipAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark 注册应用前台后台通知事件
///Register application foreground background notification events
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification*)notification {
    if ([_streamingContext getStreamingEngineState] == NvsStreamingEngineState_CaptureRecording) {
        self.shootingBtn.selected = NO;
        [self faceHiddenBtn:NO];
        [self stopRecording];
        self.videoCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)_videoPathArray.count];
        self.timeLabel.textColor = UIColor.whiteColor;
        self.videoCount.hidden = NO;
        self.duration = self.duration + self.lastDuration;
        [self.durationArray addObject:[NSNumber numberWithLongLong:self.lastDuration]];
    }
    if (_currentDeviceIndex != [self frontCameraDeviceIndex]) {
        _flashBtn.alpha = 1;
        _flashBtn.userInteractionEnabled = YES;
        _flashBtn.selected = NO;
    }
    [self.streamingContext stop];
}

- (void)applicationDidBecomeActive:(NSNotification*)notification {
    self.shootingBtn.enabled = YES;
    if ([_streamingContext getStreamingEngineState] == NvsStreamingEngineState_Stopped) {
        [self startCapturePreview];
    }
}

#pragma mark 防止锁屏
///Anti-lock screen
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)installCapturescene{
    self.capturescenePackageIdDefault = [NSMutableString string];
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *string = [bundlePath stringByAppendingPathComponent:@"capturescene.bundle"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *contents = [fm contentsOfDirectoryAtPath:string error:nil];
    string = [string stringByAppendingPathComponent:contents.firstObject];
    NSString * licensePath = [NSString convertFilePathToNewPath:string WithExtension:@"lic"];
    [self.streamingContext.assetPackageManager installAssetPackage:string license:licensePath type:NvsAssetPackageType_CaptureScene sync:YES assetPackageId:self.capturescenePackageIdDefault];
}

-(UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
 
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

@end
