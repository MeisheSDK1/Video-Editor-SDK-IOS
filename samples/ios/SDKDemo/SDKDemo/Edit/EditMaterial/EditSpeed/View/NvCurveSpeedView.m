//
//  NvCurveSpeedView.m
//  SDKDemo
//
//  Created by MS on 2020/11/25.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvCurveSpeedView.h"
#import "NvBezierSpeedView.h"
#import "NvBezierUtils.h"
#import "NVHeader.h"
@interface NvCurveSpeedView ()<NvBezierSpeedViewDelegate>

@property (nonatomic, assign) int64_t originalDuration;
@property (nonatomic, copy) void (^curveSpeedStateHandle)(int64_t positon,BOOL engineStatus);

@property (nonatomic, strong) NvsVideoClip *currentClip;
@property (nonatomic, strong) NSString *curveName;

@property (nonatomic, assign) NSInteger nextIndex;
@property (nonatomic, strong) NSMutableArray *curvePoints;
@property (nonatomic, assign) CGFloat curveRangeMin;
@property (nonatomic, assign) CGFloat curveRangeMax;
@property (nonatomic, assign) CGPoint currentCurvePoint;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) UIButton *operationButton;
@property (nonatomic, strong) UIButton *durationButton;
@property (nonatomic, strong) NvBezierSpeedView *bezierView;
@end
@implementation NvCurveSpeedView

- (instancetype)initWithFrame:(CGRect)frame curveName:(NSString *)curveName clip:(NvsVideoClip *)clip inPoint:(int64_t)inPoint outPoint:(int64_t)outPoint {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorFromRGB(0x242728);
        self.nextIndex = 1;
        self.curveRangeMin = 0.1;
        self.curveRangeMax = 10;
        self.isPlayback = NO;
        self.currentCurvePoint = CGPointZero;
        self.curveName = curveName;
        self.currentClip = clip;
        self.outPoint = outPoint;
        self.inPoint = inPoint;
        self.originalDuration = self.outPoint - self.inPoint;
        self.curvePoints = [NSMutableArray array];
        self.curveId = @"None";
        [self addTopBar];
        [self addCurveView];
        [self addBottomView];
    }
    return self;
}

- (void)configOperationState:(BOOL)enable {
    self.operationButton.enabled = enable;
    self.operationButton.alpha = enable ? 1.0 : 0.5;
}

- (void)addCurveView {
    CGFloat y = 14.5*SCREENSCALE + 30*SCREENSCALE;
    CGRect rect = CGRectMake(0, y, SCREENWIDTH, CGRectGetHeight(self.frame) - y - 25*SCREENSCALE);
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(35*SCREENSCALE, 19*SCREENSCALE, 35*SCREENSCALE, 19*SCREENSCALE);
    self.bezierView = [[NvBezierSpeedView alloc] initWithFrame:rect edgeInsets:edgeInsets];
    self.bezierView.delegate = self;
    [self addSubview:self.bezierView];
}

