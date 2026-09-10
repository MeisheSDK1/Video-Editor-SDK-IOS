//
//  NvCountDownView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/15.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvCountDownView.h"
#import <NvSDKCommon/NvUtils.h>
#import <Masonry/Masonry.h>


@implementation NvProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(13*SCREENSCALE, 0, frame.size.width - 26*SCREENSCALE, frame.size.height)];
        self.backView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#4DFFFFFF"];
        self.backView.layer.cornerRadius = 2.5;
        [self addSubview:self.backView];
        self.coverView = [[UIView alloc] initWithFrame:CGRectMake(13*SCREENSCALE, 0, 0, frame.size.height)];
        self.coverView.backgroundColor = [UIColor colorWithRed:147.0/255 green:241.0/255 blue:241.0/255 alpha:1];
        [self addSubview:self.coverView];
    }
    return self;
}

-(void)setProgress:(float)progress {
    _progress = progress;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backView.frame = CGRectMake(13*SCREENSCALE, 0, self.frame.size.width - 26*SCREENSCALE, self.frame.size.height);
    self.coverView.frame = CGRectMake(13*SCREENSCALE, 0, (self.frame.size.width - 26*SCREENSCALE)*self.progress, self.frame.size.height);
}

@end

@implementation NvCountDownView {
    float value;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        value = 1;
        self.backgroundColor = [UIColor nv_colorWithHexARGB:@"#99000000"];
        self.titleLable = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLable.text = NvLocalString(@"countDownstop", @"拖动选择拍摄暂停位置");
        self.titleLable.textAlignment = NSTextAlignmentCenter;
        self.titleLable.textColor = [UIColor whiteColor];
        self.titleLable.font = [NvUtils fontWithSize:11];
        [self addSubview:self.titleLable];
        [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(13*SCREENSCALE));
            make.centerX.equalTo(self);
            make.height.equalTo(@(15*SCREENSCALE));
        }];
        self.fromLable = [[UILabel alloc] initWithFrame:CGRectZero];
        self.fromLable.text = @"0s";
        self.fromLable.textAlignment = NSTextAlignmentLeft;
        self.fromLable.textColor = [UIColor whiteColor];
        self.fromLable.font = [NvUtils fontWithSize:11];
        [self addSubview:self.fromLable];
        [self.fromLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(13*SCREENSCALE));
            make.top.equalTo(self.titleLable.mas_bottom).offset(13*SCREENSCALE);
            make.height.equalTo(@(15*SCREENSCALE));
        }];
        
        self.toLable = [[UILabel alloc] initWithFrame:CGRectZero];
        self.toLable.text = @"15s";
        self.toLable.textAlignment = NSTextAlignmentRight;
        self.toLable.textColor = [UIColor whiteColor];
        self.toLable.font = [NvUtils fontWithSize:11];
        [self addSubview:self.toLable];
        [self.toLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-13*SCREENSCALE));
            make.top.equalTo(self.titleLable.mas_bottom).offset(13*SCREENSCALE);
            make.height.equalTo(@(15*SCREENSCALE));
        }];
        
        self.countDown = [[NvProgressView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.countDown];
        [self.countDown mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.height.equalTo(@(48*SCREENSCALE));
            make.top.equalTo(self.toLable.mas_bottom).offset(8*SCREENSCALE);
        }];
        
        self.handleView = [[UIView alloc] initWithFrame:CGRectZero];
        self.handleView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.handleView];
        [self.handleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.countDown.mas_right).offset(-13*SCREENSCALE);
            make.centerY.equalTo(self.countDown);
            make.width.equalTo(@(10*SCREENSCALE));
            make.height.equalTo(@(50*SCREENSCALE));
        }];
        
        self.currentlabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.currentlabel.text = @"15s";
        self.currentlabel.textColor = UIColor.whiteColor;
        self.currentlabel.textAlignment = NSTextAlignmentCenter;
        self.currentlabel.font = [NvUtils fontWithSize:11];
        [self.handleView addSubview:self.currentlabel];
        [self.currentlabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.countDown.mas_top).offset(-8*SCREENSCALE);
            make.centerX.equalTo(self.handleView);
        }];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [self addGestureRecognizer:panGesture];
        
        self.countDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.countDownButton setTitle:NvLocalString(@"countDownTimer", @"开始倒计时拍摄") forState:UIControlStateNormal];
        self.countDownButton.backgroundColor = [UIColor nv_colorWithHexARGB:@"#FFFC3E3E"];
        self.countDownButton.layer.cornerRadius = 2.5;
        [self addSubview:self.countDownButton];
        [self.countDownButton addTarget:self action:@selector(countDownClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.countDownButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(13*SCREENSCALE));
            make.right.equalTo(@(-13*SCREENSCALE));
            make.top.equalTo(self.countDown.mas_bottom).offset(11*SCREENSCALE);
            make.height.equalTo(@(35*SCREENSCALE));
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-34*SCREENSCALE);
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(self).offset(-34*SCREENSCALE);
            }
        }];
        
    }
    return self;
}

- (void)countDownClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(countDownView:didClickCountDownValue:)]) {
        [self.delegate countDownView:self didClickCountDownValue:value];
    }
}

- (void)panGesture:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan locationInView:self];
    float y = self.handleView.center.y;
    if (point.x < (self.countDown.backView.frame.origin.x + self.progress * self.countDown.backView.frame.size.width)) {
        if (self.progress == 0) {
            value = 0.5 / 15;
            self.fromLable.hidden = YES;
        } else {
            value = self.progress;
        }
        
        self.handleView.center = CGPointMake(value * self.countDown.backView.frame.size.width + self.countDown.backView.frame.origin.x , y);
        self.currentlabel.text = [NSString stringWithFormat:@"%.1fs",value*15];
        if (value*15 > 13.5) {
            self.toLable.hidden = YES;
        } else {
            self.toLable.hidden = NO;
        }
        return;
    }
    if (point.x > (self.countDown.backView.frame.origin.x + self.countDown.backView.frame.size.width)) {
        return;
    }
    value = (point.x - self.countDown.backView.frame.origin.x) / self.countDown.backView.frame.size.width;
    if (value * 15 < 0.5) {
        self.fromLable.hidden = YES;
        return;
    }
    self.handleView.center = CGPointMake(point.x, y);
    self.currentlabel.text = [NSString stringWithFormat:@"%.1fs",value*15];
    if (value*15 <= 0.5) {
        self.fromLable.hidden = YES;
    } else {
        self.fromLable.hidden = NO;
    }
    if (value*15 > 13.5) {
        self.toLable.hidden = YES;
    } else {
        self.toLable.hidden = NO;
    }
}


/// 设置进度
/// set the progress of count down value
/// @param progress progress
-(void)setProgress:(float)progress {
    _progress = progress;
    self.countDown.progress = progress;
    [self setNeedsLayout];
}


/// 设置当前值
/// set the currentValue
/// @param currentValue currentValue
- (void)setCurrentValue:(float)currentValue {
    _currentValue = currentValue;
    value = _currentValue;
    float x = self.countDown.backView.frame.origin.x + _currentValue * self.countDown.backView.frame.size.width;
    self.handleView.center = CGPointMake(x, self.handleView.center.y);
    self.currentlabel.text = [NSString stringWithFormat:@"%.1fs",currentValue*15];
    if (value*15 <= 0.5) {
        self.fromLable.hidden = YES;
    } else {
        self.fromLable.hidden = NO;
    }
    if (value*15 > 13.5) {
        self.toLable.hidden = YES;
    } else {
        self.toLable.hidden = NO;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
