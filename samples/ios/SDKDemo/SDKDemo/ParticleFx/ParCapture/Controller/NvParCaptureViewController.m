//
//  NvParCaptureViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/9/19.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvParCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/PHPhotoLibrary.h>
#import "NvLabelCell.h"
#import "NvLabelModel.h"
#import <NvSDKCommon/NvAssetManager.h>
#import <NvStreamingSdkCore/NvsAssetPackageManager.h>
#import <NvStreamingSdkCore/NvsCaptureVideoFx.h>
#import <NvStreamingSdkCore/NvsAssetPackageParticleDescParser.h>
#import "NvAlbumViewController.h"
#import "NvPreViewLiveWindow.h"
#import <NvSDKCommon/NvCompileViewController.h>
#import "NvParEditViewController.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvGraphicBtn.h"
#import <NvSDKCommon/NvHttpRequest.h>
#import "NvParticleModel.h"
#import "NvParticleAssetCell.h"
#import <NvSDKCommon/NvInitArScence.h>

@interface NvParCaptureViewController ()
<NvsStreamingContextDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
NvAlbumViewControllerDelegate,
NvPreViewLiveWindowDelegate,
NvCompileViewControllerDelegate,
NvAssetManagerDelegate>

///界面按钮
///Interface button
///关闭
///Shut down
@property (nonatomic, strong) UIButton *backBtn;
///切换摄像头
///Switch camera
@property (nonatomic, strong) NvGraphicBtn *deviceBtn;
@property (nonatomic, strong) NvGraphicBtn *flashBtn;
///粒子特效
///Particle effect
@property (nonatomic, strong) NvGraphicBtn *particleBtn;
///涂鸦特效
///Doodle special effect
@property (nonatomic, strong) NvGraphicBtn *graffitiBtn;
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

///粒子视图
///Particle view
@property (nonatomic, strong) UIView *particlePanelView;
@property (nonatomic, strong) UICollectionView *collectionView;
///demo自带的粒子包数组，用于在网络获取后比较，不用把网络上已有的重复添加进去
///demo comes with particle packet array, used to obtain the network after comparison, do not need to add the network existing repeat
@property (nonatomic, strong) NSMutableArray <NvParticleModel *>*dataSourceArray;
///当前粒子的方向数组
///An array of directions for the current particle
@property (nonatomic, strong) NSMutableArray *currentAngleArray;

///手动对焦视图
///Manually focus the view
@property (nonatomic, strong) UIImageView *focusView;
///预览视图
///Preview view
@property (nonatomic, strong) NvPreViewLiveWindow *preView;
///粒子特效提示视图
///Particle effects prompt view
@property (nonatomic, strong) UIView *tipBoxView;
///计时器
///timer
@property (nonatomic, strong) NSTimer *timer;

//-----------------逻辑相关 Logical correlation----------------//
///当前设备摄像头索引
///Current device camera index
@property (nonatomic, assign) int currentDeviceIndex;
///视频路径数组
///Video path array
@property (nonatomic, strong) NSMutableArray *videoPathArray;
///断点拍摄每段视频的时长数组
///Breakpoint takes an array of the duration of each video
@property (nonatomic, strong) NSMutableArray *durationArray;
///总拍摄时长
///Total duration
@property (nonatomic, assign) int64_t duration;
///断点拍摄每次停止录制的时长，duration和durationArray需要用到
///Breakpoints capture the duration of each stop. Duration and durationArray are used
@property (nonatomic, assign) int64_t lastDuration;
///底部弹窗视图出现和消失
///Bottom popover view appears and disappears
@property (nonatomic, assign) BOOL clickState;
///当前操作的特效对象
///The effect object of the current operation
@property (nonatomic, strong) NvParticleModel *currentItem;
///生成路径
///Generating path
@property (nonatomic, strong) NSString *compileFilePath;
///当前操作的标签对象
///Generates the label object for the current operation of the path
@property (nonatomic, strong) NSArray *configJsonArray;

