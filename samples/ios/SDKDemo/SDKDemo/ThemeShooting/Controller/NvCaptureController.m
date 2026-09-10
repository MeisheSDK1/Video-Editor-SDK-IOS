//
//  NvCaptureController.m
//  ThemeShooting
//
//  Created by ms on 2020/7/17.
//  Copyright © 2020 ms. All rights reserved.
//

#import "NvCaptureController.h"
#import "NvThemeShootingEditVC.h"
#import "NvStreamingSdkCore.h"
#import "NVHeader.h"
#import "NVDefineConfig.h"
#import "NvCaptureBtn.h"
#import "NvBottomLine.h"
#import "NvGraphicBtn.h"
#import "NvAudioPlayer.h"
#import "NvRecordingInfo.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "YYModel.h"
#import "NvFilterUsageUtil.h"
///视频录制保存的路径
///Path for saving the video recording
#define LOCALDIR [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define VIDEO_PATH(string) [LOCALDIR stringByAppendingPathComponent:string]

@interface NvCaptureController ()<NvsStreamingContextDelegate>
@property (nonatomic, strong) NvsLiveWindow *liveWindow;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) NvCaptureBtn *captureBtn;
@property (nonatomic, strong) NvBottomLine *bottomLine;
@property (nonatomic, strong) NvGraphicBtn *deleteBtn;
@property (nonatomic, strong) NvGraphicBtn *previewBtn;

@property (nonatomic, copy) NSString *dirPath;
@property (nonatomic, strong) NSMutableArray *videoPathArray;
@property (nonatomic, strong) NvsFx *currentVideoFx;
@property (nonatomic, strong) NvShotInfoModel *currentInfoModel;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) NvGraphicBtn *flashBtn;
@property (nonatomic, strong) UIButton *switchBtn;
@property (nonatomic, strong) NvAudioPlayer *player;
@property (nonatomic, copy) NSString *musicPath;
@property (nonatomic, strong) NSMutableArray *realCaptureVideos;
@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UIImageView *alertImage;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) BOOL isTranform;
@property (nonatomic ,strong) NvsCaptureVideoFx *fx;
@property (nonatomic, assign) BOOL isBack;
@end

@implementation NvCaptureController{
    int _currentDeviceIndex;
}