- (void)addTopBar {
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 14.5*SCREENSCALE, SCREENWIDTH, 30*SCREENSCALE)];
    topBar.backgroundColor = UIColorFromRGB(0x242728);
    [self addSubview:topBar];
    self.operationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.operationButton.frame = CGRectMake(SCREENWIDTH - 19*SCREENSCALE - 54 * SCREENSCALE, 10 * SCREENSCALE, 54 * SCREENSCALE, 20 * SCREENSCALE);
    [self.operationButton setTitle:NvLocalString(@"Delete the point", @"- 删除点") forState:UIControlStateNormal];
    [self.operationButton setTitle:NvLocalString(@"Delete the point", @"- 删除点") forState:UIControlStateHighlighted];
    [self.operationButton.titleLabel setFont:[UIFont systemFontOfSize:10*SCREENSCALE]];
    self.operationButton.backgroundColor = [UIColor nv_colorWithHexString:@"#4A90E2"];
    self.operationButton.layer.cornerRadius = 2*SCREENSCALE;
    self.operationButton.layer.masksToBounds = YES;
    [topBar addSubview:self.operationButton];
    [self.operationButton addTarget:self action:@selector(didTapOperation) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addBottomView {
    CGFloat bottomH = INDICATOR + 37*SCREENSCALE;
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - bottomH, SCREENWIDTH, 0.5)];
    bottomLineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    [self addSubview:bottomLineView];
    
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishButton setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [self addSubview:finishButton];
    [finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@(25*SCREENSCALEHEIGHT));
        make.height.equalTo(@(20*SCREENSCALE));
        make.bottom.equalTo(@(-15*SCREENSCALE));
    }];
    [finishButton addTarget:self action:@selector(finishButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetBtn setTitle:NvLocalString(@"Reset", @"重置") forState:UIControlStateNormal];
    [resetBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [resetBtn addTarget:self action:@selector(resetBtnClick) forControlEvents:UIControlEventTouchUpInside];
    resetBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [resetBtn setTitleColor:[UIColor nv_colorWithHexString:@"#DFDFDF"] forState:UIControlStateNormal];
    [self addSubview:resetBtn];
    [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(17*SCREENSCALE);
        make.width.equalTo(@(30));
        make.height.equalTo(@(20));
        make.centerY.equalTo(finishButton.mas_centerY);
    }];
    
    
}

- (void)refreshCurveSpeeds:(NSMutableArray *)points {
    CGFloat speedW = self.bezierView.bounds.size.width - 38*SCREENSCALE;
    CGFloat percent = speedW / self.originalDuration;
    [self.curvePoints removeAllObjects];
    for (int i=0; i<points.count; i++) {
        CGPoint point = [points[i] CGPointValue];
        CGPoint newPoint = CGPointMake(percent*point.x, point.y);
        [self.curvePoints addObject:[NSValue valueWithCGPoint:newPoint]];
    }
    
    ///设置贝塞尔曲线的点
    ///Set the point of the Bezier curve
    NvCurveInfo *curveInfo = [NvCurveInfo new];
    curveInfo.minValue = self.curveRangeMin;
    curveInfo.maxValue = self.curveRangeMax;
    curveInfo.chartsArr = self.curvePoints;
    self.bezierView.originSpeed = curveInfo;
    
    self.bezierView.pointIndex = 0;
    self.currentCurvePoint = [self.curvePoints[0] CGPointValue];
    [self updateDuration];
    
    if (!self.currentClip) {
        return;
    }
    NvsVideoClip *clip = self.currentClip;
    if ([self.delegate respondsToSelector:@selector(nvCurveSpeedView:timelineSeekTo:playbackEOF:)]) {
        [self.delegate nvCurveSpeedView:self timelineSeekTo:clip.inPoint playbackEOF:YES];
    }
    [self.bezierView positionAnimation:0 isPlaying:NO];
    self.isSelected = YES;
    [self configOperationState:NO];
}

- (void)finishButtonClicked:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(nvCurveSpeedViewDidEndEditing:)]) {
        [self.delegate nvCurveSpeedViewDidEndEditing:self];
    }
}
    
///重置按钮点击事件
///Reset button click event
- (void)resetBtnClick {
    NSMutableArray *points = [NvBezierUtils fetchDefaultCurvePoints:self.curveId duration:self.originalDuration];
    NvCurveInfo *info = [NvCurveInfo new];
    info.chartsArr = points;
    info.minValue = 0.1;
    info.maxValue = 10;
    self.curveInfo = info;
}

