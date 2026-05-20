//
//  NvBezierSpeedView.m
//  SDKDemo
//
//  Created by MS on 2020/11/24.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvBezierSpeedView.h"
#import "NvBezierUtils.h"
#import "NVHeader.h"

@interface NvBezierSpeedView ()<UIScrollViewDelegate>
@property(nonatomic) UIEdgeInsets edgeInsets;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *midLabel;
@property (nonatomic, strong) UILabel *bottomLabel;
@property (nonatomic, strong) UIView *timelineSlider;
@property (nonatomic, strong) UIView *sublineView;
@property (nonatomic, strong) NvRangeModel *speedRange;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) NSMutableArray <UIButton *>*pointButtons;
@property (nonatomic, strong) NSMutableArray *pointArr;
@property (nonatomic, assign) CGSize pointSize;
@property (nonatomic, assign) CGFloat controlXRatio;
@property (nonatomic, assign) CGSize contentSize;
@end

@implementation NvBezierSpeedView

- (instancetype)initWithFrame:(CGRect)frame edgeInsets:(UIEdgeInsets)edgeInsets {
    if (self = [super initWithFrame:frame]) {
        self.edgeInsets = edgeInsets;
        [self setDefaultSpeedModel];
        self.pointButtons = [NSMutableArray array];
        self.pointArr = [NSMutableArray array];
        self.pointSize = CGSizeMake(16*SCREENSCALE, 16*SCREENSCALE);
        self.controlXRatio = 1/3.f;
        self.shapeLayer = [[CAShapeLayer alloc] init];
        self.pointIndex = 0;
        self.backgroundColor = UIColorFromRGB(0x242728);
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    CGFloat contentH = self.bounds.size.height - self.edgeInsets.top - self.edgeInsets.bottom;
    CGFloat contentW = self.bounds.size.width - self.edgeInsets.left - self.edgeInsets.right;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.edgeInsets.left, self.edgeInsets.top, contentW, contentH)];
    self.scrollView.contentSize = CGSizeMake(contentW, contentH);
    self.scrollView.bounces = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self insertSubview:self.scrollView atIndex:0];
    
    self.topLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.edgeInsets.left + 4.5*SCREENSCALE, self.edgeInsets.top, 100*SCREENSCALE, 11*SCREENSCALE)];
    self.topLabel.font = [UIFont systemFontOfSize:8*SCREENSCALE];
    self.topLabel.textAlignment = NSTextAlignmentLeft;
    self.topLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    [self addSubview:self.topLabel];
    
    self.midLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.edgeInsets.left + 4.5*SCREENSCALE, self.edgeInsets.top + contentH*0.5 - 11*SCREENSCALE, 100*SCREENSCALE, 11*SCREENSCALE)];
    self.midLabel.font = [UIFont systemFontOfSize:8*SCREENSCALE];
    self.midLabel.textAlignment = NSTextAlignmentLeft;
    self.midLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    [self addSubview:self.midLabel];
    
    self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.edgeInsets.left + 4.5*SCREENSCALE, self.bounds.size.height - self.edgeInsets.bottom - 12*SCREENSCALE, 100*SCREENSCALE, 11*SCREENSCALE)];
    self.bottomLabel.font = [UIFont systemFontOfSize:8*SCREENSCALE];
    self.bottomLabel.textAlignment = NSTextAlignmentLeft;
    self.bottomLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    [self addSubview:self.bottomLabel];
    
    self.timelineSlider = [[UIView alloc] initWithFrame:CGRectMake(0, self.edgeInsets.top, self.edgeInsets.left*2.0, contentH)];
    self.timelineSlider.backgroundColor = [UIColor clearColor];
    [self addSubview:self.timelineSlider];
    
    self.sublineView = [[UIView alloc] initWithFrame:CGRectMake((self.timelineSlider.frame.size.width - 2.0)*0.5, 0, 1.0, contentH)];
    self.sublineView.backgroundColor = [UIColor whiteColor];
    [self.timelineSlider addSubview:self.sublineView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(timelinePanDidChanged:)];
    [self.timelineSlider addGestureRecognizer:pan];
    
    [self bezierRect];
    [self makeChartView:3];
}

