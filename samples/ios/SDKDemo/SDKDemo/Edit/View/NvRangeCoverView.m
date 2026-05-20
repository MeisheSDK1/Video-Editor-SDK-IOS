//
//  NvRangeCoverView.m
//  SDKDemo
//
//  Created by Mac-Mini on 2025/5/7.
//  Copyright © 2025 meishe. All rights reserved.
//

#import "NvRangeCoverView.h"

@implementation NvRangeCoverView {
    float SliderWidth;
    float minSpace;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        SliderWidth = 15;
        minSpace = 0;
        self.timeAxis = [[UIView alloc] initWithFrame:CGRectMake(15, 0, 2, frame.size.height)];
        [self.timeAxis setBackgroundColor:[UIColor cyanColor]];
        self.timeAxis.alpha = 0.5;
        [self addSubview:self.timeAxis];
        ///添加左滑块
        ///Add the left slider
        self.leftSliderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SliderWidth, frame.size.height)];
        self.leftSliderView.image = [UIImage imageNamed:@"NvTailoringLeft"];
        self.leftSliderView.userInteractionEnabled = YES;
        [self addSubview:self.leftSliderView];
        [self.leftSliderView addPanGestureRecognizerWithTarget:self action:@selector(leftPan:)];
        ///添加右滑块
        ///Add the right slider
        self.rightSliderView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-SliderWidth, 0, SliderWidth, frame.size.height)];
        self.rightSliderView.image = [UIImage imageNamed:@"NvTailoringRight"];
        self.rightSliderView.userInteractionEnabled = YES;
        [self addSubview:self.rightSliderView];
        [self.rightSliderView addPanGestureRecognizerWithTarget:self action:@selector(rightPan:)];

        self.topLine = [[UIView alloc] initWithFrame:CGRectMake(self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width, 0, self.rightSliderView.frame.origin.x-(self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width), 2)];
        self.topLine.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.topLine];
        [self insertSubview:self.topLine belowSubview:self.leftSliderView];

        self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width, self.frame.size.height-2, self.rightSliderView.frame.origin.x-(self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width), 2)];
        self.bottomLine.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bottomLine];
        [self insertSubview:self.bottomLine belowSubview:self.leftSliderView];
        [self bringSubviewToFront:self.timeAxis];
        
    }
    return self;
}

- (void)leftPan:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            if ([self.delegate respondsToSelector:@selector(getMinspace)]) {
                minSpace = [self.delegate getMinspace];
            }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint point = [pan translationInView:self];
            CGFloat x = self.leftSliderView.frame.origin.x + point.x;
            if (x < 0) {
                x = 0;
            }
            if (x + minSpace > self.rightSliderView.frame.origin.x - SliderWidth) {
                x = -minSpace + self.rightSliderView.frame.origin.x - SliderWidth;
            }
            self.leftSliderView.frame = CGRectMake(x, 0, SliderWidth, self.frame.size.height);
            self.topLine.frame = CGRectMake(self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width, 0, self.rightSliderView.frame.origin.x-(self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width), 2);
            self.bottomLine.frame = CGRectMake(self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width, self.frame.size.height-2, self.rightSliderView.frame.origin.x-(self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width), 2);
            [pan setTranslation:CGPointZero inView:self];
            if ([self.delegate respondsToSelector:@selector(onRangeCoverView:didLeftOffset:isTouchUp:)]) {
                [self.delegate onRangeCoverView:self didLeftOffset:self.leftSliderView.right isTouchUp:NO];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            if ([self.delegate respondsToSelector:@selector(onRangeCoverView:didLeftOffset:isTouchUp:)]) {
                [self.delegate onRangeCoverView:self didLeftOffset:self.leftSliderView.right isTouchUp:YES];
            }
            break;
        default:
            break;
    }
}

- (void)rightPan:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            if ([self.delegate respondsToSelector:@selector(getMinspace)]) {
                minSpace = [self.delegate getMinspace];
            }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint point = [pan translationInView:self];
            CGFloat x = self.rightSliderView.frame.origin.x + point.x;
            if (x - minSpace < self.leftSliderView.frame.origin.x + SliderWidth) {
                x = minSpace + self.leftSliderView.frame.origin.x + SliderWidth;
            }
            if (x > self.frame.size.width - SliderWidth) {
                x = self.frame.size.width - SliderWidth;
            }
            self.rightSliderView.frame = CGRectMake(x, 0, SliderWidth, self.frame.size.height);
            self.topLine.frame = CGRectMake(self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width, 0, self.rightSliderView.frame.origin.x-(self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width), 2);
            self.bottomLine.frame = CGRectMake(self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width, self.frame.size.height-2, self.rightSliderView.frame.origin.x-(self.leftSliderView.frame.origin.x+self.leftSliderView.frame.size.width), 2);
            [pan setTranslation:CGPointZero inView:self];
            if ([self.delegate respondsToSelector:@selector(onRangeCoverView:didRightOffset:isTouchUp:)]) {
                [self.delegate onRangeCoverView:self didRightOffset:self.rightSliderView.left isTouchUp:NO];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            if ([self.delegate respondsToSelector:@selector(onRangeCoverView:didRightOffset:isTouchUp:)]) {
                [self.delegate onRangeCoverView:self didRightOffset:self.rightSliderView.left isTouchUp:YES];
            }
            break;
        default:
            break;
    }
}

@end
