//
//  NvPreviewViewController.m
//  NvMimoDemo
//
//  Created by MS on 2019/8/13.
//  Copyright © 2019 MS. All rights reserved.
//

#import "NvPreviewViewController.h"
#import <UIColor+NvColor.h>
#import "NvMimoLiveWindowPanelView.h"
#import "NvMimoCompileViewController.h"
#import "NvMimoUtils.h"
#import "NvPreviewCollectionViewCell.h"
#import "NvsVideoTrack.h"
#import "NvsVideoClip.h"
#import "NvsAudioTrack.h"
#import "NvsAudioClip.h"
#import "NvsVideoFx.h"
#import "NvMimoEditTailoringViewController.h"
#import "NvMimoSDKUtils.h"
#import "NvMimoSwitchView.h"
#import "NvMimoConvert.h"
#import "NvRepeatInfoModel.h"
#import <math.h>
#import "NvMimoUtils.h"
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvBaseCommon/NSString+NvPath.h>
@import NvStreamingSdkCore;

///最小支持放慢倍数
///the minimum speed coefficient supported by sdk
#define minSupportSpeedRatio 1/16.0

@interface NvPreviewViewController ()<NvMimoCompileViewControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,NvMimoLiveWindowPanelViewDelegate>
@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) NvMimoLiveWindowPanelView *liveWindowPanel;
@property (nonatomic, strong) NvMimoSwitchView *waterSwitch;
@property (nonatomic, strong) UILabel *waterLabel;
@property (nonatomic, strong) NSString *compileFilePath;
///json文件数据
///template model
@property (nonatomic, strong) NvThemeModel *themeModel;

///底部collectionView 数据源，不包含空镜头
///the datasource of bottom collection view , doesnot contain empty shot(which with assigned content by template)
@property (nonatomic, strong) NSMutableArray <NvShotModel *> *shotArr;

///组成timeline 的视频数组，包含空镜头
///The video array that makes up the timeline, contain empty shot(which with assigned content by template)
@property (nonatomic, strong) NSMutableArray <NvShotModel *> *shotInfo;

///当前复合字幕
///current compound caption
@property (nonatomic, strong) NvsTimelineCompoundCaption *currentCaption;

@property (nonatomic, strong) UICollectionView *bottomCollectionView;

///点击修改的子字幕index
///the index of subCompoundCaption for compoundCaption
@property (nonatomic, assign) NSInteger selectedIndex;

///当前字幕对应model在数组中的位置
///the index of current compound caption in the caption array
@property (nonatomic, assign) NSInteger currentCaptionIndex;

///因分割片段而创建的clip对应视频索引数组
///clipArr which contain Video index corresponding to clip as the split video requirement
@property (nonatomic, strong) NSMutableArray *clipIndexArr;

///结尾水印
///the ending watermark
@property (nonatomic, copy) NSString *animatedSticker;
@property (nonatomic, strong) NvMimoConvert *convert;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIButton *compileButton;
@end

@implementation NvPreviewViewController

- (instancetype )initWithThemeModel:(NvThemeModel *)themeModel shotArr:(NSMutableArray <NvShotModel *> *)shotArr {
    if (self = [super init]) {
        self.themeModel = themeModel;
        self.shotArr = shotArr;
        self.shotInfo = [NSMutableArray array];
        self.clipIndexArr = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor nv_colorWithHexRGB:@"#1A1D24"];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
 
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self leftNavigationBarItemView]];

    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    [self addSubviews];
    self.streamingContext = [NvsStreamingContext sharedInstance];
    [self registerFontsInAsset];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self prepareDataForTimeline];
    if (![[NvMimoSDKUtils getSDKContext] playbackTimeline:self.timeline startTime:self.liveWindowPanel.currentTime endTime:self.timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
        DLog(@"播放时间线失败！");
        return;
    }
}

- (UIView *)leftNavigationBarItemView {
    UIButton *backButton;
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, 30, 44);
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15*SCREANSCALE, 0, 0);
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    return backButton;
}

- (UIView *)rightNavigationBarItemView {
    self.compileButton = [UIButton nv_buttonWithTitle:NvLocalStringFromTable([self class], @"Compile", @"生成") textColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] fontSize:16 image:nil];
    self.compileButton.frame = CGRectMake(0, 0, 30, 44);
    self.compileButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15*SCREENSCALE);
    [self.compileButton addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.compileButton.exclusiveTouch = YES;
    return self.compileButton;
}

- (void)back {
    [[NvMimoSDKUtils getSDKContext] stop];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)addSubviews {
    self.waterSwitch = [[NvMimoSwitchView alloc]initWithFrame:CGRectMake(0, 0, 60 * SCREANSCALE, 25 * SCREANSCALE) withType:2 withState:YES];
    self.waterSwitch.selected = YES;
    [self.waterSwitch addTarget:self action:@selector(waterSwitchClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.waterSwitch];
    self.waterLabel = [[UILabel alloc] init];
    self.waterLabel.text = NvLocalStringFromTable([self class], @"Open the ending watermark", @"开启结尾水印");
    self.waterLabel.textColor = UIColor.whiteColor;
    self.waterLabel.font = [NvMimoUtils fontWithSize:12*SCREANSCALE];
    self.waterLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.waterLabel];
    [self.waterSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(47*SCREANSCALE);
        make.height.mas_equalTo(25*SCREANSCALE);
        make.right.equalTo(self.view.mas_right).offset(-15*SCREANSCALE);
        make.bottom.equalTo(self.view.mas_bottom).offset(-17*SCREANSCALE);
    }];
    
    [self.waterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(90*SCREANSCALE);
        make.height.mas_equalTo(25*SCREANSCALE);
        make.right.equalTo(self.waterSwitch.mas_left).offset(-6*SCREANSCALE);
        make.bottom.equalTo(self.waterSwitch.mas_bottom);
    }];
    
    [self.bottomCollectionView registerClass:[NvPreviewCollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
    [self.view addSubview:self.bottomCollectionView];
    [self.bottomCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.waterSwitch.mas_top).offset(-12*SCREANSCALEHEIGHT);
        make.height.mas_equalTo(84*SCREANSCALE + INDICATOR);
        make.left.equalTo(self.view.mas_left).offset(12*SCREANSCALE);
        make.right.equalTo(self.view.mas_right).offset(12*SCREANSCALE);
    }];
    [self addBaseLiveWindowPanal];
}

#pragma mark setter & getter
- (void)setCompoundCaptionText:(NSString *)compoundCaptionText {
    _compoundCaptionText = compoundCaptionText;

}

#pragma mark rightBtnClicked点击事件
- (void)rightBtnClicked {
    self.compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvMimoUtils currentDateAndTime]]];
    NvMimoCompileViewController *compileViewController = [NvMimoCompileViewController new];
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compileTimeline:_timeline outputPath:self.compileFilePath];
}

