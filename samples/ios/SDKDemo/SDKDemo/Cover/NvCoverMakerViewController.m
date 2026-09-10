//
//  NvCoverMakerViewController.m
//  SDKDemo
//
//  Created by meicam on 2020/10/19.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvCoverMakerViewController.h"
#import "NvTimelineUtils.h"
#import "NvsStreamingContext.h"
#import "NvsTimeline.h"
#import "NvsVideoTrack.h"
#import "NvsVideoClip.h"
#import "NvsTimelineVideoFx.h"
#import "NvsVideoFx.h"

#import "NvFilterView.h"
#import <NvSDKCommon/NvAssetManager.h>
#import "NvCaptureFilterModel.h"
#import "NvMoreFilterViewController.h"
#import "NvLineRectView.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvFilterDataSource.h"

@interface NvCoverMakerViewController ()<NvCaptureFilterViewDelegate>

@property (nonatomic, strong) NvsVideoTrack *videoTrack;
@property (nonatomic, strong) NvsVideoClip *clip;
@property (nonatomic, strong) NvFilterView *filterView;
@property (nonatomic, strong) NvAssetManager *assetManager;
///当前滤镜
///Current filter
@property (nonatomic, strong) NvsTimelineVideoFx *currentFx;
///当前model，用于保存到数据结构，和展示的NvCaptureFilterModel不一样
///The current model, which is used to save to the data structure, is different from the NvCaptureFilterModel shown
@property (nonatomic, strong) NvTimeFilterInfoModel *currentInfoModel;
@property (nonatomic, strong) NvLineRectView *rectView;
@property (nonatomic, strong) NvsVideoFx *tranform2D;
@property (nonatomic, strong) UIButton *compileButton;
@end

@implementation NvCoverMakerViewController

- (void)dealloc {
    NSLog(@"%s",__func__);
    [self.streamingContext stop];
    NSLog(@"%d",[self.streamingContext getStreamingEngineState]);
    [self.streamingContext clearCachedResources:NO];
    
}

- (void)viewDidLoad {
    self.timeline = [NvTimelineUtils createTimelineOrdinary:self.editMode];
    self.liveWindowPanel.liveWindow.hdrDisplayMode = NvsLiveWindowHDRDisplayMode_SDR;
    [self initTimelineData];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NvLocalString(@"EditVideo", @"视频编辑");
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.assetManager = [NvAssetManager sharedInstance];
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"filter" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_FILTER bundlePath:itemPath];
    [self.assetManager searchLocalAssets:ASSET_FILTER];
    
    self.currentInfoModel = [[NvTimeFilterInfoModel alloc]init];

    [self addSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.assetManager setAssetInfoToUserDefaults:ASSET_FILTER];
    [self connectLiveWindow];
    [self.filterView reloadDataWithSelectedModel:self.currentInfoModel];
}

- (UIView *)rightNavigationBarItemView {
    self.compileButton = [UIButton nv_buttonWithTitle:NvLocalString(@"Compile", @"生成") textColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] fontSize:16 image:nil];
    self.compileButton.frame = CGRectMake(0, 0, 30, 44);
    self.compileButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15*SCREENSCALE);
    [self.compileButton addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.compileButton.exclusiveTouch = YES;
    return self.compileButton;
}

#pragma mark 连接预览窗口并且播放
///Connect the preview window and play
- (void)connectLiveWindow {
    [self.liveWindowPanel connectTimeline:self.timeline];
    [self seekTimeline:self.liveWindowPanel.currentTime];
}

/**
 需要改动子类需要重写这个方法
 You need to change the subclass you need to override this method
 @return 需要显示的返回按钮
 The back button that needs to be displayed
 */
- (UIView *)leftNavigationBarItemView {
    UIButton *backButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:15 image:[UIImage imageNamed:@"icon_back"]];
    backButton.frame = CGRectMake(0, 0, 30, 44);
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15*SCREENSCALE, 0, 0);
    __weak typeof(self)weakSelf = self;
    __weak typeof(NvsTimeline*)weakTimeline = self.timeline;
    [backButton nv_BtnClickHandler:^{
        [weakSelf.streamingContext removeTimeline:weakTimeline];
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    }];
    return backButton;
}

- (void)initTimelineData {
    self.videoTrack = [self.timeline getVideoTrackByIndex:0];
    for (NvAlbumAsset *asset in self.selectAssets) {
        if (asset.asset.mediaType == PHAssetMediaTypeVideo) {
            self.clip = [self.videoTrack appendClip:asset.asset.localIdentifier];
        } else if (asset.asset.mediaType == PHAssetMediaTypeImage) {
            self.clip = [self.videoTrack appendClip:asset.asset.localIdentifier];
            [self.clip changeTrimOutPoint:10*NV_TIME_BASE affectSibling:true];
        }
        self.tranform2D = [self.clip appendBuiltinFx:@"Transform 2D"];
        [self.tranform2D setAbsoluteTimeUsed:true];
    }
}

