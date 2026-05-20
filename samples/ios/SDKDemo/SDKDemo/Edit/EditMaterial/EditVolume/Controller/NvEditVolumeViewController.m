//
//  NvEditVolumeViewController.m
//  SDKDemo
//
//  Created by ms on 2021/8/4.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvEditVolumeViewController.h"
#import "NvEditClipLiveWindow.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvStreamingSdkCore.h"
#import "NvVolumeSequenceView.h"
#import "NvKeyFrameView.h"
#import "NvVolumeKeyFrameManager.h"
#import "NvCaptionCurveView.h"
#import "NvCustomCaptionBezierView.h"

#define AudioVolumeFx @"Audio Volume"
#define FxCategory 2.0

@interface NvEditVolumeViewController ()
@property (nonatomic, strong) NvVolumeSequenceView *sequenceView;
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
@property (nonatomic, strong) NvKeyFrameView *volumeKeyframeView;
@property (nonatomic, strong) NSArray *volumeKeyArr;
@property (nonatomic, strong) NvsAudioFx *audioVolumeFx;
@property (nonatomic, strong) NvCaptionCurveView *volumeKeyCurveView;
/// 添加曲线运动的时间
/// Add the time of the curve motion
@property (nonatomic, assign) int64_t curveTime;

@property (nonatomic, strong) NvVolumeKeyFrameInfo *currentKeyframeInfo;

///音量模块
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) UILabel *volumeMaxlabel;
@property (nonatomic, strong) UILabel *volumeLabel;
@property (nonatomic, strong) UILabel *minlabel;

@property (nonatomic, assign) BOOL isChange;
@property (nonatomic, assign) CGFloat scaleForSeek;
@end

@implementation NvEditVolumeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.streamingContext = [NvSDKUtils getSDKContext];
    self.clipTimeline = [NvTimelineUtils createTimeline:self.editMode];
    self.volumeKeyArr = @[@"Left Gain", @"Right Gain"];
    
    [NvTimelineUtils resetEditData:self.clipTimeline editDataArray:[NSArray arrayWithObject:_model]];
    [NvTimelineUtils resetVideoFx:self.clipTimeline videoFxDataArray:[self getClipTimelineFilter:_model]];
    
    self.videoClip = [[self.clipTimeline getVideoTrackByIndex:0] getClipWithIndex:0];
    [NvTimelineUtils removeClipCropAndTransformFx:self.videoClip];
    
    self.audioVolumeFx = [self.videoClip getAudioVolumeFx];
    [self addSubViews];
    BOOL hasKeyFrame = [NvVolumeKeyFrameManager isExistKeyFrame:self.volumeKeyArr audioFx:self.audioVolumeFx];
    
    [self.sequenceView setKeyframeState:hasKeyFrame];
    
    [self.clipLivewindow play];

    [self setSlideStatus];
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
    
    
    self.sequenceView = [NvVolumeSequenceView new];
    self.sequenceView.delegate = self;
    self.sequenceView.timeline = self.clipTimeline;
    self.sequenceView.keyframeButton.hidden = NO;
    [self.view addSubview:self.sequenceView];
    [self.sequenceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.height.equalTo(@(234*SCREENSCALE + INDICATOR));
    }];
    
    UILabel *volumeLabel = [UILabel new];
    volumeLabel.text = NvLocalString(@"Volume", @"音量");
    volumeLabel.textColor = UIColor.whiteColor;
    volumeLabel.alpha = 0.8;
    volumeLabel.font = [NvUtils fontWithSize:12 * SCREENSCALE];
    [self.view addSubview:volumeLabel];
    self.volumeLabel = volumeLabel;
    
    UILabel *minlabel = [UILabel new];
    minlabel.text = @"0";
    minlabel.textColor = UIColor.whiteColor;
    minlabel.alpha = 0.8;
    minlabel.font = [NvUtils fontWithSize:12 * SCREENSCALE];
    [self.view addSubview:minlabel];
    self.minlabel = minlabel;
    self.minlabel.hidden = YES;
    
    self.volumeSlider = [UISlider new];
    [self.volumeSlider setMinimumValue:0];
    [self.volumeSlider setMaximumValue:100];
    self.volumeSlider.hidden = YES;
    self.volumeSlider.minimumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    self.volumeSlider.maximumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    [self.volumeSlider setThumbImage:NvImageNamed(@"Nvslider") forState:UIControlStateNormal];
    [self.volumeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.volumeSlider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpInside];