#pragma mark - 数据处理
///Data processing
- (void)configDefaultData:(NvCurveInfo *)curveInfo {
    if (!self.speedRange) {
        self.speedRange = [NvRangeModel new];
    }
    self.speedRange.minValue = curveInfo.minValue;
    self.speedRange.maxValue = curveInfo.maxValue;
    if (!self.shapeLayer) {
        self.shapeLayer = [[CAShapeLayer alloc] init];
    }
    [self.shapeLayer removeFromSuperlayer];
    ///视图 Y轴的值转化为速度
    ///The value of the Y-axis of the view is converted to velocity
    [self convertToPosition:curveInfo.chartsArr];
    ///画贝塞尔曲线
    ///Let me draw the Bezier curve
    [self bezierLine];
}

- (void)updatePointArr {
    if (self.speedRange.maxValue < self.speedRange.minValue) {
        return;
    }
    
    for (UIButton *button in self.pointButtons) {
        [button removeFromSuperview];
    }
    [self.pointButtons removeAllObjects];
    NSInteger tag = 1000;
    for (int i=0; i<self.pointArr.count; i++) {
        CGPoint point = [self.pointArr[i] CGPointValue];
        UIButton *btn = [self createPointButton];
        [self.pointButtons addObject:btn];
        btn.tag = tag;
        btn.frame = CGRectMake(point.x - self.pointSize.width*0.5 + self.edgeInsets.left, point.y - self.pointSize.height*0.5 + self.edgeInsets.top, self.pointSize.width, self.pointSize.height);
        tag += 1;
    }
}

///Y轴: 速度坐标转化为视图坐标
///Y-axis: Velocity coordinates are converted to view coordinates
- (void)convertToPosition:(NSMutableArray *)charts {
    if (self.speedRange.maxValue < self.speedRange.minValue) {
        return;
    }
    [self.pointArr removeAllObjects];
    for (UIButton *button in self.pointButtons) {
        [button removeFromSuperview];
    }
    [self.pointButtons removeAllObjects];
    
    NSInteger tag = 1000;
    CGFloat chartH = self.bounds.size.height - self.edgeInsets.bottom - self.edgeInsets.top;
    ///创建曲线的点
    ///Create the point of the curve
    for (NSValue *value in charts) {
        CGPoint point = [value CGPointValue];
        CGPoint resultP = [self speedPointWithPoint:point chartHeight:chartH];
        
        [self.pointArr addObject:[NSValue valueWithCGPoint:resultP]];
        
        UIButton *btn = [self createPointButton];
        [self.pointButtons addObject:btn];
        btn.tag = tag;
        btn.frame = CGRectMake(resultP.x - self.pointSize.width * 0.5 + self.edgeInsets.left, resultP.y - self.pointSize.height*0.5 + self.edgeInsets.top, self.pointSize.width, self.pointSize.height);
        tag += 1;
    }
}

///Y轴： 视图坐标转化为速度
///Y-axis: View coordinates are converted to velocity
- (void)convertToChartY:(CGFloat)chartX block:(void(^)(NSInteger nextIndex,CGPoint speed))block {
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    NSInteger nextIndex = 0;
    NSInteger endIndex = self.pointArr.count;
    for (int i = 0; i<endIndex; i++) {
        CGPoint point = [self.pointArr[i] CGPointValue];
        NSString *px = [NSString stringWithFormat:@"%.6f",point.x];
        NSString *cx = [NSString stringWithFormat:@"%.6f",chartX];
        if (px.doubleValue>cx.doubleValue && endIndex>1 && i>0) {
            startPoint = [self.pointArr[i-1] CGPointValue];
            endPoint = [self.pointArr[i] CGPointValue];
            nextIndex = i;
            break;
        }
    }
    ///获取Y轴坐标
    ///Get the Y-axis coordinate
    CGPoint p1 = CGPointMake((endPoint.x - startPoint.x)*self.controlXRatio + startPoint.x, startPoint.y);
    CGPoint p2 = CGPointMake((endPoint.x - startPoint.x) * self.controlXRatio * 2 + startPoint.x, endPoint.y);
    CGFloat chartY = [NvBezierUtils calculateBezierPointY:chartX startPoint:startPoint endPoint:endPoint controlP1:p1 controlP2:p2];
    
    ///转化Y轴，获取速度
    ///Transform the Y-axis to get the velocity
    double speedValue = [self convertOriginYToSpeed:chartY];
    if (block) {
        block(nextIndex,CGPointMake(chartX, (CGFloat)speedValue));
    }
}