- (void)rightBtnClicked {
    UIImage *image = [self.streamingContext grabImageFromTimeline:self.timeline timestamp:[self.streamingContext getTimelineCurrentPosition:self.timeline] proxyScale:nil flags:0];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [NvToast showInfoWithMessage:NvLocalString(@"storage", @"请检查手机存储空间")];
    } else {
        [NvToast showInfoWithMessage:NvLocalString(@"Save Succecs!", @"保存成功!")];
    }
}

#pragma mark 添加子视图
///Add subview
- (void)addSubViews{
    [self.liveWindowPanel removeTapScreenPause];
    self.rectView = [[NvLineRectView alloc] initWithFrame:self.liveWindowPanel.bounds];
    self.rectView.hiddenRectLine = YES;
    [self.liveWindowPanel addSubview:self.rectView];
    [self.liveWindowPanel bringSubviewToFront:self.liveWindowPanel.controlPanelView];
    self.rectView.delegate = self;
    [self.liveWindowPanel setAlwaysShowControlPanel:true];
    [self.liveWindowPanel hiddenVolumeButton];
    NvButton *button= [NvButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:button];
    [button setTitle:NvLocalString(@"Reset", @"重置") forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [NvUtils regularFontWithSize:12];
    button.backgroundColor = [UIColor colorWithRed:74.0/255 green:144.0/255 blue:226.0/255 alpha:1];
    [button addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 13.5;
    button.layer.masksToBounds = true;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-12.5));
        make.top.equalTo(self.liveWindowPanel.mas_bottom).offset(12.5);
        make.width.equalTo(@62);
        make.height.equalTo(@27);
    }];
    self.filterView = [NvFilterView coverFilterViewWithAspectRatio:AspectRatio_All delegate:self];
    [self.view addSubview:self.filterView];
    CGRect frame = self.filterView.frame;
    frame.origin.y = self.view.frame.size.height - NV_STATUSBARHEIGHT - 44 - frame.size.height;
    self.filterView.frame = frame;
    [self.filterView backColor:UIColor.clearColor];
}

- (void)reset {
    [self.tranform2D setFloatVal:@"Scale X" val:1];
    [self.tranform2D setFloatVal:@"Scale Y" val:1];
    [self.tranform2D setFloatVal:@"Rotation" val:0];
    [self.tranform2D setFloatVal:@"Trans X" val:0];
    [self.tranform2D setFloatVal:@"Trans Y" val:0];
    [self seekTimeline];
}

#pragma mark 某个点是否包含贴纸或字幕
///Whether a point contains stickers or subtitles
- (BOOL)containObjectForPoint:(CGPoint)point {
    return true;
}

#pragma mark 手指按住的两个点是否是一个字幕或贴纸对象
///Whether the two points the finger is holding are a subtitle or sticker object
- (BOOL)containSameObjectForPoint:(CGPoint)point otherPoint:(CGPoint)otherPoint {
    return true;
}

#pragma mark 手势缩放
///Gesture zoom
- (void)gestureRectViewPinchScale:(float)scale {
    [self.tranform2D setFloatVal:@"Scale X" val:scale * [self.tranform2D getFloatVal:@"Scale X"]];
    [self.tranform2D setFloatVal:@"Scale Y" val:scale * [self.tranform2D getFloatVal:@"Scale Y"]];
    [self seekTimeline];
}

#pragma mark 手势旋转
///Gesture rotation
- (void)gestureRectViewRotation:(float)rotation {
    float rotation1 = [self.tranform2D getFloatVal:@"Rotation"];
    rotation1 = rotation1+rotation;

    [self.tranform2D setFloatVal:@"Rotation" val:rotation1];
    [self seekTimeline];
}

#pragma mark 手势平移
///Gesture translation
- (void)lineRectView:(NvLineRectView *)lineRectView currentPoint:(CGPoint)currentPoint previousPoint:(CGPoint)previousPoint {
    CGPoint p1 = [self.liveWindowPanel.liveWindow mapViewToCanonical:currentPoint];
    CGPoint p2 = [self.liveWindowPanel.liveWindow mapViewToCanonical:previousPoint];
    float transx = [self.tranform2D getFloatVal:@"Trans X"];
    float transy = [self.tranform2D getFloatVal:@"Trans Y"];
    [self.tranform2D setFloatVal:@"Trans X" val:transx+(p1.x-p2.x)];
    [self.tranform2D setFloatVal:@"Trans Y" val:transy+(p1.y-p2.y)];
    [self seekTimeline];
}