//-----------------sdk相关  SDK-related----------------//
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) NvsLiveWindow *liveWindow;
@property (nonatomic, strong) NvsLiveWindow *liveWindowBack;
///当前窗口
///Current window
@property (nonatomic, strong) NvsLiveWindow *curLiveWindow;
///素材管理
///Material management
@property (nonatomic, strong) NvAssetManager *assetManager;
///粒子特效
///Particle effect
@property (nonatomic, strong) NvsCaptureVideoFx *fxARFace;
@property (nonatomic, assign) BOOL isContentAI;

@end

@implementation NvParCaptureViewController

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.streamingContext.getStreamingEngineState != NvsStreamingEngineState_CapturePreview) {
        [self startCapturePreview];
        self.streamingContext.delegate = self;
    }
    self.navigationController.navigationBar.hidden = YES;
    self.assetManager.delegate = self;
    [self addObservers];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.assetManager = [NvAssetManager sharedInstance];
    self.assetManager.delegate = self;
    [self.assetManager searchLocalAssets:ASSET_PARTICLE];
    
    self.videoPathArray = [NSMutableArray array];
    self.durationArray = [NSMutableArray array];
    self.currentAngleArray = [NSMutableArray array];
    self.dataSourceArray = [NSMutableArray array];
    
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addParticleArray];
    });
   
}

#pragma mark - 初始化人脸授权
/*
 初始化人脸授权
 Initialize face authorization
 */
- (void)initARFace {
    if (![NvInitArScence getInitArFace]) {
        if (ARSCENE_MS){
            [NvInitArScence initARFace:NvFaceMode_106];
        }else if (ARSCENE_MS_240){
            [NvInitArScence initARFace:NvFaceMode_240];
        }
    }
    
    if ([NvInitArScence getInitArFace]) {
        self.isContentAI = YES;
        [NvsStreamingContext sharedInstance].delegate = self;
        self.fxARFace = [[NvsStreamingContext sharedInstance] appendBuiltinCaptureVideoFx:@"AR Scene"];
        [self.fxARFace setBooleanVal:@"Max Faces Respect Min" val:YES];
        BOOL highVersion = [NvInitArScence isHighVersionPhone];
        if(highVersion) {
            [self.fxARFace setBooleanVal:@"AI Face Occlusion Enabled" val:YES];
        }
//        if (ARSCENE_ST_240 || ARSCENE_MS_240) {
//            // !!!: 设置后就会走检测， 不需要设置 3.12.0+
//            [self.fxARFace setBooleanVal:@"Use Face Extra Info" val:YES];
//        }
    }
}

#pragma mark 给粒子视图的数组添加数据
///Adds data to the array of particle views
- (void)addParticleArray{
    NvParticleModel *item = [NvParticleModel new];
    item.state = Finish;
    item.displayName = NvLocalString(@"None", @"无");
    item.coverName = @"NvsFilterNone";
    item.selected = NO;
    item.isParGraffiti = YES;
    [self.dataSourceArray removeAllObjects];
    [self.dataSourceArray addObject:item];
    int large,minor,revision;
    [NvsStreamingContext getSdkVersion:&large minorVersion:&minor revisionNumber:&revision];
    [self.assetManager newDownloadRemoteAssetsInfo:ASSET_ARSCENE categoryId:5 categoryList:nil keyword:nil page:1 pageSize:100 kind:NV_KIND_ID_ALL ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NSString stringWithFormat:@"%d.%d.%d",large,minor,revision]];
    [self.assetManager searchLocalAssets:ASSET_ARSCENE];
}


#pragma mark - NvAssetManagerDelegate
///获取素材列表成功回调
///Callback successfully obtained material list
- (void)onRemoteAssetsChanged:(BOOL)hasNext {
    NSArray <NvAsset *>*array = [self.assetManager getRemoteAssets:ASSET_ARSCENE aspectRatio:AspectRatio_All categoryId:5 kindId:NV_KIND_ID_ALL];
    for (NvAsset *asset in array) {
        NvParticleModel *model = [NvParticleModel new];
        model.coverName = asset.coverUrl;
        model.displayName = asset.displayName;
        model.packageId = asset.uuid;
        model.size = [NvSDKUtils getAssetPackageSizeString:asset.packageSize];
        model.draw = [NvSDKUtils getAssetAspectRatioString:asset.remoteAspectRatio];
        model.categoryId = asset.category;
        model.kindId = asset.kind;
        model.isAdjusted = asset.isAdjusted;
        if ([asset isReserved]) {
            model.packagePath = asset.bundledLocalDirPath;
        }else{
            model.packagePath = asset.localDirPath;
        }
        
        if ([asset isUsable]) {
            if ([asset hasUpdate]) {
                model.state = Update;
            }else{
                model.state = Finish;
            }
        }else{
            model.state = NODownload;
        }
        [self.dataSourceArray addObject:model];
    }
    [self.collectionView reloadData];
}

