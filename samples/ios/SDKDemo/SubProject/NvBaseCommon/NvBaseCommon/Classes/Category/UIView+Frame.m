//
//  UIView+Frame.m
//  JXShop
//
//  Created by clj on 2017/8/19.
//  Copyright © 2017年 JX. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (void)setViewTop:(CGFloat)viewTop
{
    CGRect frame = self.frame;
    frame.origin.y = viewTop;
    self.frame = frame;;
}

- (CGFloat)viewTop
{
    return self.frame.origin.y;
}

- (void)setViewBottom:(CGFloat)viewBottom
{
    CGRect frame = self.frame;
    frame.origin.y = viewBottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)viewBottom
{
    return self.frame.origin.y + self.frame.size.height;
}


- (void)setViewHeight:(CGFloat)viewHeight
{
    CGRect frame = self.frame;
    frame.size.height = viewHeight;
    self.frame = frame;
}

- (CGFloat)viewHeight
{
    return self.frame.size.height;
}


- (void)setViewWidth:(CGFloat)viewWidth
{
    CGRect frame = self.frame;
    frame.size.width = viewWidth;
    self.frame = frame;
}

- (CGFloat)viewWidth
{
    return self.frame.size.width;
}

- (void)setViewRight:(CGFloat)viewRight
{
    CGRect frame = self.frame;
    frame.origin.x = viewRight - frame.size.width;
    self.frame = frame;
}

- (CGFloat)viewRight
{
    return self.frame.origin.x + self.frame.size.width;
}


- (void)setViewLeft:(CGFloat)viewLeft
{
    CGRect frame = self.frame;
    frame.origin.x = viewLeft;
    self.frame = frame;
}

- (CGFloat)viewLeft
{
    return self.frame.origin.x;
}

- (void)setViewSize:(CGSize)viewSize
{
    if (viewSize.width == NAN) {
        viewSize.width = 0;
    }
    if (viewSize.height == NAN) {
        viewSize.height = 0;
    }
    CGRect frame = self.frame;
    frame.size = viewSize;
    self.frame = frame;
}

- (CGSize)viewSize
{
  return  self.frame.size;
}

- (void)setViewX:(CGFloat)viewX
{
    if (viewX == NAN) {
        viewX = 0;
    }
    CGRect frame = self.frame;
    frame.origin.x = viewX;
    self.frame = frame;
}

- (CGFloat)viewX
{
    return self.frame.origin.x;
}

- (void)setViewY:(CGFloat)viewY
{
    CGRect frame = self.frame;
    frame.origin.y = viewY;
    self.frame = frame;
}

- (CGFloat)viewY
{
    return self.frame.origin.y;
}


- (void)setViewCenterX:(CGFloat)viewCenterX
{
    self.center = CGPointMake(viewCenterX, self.center.y);
}

- (CGFloat)viewCenterX
{
    return self.center.x;
}

- (void)setViewCenterY:(CGFloat)viewCenterY
{
    self.center = CGPointMake(self.center.x, viewCenterY);
}

- (CGFloat)viewCenterY
{
    return self.center.y;
}

@end
