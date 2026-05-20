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
///用于标识是否是点击
///Used to identify whether it is a click
@property (assign, nonatomic) BOOL isTouchUpInsideStatus;

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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
