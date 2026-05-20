//
//  NvRectView.m
//  aa
//
//  Created by 刘东旭 on 2017/8/11.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import "NvRectView.h"
#import "EFContentView.h"


@implementation NvRotationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(rotationView:touchesBegan:withEvent:)]) {
        [self.delegate rotationView:self touchesBegan:touches withEvent:event];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(rotationView:touchesMoved:withEvent:)]) {
        [self.delegate rotationView:self touchesMoved:touches withEvent:event];
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(rotationView:touchesEnded:withEvent:)]) {
        [self.delegate rotationView:self touchesEnded:touches withEvent:event];
    }
    [super touchesEnded:touches withEvent:event];
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self setImage:[UIImage imageNamed:@"NvRotate"] forState:UIControlStateNormal];
}

@end


@interface NvRectView ()

@property (strong, nonatomic) UIButton *leftTop;
@property (strong, nonatomic) UIButton *rightTop;
@property (strong, nonatomic) NvRotationView *rightBottom;
@property (strong, nonatomic) UIButton *leftBottom;
@property (assign, nonatomic) CGPoint leftTopPoint;
@property (assign, nonatomic) CGPoint rightTopPoint;
@property (assign, nonatomic) CGPoint rightBottompPoint;
@property (assign, nonatomic) CGPoint leftBottomPoint;
@property (assign, nonatomic) BOOL isInRect;
//Used to indicate whether it was a click
@property (assign, nonatomic) BOOL isTouchUpInsideStatus;//用于标识是否是点击

@property (assign, nonatomic) BOOL isHiddenRotation;//
//The time to start pressing
@property (nonatomic, assign) NSTimeInterval begin; //开始按下的时间
//End the time pressed
@property (nonatomic, assign) NSTimeInterval end; //结束按下的时间
//The point at which the press starts
@property (nonatomic, assign) CGPoint beginPoint; //开始按下的点
//End the point pressed
@property (nonatomic, assign) CGPoint endPoint; //结束按下的点
//Whether to stroke the screen
@property (nonatomic, assign) BOOL rollout; //是否划出屏幕
//The compound subtitle draws the bounding box array
@property (nonatomic, strong) NSMutableArray *subCompoundShapeLayers; //复合字幕子字幕绘制边框数组
//Whether it is vertical subtitles or not
@property (nonatomic, assign) BOOL isVerticalCaption;//是否是竖排字幕
@property (nonatomic, assign) NvTextAlign textAlign;
@end

#define NvInterval 150