//    [self.volumeSlider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpOutside];
    [self.view addSubview:self.volumeSlider];
    
    self.volumeMaxlabel = [UILabel new];
    self.volumeMaxlabel.text = @"0";
    self.volumeMaxlabel.textColor = UIColor.whiteColor;
    self.volumeMaxlabel.alpha = 0.8;
    self.volumeMaxlabel.font = [NvUtils fontWithSize:12 * SCREENSCALE];
    [self.view addSubview:self.volumeMaxlabel];
    
    
    
    [volumeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sequenceView.mas_top).offset(20 * SCREENSCALE);
        make.left.equalTo(self.view).offset(13 * SCREENSCALE);
    }];
    
    [minlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(volumeLabel.mas_right).offset(18 * SCREENSCALE);
        make.centerY.equalTo(volumeLabel.mas_centerY);
    }];
    
    [self.volumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(minlabel.mas_right).offset(11 * SCREENSCALE);
        make.centerY.equalTo(volumeLabel.mas_centerY);
        make.width.offset(254 * SCREENSCALE);
        make.height.offset(10 * SCREENSCALE);
    }];
    
    [self.volumeMaxlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.volumeSlider.mas_right).offset(11 * SCREENSCALE);
        make.centerY.equalTo(volumeLabel.mas_centerY);
    }];
    
    self.volumeSlider.value = 0;
 
    [self.sequenceView setcurrentTime:[self.streamingContext getTimelineCurrentPosition:self.clipTimeline]];
}

-(void)sliderValueEnd:(UISlider *)slider{
    
    if (!self.volumeKeyframeView) {
        return;
    }
    
    CGFloat fxValue = slider.value * FxCategory / 100.0;
    int64_t timePos = [self.streamingContext getTimelineCurrentPosition:self.clipTimeline];
     NvVolumeKeyFrameInfo *keyframeInfo = [NvVolumeKeyFrameManager isExistKeyFrame:self.model.keyFramesArray timelinePos:timePos];

    if (keyframeInfo) {
        [self.audioVolumeFx setFloatValAtTime:@"Left Gain" val:fxValue time:keyframeInfo.pos];
        [self.audioVolumeFx setFloatValAtTime:@"Right Gain" val:fxValue time:keyframeInfo.pos];
        keyframeInfo.leftGainValue = [self.audioVolumeFx getFloatValAtTime:@"Left Gain" time:keyframeInfo.pos];
        keyframeInfo.rightGainValue = [self.audioVolumeFx getFloatValAtTime:@"Right Gain" time:keyframeInfo.pos];
        self.currentKeyframeInfo = keyframeInfo;
    }else{
        __block NvVolumeKeyFrameInfo *newKeyframeInfo = nil;
        [NvVolumeKeyFrameManager insertKeyframe:timePos keyframeSource:self.model.keyFramesArray audioFx:self.audioVolumeFx fxType:NvKeyframe_Volume completeHandler:^(NvVolumeKeyFrameInfo * _Nonnull keyModel, int index) {
            newKeyframeInfo = keyModel;
           
            [self.audioVolumeFx setFloatValAtTime:@"Left Gain" val:fxValue time:newKeyframeInfo.pos];
            [self.audioVolumeFx setFloatValAtTime:@"Right Gain" val:fxValue time:newKeyframeInfo.pos];
            newKeyframeInfo.leftGainValue = [self.audioVolumeFx getFloatValAtTime:@"Left Gain" time:newKeyframeInfo.pos];
            newKeyframeInfo.rightGainValue = [self.audioVolumeFx getFloatValAtTime:@"Right Gain" time:newKeyframeInfo.pos];
            [self.sequenceView.timelineEditor configKeyFrames:[self numberArray:self.model.keyFramesArray]];
            [self.sequenceView.timelineEditor configSelectKeyFrames:index];
            [self.volumeKeyframeView resetOptKeyFrameButton:YES];
            self.currentKeyframeInfo = newKeyframeInfo;
        }];
    }
    
}