- (double)convertOriginYToSpeed:(CGFloat)originY {
    /// 转化Y轴，获取速度
    /// Transform the Y-axis to get the velocity
    CGFloat chartH = self.bounds.size.height - self.edgeInsets.bottom - self.edgeInsets.top;
    CGFloat chartY = originY;
    CGFloat speed;
    if (chartY < chartH * 0.5) {
        CGFloat delta = self.speedRange.maxValue - 1;
        speed = delta * (1 - 2.0 * chartY / chartH) + 1;
    }else if (chartY > chartH * 0.5) {
        CGFloat delta = 1 - self.speedRange.minValue;
        speed = 2.0 * delta * (1 - chartY / chartH) + self.speedRange.minValue;
    }else {
        speed = 1.0;
    }
    NSString *speedValue = [NSString stringWithFormat:@"%.3f",speed];
    NSDecimalNumber *decNumber = [NSDecimalNumber decimalNumberWithString:speedValue];
    
    return decNumber.doubleValue;
}

- (void)setDefaultSpeedModel {
    self.speedRange = [NvRangeModel new];
    self.speedRange.minValue = 0.1;
    self.speedRange.maxValue = 10;
}

#pragma mark - ShapeLayer
///画贝塞尔曲线
///Let me draw the Bezier curve
- (void)bezierLine {
    if (!self.pointArr || self.pointArr.count == 0) {
        return;
    }
    CGPoint startPoint = [self.pointArr.firstObject CGPointValue];
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:startPoint];
    for (int i=1; i<self.pointArr.count; i++) {
        CGPoint prePoint = [self.pointArr[i-1] CGPointValue];
        CGPoint currentPoint = [self.pointArr[i] CGPointValue];
       
        CGPoint controlP1 = CGPointMake((currentPoint.x - prePoint.x) * self.controlXRatio + prePoint.x, prePoint.y);
        CGPoint controlP2 = CGPointMake((currentPoint.x - prePoint.x) * self.controlXRatio * 2 + prePoint.x, currentPoint.y);
        [linePath addCurveToPoint:currentPoint controlPoint1:controlP1 controlPoint2:controlP2];
        
        if (i == self.pointArr.count - 1) {
            [linePath moveToPoint:currentPoint];
        }
    }
    
    self.shapeLayer.path = linePath.CGPath;
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.shapeLayer.strokeColor = [UIColor nv_colorWithHexString:@"#4A90E2"].CGColor;
    self.shapeLayer.lineWidth = 1.0f;
    [self.scrollView.layer addSublayer:self.shapeLayer];
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"strokeEnd";
    animation.fromValue = 0;
    animation.toValue = @1;
    animation.duration = 0.01;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.autoreverses = NO;
    [self.shapeLayer addAnimation:animation forKey:@"stroke"];
    
    for(UIButton *button in self.pointButtons) {
        [self insertSubview:button belowSubview:self.timelineSlider];
    }
}

///画曲线矩形边框
///Draw a curved rectangle border
- (void)bezierRect {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.scrollView.frame];
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineDashPattern = @[[NSNumber numberWithInteger:5],[NSNumber numberWithInteger:1]];
    [self.layer insertSublayer:shapeLayer atIndex:0];
}

