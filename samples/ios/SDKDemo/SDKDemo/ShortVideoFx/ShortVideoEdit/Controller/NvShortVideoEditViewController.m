//
//  NvShortVideoEditViewController.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/8/31.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvShortVideoEditViewController.h"
#import "NvShortVideoEditView.h"
#import <NvSDKCommon/NvUtils.h>
#import "NvTimelineUtils.h"
#import "NvTimelineData.h"
#import "YYModel.h"
#import "NvFileConvert.h"
#import "NvsTimelineVideoFx.h"
#import "NvRecordingInfo.h"
#import "NvsVideoClip.h"
#import <NvSDKCommon/NvCompileViewController.h>
#import "NvTipsView.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import <NvSDKCommon/NvAssetManager.h>
#import "NvFilterFxModel.h"
#import <NvBaseCommon/UIButton+NvButton.h>
#import <NvBaseCommon/UIView+Dimension.h>
#import <NvBaseCommon/NvToast.h>

@interface NvShortVideoEditViewController () <NvsStreamingContextDelegate, NvShortVideoEditViewDelegate, NvCompileViewControllerDelegate, NvAssetManagerDelegate>

@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, strong) NvFileConvert *fileConvert;

//是否是长按添加滤镜的状态
//under the long press state to add filter whether or not
@property (nonatomic, assign) BOOL isAddFx;

//用于记录每次添加录制的数据
//record the data of recording each time
@property (nonatomic, strong) NSMutableArray *fxInfoArray;

//去掉重复的数据
//remove the duplicate data
@property (nonatomic, strong) NSMutableArray *fxNewArray;

//去掉重复的倒放数据
//remove the duplicate of revert data
@property (nonatomic, strong) NSMutableArray *fxRevertArray;

//转码是否完成
//the indicate of whether the convertion is finish or not
@property (atomic, assign) BOOL convertFinish;

//是否正在动画
//is in animtion now
@property (atomic, assign) BOOL isAnimation;

//是否是时间特效
//is fx of timing
@property (atomic, assign) BOOL isTimeFx;

//当前正在播放的位置
//the current time of playing
@property (atomic, assign) int64_t currentPlayTime;

//当前转码时的实际状态
//the type of current convertion
@property (assign, nonatomic) NvTimelineType type;

//当前选择的状态
//the type of current seletion
@property (assign, nonatomic) NvTimelineType currentSelectType;

@property (nonnull, strong) NSString *compileFilePath;

@property (nonatomic, strong) NvAssetManager *assetManager;

@property (strong, nonatomic) NSMutableArray <NvFilterFxModel*> *videoFxDataSource;

//是否有字体列表
//has the font list or not
@property (nonatomic, assign) BOOL isHaveList;

//用于颜色控件
//be used in color controls
@property (nonatomic, strong) NSMutableArray *uuids;
@property (nonatomic, assign) NvEditMode editMode;

@property (nonatomic, assign) BOOL isChange;
@property (nonatomic, assign) CGFloat scaleForSeek;
@property (nonatomic, strong) UIButton *compileButton;
@end

@implementation NvShortVideoEditViewController {
    NvShortVideoEditView *contentView;
    NvsStreamingContext *context;
    NvTimeFilterInfoModel *currentFilterModel;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self prefersStatusBarHidden];
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.fxInfoArray = [NSMutableArray array];
    //为倒放转码
    //convert for reverse
    [self convert];
    self.view.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    contentView = [[NvShortVideoEditView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - NV_STATUSBARHEIGHT - 44)];
    contentView.delegate = self;
    [self.view addSubview:contentView];
    contentView.revertBtn.hidden = YES;
    self.editMode = NvEditMode9v16;
    context = [NvsStreamingContext sharedInstance];
    self.timeline = [NvTimelineUtils createTimelineOrdinary:self.editMode];
    [self addClips:self.videoPathArray toTimeline:self.timeline];
    
    if (![context connectTimeline:self.timeline withLiveWindow:contentView.getLiveWindow]) {
    }
    
    context.delegate = self;
    [NvTimelineUtils seekTimeline:_timeline timestamp:0 flags:NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
    [contentView setupEffectWrapper:[NvTimelineUtils getThumbnailSequenceDescArray:self.timeline] duration:self.timeline.duration];
    [contentView setupTimelineEditor:[NvTimelineUtils getThumbnailSequenceDescArray:self.timeline] duration:self.timeline.duration];
    contentView.delegate = self;
    
    self.videoFxDataSource = [NSMutableArray array];
    NSString *packagePath = [[NSBundle mainBundle] pathForResource:@"shortVideoPackage" ofType:@"bundle"];
    NSString *jsonPath = [packagePath stringByAppendingPathComponent:@"fx.json"];
    NSString *jsontext = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
    NSData *data =[jsontext dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    self.uuids = [NSMutableArray array];
    for (int i = 0; i < array.count; i++) {
        NSDictionary *dic = array[i];
        NvFilterFxModel *item = [NvFilterFxModel new];
        item.imagePath = [packagePath stringByAppendingPathComponent:dic[@"imageName"]];
        item.coverName = dic[@"imageName"];
        [self.uuids addObject:dic[@"fxid"]];
        if (i == array.count - 1) {
            item.builtinName = dic[@"fxid"];
            item.packageId = dic[@"fxid"];
        } else {
            item.packageId = dic[@"fxid"];
        }
        item.displayName = dic[@"name"];
        item.selected = NO;
        item.state = Finish;
        [self.videoFxDataSource addObject:item];
    }
    contentView.videoFxDataSource = self.videoFxDataSource;
    contentView.effectWrapper.colorBarView.allUUids = self.uuids;
    self.assetManager = [NvAssetManager sharedInstance];
    self.assetManager.delegate = self;
//    [self.assetManager downloadRemoteAssetsInfo:ASSET_FILTER aspectRatio:AspectRatio_All categoryId:7 page:0 pageSize:100];
    
    [self.assetManager downloadRemoteAssetsInfo:ASSET_FILTER categoryId:2 page:1 pageSize:200 kind:4 modular:NvAssetModularAll ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NvSDKUtils getSdkVersion]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NvsStreamingContext sharedInstance] setDelegate:self];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (UIView *)leftNavigationBarItemView {
    UIButton *back = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvback")];
    back.frame = CGRectMake(0, 0, 30, 44);
    back.imageEdgeInsets = UIEdgeInsetsMake(0, -15*SCREENSCALE, 0, 0);
    __weak typeof(self)weakSelf = self;
    [back nv_BtnClickHandler:^{
        [weakSelf backBtnClicked];
    }];
    return back;
}

