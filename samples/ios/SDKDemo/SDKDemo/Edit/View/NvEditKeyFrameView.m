//
//  NvEditKeyFrameView.m
//  SDKDemo
//  编辑关键帧界面
//  Edit the keyframe interface
//  Created by MS on 2020/6/5.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvEditKeyFrameView.h"
#import "NvsVideoTrack.h"
#import "NvsVideoClip.h"
#import "NvKeyFrameButton.h"
#import "NVHeader.h"
#import "NvTimelineUtils.h"
#import "NvSDKUtils.h"

@interface NvEditKeyFrameView ()<NvsCTimelineEditorDelegate>
///编辑关键帧按钮
///Edit keyframe button
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *finishButton;
@property (nonatomic, strong) UISlider *strengthSlider;
///放大按钮
///Enlarge button
@property (nonatomic, strong) NvKeyFrameButton *zoomInBtn;
///缩小按钮
///Zoom button
@property (nonatomic, strong) NvKeyFrameButton *zoomOutBtn;
///上一帧按钮
///Previous frame button
@property (nonatomic, strong) NvKeyFrameButton *preFrameBtn;
///下一帧按钮
///Next frame button
@property (nonatomic, strong) NvKeyFrameButton *nextFrameBtn;
///控制关键帧按钮（添加、删除）
///Control key frame button (add, delete)
@property (nonatomic, strong) NvKeyFrameButton *managerFrameBtn;
@property (nonatomic, assign) int64_t trimIn;
@property (nonatomic, assign) int64_t trimOut;
@end
@implementation NvEditKeyFrameView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.atKeyFrameTime = NO;
        
        [self addSubviews];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.atKeyFrameTime = NO;
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    ///编辑关键帧按钮
    ///Edit keyframe button
    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.editButton];
    [self.editButton setTitle:NvLocalString(@"EditKeyFrame", @"编辑关键帧") forState:UIControlStateNormal];
    self.editButton.titleLabel.font = [UIFont systemFontOfSize:11*SCREENSCALE];
    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30*SCREENSCALE);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.mas_top);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.editButton.mas_bottom).offset(1);
        make.width.offset(SCREENWIDTH);
        make.height.offset(1.5);
    }];
    
    //slider
    self.strengthSlider = [[UISlider alloc]init];
    [self.strengthSlider setMinimumValue:0.0];
    [self.strengthSlider setMaximumValue:1.0];
    self.strengthSlider.value = 1.0;
    self.strengthSlider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    self.strengthSlider.maximumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    [self.strengthSlider setThumbImage:NvImageNamed(@"NvsliderWhite") forState:UIControlStateNormal];
    [self.strengthSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.strengthSlider];
    [self.strengthSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line.mas_bottom).offset(19*SCREENSCALE);
        make.centerX.equalTo(self.mas_centerX);
        make.width.offset(281 * SCREENSCALE);
        make.height.offset(10 * SCREENSCALE);
    }];
  
    self.timelineEditor = [[NvsCTimelineEditor alloc] init];
    self.timelineEditor.caneditTimeSpan = YES;
    _timelineEditor.canOverlapTimeSpan = NO;
    _timelineEditor.delegate = self;
    [self addSubview:_timelineEditor];
    [_timelineEditor mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line.mas_bottom).offset(45*SCREENSCALE);
        make.left.equalTo(self.mas_left).offset(40*SCREENSCALE);
        make.right.equalTo(self.mas_right).offset(-40*SCREENSCALE);
        make.height.mas_equalTo(45*SCREENSCALE);
    }];
    
    UIView *buttonBGView = [[UIView alloc] init];
    [self addSubview:buttonBGView];
    [buttonBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timelineEditor.mas_bottom).offset(12*SCREENSCALE);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.mas_equalTo(45*SCREENSCALE);
    }];
    
    CGFloat sepSpace = 0;
    CGFloat buttonWidth = 60*SCREENSCALE;
    CGFloat buttonSep = (SCREENWIDTH - 5*buttonWidth)/4;
    self.zoomInBtn = [NvKeyFrameButton buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"ZoomIn", @"缩小") withImageNormal:@"nv_edit_zoomOut" withImageSelected:nil];
    self.zoomInBtn.btnLabel.font = [UIFont systemFontOfSize:8*SCREENSCALE];
    [self.zoomInBtn addTarget:self action:@selector(zoomInClicked:) forControlEvents:UIControlEventTouchUpInside];
    [buttonBGView addSubview:self.zoomInBtn];
    [self.zoomInBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(buttonBGView.mas_left).offset(sepSpace);
        make.width.mas_equalTo(buttonWidth);
        make.top.equalTo(buttonBGView.mas_top);
        make.bottom.equalTo(buttonBGView.mas_bottom).offset(-3*SCREENSCALE);
    }];
    
    self.preFrameBtn = [NvKeyFrameButton buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Previous frame", @"上一帧") withImageNormal:@"nv_edit_preFrame" withImageSelected:nil];
    self.preFrameBtn.btnLabel.font = [UIFont systemFontOfSize:8*SCREENSCALE];
    [self.preFrameBtn addTarget:self action:@selector(preButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [buttonBGView addSubview:self.preFrameBtn];
    [self.preFrameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.zoomInBtn.mas_right).offset(buttonSep);
        make.width.mas_equalTo(buttonWidth);
        make.top.equalTo(buttonBGView.mas_top);
        make.bottom.equalTo(buttonBGView.mas_bottom).offset(-3*SCREENSCALE);
    }];
    
    self.managerFrameBtn = [NvKeyFrameButton buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Add key frame", @"增加关键帧") withImageNormal:@"nv_edit_addFrame" withImageSelected:nil];
    self.managerFrameBtn.btnLabel.font = [UIFont systemFontOfSize:8*SCREENSCALE];
    [self.managerFrameBtn addTarget:self action:@selector(managerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [buttonBGView addSubview:self.managerFrameBtn];
    [self.managerFrameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.preFrameBtn.mas_right).offset(buttonSep);
        make.width.mas_equalTo(buttonWidth);
        make.top.equalTo(buttonBGView.mas_top);
        make.bottom.equalTo(buttonBGView.mas_bottom).offset(-3*SCREENSCALE);
    }];
    
    self.nextFrameBtn = [NvKeyFrameButton buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Next frame", @"下一帧") withImageNormal:@"nv_edit_nextFrame" withImageSelected:nil];
    [self.nextFrameBtn addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.nextFrameBtn.btnLabel.font = [UIFont systemFontOfSize:8*SCREENSCALE];
    [buttonBGView addSubview:self.nextFrameBtn];
    [self.nextFrameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.managerFrameBtn.mas_right).offset(buttonSep);
        make.width.mas_equalTo(buttonWidth);
        make.top.equalTo(buttonBGView.mas_top);
        make.bottom.equalTo(buttonBGView.mas_bottom).offset(-3*SCREENSCALE);
    }];
    
    
    self.zoomOutBtn = [NvKeyFrameButton buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"ZoomOut", @"放大") withImageNormal:@"nv_edit_zoomIn" withImageSelected:nil];
    self.zoomOutBtn.btnLabel.font = [UIFont systemFontOfSize:8*SCREENSCALE];
    [self.zoomOutBtn addTarget:self action:@selector(zoomOutClicked:) forControlEvents:UIControlEventTouchUpInside];
    [buttonBGView addSubview:self.zoomOutBtn];
    [self.zoomOutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nextFrameBtn.mas_right).offset(buttonSep);
        make.width.mas_equalTo(buttonWidth);
        make.top.equalTo(buttonBGView.mas_top);
        make.bottom.equalTo(buttonBGView.mas_bottom).offset(-3*SCREENSCALE);
    }];
    
    UIView *sepLine = [[UIView alloc] init];
    sepLine.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self addSubview:sepLine];
    [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(buttonBGView.mas_bottom).offset(1);
        make.width.offset(SCREENWIDTH);
        make.height.offset(0.5);
    }];
    
    //finish button
    self.finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.finishButton setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [self.finishButton addTarget:self action:@selector(finshClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.finishButton];
    [self.finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sepLine.mas_bottom).offset(10*SCREENSCALE);
        make.centerX.equalTo(self.mas_centerX);
        make.width.offset(25 * SCREENSCALE);
        make.height.offset(20 * SCREENSCALE);
    }];
}

