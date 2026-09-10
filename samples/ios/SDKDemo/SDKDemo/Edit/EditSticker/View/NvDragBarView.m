//
//  NvDragBarView.m
//  SDKDemo
//
//  Created by dx on 2018/6/21.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvDragBarView.h"

@implementation NvDragBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        int width = self.bounds.size.width;
        int height = self.bounds.size.height;
        if(width < 20) {
            width = 20;
        }
        if(height < 20) {
            height = 20;
        }
        CGRect rect = CGRectMake(width / 2 - 10, height / 2 - 10, 20, 20);
        imageView = [[UIImageView alloc]initWithFrame:rect];
        UIImage * image = [UIImage imageNamed:@"Oval 5"];
        [imageView setImage:image];
        [self addSubview:imageView];
        
    }
    
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ///保存触摸起始点位置
    ///Save the start of the touch position
    CGPoint point = [[touches anyObject] locationInView:self];
    startPoint = point;
    
    [[self superview] bringSubviewToFront:self];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    ///计算位移=当前位置-起始位置
    ///Calculated displacement = current position - starting position
    CGPoint point = [[touches anyObject] locationInView:self];
    float dx = point.x - startPoint.x;
    float dy = point.y - startPoint.y;
    
    if (_mode != freeMode) {
        if(dx > dy) {
            ///等比例位移
            ///Equal scale displacement
            dy = dx / _scale;
        } else {
            dx = dy * _scale;
        }
    }
    
    CGPoint oldcenter = self.center;
    ///计算移动后的view中心点
    ///Calculate the center point of the moved view
    CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
    
    CGPoint movePoint = CGPointMake(newcenter.x - oldcenter.x, newcenter.y - oldcenter.y);
    [_delegate movePoint:movePoint];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