-(void)dealloc{
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
   
    self.videoPathArray = [NSMutableArray array];
    self.realCaptureVideos = self.model.packageInfoModel.realCaptureVideos;
    self.dirPath = [[NSHomeDirectory() stringByAppendingPathComponent:self.model.isLocal ? @"Documents/LocalThemeShoot": @"Documents/ThemeShoot"] stringByAppendingPathComponent:self.model.uuid ? self.model.uuid : self.model.packageInfoModel.ID];
    [self configAlertImage];
    for (NvShotInfoModel *info in self.model.packageInfoModel.shotInfos) {
        if (info.speed.count) {
            uint64_t s = 0 , sum = 0;
            int64_t duration = 0 ;
            for (NvSpeedModel *speedModel in info.speed) {
                duration = (speedModel.end-speedModel.start)*(speedModel.speed0+speedModel.speed1)/2.0;
                sum = sum + speedModel.start - s + duration;
                s = speedModel.end;
            }
            info.duration = sum;
        }
    }
    
    self.currentIndex = 0;
    self.currentInfoModel = self.realCaptureVideos.firstObject;

    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:self.dirPath]) {
        [fm createDirectoryAtPath:self.dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    self.musicPath = [self.dirPath stringByAppendingPathComponent:self.model.packageInfoModel.music];
    self.model.packageInfoModel.titleCover = [self.dirPath stringByAppendingPathComponent:self.model.packageInfoModel.titleCover];
    self.model.packageInfoModel.endingCover = [self.dirPath stringByAppendingPathComponent:self.model.packageInfoModel.endingCover];
    
    
    [self setupMeiSheSdk];
    [self installItems];
    [self addLiveWindows];
    [self initUI];
    [self startCapturePreview];
    [self addObserver];
    if (self.editMode == NvEditMode16v9) {
        [self resetHorLayout];
    }else{
        [self configAutolayout];
    }
    
    NvShotInfoModel *shot = self.realCaptureVideos[_currentIndex];
    NvAlertModel *alert = shot.alertInfo.firstObject;
    if([NvUtils currentLanguagesIsChinese]) {
       self.titleLable.text = alert.targetText;
    }else{
       self.titleLable.text = alert.originalText;
    }
    if (shot.alertImage.length > 0) {
        UIImage *image = [UIImage imageWithContentsOfFile:shot.alertImagePath];
        if (image) {
             self.alertImage.image = image;
        }
        
    }
    
    [self configAudioSession];
    
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
//    [self resetHorLayout];
}

- (void)addVertailLiveWindows {
    _liveWindow = [[NvsLiveWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _liveWindow.fillMode = NvsLiveWindowFillModePreserveAspectCrop;
    [self.view addSubview:_liveWindow];
    if (![_streamingContext connectCapturePreviewWithLiveWindow:_liveWindow]) {
    }
}

- (void)configAudioSession {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}
-(void)updateCaptureBtnStatus{
    
}

-(void)initUI{
    self.captureBtn = [[NvCaptureBtn alloc] init];
    [self.captureBtn addTapGestureRecognizerWithTarget:self action:@selector(captureBtnClick)];
    [self.view addSubview:self.captureBtn];
    
    self.bottomLine = [[NvBottomLine alloc] init];
    
    self.bottomLine.arr = self.realCaptureVideos;
    self.bottomLine.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.bottomLine];
    __weak typeof(self)weakSelf = self;
    self.deleteBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"themeDelete", @"删除") withImageNormal:@"theme_delegate_btn" withImageSelected:@"theme_delegate_btn"];
    [self.deleteBtn setCustomImageSize:CGSizeMake(35.0f*SCREENSCALE, 35.0f*SCREENSCALE) offset:7.5*SCREENSCALE];
    [self.deleteBtn setCustomFontSize:12];
    [self.deleteBtn setAlpha:0.8];
    [self.view addSubview:self.deleteBtn];
    
    [self.deleteBtn nv_BtnClickHandler:^{
        
        if (weakSelf.videoPathArray.count) {
            [weakSelf deleLastVedio];
        }
    }];
    
    self.previewBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"themePreview", @"预览") withImageNormal:@"theme_preview_ben" withImageSelected:@"theme_preview_ben"];
    [self.previewBtn setCustomImageSize:CGSizeMake(35.0f*SCREENSCALE, 35.0f*SCREENSCALE) offset:7.5*SCREENSCALE];
    [self.previewBtn setCustomFontSize:12];
    [self.previewBtn setAlpha:0.8];
    self.previewBtn.hidden = YES;
    [self.view addSubview:self.previewBtn];
    
    
    [self.previewBtn nv_BtnClickHandler:^{
        weakSelf.previewBtn.enabled = NO;
        if (weakSelf.videoPathArray.count != weakSelf.realCaptureVideos.count) {
            return;
        }
        NvThemeShootingEditVC *vc = [[NvThemeShootingEditVC alloc]init];
        vc.currentModel = [weakSelf.model.packageInfoModel copy];
        vc.dirPath = weakSelf.dirPath;
        vc.needRotate = weakSelf.editMode == NvEditMode16v9;
        vc.editMode = weakSelf.editMode;
        [weakSelf.navigationController pushViewController:vc animated:YES];
        weakSelf.previewBtn.enabled = YES;
       
    }];
    
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_backBtn];
    [_backBtn setImage:NvImageNamed(@"theme_capture_back") forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.flashBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:@"" withImageNormal:@"Nvflash_off" withImageSelected:@"Nvflash_on"];
    [self.view addSubview:self.flashBtn];
    [self.flashBtn setCustomFontSize:11*SCREENSCALE];
    [self.flashBtn addTarget:self action:@selector(flashBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_switchBtn];
    [_switchBtn setImage:NvImageNamed(@"camera_switch_theme") forState:UIControlStateNormal];
    [_switchBtn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    UILabel *tipLabel = [[UILabel alloc]init];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = UIColor.whiteColor;
    tipLabel.numberOfLines = 0;
    tipLabel.font = [UIFont systemFontOfSize:18.0f];
    tipLabel.backgroundColor = [UIColor clearColor];
    self.titleLable = tipLabel;
    [self.view addSubview:tipLabel];
    self.titleLable.frame = CGRectMake(0, NV_STATUSBARHEIGHT + 50.0f, kScreenWidth-40.0f, 25.0f);
    self.titleLable.centerX = self.view.viewCenterX;
    
    self.alertImage = [[UIImageView alloc] init];
    [self.view addSubview:self.alertImage];
    if (self.editMode == NvEditMode16v9) {
        self.alertImage.frame = CGRectMake(0, NV_STATUSBARHEIGHT + 100.0f, 640.0f, 360.0f);
    }else{
        self.alertImage.frame = CGRectMake(0, NV_STATUSBARHEIGHT + 100.0f, 360.0f, 640.0f);
    }
    
    self.alertImage.viewCenterX = self.view.viewCenterX;
    self.alertImage.viewCenterY = self.view.viewCenterY;
    self.alertImage.contentMode = UIViewContentModeScaleAspectFit;
}

-(void)configAutolayout{
    [self.captureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).offset(-107.0f*SCREENSCALE);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.height.mas_equalTo(78.0f);
    }];

    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.captureBtn.mas_centerY);
        make.right.mas_equalTo(self.captureBtn.mas_left).offset(-65.0f*SCREENSCALE);
        make.width.mas_equalTo(40.0f);
        make.height.mas_equalTo(60.0f);
    }];
    
    [self.previewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.captureBtn.mas_centerY);
        make.left.mas_equalTo(self.captureBtn.mas_right).offset(65.0f*SCREENSCALE);
        make.width.mas_equalTo(40.0f);
        make.height.mas_equalTo(60.0f);
    }];
    
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NV_STATUSBARHEIGHT);
        make.left.equalTo(self.view).offset(13 * SCREENSCALE);
        make.width.offset(33 * SCREENSCALE);
        make.height.offset(33 * SCREENSCALE);
    }];
    [_flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NV_STATUSBARHEIGHT);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.offset(33 * SCREENSCALE);
        make.height.offset(33 * SCREENSCALE);
    }];
    
    [_switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NV_STATUSBARHEIGHT);
        make.right.equalTo(self.view).offset(-13 * SCREENSCALE);
        make.width.offset(33 * SCREENSCALE);
        make.height.offset(33 * SCREENSCALE);
    }];
    self.bottomLine.frame = CGRectMake(0, SCREENHEIGHT - 50.0f, SCREENWIDTH, 4.0f);
}



