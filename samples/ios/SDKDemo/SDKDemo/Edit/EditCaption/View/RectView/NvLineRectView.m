//
//  NvLineRectView.m
//  
//
//  Created by 刘东旭 on 2019/8/15.
//  Copyright © 2019 刘东旭. All rights reserved.
//

#import "NvLineRectView.h"
#import <NvSDKCommon/NvUtils.h>

@interface NvLineRectView ()<UIGestureRecognizerDelegate>

@property (assign, nonatomic) CGPoint leftTopPoint;
@property (assign, nonatomic) CGPoint rightTopPoint;
@property (assign, nonatomic) CGPoint rightBottompPoint;
@property (assign, nonatomic) CGPoint leftBottomPoint;

@property (nonatomic, assign) float preRotation;
@property (nonatomic, assign) CGPoint prePonit;

@end


@implementation NvLineRectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        pinch.delegate = self;
        [self addGestureRecognizer:pinch];
        UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotation:)];
        rotation.delegate = self;
        [self addGestureRecognizer:rotation];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.delegate = self;
        [self addGestureRecognizer:pan];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        //        tap.delegate = self;
        [self addGestureRecognizer:tap];
        [tap requireGestureRecognizerToFail:pan];
    }
    return self;
}

#pragma mark 点击手势
///Click gesture
- (void)tap:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    if ([self.delegate respondsToSelector:@selector(containObjectForPoint:)]) {
        BOOL contain = [self.delegate containObjectForPoint:point];
        if (!contain) {
            if ([self.delegate respondsToSelector:@selector(lineRectView:touchUpInside:)]) {
                [self.delegate lineRectView:self touchUpInside:point];
            }
            return;
        }
    }
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"pinch begin");
            if ([self.delegate respondsToSelector:@selector(lineRectView:touchBeganPoint:)]) {
                [self.delegate lineRectView:self touchBeganPoint:point];
            }
            break;
        case UIGestureRecognizerStateChanged:
            
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
            if ([self.delegate respondsToSelector:@selector(lineRectView:touchUpInside:)]) {
                [self.delegate lineRectView:self touchUpInside:point];
            }
            break;
        default:
            break;
    }
}
#pragma mark 捏合手势
///PinchGesture
- (void)pinch:(UIPinchGestureRecognizer *)gesture {
    float scale = 1;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            scale = 1;
            NSLog(@"pinch begin");
            CGPoint point = [gesture locationInView:self];
            if ([self.delegate respondsToSelector:@selector(lineRectView:touchBeganPoint:)]) {
                [self.delegate lineRectView:self touchBeganPoint:point];
            }
            break;
        case UIGestureRecognizerStateChanged:
        {
            scale = gesture.scale;
            if ([self.delegate respondsToSelector:@selector(gestureRectViewPinchScale:)]) {
                [self.delegate gestureRectViewPinchScale:scale];
            }
            NSLog(@"%f",scale);
            gesture.scale = 1;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
            scale = 1;
            if ([self.delegate respondsToSelector:@selector(lineRectView:touchesEnded:)]) {
                CGPoint point = [gesture locationInView:self];
                [self.delegate lineRectView:self touchesEnded:point];
            }
            break;
        default:
            break;
    }
}
#pragma mark 旋转手势
///RotationGesture
- (void)rotation:(UIRotationGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"rotation begin");
            CGPoint point = [gesture locationInView:self];
            if ([self.delegate respondsToSelector:@selector(lineRectView:touchBeganPoint:)]) {
                [self.delegate lineRectView:self touchBeganPoint:point];
            }
            break;
        case UIGestureRecognizerStateChanged:
        {
            float angle = -(gesture.rotation - self.preRotation) * 180/M_PI;
            if ([self.delegate respondsToSelector:@selector(gestureRectViewRotation:)]) {
                [self.delegate gestureRectViewRotation:angle];
            }
            self.preRotation = gesture.rotation;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
            self.preRotation = 0;
            if ([self.delegate respondsToSelector:@selector(lineRectView:touchesEnded:)]) {
                CGPoint point = [gesture locationInView:self];
                [self.delegate lineRectView:self touchesEnded:point];
            }
            break;
        default:
            break;
    }
}
#pragma mark 平移手势
///PanGesture
- (void)pan:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    CGPoint pointP = [gesture translationInView:self];
    if (!CGRectContainsPoint(self.bounds, point)) {
        gesture.enabled = NO;
    }
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.prePonit = point;
            CGPoint pointbegin = [gesture locationInView:self];
            if ([self.delegate respondsToSelector:@selector(lineRectView:touchBeganPoint:)]) {
                [self.delegate lineRectView:self touchBeganPoint:pointbegin];
            }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if ([self.delegate respondsToSelector:@selector(lineRectView:currentPoint:previousPoint:)]) {
                [self.delegate lineRectView:self currentPoint:point previousPoint:CGPointMake(point.x-pointP.x, point.y-pointP.y)];
            }
            ///重置偏移量
            ///Reset offset
            [gesture setTranslation:CGPointZero inView:self];
            self.prePonit = point;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
            if ([self.delegate respondsToSelector:@selector(lineRectView:touchesEnded:)]) {
                [self.delegate lineRectView:self touchesEnded:point];
            }
            gesture.enabled = YES;
            break;
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSUInteger num = gestureRecognizer.numberOfTouches;
    if (num == 1) {
        CGPoint firstPonit = [gestureRecognizer locationOfTouch:0 inView:self];
        if ([self.delegate respondsToSelector:@selector(containObjectForPoint:)]) {
            BOOL containFirst = [self.delegate containObjectForPoint:firstPonit];
            if (!containFirst) {
                if ([self isInRect:firstPonit]) {
                    return YES;
                } else {
                    return NO;
                }
            } else {
                return YES;
            }
        }
    } else if (num == 2) {
        CGPoint firstPonit = [gestureRecognizer locationOfTouch:0 inView:self];
        CGPoint lastPonit = [gestureRecognizer locationOfTouch:1 inView:self];
        if ([self.delegate respondsToSelector:@selector(containSameObjectForPoint:otherPoint:)]) {
            return [self.delegate containSameObjectForPoint:firstPonit otherPoint:lastPonit];
        }
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

///重新绘制
///redraw
- (void)setPoints:(NSArray *)array {
    self.leftTopPoint = [array[0] CGPointValue];
    self.leftBottomPoint = [array[1] CGPointValue];
    self.rightBottompPoint = [array[2] CGPointValue];
    self.rightTopPoint = [array[3] CGPointValue];
    [self setNeedsDisplay];
}

///判断点是否在四点围城rect之内
///Determine if the point is within the four-point Siege rect
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
    return CGPointMake((self.leftTopPoint.x+self.rightBottompPoint.x)/2, (self.leftTopPoint.y+self.rightBottompPoint.y)/2);
}

- (void)setHiddenRectLine:(BOOL)hiddenRectLine {
    _hiddenRectLine = hiddenRectLine;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (!self.hiddenRectLine) {
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        CGContextSetLineCap(contextRef, kCGLineCapRound);
        CGContextSetLineWidth(contextRef, 2);
        CGContextSetAllowsAntialiasing(contextRef, true);
        CGContextSetRGBStrokeColor(contextRef, 234.0 / 255.0, 46.0 / 255.0, 81.0 / 255.0, 1.0);
        CGContextBeginPath(contextRef);
        
        CGContextMoveToPoint(contextRef, self.leftTopPoint.x, self.leftTopPoint.y);
        CGContextAddLineToPoint(contextRef, self.leftBottomPoint.x, self.leftBottomPoint.y);
        CGContextAddLineToPoint(contextRef, self.rightBottompPoint.x, self.rightBottompPoint.y);
        CGContextAddLineToPoint(contextRef, self.rightTopPoint.x, self.rightTopPoint.y);
        CGContextAddLineToPoint(contextRef, self.leftTopPoint.x, self.leftTopPoint.y);
        
        CGContextStrokePath(contextRef);
    }
    
}

@end