///添加、删除变速点事件
///Add and delete shift point events
- (void)didTapOperation {
    NSInteger opIndex = self.nextIndex;
    if (opIndex<1) {
        return;
    }
    CGPoint dePoint = [self.curvePoints[opIndex-1] CGPointValue];
    CGFloat speedW = self.bezierView.bounds.size.width - 38*SCREENSCALE;
    /// 先停止播放
    /// Stop playing first
    if (self.delegate && [self.delegate respondsToSelector:@selector(nvCurveSpeedView:playbackStatus:)]) {
        [self.delegate nvCurveSpeedView:self playbackStatus:NO];
    }
    if (self.isSelected) {
        ///删除
        ///delete
        if(opIndex >= self.curvePoints.count)  {
            return;
        }
        [self.curvePoints removeObjectAtIndex:self.nextIndex-1];
        [self.bezierView deletePoint:self.nextIndex-1];
        self.isSelected = NO;
        [self updateDuration];
        ///时码线移动到添加点的位置
        ///The time code line moves to the position of the add point
        int64_t clipPos = dePoint.x * self.originalDuration/speedW;
        int64_t timelinePos = [self.currentClip getTimelinePosByClipPosCurvesVariableSpeed:clipPos + self.currentClip.trimIn];
        if ([self.delegate respondsToSelector:@selector(nvCurveSpeedView:timelineSeekTo:playbackEOF:)]) {
            [self.delegate nvCurveSpeedView:self timelineSeekTo:timelinePos playbackEOF:YES];
        }
        [self.bezierView resetPointSelectState];
        CGFloat s = clipPos * speedW / self.originalDuration;
        [self.bezierView positionAnimation:s isPlaying:NO];
        self.isSelected = NO;
        self.nextIndex = opIndex - 1;
        self.currentCurvePoint = dePoint;
    }else{
        ///添加
        ///add
        [self.curvePoints insertObject:[NSValue valueWithCGPoint:self.currentCurvePoint] atIndex:self.nextIndex];
        [self.bezierView insertPoint:self.currentCurvePoint index:self.nextIndex];
        self.isSelected = YES;
        ///更新时长
        ///Update time
        [self updateDuration];
        if (self.currentClip) {
            NvsVideoClip *clip = self.currentClip;
            CGPoint nextPoint = [self.curvePoints[opIndex] CGPointValue];
            int64_t clipPos = nextPoint.x * self.originalDuration / speedW;
            int64_t timelinePos = [clip getTimelinePosByClipPosCurvesVariableSpeed:clipPos + clip.trimIn];
            if ([self.delegate respondsToSelector:@selector(nvCurveSpeedView:timelineSeekTo:playbackEOF:)]) {
                [self.delegate nvCurveSpeedView:self timelineSeekTo:timelinePos playbackEOF:YES];
            }
            CGFloat s = clipPos * speedW / self.originalDuration;
            [self.bezierView positionAnimation:s isPlaying:NO];
            self.bezierView.pointIndex = opIndex;
            self.isSelected = YES;
            self.currentCurvePoint = nextPoint;
            self.nextIndex = opIndex + 1;
        }
    }
    [self configOperationState:YES];
}

- (void)updateDuration {
    if (!self.currentClip) {
        return;
    }
    NvsVideoClip *clip = self.currentClip;
    ///恢复到常规速度
    ///Return to normal speed
    [clip changeSpeed:1.0 keepAudioPitch:YES];
    int64_t inPoint = clip.inPoint;
    int64_t outPoint = clip.outPoint;
    ///修改变速
    ///Modified speed change
    NSString *bezierPoints = [self fetchCurvesPoints];
    BOOL changeResult = [clip changeCurvesVariableSpeed:bezierPoints keepAudioPitch:YES];
    if (!changeResult) {
        return;
    }
    /// 应用曲线变速成功
    /// The curve speed change was successfully applied
    /// x轴转化为clip的时长
    /// The length of time the X-axis is converted to clip
    NSMutableArray *points = [self convertChartXToTime:self.curvePoints];
    if ([self.delegate respondsToSelector:@selector(nvCurveSpeedView:clip:inPoint:outPoint:speedChangedPoints:)]) {
        [self.delegate nvCurveSpeedView:self clip:self.currentClip inPoint:inPoint outPoint:outPoint speedChangedPoints:points];
    }
    
}

- (NSString *)fetchCurvesPoints {
    NSMutableArray *tmpPoints = [self.bezierView fetchBezierPoint];
    NSMutableArray *points = [self convertChartXToTime:tmpPoints];
    NSString *result = [NvBezierUtils bezierPointsConvertToString:points];
    return result;
}