#pragma mark 滤镜强度调节
///Filter strength adjustment
- (void)sliderValueChanged:(UISlider *)slider{
    if([self.delegate respondsToSelector:@selector(nvEditKeyFrameViewSliderChanged:val:time:)]) {
        [self.delegate nvEditKeyFrameViewSliderChanged:self val:slider.value time:self.timelineEditor.timelinePosition];
    }
}

#pragma mark finshClick——完成按钮点击
///finshClick -- Complete button click
- (void)finshClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(nvEditKeyFrameViewFinishButtonClicked:)]) {
        [self.delegate nvEditKeyFrameViewFinishButtonClicked:self];
    }
}

///放大按钮点击方法
///Enlarge button click method
- (void)zoomInClicked:(UIButton *)sender {
    [self.timelineEditor zoomIn];
}

///缩小按钮点击方法
///Zoom out button click method
- (void)zoomOutClicked:(UIButton *)sender {
    [self.timelineEditor zoomOut];
}

#pragma mark - 点击关键帧按钮方法
///Click the keyframe button method
- (void)managerButtonClicked:(UIButton *)sender {
    if(!self.atKeyFrameTime) {
        if ([self.delegate respondsToSelector:@selector(nvEditKeyFrameViewAddKeyFrame:val:time:)]) {
            [self.delegate nvEditKeyFrameViewAddKeyFrame:self val:self.strengthSlider.value time:self.timelineEditor.timelinePosition];
        }
    }else{
        self.strengthSlider.value = 1;
        if ([self.delegate respondsToSelector:@selector(nvEditKeyFrameViewDeleteKeyFrame:time:)]) {
            [self.delegate nvEditKeyFrameViewDeleteKeyFrame:self time:self.timelineEditor.timelinePosition];
        }
    }
}