///水印
///ending watermark
- (void)waterSwitchClick:(NvMimoSwitchView *)sender {
    sender.selected = !sender.selected;
    if(sender.selected){
        ///开启
        ///open ending watermark
        sender.backgroundColor = [UIColor nv_colorWithHexRGB:@"#2A7DFF"];
        sender.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
        sender.selected = YES;
        [self resetWatermark];
        [UIView animateWithDuration:0.1 animations:^{
            sender.sliderView.frame = CGRectMake(2, 2, sender.sliderView.frame.size.width, sender.sliderView.frame.size.height);
        }];
    }else{
        ///关闭
        ///close ending watermark
        sender.backgroundColor = [UIColor nv_colorWithHexRGB:@"#ADADAD"];
        sender.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
        sender.selected = NO;
        [self deleteWatermark];
        [UIView animateWithDuration:0.1 animations:^{
            sender.sliderView.frame = CGRectMake(sender.frame.size.width - sender.sliderView.frame.size.width -2, 2,sender.sliderView.frame.size.width, sender.sliderView.frame.size.height);
        }];
    }
}

- (void)addBaseLiveWindowPanal {
    self.liveWindowPanel = [[NvMimoLiveWindowPanelView alloc] initWithFrame:CGRectMake(0, 0, SCREANWIDTH, SCREANWIDTH) isShowCaptionInfo:YES];
    _liveWindowPanel.editMode = self.editMode;
    _liveWindowPanel.delegate = self;
    [self.view addSubview:_liveWindowPanel];
}

- (void)seekTimeline {
    int flag = 0;
    int64_t currentTime = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (![self.streamingContext seekTimeline:self.timeline timestamp:currentTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag]) {
        DLog(@"Failed to seek timeline!");
    }
}

- (void)seekTimeline:(int64_t)postion {
    int flag = 0;
    flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (![_streamingContext seekTimeline:_timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag])
        DLog(@"定位时间线失败！");
    _liveWindowPanel.progressSlider.value = 1.0*postion/self.timeline.duration;
    _liveWindowPanel.currentTime = postion;
}

#pragma mark - 准备创建timeline的数据
- (void)prepareDataForTimeline {
   /*
    * 比较底部collectionView 和 themeModel 中镜头数组（shotInfo）
    * 如果两者count 相同，说明没有空镜头，直接赋值self.shotInfo,不必做额外处理
    * 否则说明具有空镜头，需要对比处理，将处理好的数据赋值self.shotInfo
    */
    /*
     compare the self.shotArr and self.themeModel.shotInfos
     if the count of self.shotArr equal to self.themeModel.shotInfos, this template does not contain empty shot,then you can use self.shotInfo to make up self.shotInfo directly.
     If not equal to each other, use the empty shot in self.themeModel.shotInfos and unEmpty shot in self.shotArr to make up self.shotInfo.
     */
    if(self.shotArr.count > 0){
        NSArray *shotInfoArr = self.themeModel.shotInfos;
        if(self.shotArr.count == shotInfoArr.count) {
            self.shotInfo = [NSMutableArray arrayWithArray:self.shotArr];
        }else if(self.shotArr.count < shotInfoArr.count) {
            [self.shotInfo removeAllObjects];
           
            for (int i=0; i<shotInfoArr.count; i++) {
                NvShotModel *model;
                NvShotModel *emptyModel = shotInfoArr[i];
               
                for (NvShotModel *tmpModel in  self.shotArr) {
                    if (tmpModel.shot == i) {
                        model = tmpModel;
                    }
                }
                if (model) {
                    [self.shotInfo addObject:model];
                }else{
                    [self.shotInfo addObject:emptyModel];
                }
                
            }
        }
    }else{
        NSAssert(false, @"镜头数据不正确");
    }
    ///按照json文件要求修改model时长信息
    ///process the trimIn and trimOut attribute of elements in self.shotInfo
    [NvMimoTimelineUtils arrangeVideoData:self.shotInfo dirPath:self.dirPath];
    [self processTimeline];
}

- (void)processTimeline {
    self.timeline = [NvMimoTimelineUtils createTimeline:self.editMode];
    [self resetEditData:self.timeline editDataArray:self.shotInfo];
    [self resetVideoTransition];
    [self resetMusicTrack];
    [self connectLiveWindow];
}