///画曲线的虚实基线
///Draw the imaginary and real baseline of the curve
- (void)makeChartView:(NSInteger)lineNumber {
    if (lineNumber <= 0) {
        return;
    }
    CGFloat contentH = self.bounds.size.height - self.edgeInsets.top - self.edgeInsets.bottom;
    CGFloat padding = floor(contentH - lineNumber) / (lineNumber + 1);
    CGFloat lineWidth = self.scrollView.contentSize.width - 2.0;
    CGFloat startY = padding;
    
    for (int i=1; i<=lineNumber; i++) {
        if (i%2 != 0) {
            ///虚线
            ///Dotted line
            CAShapeLayer *dottedLineLayer = [[CAShapeLayer alloc] init];
            dottedLineLayer.frame = CGRectMake(0, startY, lineWidth, 1.0);
            dottedLineLayer.strokeColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
            dottedLineLayer.fillColor = [UIColor clearColor].CGColor;
            dottedLineLayer.lineWidth = 1.0f;
            dottedLineLayer.lineJoin = kCALineJoinRound;
            dottedLineLayer.lineDashPattern = @[[NSNumber numberWithInteger:7],[NSNumber numberWithInteger:3]];
            
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, NULL, 0, 0);
            CGPathAddLineToPoint(pathRef, NULL, lineWidth, 0);
            dottedLineLayer.path = pathRef;
            [self.scrollView.layer addSublayer:dottedLineLayer];
        }else{
            ///实线
            ///Solid line
            CAShapeLayer *solidLineLayer = [[CAShapeLayer alloc] init];
            solidLineLayer.frame = CGRectMake(0, startY, lineWidth, 1.0);
            solidLineLayer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.31].CGColor;
            [self.scrollView.layer addSublayer:solidLineLayer];
        }
        startY += padding;
    }
}

#pragma mark 由界面point计算真实速度point
///Calculate the real speed point from the interface point
- (CGPoint)speedPointWithPoint:(CGPoint)point chartHeight:(CGFloat)chartHeight {
    ///上下比例不同：speedRange.minValue～1，1～speedRange.maxValue
    ///The upper and lower ratios are different: speedRange.minValue ~ 1,1 ~ speedRange.maxValue
    CGPoint resultP;
    if (point.y > 1) {
        CGFloat delta = self.speedRange.maxValue - 1;
        resultP = CGPointMake(point.x, chartHeight*0.5*(1-(point.y -1)/delta));
    }else if (point.y < 1) {
        CGFloat delta = 1 - self.speedRange.minValue;
        resultP = CGPointMake(point.x, chartHeight*(1-(point.y - self.speedRange.minValue) * 0.5 / delta));
    }else{
        resultP = CGPointMake(point.x, chartHeight*0.5);
    }
    return resultP;
}

#pragma mark - 曲线上的点
///The point on the curve
- (UIButton *)createPointButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"videoClip_curve_point_normal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"videoClip_curve_point_select"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(didTapPointButton:) forControlEvents:UIControlEventTouchUpInside];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanPointButton:)];
    [button addGestureRecognizer:pan];
    return button;
}

- (void)didTapPointButton:(UIButton *)sender {
    ///设置当前点击的状态
    ///Set the current click state
    for (UIButton *button in self.pointButtons) {
        button.selected = NO;
    }
    sender.selected = !sender.selected;
    ///移动时码线
    ///Move time code line
    self.pointIndex = sender.tag - 1000;
    if(self.pointIndex < 0 || self.pointIndex >= self.pointArr.count) {
        return;
    }
    CGSize size = self.timelineSlider.frame.size;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGPoint point = [self.pointArr[self.pointIndex] CGPointValue];
    [self changeTimelinePos:rect point:point];
    double speed = [self convertOriginYToSpeed:point.y];
    if ([self.delegate respondsToSelector:@selector(nvBezierSpeedView:timelineDidChangedNextIndex:speed:isTouchPoint:)]) {
        [self.delegate nvBezierSpeedView:self timelineDidChangedNextIndex:self.pointIndex + 1 speed:CGPointMake(point.x, (CGFloat)speed) isTouchPoint:YES];
    }
}

