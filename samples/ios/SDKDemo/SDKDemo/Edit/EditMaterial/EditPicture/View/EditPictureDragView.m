//
//  NvDragView.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/8/8.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "EditPictureDragView.h"
#import "EditPictureDragBarView.h"
#import <QuartzCore/CALayer.h>


@interface EditPictureDragView()<EditPictureDragBarViewDelegate>

@end

@implementation EditPictureDragView{
    UILabel *_textLabel;
    EditPictureDragBarView *_dragBarView;
    CAShapeLayer *_border;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 30)];
        [_textLabel setTextColor:[UIColor colorWithRed:208/255.0 green:2/255.0 blue:27/255.0 alpha:1]];
        _textLabel.font = [UIFont systemFontOfSize:12];
        [_textLabel setTextAlignment:NSTextAlignmentCenter];
        
        [self addSubview:_textLabel];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        _border = [CAShapeLayer layer];
        _border.strokeColor = [UIColor colorWithRed:208/255.0 green:2/255.0 blue:27/255.0 alpha:1].CGColor;
        
        _border.fillColor = nil;
        
        _border.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        
        _border.frame = self.bounds;
        
        _border.lineWidth = 3;
        
        _border.lineCap = @"square";
        
        [self.layer addSublayer:_border];
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
    
    ///计算移动后的view中心点
    ///Calculate the center point of the moved view
    CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
    
    /*
     限制用户不可将视图托出屏幕
     Restrict users from pushing views off the screen
     */
    float halfx = CGRectGetMidX(self.bounds);
    ///x坐标左边界
    ///The left boundary of the x-coordinate
    newcenter.x = MAX(halfx, newcenter.x);
    ///x坐标右边界
    ///The right edge of the x-coordinate
    newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);
    
    float halfy = CGRectGetMidY(self.bounds);
    newcenter.y = MAX(halfy, newcenter.y);
    newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);
    
    ///移动view
    ///Move view
    self.center = newcenter;
    [self.delegate updateRect:self.frame withMode:_mode];
}

- (void) setText:(NSString *)text {
    _textLabel.text = text;
}

- (void) movePoint:(CGPoint)point {
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;
    CGFloat width = self.frame.size.width + point.x;
    CGFloat height = self.frame.size.height + point.y;
    CGSize maxSize = self.superview.bounds.size;
    CGFloat scale = self.bounds.size.width / self.bounds.size.height;
    CGSize minSize ;
    if (scale > 1) {
       minSize = CGSizeMake(self.imageSize.width/2, (self.imageSize.width/2)/scale);
    }else{
       minSize = CGSizeMake((self.imageSize.height/2) * scale, self.imageSize.height/2);
    }
    if (x+width > maxSize.width) {
        width = maxSize.width - x;
        height = width / scale;
    }
    if (y+height > maxSize.height) {
        height = maxSize.height - y;
        width = height * scale;
    }
    
    if (width > minSize.width && height > minSize.height) {
        CGRect rect = CGRectMake(x, y, width, height);
        [self setFrame:rect];
        [self.delegate updateRect:rect withMode:_mode];
    }
    
    [self updateDragBar];
}

- (void) addDragBar {
    if(_dragBarView != nil)
        return;
    CGFloat x = self.frame.size.width - 48;
    CGFloat y = self.frame.size.height - 48;
    CGFloat width = 48;
    CGFloat height = 48;
    
    _dragBarView = [[EditPictureDragBarView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    
    _dragBarView.delegate = self;
    _dragBarView.scale = _scale;
    
    [self addSubview:_dragBarView];
}

- (void) updateDragBar {
    CGFloat x = self.frame.size.width - 48;
    CGFloat y = self.frame.size.height - 48;
    CGFloat width = 48;
    CGFloat height = 48;
    
    [_dragBarView setFrame:CGRectMake(x, y, width, height)];
}

- (void) layoutSubviews{
    _border.frame = self.bounds;
    _border.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    _textLabel.frame = CGRectMake(0, self.bounds.size.height - 30, 80, 30);
}

@end