///获取素材列表失败回调
///Callback failed to get the material list
- (void)onGetRemoteAssetsFailed{
    [self.collectionView reloadData];
}

///下载素材进度回调
///Download material progress callback
- (void)onDownloadAssetProgress:(NSString *)uuid progress:(int)progress{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int j = 0; j < self.dataSourceArray.count; j++) {
            NvParticleModel *model = self.dataSourceArray[j];
            if ([model.packageId isEqualToString:uuid]) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForItem:j inSection:0];
                NvParticleAssetCell *cell = (NvParticleAssetCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                cell.downloadButton.status = NvDownloading;
                cell.downloadButton.progress = progress/100.f;
            }
        }
    });
}

///下载素材成功回调
///Download material successfully callback
- (void)onDonwloadAssetSuccess:(NSString *)uuid{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int j = 0; j < self.dataSourceArray.count; j++) {
            NvParticleModel *model = self.dataSourceArray[j];
            
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:j inSection:0];
            if ([model.packageId isEqualToString:uuid]) {
                NSString *tipString = [self.streamingContext.assetPackageManager getARSceneAssetPackagePrompt:uuid];
                if (tipString.length>0) {
                    [NvToast showInfoWithMessage:tipString];
                }
                
                model.state = Finish;
                [self.fxARFace setStringVal:@"Scene Id" val:model.packageId];
            }
            [UIView performWithoutAnimation:^{
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
        }
    });
}

///下载素材失败回调
///Material download failure callback
- (void)onDonwloadAssetFailed:(NSString *)uuid{

}

#pragma mark 初始化美摄sdk
///Initialize the Beauty sdk
- (void)startupCapture{
    self.streamingContext = [NvsStreamingContext sharedInstance];
    if (!_streamingContext) {
        return;
    }

    _streamingContext.delegate = self;

    if ([_streamingContext captureDeviceCount] == 0) {
    }

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
    [self addParticleFxView];
    [self initFocusView];
    [self configParameter];

    [self initARFace];
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
    
    self.deviceBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"flip", @"切换") withImageNormal:@"Nvdevice" withImageSelected:nil];
    [self.deviceBtn addTarget:self action:@selector(deviceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.flashBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"flash", @"补光灯") withImageNormal:@"Nvflash_off" withImageSelected:@"Nvflash_on"];
    [self.flashBtn addTarget:self action:@selector(flashBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.particleBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"particle", @"粒子") withImageNormal:@"Nvfilter" withImageSelected:nil];
    [self.particleBtn addTarget:self action:@selector(particleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.graffitiBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"graffiti", @"涂鸦") withImageNormal:@"NvGraffiti" withImageSelected:nil];
    [self.graffitiBtn addTarget:self action:@selector(graffitiBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.shootingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shootingBtn setImage:NvImageNamed(@"Nvshooting") forState:UIControlStateNormal];
    [self.shootingBtn setImage:NvImageNamed(@"Nvsuspended") forState:UIControlStateSelected];
    [self.shootingBtn addTarget:self action:@selector(shootingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.shootingBtn_1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shootingBtn_1 setImage:NvImageNamed(@"NvParticleShooting") forState:UIControlStateNormal];
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
    self.timeLabel.font = [NvUtils fontWithSize:12];
    
    self.videoCount = [UILabel new];
    self.videoCount.userInteractionEnabled = NO;
    self.videoCount.font = [NvUtils fontWithSize:12];
    self.videoCount.textColor = UIColor.whiteColor;
    
    [self.view addSubview:self.backBtn];
    [btnView addSubview:self.deviceBtn];
    [btnView addSubview:self.flashBtn];
    [btnView addSubview:self.particleBtn];
    [btnView addSubview:self.graffitiBtn];
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
    
    [self.particleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.flashBtn.mas_bottom).offset(24 * SCREENSCALE);
        make.left.right.equalTo(btnView);
    }];
    
    [self.graffitiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.particleBtn.mas_bottom).offset(24 * SCREENSCALE);
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
}

