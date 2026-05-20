//
//  NvEditNoiseSuppressionViewController.m
//  SDKDemo
//
//  Created by Meishe on 2022/9/9.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvEditNoiseSuppressionViewController.h"
#import "NvEditClipLiveWindow.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvStreamingSdkCore.h"
#import "NvNoiseSuppressionView.h"
#import "NvKeyFrameView.h"
#import "NvVolumeKeyFrameManager.h"
#import "NvCaptionCurveView.h"
#import "NvCustomCaptionBezierView.h"

@interface NvEditNoiseSuppressionViewController ()<NvNoiseSuppressionViewDelegate>
@property (nonatomic, strong) NvNoiseSuppressionView *sequenceView;
///播放控件
///Playback control
@property (nonatomic, strong) NvEditClipLiveWindow *clipLivewindow;
///这个时间线上只有一个片段
///There's only one fragment of this timeline
@property (nonatomic, strong) NvsTimeline *clipTimeline;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
///视频操作的片段对象
///A fragment object for a video operation
@property (nonatomic, strong) NvsVideoClip *videoClip;
@property (nonatomic, strong) NvsAudioFx *audioNoiseSuppressionFx;

@property (nonatomic, assign) BOOL isChange;
@property (nonatomic, assign) CGFloat scaleForSeek;
@end

@implementation NvEditNoiseSuppressionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.streamingContext = [NvSDKUtils getSDKContext];
    self.clipTimeline = [NvTimelineUtils createTimeline:self.editMode];
    
    [NvTimelineUtils resetEditData:self.clipTimeline editDataArray:[NSArray arrayWithObject:_model]];
    [NvTimelineUtils resetVideoFx:self.clipTimeline videoFxDataArray:[self getClipTimelineFilter:_model]];
    
    self.videoClip = [[self.clipTimeline getVideoTrackByIndex:0] getClipWithIndex:0];
    [NvTimelineUtils removeClipCropAndTransformFx:self.videoClip];
    
    [self addSubViews];
    [self.clipLivewindow play];
}

- (void)getAudioNoiseSuppressionFx {
    for (int i=0; i<self.videoClip.audioFxCount; i++) {
        NvsAudioFx * audioFx = [self.videoClip getAudioFxWithIndex:i];
        if ([audioFx.bultinAudioFxName isEqualToString: NoiseSuppressionFx]) {
            self.audioNoiseSuppressionFx = audioFx;
            break;
        }
    }
    if (!self.audioNoiseSuppressionFx) {
        self.audioNoiseSuppressionFx = [self.videoClip appendAudioFx:NoiseSuppressionFx];
    }
}


- (NSMutableArray *)getClipTimelineFilter:(NvEditDataModel *)clipInfo {
    NSUInteger index = [[NvTimelineData sharedInstance].editDataArray indexOfObject:clipInfo];
    NSMutableArray *filters = [[NvTimelineData sharedInstance] videoFxDataArray];
    NSMutableArray *clipFilters = NSMutableArray.new;
    if (filters.count > index) {
        NvTimeFilterInfoModel *filterModel = filters[index];
        NvTimeFilterInfoModel *clipFilter = [filterModel copy];
        clipFilter.inPoint = 0;
        clipFilter.outPoint = _clipTimeline.duration;
        [clipFilters addObject:clipFilter];
    } else {
        
    }
    return clipFilters;
}

- (void)addSubViews{
    
    self.clipLivewindow = [[NvEditClipLiveWindow alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width)];
    [self.view addSubview:self.clipLivewindow];
    [self.clipLivewindow connectTimeline:self.clipTimeline];
    self.clipLivewindow.editMode = self.editMode;
    [self.clipLivewindow setPlayRangeIn:0 rangeOut:self.model.trimOut/self.model.speed];
    [self.clipLivewindow seekTimeline:0];
    self.clipLivewindow.delegate = self;
    
    
    self.sequenceView = [NvNoiseSuppressionView new];
    self.sequenceView.delegate = self;
    self.sequenceView.timeline = self.clipTimeline;
//    self.sequenceView.keyframeButton.hidden = NO;
    [self.view addSubview:self.sequenceView];
    [self.sequenceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.height.equalTo(@(234*SCREENSCALE + INDICATOR));
    }];
 
    ///显示时间
    ///Display time
    [self.sequenceView setcurrentTime:[self.streamingContext getTimelineCurrentPosition:self.clipTimeline]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_model.audioNoiseSuppressionLevel > 0) {
        self.sequenceView.selectedIndex = _model.audioNoiseSuppressionLevel;
    }
}

