//
//  NvMultiMusicView.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/9/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMultiMusicView.h"
#import <NvSDKCommon/NvLiveWindowPanelView.h>
#import "NvTimeLabelView.h"
#import "NvButton.h"
#import <NvSDKCommon/NvSDKUtils.h>

@interface NvMultiMusicView ()<NvLiveWindowPanelViewDelegate, NvTimeLabelViewDelegate, NvsCTimelineEditorDelegate>

@property (nonatomic, strong) UIView *line;

@property (nonatomic, assign) BOOL isChange;

@property (nonatomic, assign) CGFloat scaleForSeek;


@end

@implementation NvMultiMusicView {
    NvLiveWindowPanelView *liveWindowPanel;
    UIView *modifyPanelView;
    NvTimeLabelView *timeLabel;
    UIButton *playBtn;
    NvsCTimelineEditor *timelineEditor;
    NvsTimeline *_timeline;
    UIButton *addBtn;
    UIButton *fadeBtn;
    UILabel *fadeLabel;
    UISlider *volumeSlider;
    int64_t timelineDuration;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self initLiveWindowView];
    [self initModifyPanelView];
    [self checkAudioState];
    return self;
}

- (void)initLiveWindowView {
    liveWindowPanel = [[NvLiveWindowPanelView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.width)];
    liveWindowPanel.delegate = self;
    liveWindowPanel.forceHiddenControlPanel = YES;
    [self addSubview:liveWindowPanel];
    [liveWindowPanel addTapScreenPause];
}

- (void)setupLiveWindow:(NvsTimeline *)timeline {
    [liveWindowPanel connectTimeline:timeline];
    liveWindowPanel.editMode = self.editMode;
    timelineDuration = timeline.duration;
    timeLabel.duration = timelineDuration;
    [timeLabel updateLabel];
    _timeline = timeline;
}

- (void)initModifyPanelView {
    modifyPanelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 214*SCREENSCALE + INDICATOR)];
    [self addSubview:modifyPanelView];
    [modifyPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self);
        }
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.offset(214 * SCREENSCALE + INDICATOR);
    }];
    [self initAddView];
    [self initTimespan];
    [self initVolumeSlider];
}

- (void)initVolumeSlider {
    volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(SCREENWIDTH-125*SCREENSCALE, liveWindowPanel.centerY, 191*SCREENSCALE, 20*SCREENSCALE)];
    volumeSlider.maximumValue = 4;
    volumeSlider.value = [self getVolume:0];
    [volumeSlider setThumbImage:NvImageNamed(@"NvSliderHandle") forState:UIControlStateNormal];
    [self addSubview:volumeSlider];
    volumeSlider.transform = CGAffineTransformRotate(volumeSlider.transform, -M_PI_2);
    [volumeSlider addTarget:self action:@selector(volumeChanged:) forControlEvents:UIControlEventValueChanged];
    volumeSlider.hidden = !addBtn.selected;
}

- (void)initTimeLabelView {
    timeLabel = [[NvTimeLabelView alloc] initWithFrame:CGRectMake(0, 5*SCREENSCALE, SCREENWIDTH, 40*SCREENSCALE)];
    timeLabel.duration = timelineDuration;
    timeLabel.currentPos = 0;
    timeLabel.delegate = self;
    [modifyPanelView addSubview: timeLabel];
}