#pragma mark flashBtnClick
- (void)flashBtnClick:(UIButton *)sender{
    if ([_streamingContext getCaptureDeviceCapability:_currentDeviceIndex].supportFlash) {
        [_streamingContext toggleFlash:![_streamingContext isFlashOn]];
        _flashBtn.selected = [_streamingContext isFlashOn];
    }
}


#pragma mark cameraButtonClicked
- (void)cameraButtonClicked {
    ///前置摄像头
    ///Front camera
    if ([self.streamingContext isCaptureDeviceBackFacing:_currentDeviceIndex]) {
        _currentDeviceIndex = [self frontCameraDeviceIndex];
        _flashBtn.selected = NO;
    } else {
        ///后置摄像头
        ///Rear camera
        _currentDeviceIndex = [self backCameraDeviceIndex];
    }
    
    [self startCapturePreview];
}

-(void)switchBtnClick:(UIButton *)btn{
    [self cameraButtonClicked];
}

#pragma mark 获取后置摄像头
///Obtain the rear camera
- (unsigned int)backCameraDeviceIndex {
    for (unsigned int i = 0; i < self.streamingContext.captureDeviceCount; i++) {
        if ([self.streamingContext isCaptureDeviceBackFacing:i])
            return i;
    }
    return 0;
}

-(void)configAlertImage{

    for (int i=0; i<self.model.packageInfoModel.shotInfos.count; i++) {
        NvShotInfoModel *model = self.model.packageInfoModel.shotInfos[i];
        if (model.alertImage.length > 0) {
            if (self.editMode == NvEditMode16v9) {
                model.alertImagePath = [self.dirPath stringByAppendingPathComponent:model.alertImage];
            }else{
                NSMutableString *tempMutableString = [NSMutableString stringWithString:model.alertImage];
                [tempMutableString insertString:@"9v16" atIndex:[model.alertImage rangeOfString:@"."].location];
                model.alertImagePath = [self.dirPath stringByAppendingPathComponent:tempMutableString];
            }
        }
    }
}

