//
//  NvPIPEditViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/12.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvPIPEditViewController.h"
#import <NvSDKCommon/NvCompileViewController.h>
#import "NvPIPPreviewViewController.h"
#import "NvAlbumViewController.h"
#import "NvsLiveWindow.h"
#import "NvsVideoTrack.h"
#import "NvsVideoFx.h"
#import "NvTimelineUtils.h"
#import "NvPIPThemeItem.h"
#import "NvCustomButton.h"
#import "NvPIPOperationView.h"
#import "NvPIPThemeView.h"
#import "NvTipsView.h"
#import "NvPIPRectView.h"
#import "NvPIPWindowView.h"
#import "NvCutVideoViewController.h"
#import <Masonry/Masonry.h>
#import <NvBaseCommon/UIView+Dimension.h>
#import <NvSDKCommon/NvSDKUtils.h>

@interface NvPIPEditViewController ()<NvCompileViewControllerDelegate, NvPIPRectViewDelegate>
{
    NvPIPWindowView *_pipWindow;
}

@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, strong) NvsLiveWindow *liveWindow;
@property (nonatomic, strong) NSString *compileFilePath;
@property (nonatomic, strong) NvCustomButton *themeButton,*preViewButton;
@property (nonatomic, strong) NvPIPOperationView *opView;
@property (nonatomic, strong) NvPIPThemeView *pipThemeView;
@property (nonatomic, strong) NvPIPRectView *pipRectView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) NvEditMode editMode;
///当前轨道
///Current orbit
@property (nonatomic, strong) NvsVideoTrack *currentTrack;
///选择的模版
///The template of choice
@property (nonatomic, assign) NSInteger selectIndex;
///第一个轨道音量按钮
///First track volume button
@property (nonatomic, strong) UIButton *firstTrackButton;
///第二个轨道音量按钮
///Second track volume button
@property (nonatomic, strong) UIButton *secondTrackButton;
@property (nonatomic, strong) UIButton *compileButton;
@property (nonatomic, assign) BOOL initFirst;
@end

@implementation NvPIPEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NvLocalString(@"PIPEdit", @"画中画编辑");
    self.initFirst = YES;
    self.streamingContext = [NvsStreamingContext sharedInstanceWithFlags:NvsStreamingContextFlag_Support4KEdit | NvsStreamingContextFlag_InterruptStopForInternalStop | NvsStreamingContextFlag_NeedGifMotion];
    
    [self initTimeline:NvEditMode9v16];
    

    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.liveWindow = [[NvsLiveWindow alloc] initWithFrame:CGRectMake(64*SCREENSCALE, 0, SCREENWIDTH - 2*64*SCREENSCALE, (SCREENWIDTH - 2*64*SCREENSCALE) * 16.0/9)];
    [self.view addSubview:self.liveWindow];
    
    _pipWindow = [[NvPIPWindowView alloc] initWithFrame:self.liveWindow.frame];
    _pipWindow.delegate = self;
    [self.view addSubview:_pipWindow];

    self.themeButton = [[NvCustomButton alloc] init];
    self.themeButton.image = NvImageNamed(@"pip-format");
    self.themeButton.name = NvLocalString(@"Mould", @"模板");
    [self.view addSubview:self.themeButton];
    [self.themeButton mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.mas_equalTo(KScale6s(50));
        make.width.mas_equalTo(KScale6s(50));
        make.height.mas_equalTo(KScale6s(80));
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-KScale6s(10));
    }];
    
    [self.themeButton addTarget:self action:@selector(themeClick:) forControlEvents:UIControlEventTouchUpInside];
    self.themeButton.fontSize = 12;
    self.themeButton.fontSizeAdjustsToFitWidth = NO;
    self.preViewButton = [[NvCustomButton alloc] init];
    self.preViewButton.image = NvImageNamed(@"pip-preview");
    self.preViewButton.name = NvLocalString(@"Preview", @"预览");
    [self.view addSubview:self.preViewButton];
    [self.preViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.mas_equalTo(-KScale6s(50));
        make.width.mas_equalTo(KScale6s(50));
        make.height.mas_equalTo(KScale6s(80));
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-KScale6s(10));
    }];
    [self.preViewButton addTarget:self action:@selector(preViewClick:) forControlEvents:UIControlEventTouchUpInside];
    self.preViewButton.fontSize = 12;
    self.preViewButton.fontSizeAdjustsToFitWidth = NO;
    self.opView = [[NvPIPOperationView alloc] init];
    self.opView.delegate = self;
    self.opView.clipsToBounds = YES;
    [self.view addSubview:self.opView];
    self.opView.hidden = YES;
    [self.opView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0*SCREENSCALE));
        make.top.equalTo(@(100*SCREENSCALE));
    }];
    
    self.pipRectView = [[NvPIPRectView alloc] initWithFrame:CGRectMake(0, 0, self.liveWindow.width, self.liveWindow.height/2)];
    self.pipRectView.delegate = self;
    [self.liveWindow addSubview:self.pipRectView];
    self.pipRectView.hidden = YES;
    [self.pipRectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    self.pipThemeView = [[NvPIPThemeView alloc] init];
    [self.view addSubview:self.pipThemeView];
    [self.pipThemeView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(KScale6s(140));
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-KScale6s(10));
    }];
    self.pipThemeView.delegate = self;
    self.pipThemeView.hidden = YES;
    
    self.firstTrackButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"volume_up - material")];
    [self.firstTrackButton setImage:NvImageNamed(@"volume_off - material") forState:UIControlStateSelected];
    self.firstTrackButton.frame = CGRectMake(11*SCREENSCALE, 15*SCREENSCALE, 25*SCREENSCALE, 25*SCREENSCALE);
    [self.firstTrackButton addTarget:self action:@selector(firstTrackButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_pipWindow addSubview:self.firstTrackButton];
    self.secondTrackButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"volume_up - material")];
    [self.secondTrackButton setImage:NvImageNamed(@"volume_off - material") forState:UIControlStateSelected];
    self.secondTrackButton.frame = CGRectMake(11*SCREENSCALE, self.liveWindow.height/2+15*SCREENSCALE, 25*SCREENSCALE, 25*SCREENSCALE);
    [self.secondTrackButton addTarget:self action:@selector(secondTrackButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_pipWindow addSubview:self.secondTrackButton];
    
    ///给NvPIPThemeView加载数据并刷新
    ///Load data to the NvPIPThemeView and refresh it
    [self readData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.streamingContext connectTimeline:self.timeline withLiveWindow:self.liveWindow];
    [self.streamingContext seekTimeline:self.timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}

- (UIView *)rightNavigationBarItemView {
    self.compileButton = [UIButton nv_buttonWithTitle:NvLocalString(@"Compile", @"生成") textColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] fontSize:16 image:nil];
    self.compileButton.frame = CGRectMake(0, 0, 30, 44);
    self.compileButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15*SCREENSCALE);
    [self.compileButton addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.compileButton.exclusiveTouch = YES;
    return self.compileButton;
}