#pragma mark 故事线上添加视频片段，片段上添加复合字幕/滤镜
/// add clips into track of timeline , and add fxs into timeline
- (void)resetEditData:(NvsTimeline *)timeline editDataArray:(NSArray *)editDataArray {
    [self.clipIndexArr removeAllObjects];
    NvsVideoTrack *videoTrack = [timeline getVideoTrackByIndex:0];
    if (videoTrack == nil) {
        return;
    }
    [videoTrack removeAllClips];
    
    /*--------       添加镜头到timeline       --------*/
    /*---   add the shot into timeline as video clip ---*/
    //处理倒放（reverse） 与 重复(repeat)
    //process reverse and repeat effect
    //注：这里的倒放与重复指的是json文件里标注的效果
    //json文件中的倒放及重复效果都需先转码原视频生成倒放视频
    //NOTE: the reverse and repeat is in the json file
    //and the relevant shot videos should be convert to reverse file before using them
    int64_t totalTime =0 ;
    for (int i = 0; i < editDataArray.count; i++) {
        __block NvShotModel *editDataModel = editDataArray[i];
        if (editDataModel.isImage == NO) {
            if(editDataModel.reverse == YES || editDataModel.repeat.count > 0){
                
                if (!_convert) {
                    _convert = [[NvMimoConvert alloc] init];
                }
                if (![self convertFileExisted:editDataModel.videoPath]) {
                    dispatch_semaphore_t smp = dispatch_semaphore_create(0);
                    [self.convert startConvertWithOriginFilePath:editDataModel.videoPath trimIn:0 trimOut:editDataModel.assetDuration];
                    [self.convert finishBlock:^(BOOL isFinish, NSString * _Nonnull outputPath) {
                        if (outputPath.length > 0) {
                            editDataModel.convertPath = outputPath;
                        }
                        dispatch_semaphore_signal(smp);
                    }];
                    dispatch_semaphore_wait(smp, DISPATCH_TIME_FOREVER);
                }else{
                    editDataModel.convertPath = [self convertPathWithOriginPath:editDataModel.videoPath];
                }
                
                if (editDataModel.subTrackFilter.count > 0) {
                    for (int k=0; k<editDataModel.subTrackFilter.count; k++) {
                        NvSubTrackFilterModel *subTrackModel = editDataModel.subTrackFilter[k];
                        if (![self convertFileExisted:subTrackModel.trackVideoPath]) {
                            dispatch_semaphore_t smp = dispatch_semaphore_create(0);
                            [self.convert startConvertWithOriginFilePath:subTrackModel.trackVideoPath trimIn:0 trimOut:subTrackModel.assetDuration];
                            [self.convert finishBlock:^(BOOL isFinish, NSString * _Nonnull outputPath) {
                                if (outputPath.length > 0) {
                                    subTrackModel.trackConvertPath = outputPath;
                                }
                                dispatch_semaphore_signal(smp);
                            }];
                            dispatch_semaphore_wait(smp, DISPATCH_TIME_FOREVER);
                        }else{
                            subTrackModel.trackConvertPath = [self convertPathWithOriginPath:subTrackModel.trackVideoPath];
                        }
                        
                    }
                }
            }
            
        }
        
        //重复效果不要与多个变速，或者匀变速度同时出现在一个镜头里(仅支持一个稳定速度)
        //the repeat effect should not be with multi speed change in same shot (only support with one stablity speed in same shot)
        if (editDataModel.isImage == NO) {
            //json文件重复效果
            if(editDataModel.repeat.count > 0 && editDataModel.speed.count >0) {
                [self repeatUnderSpeedWithTrack:videoTrack model:editDataModel index:i];
                continue;
            }else if(editDataModel.repeat.count > 0 ){
                [self repeatWithTrack:videoTrack model:editDataModel index:i];
                continue;
            }
        }
        
        
        if (editDataModel.speed.count > 0 && !editDataModel.isImage) {
            //镜头包含分节变速
            //the shot contain speed change
            [self multiSpeedWithModel:editDataModel videoTrack:videoTrack totalTime:totalTime modelIndex:i];
        }else{
            //镜头本身无分节变速
            //the shot doesnot contain speed change
            [self noneSpeedWithModel:editDataModel videoTrack:videoTrack totalTime:totalTime modelIndex:i];
        }
        totalTime += editDataModel.trimOut;
    }
    
    /*--------       安装使用timeline(非镜头内)素材       --------*/
    /*---------    add the fxs into timeline    -----*/
    //titleFilter<片头水印贴纸>
    if (self.themeModel.titleFilter.length > 0) {
        NSString *itemId = [self installItem:self.themeModel.titleFilter];
        if ([self isBuiltinFilter:self.themeModel.titleFilter]) {
            [self.timeline addBuiltinTimelineVideoFx:0  duration:self.themeModel.titleFilterDuration videoFxName:itemId];
        }else{
            [self.timeline addPackagedTimelineVideoFx:0 duration:self.themeModel.titleFilterDuration videoFxPackageId:itemId];
        }
    }
    
    //titleCaption<片头字幕>
    if (self.themeModel.titleCaption.length > 0) {
        NSString *itemId = [self installItem:self.themeModel.titleCaption];
        [self.timeline addCompoundCaption:0 duration:self.themeModel.titleCaptionDuration compoundCaptionPackageId:itemId];
    }
    
    //timeline Filter
    if (self.themeModel.timelineFilter.length > 0) {
        NSString *itemId = [self installItem:self.themeModel.timelineFilter];
        if ([self isBuiltinFilter:self.themeModel.timelineFilter]) {
            [self.timeline addBuiltinTimelineVideoFx:0  duration:self.themeModel.musicDuration videoFxName:itemId];
        }else{
            [self.timeline addPackagedTimelineVideoFx:0  duration:self.themeModel.musicDuration videoFxPackageId:itemId];
        }
    }
    
    //ending Filter
    if (self.themeModel.endingFilter.length > 0) {
        NSString *itemId = [self installItem:self.themeModel.endingFilter];
        if ([self isBuiltinFilter:self.themeModel.endingFilter]) {
            [self.timeline addBuiltinTimelineVideoFx:(self.themeModel.musicDuration - self.themeModel.endingFilterLen)  duration:self.themeModel.endingFilterLen videoFxName:itemId];
        }else{
            [self.timeline addPackagedTimelineVideoFx:(self.themeModel.musicDuration - self.themeModel.endingFilterLen) duration:self.themeModel.endingFilterLen videoFxPackageId:itemId];
        }
    }
    
    //时间线普通字幕
    //captionArr
    if(self.themeModel.captionArr.count > 0) {
        for (NvCaptionModel *captionModel in self.themeModel.captionArr) {
            NSString *itemId = [self installItem:captionModel.packageId];
            [self.timeline addCaption:captionModel.text inPoint:captionModel.inPoint duration:captionModel.duration captionStylePackageId:captionModel.packageId];
        }
    }
    
    //片尾水印
    //the ending watermark
    if (self.themeModel.endingWatermark.length > 0){
        self.waterLabel.hidden = NO;
        self.waterSwitch.hidden = NO;
        [self resetWatermark];
    }else{
        self.waterLabel.hidden = YES;
        self.waterSwitch.hidden = YES;
    }
}

- (BOOL)convertFileExisted:(NSString *)path {
    NSString *convertPath = [self convertPathWithOriginPath:path];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:convertPath]) {
        return YES;
    }
    return NO;
}

- (NSString *)convertPathWithOriginPath:(NSString *)originPath {
    NSString *filePath  = [originPath stringByReplacingOccurrencesOfString:@"/" withString:@"*"];
    NSString *convertPath = [NSString stringWithFormat:@"%@.mp4",[CONVERTPATH stringByAppendingPathComponent:filePath]];
    return convertPath;
}

- (void)resetWatermark {
    //ending waterMark
    if (self.themeModel.endingWatermark.length > 0 && self.waterSwitch.selected) {
        self.animatedSticker = [self installItem:self.themeModel.endingWatermark];
        [self.timeline addAnimatedSticker:(self.themeModel.musicDuration - self.themeModel.endingFilterLen) duration:self.themeModel.endingFilterLen animatedStickerPackageId:self.animatedSticker];
    }
}

- (void)deleteWatermark {
    if (self.animatedSticker.length >0) {
        NvsTimelineAnimatedSticker *animatedSticker = [self.timeline getLastAnimatedSticker];
        [self.timeline removeAnimatedSticker:animatedSticker];
    }
}

///一个视频因变速等被切成多个clip后，往timeline上添加本应添加到clip上滤镜、字幕等素材。
///the fxs in the shot be added in timeline as the shot be split into several clips caused by the speed changes etc.
- (void)resetTimeline:(NvsTimeline *)timeline model:(NvShotModel *)editDataModel inPoint:(int64_t)inPoint duration:(int64_t)duration {
    if (editDataModel.filter.length > 0) {
        NSString *filterId = [self installItem:editDataModel.filter];
        if ([self isBuiltinFilter:filterId ]) {
            [timeline addBuiltinTimelineVideoFx:inPoint duration:duration videoFxName:filterId ];
        }else{
            [timeline addPackagedTimelineVideoFx:inPoint duration:duration videoFxPackageId:filterId];
        }
    }

    //compound caption
    if (editDataModel.compoundCaption.length > 0) {
        NSString *itemId = [self installItem:editDataModel.compoundCaption];
        [self.timeline addCompoundCaption:inPoint duration:duration compoundCaptionPackageId:itemId];
    }
}