#pragma mark 添加特效标签滚动视图
///Add effects TAB scroll view
- (void)addParticleFxView{
    self.particlePanelView = [[UIView alloc]init];
    self.particlePanelView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#99000000"];
    [self.view addSubview:self.particlePanelView];
    [self.particlePanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.right.equalTo(self.view.mas_right);
        make.height.offset(100 * SCREENSCALE + INDICATOR);
        make.top.equalTo(self.view.mas_bottom).offset(0);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(70*SCREENSCALE,floor(100*SCREENSCALE));
    layout.minimumLineSpacing = 10*SCREENSCALE;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 16*SCREENSCALE, 0, 0);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 100 * SCREENSCALE) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsHorizontalScrollIndicator = NO;
    [collectionView registerClass:[NvParticleAssetCell class] forCellWithReuseIdentifier:@"NvParticleAssetCell"];
    self.collectionView = collectionView;
    [self.particlePanelView addSubview:collectionView];
}

#pragma mark 添加手动对焦视图
///Added manual focus view
- (void)initFocusView{
    self.focusView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.focusView.alpha = 0;
    [_focusView setImage:NvImageNamed(@"NvsCaptureFocus")];
    [self.view addSubview:self.focusView];
}

#pragma mark 启动采集之后，初始化效果采集参数
///After starting the collection, initialize the effects collection parameters
- (void)configParameter{
    self.timeLabel.hidden = YES;
    self.deleteBtn.hidden = YES;
    self.finishBtn.hidden = YES;
    
    [self.streamingContext removeAllCaptureVideoFx];
    if (_currentDeviceIndex == [self frontCameraDeviceIndex]) {
        self.flashBtn.userInteractionEnabled = NO;
        self.flashBtn.alpha = 0.7;
    } else {
        self.flashBtn.userInteractionEnabled = YES;
        self.flashBtn.alpha = 1;
    }
}

#pragma mark 相册权限提示
///Photo album permission prompt
- (void)tipView{
    
    [UIAlertController presentAlertFromVC:self
                                    title:NvLocalString(@"Save failed", @"保存失败")
                                  message:NvLocalString(@"Album permissions", @"您还没有允许相册访问权限")
                        buttonTitleColors:nil
                        cancelButtonTitle:nil
                         otherButtonTitle:NvLocalString(@"Know", @"知道了")
                       cancelButtonAction:nil
                        otherButtonAction:nil];

}

#pragma mark 将拍摄的视频保存到本地相册
///Save the video you shot to your local album
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {

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
    CGPoint point = CGPointMake(0.49*self.liveWindow.width, self.liveWindow.height / 2);
    if (capability.supportAutoFocus) {
        [_streamingContext startAutoFocus:point];
    }
    [self performSelector:@selector(delayaf) withObject:nil afterDelay:3.0];
}

- (void)captureVideoFrameGrabbedArrived:(NvsVideoFrameInfo*)sampleBufferInfo{
    if(!sampleBufferInfo)
        return;
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
        self.graffitiBtn.enabled = YES;
        self.graffitiBtn.alpha = 1;
    }else{
        self.videoCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)_videoPathArray.count];
        int64_t subResult = self.duration - [[_durationArray lastObject] longLongValue];
        self.duration = fmax(subResult, 0) ;
        self.timeLabel.text = [NvUtils convertTimecode:self.duration];
    }
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