- (void)readData {
    self.dataSource = [NSMutableArray array];

    NSString *packagePath = [[NSBundle mainBundle] pathForResource:@"PIPPackage" ofType:@"bundle"];
    NSString *jsonPath = [packagePath stringByAppendingPathComponent:@"pipFileInfo.json"];
    NSString *jsontext = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
    NSData *data =[jsontext dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    for (int i = 0; i < array.count; i++) {
        NSDictionary *dic = array[i];
        NvPIPThemeItem *item = [NvPIPThemeItem new];
        item.packageId1 = dic[@"pipPackage1"];
        item.packageId2 = dic[@"pipPackage2"];
        item.bundleImagePath = dic[@"bundleImagePath"];
        item.name = NvLocalString(dic[@"name"], @"") ;
        item.imageUrl = dic[@"imageName"];
        item.isSelect = NO;
        item.isInstall = YES;
        [self.dataSource addObject:item];
    }
    
    NvPIPThemeItem *item = self.dataSource.firstObject;
    item.isSelect = YES;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:PIPPACKAGE_PATH]) {
        [fm createDirectoryAtPath:PIPPACKAGE_PATH withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *jsonPath2 = [PIPPACKAGE_PATH stringByAppendingPathComponent:@"pipFileInfo.json"];
    NSString *jsontext2 = [NSString stringWithContentsOfFile:jsonPath2 encoding:NSUTF8StringEncoding error:nil];
    NSData *data2 =[jsontext2 dataUsingEncoding:NSUTF8StringEncoding];
    if (data2){
        NSArray *array2 =[NSJSONSerialization JSONObjectWithData:data2 options:0 error:nil];
        for (int i = 0; i < array2.count; i++) {
            NSDictionary *dic = array2[i];
            NvPIPThemeItem *item = [NvPIPThemeItem new];
            item.packageId1 = dic[@"pipPackage1"];
            item.packageId2 = dic[@"pipPackage2"];
            item.bundleImagePath = dic[@"bundleImagePath"];
            item.name = NvLocalString(dic[@"name"], @"");
            item.imageUrl = dic[@"imageName"];
            item.isSelect = NO;
            item.isInstall = YES;
            [self.dataSource addObject:item];
        }
    }
        
    self.pipThemeView.dataSource = self.dataSource;
    [self nvPIPThemeView:self.pipThemeView applyTemplate:self.dataSource.firstObject];


    self.currentTrack = [self.timeline getVideoTrackByIndex:0];
    NvsVideoClip *clip = [self.currentTrack getClipWithIndex:0];
    self.opView.hiddenCrop = !(clip.videoType == NvsVideoClipType_AV);
    
    self.pipRectView.hidden = NO;
    [self.pipRectView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(@0);
        make.width.equalTo(@(self.liveWindow.bounds.size.width));
        make.height.equalTo(@(self.liveWindow.bounds.size.height/2));
    }];
    self.opView.hidden = NO;
    [self.opView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.pipRectView);
        make.bottom.equalTo(self.pipRectView);
    }];
}

- (void)themeClick:(NvCustomButton *)customButton {
    self.pipThemeView.hidden = NO;
}

- (void)preViewClick:(NvCustomButton *)customButton {
    NvPIPPreviewViewController *pipPreview = [NvPIPPreviewViewController new];
    pipPreview.timeline = self.timeline;
    pipPreview.editMode = self.editMode;
    [self.navigationController pushViewController:pipPreview animated:YES];
}

