//
//  NvEditSpeedViewController.m
//  SDKDemo
//
//  Created by MS on 2020/11/26.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvEditSpeedViewController.h"
#import <NvSDKCommon/NvLiveWindowPanelView.h>
#import "NvCaptureFilterCell.h"
#import "NvCurveSpeedListView.h"
#import "NvCurveSpeedUtils.h"
#import "NvCurveSpeedView.h"
#import "NvBezierSpeedModel.h"
#import "NvNormalSpeedView.h"
#import "NvsVideoClip.h"
#import "NvTimelineUtils.h"

@interface NvEditSpeedViewController ()<NvLiveWindowPanelViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,NvCurveSpeedListViewDelegate,NvCurveSpeedViewDelegate,NvNormalSpeedViewDelegate>
@property (nonatomic, strong) NvLiveWindowPanelView *liveWindowPanel;
@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, strong) NvsVideoClip *clip;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) NvTimelineData *timelineData;
@property (nonatomic, strong) UICollectionView *collectionView;
///变速类型数组:（普通变速、曲线变速）
///Array of variable speed types: (normal variable speed, curved variable speed)
@property (nonatomic, strong) NSArray *speedCateArr;

@property (nonatomic, strong) NvCurveSpeedListView *curveSpeedListView;
@property (nonatomic, strong) NvsVideoClip *currentClip;
@property (nonatomic, strong) NvCurveSpeedUtils *curveSpeedUtils;

@property (nonatomic, strong) NvCurveSpeedView *curveSpeedView;
@property (nonatomic, strong) NSString *curveId;
@property (nonatomic, strong) NSMutableArray *curvePointArr;

///常规变速
///Conventional speed change
@property (nonatomic, strong) NvNormalSpeedView *normalSpeedView;
@property (nonatomic, assign) double normalSpeed;
@end

@implementation NvEditSpeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.streamingContext = [NvsStreamingContext sharedInstanceWithFlags:NvsStreamingContextFlag_Support4KEdit | NvsStreamingContextFlag_InterruptStopForInternalStop | NvsStreamingContextFlag_NeedGifMotion];
    [self initTimeline];
    [self initBottomCollectionViewDataSource];
    [self addSubviews];
    self.curveSpeedUtils = [NvCurveSpeedUtils new];
    self.curveId = self.model.curveSpeedsId ? self.model.curveSpeedsId : @"none";
    self.curvePointArr = [NSMutableArray arrayWithArray:self.model.curveSpeeds];
    self.normalSpeed = self.model.speed;
    [self.streamingContext seekTimeline:self.timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}

- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

- (void)addSubviews {
    self.liveWindowPanel = [[NvLiveWindowPanelView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH)];
    self.liveWindowPanel.editMode = self.editMode;
    [self.liveWindowPanel connectTimeline:self.timeline];
    self.liveWindowPanel.delegate = self;
    [self.liveWindowPanel hiddenVolumeButton];
    [self.view addSubview:self.liveWindowPanel];

    
    UIButton *finsh = [UIButton buttonWithType:UIButtonTypeCustom];
    [finsh setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [finsh addTarget:self action:@selector(finshClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finsh];
    [finsh mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(25*SCREENSCALEHEIGHT));
        make.height.equalTo(@(20*SCREENSCALE));
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(@(-15*SCREENSCALE));
        }
    }];
    
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(finsh.mas_top).offset(-12*SCREENSCALE);
    }];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(line.mas_top).offset(-26 * SCREENSCALE);
        make.left.right.equalTo(self.view);
        make.height.offset(86 * SCREENSCALE);
    }];
    
    [self.view addSubview:self.curveSpeedListView];
    [self.curveSpeedListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom);
        make.left.right.equalTo(self.view);
    }];
    
    CGFloat liveWindowMaxY = CGRectGetMaxY(self.liveWindowPanel.frame);
    self.curveSpeedView = [[NvCurveSpeedView alloc] initWithFrame:CGRectMake(0, liveWindowMaxY, SCREENWIDTH, SCREENHEIGHT - liveWindowMaxY - NV_STATUSBARHEIGHT - NV_NAV_BAR_HEIGHT - INDICATOR) curveName:@"" clip:self.currentClip inPoint:self.model.trimIn outPoint:self.model.trimOut];
    [self.view addSubview:self.curveSpeedView];
    self.curveSpeedView.delegate = self;
    self.curveSpeedView.hidden = YES;
    self.curveSpeedView.inPoint = self.model.trimIn;
    self.curveSpeedView.outPoint = self.model.trimOut;
    
    self.normalSpeedView = [[NvNormalSpeedView alloc] init];
    self.normalSpeedView.delegate = self;
    [self.view addSubview:self.normalSpeedView];
    [self.normalSpeedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(200*SCREENSCALE);
    }];
    self.normalSpeedView.keepAudioPitch = self.model.keepAudioPitchNormalChangeSpeed;
}

