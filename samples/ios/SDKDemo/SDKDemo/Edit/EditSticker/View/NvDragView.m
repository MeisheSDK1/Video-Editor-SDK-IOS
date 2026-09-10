//
//  NvDragView.m
//  SDKDemo
//
//  Created by dx on 2018/6/21.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvDragView.h"
#import "NvDragBarView.h"
#import <QuartzCore/CALayer.h>

@interface NvDragView() <NvDragBarViewDelegate>

@end

@implementation NvDragView {
    CGPoint _startPoint;
    NvDragBarView *_dragBarView;
    CAShapeLayer *_border;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.userInteractionEnabled = YES;
        [self setBackgroundColor:[UIColor clearColor]];
        
        _border = [CAShapeLayer layer];

        _border.strokeColor = [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1.0].CGColor;
        
        _border.fillColor = nil;
        
        _border.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        
        _border.frame = self.bounds;
        _originRect = self.bounds;
        
        _border.lineWidth = 3;
        
        _border.lineCap = @"square";
        
        [self.layer addSublayer:_border];
    }
    
    
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    _startPoint = point;
    
    [[self superview] bringSubviewToFront:self];
}

- (BOOL)isMoveRightBottomPoint:(CGPoint)point {
    if (fabs(point.x - self.bounds.size.width) <= 50*SCREENSCALE && fabs(point.y - self.bounds.size.height) <= 50*SCREENSCALE) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -50, -50);
    return CGRectContainsPoint(bounds, point);
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    CGPoint previousPoint = [[touches anyObject] previousLocationInView:self];

    if ([self isMoveRightBottomPoint:previousPoint]) {
        float dx = point.x - previousPoint.x;
        float dy = point.y - previousPoint.y;
        
        if (_mode != freeMode) {
            if(dx > dy) {
                dy = dx / _scale;
            } else {
                dx = dy * _scale;
            }
        }
        
        CGPoint oldcenter = self.center;

        CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
        
        CGPoint movePoint = CGPointMake(newcenter.x - oldcenter.x, newcenter.y - oldcenter.y);
        [self movePoint:movePoint];
        return;
    }
    float dx = point.x - previousPoint.x;
    float dy = point.y - previousPoint.y;
    
    ///计算移动后的view中心点
    ///Calculate the center point of the moved view
    CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
    
    ///限制用户不可将视图托出屏幕
    ///Restrict users from pushing views off the screen
    float halfx = CGRectGetMidX(self.bounds);
    ///x坐标左边界
    ///The left boundary of the x-coordinate
    newcenter.x = MAX(halfx, newcenter.x);
    ///x坐标右边界
    ///The right edge of the x-coordinate
    newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);
    
    ///y坐标同理
    ///Same thing with the y coordinate
    float halfy = CGRectGetMidY(self.bounds);
    newcenter.y = MAX(halfy, newcenter.y);
    newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);
    
    ///移动view
    ///Move view
    self.center = newcenter;
    [self.delegate updateRect:self.frame];
}

- (void) movePoint:(CGPoint)point {
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;
    CGFloat width = self.frame.size.width + point.x;
    CGFloat height = self.frame.size.height + point.y;
    CGSize maxSize = self.superview.bounds.size;
    CGFloat scale = self.bounds.size.width / self.bounds.size.height;
    CGSize minSize = CGSizeMake(100 * SCREENSCALE, 100 * SCREENSCALE);
    if (x+width > maxSize.width) {
        width = maxSize.width - x;
        if (_mode != freeMode)
            height = width / scale;
    }
    if (y+height > maxSize.height) {
        height = maxSize.height - y;
        if (_mode != freeMode)
            width = height * scale;
    }
    if (width > minSize.width && height > minSize.height) {
        CGRect rect = CGRectMake(x, y, width, height);
        [self setFrame:rect];
        [_delegate updateRect:rect];
    }
    
    [self updateDragBar];
}

///添加缩放按钮
///Add zoom button
- (void) addDragBar {
    if (_dragBarView != nil) {
        [_dragBarView removeFromSuperview];
    }
    
    CGFloat x = self.frame.size.width - 25;
    CGFloat y = self.frame.size.height - 25;
    if (_mode == roundMode) {
        x = (self.frame.size.width/2)*(1+cosf(M_PI/4)) - 25;
        y = (self.frame.size.width/2)*(1+cosf(M_PI/4)) - 25;
    }
    CGFloat width = 50;
    CGFloat height = 50;
    
    _dragBarView = [[NvDragBarView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    
    _dragBarView.delegate = self;
    _dragBarView.scale = 1;
    
    [self addSubview:_dragBarView];
}

///刷新缩放按钮
///Refresh zoom button
- (void) updateDragBar {
    CGFloat x = self.frame.size.width - 25;
    CGFloat y = self.frame.size.height - 25;
    if (_mode == roundMode) {
        x = (self.frame.size.width/2)*(1+cosf(M_PI/4)) - 25;
        y = (self.frame.size.width/2)*(1+cosf(M_PI/4)) - 25;
    }
    CGFloat width = 50;
    CGFloat height = 50;
    
    [_dragBarView setFrame:CGRectMake(x, y, width, height)];
}

- (void) layoutSubviews{
    _border.frame = self.bounds;
    if (_mode == freeMode) {
        _border.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    } else if (_mode == squreMode) {
        _border.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    } else if (_mode == roundMode) {
        _border.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.bounds.size.width/2].CGPath;
    }
}

- (void) setDragMode: (DragMode)dragMode {
    _mode = dragMode;
    self.frame = _originRect;
    [self addDragBar];
    _dragBarView.mode = dragMode;
    [self layoutSubviews];
}

@end
