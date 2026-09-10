//
//  NvsRecordingButton.m
//  progress
//
//  Created by Meicam on 2018/3/18.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvsRecordingButton.h"
#import <NvSDKCommon/NvUtils.h>

#define AnimationTime 1.0

@interface NvsRecordingButton ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation NvsRecordingButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.bounds;
        gradientLayer.colors = @[(id)[UIColor colorWithRed:2.0/255.0 green:235.0/255.0 blue:147.0/255.0 alpha:1].CGColor,(id)[UIColor colorWithRed:24.0/255.0 green:222.0/255.0 blue:254.0/255.0 alpha:1].CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);     
        [self.layer addSublayer:gradientLayer];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.label.userInteractionEnabled = YES;
        self.label.textColor = [UIColor whiteColor];
        self.label.text = NvLocalString(@"holdShoot", @"按住拍");
        self.label.font = [UIFont systemFontOfSize:14*SCREENSCALE];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];
        UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGes:)];
        [self addGestureRecognizer:longGes];
        self.layer.cornerRadius = self.frame.size.width/2;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.3].CGColor;
        
    }
    return self;
}

///长按手势方法
///the method of long press gesture recognizer
- (void)longGes:(UILongPressGestureRecognizer *)ges {
    if (ges.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(touchBegin)]) {
            [self.delegate touchBegin];
        }
        self.label.hidden = YES;
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.duration = AnimationTime;
        group.repeatCount = HUGE_VAL;
        
        CABasicAnimation *transform = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        transform.fromValue = @1;
        transform.toValue   = @1.5;
        transform.duration = AnimationTime/2;
        transform.fillMode = kCAFillModeForwards;
        
        CABasicAnimation *widthAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
        widthAnimation.fromValue = @10;
        widthAnimation.toValue   = @0;
        widthAnimation.duration = AnimationTime/2;
        widthAnimation.fillMode = kCAFillModeForwards;
        
        CABasicAnimation *opaqueAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opaqueAnimation.fromValue = @1;
        opaqueAnimation.toValue   = @0.1;
        opaqueAnimation.duration = AnimationTime/2;
        opaqueAnimation.fillMode = kCAFillModeForwards;
        
        CABasicAnimation *widthAnimation1 = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
        widthAnimation1.fromValue = @0;
        widthAnimation1.toValue   = @10;
        widthAnimation1.duration = AnimationTime/2;
        widthAnimation1.beginTime = AnimationTime/2;
        widthAnimation1.fillMode = kCAFillModeForwards;
        
        CABasicAnimation *opaqueAnimation1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opaqueAnimation1.fromValue = @0.1;
        opaqueAnimation1.toValue   = @1;
        opaqueAnimation1.duration = AnimationTime/2;
        opaqueAnimation1.beginTime = AnimationTime/2;
        opaqueAnimation1.fillMode = kCAFillModeForwards;
        
        CABasicAnimation *transform1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        transform1.fromValue = @1.5;
        transform1.toValue   = @1;
        transform1.duration = AnimationTime/2;
        transform1.beginTime = AnimationTime/2;
        transform1.fillMode = kCAFillModeForwards;
        
        group.animations = [NSArray arrayWithObjects:transform,widthAnimation,opaqueAnimation,widthAnimation1,opaqueAnimation1,transform1, nil];
        [self.layer addAnimation:group forKey:@"borderWidths"];
    } else if (ges.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(touchEnd)]) {
            [self.delegate touchEnd];
        }
        self.label.hidden = NO;
        [self.layer removeAllAnimations];
        self.transform = CGAffineTransformIdentity;
    }
    
}

///结束动画
///stop the animation
- (void)stopAnimation {
    self.label.hidden = NO;
    [self.layer removeAllAnimations];
    self.transform = CGAffineTransformIdentity;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
