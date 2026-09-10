//
//  CLSlider.m
//  CLBrowser
//
//  Created by chuliangliang on 2017/3/15.
//  Copyright © 2017年 chuliangliang. All rights reserved.
//

#import "CLSlider.h"
#import "NVHeader.h"

@interface ClCircleLayer: CALayer
@property (nonatomic,strong) CALayer *fillLayer;
@property (nonatomic) UIColor *fillColor;
@property (nonatomic) UIColor *shadowFilColor;
@property (nonatomic) CGFloat shadowFillOpacity;

@end

@implementation ClCircleLayer
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self doInit];
    }
    return self;
}

- (void)doInit
{
    _shadowFillOpacity = 1.0f;
    self.shadowOffset = CGSizeMake(0, 0);
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, 13, 13);
    imageView.backgroundColor = [UIColor nv_colorWithHexString:@"#242728"];
    imageView.layer.cornerRadius = 13/2;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 1.f;
    [self addSublayer:imageView.layer];
    
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    
    if (!CGSizeEqualToSize(self.bounds.size, self.fillLayer.frame.size)) {
        ///更新圆角及阴影 尺寸
        ///Updated fillet and shadow size
        CGPoint centerPoint = CGPointMake(CGRectGetWidth(self.bounds)*0.5, CGRectGetHeight(self.bounds)*0.5);
        CGFloat cornerRadius = CGRectGetWidth(self.bounds) *0.5;
        CGMutablePathRef shadowPath = CGPathCreateMutable();
        CGPathAddArc(shadowPath, nil, centerPoint.x, centerPoint.y, cornerRadius, 0, (CGFloat)M_PI*2, YES);
        self.shadowPath = shadowPath;
        
        self.fillLayer.cornerRadius = cornerRadius;
        CGPathRelease(shadowPath);
        
    }
    self.fillLayer.frame = self.bounds;
}

- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    self.fillLayer.backgroundColor = self.fillColor.CGColor;
}
- (void)setShadowFilColor:(UIColor *)shadowFilColor
{
    _shadowFilColor = shadowFilColor;
    self.shadowColor = self.shadowFilColor.CGColor;
}

- (void)setShadowFillOpacity:(CGFloat)shadowFillOpacity
{
    shadowFillOpacity = MAX(0, shadowFillOpacity);
    shadowFillOpacity = MIN(1, shadowFillOpacity);
    
    _shadowFillOpacity = shadowFillOpacity;
    self.shadowOpacity = self.shadowFillOpacity;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                     ||                                                 //
//                                                     ||                                                 //
//====================================================>⭕️=================================================//
//                                                     ||                                                 //
//                                                     ||                                                 //
////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface CLSlider ()
{
    BOOL touchOnCircleLayer;
    CGRect lastFrame;
}
@property (nonatomic,strong)ClCircleLayer *thumbLayer;
@property (nonatomic, strong) CATextLayer *titleLayer;
@property (nonatomic,assign,readwrite) NSInteger currentIdx;
@end

@implementation CLSlider

#pragma mark -
#pragma mark - alloc init

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doInit];
    }
    return self;
}

- (void)doInit
{
    touchOnCircleLayer = NO;
    _currentIdx = 0;
    _sliderStyle = CLSliderStyle_Nomal;
    
    ///滑块相关
    ///Slider correlation
    _thumbShadowOpacity = 0.6;
    _thumbShadowColor = [UIColor yellowColor];
    _thumbTintColor = [UIColor whiteColor];
    _thumbDiameter = 20;
    
    ///刻度线相关
    ///Scale correlation
    _scaleLineWidth = 1.0f;
    _scaleLineColor = [UIColor whiteColor];
    _scaleLineNumber = 4;
    _scaleLineHeight = 5;
    self.backgroundColor = [UIColor clearColor];
    
    ///滑块
    ///slider
    self.thumbLayer = [ClCircleLayer new];
    self.thumbLayer.anchorPoint = CGPointMake(0.5, 0.5);
    [self.layer addSublayer:self.thumbLayer];
    
    self.titleLayer = [CATextLayer layer];
    [self.layer addSublayer:self.titleLayer];
    self.titleLayer.alignmentMode = kCAAlignmentCenter;
    self.titleLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.titleLayer.fontSize = 10.f;
    self.titleLayer.contentsScale = [UIScreen mainScreen].scale;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!CGRectEqualToRect(lastFrame, self.frame)) {
        lastFrame = self.frame;
        [self setNeedsDisplay];
        
    }
}