- (void)initBottomCollectionViewDataSource {
    NvBaseModel *model = [NvBaseModel new];
    model.coverName = @"nv_edit_regular_speed";
    model.displayName = NvLocalString(@"Normal speed", @"常规变速");
    model.selected = NO;
    
    NvBaseModel *model1 = [NvBaseModel new];
    model1.coverName = @"nv_edit_curve_speed";
    model1.displayName = NvLocalString(@"Curve speed", @"曲线变速");
    model1.selected = NO;
    self.speedCateArr = @[model,model1];
}

- (void)initTimeline {
    self.timeline = [NvTimelineUtils createTimeline:self.editMode];
    self.timelineData = [NvTimelineData sharedInstance];
    [NvTimelineUtils resetEditData:self.timeline editDataArray:[NSArray arrayWithObject:_model]];
    [NvTimelineUtils resetVideoFx:self.timeline videoFxDataArray:[NvTimelineUtils getClipTimelineFilter:_model timeline:self.timeline]];
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    self.currentClip = [track getClipWithIndex:0];
    [NvTimelineUtils removeClipCropAndTransformFx:self.currentClip];
}

#pragma mark 完成按钮点击事件
///Complete the button click event
- (void)finshClick:(UIButton *)sender {
    if (self.curveSpeedUtils.curveSpeedsId.length > 0) {
        NSMutableArray *points = self.curveSpeedUtils.curveSpeeds[self.curveSpeedUtils.curveSpeedsId];
        if (points.count>0) {
            self.model.curveSpeeds = points;
            self.model.curveSpeedsId = self.curveSpeedUtils.curveSpeedsId;
            self.model.speed = 1;
        }
        
    }else{
        self.model.keepAudioPitchNormalChangeSpeed = self.normalSpeedView.keepAudioPitch;
        self.model.speed = self.normalSpeed;
        self.model.curveSpeedsId = @"";
        [self.model.curveSpeeds removeAllObjects];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NvLiveWindowPanelViewDelegate
- (void)playback {
    
}

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    if (self.curveSpeedUtils.curveSpeedsId.length > 0){
        [self fetchTimelineInfo:position state:[self.streamingContext getStreamingEngineState]];
    }
}

- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.streamingContext seekTimeline:self.timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
        self.liveWindowPanel.currentTime = 0;
    });
}

- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state {
    int64_t position = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    [self fetchTimelineInfo:position state: state];
    if (state == NvsStreamingEngineState_Playback && self.curveSpeedView.isHidden == NO) {
        /// 播放状态中，取消曲线点选中状态
        ///In playing state, unselect the curve point
        [self.curveSpeedView resetCurvePoints];
    }
}

- (BOOL)fetchTimelineInfo:(int64_t)position state:(NvsStreamingEngineState)state {
    BOOL isPlaying = NO;
    if (state == NvsStreamingEngineState_Playback) {
        isPlaying = YES;
    }
    self.curveSpeedView.isPlayback = isPlaying;
    return [self.curveSpeedView updataTimeline:position state:isPlaying];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.speedCateArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvCaptureFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvSpeedID" forIndexPath:indexPath];
    NvBaseModel* model = self.speedCateArr[indexPath.item];
    [cell renderCellWithModel:model];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == 0) {
        ///常规变速
        ///Conventional speed change
        [self.normalSpeedView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            } else {
                make.bottom.equalTo(self.view.mas_bottom);
            }
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(200*SCREENSCALE);
        }];
        [UIView animateWithDuration:0.1 animations:^{
            [self.view layoutIfNeeded];
        }];
        [self.normalSpeedView setSpeed:self.normalSpeed];
    }else if (indexPath.item == 1) {
        ///曲线变速
        ///Curve speed change
        [self.curveSpeedListView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            } else {
                make.bottom.equalTo(self.view.mas_bottom);
            }
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(180*SCREENSCALE);
        }];
        [UIView animateWithDuration:0.1 animations:^{
            [self.view layoutIfNeeded];
        }];
        if (self.curveId.length > 0 && self.curvePointArr.count > 0) {
            self.curveSpeedListView.selectedCurveId = self.curveId;
            self.curveSpeedUtils.curveSpeedsId = self.curveId;
            [self.curveSpeedUtils setPackageId:self.curveId points:self.curvePointArr];
        }else if([self.curveId isEqualToString:@"none"]){
            self.curveSpeedListView.selectedCurveId = self.curveId;
        }
            
    }
}

#pragma mark - NvCurveSpeedListViewDelegate
- (void)nvFinishCurveSpeedListView:(NvCurveSpeedListView *)listView {
    [self.curveSpeedListView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom);
        make.left.right.equalTo(self.view);
    }];
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
    }];
    if (self.curveSpeedUtils.curveSpeedsId.length > 0) {
        NSMutableArray *points = self.curveSpeedUtils.curveSpeeds[self.curveSpeedUtils.curveSpeedsId];
        self.curveId = self.curveSpeedUtils.curveSpeedsId;
        if (points.count>0) {
            self.curvePointArr = points;
        }else{
            [self.curvePointArr removeAllObjects];
        }
    }
}