#pragma mark - noiseSuppressionViewDelegate
- (void)noiseSuppressionViewdidAddOkClick {
    
    [self.streamingContext removeTimeline:self.clipTimeline];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)noiseSuppressionView:(NvNoiseSuppressionView *)view selectIndex:(NSInteger)index {
    if (index == 0) {
        [self.videoClip removeAudioFx:self.audioNoiseSuppressionFx.index];
        self.audioNoiseSuppressionFx = nil;
    }else {
        if (self.audioNoiseSuppressionFx == nil) {
            [self getAudioNoiseSuppressionFx];
        }
        int level = (int)index;
        [self.audioNoiseSuppressionFx setIntVal:NoiseSuppressionLevel val:level];
    }
    _model.audioNoiseSuppressionLevel = (int)index;
    [self.clipLivewindow playbackTimeline:0];
}

#pragma mark - 拖拽timelineEditor回调
///Drag and drop the timelineEditor callback
- (void)dragTimelineEditor:(int64_t)timestamp {
    self.isChange = YES;
    ///拖动过程中显示时间
    ///Show the time while dragging
    [self.sequenceView setcurrentTime:timestamp];
    [self seekTimeline:timestamp];
}

- (void)dragScrollTimelineEnded:(int64_t)timestamp {
    self.isChange = NO;
    [self seekTimeline:timestamp];
}

- (NvsAudioFx *)getAudioFx:(NvsVideoClip *)clip name:(NSString *)name {
    for (int i = 0; i < clip.audioFxCount; i++) {
        NvsAudioFx *videoFx = [clip getAudioFxWithIndex:i];
        if ([videoFx.bultinAudioFxName isEqualToString:name])
            return videoFx;
    }
    return nil;
}

///放大timelineEditor
///Enlarge the timelineEditor
- (void)noiseSuppressionTimelineEditorZoomIn {
    [self.sequenceView.timelineEditor zoomIn];
    [self.sequenceView setcurrentTime:[self.streamingContext getTimelineCurrentPosition:self.clipTimeline]];
}

///缩小timelineEditor
///Zoom out the timelineEditor
- (void)noiseSuppressionTimelineEditorZoomOut {
    [self.sequenceView.timelineEditor zoomOut];
    [self.sequenceView setcurrentTime:[self.streamingContext getTimelineCurrentPosition:self.clipTimeline]];
}


- (void)timelineEditor:(nonnull id)timelineEditor dragHandleEnded:(int64_t)timestamp isInPoint:(bool)isInPoint {
    
}


- (void)timelineEditor:(nonnull id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint {
    
}

// 定位某一时间戳的图像
- (void)seekTimeline:(int64_t)postion {
    int flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (self.isChange) {
        flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing;
        self.scaleForSeek = _clipTimeline.duration / 1000000 /  [self.sequenceView getTimelineEditorWidth] / UIScreen.mainScreen.scale;
        [_streamingContext setTimeline:_clipTimeline scaleForSeek:self.scaleForSeek];
    }
    if (![_streamingContext seekTimeline:_clipTimeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag]){
        NSLog(@"定位时间线失败！Failed to seek timeline!");
    }
    
    [_clipLivewindow updateUI:postion];
}

///播放过程中的回调
///Callbacks during playback
- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    
    self.sequenceView.playButton.selected = YES;
    [self.sequenceView.timelineEditor setTimelinePosition:position];
    ///播放过程中显示时间
    ///The time is displayed during playback
    [self.sequenceView setcurrentTime:position];
}

///播放停止的回调
///A callback that stops playing
- (void)didPlaybackStopped:(NvsTimeline *)timeline {
    int64_t timeStamp = [self.streamingContext getTimelineCurrentPosition:timeline];
    [self.sequenceView.timelineEditor setTimelinePosition:timeStamp];
    self.sequenceView.playButton.selected = NO;
}

///播放到末尾的回调
///Play to the end of the callback
- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    __block int64_t timePos = 0;
    
    [self.sequenceView.timelineEditor setTimelinePosition:timePos];
    [self seekTimeline:timePos];
}

-(void)dragEndStartTime:(int64_t)startTime withEndTime:(int64_t)endTime{
    [NvTimelineUtils playbackTimeline:self.clipTimeline startTime:startTime endTime:endTime flags:NvsStreamingEnginePlaybackFlag_LowPipelineSize|NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}

- (NSMutableArray *)numberArray:(NSMutableArray *)array{
    NSMutableArray *timeArr = [NSMutableArray array];
    for (NvVolumeKeyFrameInfo *model in array) {
        NSNumber *num = [NSNumber numberWithLongLong:model.pos];
        [timeArr addObject:num];
    }
    return timeArr;
}

@end
