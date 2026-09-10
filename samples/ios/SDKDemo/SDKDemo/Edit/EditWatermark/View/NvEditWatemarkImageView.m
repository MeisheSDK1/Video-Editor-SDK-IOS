//
//  NvEditWatemarkImageView.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/9/3.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvEditWatemarkImageView.h"
#import "NvWatemarkBoxView.h"
#import "NVHeader.h"

@interface NvEditWatemarkImageView ()<NvWatemarkBoxViewDelegate>

@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, strong) NvWatemarkBoxView *box;
@property (nonatomic, strong) CAShapeLayer *border;
@property (nonatomic, assign) BOOL isEdit;

@end

@implementation NvEditWatemarkImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.isEdit = YES;
        _border = [CAShapeLayer layer];
        
        _border.strokeColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        
        _border.fillColor = nil;
        
        _border.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        
        _border.frame = self.bounds;
        
        _border.lineWidth = 2;
        
        _border.lineCap = @"square";
        
        [self.layer addSublayer:_border];
        
        [self addSubviews:frame];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _border.frame = self.bounds;
    _border.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

#pragma mark - 添加视图
/*
 添加视图
 Add view
 
 @param rect 位置 rect
 
 */
- (void)addSubviews:(CGRect)rect{
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteBtn.frame = CGRectMake(rect.size.width - 13, -10, 20, 20);
    [self.deleteBtn setImage:NvImageNamed(@"NvClose") forState:UIControlStateNormal];
    [self.deleteBtn addTarget:self action:@selector(deleteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteBtn];
    
    self.box = [[NvWatemarkBoxView alloc]initWithFrame:CGRectMake(rect.size.width - 13, rect.size.height-13, 20, 20)];
    self.box.delegate = self;
    self.box.scale = self.bounds.size.width / self.bounds.size.height;
    [self addSubview:self.box];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isEdit) {
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
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isEdit) {
        /*
         计算位移=当前位置-起始位置
         Calculated displacement = current position-starting position
         */
        CGPoint point = [[touches anyObject] locationInView:self];
        float dx = point.x - self.startPoint.x;
        float dy = point.y - self.startPoint.y;
        
        /*
         计算移动后的view中心点
         Calculate the center point of the view after moving
         */
        CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
        
        /*
         限制用户不可将视图托出屏幕
         Restrict users from being able to pull the view off the screen
         */
        float halfx = CGRectGetMidX(self.bounds);
        
        /*
         x坐标左边界
         x coordinate left boundary
         */
        newcenter.x = MAX(halfx, newcenter.x);

        /*
         x坐标右边界
         x-coordinate right boundary
         */
        newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);
        
        /*
         y坐标同理
         y coordinate is the same
         */
        float halfy = CGRectGetMidY(self.bounds);
        newcenter.y = MAX(halfy, newcenter.y);
        newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);
        
        /*
         移动view
         Mobile view
         */
        self.center = newcenter;
        [self.delegate nvEditWatemarkImageView:self updateRect:self.frame withState:NO];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
     [self.delegate nvEditWatemarkImageView:self updateRect:self.frame withState:YES];
}

#pragma mark - 删除按钮点击事件
/*
 删除按钮点击事件
 Delete button click event
 
 @param sender 当前按钮 Current button
 
 */
- (void)deleteBtn:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(nvEditWatemarkImageViewWithDeleteClick)]){
        [self.delegate nvEditWatemarkImageViewWithDeleteClick];
    }
}

#pragma mark - 拖拽回调
/*
 拖拽回调
 Drag and drop callback
 
 @param point 当前位置 current position
 @param isEnd 是否停止拖拽 Whether to stop dragging
 
 */
- (void) movePoint:(CGPoint)point withEnd:(BOOL)isEnd{
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;
    CGPoint center = self.center;
    CGFloat width = self.frame.size.width + point.x;
    CGFloat height = self.frame.size.height + point.y;
    CGSize maxSize = self.superview.bounds.size;
    CGFloat scale = self.bounds.size.width / self.bounds.size.height;
    if (x+width > maxSize.width) {
        width = maxSize.width - x;
        height = width / scale;
    }
    if (y+height > maxSize.height) {
        height = maxSize.height - y;
        width = height * scale;
    }
    
    if (center.x < width/2 || center.y < height/2) {
        
    }else{
        CGRect rect = CGRectMake(x, y, width, height);
        [self setFrame:rect];
        self.center = center;
        rect = self.frame;
        if ([self.delegate respondsToSelector:@selector(nvEditWatemarkImageView:updateRect:withState:)]){
            [self.delegate nvEditWatemarkImageView:self updateRect:rect withState:isEnd];
        }
        [self updateDragBar];
    }

}

- (void)hiddenView:(BOOL)state{
    if (state) {
        _border.lineWidth = 0;
        _deleteBtn.hidden = state;
        _box.hidden = state;
    }else{
        _border.lineWidth = 2;
        _deleteBtn.hidden = state;
        _box.hidden = state;
    }
    self.isEdit = !state;
}

- (void)updateDragBar{
    CGFloat x = self.frame.size.width - 13;
    CGFloat y = self.frame.size.height - 13;
    CGFloat width = 20;
    CGFloat height = 20;
    
    self.deleteBtn.frame = CGRectMake(x, -10, width, height);
    self.box.frame = CGRectMake(x, y, width, height);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint tp = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, tp)) {
                view = subView;
            }
        }
    }
    return view;
}

@end