- (void)drawRect:(CGRect)rect
{
    
    CGFloat W = CGRectGetWidth(self.bounds);
    CGFloat H = CGRectGetHeight(self.bounds);
    
    ///绘制背景颜色
    ///Paint background color
    [self.backgroundColor setFill];
    UIRectFill([self bounds]);

    ///绘制主刻度线
    ///Draw the main scale line
    CGPoint spindleScaleStartPoint = CGPointMake(self.thumbDiameter*0.5, H *0.5);
    CGPoint spindleScaleEndPoint = CGPointMake(W - self.thumbDiameter*0.5, H *0.5);
    
    ///设置刻度线颜色
    ///Set the scale color
    [self.scaleLineColor setStroke];
    ///绘主刻度轴(X轴)
    ///Draw main scale axis (X axis)
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, self.scaleLineWidth);
    CGContextMoveToPoint(context, spindleScaleStartPoint.x,spindleScaleStartPoint.y);
    CGContextAddLineToPoint(context, spindleScaleEndPoint.x,spindleScaleEndPoint.y);
    CGContextStrokePath(context);

    if (CLSliderStyle_Nomal == self.sliderStyle || CLSliderStyle_Cross == self.sliderStyle) {
        ///绘制竖直刻度短线
        ///Draw a short vertical scale line
        NSInteger lineNum = self.scaleLineNumber+1;
        CGFloat oneW = (W-self.thumbDiameter)/self.scaleLineNumber;
        CGFloat x = self.thumbDiameter * 0.5;
        CGFloat startY = 0;
        
        if (CLSliderStyle_Nomal ==self.sliderStyle) {
            startY = MAX(0, spindleScaleStartPoint.y-self.scaleLineHeight);
        }else if (CLSliderStyle_Cross == self.sliderStyle) {
            startY = MAX((H-self.scaleLineHeight)*0.5, 0);
        }
        CGFloat endY = H;
        if (CLSliderStyle_Nomal ==self.sliderStyle) {
            endY = spindleScaleStartPoint.y;
        }else if (CLSliderStyle_Cross == self.sliderStyle) {
            endY = MIN(H, startY+self.scaleLineHeight);
        }
        
        for (NSInteger i = 0; i < lineNum; i ++) {
            CGPoint startP = CGPointMake(x+(i*(oneW)), startY);
            CGPoint endP = CGPointMake(x+(i*(oneW)), endY);
            CGContextMoveToPoint(context, startP.x, startP.y);
            CGContextAddLineToPoint(context, endP.x, endP.y);
            CGContextStrokePath(context);
            
        }
    }else if (CLSliderStyle_Point == self.sliderStyle) {
        ///绘制圆点型刻度分隔
        ///Draw a dot type scale separation
        NSInteger lineNum = self.scaleLineNumber+1;
        CGFloat oneW = (W-self.thumbDiameter)/self.scaleLineNumber;
        CGFloat x = self.thumbDiameter * 0.5;
        CGFloat y = spindleScaleStartPoint.y;

        for (int i = 0; i < lineNum; i++) {
            CGPoint point = CGPointMake(x+(i*(oneW)), y);
            ///填充颜色
            ///Fill color
            CGContextSetFillColorWithColor(context, self.scaleLineColor.CGColor);
            CGContextSetLineWidth(context, 1);
            CGContextAddArc(context, point.x, point.y, self.scaleLineHeight, 0, 2*M_PI, YES);
            ///添加一个圆
            ///Add a circle
            CGContextDrawPath(context, kCGPathFillStroke);
        }
        
    }
    ///设置滑块位置
    ///Set the slider position
    CGFloat thumLayerFrameX = [self thumbLayerFrameXAtindex:self.currentIdx];
    CGRect tmpRect = CGRectMake(thumLayerFrameX, (H-self.thumbDiameter)*0.5, self.thumbDiameter, self.thumbDiameter);
    [self setThumbLayerFrame:tmpRect animated:YES];
}