- (NSMutableArray *)convertChartXToTime:(NSArray *)tmpPoints {
    NSMutableArray *points = [NSMutableArray array];
    ///x轴转化为clip的时长
    ///The length of time the X-axis is converted to clip
    CGFloat speedW = self.bezierView.bounds.size.width - 38*SCREENSCALE;
    CGFloat dx = self.originalDuration / speedW;
    for (int i=0; i<tmpPoints.count; i++) {
        CGPoint point = [tmpPoints[i] CGPointValue];
        CGPoint newPoint = CGPointMake(point.x * dx, point.y);
        [points addObject:[NSValue valueWithCGPoint:newPoint]];
    }
    return points;
}

- (BOOL)updataTimeline:(int64_t)timestamp state:(BOOL)state {
    if(!self.currentClip){
        return NO;
    }
    NvsVideoClip *clip = self.currentClip;
    CGFloat speedW = self.bezierView.bounds.size.width - 38*SCREENSCALE;
    int64_t clipPos = [clip getClipPosByTimelinePosCurvesVariableSpeed:timestamp] - clip.trimIn;

    CGFloat s = clipPos * speedW / self.originalDuration;
    [self.bezierView positionAnimation:s isPlaying:state];
    BOOL isSelected = NO;
    for (int i=0; i<self.curvePoints.count; i++) {
        CGPoint point = [self.curvePoints[i] CGPointValue];
        if (point.x - 16*SCREENSCALE*0.5 <= s && point.x+16*SCREENSCALE*0.5 >= s) {
            isSelected = YES;
            break;
        }
    }
    self.isSelected = isSelected;
    if (clipPos > clip.inPoint && clipPos < clip.outPoint && !self.operationButton.isEnabled) {
        /// 重置删除和添加状态
        /// Reset the delete and add states
        self.operationButton.enabled = YES;
        self.operationButton.alpha = 1.0;
    }
    ///防止播放完成，退出编辑界面
    ///Exit the editing screen to prevent playback from completing
    if (self.originalDuration == clipPos && !(clipPos == clip.trimIn) && !(clipPos == clip.outPoint)) {
        if ([self.delegate respondsToSelector:@selector(nvCurveSpeedView:timelineSeekTo:playbackEOF:)]) {
            [self.delegate nvCurveSpeedView:self timelineSeekTo:clip.inPoint playbackEOF:YES];
        }
        self.isSelected = YES;
        self.bezierView.pointIndex = 0;
    }
    return YES;
}

- (void)resetCurvePoints {
    [self.bezierView resetPointSelectState];
}
#pragma mark - NvBezierSpeedViewDelegate
- (void)nvBezierSpeedView:(NvBezierSpeedView *)speedView timelineDidChangedNextIndex:(NSInteger)nextIndex speed:(CGPoint)speed isTouchPoint:(BOOL)isTouchPoint {
    if (!self.hidden) {
        self.currentCurvePoint = speed;
        self.nextIndex = nextIndex;
        BOOL isSelected = NO;
        for (int i=0; i<self.curvePoints.count; i++) {
            CGPoint point = [self.curvePoints[i] CGPointValue];
            if (point.x == speed.x) {
                isSelected = YES;
                break;
            }
        }
        self.isSelected = isSelected;
        
        if (self.isSelected && (self.nextIndex == 1 || self.nextIndex == self.curvePoints.count)) {
            [self configOperationState:NO];
        }else{
            [self configOperationState:YES];
        }
        ///x轴转化为时码线的pos
        ///x axis transforms pos of time code line
        if (!self.currentClip) {
            return;
        }
        NvsVideoClip *clip = self.currentClip;
        CGFloat speedW = self.bezierView.bounds.size.width - 38*SCREENSCALE;
        int64_t clipPos = speed.x * self.originalDuration/speedW;
//        int64_t timestamp = clipPos + clip.trimIn;
        int64_t timelinePos = [clip getTimelinePosByClipPosCurvesVariableSpeed:clipPos + clip.trimIn];
        timelinePos = (timelinePos < clip.inPoint) ? clip.inPoint : timelinePos ;
        if (timelinePos == clip.inPoint) {
            timelinePos -= (clip.outPoint - clip.inPoint);
            clipPos = 0;
            self.bezierView.pointIndex = 0;
            self.currentCurvePoint = [self.curvePoints[0] CGPointValue];
        }
        
        if ([self.delegate respondsToSelector:@selector(nvCurveSpeedView:timelineSeekTo:playbackEOF:)]) {
            [self.delegate nvCurveSpeedView:self timelineSeekTo:timelinePos playbackEOF:isTouchPoint];
        }

        CGFloat s = clipPos * speedW / self.originalDuration;
        [self.bezierView positionAnimation:s];
    }
}

