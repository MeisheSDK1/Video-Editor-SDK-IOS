//
//  NvLiveSwitchView.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/25.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvLiveSwitchView.h"
#import "NvLiveARSceneUtils.h"
#import "Masonry.h"
#import "UIColor+NvLiveColor.h"
#import "NvLiveAppEnv.h"

@interface NvLiveSwitchView ()

@property(nonatomic, assign) BOOL stateType;

@end

@implementation NvLiveSwitchView

- (instancetype)initWithFrame:(CGRect)frame withType:(NSInteger)type withState:(BOOL)state {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#D8D8D8"];
        self.layer.masksToBounds = YES;
        if (type == 1) {
            self.layer.cornerRadius = frame.size.width / 5;
        } else {
            self.layer.cornerRadius = frame.size.height / 2;
        }

        self.stateType = state;
        [self addSubviews:frame withType:type];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#D8D8D8"];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 4;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#54595F"].CGColor;
        [self addSubviews:frame withType:0];
    }
    return self;
}

- (void)addSubviews:(CGRect)rect withType:(NSInteger)type {
    if (type == 1) {
        UILabel *onLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, (62 * NvScreen(kScale) - 10 * NvScreen(kScale)) / 2, 27 * NvScreen(kScale) - 4)];
        onLabel.text = @"ON";
        onLabel.textColor = UIColor.whiteColor;
        onLabel.font = [UIFont systemFontOfSize:11 * NvScreen(kScale)];
        [self addSubview:onLabel];

        UILabel *offLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 * NvScreen(kScale) + (62 * NvScreen(kScale) - 10) / 2, 2, (54 * NvScreen(kScale) - 10 * NvScreen(kScale)) / 2, 27 * NvScreen(kScale) - 4)];
        offLabel.text = @"OFF";
        offLabel.textColor = UIColor.whiteColor;
        offLabel.font = [UIFont systemFontOfSize:11 * NvScreen(kScale)];
        [self addSubview:offLabel];

        if (self.stateType) {
            self.sliderView = [[UIView alloc] initWithFrame:CGRectMake(2 + (62 * NvScreen(kScale) - 4) / 2, 2, (62 * NvScreen(kScale) - 4) / 2, 27 * NvScreen(kScale) - 4)];
            self.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#3D8AE9"];
        } else {
            self.sliderView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, (62 * NvScreen(kScale) - 4 * NvScreen(kScale)) / 2, 27 * NvScreen(kScale) - 4)];
            self.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#A3A3A3"];
        }

        self.sliderView.tag = 2000;
        self.sliderView.layer.masksToBounds = YES;
        self.sliderView.layer.cornerRadius = (62 * NvScreen(kScale) - 4 * NvScreen(kScale)) / 5;
        self.sliderView.userInteractionEnabled = NO;
        [self addSubview:_sliderView];
    } else if (type == 2) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4E5253"];
        self.sliderView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, rect.size.height - 4, rect.size.height - 4)];
        self.sliderView.tag = 2000;
        self.sliderView.layer.masksToBounds = YES;
        self.sliderView.layer.cornerRadius = (rect.size.height - 4) / 2;
        self.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#DBDCDC"];
        self.sliderView.userInteractionEnabled = NO;
        [self addSubview:_sliderView];
    } else {
        self.sliderView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, (54 * NvScreen(kScale) - 4) / 2, 21 * NvScreen(kScale) - 4)];
        self.sliderView.tag = 2000;
        self.sliderView.layer.masksToBounds = YES;
        self.sliderView.layer.cornerRadius = 5;
        self.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#54595F"];
        self.sliderView.userInteractionEnabled = NO;
        [self addSubview:_sliderView];
    }
}

- (void)switchSelected:(BOOL)selected {
    if (selected) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        self.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#D9E8FB"];
    } else {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4E5253"];
        self.sliderView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#DBDCDC"];
    }
}

@end
