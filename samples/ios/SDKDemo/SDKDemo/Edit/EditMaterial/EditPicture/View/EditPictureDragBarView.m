//
//  EditPictureDragBarView.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/8/8.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "EditPictureDragBarView.h"

@implementation EditPictureDragBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        UIImage * image = [UIImage imageNamed:@"NvEditPictureBox"];
        [imageView setImage:image];
        [self addSubview:imageView];
        
        self.userInteractionEnabled = YES;
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

    if(dx > dy) {
        dy = dx / _scale;
    } else {
        dx = dy * _scale;
    }

    CGPoint oldcenter = self.center;
    ///计算移动后的view中心点
    ///Calculate the center point of the moved view
    CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);

    CGPoint movePoint = CGPointMake(newcenter.x - oldcenter.x, newcenter.y - oldcenter.y);
    [_delegate movePoint:movePoint];
    
}

@end