- (void)initSequenceView {
    timelineEditor = [[NvsCTimelineEditor alloc] initWithFrame:CGRectMake(0, 40*SCREENSCALE, [UIScreen mainScreen].bounds.size.width, 49*SCREENSCALE)];
    timelineEditor.caneditTimeSpan = YES;
    timelineEditor.canOverlapTimeSpan = NO;
    
    timelineEditor.delegate = self;
    [modifyPanelView addSubview:timelineEditor];
    
    playBtn = [[NvButton alloc] initWithFrame:CGRectMake(0, 0, 49*SCREENSCALE, 49*SCREENSCALE)];
    playBtn.backgroundColor = UIColorFromRGB(0x242728);
    [playBtn setImage:[UIImage imageNamed:@"NvPlayback"] forState:UIControlStateNormal];
    [timelineEditor addSubview:playBtn];
    [playBtn addTarget:self action:@selector(onPlayClicked) forControlEvents:UIControlEventTouchUpInside];
    playBtn.selected = YES;
    [playBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [playBtn removeObserver:self forKeyPath:@"selected"];
    [addBtn removeObserver:self forKeyPath:@"selected"];
    [fadeBtn removeObserver:self forKeyPath:@"selected"];
}

- (void)setupSequenceView:(NSMutableArray *)descArray {
    [timelineEditor initTimelineEditor:descArray timelineDuration:timelineDuration];
}

- (void)onPlayClicked {
    if ([self.delegate respondsToSelector:@selector(onPlayClicked)]) {
        playBtn.selected = !playBtn.selected;
        [self.delegate onPlayClicked];
    }
}

- (void)initAddView {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25*SCREENSCALE, 20*SCREENSCALE)];
    [button setImage:[UIImage imageNamed:@"Nvcheck - material"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onFinishAddMusic) forControlEvents:UIControlEventTouchUpInside];
    [modifyPanelView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self->modifyPanelView.mas_bottom).offset(-12 * SCREENSCALE - INDICATOR);
        make.centerX.equalTo(self->modifyPanelView);
        make.height.with.offset(25 * SCREENSCALE);
    }];
    
    self.line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 1)];
    self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [modifyPanelView addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(button.mas_top).offset(-12*SCREENSCALE);
    }];
    
    addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 40*SCREENSCALE, 40*SCREENSCALE)];
    [addBtn addTarget:self action:@selector(onAddMusicClicked) forControlEvents:UIControlEventTouchUpInside];
    [addBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    addBtn.selected = [timelineEditor isInTimespan:0];
    [addBtn setImage:[UIImage imageNamed:@"NvAddCaptionButton"] forState:UIControlStateNormal];
    [modifyPanelView addSubview:addBtn];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self->modifyPanelView);
        make.width.height.equalTo(@(40*SCREENSCALE));
        make.bottom.equalTo(button.mas_top).offset(-26*SCREENSCALE);
    }];
    
    fadeBtn = [[UIButton alloc] initWithFrame:CGRectMake(255*SCREENSCALE, 110*SCREENSCALE, 15*SCREENSCALE, 15*SCREENSCALE)];
    [fadeBtn setImage:[UIImage imageNamed:@"NvRadioUnselect"] forState:UIControlStateNormal];
    [modifyPanelView addSubview:fadeBtn];
    [fadeBtn addTarget:self action:@selector(onFadeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [fadeBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    fadeBtn.selected = [self isFade:0];
    [fadeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self->addBtn).offset(70*SCREENSCALE);
        make.centerY.mas_equalTo(self->addBtn);
        make.width.mas_equalTo(15*SCREENSCALE);
        make.height.mas_equalTo(15*SCREENSCALE);
    }];
    fadeBtn.hidden = !addBtn.selected;
    
    fadeLabel = [[UILabel alloc] initWithFrame:CGRectMake(255*SCREENSCALE, 110*SCREENSCALE, 100*SCREENSCALE, 15*SCREENSCALE)];
    fadeLabel.text = NvLocalString(@"Fade", @"淡入淡出");
    fadeLabel.font = [UIFont systemFontOfSize:12*SCREENSCALE];
    fadeLabel.textColor = [UIColor whiteColor];
    [modifyPanelView addSubview:fadeLabel];
    [fadeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self->fadeBtn.mas_right).offset(5*SCREENSCALE);
        make.centerY.mas_equalTo(self->fadeBtn);
        make.width.mas_equalTo(100*SCREENSCALE);
        make.height.mas_equalTo(15*SCREENSCALE);
    }];
    fadeLabel.hidden = !addBtn.selected;
    
    UIView *sequenceView = [UIView new];
    [modifyPanelView addSubview:sequenceView];
    sequenceView.backgroundColor = [UIColor clearColor];
    [sequenceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(49*SCREENSCALE));
        make.left.right.equalTo(@0);
        make.bottom.equalTo(self->addBtn.mas_top).offset(-26*SCREENSCALE);
    }];
    
    timelineEditor = [[NvsCTimelineEditor alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 49 * SCREENSCALE)];
    timelineEditor.caneditTimeSpan = YES;
    timelineEditor.canOverlapTimeSpan = NO;
    timelineEditor.delegate = self;
    [sequenceView addSubview:timelineEditor];
    
    playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 49*SCREENSCALE, 49*SCREENSCALE)];
    playBtn.backgroundColor = UIColorFromRGB(0x242728);
    [playBtn setImage:[UIImage imageNamed:@"NvPlayback"] forState:UIControlStateNormal];
    [timelineEditor addSubview:playBtn];
    [playBtn addTarget:self action:@selector(onPlayClicked) forControlEvents:UIControlEventTouchUpInside];
    playBtn.selected = YES;
    [playBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@(49*SCREENSCALE));
        make.left.equalTo(@0);
        make.bottom.equalTo(self->addBtn.mas_top).offset(-26*SCREENSCALE);
    }];
    
    timeLabel = [[NvTimeLabelView alloc] initWithFrame:CGRectMake(0, 5*SCREENSCALE, SCREENWIDTH, 40*SCREENSCALE)];
    timeLabel.duration = timelineDuration;
    timeLabel.currentPos = 0;
    timeLabel.delegate = self;
    [modifyPanelView addSubview: timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(20*SCREENSCALE));
        make.left.right.equalTo(@0);
        make.bottom.equalTo(sequenceView.mas_top).offset(-16*SCREENSCALE);
    }];
}