-(void)configSource{
    
    for (NvShotInfoModel *info in self.model.packageInfoModel.shotInfos) {
        info.sourcePath = @"";
    }
    
    int j =0;
    for (int i=0; i<self.model.packageInfoModel.shotInfos.count; i++) {
        NvShotInfoModel *model = self.model.packageInfoModel.shotInfos[i];
        if (model.source.length > 0) {
            if (self.editMode == NvEditMode16v9) {
                model.sourcePath = [self.dirPath stringByAppendingPathComponent:model.source];
            }else{
                NSMutableString *tempMutableString = [NSMutableString stringWithString:model.source];
                [tempMutableString insertString:@"9v16" atIndex:[model.source rangeOfString:@"."].location];
                model.sourcePath = [self.dirPath stringByAppendingPathComponent:tempMutableString];
            }
        }else{
            if (j>=self.videoPathArray.count) {
                NSLog(@"error: 主题拍摄数组越界 Subject shot array out of bounds");
                return;
            }
            NvRecordingInfo *info = self.videoPathArray[j];
            model.sourcePath = info.recordingPath;
            j++;
        }
    }
}

-(void)deleLastVedio{
    
    NVWeakSelf
    UIAlertController * alertController = [UIAlertController alertWithTitle:NvLocalString(@"Are you sure you want to delete this video？" , @"确定要删除这段视频？")
                                                                    message:nil
                                                          buttonTitleColors:nil
                                                          cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"album.cancel",@"NvAlbum",[NSBundle bundleForClass:self.class],nil)
                                                           otherButtonTitle:NSLocalizedStringFromTableInBundle(@"album.ok",@"NvAlbum",[NSBundle bundleForClass:self.class],nil)
                                                         cancelButtonAction:nil
                                                          otherButtonAction:^(UIAlertAction * _Nonnull action) {
        if (weakSelf.videoPathArray.count > 0) {
            self.titleLable.hidden = NO;
            self.alertImage.hidden = NO;
            NvRecordingInfo *info = [weakSelf.videoPathArray lastObject];
            float musicStartPos = info.musicStartPos;
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:info.recordingPath error:nil];
            [weakSelf.videoPathArray removeLastObject];
            [weakSelf.bottomLine deleteLastPath];
            weakSelf.currentIndex = weakSelf.videoPathArray.count;
            NvRecordingInfo *infolast = [weakSelf.videoPathArray lastObject];
            if (infolast == nil) {
                [weakSelf.player seekToTime:musicStartPos];
            } else {
                [weakSelf.player seekToTime:infolast.musicEndPos];
            }
            weakSelf.captureBtn.userInteractionEnabled = YES;
            weakSelf.captureBtn.completeImage.hidden = YES;
            weakSelf.previewBtn.hidden = YES;
            NvShotInfoModel *shot = self.realCaptureVideos[self->_currentIndex];
            NvAlertModel *alert = shot.alertInfo.firstObject;
            if([NvUtils currentLanguagesIsChinese]) {
                self.titleLable.text = alert.targetText;
            }else{
                self.titleLable.text = alert.originalText;
            }
            if (shot.alertImage.length > 0) {
                UIImage *image = [UIImage imageWithContentsOfFile:shot.alertImagePath];
                if (image) {
                    self.alertImage.image = image;
                    self.alertImage.hidden = NO;
                }
            }
        }
    }];
    alertController.view.hidden = YES;
    [self presentViewController:alertController animated:YES completion:^{
        
        alertController.view.hidden = NO;
    }];
}