///单独视频clip设置相应滤镜、字幕等素材
///add fxs in single clip
- (void)resetVideoClip:(NvsVideoClip *)videoClip model:(NvShotModel *)editDataModel shot:(NSInteger)shotNum {
    //视频原声禁止
     [videoClip setVolumeGain:0 rightVolumeGain:0];
     [videoClip setPan:0 andScan:1];
    
    //filter
    if (editDataModel.filter.length > 0) {
        NSString *itemId = [self installItem:editDataModel.filter];
        [self resetVideoFx:videoClip videoFxName:itemId];
    }
    
    //compound caption
    if (editDataModel.compoundCaption.length > 0) {
        NSString *itemId = [self installItem:editDataModel.compoundCaption];
        NvsTimelineCompoundCaption *caption = [self.timeline addCompoundCaption:videoClip.inPoint duration:editDataModel.duration compoundCaptionPackageId:itemId];
        if (self.compoundCaptionText.length > 0 && self.currentCaptionIndex == shotNum) {
            [caption setText:self.selectedIndex text:self.compoundCaptionText];
            self.currentCaption = caption;
        }
    }
}

///repeat + speed  效果实现
///"repeat + speed" effect implementation
- (void)repeatUnderSpeedWithTrack:(NvsVideoTrack *)videoTrack model:(NvShotModel *)editDataModel index:(NSInteger)i {
       //CGFloat trimIn = 0;
       CGFloat trimOut = 0;
       CGFloat speedDuration = 0;
       /*
        * 计算单个镜头各个分节速度model
        * calulate each speedModel of a shot
        */
       NSMutableArray *tmpSpeedArr = [NSMutableArray array];
       for (int m=0; m<editDataModel.speed.count; m++) {
           NvShotSpeedModel *speedModel =editDataModel.speed[m];
           if(speedModel.start != speedDuration){
               NvShotSpeedModel *regularSpeed = [NvShotSpeedModel new];
               regularSpeed.start = speedDuration;
               regularSpeed.end = speedModel.start;
               regularSpeed.speed0 = 1;
               regularSpeed.speed1 = 1;
               [tmpSpeedArr addObject:regularSpeed];
               speedDuration += regularSpeed.end - regularSpeed.start;
           }
           [tmpSpeedArr addObject:[speedModel copy]];
           speedDuration += speedModel.end - speedModel.start;
       }
       if (speedDuration < editDataModel.duration) {
           NvShotSpeedModel *regularSpeed = [NvShotSpeedModel new];
           regularSpeed.start = speedDuration;
           regularSpeed.end = editDataModel.duration;
           regularSpeed.speed0 = 1;
           regularSpeed.speed1 = 1;
           [tmpSpeedArr addObject:regularSpeed];
           speedDuration += regularSpeed.end - regularSpeed.start;
       }
       /*
        * 计算资源时长是否小于规定时长（速度全部转换为1的规定时长）
        * calulate the video duration is whether less than appointed duration as all the speeds convert to 1
        */
       //计算资源时长
       for (int n=0; n<tmpSpeedArr.count; n++) {
           NvShotSpeedModel *speedModel =tmpSpeedArr[n];
           CGFloat speed = (speedModel.speed0 + speedModel.speed1)/2;
           if (speed<1) {
               speed =1;
           }
           trimOut += speed * (speedModel.end - speedModel.start);
           
       }
       
       //计算资源时长是否小于规定时长，设置相应放慢速度
       //if the video duration less than appointed duration, then set the regular slow speed
       if (trimOut > editDataModel.assetDuration && editDataModel.isImage == NO) {
           editDataModel.slowSpeedValue = editDataModel.assetDuration/trimOut;
           
       }else{
           editDataModel.slowSpeedValue = 0;
       }
    
    BOOL repeatSpeed = NO; //重复时间里有没有变速
    for(int p=0; p <tmpSpeedArr.count;p++) {
        NvShotSpeedModel *shotSpeed = tmpSpeedArr[p];
        BOOL isRepeat = NO;
        int repeatIndex = 0;
        for (int q=0; q<editDataModel.repeat.count; q++) {
            NvShotRepeatModel *shotRepeat = editDataModel.repeat[q];
            if (shotSpeed.start >= shotRepeat.start && shotSpeed.start <= shotRepeat.end) {
                //添加repeat
                isRepeat = YES;
                repeatSpeed = YES;
                repeatIndex = q;
            }
        }
        if (isRepeat) {
            //添加repeat
            NvShotRepeatModel *repeatModel = editDataModel.repeat[repeatIndex];
            double repeatDuration = repeatModel.originDuration;
                        
            CGFloat speed =(shotSpeed.speed0 + shotSpeed.speed1)/2;
            CGFloat reverseTrimIn = editDataModel.assetDuration - (repeatDuration + repeatModel.start+editDataModel.trimIn);

            NvsVideoClip *videoClip;
            /*-------  repeat 镜头 分段速度变化不同  ---------*/
            if (shotSpeed.start<repeatModel.start + repeatDuration/speed && shotSpeed.end <=repeatModel.end) {
                //第一个正序播放clip
                NSString *filePath = editDataModel.videoPath;
                videoClip = [videoTrack appendClip:filePath
                                                          trimIn:editDataModel.trimIn+repeatModel.start
                                                         trimOut:editDataModel.trimIn+repeatModel.start+repeatDuration];

               
                if (videoClip != nil) {
                    if (shotSpeed.speed1 == shotSpeed.speed0) {
                        [videoClip changeSpeed:shotSpeed.speed0];
                    }else{
                        [videoClip changeVariableSpeed:shotSpeed.speed0 endSpeed:shotSpeed.speed1 keepAudioPitch:YES];
                    }
                }
                [self.clipIndexArr addObject:[NSNumber numberWithInteger:i]];
                          
                [self resetVideoClip:videoClip model:editDataModel shot:i];
            }else if(shotSpeed.start>=repeatModel.start + repeatDuration/speed && shotSpeed.end <=repeatModel.end){
                //倒序正序clips
                [self repeatAndReverseClipsInTrack:videoTrack shotModel:editDataModel clipsModel:repeatModel speedModel:shotSpeed repeatDuration:repeatDuration reverseTrimIn:reverseTrimIn loopStart:1 loopEnd:repeatModel.count*2 +1 shotIndex:i];
            }else{
                /*-------  整个repeat 速度不分区  ---------*/
                [self repeatAndReverseClipsInTrack:videoTrack shotModel:editDataModel clipsModel:repeatModel speedModel:shotSpeed repeatDuration:repeatDuration reverseTrimIn:reverseTrimIn loopStart:0 loopEnd:repeatModel.count*2 +1 shotIndex:i];
            }
            
        }else{
            //添加变速
            NSString *filePath = editDataModel.videoPath;
            NvsVideoClip * videoClip = [videoTrack appendClip:filePath
                                                       trimIn:editDataModel.trimIn+shotSpeed.start
                                                      trimOut:editDataModel.trimIn+(shotSpeed.end-shotSpeed.start)*(shotSpeed.speed0+shotSpeed.speed1)/2];

            
             if (videoClip != nil) {
                 if (shotSpeed.speed1 == shotSpeed.speed0) {
                     [videoClip changeSpeed:shotSpeed.speed0];
                 }else{
                     [videoClip changeVariableSpeed:shotSpeed.speed0 endSpeed:shotSpeed.speed1 keepAudioPitch:YES];
                 }
             }
            [self.clipIndexArr addObject:[NSNumber numberWithInteger:i]];
                      
            [self resetVideoClip:videoClip model:editDataModel shot:i];
        }
    }
    
    
    if (!repeatSpeed) {
        NSLog(@"变速没有覆盖repeat The transmission does not cover repeat");
    }
}