- (void)sliderValueChanged:(UISlider *)slider{
    
    self.volumeMaxlabel.text = [NSString stringWithFormat:@"%.0f",slider.value];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}



#pragma mark - 关键帧编辑 Keyframe editing
- (void)nvVolumeSequenceViewShowKeyFrame:(BOOL)isHiden {
    if (self.volumeKeyframeView != nil) {
        self.sequenceView.keyframeButton.hidden = YES;
    }
    if (isHiden && self.volumeKeyframeView) {
        self.volumeKeyframeView.enablePrebutton  = NO;
        self.volumeKeyframeView.enableNextbutton = NO;
        self.volumeKeyframeView.enableAddbutton  = NO;
        return;
    }
    if (self.volumeKeyframeView != nil) {/// 已经进入关键帧编辑
        [self nvUpdateKeyframeStatus];
    }else {
        BOOL hasKeyFrame = [NvVolumeKeyFrameManager isExistKeyFrame:self.volumeKeyArr audioFx:self.audioVolumeFx];
        
        [self.sequenceView setKeyframeState:hasKeyFrame];
    }
}


- (void)nvAddVolumeViewShowKeyFrame:(BOOL)isHiden {
    if (self.volumeKeyframeView != nil) {
        self.sequenceView.keyframeButton.hidden = YES;
    }
    if (isHiden && self.volumeKeyframeView) {
        self.volumeKeyframeView.enablePrebutton  = NO;
        self.volumeKeyframeView.enableNextbutton = NO;
        self.volumeKeyframeView.enableAddbutton  = NO;
        return;
    }
    if (self.volumeKeyframeView != nil) {/// 已经进入关键帧编辑
        [self nvUpdateKeyframeStatus];
    }else {
        
        BOOL hasKeyFrame = [NvVolumeKeyFrameManager isExistKeyFrame:self.volumeKeyArr audioFx:self.audioVolumeFx];
        
        [self.sequenceView setKeyframeState:hasKeyFrame];
    }
}



#pragma mark - 界面刷新 Interface refresh
- (void)nvUpdateKeyframeStatus {
    self.volumeSlider.hidden = YES;
    int64_t timelinePos = [self.streamingContext getTimelineCurrentPosition:self.clipTimeline];
    __block NvVolumeKeyFrameInfo *keyframeModel = nil;
    [self.sequenceView.timelineEditor configKeyFrames:[self numberArray:self.model.keyFramesArray]];
    [NvVolumeKeyFrameManager fetchKeyframeStatus:timelinePos frameKeys:self.volumeKeyArr keyframeSource:self.model.keyFramesArray audioFx:self.audioVolumeFx completeHandler:^(BOOL previous, BOOL next, NvVolumeKeyFrameInfo * _Nullable keyModel, int index) {
        if (previous || next || keyModel) {
            [self.sequenceView setKeyframeState:YES];
        }else {
            [self.sequenceView setKeyframeState:NO];
        }

        if (self.volumeKeyframeView ) {
            [self.sequenceView setKeyframeAddCurve];
            self.sequenceView.keyframeButton.enabled = NO;
            self.sequenceView.keyframeButton.alpha = 0.5;
            if (keyModel) {
                
            }else if(previous && next){
                
                self.sequenceView.keyframeButton.enabled = YES;
                self.sequenceView.keyframeButton.alpha = 1;
                self.curveTime = [self.streamingContext getTimelineCurrentPosition:self.clipTimeline];
            }
        }
        
        self.volumeKeyframeView.enablePrebutton  = previous;
        self.volumeKeyframeView.enableNextbutton = next;
        self.volumeKeyframeView.enableAddbutton  = YES;
        [self.volumeKeyframeView resetOptKeyFrameButton: (keyModel== nil ? NO : YES)];
        if (keyModel != nil) {
            [self.sequenceView.timelineEditor setTimelinePosition:keyModel.pos];
            [self seekTimeline:keyModel.pos];
            [self.sequenceView.timelineEditor configSelectKeyFrames:index];
        }
        keyframeModel = keyModel;
    }];
    self.currentKeyframeInfo = keyframeModel;

    [self setSlideStatus];
}