#pragma mark - 私有方法
///Private Method
- (CGFloat)thumbLayerFrameXAtindex:(NSInteger)idx
{
    CGFloat W = CGRectGetWidth(self.frame);
    CGFloat oneW = (W-self.thumbDiameter)/self.scaleLineNumber;
    CGFloat x = oneW*idx;
    return x;
}

- (void)setThumbLayerFrame:(CGRect)frame animated:(BOOL)animated
{
    if(animated) {
        self.thumbLayer.actions = nil;
        self.thumbLayer.frame = frame;
    }else {
        NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"position", [NSNull null], @"bounds", nil];
        self.thumbLayer.actions = newActions;
        self.thumbLayer.frame = frame;
    }
}

#pragma mark -
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event
{
    CGPoint p = [touch locationInView:self];
    if (p.y>=0 && p.y <= CGRectGetHeight(self.frame)) {
        p.y = self.thumbLayer.position.y;
    }
    if (CGRectContainsPoint(self.thumbLayer.frame, p)) {
        touchOnCircleLayer = YES;
        [self didSeleCtcircleLayer];
        return YES;
    }
    touchOnCircleLayer = NO;
    self.titleLayer.hidden = NO;
    return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event
{
    if (touchOnCircleLayer) {
        CGPoint point = [touch locationInView:self];
        
        CGRect mRect = self.thumbLayer.frame;
        CGFloat x = point.x-self.thumbDiameter*0.5;
        mRect.origin.x = MAX(x, 0);
        mRect.origin.x = MIN(mRect.origin.x, CGRectGetWidth(self.frame)-self.thumbDiameter);
        [self setThumbLayerFrame:mRect animated:NO];
        self.titleLayer.hidden = NO;
        [self refreshSliderPosition];
        [self refreshTitleLayerFrame];
        [self delayAction];

        return YES;
    }
    return NO;
}

- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event
{
    ///设置吸附效果
    ///Set adsorption effect
    CGRect mRect = self.thumbLayer.frame;
    CGFloat W = CGRectGetWidth(self.bounds);
    CGFloat oneW = (W-self.thumbDiameter)/self.scaleLineNumber;
    CGFloat standardW = self.thumbDiameter - 10;
    ///是否需要吸附
    ///Whether adsorption is needed
    BOOL shouldMove = NO;
    int cIdx = -1;
    for (int i=0; i<6; i++) {
        CGFloat x = i*(oneW);
        if (fabs(mRect.origin.x - x) < standardW) {
            shouldMove = YES;
            cIdx = i;
            break;
        }
    }
    if (shouldMove && cIdx >0 && cIdx < 6) {
       [self setSelectedIndex:cIdx];
    }
    
    [self refreshSliderPosition];
    [self endChanged];
    [self refreshTitleLayerFrame];
    [self delayAction];
}

- (void)cancelTrackingWithEvent:(nullable UIEvent *)event
{
//    [self desSelectCircleLayer];
    [self refreshSliderPosition];
    [self endChanged];
    [self refreshTitleLayerFrame];
    [self delayAction];
}

- (void)endChanged {
    if ([self.delegate respondsToSelector:@selector(clSliderEndChanged:)]) {
        [self.delegate clSliderEndChanged:self];
    }
}

- (void)refreshSliderPosition {
    CGFloat W = CGRectGetWidth(self.bounds);
    CGRect finalRect = self.thumbLayer.frame;
    CGFloat finalX = finalRect.origin.x;
    CGFloat rationX = finalX / (W - self.thumbDiameter);
    
    if ([self.delegate respondsToSelector:@selector(clSlider:selectRatio:)]) {
        [self.delegate clSlider:self selectRatio:rationX];
    }
}

- (void)refreshTitleLayerFrame {
    if (self.titleLayerWidth > 0) {
        /*---------- 计算titleLayer位置 Calculate the titleLayer position------------*/
        CGRect finalRect = self.thumbLayer.frame;
        CGFloat finalX = finalRect.origin.x;
        ///计算中心点x
        ///Calculate the center point x
        CGFloat centerX = finalX + self.thumbDiameter/2;
        CGFloat originX = centerX - self.titleLayerWidth/2;
        CGFloat originY = finalRect.origin.y - 24*SCREENSCALE;
        CGFloat width = self.titleLayerWidth;
        CGFloat height = 18*SCREENSCALE;
       
        NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"position", [NSNull null], @"bounds", nil];
        self.titleLayer.actions = newActions;
        self.titleLayer.frame = CGRectMake(originX, originY, width, height);
    }
}