@implementation NvRectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.type = NV_CAPTION;
        self.subCompoundShapeLayers = [NSMutableArray array];
        [self addSubview:self.leftTop];
        [self addSubview:self.rightTop];
        [self addSubview:self.leftBottom];
        [self addSubview:self.rightBottom];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame type:(NvType)type {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.subCompoundShapeLayers = [NSMutableArray array];
        self.type = type;
        [self addSubview:self.leftTop];
        [self addSubview:self.rightTop];
        [self addSubview:self.leftBottom];
        [self addSubview:self.rightBottom];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.isTouchUpInsideStatus = YES;
    self.rollout = NO;
    self.begin = [NSDate date].timeIntervalSince1970*1000;
    // Several fingers touch the screen
    NSUInteger toucheNum = [[event allTouches] count];//有几个手指触摸屏幕
    if ( toucheNum > 1 ) {
        //Multiple fingers do not perform rotation
        return;//多个手指不执行旋转
    }
    
    if (![touch.view isEqual:self] && ![self.subviews containsObject:touch.view]) {
        return;
    }
    
    //The coordinates of the current finger
    CGPoint currentPoint = [touch locationInView:touch.view];//当前手指的坐标
    self.beginPoint = currentPoint;
    if ([self.delegate respondsToSelector:@selector(rectView:touchBeganPoint:)]) {
        [self.delegate rectView:self touchBeganPoint:currentPoint];
    }
    
    if ([self isInRect:currentPoint]) {
        self.isInRect = true;
        if ([self.delegate respondsToSelector:@selector(rectViewtouchBegan:)]) {
            [self.delegate rectViewtouchBegan:self];
        }
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    self.isTouchUpInsideStatus = NO;
    UITouch *touch = [touches anyObject];
    
    if (self.rollout) {
        return;
    }
    // Several fingers touch the screen
    NSUInteger toucheNum = [[event allTouches] count];//有几个手指触摸屏幕
    if ( toucheNum > 1 ) {
        // Multiple fingers do not perform rotation
        return;//多个手指不执行旋转
    }
    
    if (![touch.view isEqual:self] && ![self.subviews containsObject:touch.view]) {
        return;
    }
    
    CGPoint center = [self getCenter];
    //The coordinates of the current finger
    CGPoint currentPoint = [touch locationInView:touch.view];//当前手指的坐标
    CGPoint previousPoint = [touch previousLocationInView:touch.view];
    
    if (!CGRectContainsPoint(self.bounds, currentPoint)) {
        self.rollout = YES;
        return;
    }
    
    float x = currentPoint.x-previousPoint.x;
    float y = currentPoint.y-previousPoint.y;
    // Distance from the boundary
    NSInteger s = 10;//跟边界的距离

    float minx = currentPoint.x;
    float maxx = currentPoint.x;
    float miny = currentPoint.y;
    float maxy = currentPoint.y;
    //Slide left
    //向左滑
    if (x<0) {
        if ((minx-s)<=0) {
            return;
        }
        //Slide right
    } else {//向右滑
        if ((maxx+s)>=self.frame.size.width) {
            return;
        }
    }
    //Slide up
    //向上滑
    if (y<0) {
        if ((miny-s)<=0) {
            return;
        }
        //Slide down
    } else {//向下滑
        if ((maxy+s)>=self.frame.size.height) {
            return;
        }
    }

    if(self.isInRect) {
        if ([self.delegate respondsToSelector:@selector(rectView:currentPoint:previousPoint:)]) {
            [self.delegate rectView:self currentPoint:currentPoint previousPoint:previousPoint];
        }
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"touchesEnded");
    self.isInRect = false;
    
    UITouch *touch = [touches anyObject];
    NSUInteger toucheNum = [[event allTouches] count];
    if ( toucheNum > 1 ) {
        return;
    }

    if (![touch.view isEqual:self] && ![self.subviews containsObject:touch.view]) {
        return;
    }
    CGPoint currentPoint = [touch locationInView:touch.view];
    
    self.end = [NSDate date].timeIntervalSince1970*1000;
    self.endPoint = currentPoint;
    float offset = [self offsetStartPoint:self.beginPoint endPoint:self.endPoint];
    // Determine if the slide is over
    /// 判断是否是滑动结束
    if (!CGPointEqualToPoint(self.endPoint, self.beginPoint)) {
        if ([self.delegate respondsToSelector:@selector(rectView:touchesEnded:)]) {
            [self.delegate rectView:self touchesEnded:currentPoint];
        }
    }
    
    /*
     On iphone8, on iOS12 system, clicking the screen will start touchmove, which may be caused by too sensitive hardware sensor or system difference, so it is changed to judge by moving offset and press time
    单独isTouchUpInsideStatus来判断在iphone8上iOS12系统上，单击屏幕会出发touchmove，可能是硬件传感器过于灵敏导致的也可能是系统差异，所以改为通过移动偏移量和按压时间来判断
    */
    if (/*self.isTouchUpInsideStatus && */offset < 3 && (self.begin-self.end)<NvInterval) {
        //It's just click events
        //只是点击事件
        if ([self.delegate respondsToSelector:@selector(rectView:touchUpInside:)]) {
            [self.delegate rectView:self touchUpInside:currentPoint];
        }
    }
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    self.isInRect = false;
    
    UITouch *touch = [touches anyObject];
    NSUInteger toucheNum = [[event allTouches] count];
    if ( toucheNum > 1 ) {
        return;
    }

    if (![touch.view isEqual:self] && ![self.subviews containsObject:touch.view]) {
        return;
    }
    CGPoint currentPoint = [touch locationInView:touch.view];
    
    if ([self.delegate respondsToSelector:@selector(rectView:touchesEnded:)]) {
        [self.delegate rectView:self touchesEnded:currentPoint];
    }
    
    self.end = [NSDate date].timeIntervalSince1970*1000;
    self.endPoint = currentPoint;
    float offset = [self offsetStartPoint:self.beginPoint endPoint:self.endPoint];
    if (/*self.isTouchUpInsideStatus && */offset < 3 && (self.begin-self.end)<NvInterval) {
        if ([self.delegate respondsToSelector:@selector(rectView:touchUpInside:)]) {
            [self.delegate rectView:self touchUpInside:currentPoint];
        }
    }
    [super touchesCancelled:touches withEvent:event];
}

- (void)rotationView:(NvRotationView *)rotationView touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.rollout = NO;
    if ([self.delegate respondsToSelector:@selector(rectViewtouchBegan:)]) {
        [self.delegate rectViewtouchBegan:self];
    }
}
- (void)rotationView:(NvRotationView *)rotationView touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(rectView:rotationEnded:)]) {
        [self.delegate rectView:self rotationEnded:CGPointZero];
    }
}
// Zoom and rotate
//缩放和旋转
- (void)rotationView:(NvRotationView *)rotationView touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.isTouchUpInsideStatus = NO;
    UITouch *touch = [touches anyObject];
    
    if (self.rollout) {
        return;
    }
    
    NSUInteger toucheNum = [[event allTouches] count];
    if ( toucheNum > 1 ) {
        return;
    }
    
    CGPoint center = [self getCenter];
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint previousPoint = [touch previousLocationInView:self];
    
    if (!CGRectContainsPoint(self.bounds, currentPoint)) {
        self.rollout = YES;
        return;
    }
    
    float x = currentPoint.x-previousPoint.x;
    float y = currentPoint.y-previousPoint.y;
    NSInteger s = 10;
    
    float minx = currentPoint.x;
    float maxx = currentPoint.x;
    float miny = currentPoint.y;
    float maxy = currentPoint.y;
    //slide left
    //向左滑
    if (x<0) {
        if ((minx-s)<=0) {
            return;
        }
    } else {//向右滑 slide right
        if ((maxx+s)>=self.frame.size.width) {
            return;
        }
    }
    //向上滑 slide up
    if (y<0) {
        if ((miny-s)<=0) {
            return;
        }
    } else {//向下滑 slide down
        if ((maxy+s)>=self.frame.size.height) {
            return;
        }
    }
    
        
    CGFloat angle = atan2f(currentPoint.y - center.y, currentPoint.x - center.x) - atan2f(previousPoint.y - center.y, previousPoint.x - center.x);
    
    CGFloat scale = sqrtf(powf(currentPoint.y - center.y, 2)+powf(currentPoint.x - center.x, 2))/sqrtf(powf(previousPoint.y - center.y, 2)+powf(previousPoint.x - center.x, 2));
    
    if ([self.delegate respondsToSelector:@selector(rectView:rotate:scale:)]) {
        [self.delegate rectView:self rotate:-angle*180/M_PI scale:scale];
    }
        
}

