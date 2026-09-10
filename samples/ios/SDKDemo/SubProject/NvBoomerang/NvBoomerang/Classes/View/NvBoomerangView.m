//
//  NvBoomerangView.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/12/19.
//  Copyright © 2018 meishe. All rights reserved.
//

#import "NvBoomerangView.h"
#import <NvBaseCommon/NvBaseUtils.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import <Masonry/Masonry.h>
#import "NvBoomrangeGraphicBtn.h"
#import <NvBaseCommon/NvCircleProgressView.h>

@implementation NvBoomerangView {
    UIButton *backBtn;
    NvBoomrangeGraphicBtn *deviceBtn;
    NvBoomrangeGraphicBtn *flashBtn;
    UIView *animateView;
    NvCircleProgressView *circleProgressView;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self initView:frame];
    return self;
}

- (void)initView:(CGRect)frame {
    self.liveWindow = [[NvsLiveWindow alloc] initWithFrame:frame];
    [self addSubview:self.liveWindow];
    
    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:backBtn];
    [backBtn setImage:NvImageNamedForBundle(@"Nvback",NvCurrentBundle) forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(NV_STATUSBARHEIGHT);
        make.left.equalTo(self).offset(13 * SCREENSCALE);
        make.width.offset(33 * SCREENSCALE);
        make.height.offset(33 * SCREENSCALE);
    }];
    
    deviceBtn = [NvBoomrangeGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalStringFromTable([self class],@"flip", @"切换") withImageNormal:@"Nvdevice" withImageSelected:nil];
    [self addSubview:deviceBtn];
    deviceBtn.exclusiveTouch = YES;
    [deviceBtn addTarget:self action:@selector(deviceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [deviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(NV_STATUSBARHEIGHT);
        make.right.equalTo(self).offset(- 13 * SCREENSCALE);
        make.width.offset(45 * SCREENSCALE);
    }];
    
    flashBtn = [NvBoomrangeGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalStringFromTable([self class],@"flash", @"补光灯") withImageNormal:@"Nvflash_off" withImageSelected:@"Nvflash_on"];
    [self addSubview:flashBtn];
    [flashBtn addTarget:self action:@selector(flashBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->deviceBtn.mas_bottom).offset(24 * SCREENSCALE);
        make.leading.equalTo(self->deviceBtn.mas_leading);
        make.width.equalTo(self->deviceBtn.mas_width);
    }];
    
    animateView = [[UIView alloc] initWithFrame:frame];
    animateView.backgroundColor = [UIColor colorWithWhite:1.f alpha:.5f];
    [self addSubview:animateView];
    [animateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right);
        make.left.equalTo(self.mas_left);
    }];
    animateView.hidden = YES;
    
    circleProgressView = [[NvCircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 70*SCREENSCALE, 70*SCREENSCALE) type:kViewBoomrange];
    [self addSubview:circleProgressView];
    [circleProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self.mas_bottom).offset(-52*SCREENSCALE);
        make.width.equalTo(@(70*SCREENSCALE));
        make.height.equalTo(@(70*SCREENSCALE));
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shootingBtnClick:)];
    tap.requiresExclusiveTouchType = YES;
    [circleProgressView addGestureRecognizer:tap];
}

- (void)addAnimation {
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 1.;
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @0;
    alphaAnimation.toValue   = @1;
    alphaAnimation.repeatCount = HUGE_VAL;
    alphaAnimation.duration = .02;;
    [group setAnimations:@[alphaAnimation]];
    [animateView.layer addAnimation:group forKey:@"opacity"];
}

- (void)removeAnimation {
    [animateView.layer removeAllAnimations];
}

- (void)setProgress:(int)progress {
    circleProgressView.progress = progress;
//    [circleProgressView setNeedsDisplay];
}

- (void)enableFlash:(BOOL)enable {
    [flashBtn setEnabled:enable];
    if (!enable) {
        flashBtn.alpha = 0.7;
        flashBtn.userInteractionEnabled = NO;
        flashBtn.selected = NO;
    } else {
        flashBtn.alpha = 1;
        flashBtn.userInteractionEnabled = YES;
    }
}

- (void)toggleFlash:(BOOL)flash {
        flashBtn.selected = flash;
}

- (void)enableRecordBtn:(BOOL)enable {
    circleProgressView.userInteractionEnabled = enable;
    if (!enable) {
        [self addAnimation];
        animateView.hidden = NO;
    } else {
        [self removeAnimation];
        animateView.hidden = YES;
    }
}

- (void)backBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(backBtnClick)]) {
        [self.delegate backBtnClick];
    }
}

- (void)deviceBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(deviceBtnClick)]) {
        [self.delegate deviceBtnClick];
    }
}

- (void)flashBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(flashBtnClick)]) {

        [self.delegate flashBtnClick];
    }
}

- (void)shootingBtnClick:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(shootingBtnClick)]) {
        [self.delegate shootingBtnClick];
    }
}
@end