- (void)nvCurveSpeedListView:(NvCurveSpeedListView *)listView didSelectItem:(NvCurveSpeedModel *)item {
    [self.curveSpeedUtils applyCurveSpeed:self.currentClip model:item];
    self.liveWindowPanel.duration = self.timeline.duration;
    if ([item.packageId isEqualToString:@"none"]) {
        [self.streamingContext stop];
    }else{
        self.liveWindowPanel.currentTime = 0;
        [self.liveWindowPanel playAtTime:0];
    }
}

- (void)nvCurveSpeedListView:(NvCurveSpeedListView *)listView didBeginEditing:(NvCurveSpeedModel *)item {
    self.curveSpeedView.hidden = NO;
    NSMutableArray *points = self.curveSpeedUtils.curveSpeeds[item.packageId];
    
    NvCurveInfo *curveInfo = [NvCurveInfo new];
    curveInfo.chartsArr = points;
    curveInfo.minValue = 0.1;
    curveInfo.maxValue = 10;
    self.curveSpeedView.curveInfo = curveInfo;
    self.curveSpeedView.curveId = item.packageId;
    [self.liveWindowPanel seekTimeline:0];
    int64_t timeStamp = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    [self.curveSpeedView updataTimeline:timeStamp state:NO];
}

#pragma mark - NvCurveSpeedViewDelegate
- (void)nvCurveSpeedView:(NvCurveSpeedView *)speedView playbackStatus:(BOOL)status {
    if (!status) {
        [self.streamingContext stop];
    }
}

- (void)nvCurveSpeedViewDidEndEditing:(NvCurveSpeedView *)speedView {
    self.curveSpeedView.hidden = YES;
    [self.streamingContext stop];
}

- (void)nvCurveSpeedView:(NvCurveSpeedView *)speedView timelineSeekTo:(int64_t)timestamp playbackEOF:(BOOL)playbackEOF {
    if (timestamp < 0 || timestamp > self.timeline.duration) {
        return;
    }
    if ([self.streamingContext getStreamingEngineState] != NvsStreamingEngineState_Playback || playbackEOF == NO) {
        [_streamingContext seekTimeline:self.timeline timestamp:timestamp videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
    }
    
    self.liveWindowPanel.currentTime = timestamp;
}

- (void)nvCurveSpeedView:(NvCurveSpeedView *)speedView clip:(NvsVideoClip *)clip inPoint:(int64_t)inPoint outPoint:(int64_t)outPoint speedChangedPoints:(NSMutableArray *)points  {
    self.liveWindowPanel.duration = self.timeline.duration;
    self.curveId = self.curveSpeedUtils.curveSpeedsId;
    self.curvePointArr = points;
    self.curveSpeedUtils.curveSpeeds[self.curveSpeedUtils.curveSpeedsId] = points;
    self.currentClip = clip;
    /// seek到0,从头开始播放
    /// seek to 0 and play from the beginning
//    if ([self.streamingContext getStreamingEngineState] != NvsStreamingEngineState_Playback) {
//        [self.streamingContext seekTimeline:self.timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
//    }
    
    self.liveWindowPanel.currentTime = 0;
//    [self.liveWindowPanel playAtTime:0];
}

#pragma mark - NvNormalSpeedViewDelegate
- (void)nvNormalSpeedView:(NvNormalSpeedView *)speedView speed:(double)speed {
    [self.streamingContext stop];
    [self.currentClip changeSpeed:speed keepAudioPitch:speedView.keepAudioPitch];
    self.liveWindowPanel.duration = self.timeline.duration;
    self.normalSpeed = speed;
    self.curveSpeedUtils.curveSpeedsId = @"";
    self.curveId = @"none";
    [self.curvePointArr removeAllObjects];
}

- (void)nvNormalSpeedView:(NvNormalSpeedView *)speedView keepAudioPitch:(BOOL)keepAudioPitch {
    [self.currentClip changeSpeed:self.normalSpeed keepAudioPitch:keepAudioPitch];
}

- (void)nvFinishNormalSpeedView:(NvNormalSpeedView *)speedView {
    [self.normalSpeedView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(200*SCREENSCALE);
    }];
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)nvNormalSpeedViewChangedEnd:(NvNormalSpeedView *)speedView {
    self.liveWindowPanel.currentTime = 0;
    [self.liveWindowPanel playAtTime:0];
}

#pragma mark - lazyload
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(49*SCREENSCALE, 85*SCREENSCALE);
        layout.minimumLineSpacing = (SCREENWIDTH - 205*SCREENSCALE - 49*SCREENSCALE*self.speedCateArr.count)/(self.speedCateArr.count - 1);
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 102.5*SCREENSCALE, 0, 102.5*SCREENSCALE);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,SCREENWIDTH, 0) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[NvCaptureFilterCell class] forCellWithReuseIdentifier:@"NvSpeedID"];
    }
    return _collectionView;
}

- (NvCurveSpeedListView *)curveSpeedListView {
    if (!_curveSpeedListView) {
        _curveSpeedListView = [[NvCurveSpeedListView alloc] init];
        _curveSpeedListView.delegate = self;
    }
    return _curveSpeedListView;
}
@end