#pragma mark - VolumeSequenceViewDelegate
- (void)nvVolumeSequenceViewdidAddOkClick {
    
    [self.streamingContext removeTimeline:self.clipTimeline];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nvVolumeSequenceViewdidAddKeyFrameClick {
    /// 关键帧编辑窗口
    /// Keyframe editing window
    self.volumeKeyframeView = [[NvKeyFrameView alloc] init];
    self.volumeKeyframeView.delegate = self;
    [self.volumeKeyframeView nv_fadeIn:self.view];
    self.sequenceView.keyframeButton.hidden = YES;

    /// 查询关键帧状态
    /// Example Query the key frame status
    [self nvUpdateKeyframeStatus];
}

- (void)nvVolumeSequenceCurveAdjustmentClick{
    self.volumeKeyCurveView = [[NvCaptionCurveView alloc] init];
    self.volumeKeyCurveView.delegate = self;
    self.volumeKeyCurveView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    self.volumeKeyCurveView.frame = CGRectMake(0, self.view.viewHeight - 260 * SCREENSCALE - INDICATOR, kScreenWidth, 260 * SCREENSCALE + INDICATOR);
    int64_t timePos = self.curveTime;

    __block NvVolumeKeyFrameInfo *preKeyframeModel = nil;
    [NvVolumeKeyFrameManager getPreKeyFrame:self.volumeKeyArr timelinePos:timePos keyframeSource:self.model.keyFramesArray audioFx:self.audioVolumeFx completeHandler:^(NvVolumeKeyFrameInfo * _Nonnull keyModel, int index, BOOL previous) {
        preKeyframeModel = keyModel;
    }];
    [self.volumeKeyCurveView setupSelectedDefault:preKeyframeModel.type];
    [self.view addSubview:self.volumeKeyCurveView];
}

///拖拽timelineEditor回调
///Drag and drop the timelineEditor callback
- (void)dragTimelineEditor:(int64_t)timestamp {
    self.isChange = YES;
    [self.sequenceView setcurrentTime:timestamp];
    [self seekTimeline:timestamp];
}

///拖拽timelineEditor结束回调
///Drag and drop timelineEditor to end the callback
- (void)dragScrollTimelineEnded:(int64_t)timestamp {
    self.isChange = NO;
    [self targetSeekToTimeStamp:timestamp];
}

#pragma mark - 拖动、停止、播放结束时需要做的工作
///Drag, stop, and end of play
- (void)targetSeekToTimeStamp:(int64_t)timeStamp {
    self.sequenceView.keyframeButton.hidden = NO;
    [self hiddenORShowAddCaptionView:timeStamp];
    [self seekTimeline:timeStamp];
    if (self.volumeKeyframeView != nil) {
        [self nvUpdateKeyframeStatus];
    }
}

- (void)hiddenORShowAddCaptionView:(int64_t)timeStamp {
    
    if (self.volumeKeyframeView != nil) {
        self.sequenceView.keyframeButton.hidden = YES;
    }
    
    BOOL hasKeyFrame = NO;
    
    hasKeyFrame = [NvVolumeKeyFrameManager isExistKeyFrame:self.volumeKeyArr audioFx:self.audioVolumeFx];
    [self.sequenceView setKeyframeState:hasKeyFrame];
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
- (void)volumeTimelineEditorZoomIn {
    [self.sequenceView.timelineEditor zoomIn];
    [self.sequenceView setcurrentTime:[self.streamingContext getTimelineCurrentPosition:self.clipTimeline]];
}
///缩小timelineEditor
///Zoom out the timelineEditor
- (void)volumeTimelineEditorZoomOut {
    [self.sequenceView.timelineEditor zoomOut];
    [self.sequenceView setcurrentTime:[self.streamingContext getTimelineCurrentPosition:self.clipTimeline]];
}

/// 定位某一时间戳的图像
/// Seeks to a certain timestamp of images
- (void)seekTimeline:(int64_t)postion {
    int flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (self.isChange) {
        flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing;
        self.scaleForSeek = self.clipTimeline.duration / 1000000 /  [self.sequenceView getTimelineEditorWidth] / UIScreen.mainScreen.scale;
    }
    if (![_streamingContext seekTimeline:_clipTimeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag])
        NSLog(@"定位时间线失败！ Failed to seek timeline!");

    [_clipLivewindow updateUI:postion];
}

#pragma mark - NvKeyFrameViewDelegate
- (void)nvKeyFrameView:(NvKeyFrameView *)view didReceive:(KeyFrameRespone)response {
    if (response == KeyFrame_Previous) {
        ///上一帧
        ///Previous frame
        int64_t timePos = [self.streamingContext getTimelineCurrentPosition:self.clipTimeline];
        __block NvVolumeKeyFrameInfo *keyframeModel = nil;
        
        [NvVolumeKeyFrameManager getPreKeyFrame:self.volumeKeyArr timelinePos:timePos keyframeSource:self.model.keyFramesArray audioFx:self.audioVolumeFx completeHandler:^(NvVolumeKeyFrameInfo * _Nonnull keyModel, int index, BOOL previous) {
            keyframeModel = keyModel;
            [self.sequenceView.timelineEditor setTimelinePosition:keyModel.pos];
            [self.sequenceView.timelineEditor configSelectKeyFrames:index];
            [self seekTimeline:keyModel.pos];
            [self.volumeKeyframeView resetOptKeyFrameButton:YES];
            self.volumeKeyframeView.enableNextbutton = YES;
            if (!previous && self.volumeKeyframeView) {
                self.volumeKeyframeView.enablePrebutton = NO;
            }
        }];

        self.currentKeyframeInfo = keyframeModel;
    }else if (response == KeyFrame_Next) {
        ///下一帧
        ///Next frame
        int64_t timePos = [self.streamingContext getTimelineCurrentPosition:self.clipTimeline];

        __block NvVolumeKeyFrameInfo *keyframeModel = nil;
        [NvVolumeKeyFrameManager getNextKeyFrame:self.volumeKeyArr timelinePos:timePos keyframeSource:self.model.keyFramesArray audioFx:self.audioVolumeFx completeHandler:^(NvVolumeKeyFrameInfo * _Nonnull keyModel, int index, BOOL next) {
            keyframeModel = keyModel;
            [self.sequenceView.timelineEditor setTimelinePosition:keyModel.pos];
            [self.sequenceView.timelineEditor configSelectKeyFrames:index];
            [self seekTimeline:keyModel.pos];
            [self.volumeKeyframeView resetOptKeyFrameButton:YES];
            self.volumeKeyframeView.enablePrebutton = YES;
            if (!next && self.volumeKeyframeView) {
                self.volumeKeyframeView.enableNextbutton = NO;
            }
        }];

        self.currentKeyframeInfo = keyframeModel;
    }else if (response == KeyFrame_Add) {
        /// 添加关键帧
        /// Add keyframe
        int64_t timePos = [self.streamingContext getTimelineCurrentPosition:self.clipTimeline];
        __block NvVolumeKeyFrameInfo *keyframeInfo = nil;
        
        [NvVolumeKeyFrameManager insertKeyframe:timePos keyframeSource:self.model.keyFramesArray audioFx:self.audioVolumeFx fxType:NvKeyframe_Volume completeHandler:^(NvVolumeKeyFrameInfo * _Nonnull keyModel, int index) {
            keyframeInfo = keyModel;
            [self.audioVolumeFx setFloatValAtTime:@"Left Gain" val:self.volumeSlider.value / 100.0 * FxCategory time:keyframeInfo.pos];
            [self.audioVolumeFx setFloatValAtTime:@"Right Gain" val:self.volumeSlider.value / 100.0 * FxCategory  time:keyframeInfo.pos];
            keyframeInfo.leftGainValue = [self.audioVolumeFx getFloatValAtTime:@"Left Gain" time:keyframeInfo.pos];
            keyframeInfo.rightGainValue = [self.audioVolumeFx getFloatValAtTime:@"Right Gain" time:keyframeInfo.pos];
            [self.sequenceView.timelineEditor configKeyFrames:[self numberArray:self.model.keyFramesArray]];
            [self.sequenceView.timelineEditor configSelectKeyFrames:index];
            [self.volumeKeyframeView resetOptKeyFrameButton:YES];
        }];

        
        self.currentKeyframeInfo = keyframeInfo;
    }else if (response == KeyFrame_Delete) {
        ///删除关键帧
        ///Delete key frame
        
        __weak typeof(self)weakSelf = self;
        
        
        [NvVolumeKeyFrameManager removeKeyFrame:self.volumeKeyArr keyframeSource:self.model.keyFramesArray keyframeTarget:self.currentKeyframeInfo audioFx:self.audioVolumeFx completeHandler:^{
            [self.sequenceView.timelineEditor configKeyFrames:[self numberArray:self.model.keyFramesArray]];
            /// 设置中间按钮
            /// Set the middle button
            BOOL previous = [NvVolumeKeyFrameManager isExistPreKeyFrame:self.currentKeyframeInfo.pos frameKeys:self.volumeKeyArr audioFx:self.audioVolumeFx];
            BOOL next     = [NvVolumeKeyFrameManager isExistNextKeyFrame:self.currentKeyframeInfo.pos frameKeys:self.volumeKeyArr audioFx:self.audioVolumeFx];

            [weakSelf.volumeKeyframeView resetOptKeyFrameButton:NO];
            weakSelf.volumeKeyframeView.enablePrebutton = previous;
            weakSelf.volumeKeyframeView.enableNextbutton = next;
            /// 重置数据
            /// Reset data
            if (self.model.keyFramesArray.count == 0) {
                [self seekTimeline:[self.streamingContext getTimelineCurrentPosition:self.clipTimeline]];
            }
        }];
        self.currentKeyframeInfo = nil;
    }
    [self setSlideStatus];
}

-(void)setSlideStatus{
    int64_t timePos = [self.streamingContext getTimelineCurrentPosition:self.clipTimeline];
    
    self.volumeSlider.hidden = !self.volumeKeyframeView;
    self.volumeLabel.hidden = !self.volumeKeyframeView;
    self.volumeMaxlabel.hidden = !self.volumeKeyframeView;
    CGFloat value = [self.audioVolumeFx getFloatValAtTime:@"Left Gain" time:timePos] / FxCategory * 100.0;
    self.volumeSlider.value = value;
    self.volumeMaxlabel.text = [NSString stringWithFormat:@"%.0f", value];
}

- (void)nvKeyFrameViewDidFinished:(NvKeyFrameView *)view {
    self.volumeKeyframeView.delegate = nil;
    [self.volumeKeyframeView nv_fadeOut];
    self.volumeKeyframeView = nil;
    self.sequenceView.keyframeButton.hidden = NO;
    ///从关键帧界面出来应刷新关键帧状态
    ///The key frame status should be refreshed after the key frame interface is displayed
    [self nvUpdateKeyframeStatus];
  
    [self.sequenceView.timelineEditor removeAllKeyFrameImageViews];
}


- (void)nvCaptionCurveViewDidFinished:(NvCaptionCurveView *)view{
    [self.volumeKeyCurveView removeFromSuperview];
    self.volumeKeyCurveView = nil;
}
- (void)nvCaptionCurveViewDidSelectModel:(NvCaptionCurveItem *)item{
    if (item.type == CurveAnimationTypeCustom) {
        NvCustomCaptionBezierView *view = [[NvCustomCaptionBezierView alloc] init];
        view.delegate = self;
        view.frame = CGRectMake(0, self.view.viewHeight - 300 * SCREENSCALE - INDICATOR, kScreenWidth, 300 * SCREENSCALE + INDICATOR);
        [self.view addSubview:view];
        /*
         给曲线视图的控制点设置初始位置
         Sets the initial position of the control point for the curve view
         */
        int64_t timePos = self.curveTime;
        __block NvVolumeKeyFrameInfo *preKeyframeModel = nil;
        [NvVolumeKeyFrameManager getPreKeyFrame:self.volumeKeyArr timelinePos:timePos keyframeSource:self.model.keyFramesArray audioFx:self.audioVolumeFx completeHandler:^(NvVolumeKeyFrameInfo * _Nonnull keyModel, int index, BOOL previous) {
            preKeyframeModel = keyModel;
        }];
        
        preKeyframeModel.type = CurveAnimationTypeCustom;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [view setupSelectedDefault:preKeyframeModel.leftPoint with:preKeyframeModel.rightPoint];
        });
    }else{
        CGPoint leftControlP = CGPointMake(0, 0);
        CGPoint rightControlP = CGPointMake(0, 0);
        if (item.type == CurveAnimationType1) {
            leftControlP = CGPointMake(0.333333, 0.333333);
            rightControlP = CGPointMake(0.666667, 0.666667);
        }else if (item.type == CurveAnimationType2){
            leftControlP = CGPointMake(0.5, 0);
            rightControlP = CGPointMake(1.0, 0.5);
        }else if (item.type == CurveAnimationType3){
            leftControlP = CGPointMake(0, 0.75);
            rightControlP = CGPointMake(0.25, 1.0);
        }else if (item.type == CurveAnimationType4){
            leftControlP = CGPointMake(1, 0);
            rightControlP = CGPointMake(0, 1);
        }else if (item.type == CurveAnimationType5){
            leftControlP = CGPointMake(0.0, 1.0);
            rightControlP = CGPointMake(1.0, 0.0);
        }else if (item.type == CurveAnimationType6){
            leftControlP = CGPointMake(0.5, 0);
            rightControlP = CGPointMake(0.5, 1);
        }else if (item.type == CurveAnimationType7){
            leftControlP = CGPointMake(0.75, 0.0);
            rightControlP = CGPointMake(1.0, 0.0);
        }
        
        int64_t timePos = self.curveTime;
        __block NvVolumeKeyFrameInfo *preKeyframeModel = nil;
        [NvVolumeKeyFrameManager getPreKeyFrame:self.volumeKeyArr timelinePos:timePos keyframeSource:self.model.keyFramesArray audioFx:self.audioVolumeFx completeHandler:^(NvVolumeKeyFrameInfo * _Nonnull keyModel, int index, BOOL previous) {
            preKeyframeModel = keyModel;
        }];
        __block NvVolumeKeyFrameInfo *nextKeyframeModel = nil;
        [NvVolumeKeyFrameManager getNextKeyFrame:self.volumeKeyArr timelinePos:timePos keyframeSource:self.model.keyFramesArray audioFx:self.audioVolumeFx completeHandler:^(NvVolumeKeyFrameInfo * _Nonnull keyModel, int index, BOOL next) {
            nextKeyframeModel = keyModel;
        }];

        preKeyframeModel.type = item.type;
        
        [self setCurveAnimationWithLeftKeyframe:preKeyframeModel RightKeyframe:nextKeyframeModel LeftPoint:leftControlP RightPoint:rightControlP];
    }
}