- (void)addMusicFade{
    if ([self.delegate respondsToSelector:@selector(onFadeBtnClicked:)]) {
        [self.delegate onFadeBtnClicked:true];
    }
}

- (void)onFadeBtnClicked {
    if ([self.delegate respondsToSelector:@selector(onFadeBtnClicked:)]) {
        fadeBtn.selected = !fadeBtn.selected;
        [self.delegate onFadeBtnClicked:fadeBtn.selected];
    }
}

- (void)deleteAllmusic{
    [timelineEditor deleteAllTimeSpan];
}

- (void)onAddMusicClicked {
    if (addBtn.selected) {
        if ([self.delegate respondsToSelector:@selector(onDeleteMusicClicked)]) {
            [self.delegate onDeleteMusicClicked];
            [timelineEditor deleteSelectedTimeSpan];
            addBtn.selected = NO;
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(onAddMusicClicked)]) {
            [self.delegate onAddMusicClicked];
        }
    }
}

- (void)initFinishView {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH/2 - 12*SCREENSCALE, modifyPanelView.height - 35*SCREENSCALE - INDICATOR, 25*SCREENSCALE, 20*SCREENSCALE)];
    [button setImage:[UIImage imageNamed:@"Nvcheck - material"] forState:UIControlStateNormal];
    [modifyPanelView addSubview:button];
    
    [button addTarget:self action:@selector(onFinishAddMusic) forControlEvents:UIControlEventTouchUpInside];
    
    self.line = [[UIView alloc] initWithFrame:CGRectMake(0, button.top - 16*SCREENSCALE, SCREENWIDTH, 1)];
    self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [modifyPanelView addSubview:self.line];
}

- (void)onFinishAddMusic {
    if ([self.delegate respondsToSelector:@selector(onFinishAddMusic)]) {
        [self.delegate onFinishAddMusic];
    }
}