- (void)didPanPointButton:(UIPanGestureRecognizer *)sender {
    ///获取当前滑动的按钮和索引
    ///Gets the currently sliding button and index
    UIView *view = sender.view;
    if (![view isKindOfClass:[UIButton class]]) {
        return;
    }
    BOOL hasButton = NO;
    UIButton *button;
    for (UIButton *btn in self.pointButtons) {
        if (btn.tag == view.tag) {
            hasButton = YES;
            button = btn;
            break;
        }
    }
    if (!hasButton) {
        return;
    }
    ///设置坐标点的拖拽区间
    ///Sets the drag interval for coordinate points
    CGPoint point = [sender translationInView:self];
    CGRect rect = button.frame;
    CGFloat comY = rect.origin.y + point.y;
    CGFloat maxY = self.edgeInsets.top - self.pointSize.height*0.5;
    CGFloat minY = self.bounds.size.height - self.edgeInsets.bottom - self.pointSize.height * 0.5;
    if (comY < maxY) {
        rect.origin.y = maxY;
    }else if (comY > minY) {
        rect.origin.y = minY;
    }else {
        rect.origin.y += point.y;
    }
    ///曲线点x轴方向移动
    ///The curve point is moving in the x direction
    NSInteger tag = button.tag;
    if ((tag != 1000) && (tag - 1000 != self.pointButtons.count - 1)) {
        CGFloat comX = rect.origin.x + point.x;
        CGFloat minX = self.pointButtons[tag - 1000 - 1].frame.origin.x + self.pointSize.width;
        CGFloat maxX = self.pointButtons[tag - 1000 + 1].frame.origin.x - self.pointSize.width;
        if (comX < minX) {
            rect.origin.x = minX;
        }else if (comX > maxX) {
            rect.origin.x = maxX;
        }else {
            rect.origin.x += point.x;
        }
    }
    button.frame = CGRectMake(rect.origin.x, rect.origin.y, self.pointSize.width, self.pointSize.height);
    
    ///手势结束处理
    ///End of gesture processing
    NSInteger index = button.tag - 1000;
    CGPoint targetPoint = [self.pointArr[index] CGPointValue];
    CGPoint btnOrigin = button.frame.origin;
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed ) {
        double speed = [self convertOriginYToSpeed:targetPoint.y];
        if ([self.delegate respondsToSelector:@selector(nvBezierSpeedView:timelineDidChangedCurrentIndex:speed:)]) {
            [self.delegate nvBezierSpeedView:self timelineDidChangedCurrentIndex:index speed:CGPointMake(targetPoint.x, (CGFloat)speed)];
        }
    }else if (sender.state == UIGestureRecognizerStateChanged) {
        ///修改点数据
        ///Modification point data
        targetPoint = CGPointMake(btnOrigin.x + self.pointSize.width * 0.5 - self.edgeInsets.left, btnOrigin.y + self.pointSize.height * 0.5 - self.edgeInsets.top);
        [self.pointArr replaceObjectAtIndex:index withObject:[NSValue valueWithCGPoint:targetPoint]];
        ///删除旧的曲线
        ///Delete the old curve
        [self.shapeLayer removeFromSuperlayer];
        ///重新绘制
        ///redraw
        [self bezierLine];
        ///移动timeline
        ///Mobile timeline
        CGSize size = self.timelineSlider.frame.size;
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        [self changeTimelinePos:rect point:targetPoint];
        CGFloat chartX = self.timelineSlider.frame.origin.x;
        if ([self.delegate respondsToSelector:@selector(nvBezierSpeedView:timelineDidChangedNextIndex:speed:isTouchPoint:)]) {
            [self convertToChartY:chartX block:^(NSInteger nextIndex, CGPoint speed) {
                [self.delegate nvBezierSpeedView:self timelineDidChangedNextIndex:nextIndex speed:speed isTouchPoint:NO];
            }];
        }
        
    }
    [sender setTranslation:CGPointZero inView:self];
}

#pragma mark - 添加和删除曲线上的点
///Add and delete points on the curve
- (void)insertPoint:(CGPoint)point index:(NSInteger)index {
    CGFloat chartH = self.bounds.size.height - self.edgeInsets.bottom - self.edgeInsets.top;
    CGPoint newPoint = [self speedPointWithPoint:point chartHeight:chartH];
    [self.pointArr insertObject:[NSValue valueWithCGPoint:newPoint] atIndex:index];
    
    ///移除旧的Layer
    ///Remove the old Layer
    [self.shapeLayer removeFromSuperlayer];
    [self updatePointArr];
    [self bezierLine];
    
    ///移动时码线
    ///Move time code line
    self.pointIndex = index;
    if (self.pointIndex<0 || self.pointIndex>= self.pointArr.count) {
        return;
    }
    CGRect rect = CGRectMake(0, 0, self.timelineSlider.frame.size.width, self.timelineSlider.frame.size.height);
    [self changeTimelinePos:rect point:[self.pointArr[self.pointIndex] CGPointValue]];
}