- (void)NvCustomCaptionBezierViewDidFinishedWithControlLeft:(CGPoint)controlLeft ControlRight:(CGPoint)controlRighty{

    int64_t timePos = self.curveTime;
    __block NvVolumeKeyFrameInfo *preKeyframeModel = nil;
    [NvVolumeKeyFrameManager getPreKeyFrame:self.volumeKeyArr timelinePos:timePos keyframeSource:self.model.keyFramesArray audioFx:self.audioVolumeFx completeHandler:^(NvVolumeKeyFrameInfo * _Nonnull keyModel, int index, BOOL previous) {
        preKeyframeModel = keyModel;
    }];
    __block NvVolumeKeyFrameInfo *nextKeyframeModel = nil;
    [NvVolumeKeyFrameManager getNextKeyFrame:self.volumeKeyArr timelinePos:timePos keyframeSource:self.model.keyFramesArray audioFx:self.audioVolumeFx completeHandler:^(NvVolumeKeyFrameInfo * _Nonnull keyModel, int index, BOOL next) {
        nextKeyframeModel = keyModel;
    }];
    [self setCurveAnimationWithLeftKeyframe:preKeyframeModel RightKeyframe:nextKeyframeModel LeftPoint:controlLeft RightPoint:controlRighty];
    
    preKeyframeModel.leftPoint = controlLeft;
    preKeyframeModel.rightPoint = controlRighty;
}

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {

    self.sequenceView.playButton.selected = YES;
    [self hiddenORShowAddCaptionViewOnCurrentTime];
    [self.sequenceView.timelineEditor setTimelinePosition:position];
   
    [self.sequenceView setcurrentTime:position];
    ///播放过程中关闭字幕关键帧编辑
    ///Turn off subtitle keyframe editing during playback
    if (self.volumeKeyframeView) {
        self.volumeKeyframeView.enablePrebutton  = NO;
        self.volumeKeyframeView.enableNextbutton = NO;
        self.volumeKeyframeView.enableAddbutton  = NO;
    }
    self.sequenceView.keyframeButton.hidden = YES;
    
    NSLog(@"left gain %f  pposition %lld", [self.audioVolumeFx getFloatValAtTime:@"Left Gain" time:position], position);
    CGFloat value = [self.audioVolumeFx getFloatValAtTime:@"Left Gain" time:position] / FxCategory * 100.0;
    self.volumeSlider.value = value;
    self.volumeMaxlabel.text = [NSString stringWithFormat:@"%.0f", value];
}