- (void)updateTimelineEditor:(int64_t)pos {
    [timelineEditor setTimelinePosition:pos];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selected"]) {
        if ([object isEqual:playBtn]) {
            if (playBtn.selected) {
                [playBtn setImage:[UIImage imageNamed:@"NvPlayback"] forState:UIControlStateNormal];
            } else {
                [playBtn setImage:[UIImage imageNamed:@"NvPause"] forState:UIControlStateNormal];
                [timelineEditor clearTimeSpanSelection];
            }
        } else if ([object isEqual:addBtn]) {
            if (addBtn.selected) {
                [addBtn setImage:[UIImage imageNamed:@"deleteRecord"] forState:UIControlStateNormal];
            } else {
                [addBtn setImage:[UIImage imageNamed:@"NvAddCaptionButton"] forState:UIControlStateNormal];
            }
            fadeBtn.hidden = !addBtn.selected;
            fadeLabel.hidden = !addBtn.selected;
            volumeSlider.hidden = !addBtn.selected;
        } else if ([object isEqual:fadeBtn]) {
            if (fadeBtn.selected) {
                [fadeBtn setImage:[UIImage imageNamed:@"NvRadioSelect"] forState:UIControlStateNormal];
            } else {
                [fadeBtn setImage:[UIImage imageNamed:@"NvRadioUnselect"] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)addTimespan:(int64_t)inPoint outPoint:(int64_t)outPoint {
    [timelineEditor addTimeSpan:inPoint outPoint:outPoint];
    addBtn.selected = [timelineEditor isInTimespan:inPoint];
    fadeBtn.selected = [self isFade:inPoint];
    volumeSlider.value = [self getVolume:inPoint];
}

///检查两个音乐时间线位置是否重合继而作出改变
///Check to see if the two timelines coincide and make changes
- (void)checkAudioState {
    addBtn.selected = [timelineEditor isInTimespan:timeLabel.currentPos];
    fadeBtn.selected = [self isFade:timeLabel.currentPos];
    volumeSlider.value = [self getVolume:timeLabel.currentPos];
}
#pragma mark NvLiveWindowPanelViewDelegate
- (void)playback{
    playBtn.selected = NO;
}

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    [timelineEditor setTimelinePosition:position];
    
    timeLabel.currentPos = position;
    [timeLabel updateLabel];
    [self checkAudioState];
}

- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    [timelineEditor clearTimeSpanSelection];
    int64_t curPos = 0;
    [timelineEditor setTimelinePosition:curPos];
    [timelineEditor selectTimeSpanByPosition:curPos];
    [NvTimelineUtils seekTimeline:timeline timestamp:curPos flags:NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
    timeLabel.currentPos = curPos;
    [timeLabel updateLabel];
    playBtn.selected = YES;

    [self checkAudioState];
}

- (void)didPlaybackStopped:(NvsTimeline *)timeline {
    [timelineEditor clearTimeSpanSelection];
    [timelineEditor selectTimeSpanByPosition:timeLabel.currentPos];
    
    [self checkAudioState];
    playBtn.selected = YES;
}

#pragma mark NvTimeLabelViewDelegate
- (void)onZoomInClicked {
    [timelineEditor zoomIn];
}

- (void)onZoomOutClicked {
    [timelineEditor zoomOut];
}

# pragma mark 代理NvsCTimelineEditorDelegate
- (void)timelineEditor:(id)timelineEditor dragHandleStarted:(int64_t)timestamp isInPoint:(bool)isInPoint {
}

- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint {
}

- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)timestamp isInPoint:(bool)isInPoint {
    if ([self.delegate respondsToSelector:@selector(updateMusicInfo:isInPoint:with:)]) {
        [self.delegate updateMusicInfo:timestamp isInPoint:isInPoint with:(NvsCTimelineEditor *)timelineEditor];
        addBtn.selected = [timelineEditor isInTimespan:timeLabel.currentPos];
        fadeBtn.selected = [self isFade:timeLabel.currentPos];
        volumeSlider.value = [self getVolume:timeLabel.currentPos];
    }
}

- (void)timelineEditor:(id)timelineEditor dragScrollingTimeline:(int64_t)timestamp {
    self.isChange = YES;
    self.scaleForSeek = _timeline.duration / 1000000 /  [timelineEditor getTimelineEditorWidth] / UIScreen.mainScreen.scale;
    [timelineEditor setTimelinePosition:timestamp];
    [self seekTimeline:timestamp];
    timeLabel.currentPos = timestamp;
    [timeLabel updateLabel];
    
    if (_timeline.duration - timestamp <= NV_TIME_BASE) {
        addBtn.hidden = YES;
    }else{
        addBtn.hidden = NO;
        for (NvMusicInfoModel *model in [[NvTimelineData sharedInstance] musicDataArray]) {
            if (timestamp < model.inPoint && model.inPoint - timestamp <= NV_TIME_BASE) {
                addBtn.hidden = YES;
                break;
            }
        }
    }
    addBtn.selected = [timelineEditor isInTimespan:timestamp];
    fadeBtn.selected = [self isFade:timeLabel.currentPos];
    volumeSlider.value = [self getVolume:timeLabel.currentPos];
}

- (void)timelineEditor:(id)timelineEditor dragScrollTimelineEnded:(int64_t)timestamp{
    self.isChange = NO;
    [self seekTimeline:timestamp];
}

// 定位某一时间戳的图像
- (void)seekTimeline:(int64_t)postion {
    int flag = NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (self.isChange) {
        flag = NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing;
        [[NvSDKUtils getSDKContext] setTimeline:_timeline scaleForSeek:self.scaleForSeek];
    }
    if (![[NvSDKUtils getSDKContext] seekTimeline:_timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag])
        NSLog(@"定位时间线失败！Failed to seek timeline!");
    liveWindowPanel.progressSlider.value = 1.0*postion/_timeline.duration;
    liveWindowPanel.currentTime = postion;
}

- (BOOL)isFade:(int64_t)position {
    NSMutableArray *musicInfoArray = [[NvTimelineData sharedInstance] musicDataArray];
    for (NvMusicInfoModel *info in musicInfoArray) {
        if (position >= info.inPoint && position <= info.outPoint) {
            return info.isFade;
        }
    }
    return NO;
}

- (void)initTimespan {
    NSMutableArray *musicInfoArray = [[NvTimelineData sharedInstance] musicDataArray];
    for (NvMusicInfoModel *info in musicInfoArray) {
        [timelineEditor addTimeSpan:info.inPoint outPoint:info.outPoint];
    }
}

- (float)getVolume:(int64_t)position {
    NSMutableArray *musicInfoArray = [[NvTimelineData sharedInstance] musicDataArray];
    for (NvMusicInfoModel *info in musicInfoArray) {
        if (position >= info.inPoint && position <= info.outPoint) {
            return info.volume;
        }
    }
    return 1;
}

- (void)volumeChanged:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(onVolumeChanged:)]) {
        [self.delegate onVolumeChanged:slider.value];
    }
}
@end
