//
//  NvCountDownAnimationView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/16.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvCountDownAnimationView.h"
#import <NvSDKCommon/NvUtils.h>

@interface NvCountDownAnimationView ()

@property (nonatomic, strong) UILabel *numLable;

@end

@implementation NvCountDownAnimationView

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.numLable = [[UILabel alloc] initWithFrame:self.bounds];
        self.numLable.textColor = UIColor.whiteColor;
        self.numLable.text = @"3";
        self.numLable.textAlignment = NSTextAlignmentCenter;
        self.numLable.font = [NvUtils fontWithSize:144];
//        self.numLable.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.numLable];
    }
    return self;
}

- (void)startAnimation {
    self.numLable.text = @"3";
    self.numLable.frame = self.bounds;
    self.numLable.layer.anchorPoint = CGPointMake(0.5, 0.5);
    [UIView animateWithDuration:1.0 animations:^{
        self.numLable.transform = CGAffineTransformScale(self.numLable.transform, 0.1, 0.1);
    } completion:^(BOOL finished) {
        self.numLable.transform = CGAffineTransformIdentity;
        self.numLable.text = @"2";
        [UIView animateWithDuration:1.0 animations:^{
            self.numLable.transform = CGAffineTransformScale(self.numLable.transform, 0.1, 0.1);
        } completion:^(BOOL finished) {
            self.numLable.text = @"1";
            self.numLable.transform = CGAffineTransformIdentity;
            [UIView animateWithDuration:1.0 animations:^{
                self.numLable.transform = CGAffineTransformScale(self.numLable.transform, 0.1, 0.1);
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(countDownAnimationStopAnimationView:)]) {
                    [self.delegate countDownAnimationStopAnimationView:self];
                }
            }];
        }];

    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