- (void)didPlaybackStopped:(NvsTimeline *)timeline {
    int64_t timeStamp = [self.streamingContext getTimelineCurrentPosition:timeline];
    [self.sequenceView.timelineEditor setTimelinePosition:timeStamp];
    self.sequenceView.playButton.selected = NO;
    self.sequenceView.keyframeButton.hidden = NO;
    [self targetSeekToTimeStamp:timeStamp];
}

- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    __block int64_t timePos = 0;
    if (self.volumeKeyCurveView) {
        timePos = self.curveTime;
        __block NvVolumeKeyFrameInfo *preKeyframeModel = nil;
        [NvVolumeKeyFrameManager getPreKeyFrame:self.volumeKeyArr timelinePos:timePos keyframeSource:self.model.keyFramesArray audioFx:self.audioVolumeFx completeHandler:^(NvVolumeKeyFrameInfo * _Nonnull keyModel, int index, BOOL previous) {
            preKeyframeModel = keyModel;
        }];
        timePos = preKeyframeModel.pos;
    }
    
    [self.sequenceView.timelineEditor setTimelinePosition:timePos];
    [self seekTimeline:timePos];
    [self targetSeekToTimeStamp:timePos];
}

- (void)hiddenORShowAddCaptionViewOnCurrentTime {
    int64_t currentTime = [self.streamingContext getTimelineCurrentPosition:self.clipTimeline];
    [self hiddenORShowAddCaptionView:currentTime];
}

-(void)setCurveAnimationWithLeftKeyframe:(NvVolumeKeyFrameInfo *)leftKeyframe RightKeyframe:(NvVolumeKeyFrameInfo *)rightKeyframe LeftPoint:(CGPoint)leftPoint RightPoint:(CGPoint)rightPoint {
    
    [NvVolumeKeyFrameManager insertKeyframeControlPoint:leftKeyframe RightKeyframe:rightKeyframe LeftPoint:leftPoint RightPoint:rightPoint audioFx:self.audioVolumeFx];
    
    [self dragEndStartTime:leftKeyframe.pos withEndTime:rightKeyframe.pos];
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