///repeat 效果实现
///repeat effect implementation
- (void)repeatWithTrack:(NvsVideoTrack *)videoTrack model:(NvShotModel *)editDataModel index:(NSInteger)i  {
    /*
     重复效果（包含倒放和正放重复播放）实现：
     根据json 文件中所规定重复时间计算其正放/倒放各自对应的trimIn、trimOut
     */
    /*
     calulate the trimIn and trimOut of play forward or backward  according the repeat time in json file
     */
    NSMutableArray *repeatInfoArr = [NSMutableArray array];
    CGFloat repDuration = 0;
    for(NvShotRepeatModel *repeatModel in editDataModel.repeat) {
        CGFloat repeatDuration = (repeatModel.end - repeatModel.start)/repeatModel.count/2;
        repDuration += repeatModel.count*2*repeatDuration;
    }
    if (editDataModel.assetDuration < editDataModel.duration - repDuration) {
        
    }
    
    for(NvShotRepeatModel *repeatModel in editDataModel.repeat) {
        CGFloat repeatDuration = (repeatModel.end - repeatModel.start)/(repeatModel.count*2+1);
        CGFloat reverseTrimIn = editDataModel.assetDuration - (repeatDuration + repeatModel.start);
        NvRepeatInfoModel *infoModel = [NvRepeatInfoModel new];
        infoModel.normalTrimIn = repeatModel.start;
        infoModel.reverseTrimIn = reverseTrimIn;
        infoModel.repeatDuration = repeatDuration;
        infoModel.count = repeatModel.count;
        [repeatInfoArr addObject:infoModel];
    }
    CGFloat repeatTrimIn = 0;
    CGFloat repeatTrimDuration = 0; //重复时长

    for (int j=0; j<repeatInfoArr.count; j++) {
        /* ---------- 加载重复之前正常片段 ------------*/
        /*
         add the normal clips (unrepeat clips) before the repeat clips
         */
        NvRepeatInfoModel *infoModel = repeatInfoArr[j];
        NSString *filePath = editDataModel.videoPath;
        NvsVideoClip *videoClip = [videoTrack appendClip:filePath
                                                  trimIn:editDataModel.trimIn+repeatTrimIn
                                                 trimOut:editDataModel.trimIn+infoModel.normalTrimIn - repeatTrimDuration];
        if (videoClip) {
            [self.clipIndexArr addObject:[NSNumber numberWithInteger:i]];
            [self resetVideoClip:videoClip model:editDataModel shot:i];
        }
        
        /* --------- 加载重复片段 ------------*/
        /*
         add the repeat clips
         */
        
        //与设计讨论后，speed默认与repeat 重复片段时间一致
        NvShotSpeedModel *speedModel;
        if(editDataModel.speed.count > 0) {
            speedModel = editDataModel.speed[j];
        }
        for (int m=0; m<infoModel.count*2+1; m++) {
            if (m%2 == 0) {
                //正放
                //play forward clips
                filePath = editDataModel.videoPath;
                videoClip = [videoTrack appendClip:filePath
                 trimIn:editDataModel.trimIn+infoModel.normalTrimIn
                               trimOut:editDataModel.trimIn+infoModel.normalTrimIn+infoModel.repeatDuration];
            }else{
                //倒放
                //play backward clips
                filePath = editDataModel.convertPath;
                videoClip = [videoTrack appendClip:filePath
                 trimIn:infoModel.reverseTrimIn - editDataModel.trimIn
                               trimOut:infoModel.reverseTrimIn - editDataModel.trimIn+infoModel.repeatDuration];
            }
            if (videoClip) {
                [self.clipIndexArr addObject:[NSNumber numberWithInteger:i]];
                [self resetVideoClip:videoClip model:editDataModel shot:i];
            }
            
        }
        
        repeatTrimIn = infoModel.normalTrimIn - repeatTrimDuration + infoModel.repeatDuration;
        repeatTrimDuration += infoModel.repeatDuration*(infoModel.count*2);
    }
    
}

- (void)repeatAndReverseClipsInTrack:(NvsVideoTrack *)videoTrack shotModel:(NvShotModel *)editDataModel clipsModel:(NvShotRepeatModel *)repeatModel speedModel:(NvShotSpeedModel *)shotSpeed repeatDuration:(CGFloat)repeatDuration reverseTrimIn:(CGFloat)reverseTrimIn loopStart:(int)start loopEnd:(int)end
    shotIndex:(NSInteger)i {
    NvsVideoClip *videoClip;
    for (int u=start; u<end; u++) {
                       if (u%2 == 0) {
                                      //正放
                                      //play forward clips
                                     NSString * filePath = editDataModel.videoPath;
                                     videoClip = [videoTrack appendClip:filePath
                                       trimIn:editDataModel.trimIn+repeatModel.start
                                                     trimOut:editDataModel.trimIn+repeatModel.start+repeatDuration];
                                  }else{
                                      //倒放
                                      //play backward clips
                                     NSString * filePath = editDataModel.convertPath;
                                      videoClip = [videoTrack appendClip:filePath
                                       trimIn:reverseTrimIn
                                                     trimOut:reverseTrimIn +repeatDuration];
                                  }
        if (videoClip != nil) {
            if (shotSpeed.speed1 == shotSpeed.speed0) {
                [videoClip changeSpeed:shotSpeed.speed0];
            }else{
                [videoClip changeVariableSpeed:shotSpeed.speed0 endSpeed:shotSpeed.speed1 keepAudioPitch:YES];
            }
        }
       
        [self.clipIndexArr addObject:[NSNumber numberWithInteger:i]];
                  
        [self resetVideoClip:videoClip model:editDataModel shot:i];
    }
}