-(void)backBtnClick:(UIButton *)btn{
    
    NVWeakSelf
    UIAlertController * alertController = [UIAlertController alertWithTitle:NvLocalString(@"Are you sure you want to quit shooting？" , @"确定要退出拍摄？")
                                                                    message:nil
                                                          buttonTitleColors:nil
                                                          cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"album.cancel",@"NvAlbum",[NSBundle bundleForClass:self.class],nil)
                                                           otherButtonTitle:NSLocalizedStringFromTableInBundle(@"album.ok",@"NvAlbum",[NSBundle bundleForClass:self.class],nil)
                                                         cancelButtonAction:nil
                                                          otherButtonAction:^(UIAlertAction * _Nonnull action) {
        [weakSelf.streamingContext stop];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    alertController.view.hidden = YES;
    [self presentViewController:alertController animated:YES completion:^{
        
        alertController.view.hidden = NO;
    }];
}


- (void)setupMeiSheSdk {
    
    self.streamingContext = [NvSDKUtils getSDKContext];
    if (!_streamingContext) {
        return;
    }
    if ([self.streamingContext getCaptureVideoFxCount]) {
           [self.streamingContext removeAllCaptureVideoFx];
    }
    
    self.streamingContext.delegate = self;
    
    if ([_streamingContext captureDeviceCount] == 0) {
    }
    ///添加经典滤镜
    ///Add a classic filter
    NvShotInfoModel *shot = self.realCaptureVideos.firstObject;
    NvAlertModel *alert = shot.alertInfo.firstObject;
    if([NvUtils currentLanguagesIsChinese]) {
       self.titleLable.text = alert.targetText;
    }else{
       self.titleLable.text = alert.originalText;
    }
}

- (void)installItems {
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:self.dirPath error:nil];
    NSString *fullPath ;
    for (NSString *path in dirArray) {
        
        fullPath = [self.dirPath stringByAppendingPathComponent:path];
        if ([fullPath hasSuffix:@"videofx"] ||
            [fullPath hasSuffix:@"videotransition"] ||
            [fullPath hasSuffix:@"compoundcaption"] ||
            [fullPath hasSuffix:@"animatedsticker"]) {
            
            NSMutableString* sceneId = [[NSMutableString alloc] init];
            NvsAssetPackageType assetType;
            if ([fullPath.pathExtension containsString:@"videofx"]) {
                assetType = NvsAssetPackageType_VideoFx;
            } else if ([fullPath.pathExtension containsString:@"compoundcaption"]) {
                assetType = NvsAssetPackageType_CompoundCaption;
            } else if ([fullPath.pathExtension containsString:@"videotransition"]) {
                assetType = NvsAssetPackageType_VideoTransition;
            } else {
                assetType = NvsAssetPackageType_AnimatedSticker;
            }
            NSString * licensePath = [NSString convertFilePathToNewPath:fullPath WithExtension:@"lic"];
            NvsAssetPackageManagerError error = [self.streamingContext.assetPackageManager installAssetPackage:fullPath license:licensePath type:assetType sync:YES assetPackageId:sceneId];
            NSLog(@"===%d", error);
            if (error != NvsAssetPackageManagerError_NoError && error != NvsAssetPackageManagerError_AlreadyInstalled) {
                NSLog(@"failure %@",fullPath);
            }else{
                NSLog(@"success %@",fullPath);
            }
        }
    }
}