///返回按钮
///Back button
- (UIView *)leftNavigationBarItemView {
    UIButton *backButton;
    backButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"icon_back")];
    backButton.frame = CGRectMake(0, 0, 30, 44);
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15*SCREENSCALE, 0, 0);
    __weak typeof(self)weakSelf = self;
    [backButton nv_BtnClickHandler:^{
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    }];
    return backButton;
}
///生成按钮
///Generate button
- (void)rightBtnClicked {
    _compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NvCompileViewController *compileViewController = [NvCompileViewController new];
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compileTimeline:_timeline outputPath:_compileFilePath];
}
///添加数据
///Add data
- (void)initTimeline:(NvEditMode)model {
    self.editMode = model;
    self.timeline = [NvTimelineUtils createTimelineOrdinary:model];
    [self.timeline appendVideoTrack];
    
    __block BOOL isshowToast = NO;

    NvAlbumAsset * _Nonnull obj = self.selectAsset.firstObject;
    [self appendClip:obj ForTrack:[self.timeline getVideoTrackByIndex:0] containiCloud:&isshowToast];
    NvAlbumAsset * _Nonnull obj1 = self.selectAsset.lastObject;
    [self appendClip:obj1 ForTrack:[self.timeline getVideoTrackByIndex:1] containiCloud:&isshowToast];
    [self adjustTowTracks:[self.timeline getVideoTrackByIndex:0] otherVideoTrack:[self.timeline getVideoTrackByIndex:1]];
    if (isshowToast) {
        
        [UIAlertController presentAlertFromVC:self
                                        title:NvLocalString(@"Tips", @"提示")
                                      message:NvLocalString(@"album.iClould", @"所选资源在iCloud中")
                            buttonTitleColors:nil
                            cancelButtonTitle:nil
                             otherButtonTitle:NvLocalString(@"Know", @"知道了")
                           cancelButtonAction:nil
                            otherButtonAction:nil];
    }
}

- (void)initTimeline:(NvEditMode)model withCurrentTimeline:(NvsTimeline *)timeline {
    NvsVideoClip *currentClip = [[timeline getVideoTrackByIndex:0] getClipWithIndex:0];
    NSString *currentClipPath = currentClip.filePath;
    
    NvsVideoClip *otherClip = [[timeline getVideoTrackByIndex:1] getClipWithIndex:0];
    NSString *otherClipPath = otherClip.filePath;
    
    self.editMode = model;
    [_streamingContext removeTimeline:self.timeline];
    self.timeline = [NvTimelineUtils createTimelineOrdinary:model];
    [self.timeline appendVideoTrack];
    NvsVideoTrack *firstTrack = [self.timeline getVideoTrackByIndex:0];
    NvsVideoTrack *secondTrack = [self.timeline getVideoTrackByIndex:1];
    NvsVideoClip *firstClip = [firstTrack appendClip:currentClipPath];
    firstClip.imageMotionAnimationEnabled = NO;
    NvsVideoClip *secondClip = [secondTrack appendClip:otherClipPath];
    secondClip.imageMotionAnimationEnabled = NO;
}
#pragma mark - 添加clip
///Add clip
- (void)appendClip:(NvAlbumAsset *)obj ForTrack:(NvsVideoTrack *)track containiCloud:(BOOL *)contain {
    if (obj.isLivePhoto || obj.asset.mediaType == PHAssetMediaTypeVideo) {
        if (obj.isLivePhoto) {
            NvsVideoClip *clip = [track appendClip:obj.albumVideoPath];
            clip.imageMotionAnimationEnabled = NO;
            NvsVideoFx *fx = [clip appendBuiltinFx:@"Transform 2D"];
            [fx setAbsoluteTimeUsed:true];
            return;
        }
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
        __block NSString *localIdentifier = nil;
        [[PHImageManager defaultManager] requestAVAssetForVideo:obj.asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if (asset && [asset isKindOfClass:[AVURLAsset class]]) {
                localIdentifier = obj.asset.localIdentifier;
            } else {
                *contain = YES;
            }
            
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        if (localIdentifier) {
            NvsVideoClip *clip = [track appendClip:localIdentifier];
            clip.imageMotionAnimationEnabled = NO;
            NvsVideoFx *fx = [clip appendBuiltinFx:@"Transform 2D"];
            [fx setAbsoluteTimeUsed:true];
        }
    } else {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        options.resizeMode   = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        __block NSString *localIdentifier = nil;
        [[PHImageManager defaultManager] requestImageForAsset:obj.asset targetSize:CGSizeMake(80, 80) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL isIcloud =  [[info valueForKeyPath:@"PHImageResultIsInCloudKey"] boolValue];
            if (isIcloud) {
                *contain = YES;
            } else {
                localIdentifier = obj.asset.localIdentifier;
            }
        }];
        if (localIdentifier) {
            NvsVideoClip *clip = [track appendClip:localIdentifier];
            clip.imageMotionAnimationEnabled = NO;
            NvsVideoFx *fx = [clip appendBuiltinFx:@"Transform 2D"];
            [fx setAbsoluteTimeUsed:true];
        }
    }
}