///镜头本身分节变速(即，json文件该shot设置了速度)
///the shot contains speed change
- (void)multiSpeedWithModel:(NvShotModel *)editDataModel videoTrack:(NvsVideoTrack *)videoTrack totalTime:(int64_t)totalTime modelIndex:(int)index {
    CGFloat trimIn = 0;
    CGFloat trimOut = 0;
    CGFloat speedDuration = 0;
    editDataModel.start = totalTime;
    /*
     * 计算单个镜头各个分节速度model
     * calculate each speed model in every shot
     */
    NSMutableArray *tmpSpeedArr = [NSMutableArray array];
    for (int m=0; m<editDataModel.speed.count; m++) {
        NvShotSpeedModel *speedModel =editDataModel.speed[m];
        if(speedModel.start != speedDuration){
            NvShotSpeedModel *regularSpeed = [NvShotSpeedModel new];
            regularSpeed.start = speedDuration;
            regularSpeed.end = speedModel.start;
            regularSpeed.speed0 = 1;
            regularSpeed.speed1 = 1;
            [tmpSpeedArr addObject:regularSpeed];
            speedDuration += regularSpeed.end - regularSpeed.start;
        }
        [tmpSpeedArr addObject:[speedModel copy]];
        speedDuration += speedModel.end - speedModel.start;
    }
    if (speedDuration < editDataModel.duration) {
        NvShotSpeedModel *regularSpeed = [NvShotSpeedModel new];
        regularSpeed.start = speedDuration;
        regularSpeed.end = editDataModel.duration;
        regularSpeed.speed0 = 1;
        regularSpeed.speed1 = 1;
        [tmpSpeedArr addObject:regularSpeed];
        speedDuration += regularSpeed.end - regularSpeed.start;
    }
    /*
     * 计算资源时长是否小于规定时长（速度全部转换为1的规定时长）
     * calulate the video duration is whether less than appointed duration as all the speeds convert to 1
     */
    //计算资源时长
    for (int n=0; n<tmpSpeedArr.count; n++) {
        NvShotSpeedModel *speedModel =tmpSpeedArr[n];
        CGFloat speed = (speedModel.speed0 + speedModel.speed1)/2;
        trimOut += speed * (speedModel.end - speedModel.start);
        
    }
    
    //计算资源时长是否小于规定时长，设置相应放慢速度
    //if the asset duration less than the appointed duration, set the regular slow speed
    if (trimOut > (editDataModel.assetDuration - editDataModel.trimIn) && editDataModel.isImage == NO) {
        editDataModel.slowSpeedValue = (editDataModel.assetDuration - editDataModel.trimIn)/trimOut;
        
    }else{
        editDataModel.slowSpeedValue = 0;
    }

    
    /*
     * 开始调整各个分节规定速度调节其在时间线上速度
     * start to adjust each speed model
     */
    int64_t inPoint = 0;
    //正确添加clip(trimIn 、trimOut),调整具体clip速度
    CGFloat trimOutNew = 0;
    for (int k=0; k<tmpSpeedArr.count; k++) {
        NvShotSpeedModel *speedModel =tmpSpeedArr[k];
        
        CGFloat speed = (speedModel.speed0 + speedModel.speed1)/2;
        if (editDataModel.slowSpeedValue>0) {
            trimOutNew += (speedModel.end - speedModel.start)*editDataModel.slowSpeedValue;
        }else{
            trimOutNew += speed * (speedModel.end - speedModel.start);
        }
        NSString *filePath = editDataModel.isImage ? editDataModel.localIdentifier : editDataModel.videoPath;
        if (editDataModel.reverse == YES) {
            filePath = editDataModel.convertPath;
        }
        NvsVideoClip *videoClip = [videoTrack appendClip:filePath
                                                  trimIn:editDataModel.trimIn + trimIn
                                                 trimOut:editDataModel.trimIn + trimOutNew];
        if(k==0){
            inPoint = videoClip.inPoint;
        }
        //调节多轨
        //set the multi tracks
        if (editDataModel.subTrackFilter.count >0) {
            NSString *fxName = [self installItem:editDataModel.mainTrackFilter];
            [self resetVideoFx:videoClip videoFxName:fxName];
            for (int i=0; i<editDataModel.subTrackFilter.count; i++) {
                NvSubTrackFilterModel *subTrackModel = editDataModel.subTrackFilter[i];
                NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:i+1];
                if (!track) {
                    track = [self.timeline appendVideoTrack];
                }
                CGFloat subTrackTrimOut;
                if (editDataModel.slowSpeedValue>0) {
                    subTrackTrimOut = trimOutNew - (speedModel.end - speedModel.start)*editDataModel.slowSpeedValue;
                }else{
                    subTrackTrimOut = trimOutNew - speed * (speedModel.end - speedModel.start);
                }
                //计算资源时长是否小于规定时长，设置相应放慢速度
                // If the computation time is less than the specified time, set the speed to slow down accordingly
                if (trimOut > subTrackModel.assetDuration && subTrackModel.isImage == NO) {
                    subTrackModel.slowSpeedValue = subTrackModel.assetDuration/trimOut;
                    subTrackTrimOut += (speedModel.end - speedModel.start)*subTrackModel.slowSpeedValue;
                }else{
                    subTrackModel.slowSpeedValue = 0;
                    subTrackTrimOut += speed * (speedModel.end - speedModel.start);
                }
                
               
                NvsVideoClip *subTrackClip = [track addClip:subTrackModel.trackVideoPath inPoint:videoClip.inPoint trimIn:subTrackModel.trimIn + trimIn trimOut:subTrackModel.trimIn + subTrackTrimOut];

                if (subTrackModel.slowSpeedValue !=0 && subTrackModel.isImage == NO) {
                    if(subTrackModel.slowSpeedValue < minSupportSpeedRatio){
                        [subTrackClip changeSpeed:minSupportSpeedRatio];
                    }else{
                        [subTrackClip changeVariableSpeed:subTrackModel.slowSpeedValue*speedModel.speed0 endSpeed:subTrackModel.slowSpeedValue*speedModel.speed1 keepAudioPitch:YES];
                    }
                    
                }else{
                    if (speedModel.speed0 >0 && speedModel.speed1 >0) {
                        [subTrackClip changeVariableSpeed:speedModel.speed0 endSpeed:speedModel.speed1 keepAudioPitch:YES];
                    }else{
                        [subTrackClip changeSpeed:speedModel.speed0];
                    }
                }
                [subTrackClip setVolumeGain:0 rightVolumeGain:0];
                [subTrackClip setPan:0 andScan:1];
                NSString *fxID = [self installItem:subTrackModel.filterName];
                [self resetVideoFx:subTrackClip videoFxName:fxID];
            }
            
        }
        
        if (editDataModel.slowSpeedValue>0) {
            trimIn += (speedModel.end - speedModel.start)*editDataModel.slowSpeedValue;
        }else{
            trimIn += speed * (speedModel.end - speedModel.start);
        }
        
        //调整具体clip速度
        // Adjust specific clip speed
        if (!videoClip) {
            continue;
        }
        if (editDataModel.slowSpeedValue>0) {
            if(speedModel.speed0 != speedModel.speed1){
                [videoClip changeVariableSpeed:editDataModel.slowSpeedValue/speed*speedModel.speed0 endSpeed:editDataModel.slowSpeedValue/speed*speedModel.speed1 keepAudioPitch:YES];
            }else{
                [videoClip changeSpeed:editDataModel.slowSpeedValue/speed*speedModel.speed0];
            }
            
        }else{
            if (speedModel.speed0 >0 && speedModel.speed1 >0 && speedModel.speed0 != speedModel.speed1) {
                [videoClip changeVariableSpeed:speedModel.speed0 endSpeed:speedModel.speed1 keepAudioPitch:YES];
            }else{
                [videoClip changeSpeed:speedModel.speed0];
            }
        }
        
        [self.clipIndexArr addObject:[NSNumber numberWithInteger:index]];
        [videoClip setVolumeGain:0 rightVolumeGain:0];
        [videoClip setPan:0 andScan:1];
        if(tmpSpeedArr.count == 1){
            [self resetVideoClip:videoClip model:editDataModel shot:index];
        }

    }
    if (tmpSpeedArr.count > 1) {
       [self resetTimeline:self.timeline model:editDataModel inPoint:inPoint duration:editDataModel.duration];
    }
    
}