///取消选中
///deselect
- (void)desSelectCircleLayer
{
    self.thumbLayer.transform = CATransform3DIdentity;
    CGRect tmpRect = self.thumbLayer.frame;
    tmpRect.origin.x = [self thumbLayerFrameXAtindex:self.currentIdx];
    
    self.thumbLayer.actions = nil;
    self.thumbLayer.frame = tmpRect;
}

///选中
///select
- (void)didSeleCtcircleLayer
{

}


#pragma mark -
#pragma mark - Setter Method

- (void)setThumbTintColor:(UIColor *)thumbTintColor
{
    _thumbTintColor = thumbTintColor;
    self.thumbLayer.fillColor = thumbTintColor;
}

- (void)setThumbShadowOpacity:(CGFloat)thumbShadowOpacity
{
    _thumbShadowOpacity = thumbShadowOpacity;
    self.thumbLayer.shadowFillOpacity = thumbShadowOpacity;
}
- (void)setThumbShadowColor:(UIColor *)thumbShadowColor
{
    _thumbShadowColor = thumbShadowColor;
    self.thumbLayer.shadowFilColor = thumbShadowColor;
}


- (void)delayAction {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenTitleLayer) object:nil];
    [self performSelector:@selector(hiddenTitleLayer) withObject:nil afterDelay:3.0];
}

- (void)hiddenTitleLayer {
    self.titleLayer.hidden = YES;
}

#pragma mark - Public Method
- (void)setSelectedIndex:(NSInteger)index
{
    index = MAX(0, index);
    index = MIN(index, self.scaleLineNumber);
    self.currentIdx = index;
    
    CGRect tmpRect = self.thumbLayer.frame;
    tmpRect.origin.x = [self thumbLayerFrameXAtindex:self.currentIdx];
    [self setThumbLayerFrame:tmpRect animated:NO];
}
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated
{
    index = MAX(0, index);
    index = MIN(index, self.scaleLineNumber);
    self.currentIdx = index;
    CGRect tmpRect = self.thumbLayer.frame;
    tmpRect.origin.x = [self thumbLayerFrameXAtindex:self.currentIdx];
    [self setThumbLayerFrame:tmpRect animated:animated];

}

- (void)setText:(NSString *)text {
    self.titleLayer.string = text;
}

- (void)setThumbRatio:(double)thumbRatio {
    if (thumbRatio<0 || thumbRatio>1) {
        return;
    }
    CGFloat W = CGRectGetWidth(self.frame);
    CGFloat originX = (W-self.thumbDiameter)*thumbRatio;
    CGRect tmpRect = self.thumbLayer.frame;
    tmpRect.origin.x = originX;
    [self setThumbLayerFrame:tmpRect animated:NO];
}
@end