#pragma mark 裁剪视频后调整对齐两个视频轨道
///Adjust and align the two video tracks after cropping the video
- (void)adjustTowTracks:(NvsVideoTrack *)currentVideoTrack otherVideoTrack:(NvsVideoTrack *)secondVideoTrack {
    NvsVideoClip *currentClip = [currentVideoTrack getClipWithIndex:0];
    NvsVideoClip *otherClip = [secondVideoTrack getClipWithIndex:0];
    NSString *currentClipFilePath = currentClip.filePath;
    NSString *otherClipFilePath = otherClip.filePath;
    ///先把每个轨道上多余的片段去除掉
    ///We're going to start by removing the extra bits from each track
    for (int i = 1; i < currentVideoTrack.clipCount; ++i) {
        NvsVideoClip *clip = [currentVideoTrack getClipWithIndex:i];
        [currentVideoTrack removeClip:clip.index keepSpace:NO];
        --i;
    }
    
    for (int i = 1; i < secondVideoTrack.clipCount; ++i) {
        NvsVideoClip *clip = [secondVideoTrack getClipWithIndex:i];
        [secondVideoTrack removeClip:clip.index keepSpace:NO];
        --i;
    }
    
    ///比较两个视频轨道的duration进行补齐
    ///Compare the duration of two video tracks to complete
    if (currentVideoTrack.duration > secondVideoTrack.duration) {
        int64_t a = currentVideoTrack.duration/secondVideoTrack.duration;
        for (int i = 1; i < a; ++i) {
            NvsVideoClip *clip = [secondVideoTrack appendClip:otherClipFilePath trimIn:otherClip.trimIn trimOut:otherClip.trimOut];
            clip.imageMotionAnimationEnabled = NO;
        }
        int64_t lastDuration = currentVideoTrack.duration - secondVideoTrack.duration;
        NvsVideoClip *clip = [secondVideoTrack appendClip:otherClipFilePath trimIn:otherClip.trimIn trimOut:otherClip.trimIn + lastDuration];
        clip.imageMotionAnimationEnabled = NO;
    } else {
        int64_t a = secondVideoTrack.duration/currentVideoTrack.duration;
        for (int i = 1; i < a; ++i) {
            NvsVideoClip *clip = [currentVideoTrack appendClip:currentClipFilePath trimIn:currentClip.trimIn trimOut:currentClip.trimOut];
            clip.imageMotionAnimationEnabled = NO;
        }
        int64_t lastDuration = secondVideoTrack.duration - currentVideoTrack.duration;
        NvsVideoClip *clip = [currentVideoTrack appendClip:currentClipFilePath trimIn:currentClip.trimIn trimOut:currentClip.trimIn + lastDuration];
        clip.imageMotionAnimationEnabled = NO;
    }
    
    ///应用模版特效
    ///Apply stencil effects
    NSString *fxIdFirst = (NSString *)[currentVideoTrack getAttachment:@"fxId"];
    for (int i = 1; i < currentVideoTrack.clipCount; i++) {
        NvsVideoClip *clip = [currentVideoTrack getClipWithIndex:i];
        
        NvsVideoFx *fx = [self getTransform2DWithClip:clip];
        if (!fx) {
            fx = [clip appendBuiltinFx:@"Transform 2D"];
        }
        [fx setAbsoluteTimeUsed:true];
        NvsVideoFx *firstFx = [clip appendPackagedFx:fxIdFirst];
        [firstFx setAbsoluteTimeUsed:true];
    }
    
    NSString *fxIdSecond = (NSString *)[secondVideoTrack getAttachment:@"fxId"];
    for (int i = 1; i < secondVideoTrack.clipCount; i++) {
        NvsVideoClip *clip = [secondVideoTrack getClipWithIndex:i];
        
        NvsVideoFx *fx = [self getTransform2DWithClip:clip];
        if (!fx) {
           fx = [clip appendBuiltinFx:@"Transform 2D"];
        }
        [fx setAbsoluteTimeUsed:true];
        
        NvsVideoFx *secFx = [clip appendPackagedFx:fxIdSecond];
        [secFx setAbsoluteTimeUsed:true];
    }
    
    ///应用Transform数据
    ///Apply Transform data
    NvsVideoFx *currentfx = [self getTransform2DWithClip:currentClip];
    for (int i = 1; i < currentVideoTrack.clipCount; ++i) {
        NvsVideoClip *clip = [currentVideoTrack getClipWithIndex:i];
        NvsVideoFx *fx = [self getTransform2DWithClip:clip];
        float transx = [currentfx getFloatVal:@"Trans X"];
        float transy = [currentfx getFloatVal:@"Trans Y"];
        [fx setFloatVal:@"Trans X" val:transx];
        [fx setFloatVal:@"Trans Y" val:transy];
        
        float scaleX = [currentfx getFloatVal:@"Scale X"];
        [fx setFloatVal:@"Scale X" val:scaleX];
        [fx setFloatVal:@"Scale Y" val:scaleX];
        
        float rotation = [currentfx getFloatVal:@"Rotation"];
        [fx setFloatVal:@"Rotation" val:rotation];
    }
    
    NvsVideoFx *otherfx = [self getTransform2DWithClip:otherClip];
    for (int i = 1; i < secondVideoTrack.clipCount; ++i) {
        NvsVideoClip *clip = [secondVideoTrack getClipWithIndex:i];
        NvsVideoFx *fx = [self getTransform2DWithClip:clip];
        float transx = [otherfx getFloatVal:@"Trans X"];
        float transy = [otherfx getFloatVal:@"Trans Y"];
        [fx setFloatVal:@"Trans X" val:transx];
        [fx setFloatVal:@"Trans Y" val:transy];
        
        float scaleX = [otherfx getFloatVal:@"Scale X"];
        [fx setFloatVal:@"Scale X" val:scaleX];
        [fx setFloatVal:@"Scale Y" val:scaleX];
        
        float rotation = [otherfx getFloatVal:@"Rotation"];
        [fx setFloatVal:@"Rotation" val:rotation];
    }
}