///json文件中该shot没有设置speed
///the shot has not speed in json file
- (void)noneSpeedWithModel:(NvShotModel *)editDataModel videoTrack:(NvsVideoTrack *)videoTrack totalTime:(int64_t)totalTime modelIndex:(int)index {
    NSString *filePath = editDataModel.isImage ? editDataModel.localIdentifier : editDataModel.videoPath;
    if (editDataModel.reverse == YES) {
        filePath = editDataModel.convertPath;
    }
    NvsVideoClip *videoClip;
    BOOL needRepeatClip = NO;
    double speed = (editDataModel.assetDuration - editDataModel.trimIn) / editDataModel.duration;
    if(speed < minSupportSpeedRatio && speed > 0){
        needRepeatClip = YES;
        videoClip = [videoTrack appendClip:editDataModel.isImage ? editDataModel.localIdentifier : editDataModel.videoPath
                                    trimIn:editDataModel.trimIn
                                   trimOut:editDataModel.trimIn + editDataModel.duration*minSupportSpeedRatio];
    }else{
        videoClip = [videoTrack appendClip:editDataModel.isImage ? editDataModel.localIdentifier : editDataModel.videoPath
                                    trimIn:editDataModel.trimIn
                                   trimOut:editDataModel.trimOut];
    }
    //选择视频素材时长小于规定时间
    // Select video footage less than specified time
    if ((editDataModel.duration > (editDataModel.assetDuration-editDataModel.trimIn)) && !editDataModel.isImage && editDataModel.source.length <=0) {
        if (needRepeatClip) {
            [videoClip changeSpeed:minSupportSpeedRatio];
        }else{
            [videoClip changeSpeed:speed];
        }
    }
    
    if (editDataModel.subTrackFilter.count >0) {
        for (int i=0; i<editDataModel.subTrackFilter.count; i++) {
            NvSubTrackFilterModel *subTrackModel = editDataModel.subTrackFilter[i];
            NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:i+1];
            if (!track) {
                track = [self.timeline appendVideoTrack];
            }
            NSString *trackFile = subTrackModel.trackVideoPath;
            if (editDataModel.reverse == YES) {
                trackFile = subTrackModel.trackConvertPath;
            }
            NvsVideoClip *subTrackClip;
            CGFloat subClipSpeed = (subTrackModel.assetDuration - subTrackModel.trimIn)/editDataModel.duration;
            if (subClipSpeed < minSupportSpeedRatio && subClipSpeed > 0) {
                subTrackClip = [track addClip:trackFile inPoint:videoClip.inPoint trimIn:subTrackModel.trimIn trimOut:subTrackModel.trimIn + editDataModel.duration * minSupportSpeedRatio];
            }else if (subClipSpeed > minSupportSpeedRatio && (subTrackModel.assetDuration - subTrackModel.trimIn) < editDataModel.duration){
                subTrackClip = [track addClip:trackFile inPoint:videoClip.inPoint trimIn:subTrackModel.trimIn trimOut:subTrackModel.trimIn + editDataModel.duration * subClipSpeed];
            }
            else{
                subTrackClip= [track addClip:trackFile inPoint:videoClip.inPoint trimIn:subTrackModel.trimIn trimOut:subTrackModel.trimIn +editDataModel.duration];
            }
             
            if (editDataModel.duration > (subTrackModel.assetDuration-subTrackModel.trimIn) && !subTrackModel.isImage ) {
                if (subClipSpeed < minSupportSpeedRatio && subClipSpeed > 0) {
                    [subTrackClip changeSpeed:minSupportSpeedRatio];
                }else{
                    [subTrackClip changeSpeed:subTrackModel.assetDuration / editDataModel.duration];
                }
                
            }
            NSString *itemId = [self installItem:subTrackModel.filterName];
            [self resetVideoFx:subTrackClip videoFxName:itemId];
            [subTrackClip setVolumeGain:0 rightVolumeGain:0];
            [subTrackClip setPan:0 andScan:1];
        }
        NSString *fxId = [self installItem:editDataModel.mainTrackFilter];
        [self resetVideoFx:videoClip videoFxName:fxId];
    }
    
    if (!videoClip) {
        return;
    }
    
    editDataModel.start = totalTime;
    [self.clipIndexArr addObject:[NSNumber numberWithInteger:index]];
    [self resetVideoClip:videoClip model:editDataModel shot:index];
    
}

///设置视频转场(视频转场需要在数据处理完后单独处理，否则无效！)
///set the video transition.
///Note:the video transition must be set in the end,or it will not work!
- (void)resetVideoTransition {
    //transition
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    for (int j=0; j<videoTrack.clipCount; j++) {
        [videoTrack setBuiltinTransition:j withName:@""];
        [videoTrack setPackagedTransition:j withPackageId:@""];
    }
    for (int i = 0; i < self.shotInfo.count; i++) {
        int k = [self lastIndexOfObject:i];
        NvShotModel *editDataModel = self.shotInfo[i];
        if (editDataModel.trans.length > 0) {
            if (![NvMimoUtils isStringEmpty:editDataModel.trans]) {
                NSString *itemId = [self installItem:editDataModel.trans];
                if ([NvMimoSDKUtils isBuiltinVideoTransition:editDataModel.trans]) {
                    
                    [videoTrack setBuiltinTransition:k withName:itemId];
                    
                }else{
                    [videoTrack setPackagedTransition:k withPackageId:itemId];
                }
            }
            
        }else{
            [videoTrack setBuiltinTransition:k withName:@""];
            [videoTrack setPackagedTransition:k withPackageId:@""];
        }
    }
}

