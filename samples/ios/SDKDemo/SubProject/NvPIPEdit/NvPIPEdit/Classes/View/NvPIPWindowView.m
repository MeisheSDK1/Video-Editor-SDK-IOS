//
//  NvPIPWindowView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/21.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvPIPWindowView.h"

@interface NvPIPWindowView ()

@property (assign, nonatomic) BOOL isDown;
@property (assign, nonatomic) BOOL isInRect;
@property (assign, nonatomic) BOOL isTouchUpInsideStatus;//用于标识是否是点击

@end

@implementation NvPIPWindowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