#pragma mark - 第一个音量按钮回调
///First volume button callback
- (void)firstTrackButtonClick:(UIButton *)button {
    NvsVideoTrack *firstTrack = [self.timeline getVideoTrackByIndex:0];
    if (button.selected) {
        [firstTrack setVolumeGain:1 rightVolumeGain:1];
    } else {
        [firstTrack setVolumeGain:0 rightVolumeGain:0];
    }
    
    button.selected = !button.selected;
}
#pragma mark - 第二个音量按钮回调
///Second volume button callback
- (void)secondTrackButtonClick:(UIButton *)button {
    NvsVideoTrack *secondTrack = [self.timeline getVideoTrackByIndex:1];
    if (button.selected) {
        [secondTrack setVolumeGain:1 rightVolumeGain:1];
    } else {
        [secondTrack setVolumeGain:0 rightVolumeGain:0];
    }
    
    button.selected = !button.selected;
}

- (void)rectView:(NvPIPWindowView *)rectView touchBeganPoint:(CGPoint)point {
    ///根据当前模式获取点击时的track
    ///Get the track at the time of the click based on the current mode
    if (self.selectIndex == 0) {
        CGRect topRect = CGRectMake(0, 0, self.liveWindow.bounds.size.width, self.liveWindow.bounds.size.height/2);
        CGRect bottomRect = CGRectMake(0, self.liveWindow.bounds.size.height/2, self.liveWindow.bounds.size.width, self.liveWindow.bounds.size.height/2);
        if (CGRectContainsPoint(topRect, point)) {
            self.currentTrack = [self.timeline getVideoTrackByIndex:0];
            NvsVideoClip *clip = [self.currentTrack getClipWithIndex:0];
            self.opView.hiddenCrop = !(clip.videoType == NvsVideoClipType_AV);
            self.pipRectView.hidden = NO;
            self.opView.hidden = NO;
            [self.pipRectView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.left.equalTo(@0);
                make.width.equalTo(@(self.liveWindow.bounds.size.width));
                make.height.equalTo(@(self.liveWindow.bounds.size.height/2));
            }];
            [self.opView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.pipRectView);
                make.bottom.equalTo(self.pipRectView);
            }];
            
        } else if (CGRectContainsPoint(bottomRect, point)) {
            self.currentTrack = [self.timeline getVideoTrackByIndex:1];
            NvsVideoClip *clip = [self.currentTrack getClipWithIndex:0];
            self.opView.hiddenCrop = !(clip.videoType == NvsVideoClipType_AV);
            self.pipRectView.hidden = NO;
            self.opView.hidden = NO;
            [self.pipRectView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@0);
                make.top.equalTo(@(self.liveWindow.bounds.size.height/2));
                make.width.equalTo(@(self.liveWindow.bounds.size.width));
                make.height.equalTo(@(self.liveWindow.bounds.size.height/2));
            }];
            [self.opView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.pipRectView);
                make.bottom.equalTo(self.pipRectView);
            }];
        }
    } else if (self.selectIndex == 1) {
        CGRect leftRect = CGRectMake(0, 0, self.liveWindow.bounds.size.width/2, self.liveWindow.bounds.size.height);
        CGRect rightRect = CGRectMake(self.liveWindow.bounds.size.width/2, 0, self.liveWindow.bounds.size.width, self.liveWindow.bounds.size.height);
        if (CGRectContainsPoint(leftRect, point)) {
            self.currentTrack = [self.timeline getVideoTrackByIndex:0];
            NvsVideoClip *clip = [self.currentTrack getClipWithIndex:0];
            self.opView.hiddenCrop = !(clip.videoType == NvsVideoClipType_AV);
            self.pipRectView.hidden = NO;
            self.opView.hidden = NO;
            [self.pipRectView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@0);
                make.top.equalTo(@(0));
                make.width.equalTo(@(self.liveWindow.bounds.size.width/2));
                make.height.equalTo(@(self.liveWindow.bounds.size.height));
            }];
            [self.opView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.pipRectView);
                make.bottom.equalTo(self.pipRectView);
            }];
        } else if (CGRectContainsPoint(rightRect, point)) {
            self.currentTrack = [self.timeline getVideoTrackByIndex:1];
            NvsVideoClip *clip = [self.currentTrack getClipWithIndex:0];
            self.opView.hiddenCrop = !(clip.videoType == NvsVideoClipType_AV);
            self.pipRectView.hidden = NO;
            self.opView.hidden = NO;
            [self.pipRectView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(self.liveWindow.bounds.size.width/2));
                make.top.equalTo(@(0));
                make.width.equalTo(@(self.liveWindow.bounds.size.width/2));
                make.height.equalTo(@(self.liveWindow.bounds.size.height));
            }];
            [self.opView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.pipRectView);
                make.bottom.equalTo(self.pipRectView);
            }];
        }
    } else if (self.selectIndex == 2) {
        CGRect leftTopRect = CGRectMake(0, 0, self.liveWindow.bounds.size.width*0.3, self.liveWindow.bounds.size.height*0.3);
        CGRect allRect = CGRectMake(0, 0, self.liveWindow.bounds.size.width, self.liveWindow.bounds.size.height);
        if (CGRectContainsPoint(leftTopRect, point)) {
            self.currentTrack = [self.timeline getVideoTrackByIndex:1];
            NvsVideoClip *clip = [self.currentTrack getClipWithIndex:0];
            self.opView.hiddenCrop = !(clip.videoType == NvsVideoClipType_AV);
            self.pipRectView.hidden = NO;
            self.opView.hidden = NO;
            [self.pipRectView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(0));
                make.top.equalTo(@(0));
                make.width.equalTo(@(self.liveWindow.bounds.size.width*0.3));
                make.height.equalTo(@(self.liveWindow.bounds.size.height*0.3));
            }];
            [self.opView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.pipRectView);
                make.bottom.equalTo(self.pipRectView);
            }];
        } else if (CGRectContainsPoint(allRect, point)) {
            self.currentTrack = [self.timeline getVideoTrackByIndex:0];
            NvsVideoClip *clip = [self.currentTrack getClipWithIndex:0];
            self.opView.hiddenCrop = !(clip.videoType == NvsVideoClipType_AV);
            self.pipRectView.hidden = NO;
            self.opView.hidden = NO;
            [self.pipRectView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(0));
                make.top.equalTo(@(0));
                make.width.equalTo(@(self.liveWindow.bounds.size.width));
                make.height.equalTo(@(self.liveWindow.bounds.size.height));
            }];
            [self.opView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.pipRectView);
                make.bottom.equalTo(self.pipRectView);
            }];
        }
    } else if (self.selectIndex == 3) {
        CGRect leftTopRect = CGRectMake(12*SCREENSCALE, 6, self.liveWindow.bounds.size.width/2, self.liveWindow.bounds.size.height/2);
        CGRect rightBottomRect = CGRectMake(self.liveWindow.bounds.size.width/2-12*SCREENSCALE, self.liveWindow.bounds.size.height/2-6, self.liveWindow.bounds.size.width/2, self.liveWindow.bounds.size.height/2);
        if (CGRectContainsPoint(leftTopRect, point)) {
            self.currentTrack = [self.timeline getVideoTrackByIndex:0];
            NvsVideoClip *clip = [self.currentTrack getClipWithIndex:0];
            self.opView.hiddenCrop = !(clip.videoType == NvsVideoClipType_AV);
            self.pipRectView.hidden = NO;
            self.pipRectView.frame = leftTopRect;
            self.opView.hidden = NO;
            [self.pipRectView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(12*SCREENSCALE));
                make.top.equalTo(@(6));
                make.width.equalTo(@(self.liveWindow.bounds.size.width/2));
                make.height.equalTo(@(self.liveWindow.bounds.size.height/2));
            }];
            [self.opView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.pipRectView);
                make.bottom.equalTo(self.pipRectView);
            }];
        } else if (CGRectContainsPoint(rightBottomRect, point)) {
            self.currentTrack = [self.timeline getVideoTrackByIndex:1];
            NvsVideoClip *clip = [self.currentTrack getClipWithIndex:0];
            self.opView.hiddenCrop = !(clip.videoType == NvsVideoClipType_AV);
            self.pipRectView.hidden = NO;
            self.opView.hidden = NO;
            [self.pipRectView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(self.liveWindow.bounds.size.width/2-12*SCREENSCALE));
                make.top.equalTo(@(self.liveWindow.bounds.size.height/2-6));
                make.width.equalTo(@(self.liveWindow.bounds.size.width/2));
                make.height.equalTo(@(self.liveWindow.bounds.size.height/2));
            }];
            [self.opView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.pipRectView);
                make.bottom.equalTo(self.pipRectView);
            }];
        }
    }
}