- (void)preButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(nvEditKeyFrameViewPreButtonClicked:)]) {
        [self.delegate nvEditKeyFrameViewPreButtonClicked:self];
    }
}

- (void)nextButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(nvEditKeyFrameViewNextButtonClicked:)]) {
        [self.delegate nvEditKeyFrameViewNextButtonClicked:self];
    }
}

- (void)updateFilterSliderStrength:(double)value {
    self.strengthSlider.value = value;
}

# pragma mark - NvsCTimelineEditorDelegate
- (void)timelineEditor:(id)timelineEditor dragHandleStarted:(int64_t)timestamp isInPoint:(bool)isInPoint {
}

- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint {
}

- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)timestamp isInPoint:(bool)isInPoint {

}

- (void)timelineEditor:(id)timelineEditor dragScrollingTimeline:(int64_t)timestamp {
    [timelineEditor setTimelinePosition:timestamp];
    int64_t scaleForSeek = self.timeline.duration / 1000000 /  [self.timelineEditor getTimelineEditorWidth] / UIScreen.mainScreen.scale;
    [[NvSDKUtils getSDKContext] setTimeline:_timeline scaleForSeek:scaleForSeek];
    [NvTimelineUtils seekTimeline:_timeline timestamp:timestamp flags:NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing];
    if ([self.delegate respondsToSelector:@selector(nvEditKeyFrameViewDragTimeline:time:)]) {
        [self.delegate nvEditKeyFrameViewDragTimeline:self time:timestamp];
    }
}