- (void)addLiveWindows {
    _liveWindow = [[NvsLiveWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _liveWindow.fillMode = NvsLiveWindowFillModePreserveAspectCrop;
    [self.view addSubview:_liveWindow];
    if (![_streamingContext connectCapturePreviewWithLiveWindow:_liveWindow]) {
    }
}

-(void)captureBtnClick{
    if (_currentIndex == self.realCaptureVideos.count) {
        if (self.videoPathArray.count != self.realCaptureVideos.count) {
            return;
        }
        
        NvThemeShootingEditVC *vc = [[NvThemeShootingEditVC alloc]init];
        vc.currentModel = [self.model.packageInfoModel copy];
        vc.dirPath = self.dirPath;
        vc.needRotate = self.editMode == NvEditMode16v9;
        vc.editMode = self.editMode;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        self.captureBtn.userInteractionEnabled = NO;
        [self.captureBtn beginRecord];
        [self startRecording];
    }
}

#pragma mark - 启动摄像头采集预览
///Start the camera capture preview
- (BOOL)startCapturePreview {
    NvsRational rational ;
    rational.num = 9;
    rational.den = 16;
    BOOL result = [_streamingContext startCapturePreview:_currentDeviceIndex videoResGrade:NvsVideoCaptureResolutionGradeSupperHigh flags:NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame | NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize|NvsStreamingEngineCaptureFlag_EnableTakePicture|NvsStreamingEngineCaptureFlag_IgnoreScreenOrientation aspectRatio:&rational];
    
    return result;
}

-(void)appendTimelineFilter{
    self.fx = [NvFilterUsageUtil appendPackagedCaptureVideoFx:self.model.packageInfoModel.timelineFilter];
    [self.fx setFilterIntensity:1.0f];
}

-(void)removeTimelineFilter{
    [self.streamingContext removeCaptureVideoFx:self.fx.index];
}

#pragma mark 开始录制
///Start recording
- (void)startRecording{
    self.bottomLine.hidden = YES;
    self.deleteBtn.hidden = YES;
    self.backBtn.hidden = YES;
    self.flashBtn.hidden = YES;
    self.switchBtn.hidden = YES;
    self.titleLable.hidden = YES;
    self.alertImage.hidden = YES;
    if (!self.realCaptureVideos.count) {
        return;
    }
    NvShotInfoModel *shot = self.realCaptureVideos[_currentIndex];
    NvsCaptureVideoFx *fx = [NvFilterUsageUtil appendPackagedCaptureVideoFx:shot.filter];
    [fx setFilterIntensity:1.0f];
    if (self.videoPathArray.count > 0 && _currentIndex < self.realCaptureVideos.count) {
        NvRecordingInfo *rec = self.videoPathArray.lastObject;
        [self.player seekToTime:rec.musicEndPos];
    }else{
        [self.player seekToTime:0];
    }
    [self.player play];
    NSString *path = [VIDEO_PATH(@"Record") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
    
    [_streamingContext startRecordingWithFx:path withFlags:NvsStreamingEngineRecordingFlag_IgnoreVideoRotation withRecordConfigurations:config];
    NvRecordingInfo *info = [NvRecordingInfo new];
    info.recordingPath = path;
    info.musicStartPos = self.player.currentTime;
    [self.videoPathArray addObject:info];
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


#pragma mark NvsStreamingContextDelegate
- (void)didCaptureRecordingDurationUpdated:(int)captureDeviceIndex duration:(int64_t)duration{
    
    if(_currentIndex == self.realCaptureVideos.count){
        return;
    }
    NvShotInfoModel *shot = self.realCaptureVideos[_currentIndex];
    int64_t restTime = shot.duration - duration;
    if (restTime >= 0) {
        CGFloat ratio = duration * 1.0 / shot.duration;
        self.captureBtn.progress = ratio;
        self.captureBtn.percentageLabel.text = [NSString stringWithFormat:@"%.1fs",restTime*1.0/NV_TIME_BASE];
    }
    
    if (restTime <= 0) {
        [self stopRecordWithNotifi:NO];
        NvRecordingInfo *lastInfo = self.videoPathArray.lastObject;
        lastInfo.isRecordSuccess = YES;
    }
}

-(void)stopRecordWithNotifi:(BOOL)noti{
    [_streamingContext stopRecording];
    self.bottomLine.hidden = NO;
    self.deleteBtn.hidden = NO;
    self.backBtn.hidden = NO;
    self.flashBtn.hidden = NO;
    self.switchBtn.hidden = NO;
    if (_currentIndex != self.realCaptureVideos.count - 1) {
        self.titleLable.hidden = NO;
        self.alertImage.hidden = NO;
    }

    _captureBtn.userInteractionEnabled = YES;
    [self.player pause];
    [self.captureBtn stopRecord];
    NvRecordingInfo *info = [self.videoPathArray lastObject];
    info.musicEndPos = self.player.currentTime;
    if (self.videoPathArray.count && !noti) {
        self.bottomLine.currentIndex = _currentIndex;
    }
    _currentIndex = self.videoPathArray.count ;
    [self.streamingContext removeAllCaptureVideoFx];
    if (_currentIndex == self.realCaptureVideos.count) {
        [self configSource];
        self.previewBtn.hidden = NO;
        self.captureBtn.completeImage.hidden = NO;
        return;
    }
    NvShotInfoModel *shot = self.realCaptureVideos[_currentIndex];
    NvAlertModel *alert = shot.alertInfo.firstObject;
    
    if([NvUtils currentLanguagesIsChinese]) {
       self.titleLable.text = alert.targetText;
    }else{
       self.titleLable.text = alert.originalText;
    }
    if (shot.alertImage.length > 0) {
        UIImage *image = [UIImage imageWithContentsOfFile:shot.alertImagePath];
        if (image) {
             self.alertImage.image = image;
             
        }
        
    }
}

- (void)didCaptureRecordingStarted:(unsigned int)captureDeviceIndex {
   
}

- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state {
    _flashBtn.selected = [_streamingContext isFlashOn];
}

- (void)didFirstVideoFramePresented:(NvsTimeline *)timeline {

}

- (void)didCaptureDeviceCapsReady:(unsigned int)captureDeviceIndex{
    
}

- (void)didCaptureDeviceError:(unsigned int)captureDeviceIndex errorCode:(int32_t)errorCode{
    
}

#pragma mark 添加通知
///Add notification
- (void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

}

-(void)resetHorLayout{
    self.switchBtn.frame = CGRectMake(self.view.width-53, 30, 33, 33);
    self.flashBtn.frame = CGRectMake(0, 30, 33, 33);
    self.flashBtn.centerX = self.view.width/2;

    self.backBtn.frame = CGRectMake(20, 30, 33, 33);

    self.titleLable.frame = CGRectMake(self.view.width/2-20 , 0, self.view.width, 25);
    self.titleLable.centerY = self.view.height/2;
    
    self.bottomLine.frame = CGRectMake(-self.view.width/2+20, 0, self.view.width, 4);
    self.bottomLine.centerY = self.view.height/2;

    self.captureBtn.frame = CGRectMake(0, 0, 78, 78);
    self.captureBtn.centerX = self.view.width/2;
    self.captureBtn.bottom = self.view.height-20;
    

    self.deleteBtn.frame = CGRectMake(20, self.view.height-60-20, 40, 60);

    self.previewBtn.frame = CGRectMake(self.view.width-40-20, 0, 40, 60);
    self.previewBtn.bottom = self.view.height-20;

    [self.liveWindow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
    CGFloat ang = M_PI_2;
    self.switchBtn.transform = CGAffineTransformRotate(self.switchBtn.transform, ang);
    self.flashBtn.transform = CGAffineTransformRotate(self.flashBtn.transform, ang);
    self.backBtn.transform = CGAffineTransformRotate(self.backBtn.transform, ang);
    self.titleLable.transform = CGAffineTransformRotate(self.titleLable.transform, ang);
    self.alertImage.transform = CGAffineTransformRotate(self.alertImage.transform, ang);
    self.bottomLine.transform = CGAffineTransformRotate(self.bottomLine.transform, ang);
    self.captureBtn.transform = CGAffineTransformRotate(self.captureBtn.transform, ang);
    self.deleteBtn.transform = CGAffineTransformRotate(self.deleteBtn.transform, ang);
    self.previewBtn.transform = CGAffineTransformRotate(self.previewBtn.transform, ang);
}


#pragma mark - 应用进入后台，停止播放
///The application enters the background and stops playing
- (void)applicationWillResignActive:(NSNotification*)notification {
    NvRecordingInfo *lastInfo = self.videoPathArray.lastObject;
    if (!lastInfo.isRecordSuccess) {
        [self.videoPathArray removeLastObject];
    }
    [self stopRecordWithNotifi:YES];
    
}

#pragma mark - 应用进入前台，恢复播放
///The application enters the foreground and resumes playing
- (void)applicationBecomeActive:(NSNotification*)notification {
    [self startCapturePreview];
}


#pragma mark - 生命周期
///Life cycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.streamingContext.delegate = self;
    if ([self.streamingContext getStreamingEngineState] != NvsStreamingEngineState_CapturePreview) {
        [self startCapturePreview];
    }
    
    self.navigationController.navigationBar.hidden = YES;
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    
}

-(NvAudioPlayer *)player{
    if (!_player) {
        _player = [NvAudioPlayer new];
        _player.delegate = self;
        [_player setUrlString:self.musicPath];
    }
    return _player;
}

@end
