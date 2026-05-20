//
//  NvCapturePopupView.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/1.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvCapturePopupView.h"
#import "NVHeader.h"
#import "NvConstant.h"

@interface NvCapturePopupView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UISlider *slider;

@property (nonatomic, assign) CapturePopup type;

@property (nonatomic, strong) UILabel *labelValue;

@end

@implementation NvCapturePopupView

- (instancetype)initWithFrame:(CGRect)frame withType:(CapturePopup)type{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor nv_colorWithHexARGB:@"#99000000"];
        [self addSubviews];
        self.type = type;
    }
    return self;
}

- (void)addSubviews{
    self.titleLabel = [UILabel new];
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.alpha = 0.8;
    self.titleLabel.font = [NvUtils fontWithSize:12];
    
    self.slider = [[UISlider alloc]init];
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.slider.maximumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    self.slider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    [self.slider setThumbImage:[NvUtils imageWithName:@"NvsliderWhite"] forState:UIControlStateNormal];
    
    self.labelValue = [UILabel new];
    self.labelValue.font = [NvUtils fontWithSize:11];
    self.labelValue.alpha = 0.8;
    self.labelValue.textColor = UIColor.whiteColor;
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.slider];
    [self addSubview:self.labelValue];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(13 * SCREENSCALE);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(26 * SCREENSCALE);
        make.width.offset(321 * SCREENSCALE);
        make.height.offset(20 * SCREENSCALE);
    }];
    
    [self.labelValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.slider.mas_bottom).offset(17 * SCREENSCALE);
        make.centerX.equalTo(self.mas_centerX);
    }];
}

- (void)configMinimumValue:(float)Minimum MaximumValue:(float)Maximum{
    [self.slider setMinimumValue:Minimum];
    [self.slider setMaximumValue:Maximum];
    [self.slider setValue:self.defaultValue];
    switch (self.type) {
        case CapturePopupTypeZoom:
            self.titleLabel.text = NvLocalString(@"Picture zoom", @"画面变焦");
            self.labelValue.text = @"1";
            self.labelValue.hidden = YES;
            break;
        case CapturePopupTypeExposure:
            self.titleLabel.text = NvLocalString(@"Exposure compensation", @"曝光补偿");
            self.labelValue.text = [NSString stringWithFormat:@"%.1f",self.defaultValue];
            break;
        default:
            break;
    }
}

-(void)sliderValueChanged:(UISlider *)paramSender{
    self.labelValue.text = [NSString stringWithFormat:@"%.1f",paramSender.value];
    self.ValueBlock(paramSender.value);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