- (void)replace {
    NvAlbumViewController *album = [NvAlbumViewController new];
    album.delegate = self;
    album.mutableSelect = NO;
    album.hiddenSelectAll = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:album];
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)zoomIn {
    NvsVideoTrack *track = self.currentTrack;
    [self zoomInWith:track scale:1.25];
}

- (void)zoomOut {
    NvsVideoTrack *track = self.currentTrack;
    [self zoomOutWith:track scale:0.8];
}

- (void)rotate {
    NvsVideoTrack *track = self.currentTrack;
    [self rotationWith:track rotation:90];
}

- (void)cutVideo {
    NSLog(@"cutVideo");
    NvsVideoClip *clip = [self.currentTrack getClipWithIndex:0];
    NvCutVideoViewController *trimVideoVC = [[NvCutVideoViewController alloc] init];
    trimVideoVC.delegate = self;
    NvsTimeline *timeline = [NvTimelineUtils createTimelineOrdinary:NvEditMode9v16];
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    trimVideoVC.editMode = NvEditMode9v16;
    NvsVideoClip *trimVideoClip = [videoTrack appendClip:clip.filePath];
    trimVideoClip.imageMotionAnimationEnabled = NO;
    trimVideoVC.timeline = timeline;
    trimVideoVC.trimIn = clip.trimIn;
    trimVideoVC.trimOut = clip.trimOut;

    [self.navigationController pushViewController:trimVideoVC animated:YES];
}