- (void)deletePoint:(NSInteger)index {
    [self.pointArr removeObjectAtIndex:index];
    [self.shapeLayer removeFromSuperlayer];
    [self updatePointArr];
    [self bezierLine];
}

- (NSMutableArray *)fetchBezierPoint {
    if (self.pointArr.count <= 0 || !self.pointArr) {
        return nil;
    }
    NSMutableArray *curvePoints = [NSMutableArray array];
    for (int i=0; i<self.pointArr.count; i++) {
        CGPoint point = [self.pointArr[i] CGPointValue];
        double speed = [self convertOriginYToSpeed:point.y];
        CGPoint curPoint = CGPointMake(point.x, (CGFloat)speed);
        CGPoint prePoint = CGPointMake(0, (CGFloat)speed);
        CGPoint nexPoint = CGPointMake(0, (CGFloat)speed);
        if (i==self.pointArr.count -1) {
            CGPoint previousPoint = [self.pointArr[i-1] CGPointValue];
            CGFloat delta = (curPoint.x - previousPoint.x)*self.controlXRatio;
            prePoint.x = curPoint.x - delta;
            nexPoint.x = curPoint.x + delta;
        }else if (i==0){
            CGPoint nextPoint = [self.pointArr[i+1] CGPointValue];
            CGFloat delta = (nextPoint.x - curPoint.x) * self.controlXRatio;
            prePoint.x = -delta;
            nexPoint.x = delta;
        }else{
            CGPoint previousPoint = [self.pointArr[i-1] CGPointValue];
            CGPoint nextPoint = [self.pointArr[i+1] CGPointValue];
            prePoint.x = curPoint.x - (curPoint.x - previousPoint.x)*self.controlXRatio;
            nexPoint.x = curPoint.x + (nextPoint.x - curPoint.x)*self.controlXRatio;
        }
        [curvePoints addObject:[NSValue valueWithCGPoint:curPoint]];
        [curvePoints addObject:[NSValue valueWithCGPoint:prePoint]];
        [curvePoints addObject:[NSValue valueWithCGPoint:nexPoint]];
    }
    return curvePoints;
}

- (void)resetPointSelectState {
    for (UIButton *button in self.pointButtons) {
        button.selected = NO;
    }
}

- (void)positionAnimation:(CGFloat)chartX isPlaying:(BOOL)isPlaying {
    [self positionAnimation:chartX];
    [self adsorptionAnimationForChartX:chartX isPlaying:isPlaying];
}

- (void)positionAnimation:(CGFloat)chartX {
    CGRect newRect = self.timelineSlider.frame;
    newRect.origin.x = chartX;
    newRect.origin.y = self.edgeInsets.top;
    self.timelineSlider.frame = newRect;
}

///设置选中point吸附效果
///Set the adsorption effect of selected point
- (void)adsorptionAnimationForChartX:(CGFloat)chartX isPlaying:(BOOL)isPlaying {
    /// 设置吸附效果选中point
    /// Set adsorption effect Select point
    BOOL hasPoint = NO;
    CGRect newRect = self.timelineSlider.frame;
    for (int i=0; i<self.pointArr.count; i++) {
        CGPoint point = [self.pointArr[i] CGPointValue];
        if (isPlaying) {

            if (point.x - self.pointSize.width * 0.01 <= chartX && point.x + self.pointSize.width * 0.01 >= chartX) {

                hasPoint = YES;
                [self processTimelineSliderOnPoint:newRect pointIndex:i point:point isPlaying:isPlaying];
                break;
            }
            
        } else {
            if (point.x - self.pointSize.width * 0.5 <= chartX && point.x + self.pointSize.width * 0.5 >= chartX) {
                hasPoint = YES;
                [self processTimelineSliderOnPoint:newRect pointIndex:i point:point isPlaying:isPlaying];
                break;
            }
        }
        
        
    }
    if (!hasPoint) {
        /// 重置速度点的坐标
        /// Reset the coordinates of the velocity point
        for (UIButton *button in self.pointButtons) {
            button.selected = NO;
        }
        
        [self convertToChartY:chartX block:^(NSInteger nextIndex, CGPoint speed) {
            if (self.hidden == NO) {
                if ([self.delegate respondsToSelector:@selector(nvBezierSpeedView:timelineDidChangedNextIndex:speed:isTouchPoint:)]) {
                    [self.delegate nvBezierSpeedView:self timelineDidChangedNextIndex:nextIndex speed:speed isTouchPoint:isPlaying];
                }
            }
        }];
    }
}

