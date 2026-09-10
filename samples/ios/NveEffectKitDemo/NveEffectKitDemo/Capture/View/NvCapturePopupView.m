//
//  NvCapturePopupView.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/1.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvCapturePopupView.h"
#import "UIColor+NvLiveColor.h"
#import "Masonry.h"
#import "NvLiveAppEnv.h"

@interface NvCapturePopupView ()

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) UISlider *slider;

@property(nonatomic, assign) CapturePopup type;

@property(nonatomic, strong) UILabel *labelValue;

@end

@implementation NvCapturePopupView

- (instancetype)initWithFrame:(CGRect)frame withType:(CapturePopup)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        [self addSubviews];
        self.type = type;
    }
    return self;
}

- (void)addSubviews {
    self.titleLabel = [UILabel new];
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.alpha = 0.8;
    self.titleLabel.font = [UIFont systemFontOfSize:12];

    self.slider = [[UISlider alloc] init];
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.slider.maximumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    self.slider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    [self.slider setThumbImage:[UIImage imageNamed:@"NvsliderWhite"] forState:UIControlStateNormal];

    self.labelValue = [UILabel new];
    self.labelValue.font = [UIFont systemFontOfSize:11];
    self.labelValue.alpha = 0.8;
    self.labelValue.textColor = UIColor.whiteColor;

    [self addSubview:self.titleLabel];
    [self addSubview:self.slider];
    [self addSubview:self.labelValue];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(13 * NvScreen(kScale));
        make.centerX.equalTo(self.mas_centerX);
    }];

    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(26 * NvScreen(kScale));
        make.width.offset(321 * NvScreen(kScale));
        make.height.offset(20 * NvScreen(kScale));
    }];

    [self.labelValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.slider.mas_bottom).offset(17 * NvScreen(kScale));
        make.centerX.equalTo(self.mas_centerX);
    }];
}

- (void)configMinimumValue:(float)Minimum MaximumValue:(float)Maximum {
    [self.slider setMinimumValue:Minimum];
    [self.slider setMaximumValue:Maximum];
    [self.slider setValue:self.defaultValue];
    switch (self.type) {
        case CapturePopupTypeZoom:
            self.titleLabel.text = NSLocalizedString(@"zoom_1", @"画面变焦");
            self.labelValue.text = @"1";
            self.labelValue.hidden = YES;
            break;
        case CapturePopupTypeExposure:
            self.titleLabel.text = NSLocalizedString(@"exposure_1", @"曝光补偿");
            self.labelValue.text = [NSString stringWithFormat:@"%.1f", self.defaultValue];
            break;
        default:
            break;
    }
}

- (void)sliderValueChanged:(UISlider *)paramSender {
    double value = paramSender.value;
    if (value < 0 && value > -0.1) {
        value = 0;
    }
    self.labelValue.text = [NSString stringWithFormat:@"%.1f", value];
    if (self.valueBlock) {
        self.valueBlock(paramSender.value);
    }
}

@end