- (float)offsetStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    CGFloat offset = sqrtf(powf(startPoint.y - endPoint.y, 2)+powf(startPoint.x - endPoint.x, 2));
    return offset;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if ([self.delegate respondsToSelector:@selector(rectView:isHidden:)]) {
        [self.delegate rectView:self isHidden:self.hidden];
    }
}

- (void)hidenAlignImage:(BOOL)hiden {
    self.leftBottom.hidden = hiden;
}

- (void)hideVoiceButton:(BOOL)hidden {
    self.leftBottom.hidden = hidden;
}

- (void)hiddenAllImage {
    self.leftBottom.hidden = YES;
    self.leftTop.hidden = YES;
    self.rightTop.hidden = YES;
    self.rightBottom.hidden = YES;
    self.isHiddenRotation = YES;
}

- (void)close {
    if ([self.delegate respondsToSelector:@selector(rectView:close:)]) {
        [self.delegate rectView:self close:self.rightTop];
    }
}

- (void)align {
    if ([self.delegate respondsToSelector:@selector(rectView:align:)]){
        [self.delegate rectView:self align:self.leftBottom];
    }
}

- (void)toggleVolume{
    if ([self.delegate respondsToSelector:@selector(rectView:toggleVolume:)]){
        [self.delegate rectView:self toggleVolume:self.leftBottom];
    }
}

- (void)horizontalFlip {
    if ([self.delegate respondsToSelector:@selector(rectView:horizontalFlip:)]) {
        [self.delegate rectView:self horizontalFlip:self.leftTop];
    }
}

- (void)verticalSwitch {
    NvTextAlign align = self.textAlign;
    self.isVerticalCaption = !self.isVerticalCaption;
    if (self.isVerticalCaption) {
        [self.leftTop setImage:[UIImage imageNamed:@"NvHorizontalSwitch"] forState:UIControlStateNormal];
    } else {
        [self.leftTop setImage:[UIImage imageNamed:@"NvVerticalSwitch"] forState:UIControlStateNormal];
    }
    self.textAlign = align;
    if ([self.delegate respondsToSelector:@selector(rectView:verticalSwitch:)]) {
        [self.delegate rectView:self verticalSwitch:self.isVerticalCaption];
    }
}