- (void)backBtnClicked {
    [context stop];
    context.delegate = nil;
    [self.fileConvert cancel];
    self.fileConvert = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)rightNavigationBarItemView {
    self.compileButton = [UIButton nv_buttonWithTitle:NvLocalString(@"Compile", @"生成") textColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] fontSize:16 image:nil];
    self.compileButton.frame = CGRectMake(0, 0, 30, 44);
    self.compileButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15*SCREENSCALE);
    [self.compileButton addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.compileButton.exclusiveTouch = YES;
    return self.compileButton;
}

- (void)rightBtnClicked {
    _compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NvCompileViewController *compileViewController = [NvCompileViewController new];
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compileTimeline:self.timeline outputPath:_compileFilePath];
}

#pragma mark 添加clip
///add clips to timeline
- (void)addClips:(NSArray <NvRecordingInfo *>*)clips toTimeline:(NvsTimeline *)timeline {
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    NvsAudioTrack *audioTrack = [timeline getAudioTrackByIndex:0];
    
    for (NvRecordingInfo *info in clips) {
        NvsVideoClip *clip;
        if (info.asset!=nil) {
            clip = [videoTrack appendClip:info.asset.localIdentifier trimIn:info.trimIn trimOut:info.trimOut];
            [clip setExtraVideoRotation:info.rotaion];
        } else {
            if (info.recordingPath) {
                clip = [videoTrack appendClip:info.recordingPath];
                [clip setExtraVideoRotation:info.rotaion];
            } else {
                clip = [videoTrack appendClip:info.convertPath];
                [clip setExtraVideoRotation:info.rotaion];
            }
        }
        [clip changeSpeed:info.speed];
    }
    
    int64_t audioDuration = audioTrack.duration;
    if (self.musicPath) {
        while (audioDuration < videoTrack.duration) {
            [audioTrack appendClip:self.musicPath trimIn:self.trimIn trimOut:self.trimOut];
            audioDuration = audioTrack.duration;
        }
    }
    
    int count = videoTrack.clipCount-1;
    if (count < 1) {
        return;
    }
    for (int i = 0; i < count; i++) {
        [videoTrack setBuiltinTransition:i withName:NULL];
    }
    
}

/// 定位某一时间戳的图像
/// seekTimeline to position
- (void)seekTimeline:(int64_t)postion {
    if (postion < 0) {
        postion = [context getTimelineCurrentPosition:self.timeline];
    }
    int flag = 0;
    flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (self.isChange) {
        flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing;
        self.scaleForSeek = self.timeline.duration / 1000000 /  [contentView.timelineEditor getTimelineEditorWidth] / UIScreen.mainScreen.scale;
        [context setTimeline:self.timeline scaleForSeek:0];
    }
    if (![context seekTimeline:self.timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag])
        NSLog(@"定位时间线失败！Failed to seek timeline!");
    
    contentView.isAddFilterFx = self.timeline.duration == postion?NO:YES;
    NSLog(@"seekTime:%lld",postion);
}

///更新颜色控件
///update the colorbar view
- (void)updateColorBarView:(NSMutableArray *)fxNewArray {
    [contentView.effectWrapper.colorBarView clearCurrentArray];
    
    for (int i = 0; i < fxNewArray.count; i++) {
        NvTimeFilterInfoModel *info = [fxNewArray objectAtIndex:i];
        int64_t inPoint = info.inPoint;
        int64_t outPoint = info.outPoint;
        NSString *fxUUID = info.name;
        if (!fxUUID) {
            fxUUID = info.name;
        }
        [contentView.effectWrapper.colorBarView addToCurrentArray:fxUUID inPoint:inPoint outPoint:outPoint];
    }

    [contentView.effectWrapper.colorBarView updateSubviewsByCurrentArray:NO withColor:nil];
}

#pragma mark NvShortVideoEditViewDelegate
- (void)cancelBtnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)canStart {
    int64_t currentTime = [context getTimelineCurrentPosition:self.timeline];
    if (currentTime + 40000 >= self.timeline.duration) {
        return false;
    } else {
        return true;
    }
}

