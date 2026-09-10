//
//  NvPIPRectView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/18.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvPIPRectView.h"
#import "NVDefineConfig.h"

@interface NvPIPRectView ()

@property (assign, nonatomic) BOOL isDown;
@property (assign, nonatomic) BOOL isInRect;
///用于标识是否是点击
///Used to identify whether it is a click
@property (assign, nonatomic) BOOL isTouchUpInsideStatus;

@end

@implementation NvPIPRectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.isTouchUpInsideStatus = YES;
    NSUInteger toucheNum = [[event allTouches] count];
    if ( toucheNum > 1 ) {
        return;
    }
    
    if (![touch.view isEqual:self]) {
        return;
    }
    
    CGPoint currentPoint = [touch locationInView:touch.view];
    
    if ([self.delegate respondsToSelector:@selector(rectView:touchBeganPoint:)]) {
        [self.delegate rectView:self touchBeganPoint:currentPoint];
    }
    [super touchesBegan:touches withEvent:event];
        self.isInRect = true;

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    self.isTouchUpInsideStatus = NO;
    UITouch *touch = [touches anyObject];
    
    NSUInteger toucheNum = [[event allTouches] count];
    if ( toucheNum > 1 ) {
        return;
    }
    
    if (![touch.view isEqual:self]) {
        return;
    }
    
    CGPoint currentPoint = [touch locationInView:touch.view];
    CGPoint previousPoint = [touch previousLocationInView:touch.view];
    
    
    float x = currentPoint.x-previousPoint.x;
    float y = currentPoint.y-previousPoint.y;
    ///边界的距离
    ///Distance of boundary
    NSInteger s = 10;
    
    float minx = currentPoint.x;
    float maxx = currentPoint.x;
    float miny = currentPoint.y;
    float maxy = currentPoint.y;
    ///向左滑
    ///Slide to the left
    if (x<0) {
        if ((minx-s)<=0) {
            return;
        }
    } else {
        ///向右滑
        ///Slide to the right
        if ((maxx+s)>=self.frame.size.width) {
            return;
        }
    }
    ///向上滑
    ///Upward slide
    if (y<0) {
        if ((miny-s)<=0) {
            return;
        }
    } else {
        ///向下滑
        ///Slide down
        if ((maxy+s)>=self.frame.size.height) {
            return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(rectView:currentPoint:previousPoint:)]) {
        [self.delegate rectView:self currentPoint:currentPoint previousPoint:previousPoint];
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.isDown = false;
    self.isInRect = false;
    
    UITouch *touch = [touches anyObject];
    NSUInteger toucheNum = [[event allTouches] count];
    if ( toucheNum > 1 ) {
        return;
    }
    
    if (![touch.view isEqual:self]) {
        return;
    }
    CGPoint currentPoint = [touch locationInView:touch.view];
    if (self.isTouchUpInsideStatus) {
        if ([self.delegate respondsToSelector:@selector(rectView:touchUpInside:)]) {
            [self.delegate rectView:self touchUpInside:currentPoint];
        }
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.isDown = false;
    self.isInRect = false;
    
    UITouch *touch = [touches anyObject];
    NSUInteger toucheNum = [[event allTouches] count];
    if ( toucheNum > 1 ) {
        return;
    }
    
    if (![touch.view isEqual:self]) {
        return;
    }
    CGPoint currentPoint = [touch locationInView:touch.view];//当前手指的坐
    if (self.isTouchUpInsideStatus) {
        if ([self.delegate respondsToSelector:@selector(rectView:touchUpInside:)]) {
            [self.delegate rectView:self touchUpInside:currentPoint];
        }
    } else {
        [super touchesCancelled:touches withEvent:event];
    }
}

///判断点是否在四点围城rect之内
///Determine if the point is within the four-point Siege rect
- (BOOL)isInRect:(CGPoint)p {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef pathRef=CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, NULL, 0, 0);
    CGPathAddLineToPoint(pathRef, NULL, 36*SCREENSCALE, 15*SCREENSCALE);
    CGPathAddLineToPoint(pathRef, NULL, 36*SCREENSCALE, 40*SCREENSCALE);
    CGPathAddLineToPoint(pathRef, NULL, 0, 40*SCREENSCALE);
    CGPathCloseSubpath(pathRef);
    CGContextAddPath(ctx, pathRef);
    BOOL isIn = CGPathContainsPoint(pathRef, nil, p, false);
    CGPathRelease(pathRef);
    return isIn;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(contextRef, kCGLineCapRound);
    CGContextSetLineWidth(contextRef, 2);
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetRGBStrokeColor(contextRef, 74.0 / 255.0, 144.0 / 255.0, 226.0 / 255.0, 1.0);
    CGContextBeginPath(contextRef);
    
    CGContextMoveToPoint(contextRef, 0, 0);
    CGContextAddLineToPoint(contextRef, rect.size.width, 0);
    CGContextAddLineToPoint(contextRef, rect.size.width, rect.size.height);
    CGContextAddLineToPoint(contextRef, 0, rect.size.height);
    CGContextAddLineToPoint(contextRef, 0, 0);
    
    CGContextStrokePath(contextRef);
}


@end