- (void)setVolume:(BOOL)isVoice {
    if (isVoice) {
        [_leftBottom setImage:[UIImage imageNamed:@"NvVoice"] forState:UIControlStateNormal];
    } else {
        [_leftBottom setImage:[UIImage imageNamed:@"NvSilent"] forState:UIControlStateNormal];
    }
}

- (void)setTextAlign:(NvTextAlign)align {
    _textAlign = align;
    if (self.isVerticalCaption) {
        if (align == NvLeft) {
            [_leftBottom setImage:[UIImage imageNamed:@"NvTextAlignedTop"] forState:UIControlStateNormal];
        } else if (align == NvCenter) {
            [_leftBottom setImage:[UIImage imageNamed:@"NvTextAlignedMid"] forState:UIControlStateNormal];
        }else if (align == NvRight) {
            [_leftBottom setImage:[UIImage imageNamed:@"NvTextAlignedBottom"] forState:UIControlStateNormal];
        } else {
            [_leftBottom setImage:[UIImage imageNamed:@"NvTextAlignedTop"] forState:UIControlStateNormal];
        }
    } else {
        if (align == NvLeft) {
            [_leftBottom setImage:[UIImage imageNamed:@"NvTextAlignedLeft"] forState:UIControlStateNormal];
        } else if (align == NvCenter) {
            [_leftBottom setImage:[UIImage imageNamed:@"NvTextAlignedCenter"] forState:UIControlStateNormal];
        }else if (align == NvRight) {
            [_leftBottom setImage:[UIImage imageNamed:@"NvTextAlignedRight"] forState:UIControlStateNormal];
        } else {
            [_leftBottom setImage:[UIImage imageNamed:@"NvTextAlignedLeft"] forState:UIControlStateNormal];
        }
    }
}

//MARK Getter
- (UIButton *)leftTop {
    if (!_leftTop) {
        _leftTop = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        if (_type == NV_CAPTION) {
            [_leftTop setImage:[UIImage imageNamed:@"NvVerticalSwitch"] forState:UIControlStateNormal];
            [_leftTop addTarget:self action:@selector(verticalSwitch) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [_leftTop setImage:[UIImage imageNamed:@"NvHorizontalFlip"] forState:UIControlStateNormal];
            [_leftTop addTarget:self action:@selector(horizontalFlip) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _leftTop;
}

- (UIButton *)rightTop {
    if (!_rightTop) {
        _rightTop = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-20, 0, 20, 20)];
        [_rightTop setImage:[UIImage imageNamed:@"NvClose"] forState:UIControlStateNormal];
        [_rightTop addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
//        _rightTop.alpha = 0;
    }
    return _rightTop;
}

- (NvRotationView *)rightBottom {
    if (!_rightBottom) {
        _rightBottom = [[NvRotationView alloc] initWithFrame:CGRectMake(self.frame.size.width-20, self.frame.size.height-20, 20, 20)];
        _rightBottom.delegate = self;
//        _rightBottom.alpha = 0;
    }
    return _rightBottom;
}

- (UIButton *)leftBottom {
    if (!_leftBottom) {
        _leftBottom = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height-20, 20, 20)];
        if (self.type == NV_CAPTION) {
            [_leftBottom setImage:[UIImage imageNamed:@"NvTextAlignedLeft"] forState:UIControlStateNormal];
            [_leftBottom addTarget:self action:@selector(align) forControlEvents:
             UIControlEventTouchUpInside];
        } else {
            [_leftBottom setImage:[UIImage imageNamed:@"NvVoice"] forState:UIControlStateNormal];
            [_leftBottom addTarget:self action:@selector(toggleVolume) forControlEvents:
             UIControlEventTouchUpInside];
        }

        //_leftBottom.alpha = 0;
    }
    return _leftBottom;
}
//redraw
//重新绘制
- (void)setPoints:(NSArray *)array {
    self.leftTopPoint = [array[0] CGPointValue];
    self.leftBottomPoint = [array[1] CGPointValue];
    self.rightBottompPoint = [array[2] CGPointValue];
    self.rightTopPoint = [array[3] CGPointValue];
    self.leftTop.center = self.leftTopPoint;
    self.rightTop.center = self.rightTopPoint;
    self.rightBottom.center = self.rightBottompPoint;
    self.leftBottom.center = self.leftBottomPoint;
    [self setNeedsDisplay];
}
//Determine if the point is within the four Point Siege rect
//判断点是否在四点围城rect之内
- (BOOL)isInRect:(CGPoint)p {
    CGMutablePathRef pathRef=CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, NULL, self.leftTopPoint.x, self.leftTopPoint.y);
    CGPathAddLineToPoint(pathRef, NULL, self.leftBottomPoint.x, self.leftBottomPoint.y);
    CGPathAddLineToPoint(pathRef, NULL, self.rightBottompPoint.x, self.rightBottompPoint.y);
    CGPathAddLineToPoint(pathRef, NULL, self.rightTopPoint.x, self.rightTopPoint.y);
    CGPathCloseSubpath(pathRef);
    BOOL isIn = CGPathContainsPoint(pathRef, nil, p, false);
    CGPathRelease(pathRef);
    return isIn;
}