- (void)timelineEditor:(id)timelineEditor dragScrollTimelineEnded:(int64_t)timestamp {
    [NvTimelineUtils seekTimeline:_timeline timestamp:timestamp flags:NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
    if ([self.delegate respondsToSelector:@selector(nvEditKeyFrameViewDragTimelineEnded:time:)]) {
        [self.delegate nvEditKeyFrameViewDragTimelineEnded:self time:timestamp];
    }
}

#pragma mark - 设置按钮状态
///Set button status
- (void)setKeyFrameStatus:(int64_t)time hasKeyFrame:(BOOL)hasKeyFrame hasPreKeyFrame:(BOOL)hasPreKeyFrame hasNextKeyFrame:(BOOL)hasNextKeyFrame {
    if (hasKeyFrame) {
        self.managerFrameBtn.btnLabel.text = NvLocalString(@"Delete key frame", @"删除关键帧");
        self.managerFrameBtn.btnImageView.image = [UIImage imageNamed:@"nv_edit_deleteFrame"];
        self.atKeyFrameTime = YES;
    }else{
        self.managerFrameBtn.btnLabel.text = NvLocalString(@"Add key frame", @"增加关键帧");
        self.managerFrameBtn.btnImageView.image = [UIImage imageNamed:@"nv_edit_addFrame"];
        self.atKeyFrameTime = NO;
    }
    
    self.preFrameBtn.enabled = hasPreKeyFrame;
    self.nextFrameBtn.enabled = hasNextKeyFrame;
    if (hasPreKeyFrame) {
        self.preFrameBtn.alpha = 1.0;
    }else{
        self.preFrameBtn.alpha = 0.5;
    }
    if (hasNextKeyFrame) {
        self.nextFrameBtn.alpha = 1.0;
    }else{
        self.nextFrameBtn.alpha = 0.5;
    }
}

#pragma mark - setter
- (void)setTimeline:(NvsTimeline *)timeline {
    _timeline = timeline;
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    NSMutableArray *clipPath = [NSMutableArray array];
    for (int i = 0; i < videoTrack.clipCount; i++) {
        NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
        NvsCTimelineEditorInfo *info = [[NvsCTimelineEditorInfo alloc] init];
        info.mediaFilePath = clip.filePath;
        info.inPoint = clip.inPoint;
        info.outPoint = clip.outPoint;
        info.trimIn = clip.trimIn;
        info.trimOut = clip.trimOut;
        info.stillImageHint = false;
        [clipPath addObject:info];
    }
    
    [self.timelineEditor initTimelineEditor:clipPath timelineDuration:self.timeline.duration];
    self.timelineEditor.delegate = self;
}

- (void)setAssetStatus:(BOOL)assetStatus {
    _assetStatus = assetStatus;
    if (assetStatus) {
        ///播放状态
        ///Play state
        self.strengthSlider.enabled = NO;
        self.managerFrameBtn.enabled = NO;
        self.preFrameBtn.enabled = NO;
        self.nextFrameBtn.enabled = NO;
    }else {
        ///暂停状态
        ///Suspended state
        self.strengthSlider.enabled = YES;
        self.managerFrameBtn.enabled = YES;
    }
    if (!assetStatus) {
        self.managerFrameBtn.alpha = 1.0;
        self.preFrameBtn.alpha = 1.0;
        self.nextFrameBtn.alpha = 1.0;
    }else{
        self.managerFrameBtn.alpha = 1.0;
        self.preFrameBtn.alpha = 0.5;
        self.nextFrameBtn.alpha = 0.5;
    }

}

- (void)setTrimIn:(int64_t)trimIn trimOut:(int64_t)trimOut {
    self.trimIn = trimIn;
    self.trimOut = trimOut;
}

- (void)setKeyFrameArr:(NSMutableArray<NvKeyFrameFilterModel *> *)keyFrameArr {
    _keyFrameArr = keyFrameArr;
    NSMutableArray *timeArr = [NSMutableArray array];
    for (NvKeyFrameFilterModel *model in keyFrameArr) {
        if (model.time >= self.trimIn && model.time <= self.trimOut) {
            NSNumber *num = [NSNumber numberWithLongLong:model.time - self.trimIn];
            [timeArr addObject:num];
        }
    }
    [self.timelineEditor configKeyFrames:timeArr];
}
@end
