//
//  NvPIPRectView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/18.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvPIPRectView.h"
#import <NvBaseCommon/NVDefineConfig.h>

@interface NvPIPRectView ()

@property (assign, nonatomic) BOOL isDown;
@property (assign, nonatomic) BOOL isInRect;
@property (assign, nonatomic) BOOL isTouchUpInsideStatus;//用于标识是否是点击

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
    NSUInteger toucheNum = [[event allTouches] count];//有几个手指触摸屏幕
    if ( toucheNum > 1 ) {
        return;//多个手指不执行旋转
    }
    
    //self.tranformView，你想旋转的视图
    if (![touch.view isEqual:self]) {
        return;
    }
    
    CGPoint currentPoint = [touch locationInView:touch.view];//当前手指的坐标
    
    if ([self.delegate respondsToSelector:@selector(rectView:touchBeganPoint:)]) {
        [self.delegate rectView:self touchBeganPoint:currentPoint];
    }
    [super touchesBegan:touches withEvent:event];
//    if (![self isInRect:currentPoint]) {
        self.isInRect = true;
//    } else {
//        [super touchesBegan:touches withEvent:event];
//    }

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    self.isTouchUpInsideStatus = NO;
    UITouch *touch = [touches anyObject];
    
    NSUInteger toucheNum = [[event allTouches] count];//有几个手指触摸屏幕
    if ( toucheNum > 1 ) {
        return;//多个手指不执行旋转
    }
    
    //self.tranformView，你想旋转的视图
    if (![touch.view isEqual:self]) {
        return;
    }
    
//    CGPoint center = [self center];
    CGPoint currentPoint = [touch locationInView:touch.view];//当前手指的坐标
    CGPoint previousPoint = [touch previousLocationInView:touch.view];//上一个坐标
    
    
    float x = currentPoint.x-previousPoint.x;
    float y = currentPoint.y-previousPoint.y;
    NSInteger s = 10;//跟边界的距离
    
    float minx = currentPoint.x;
    float maxx = currentPoint.x;
    float miny = currentPoint.y;
    float maxy = currentPoint.y;
    //向左滑
    if (x<0) {
        if ((minx-s)<=0) {
            return;
        }
    } else {//向右滑
        if ((maxx+s)>=self.frame.size.width) {
            return;
        }
    }
    //向上滑
    if (y<0) {
        if ((miny-s)<=0) {
            return;
        }
    } else {//向下滑
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
    NSUInteger toucheNum = [[event allTouches] count];//有几个手指触摸屏幕
    if ( toucheNum > 1 ) {
        return;//多个手指不执行旋转
    }
    //self.tranformView，你想旋转的视图
    if (![touch.view isEqual:self]) {
        return;
    }
    CGPoint currentPoint = [touch locationInView:touch.view];//当前手指的坐标
    if (self.isTouchUpInsideStatus) {
        //只是点击事件
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
    NSUInteger toucheNum = [[event allTouches] count];//有几个手指触摸屏幕
    if ( toucheNum > 1 ) {
        return;//多个手指不执行旋转
    }
    //self.tranformView，你想旋转的视图
    if (![touch.view isEqual:self]) {
        return;
    }
    CGPoint currentPoint = [touch locationInView:touch.view];//当前手指的坐标
    if (self.isTouchUpInsideStatus) {
        //只是点击事件
        if ([self.delegate respondsToSelector:@selector(rectView:touchUpInside:)]) {
            [self.delegate rectView:self touchUpInside:currentPoint];
        }
    } else {
        [super touchesCancelled:touches withEvent:event];
    }
}

//判断点是否在四点围城rect之内
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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(contextRef, kCGLineCapRound);
    CGContextSetLineWidth(contextRef, 2);  //线宽
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetRGBStrokeColor(contextRef, 74.0 / 255.0, 144.0 / 255.0, 226.0 / 255.0, 1.0);  //线的颜色
    CGContextBeginPath(contextRef);
    
    CGContextMoveToPoint(contextRef, 0, 0);
    CGContextAddLineToPoint(contextRef, rect.size.width, 0);
    CGContextAddLineToPoint(contextRef, rect.size.width, rect.size.height);
    CGContextAddLineToPoint(contextRef, 0, rect.size.height);
    CGContextAddLineToPoint(contextRef, 0, 0);
    
    CGContextStrokePath(contextRef);
}


@end