#pragma mark - 开始滤镜
///开始添加指定滤镜效果
///start to add the target filter into timeline
///@param filterId 滤镜id
///filterId the id of the target filter
- (void)startFilter:(NSString *)filterId {
    self.isChange = YES;
    self.scaleForSeek = self.timeline.duration / 1000000 /  [contentView.timelineEditor getTimelineEditorWidth] / UIScreen.mainScreen.scale;
    ///设置颜色控件开始绘制的位置
    ///Sets where the color control starts painting
    int64_t currentTime = [context getTimelineCurrentPosition:self.timeline];
    if (self.type == NvTimelineType_PlayRevert) {
        contentView.effectWrapper.colorBarView.timelineStartPosition = self.timeline.duration - currentTime;
    } else {
        contentView.effectWrapper.colorBarView.timelineStartPosition = currentTime;
    }
    float posX = contentView.effectWrapper.sliderView.value * SCREENWIDTH;
    __block NSUInteger index = 0;
    [self.videoFxDataSource enumerateObjectsUsingBlock:^(NvFilterFxModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.packageId isEqualToString:filterId]) {
            index = idx;
        }
    }];
    NSString *color = [NvSDKUtils getColorWithIndex:index];
    [contentView.effectWrapper.colorBarView addBar:posX width:0 color:color fxUuid:filterId];
    
    NvTimeFilterInfoModel *filterModel = NvTimeFilterInfoModel.new;
    filterModel.name = filterId;
    filterModel.inPoint = [context getTimelineCurrentPosition:self.timeline];
    filterModel.outPoint = self.timeline.duration - filterModel.inPoint;
    currentFilterModel = filterModel;
    if (self.type == NvTimelineType_PlayRevert) {
        ///如果是倒放
        ///If I do it backwards
        self.isAddFx = YES;
        
        ///先移除所有特效
        ///Remove all effects first
        [self removeAllTimelineFx:self.timeline];
        ///重新添加特效
        ///Re-add effects
        [self addFx:self.timeline withPackgeId:filterId];
        
        ///播放
        ///play
        if (context.getStreamingEngineState != NvsStreamingEngineState_Playback) {
            [NvTimelineUtils playbackTimeline:self.timeline startTime:currentTime endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
        }
    } else {
        self.isAddFx = YES;
        ///先移除所有特效
        ///Remove all effects first
        [self removeAllTimelineFx:self.timeline];
        ///重新添加特效
        ///Re-add effects
        [self addFx:self.timeline withPackgeId:filterId];
        if (context.getStreamingEngineState != NvsStreamingEngineState_Playback) {
            [NvTimelineUtils playbackTimeline:self.timeline startTime:[context getTimelineCurrentPosition:self.timeline] endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
        }
    }
}

#pragma mark - 结束滤镜
///添加滤镜结束
///end to expand current filter
- (void)stopFilter {
    self.isChange = NO;
    [self seekTimeline:[context getTimelineCurrentPosition:self.timeline]];
    [context stop];
    contentView.revertBtn.hidden = NO;
    self.isAddFx = NO;
    currentFilterModel.outPoint = [context getTimelineCurrentPosition:self.timeline];
    
    int64_t timeDuration = self.timeline.duration - currentFilterModel.outPoint;
    if (timeDuration <= 40000) {
        currentFilterModel.outPoint = self.timeline.duration;
    }
    
    //生成新的数组过滤后的不重叠的
    //create new array which all the elements are different
    NvTimeFilterInfoModel *model = [self revertModel:currentFilterModel timeline:self.timeline];
    if (self.type == NvTimelineType_PlayRevert) {
        //移除所有特效根据记录数据添加特效
        //remove all the fx has added into timeline, then add fx according the recorded datas
        [self removeAllTimelineFx:self.timeline];
        
        //生成新的数组过滤后的不重叠的
        //create new array which all the elements are different
        self.fxNewArray = [self filterModele:self.fxNewArray withNewModel:model];
        self.fxRevertArray = [self filterModele:self.fxRevertArray withNewModel:currentFilterModel];
        //添加fx
        //add fx
        [self addFxsWithNewArray:self.fxRevertArray withTimeline:self.timeline];
        
    } else {
        //移除所有特效根据记录数据添加特效
        //remove all the fx has added into timeline, then add fx according the recorded datas
        [self removeAllTimelineFx:self.timeline];
        //生成新的数组过滤后的不重叠的
        //create new array which all the elements are different
        self.fxNewArray = [self filterModele:self.fxNewArray withNewModel:currentFilterModel];
        self.fxRevertArray = [self filterModele:self.fxRevertArray withNewModel:model];
        //添加fx
        //add fx
        [self addFxsWithNewArray:self.fxNewArray withTimeline:self.timeline];
        
    }

    //记录历史操作
    //record history operation
    [self.fxInfoArray addObject:[[NSMutableArray alloc] initWithArray:self.fxNewArray copyItems:YES]];
    //更新colorbarUI
    //update the colorbar
    [self updateColorBarView:self.fxNewArray];
}

#pragma mark 撤销滤镜按钮点击
///Cancel the last time operation of adding filter by clicking the cancel filter button
- (void)revertClick {
    if (self.fxInfoArray.count == 1) {
        NSMutableArray *arr = self.fxInfoArray.firstObject;
        NvTimeFilterInfoModel *model = arr.firstObject;
        int64_t seekTime = model.inPoint;
        if (self.type == NvTimelineType_PlayRevert) {
            seekTime = model.outPoint;
            [self seekTimeline:self.timeline.duration - seekTime];
            contentView.effectWrapper.sliderView.value = (float)seekTime/self.timeline.duration;
        } else {
            [self seekTimeline:seekTime];
            contentView.effectWrapper.sliderView.value = (float)seekTime/self.timeline.duration;
        }
    }
    [self.fxInfoArray removeLastObject];
    self.fxNewArray = self.fxInfoArray.lastObject;
    self.fxRevertArray = [self revertModelWith:self.fxNewArray withTimeline:self.timeline];
    //移除所有特效根据记录数据添加特效
    //remove all the fx that has been added into timeline
    [self removeAllTimelineFx:self.timeline];
    //添加fx
    //then readd the fxs according the removed last element datasource
    if (self.type == NvTimelineType_PlayRevert) {
        [self addFxsWithNewArray:self.fxRevertArray withTimeline:self.timeline];
    } else {
        [self addFxsWithNewArray:self.fxNewArray withTimeline:self.timeline];
    }
    //更新控件
    //update the colorbarview
    [self updateColorBarView:self.fxNewArray];
    
    if (self.fxInfoArray.count > 0) {
        int64_t seekTime = [[contentView.effectWrapper.colorBarView.currentTimelineEndPositionArray lastObject] longLongValue];
        if (self.type == NvTimelineType_PlayRevert) {
            NvTimeFilterInfoModel *model = [self.fxNewArray lastObject];
            seekTime = model.inPoint;
            [self seekTimeline:self.timeline.duration - seekTime];
            contentView.effectWrapper.sliderView.value = (float)seekTime/self.timeline.duration;
        } else {
            [self seekTimeline:seekTime];
            contentView.effectWrapper.sliderView.value = (float)seekTime/self.timeline.duration;
        }
    } else {
        contentView.revertBtn.hidden = YES;
    }

}
#pragma mark 滑动seek
///Slide seek
- (void)sliderValueChanged:(UISlider *)slider {
    self.isChange = YES;
    if (self.type == NvTimelineType_PlayRevert) {
        [self seekTimeline:(1-slider.value) * self.timeline.duration];
    } else {
        [self seekTimeline:slider.value * self.timeline.duration];
    }
}

- (void)sliderValueEnd:(UISlider *)slider{
    self.isChange = NO;
    [self seekTimeline:-1];
}

#pragma mark 时间特效
///the operation of timefx
- (void)timeFxClick:(NSIndexPath*)indexPath {
    NSUInteger index = indexPath.item;
    if (index == 0) {
        ///无
        ///no
        self.type = NvTimelineType_None;
        self.currentSelectType = NvTimelineType_None;
        [self none];
    } else if (index == 1) {
        ///时光倒流
        ///Go back in time
        ///判断转码是否完成
        ///Determine whether transcoding is complete
        self.currentSelectType = NvTimelineType_PlayRevert;
        [self playRevert];
    } else if (index == 2) {
        ///反复
        ///repeat
        self.currentSelectType = NvTimelineType_Repeat;
        [self repeat];
    } else if (index == 3) {
        ///慢动作
        ///Slow motion
        self.currentSelectType = NvTimelineType_Slow;
        [self slowMotion];
    }
}
#pragma mark 时间特效
///倒放特效
///play revert timefx
- (void)playRevert {
    if (self.convertFinish) {
        [contentView.timelineEditor showCoverView:YES];
        contentView.repeatView.hidden = YES;
        ///rebuild倒放timeline
        ///rebuild timeline backwards
        [self rebuildTimeline:self.timeline isRevert:YES];
        self.type = NvTimelineType_PlayRevert;
        NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
        for (int i = 0; i < track.clipCount; i++) {
            [track setBuiltinTransition:i withName:NULL];
        }
        [self addFxsWithNewArray:self.fxRevertArray withTimeline:self.timeline];
        
        [NvTimelineUtils playbackTimeline:self.timeline startTime:0 endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
    }
}

///重复特效
///play repeat timefx
- (void)repeat {
    if (self.convertFinish) {
        [self rebuildTimeline:self.timeline isRevert:NO];
        [contentView.timelineEditor showCoverView:NO];
        contentView.repeatView.hidden = NO;
        contentView.repeatView.image = NvImageNamed(@"shortVideoRepeat");
        contentView.repeatView.centerX = contentView.timelineEditor.centerX;
        self.type = NvTimelineType_Repeat;
        [NvTimelineUtils doRepeatTimeline:self.timeline.duration/2 videotrack:[self.timeline getVideoTrackByIndex:0] originCutTrimInfo:self.videoPathArray.firstObject];
        NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
        for (int i = 0; i < track.clipCount; i++) {
            [track setBuiltinTransition:i withName:NULL];
        }
        [self addFxsWithNewArray:self.fxNewArray withTimeline:self.timeline];
        
        int64_t pos = [self playPosition:self.timeline forType:self.type current:0.5];
        [self seekTimeline:pos];
        contentView.effectWrapper.sliderView.value = 1.0*pos/self.timeline.duration;
        [contentView.timelineEditor setProgressValue:1.0*pos/self.timeline.duration];

        [NvTimelineUtils playbackTimeline:self.timeline startTime:pos endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
    }
}

///慢动作时间特效
///play slowMotion timefx
- (void)slowMotion {
    [self rebuildTimeline:self.timeline isRevert:NO];
    [contentView.timelineEditor showCoverView:NO];
    contentView.repeatView.hidden = NO;
    contentView.repeatView.image = NvImageNamed(@"shortVideoSlow");
    contentView.repeatView.centerX = contentView.timelineEditor.centerX;
    self.type = NvTimelineType_Slow;
    [NvTimelineUtils doSlowMotionTimeline:self.timeline.duration/2 videotrack:[self.timeline getVideoTrackByIndex:0]];
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    for (int i = 0; i < track.clipCount; i++) {
        [track setBuiltinTransition:i withName:NULL];
    }
    [self addFxsWithNewArray:self.fxNewArray withTimeline:self.timeline];
    
    int64_t pos = [self playPosition:self.timeline forType:self.type current:0.5];
    [self seekTimeline:pos];
    contentView.effectWrapper.sliderView.value = 1.0*pos/self.timeline.duration;
    [contentView.timelineEditor setProgressValue:1.0*pos/self.timeline.duration];
    
    [NvTimelineUtils playbackTimeline:self.timeline startTime:pos endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}

///选中无时间特效
///select the none timefx
- (void)none {
    [self rebuildTimeline:self.timeline isRevert:NO];
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    for (int i = 0; i < track.clipCount; i++) {
        [track setBuiltinTransition:i withName:NULL];
    }
    [self addFxsWithNewArray:self.fxNewArray withTimeline:self.timeline];
    [contentView.timelineEditor showCoverView:NO];
    contentView.repeatView.hidden = YES;
    [self seekTimeline:0];
    contentView.effectWrapper.sliderView.value = 0;
    [contentView.timelineEditor setProgressValue:0];
    
    [NvTimelineUtils playbackTimeline:self.timeline startTime:0 endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}

#pragma mark 转码
///the convert opration
- (void)convert {
    self.fileConvert = [NvFileConvert new];
    [self.fileConvert convertFiles:self.videoPathArray];
    __weak typeof(self)weakSelf = self;
    [self.fileConvert finishBlock:^(BOOL isFinish) {
        __strong typeof(weakSelf)self = weakSelf;
        if (isFinish) {
            NSLog(@"转码成功 Transcoding success");
        } else {
            NSLog(@"转码失败 Transcoding failure");
        }
        if (self) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.convertFinish = YES;
                [self->contentView finishConvert];
                if (weakSelf.isTimeFx) {
                    if (weakSelf.currentSelectType == NvTimelineType_Repeat) {
                        [weakSelf repeat];
                    } else if (weakSelf.currentSelectType == NvTimelineType_PlayRevert) {
                        [weakSelf playRevert];
                    }
                }
            });
        }
    }];
    [self.fileConvert startConvert];
}
#pragma mark 当前转码状态的回调
///The callback of the current transcoding status
- (BOOL)currentConvertStatus {
    return self.convertFinish;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 点击滤镜特效
///click the normal fx
- (void)videoFxClick {
    self.isTimeFx = NO;
    if (!self.convertFinish) {
        [contentView selectIndex:0];
        [contentView finishConvert];
        self.currentSelectType = NvTimelineType_None;
    }
}

#pragma mark 点击时间特效
///click the timefx
- (void)timeFxClick {
    self.isTimeFx = YES;
}
#pragma mark 时间特效拖动进度条
///drag the timefx editor
- (void)timelineEditor:(id)timelineEditor dragTimeAxis:(int64_t)timestamp {
    self.isChange = YES;
    if (self.type == NvTimelineType_PlayRevert) {
        [self seekTimeline:self.timeline.duration-timestamp];
    } else {
        [self seekTimeline:timestamp];
    }
}

- (void)timelineEditorDragTimeAxisEnded{
    self.isChange = NO;
    [self seekTimeline:-1];
}

#pragma mark 重复
///repeat
- (void)repeatPointValue:(float)value forStatus:(UIGestureRecognizerState)status{
    int64_t point = self.timeline.duration*value;
    if (status == UIGestureRecognizerStateEnded) {
        if (self.type == NvTimelineType_Slow) {
            [self rebuildTimeline:self.timeline isRevert:NO];
            [NvTimelineUtils doSlowMotionTimeline:point videotrack:[self.timeline getVideoTrackByIndex:0]];
            NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
            for (int i = 0; i < track.clipCount; i++) {
                [track setBuiltinTransition:i withName:NULL];
            }
            [self addFxsWithNewArray:self.fxNewArray withTimeline:self.timeline];
            int64_t pos = [self playPosition:self.timeline forType:self.type current:value];
            [self seekTimeline:pos];
            contentView.effectWrapper.sliderView.value = 1.0*pos/self.timeline.duration;
            [contentView.timelineEditor setProgressValue:1.0*pos/self.timeline.duration];
            
            [NvTimelineUtils playbackTimeline:self.timeline startTime:pos endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
        } else if (self.type == NvTimelineType_Repeat) {
            [self rebuildTimeline:self.timeline isRevert:NO];
            [NvTimelineUtils doRepeatTimeline:point videotrack:[self.timeline getVideoTrackByIndex:0] originCutTrimInfo:self.videoPathArray.firstObject];
            NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
            for (int i = 0; i < track.clipCount; i++) {
                [track setBuiltinTransition:i withName:NULL];
            }
            
            [self addFxsWithNewArray:self.fxNewArray withTimeline:self.timeline];
            int64_t pos = [self playPosition:self.timeline forType:self.type current:value];
            [self seekTimeline:pos];
            contentView.effectWrapper.sliderView.value = 1.0*pos/self.timeline.duration;
            [contentView.timelineEditor setProgressValue:1.0*pos/self.timeline.duration];
            
            [NvTimelineUtils playbackTimeline:self.timeline startTime:pos endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
        }
        self.timeline = self.timeline;
    }
    
}

#pragma mark NvShortVideoEditViewDelegate
- (void)liveWindowTappedStop {
    if (context.getStreamingEngineState != NvsStreamingEngineState_Playback) {
        if (![NvTimelineUtils playbackTimeline:self.timeline startTime:[context getTimelineCurrentPosition:self.timeline] endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
            NSLog(@"播放时间线失败！Failed to play timeline!");
            return;
        }
    } else {
        [context stop];
    }
}

- (void)imageViewTappedPlay {
    if (context.getStreamingEngineState != NvsStreamingEngineState_Playback) {
        if (self.timeline.duration == self.currentPlayTime) {
            if (![NvTimelineUtils playbackTimeline:self.timeline startTime:0 endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
                NSLog(@"播放时间线失败！Failed to play timeline!");
                return;
            }
        }else{
            if (![NvTimelineUtils playbackTimeline:self.timeline startTime:[context getTimelineCurrentPosition:self.timeline] endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
                NSLog(@"播放时间线失败！Failed to play timeline!");
                return;
            }
        }
    }
}

#pragma mark NvsStreamingContextDelegate
- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state {
    if (state == NvsStreamingEngineState_Playback) {
        contentView.playImageView.hidden = YES;
    } else {
        contentView.playImageView.hidden = NO;
    }
}

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    self.currentPlayTime = position;
    contentView.isAddFilterFx = YES;
    if (self.type == NvTimelineType_PlayRevert) {
        ///倒放时播放进度条是倒着来
        ///When playing backwards, the progress bar is inverted
        contentView.effectWrapper.sliderView.value = 1 - ((float)position/timeline.duration);
        [contentView.timelineEditor setProgressValue:1 - ((float)position/timeline.duration)];
    } else {
        contentView.effectWrapper.sliderView.value = (float)position/timeline.duration;
        [contentView.timelineEditor setProgressValue:(float)position/timeline.duration];
    }
    
    if (self.isAddFx) {
        if (self.type == NvTimelineType_PlayRevert) {
            contentView.effectWrapper.colorBarView.timelineCurrentPosition = self.timeline.duration - position;
            [contentView.effectWrapper.colorBarView updateLastBar:YES];
        } else {
            contentView.effectWrapper.colorBarView.timelineCurrentPosition = position;
            [contentView.effectWrapper.colorBarView updateLastBar:NO];
        }
    }
}

- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    ///如果正在添加滤镜则停就停了不用seek到0
    ///If you're adding a filter, stop it and don't seek to 0
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(self) strongSelf = weakSelf;
        if (self.isAddFx) {
            strongSelf.currentPlayTime = timeline.duration;
            strongSelf->contentView.isAddFilterFx = NO;
            if (strongSelf.type == NvTimelineType_PlayRevert) {
                strongSelf->contentView.effectWrapper.sliderView.value = 0;
                [strongSelf->contentView.timelineEditor setProgressValue:0];
                strongSelf->contentView.effectWrapper.colorBarView.timelineCurrentPosition = strongSelf.timeline.duration - strongSelf.currentPlayTime;
                [strongSelf->contentView.effectWrapper.colorBarView updateLastBar:YES];
            } else {
                strongSelf->contentView.effectWrapper.sliderView.value = 1.0;
                [strongSelf->contentView.timelineEditor setProgressValue:1.0];
                strongSelf->contentView.effectWrapper.colorBarView.timelineCurrentPosition = self.currentPlayTime;
                [strongSelf->contentView.effectWrapper.colorBarView updateLastBar:NO];
            }
            
            [strongSelf stopFilter];
        }else{
            [strongSelf->context seekTimeline:strongSelf.timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
            [NvTimelineUtils playbackTimeline:strongSelf.timeline startTime:0 endTime:strongSelf.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
        }
    });
}

#pragma mark 对timeline的操作
///operation for timeline
- (int64_t)playPosition:(NvsTimeline *)timeline forType:(NvTimelineType)type current:(float)value {
    if(type == NvTimelineType_Slow || type == NvTimelineType_Repeat) {
        int64_t time = (int64_t) (timeline.duration * value);
        time = time - 1000000;
        if (time < 0)
            time = 0;
        return time;
    } else {
        return (int64_t) (timeline.duration * value);;
    }
}

///重新buildTimeline
///rebuild timeline
- (void)rebuildTimeline:(NvsTimeline *)timeline isRevert:(BOOL)isRevert {
    NvsVideoTrack *track = [timeline getVideoTrackByIndex:0];
    [track removeAllClips];
    NvsAudioTrack *audioTrack = [timeline getAudioTrackByIndex:0];
    [audioTrack removeAllClips];
    
    [self removeAllTimelineFx:self.timeline];
    
    if (!isRevert) {
        [self addClips:self.videoPathArray toTimeline:timeline];
    } else {
        NSMutableArray *sortFiles = [NSMutableArray array];
        for (int i = 0; i < self.videoPathArray.count; i++) {
            NvRecordingInfo *info = self.videoPathArray[i];
            NvRecordingInfo *infoRevert = [NvRecordingInfo new];
            infoRevert.rotaion = info.rotaion;
            infoRevert.convertPath = info.convertPath;
            infoRevert.trimIn = info.trimIn;
            infoRevert.trimOut = info.trimOut;
            infoRevert.speed = info.speed;
            infoRevert.musicEndPos = info.musicEndPos;
            [sortFiles insertObject:infoRevert atIndex:0];
        }
        [self addClips:sortFiles toTimeline:self.timeline];
    }
    
    for (int i = 0; i < track.clipCount; i++) {
        [track setBuiltinTransition:i withName:NULL];
    }
}

///长按时添加特效
///long press to add fx
- (void)addFx:(NvsTimeline *)timeline withPackgeId:(NSString *)packageId {
    int64_t currentTime = [context getTimelineCurrentPosition:timeline];
    if ([NvSDKUtils isBuiltinFilter:packageId]) {
        [timeline addBuiltinTimelineVideoFx:currentTime duration:timeline.duration - currentTime videoFxName:packageId];
    } else {
        [timeline addPackagedTimelineVideoFx:currentTime duration:timeline.duration - currentTime videoFxPackageId:packageId];
    }
}

///移除所有特效
///remove all the fx added into timeline
- (void)removeAllTimelineFx:(NvsTimeline *)timeline {
    NvsTimelineVideoFx *videoFx = [timeline getFirstTimelineVideoFx];
    while (videoFx) {
        videoFx = [timeline removeTimelineVideoFx:videoFx];
    }
}
- (NvTimeFilterInfoModel *)revertModel:(NvTimeFilterInfoModel *)model timeline:(NvsTimeline *)timeline {
    NvTimeFilterInfoModel *modelInfo = [model copy];
    int64_t inpoint = timeline.duration - modelInfo.outPoint;
    modelInfo.outPoint = timeline.duration - modelInfo.inPoint;
    modelInfo.inPoint = inpoint;
    return modelInfo;
}

///转换为可以为倒放添加特效的model
///convert to the model can be added for revert play
- (NSMutableArray *)revertModelWith:(NSMutableArray<NvTimeFilterInfoModel *> *)fxNewArray withTimeline:(NvsTimeline *)timeline {
    NSMutableArray <NvTimeFilterInfoModel *>*array = [NSMutableArray array];
    
    for (NvTimeFilterInfoModel *model in fxNewArray) {
        NvTimeFilterInfoModel *tempModel = [model copy];
        int64_t inpoint = tempModel.inPoint;
        tempModel.inPoint = timeline.duration - tempModel.outPoint;
        tempModel.outPoint = timeline.duration - inpoint;
        [array addObject:tempModel];
    }
    
    return array;
}
///根据数据添加特效
///add fx according model
- (void)addFxsWithNewArray:(NSMutableArray<NvTimeFilterInfoModel *> *)fxNewArray withTimeline:(NvsTimeline *)timeline {
    
    for (int i = 0; i < fxNewArray.count; i++) {
        NvTimeFilterInfoModel *model = fxNewArray[i];
        if ([NvSDKUtils isBuiltinFilter:model.name]) {
            [timeline addBuiltinTimelineVideoFx:model.inPoint
                                            duration:model.outPoint - model.inPoint
                                         videoFxName:model.name];
        } else {
            [timeline addPackagedTimelineVideoFx:model.inPoint
                                             duration:model.outPoint - model.inPoint
                                     videoFxPackageId:model.name];
        }
    }
}

///生成新的不重复的序列
///Generate a new non repeating sequence
- (NSMutableArray<NvTimeFilterInfoModel *> *)filterModele:(NSMutableArray<NvTimeFilterInfoModel *> *)models withNewModel:(NvTimeFilterInfoModel *)model {
    
    int64_t inPoint = model.inPoint;
    int64_t outPoint = model.outPoint;
    NSMutableArray <NvTimeFilterInfoModel *>*array = [NSMutableArray array];
    for (int i = 0; i < models.count; i++) {
        NvTimeFilterInfoModel *info = models[i];
        int64_t tmpInPoint = info.inPoint;
        int64_t tmpOutPoint = info.outPoint;
        
        if (tmpInPoint < inPoint) {
            if (tmpOutPoint <= inPoint) {
                NvTimeFilterInfoModel *newInfo = [info copy];
                newInfo.inPoint = tmpInPoint;
                newInfo.outPoint = tmpOutPoint;
                [array addObject:newInfo];
            } else {
                NvTimeFilterInfoModel *newInfo = [info copy];
                newInfo.inPoint = tmpInPoint;
                newInfo.outPoint = inPoint;
                [array addObject:newInfo];
                
                if (tmpOutPoint > outPoint) {
                    NvTimeFilterInfoModel *newInfo = [info copy];
                    newInfo.inPoint = outPoint;
                    newInfo.outPoint = tmpOutPoint;
                    [array addObject:newInfo];
                }
            }
        } else if (tmpInPoint < outPoint) {
            if (tmpOutPoint <= outPoint) {
                // do nothing
            } else {
                NvTimeFilterInfoModel *newInfo = [info copy];
                newInfo.inPoint = outPoint;
                newInfo.outPoint = tmpOutPoint;
                [array addObject:newInfo];
            }
        } else {
            NvTimeFilterInfoModel *newInfo = [info copy];
            newInfo.inPoint = tmpInPoint;
            newInfo.outPoint = tmpOutPoint;
            [array addObject:newInfo];
        }
    }
    [array addObject:[model copy]];
    return [[NSMutableArray alloc] initWithArray:array copyItems:YES];
}

///下载asset
///download assets
- (void)downloadAsset:(NvFilterFxModel *)model {
    [self.assetManager downloadAsset:model.packageId];
}

#pragma mark - NvCompileViewControllerDelegate
- (void)compileFinished:(BOOL)needDelete {
    [context connectTimeline:self.timeline withLiveWindow:contentView.getLiveWindow];
    context.delegate = self;
    if (needDelete) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            [[NSFileManager defaultManager] removeItemAtPath:self->_compileFilePath error:nil];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            UISaveVideoAtPathToSavedPhotosAlbum(self->_compileFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        });
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}

#pragma mark - NvAssetManagerDelegate
/**
 * 获取到在线素材列表后执行该回调。
 * Perform the callback after obtaining the online material list.
 */
- (void)onRemoteAssetsChanged:(BOOL)hasNext {
    self.isHaveList = YES;
    NSArray *useArray = [self.assetManager getUsableAssets:ASSET_FILTER aspectRatio:AspectRatio_All categoryId:2 kindId:4];
    NSUInteger count = self.videoFxDataSource.count;
    for (NvAsset *asset in useArray) {
        NvFilterFxModel *item = [NvFilterFxModel new];
        item.showName = NO;
        item.selected = NO;
        item.coverDefault = @"NvFlipCaptionColor";
        item.imagePath = asset.coverUrl;
        item.packageId = asset.uuid;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.displayName = asset.displayNamezhCN;
                }else{
                    item.displayName = asset.displayName;
                }
        item.state = Finish;
        [self.uuids addObject:asset.uuid];
        BOOL isContainLocal = NO;
        for (int i = 0; i < count; i++) {
            NvFilterFxModel *obj = self.videoFxDataSource[i];
            if ([obj.packageId isEqualToString:asset.uuid]) {
                isContainLocal = YES;
            }
        }
        if (!isContainLocal) {
            [self.videoFxDataSource addObject:item];
        }
    }
    
    unsigned long localCount = self.videoFxDataSource.count;
    NSArray *array = [self.assetManager getRemoteAssets:ASSET_FILTER aspectRatio:AspectRatio_All categoryId:2 kindId:4];
    for (NvAsset *asset in array) {
        NvFilterFxModel *item = [NvFilterFxModel new];
        item.showName = NO;
        item.selected = NO;
        item.coverDefault = @"NvFlipCaptionColor";
        item.imagePath = asset.coverUrl;
        item.packageId = asset.uuid;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.displayName = asset.displayNamezhCN;
                }else{
                    item.displayName = asset.displayName;
                }
        [self.uuids addObject:asset.uuid];
        BOOL isContainLocal = NO;
        for (int i = 0; i < localCount; i++) {
            NvFilterFxModel *obj = self.videoFxDataSource[i];
            if ([obj.packageId isEqualToString:asset.uuid]) {
                item.state = Finish;
                isContainLocal = YES;
            }
        }
        if (!isContainLocal) {
            [self.videoFxDataSource addObject:item];
        }
    }
    contentView.videoFxDataSource = self.videoFxDataSource;
    contentView.effectWrapper.colorBarView.allUUids = self.uuids;
}

/**
 * 获取到在线素材列表失败执行该回调。
 * call back for fail to get the list online
 */
- (void)onGetRemoteAssetsFailed {
    [NvToast showErrorWithMessage:NvLocalString(@"CheckNetwork", @"请检查网络是否连接")];
    self.isHaveList = NO;
}

/**
 * 下载在线素材进度执行该回调。
 * call back for get the downloading asset progress
 */
- (void)onDownloadAssetProgress:(NSString *)uuid
                       progress:(int)progress {
    NSLog(@"%d",progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->contentView updateProgress:progress/100.0 uuid:uuid];
    });
}

/**
 * 下载在线素材失败执行该回调。
 * call back for fail to download asset
 */
- (void)onDonwloadAssetFailed:(NSString *)uuid {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NvToast showErrorWithMessage:NvLocalString(@"downloadFaild", @"下载失败！")];
        [self->contentView downloadFailduuid:uuid];
    });
}

/**
 * 下载在线素材完成执行该回调。
 * call back for download asset finished
 */
- (void)onDonwloadAssetSuccess:(NSString *)uuid {
    [self.videoFxDataSource enumerateObjectsUsingBlock:^(NvFilterFxModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.packageId isEqualToString:uuid]) {
            obj.state = Finish;
        }
    }];
    contentView.videoFxDataSource = self.videoFxDataSource;
}

@end