#pragma mark - NvCaptureFilterViewDelegate
- (void)NvCaptureFilterView:(NvCaptureFilterView *)view withFilterModel:(NvBaseModel *)model{
    NvCaptureFilterModel *filterModel = (NvCaptureFilterModel *)model;

    self.currentInfoModel.grayscale = filterModel.grayscale;
    self.currentInfoModel.strokeOnly = filterModel.strokeOnly;
    self.currentInfoModel.strength = 1;
    
    if (![model.displayName isEqualToString:NvLocalString(@"None", @"无")]) {
        
        self.currentInfoModel.name = model.builtinName?model.builtinName:model.packageId;
    }else{
        
        self.currentInfoModel.name = NvLocalString(@"None", @"无");
    }
    self.currentInfoModel.strokeOnly = filterModel.strokeOnly;
    self.currentInfoModel.grayscale = filterModel.grayscale;
    [self resetTimelineFilter:self.timeline filterData:self.currentInfoModel];
    self.currentFx = [self.timeline getFirstTimelineVideoFx];
    if (self.streamingContext.getStreamingEngineState != NvsStreamingEngineState_Playback) {
        [self.liveWindowPanel playBackStart:[self.streamingContext getTimelineCurrentPosition:self.timeline] end:self.timeline.duration];
    }
}

- (void)NvCaptureFilterView:(NvCaptureFilterView *)view sliderValueChanged:(UISlider *)slider{
    self.currentInfoModel.strength = slider.value;
    NvsTimelineVideoFx *firstFx = [self.timeline getFirstTimelineVideoFx];
    [firstFx setFilterIntensity:self.currentInfoModel.strength];
    
    if (self.streamingContext.getStreamingEngineState != NvsStreamingEngineState_Playback) {
        [self seekTimeline:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
    }
    
}

- (void)NvCaptureFilterView:(NvCaptureFilterView *)view moreClick:(UIButton *)sender{
    NvMoreFilterViewController *vc = [[NvMoreFilterViewController alloc]init];
    vc.editModel = self.editMode;
    vc.type = ASSET_FILTER;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)seekTimeline:(int64_t)postion {
    if (![self.streamingContext seekTimeline:self.timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|
          NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame]){
        
    }
}

- (void)resetTimelineFilter:(NvsTimeline *)timeline filterData:(NvTimeFilterInfoModel *)timelineFilterModel {
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    NvsVideoClip *firstClip = [videoTrack getClipWithIndex:0];
    NvsVideoClip *lastClip = [videoTrack getClipWithIndex:videoTrack.clipCount -1 ];
    
    ///判断是不是主题片头、片尾数据
    ///Determine whether it is the subject title data, the end of the title data
    int64_t timelineFilterStartPoint = 0;
    int64_t timelineFilterEndPoint = timeline.duration;
    if (firstClip.roleInTheme == NvsRoleInThemeTitle) {
        timelineFilterStartPoint = firstClip.outPoint;
    }
    if (lastClip.roleInTheme == NvsRoleInThemeTrailer) {
        timelineFilterEndPoint = lastClip.inPoint;
    }
    NvsTimelineVideoFx *nextFx = [timeline getFirstTimelineVideoFx];
    while (nextFx) {
        nextFx = [timeline removeTimelineVideoFx:nextFx];
    }

    if ([NvSDKUtils isBuiltinFilter:timelineFilterModel.name]) {
       NvsTimelineVideoFx *newTimelineFilter = [timeline addBuiltinTimelineVideoFx:timelineFilterStartPoint duration:timelineFilterEndPoint videoFxName:timelineFilterModel.name];
        [newTimelineFilter setFilterIntensity:timelineFilterModel.strength];
        if ([timelineFilterModel.name isEqualToString:@"Cartoon"]) {
            [newTimelineFilter setBooleanVal:@"Stroke Only" val:timelineFilterModel.strokeOnly];
            [newTimelineFilter setBooleanVal:@"Grayscale" val:timelineFilterModel.grayscale];
        }
    }else{
       NvsTimelineVideoFx *newTimelineFilter = [timeline addPackagedTimelineVideoFx:timelineFilterStartPoint duration:timelineFilterEndPoint videoFxPackageId:timelineFilterModel.name];
        [newTimelineFilter setFilterIntensity:timelineFilterModel.strength];
    }
    
}

@end