#pragma mark 拍摄按钮点击
///Shoot button click
- (void)shootingBtnClick:(UIButton *)sender{
    if ([sender isEqual:self.shootingBtn_1]) {
        [self faceHiddenBtn:YES];
        self.shootingBtn_1.hidden = YES;
        self.shootingBtn.selected = YES;
        self.timeLabel.textColor = UIColor.redColor;
        self.videoCount.hidden = YES;
        
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
            self.graffitiBtn.enabled = NO;
            self.graffitiBtn.alpha = 0.7;
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

#pragma mark 涂鸦按钮点击事件
///Doodle button click event
- (void)graffitiBtnClick:(UIButton *)sender{
    if (_currentDeviceIndex != [self frontCameraDeviceIndex]) {
        [self.streamingContext toggleFlash:NO];
        _flashBtn.alpha = 1;
        _flashBtn.userInteractionEnabled = YES;
        _flashBtn.selected = NO;
    }
    NvAlbumViewController *vc = [[NvAlbumViewController alloc]init];
    vc.delegate = self;
    vc.isOnlyVideo = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 对焦延迟执行
///Focus delay execution
- (void)delayaf{
    [self.streamingContext startContinuousFocus];
}

#pragma mark 关闭退出
///Close exit
- (void)backBtnClick:(UIButton *)sender{
    [_streamingContext removeAllCaptureVideoFx];
    [_streamingContext stop];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 粒子按钮点击事件
///Particle button click event
- (void)particleBtnClick:(UIButton *)sender{
    self.clickState = YES;
    [self faceHiddenBtn:YES];
    [self.particlePanelView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(- self.particlePanelView.frame.size.height);
    }];
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
    }];
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
    self.compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
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
    NvsVideoCaptureResolutionGrade captureResGrade = [num intValue] == 1080? NvsVideoCaptureResolutionGradeHigh:NvsVideoCaptureResolutionGradeMedium;
    if ([_streamingContext isCaptureDeviceBackFacing:_currentDeviceIndex]){
        captureResGrade = NvsVideoCaptureResolutionGradeMedium;
    }
    BOOL ret = [_streamingContext startCapturePreview:_currentDeviceIndex videoResGrade:captureResGrade flags: NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame |NvsStreamingEngineCaptureFlag_GrabCapturedVideoFrame | NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize aspectRatio:nil];
    return ret;
}

#pragma mark 开始录制
///Start recording
- (void)startRecording{
    NSString *path = [VIDEO_PATH(@"Particle") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
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
        [self tipView];
        return;
    }

    UISaveVideoAtPathToSavedPhotosAlbum(self.videoPathArray.lastObject, self, nil, nil);
}

#pragma mark 点击隐藏界面按钮
///Click the Hide Interface button
- (void)faceHiddenBtn:(BOOL)hidden{
    self.deviceBtn.hidden = hidden;
    self.flashBtn.hidden = hidden;
    self.backBtn.hidden = hidden;
    self.shootingBtn.hidden = hidden;
    self.timeLabel.hidden = hidden;
    self.deleteBtn.hidden = hidden;
    self.finishBtn.hidden = hidden;
    self.particleBtn.hidden = hidden;
    self.graffitiBtn.hidden = hidden;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvParticleAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvParticleAssetCell" forIndexPath:indexPath];
    NvParticleModel *model = self.dataSourceArray[indexPath.item];
    [cell renderCellWithModel:model];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvParticleModel *model in self.dataSourceArray) {
        model.selected = false;
    }
    NvParticleModel *model = self.dataSourceArray[indexPath.item];
    model.selected = true;
    self.currentItem = model;
    if (model.state != Finish) {
        [self.assetManager downloadAsset:model.packageId];
    } else {
        // apply arscene
        [self.fxARFace setStringVal:@"Scene Id" val:model.packageId];
        NSString *tipString = [self.streamingContext.assetPackageManager getARSceneAssetPackagePrompt:model.packageId];
        if (tipString.length>0) {
            [NvToast showInfoWithMessage:tipString];
        }
        [collectionView reloadData];
    }

}