- (void)nvBezierSpeedView:(NvBezierSpeedView *)speedView timelineDidChangedCurrentIndex:(NSInteger)currentIndex speed:(CGPoint)speed {
    [self.curvePoints replaceObjectAtIndex:currentIndex withObject:[NSValue valueWithCGPoint:speed]];
    [self updateDuration];
    if (self.isPlayback) {
        if(!self.currentClip){
            return;
        }
        NvsVideoClip *clip = self.currentClip;
        if ([self.delegate respondsToSelector:@selector(nvCurveSpeedView:timelineSeekTo:playbackEOF:)]) {
            [self.delegate nvCurveSpeedView:self timelineSeekTo:clip.inPoint playbackEOF:YES];
        }
        [self.bezierView positionAnimation:0 isPlaying:NO];
        self.isPlayback = NO;
        return;
    }
    
    ///seek到起始位置
    ///seek to the starting position
    if (!self.currentClip) {
        return;
    }
    NvsVideoClip *clip = self.currentClip;
    CGFloat speedW = self.bezierView.bounds.size.width - 38*SCREENSCALE;
    int64_t clipPos = speed.x * self.originalDuration/speedW;
    int64_t timelinePos = [clip getTimelinePosByClipPosCurvesVariableSpeed:clipPos + clip.trimIn];
    
    if ([self.delegate respondsToSelector:@selector(nvCurveSpeedView:timelineSeekTo:playbackEOF:)]) {
        [self.delegate nvCurveSpeedView:self timelineSeekTo:timelinePos playbackEOF:YES];
    }

    CGFloat s = clipPos * speedW / self.originalDuration;
    [self.bezierView positionAnimation:s isPlaying:NO];
    self.isSelected = YES;
    self.bezierView.pointIndex = currentIndex;
    [self configOperationState:NO];
    CGPoint point = [self.curvePoints[currentIndex] CGPointValue];
    self.currentCurvePoint = point;
    if (self.curvePoints.count > currentIndex + 1) {
        self.nextIndex = currentIndex + 1;
        [self configOperationState:YES];
    }

}

#pragma mark - setter & getter
- (void)setCurveInfo:(NvCurveInfo *)curveInfo {
    _curveInfo = curveInfo;
    if (curveInfo) {
        self.curveRangeMin = curveInfo.minValue;
        self.curveRangeMax = curveInfo.maxValue;
        [self refreshCurveSpeeds:curveInfo.chartsArr];
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        [self.operationButton setTitle:NvLocalString(@"Delete the point", @"- 删除点") forState:UIControlStateNormal];
        [self.operationButton setTitle:NvLocalString(@"Delete the point", @"- 删除点") forState:UIControlStateHighlighted];
    }else{
        [self.operationButton setTitle:NvLocalString(@"Add point", @"+ 添加点") forState:UIControlStateNormal];
        [self.operationButton setTitle:NvLocalString(@"Add point", @"+ 添加点") forState:UIControlStateHighlighted];
    }
}

- (void)setIsPlayback:(BOOL)isPlayback {
    _isPlayback = isPlayback;
    _isPlaying = isPlayback;
}
@end
