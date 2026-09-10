//
//  NvWatemarkBoxView.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/9/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvWatemarkBoxView.h"
#import "NVHeader.h"

@interface NvWatemarkBoxView ()

@property (nonatomic, assign) CGPoint startPoint;

@end

@implementation NvWatemarkBoxView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        int width = self.bounds.size.width;
        int height = self.bounds.size.height;
        if(width < 20) {
            width = 20;
        }
        if(height < 20) {
            height = 20;
        }
        CGRect rect = CGRectMake(width / 2 - 10, height / 2 - 10, 20, 20);
        UIImageView* imageView = [[UIImageView alloc]initWithFrame:rect];
        UIImage * image = NvImageNamed(@"NvRotate");
        [imageView setImage:image];
        [self addSubview:imageView];
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*
     保存触摸起始点位置
     Save the position of the touch start point
     */
    CGPoint point = [[touches anyObject] locationInView:self];
    self.startPoint = point;
    
    /*
     该view置于最前
     Put the view at the forefront
     */
    [[self superview] bringSubviewToFront:self];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*
     计算位移=当前位置-起始位置
     Calculated displacement = current position-starting position
     */
    CGPoint point = [[touches anyObject] locationInView:self];
    float dx = point.x - self.startPoint.x;
    float dy = point.y - self.startPoint.y;
    
    /*
     等比例位移
     Proportional displacement
     */
    if(dx > dy) {
        dy = dx / _scale;
    } else {
        dx = dy * _scale;
    }
    
    CGPoint oldcenter = self.center;
    /*
     计算移动后的view中心点
     Calculate the center point of the view after moving
     */
    CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
    
    CGPoint movePoint = CGPointMake(newcenter.x - oldcenter.x, newcenter.y - oldcenter.y);
    [self.delegate movePoint:movePoint withEnd:NO];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    /*
     计算位移=当前位置-起始位置
     Calculated displacement = current position-starting position
     */
    CGPoint point = [[touches anyObject] locationInView:self];
    float dx = point.x - self.startPoint.x;
    float dy = point.y - self.startPoint.y;
    
    /*
     等比例位移
     Proportional displacement
     */
    if(dx > dy) {
        dy = dx / _scale;
    } else {
        dx = dy * _scale;
    }
    
    CGPoint oldcenter = self.center;
    
    /*
     计算移动后的view中心点
     Calculate the center point of the view after moving
     */
    CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
    
    CGPoint movePoint = CGPointMake(newcenter.x - oldcenter.x, newcenter.y - oldcenter.y);
    [self.delegate movePoint:movePoint withEnd:YES];
    
}

@end