- (int)lastIndexOfObject:(int)value {
    int tmpIndex = 0;
    for (int i=0; i<self.clipIndexArr.count; i++) {
        NSNumber *num = self.clipIndexArr[i];
        if (num.intValue == value) {
           tmpIndex = i;
        }
    }
    return tmpIndex;
}

- (void)registerFontsInAsset {
    NSString *fontAssetPath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"FontAsset"];
    NSString *fontPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Asset/MIMOFontAsset"];
    [self registFontWithPath:fontAssetPath];
    [self registFontWithPath:fontPath];
}

- (void)registFontWithPath:(NSString *)fontPath {
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:fontPath error:nil];
    for (NSString *path in dirArray) {
        NSString *fontFamily = [self.streamingContext registerFontByFilePath:[fontPath stringByAppendingPathComponent:path]];
        DLog(@"注册字体%@",fontFamily);
    }
}

- (NSString*)installItem:(NSString*)itemPath {
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:self.dirPath error:nil];
    NSString *fullPath;
    NSString *licPath;
    for (NSString *path in dirArray) {
        if ([path containsString:itemPath]) {
            
            if([path hasSuffix:@".lic"]){
                
                licPath = [self.dirPath stringByAppendingPathComponent:path];
            }else{
                
                fullPath = [self.dirPath stringByAppendingPathComponent:path];
            }
        }
    }
    NSMutableString* sceneId = [[NSMutableString alloc] init];
    NvsAssetPackageType assetType;
    if ([fullPath.pathExtension containsString:@"videofx"]) {
        assetType = NvsAssetPackageType_VideoFx;
    } else if ([fullPath.pathExtension containsString:@"compoundcaption"]) {
        assetType = NvsAssetPackageType_CompoundCaption;
    } else if ([fullPath.pathExtension containsString:@"videotransition"]) {
        assetType = NvsAssetPackageType_VideoTransition;
    } else if([fullPath.pathExtension containsString:@"animatedsticker"]) {
        assetType = NvsAssetPackageType_AnimatedSticker;
    } else if([fullPath.pathExtension containsString:@"captionstyle"]) {
        assetType = NvsAssetPackageType_CaptionStyle;
    }
    if (assetType != NvsAssetPackageType_CompoundCaption &&
        assetType != NvsAssetPackageType_VideoFx &&
        assetType != NvsAssetPackageType_VideoTransition &&
        assetType != NvsAssetPackageType_AnimatedSticker &&
        assetType != NvsAssetPackageType_CaptionStyle) {
        return nil;
    }
    if(!licPath){
        
        licPath = [NSString convertFilePathToNewPath:fullPath WithExtension:@"lic"];
    }
    NvsAssetPackageManagerError error = [self.streamingContext.assetPackageManager installAssetPackage:fullPath license:licPath type:assetType sync:YES assetPackageId:sceneId];
    if (error != NvsAssetPackageManagerError_NoError && error != NvsAssetPackageManagerError_AlreadyInstalled) {
        DLog(@"包裹安装失败%@",fullPath);
        return nil;
    }else{
        DLog(@"安装成功%@",fullPath);
    }
    return sceneId;
}

- (void)resetVideoFx:(NvsVideoClip *)clip videoFxName:(NSString *)fxName {
    for (int j = 0; j < clip.fxCount; j++) {
        if([fxName isEqualToString:@"Transform 2D"] ||
           [fxName isEqualToString:@"Color Property"] ||
           [fxName isEqualToString:@"Sharpen"] ||
           [fxName isEqualToString:@"Vignette"]) {
            continue;
        }
        [clip removeFx:j];
        j--;
    }
    NvsVideoFx *fx;
    if ([self isBuiltinFilter:fxName]) {
        fx = [clip appendBuiltinFx:fxName];
    }else{
        fx = [clip appendPackagedFx:fxName];
    }
    [fx setAbsoluteTimeUsed:true];
}

- (BOOL)isBuiltinFilter:(NSString *)filterName {
    if (!filterName) {
        DLog(@"滤镜名字为空%@",filterName);
    }
    NvsStreamingContext *context = [NvsStreamingContext sharedInstance];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[context getAllBuiltinVideoFxNames]];
    [array addObject:@"Video Echo"];
    [array addObject:@"Cartoon"];
    
    for (NSString *_Nullable str in array) {
        if (filterName == nil) {
            continue;
        }
        if ([str isEqualToString:filterName]) {
            return YES;
        }
    }
    return NO;
}

- (void)resetMusicTrack {
    NvsAudioTrack *musicTrack = [self.timeline getAudioTrackByIndex:0];
    [musicTrack removeAllClips];
    NSString *musicPath = [self.dirPath stringByAppendingPathComponent:self.themeModel.music];
    [musicTrack appendClip:musicPath];
}

#pragma mark - NvCompileViewControllerDelegate
- (void)compileFinished:(BOOL)needDelete {
    [self connectLiveWindow];
    if (needDelete) {
        [[NSFileManager defaultManager] removeItemAtPath:_compileFilePath error:nil];
    } else {
        UISaveVideoAtPathToSavedPhotosAlbum(_compileFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)connectLiveWindow {
    if (!self.timeline) {
        return;
    }
    [self.liveWindowPanel connectTimeline:self.timeline];
    [self seekTimeline];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}

#pragma mark - 播放过程中的回调
- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf seekTimeline:0];
        self.currentCaption = [[self.timeline getCompoundCaptionsByTimelinePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]] lastObject];
    });
}

- (void)sliderValueChanged:(float)value {
    if (value ==1) {
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf seekTimeline:0];
        });
    }

}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.shotArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    NvPreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A4A4A"];
    cell.model = self.shotArr[indexPath.item];
    cell.layer.cornerRadius = 2*SCREANSCALE;
    cell.layer.masksToBounds = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NvShotModel *model = self.shotArr[indexPath.item];
    __weak typeof(self)weakSelf = self;
    NvMimoEditTailoringViewController *vc = [NvMimoEditTailoringViewController new];
    vc.editMode = self.editMode;
    vc.model = model;
    vc.replaceBlock = ^(NvShotModel *replaceModel) {
        weakSelf.selectService.isReplaceMode = YES;
        weakSelf.selectService.currentShotModel = replaceModel;
    };
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - lazyload
- (UICollectionView *)bottomCollectionView {
    if (!_bottomCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(60*SCREANSCALE, 60*SCREANSCALE);
        flowLayout.minimumLineSpacing = 12*SCREANSCALE;
        _bottomCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _bottomCollectionView.delegate = self;
        _bottomCollectionView.dataSource = self;
        _bottomCollectionView.contentInset = UIEdgeInsetsMake(0, 4*SCREANSCALE, 0, 0);
        _bottomCollectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#1A1D24"];
    }
    return  _bottomCollectionView;
}

@end