#pragma mark 增加粒子提示视图
///Added particle tip view
- (void)AddtipBoxView:(NSString *)title WithImage:(UIImage *)imageFile{
    
    if (!self.tipBoxView) {
        self.tipBoxView = [[UIView alloc]init];
        self.tipBoxView.layer.masksToBounds = YES;
        self.tipBoxView.layer.cornerRadius = 8;
        self.tipBoxView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#454A4A4A"];
        [self.curLiveWindow addSubview:self.tipBoxView];
        [self.tipBoxView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.particlePanelView.mas_top).offset(40 * SCREENSCALE);
            make.centerX.equalTo(self.view.mas_centerX);
            make.width.offset(185 * SCREENSCALE);
            make.height.offset(60 * SCREENSCALE);
        }];
        
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.image = imageFile;
        [self.tipBoxView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tipBoxView.mas_top).offset(8 * SCREENSCALE);
            make.centerX.equalTo(self.tipBoxView.mas_centerX);
            make.width.offset(21 * SCREENSCALE);
            make.height.offset(21 * SCREENSCALE);
        }];
        
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.textColor = UIColor.whiteColor;
        titleLabel.font = [UIFont systemFontOfSize:14 * SCREENSCALE];
        titleLabel.text = title;
        [self.tipBoxView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).offset(5 * SCREENSCALE);
            make.centerX.equalTo(self.tipBoxView.mas_centerX);
        }];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(deleteTip:) userInfo:nil repeats:NO];
}

- (void)deleteTip:(NSTimer *)timer{
    [self.timer invalidate];
    [self.tipBoxView removeFromSuperview];
    self.tipBoxView = nil;
}

#pragma mark NvAlbumViewControllerDelegate
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    NvAlbumAsset *asset = [assets firstObject];
    NvParEditViewController *editVC = [[NvParEditViewController alloc]init];
    editVC.selectAssets = assets;
    if (asset.asset.pixelHeight > asset.asset.pixelWidth) {
        editVC.editMode = NvEditMode9v16;
    }else{
        editVC.editMode = NvEditMode16v9;
    }
    [self.navigationController pushViewController:editVC animated:YES];
}

#pragma mark 给手动对焦视图添加动画
///Adds animation to the manual focus view
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

#pragma mark 点击空白显示界面按钮
///Click the blank display button
- (void)singleTap:(UITapGestureRecognizer *)recognizer {
    if (self.clickState) {
        self.clickState = NO;
        [self faceHiddenBtn:NO];
        [self.particlePanelView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_bottom).offset(0);
        }];
        [UIView animateWithDuration:0.1 animations:^{
            [self.view layoutIfNeeded];
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
        CGPoint point = [recognizer locationInView:_curLiveWindow];
        if (point.x >= SCREENWIDTH - 70 * SCREENSCALE || point.y >= SCREENHEIGHT - 190 * SCREENSCALE){
            return;
        }
        [_streamingContext startAutoFocus:point];
        [_streamingContext startAutoExposure:point];
        [self animateFocusView:point];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayaf) object:nil];
        [self performSelector:@selector(delayaf) withObject:nil afterDelay:3.0];
    }
}

#pragma mark 功能待开发中提示
///Function to be developed prompt
- (void)showTip {
    
    [UIAlertController presentAlertFromVC:self
                                    title:NvLocalString(@"Tips", @"提示")
                                  message:NvLocalString(@"Developing", @"Demo此功能正在开发中，敬请期待。SDK内部已支持。")
                        buttonTitleColors:nil
                        cancelButtonTitle:nil
                         otherButtonTitle:NvLocalString(@"Know", @"知道了")
                       cancelButtonAction:nil
                        otherButtonAction:nil];

}

#pragma mark 注册应用前台后台通知事件
///Register application foreground background notification events
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

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

///应用进入后台，停止采集
///The application enters the background and stops collecting data
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
    
    if ([_streamingContext getStreamingEngineState] == NvsStreamingEngineState_CapturePreview ||[_streamingContext getStreamingEngineState] == NvsStreamingEngineState_Playback) {
        [_streamingContext stop];
    }
}

///应用进入前台，开始采集
///The application enters the foreground and starts collecting
- (void)applicationDidBecomeActive:(NSNotification*)notification {
    if ([_streamingContext getStreamingEngineState] == NvsStreamingEngineState_Stopped) {
        if (self.preView) {
            
        }else{
            [self startCapturePreview];
        }
        
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

@end
