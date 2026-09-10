//
//  NvLiveCountDownAnimationView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/16.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvLiveCountDownAnimationView.h"
#import "UIColor+NvLiveColor.h"
#import "NvLiveAppEnv.h"

@interface NvLiveCountDownAnimationView ()

@property (nonatomic, strong) UILabel *numLable;

@end

@implementation NvLiveCountDownAnimationView

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexARGB:@"#80000000"];
        self.numLable = [[UILabel alloc] initWithFrame:self.bounds];
        self.numLable.textColor = UIColor.whiteColor;
        self.numLable.text = @"3";
        self.numLable.textAlignment = NSTextAlignmentCenter;
        self.numLable.font = [UIFont systemFontOfSize:144];
        [self addSubview:self.numLable];
        
        UILabel *prepareLable = [[UILabel alloc] initWithFrame:self.bounds];
        prepareLable.textColor = UIColor.whiteColor;
        prepareLable.text = NvLocalString(@"Are you ready?", @"准备好了吗？");
        prepareLable.textAlignment = NSTextAlignmentCenter;
        prepareLable.font = [UIFont systemFontOfSize:18];
        prepareLable.center = CGPointMake(self.center.x, self.center.y + 60);
        [self addSubview:prepareLable];
    }
    return self;
}

- (void)startAnimation {
    NSLog(@"开始动画！");
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
            NSLog(@"第二次结束动画！");
            self.numLable.text = @"1";
            self.numLable.transform = CGAffineTransformIdentity;
            [UIView animateWithDuration:1.0 animations:^{
                self.numLable.transform = CGAffineTransformScale(self.numLable.transform, 0.1, 0.1);
            } completion:^(BOOL finished) {
                NSLog(@"第三次结束动画！");
                [self removeFromSuperview];
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