- (void)processTimelineSliderOnPoint:(CGRect)timelineSliderRect pointIndex:(int)pointIndex point:(CGPoint)point isPlaying:(BOOL)isPlaying {
    self.pointIndex = pointIndex;
    CGRect rect = CGRectMake(0, 0, timelineSliderRect.size.width, timelineSliderRect.size.height);
    if (!isPlaying) {
        /// 移动时码线
        /// Move time code line
        [self changeTimelinePos:rect point:point];
    }
    
    double speed = [self convertOriginYToSpeed:point.y];
    if ([self.delegate respondsToSelector:@selector(nvBezierSpeedView:timelineDidChangedNextIndex:speed:isTouchPoint:)]) {
        [self.delegate nvBezierSpeedView:self timelineDidChangedNextIndex:self.pointIndex + 1 speed:CGPointMake(point.x, (CGFloat)speed) isTouchPoint:isPlaying];
    }
}

#pragma mark - UIPanGestureRecognizer
- (void)timelinePanDidChanged:(UIPanGestureRecognizer *)sender {
    ///移动时码线
    ///Move time code line
    CGPoint point = [sender translationInView:self];
    CGRect rect = self.timelineSlider.frame;
    [self changeTimelinePos:rect point:point];
    ///手势结束
    ///End of gesture
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed) {
        CGFloat chartX = self.timelineSlider.frame.origin.x;
        [self adsorptionAnimationForChartX:chartX isPlaying:NO];
    }
    [sender setTranslation:CGPointZero inView:self];
}

- (void)changeTimelinePos:(CGRect)rect point:(CGPoint)point {
    CGRect newRect = rect;
    if (newRect.origin.x + point.x < 0) {
        newRect.origin.x = 0;
    }else if (newRect.origin.x + point.x > self.bounds.size.width - self.edgeInsets.right - self.edgeInsets.left) {
        newRect.origin.x = self.bounds.size.width - self.edgeInsets.right - self.edgeInsets.left;
    }else {
        newRect.origin.x += point.x;
    }
    newRect.origin.y = self.edgeInsets.top;
    self.timelineSlider.frame = newRect;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

#pragma mark - setter & getter
- (void)setOriginSpeed:(NvCurveInfo *)originSpeed {
    _originSpeed = originSpeed;
    if (originSpeed) {
        self.topLabel.text = [NSString stringWithFormat:@"%.1fx",originSpeed.maxValue];
        self.bottomLabel.text = [NSString stringWithFormat:@"%.1fx",originSpeed.minValue];
        self.midLabel.text = @"1.0x";
        [self configDefaultData:originSpeed];
    }
}

- (void)setPointIndex:(NSInteger)pointIndex {
    _pointIndex = pointIndex;
    if (self.pointButtons.count > pointIndex) {
        for (UIButton *button in self.pointButtons) {
            button.selected = NO;
        }
        UIButton *btn = self.pointButtons[pointIndex];
        btn.selected = YES;
    }
}

- (void)setContentSize:(CGSize)contentSize {
    _contentSize = contentSize;
    self.scrollView.contentSize = contentSize;
    for (CALayer *layer in self.scrollView.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
    [self makeChartView:3];
    self.scrollView.delegate = self;
}

@end