- (void)zoomInWith:(NvsVideoTrack *)track scale:(float)scale {
    for (int i = 0; i < track.clipCount; i++) {
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NvsVideoFx *fx = [self getTransform2DWithClip:clip];
        if (!fx) {
            fx = [clip appendBuiltinFx:@"Transform 2D"];
        }
        float scale1 = [fx getFloatVal:@"Scale X"];
        [fx setFloatVal:@"Scale X" val:scale1*scale];
        [fx setFloatVal:@"Scale Y" val:scale1*scale];
        [fx setAbsoluteTimeUsed:true];
    }
    [self.streamingContext seekTimeline:self.timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}

- (void)zoomOutWith:(NvsVideoTrack *)track scale:(float)scale {
    for (int i = 0; i < track.clipCount; i++) {
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NvsVideoFx *fx = [self getTransform2DWithClip:clip];
        if (!fx) {
            fx = [clip appendBuiltinFx:@"Transform 2D"];
        }
        [fx setAbsoluteTimeUsed:true];
        float scale1 = [fx getFloatVal:@"Scale X"];
        [fx setFloatVal:@"Scale X" val:scale1*scale];
        [fx setFloatVal:@"Scale Y" val:scale1*scale];
        
    }
    [self.streamingContext seekTimeline:self.timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}

- (void)rotationWith:(NvsVideoTrack *)track rotation:(float)rotation {
    for (int i = 0; i < track.clipCount; i++) {
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NvsVideoFx *fx = [self getTransform2DWithClip:clip];
        if (!fx) {
            fx = [clip appendBuiltinFx:@"Transform 2D"];
        }
        [fx setAbsoluteTimeUsed:true];
        float rotation1 = [fx getFloatVal:@"Rotation"];
        rotation1 = rotation1-rotation;
        if (rotation1 <= -360) {
            rotation1 = rotation1 + 360;
        }
        [fx setFloatVal:@"Rotation" val:rotation1];
    }
    [self.streamingContext seekTimeline:self.timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}

- (NvsVideoFx *)getTransform2DWithClip:(NvsVideoClip *)clip {
    for(int i = 0;i<clip.fxCount;i++) {
        NvsVideoFx *fx = [clip getFxWithIndex:i];
        if ([fx.bultinVideoFxName isEqualToString:@"Transform 2D"] && fx.videoFxType == NvsVideoFxType_Builtin) {
            return fx;
        }
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 裁剪视频回调
///Crop the video callback
- (void)cutVideoViewController:(NvCutVideoViewController *)cutVideoViewController trimIn:(int64_t)trimIn trimOut:(int64_t)trimOut {
    NvsVideoClip *clip = [self.currentTrack getClipWithIndex:0];
    [clip changeTrimInPoint:trimIn affectSibling:YES];
    [clip changeTrimOutPoint:trimOut affectSibling:YES];
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    NvsVideoTrack *secondTrack;
    if (track == self.currentTrack) {
        secondTrack = [self.timeline getVideoTrackByIndex:1];
    } else {
        secondTrack = [self.timeline getVideoTrackByIndex:0];
        track = [self.timeline getVideoTrackByIndex:1];
    }
    [self adjustTowTracks:track otherVideoTrack:secondTrack];
    
    [self.streamingContext seekTimeline:self.timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}

#pragma mark - NvPIPRectViewDelegate
- (void)rectView:(NvPIPRectView*)rectView currentPoint:(CGPoint)currentPoint previousPoint:(CGPoint)previousPoint {
    CGPoint p1 = [self.liveWindow mapViewToCanonical:currentPoint];
    CGPoint p2 = [self.liveWindow mapViewToCanonical:previousPoint];
    for (int i = 0; i < self.currentTrack.clipCount; i++) {
        NvsVideoClip *clip = [self.currentTrack getClipWithIndex:i];
        NvsVideoFx *fx = [self getTransform2DWithClip:clip];
        float transx = [fx getFloatVal:@"Trans X"];
        float transy = [fx getFloatVal:@"Trans Y"];
        [fx setFloatVal:@"Trans X" val:transx+(p1.x-p2.x)];
        [fx setFloatVal:@"Trans Y" val:transy+(p1.y-p2.y)];
    }
    
    [self.streamingContext seekTimeline:self.timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}

#pragma mark - 相册回调
///Album callback
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    [self dismissViewControllerAnimated:YES completion:NULL];
    NvAlbumAsset *asset = assets.firstObject;
    
    ///两个轨道都先移除后添加
    ///Both tracks were removed before being added
    [self.currentTrack removeAllClips];
    
    BOOL isshowToast = NO;
    [self appendClip:asset ForTrack:self.currentTrack containiCloud:&isshowToast];
    NvsVideoClip *clip = [self.currentTrack getClipWithIndex:0];
    NSString *fxIdFirst = (NSString *)[self.currentTrack getAttachment:@"fxId"];
    NvsVideoFx *firstFx = [clip appendPackagedFx:fxIdFirst];
    [firstFx setAbsoluteTimeUsed:true];
    [self adjustTowTracks:[self.timeline getVideoTrackByIndex:0] otherVideoTrack:[self.timeline getVideoTrackByIndex:1]];
    
    self.opView.hiddenCrop = !(clip.videoType == NvsVideoClipType_AV);
    
    [self.streamingContext seekTimeline:self.timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}

- (void)nvAlbumViewControllerCancelClick:(NvAlbumViewController *)albumViewController {
    [albumViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - NvPIPThemeViewDelegate
- (void)nvPIPThemeViewOkClick:(NvPIPThemeView *)pipThemeView {
    self.pipThemeView.hidden = YES;
}
- (void)nvPIPThemeView:(NvPIPThemeView *)pipThemeView applyTemplate:(NvPIPThemeItem *)item {
     NSInteger index = [self.dataSource indexOfObject:item];
    if (self.selectIndex == index && self.initFirst == NO) {
        return;
    }
    self.initFirst = NO;
    self.selectIndex = index;
    ///隐藏矩形框和操作面板
    ///Hide the rectangle box and action panel
    self.pipRectView.hidden = YES;
    self.opView.hidden = YES;
    
    if ([item.name  isEqualToString:NvLocalString(@"UpDown", @"上下")]) {
//        [self initTimeline:NvEditMode9v16 withCurrentTimeline:self.timeline];
        self.liveWindow.frame = CGRectMake(64*SCREENSCALE, 0, SCREENWIDTH - 2*64*SCREENSCALE, (SCREENWIDTH - 2*64*SCREENSCALE) * 16.0/9);
    } else if ([item.name isEqualToString:NvLocalString(@"LeftRight", @"左右")]) {
//        [self initTimeline:NvEditMode1v1 withCurrentTimeline:self.timeline];
        self.liveWindow.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH);
    } else {
//        [self initTimeline:NvEditMode9v16 withCurrentTimeline:self.timeline];
        self.liveWindow.frame = CGRectMake(64*SCREENSCALE, 0, SCREENWIDTH - 2*64*SCREENSCALE, (SCREENWIDTH - 2*64*SCREENSCALE) * 16.0/9);
    }
    _pipWindow.frame = self.liveWindow.frame;
    [self adjustTowTracks:[self.timeline getVideoTrackByIndex:0] otherVideoTrack:[self.timeline getVideoTrackByIndex:1]];
    ///根据被选择的index更新音量按钮坐标
    ///Updates the volume button coordinates based on the selected index
    if (self.selectIndex == 0) {
        self.firstTrackButton.frame = CGRectMake(11*SCREENSCALE, 15*SCREENSCALE, 25*SCREENSCALE, 25*SCREENSCALE);
        self.secondTrackButton.frame = CGRectMake(11*SCREENSCALE, self.liveWindow.height/2+15*SCREENSCALE, 25*SCREENSCALE, 25*SCREENSCALE);
    } else if (self.selectIndex == 1) {
        self.firstTrackButton.frame = CGRectMake(11*SCREENSCALE, 15*SCREENSCALE, 25*SCREENSCALE, 25*SCREENSCALE);
        self.secondTrackButton.frame = CGRectMake(self.liveWindow.width/2 + 11*SCREENSCALE, 15*SCREENSCALE, 25*SCREENSCALE, 25*SCREENSCALE);
    } else if (self.selectIndex == 2) {
        self.firstTrackButton.frame = CGRectMake(self.liveWindow.width/2 + 11*SCREENSCALE, 15*SCREENSCALE, 25*SCREENSCALE, 25*SCREENSCALE);
        self.secondTrackButton.frame = CGRectMake(11*SCREENSCALE, 15*SCREENSCALE, 25*SCREENSCALE, 25*SCREENSCALE);
    } else if (self.selectIndex == 3) {
        self.firstTrackButton.frame = CGRectMake(self.liveWindow.width/2 + 11*SCREENSCALE, self.liveWindow.height/2 + 15*SCREENSCALE, 25*SCREENSCALE, 25*SCREENSCALE);
        self.secondTrackButton.frame = CGRectMake(11*SCREENSCALE, 15*SCREENSCALE, 25*SCREENSCALE, 25*SCREENSCALE);
    }
    ///更新音量按钮状态
    ///Updated the status of the volume button
    NvsVideoTrack *firstTrack = [self.timeline getVideoTrackByIndex:0];
    NvsVideoTrack *secondTrack = [self.timeline getVideoTrackByIndex:1];
    float firstTrackValum = 0;
    float secondTrackValum = 0;
    [firstTrack getVolumeGain:&firstTrackValum rightVolumeGain:&firstTrackValum];
    [secondTrack getVolumeGain:&secondTrackValum rightVolumeGain:&secondTrackValum];
    self.firstTrackButton.selected = firstTrackValum>0?NO:YES;
    self.secondTrackButton.selected = secondTrackValum>0?NO:YES;
    
//    [self.streamingContext connectTimeline:self.timeline withLiveWindow:self.liveWindow];
    [self.streamingContext seekTimeline:self.timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
    
    ///轨道2在轨道1上面
    ///Track 2 is on top of track 1
    NvsVideoTrack *firstVideoTrack = [self.timeline getVideoTrackByIndex:0];
    NvsVideoTrack *lastVideoTrack = [self.timeline getVideoTrackByIndex:1];
    for (int i = 0; i < firstVideoTrack.clipCount; i++) {
        NvsVideoClip *clip1 = [firstVideoTrack getClipWithIndex:i];
        [clip1 removeAllFx];
        [clip1 appendBuiltinFx:@"Transform 2D"];
        [clip1 appendPackagedFx:item.packageId1];
    }
    [firstVideoTrack setAttachment:item.packageId1 forKey:@"fxId"];
    
    for (int i = 0; i < lastVideoTrack.clipCount; i++) {
        NvsVideoClip *clip2 = [lastVideoTrack getClipWithIndex:i];
        [clip2 removeAllFx];
        [clip2 appendBuiltinFx:@"Transform 2D"];
        [clip2 appendPackagedFx:item.packageId2];
    }
    [lastVideoTrack setAttachment:item.packageId2 forKey:@"fxId"];
    
    
    [self.streamingContext seekTimeline:self.timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}

#pragma mark - NvCompileViewControllerDelegate
- (void)compileFinished:(BOOL)needDelete {
    NVWeakSelf
    if (needDelete) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
            [[NSFileManager defaultManager] removeItemAtPath:weakSelf.compileFilePath error:nil];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
            UISaveVideoAtPathToSavedPhotosAlbum(weakSelf.compileFilePath, weakSelf, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        });
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}

@end