- (CGPoint)getCenter {
    return CGPointMake((self.leftTop.center.x+self.rightBottom.center.x)/2, (self.leftTop.center.y+self.rightBottom.center.y)/2);
}

-(void)setRectLineColor:(UIColor *)rectLineColor {
    _rectLineColor = rectLineColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(contextRef, kCGLineCapRound);
    CGContextSetLineWidth(contextRef, 2);
    CGContextSetAllowsAntialiasing(contextRef, true);
    if (self.rectLineColor) {
        CGFloat r,g,b;
        [self.rectLineColor getRed:&r green:&g blue:&b alpha:NULL];
        CGContextSetRGBStrokeColor(contextRef, r, g, b, 1.0);
    } else {
        CGContextSetRGBStrokeColor(contextRef, 74.0 / 255.0, 144.0 / 255.0, 226.0 / 255.0, 1.0);
    }
    CGContextBeginPath(contextRef);

    CGContextMoveToPoint(contextRef, self.leftTopPoint.x, self.leftTopPoint.y);
    CGContextAddLineToPoint(contextRef, self.leftBottomPoint.x, self.leftBottomPoint.y);
    CGContextAddLineToPoint(contextRef, self.rightBottompPoint.x, self.rightBottompPoint.y);
    CGContextAddLineToPoint(contextRef, self.rightTopPoint.x, self.rightTopPoint.y);
    CGContextAddLineToPoint(contextRef, self.leftTopPoint.x, self.leftTopPoint.y);
    
    CGContextStrokePath(contextRef);
}
// A single subtitle redraws the border
//单个子字幕重新绘制边框
- (void)changeModifiableSingleCaptionWithPoints:(NSArray *)points {
    if (points.count == 4) {
        UIBezierPath *polygonPath = [UIBezierPath bezierPath];
        NSValue *value = points[0];
        CGPoint point = [value CGPointValue];
        [polygonPath moveToPoint:point];
        for (int j=1; j<points.count; j++) {
            NSValue *nextValue = points[j];
            [polygonPath addLineToPoint:[nextValue CGPointValue]];
        }
        [polygonPath closePath];
        
        CAShapeLayer *polygonLayer = [CAShapeLayer layer];
        polygonLayer.lineWidth = 1.f;
        //Set line width and line spacing
        //  设置线宽，线间距
        [polygonLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithInt:1], nil]];
        polygonLayer.strokeColor = [UIColor colorWithRed:(float)155/255 green:(float)155/255 blue:(float)155/255 alpha:1].CGColor;
        polygonLayer.path = polygonPath.CGPath;
        polygonLayer.fillColor = nil;
        [self.subCompoundShapeLayers addObject:polygonLayer];
        [self.layer insertSublayer:polygonLayer atIndex:0];
    }
}
// Can change the caption and redraw the border
//可修改字幕重新绘制边框
- (void)changeModifiableInternalCaptionsWithPoints:(NSArray *)points {
    for (CAShapeLayer *layer in self.subCompoundShapeLayers) {
        [layer removeFromSuperlayer];
    }
    if (points.count >0) {
        for (int i=0; i<points.count; i++) {
            NSArray *pointArr = points[i];
            [self changeModifiableSingleCaptionWithPoints:pointArr];
        }
        
    }
}

- (void)clearCaptionLayers {
    for (CAShapeLayer *layer in self.subCompoundShapeLayers) {
        [layer removeFromSuperlayer];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    EFContentView *superview = (EFContentView *)[self superview];
    for (UIView *view in superview.subviews) {
            if ([self isInRect:point]) {
                return self;
            } else if (CGRectContainsPoint(view.frame, point)) {
                if ([view isMemberOfClass:[self class]]) {
                    return view;
                } else {
                    return [view hitTest:point withEvent:event];
                }
            } else if (CGRectContainsPoint(self.rightBottom.frame, point)) {
                return self.rightBottom;
            }else if (CGRectContainsPoint(self.rightTop.frame, point)) {
                return self.rightTop;
            }
    }
    
    return [superview hitTest:point withEvent:event];;

}
@end
