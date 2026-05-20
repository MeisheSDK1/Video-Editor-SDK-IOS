//
//  NvShortVideoBeautyView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/9.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvShortVideoBeautyView.h"
#import "NVHeader.h"

@interface NvShortVideoBeautyView()

@property (nonatomic, strong) UILabel *strengthLabel;
@property (nonatomic, strong) UILabel *eyeEnlargingLabel;
@property (nonatomic, strong) UILabel *cheekThinningLabel;

@property (nonatomic, strong) UILabel *strengthNum;
@property (nonatomic, strong) UILabel *eyeEnlargingNum;
@property (nonatomic, strong) UILabel *cheekThinningNum;

@property (nonatomic, strong) UISlider *strengthSlider;
@property (nonatomic, strong) UISlider *eyeEnlargingSlider;
@property (nonatomic, strong) UISlider *cheekThinningSlider;

@end

@implementation NvShortVideoBeautyView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexARGB:@"#99000000"];
        self.strengthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.strengthLabel.text = NvLocalString(@"Strength", @"磨皮");
        self.strengthLabel.textColor = [UIColor whiteColor];
        self.strengthLabel.textAlignment = NSTextAlignmentCenter;
        self.strengthLabel.font = [NvUtils fontWithSize:12];
        self.strengthLabel.numberOfLines = 2;
        self.cheekThinningLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.cheekThinningLabel.text = NvLocalString(@"CheekThinning", @"瘦脸");
        self.cheekThinningLabel.textColor = [UIColor whiteColor];
        self.cheekThinningLabel.textAlignment = NSTextAlignmentCenter;
        self.cheekThinningLabel.font = [NvUtils fontWithSize:12];
        self.cheekThinningLabel.numberOfLines = 2;
        self.eyeEnlargingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.eyeEnlargingLabel.textColor = [UIColor whiteColor];
        self.eyeEnlargingLabel.textAlignment = NSTextAlignmentCenter;
        self.eyeEnlargingLabel.text = NvLocalString(@"EyeEnlarging", @"大眼");
        self.eyeEnlargingLabel.font = [NvUtils fontWithSize:12];
        self.eyeEnlargingLabel.numberOfLines = 2;
        [self addSubview:self.strengthLabel];
        [self addSubview:self.cheekThinningLabel];
        [self addSubview:self.eyeEnlargingLabel];
        [self.strengthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(10*SCREENSCALE));
            make.top.equalTo(@(12*SCREENSCALE));
            make.width.equalTo(@(60*SCREENSCALE));
            make.height.equalTo(@(40*SCREENSCALE));
        }];
        [self.cheekThinningLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(12*SCREENSCALE));
            make.top.equalTo(self.strengthLabel.mas_bottom).offset(10*SCREENSCALE);
            make.width.equalTo(self.strengthLabel);
            make.height.equalTo(@(40*SCREENSCALE));
            
        }];
        [self.eyeEnlargingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(12*SCREENSCALE));
            make.top.equalTo(self.cheekThinningLabel.mas_bottom).offset(10*SCREENSCALE);
            make.width.equalTo(self.strengthLabel);
            make.height.equalTo(@(40*SCREENSCALE));
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-10*SCREENSCALE);
        }];
        
        self.strengthNum = [[UILabel alloc] initWithFrame:CGRectZero];
        self.strengthNum.textColor = [UIColor whiteColor];
        self.strengthNum.textAlignment = NSTextAlignmentCenter;
        self.strengthNum.text = @"50";
        self.strengthNum.font = [NvUtils fontWithSize:12];
        self.cheekThinningNum = [[UILabel alloc] initWithFrame:CGRectZero];
        self.cheekThinningNum.textColor = [UIColor whiteColor];
        self.cheekThinningNum.textAlignment = NSTextAlignmentCenter;
        self.cheekThinningNum.text = @"0";
        self.cheekThinningNum.font = [NvUtils fontWithSize:12];
        self.eyeEnlargingNum = [[UILabel alloc] initWithFrame:CGRectZero];
        self.eyeEnlargingNum.textColor = [UIColor whiteColor];
        self.eyeEnlargingNum.textAlignment = NSTextAlignmentCenter;
        self.eyeEnlargingNum.text = @"0";
        self.eyeEnlargingNum.font = [NvUtils fontWithSize:12];
        [self addSubview:self.strengthNum];
        [self addSubview:self.cheekThinningNum];
        [self addSubview:self.eyeEnlargingNum];
        [self.strengthNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-18*SCREENSCALE));
            make.centerY.equalTo(self.strengthLabel);
            make.width.equalTo(@(35*SCREENSCALE));
        }];
        [self.cheekThinningNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-18*SCREENSCALE));
            make.centerY.equalTo(self.cheekThinningLabel);
            make.width.equalTo(@(35*SCREENSCALE));
        }];
        [self.eyeEnlargingNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-18*SCREENSCALE));
            make.centerY.equalTo(self.eyeEnlargingLabel);
            make.width.equalTo(@(35*SCREENSCALE));
        }];
        
        self.strengthSlider = [UISlider new];
        [self.strengthSlider setMinimumValue:0.0];
        self.strengthSlider.value = 0.5;
        [self.strengthSlider setMaximumValue:1.0];
        self.strengthSlider.minimumTrackTintColor = [UIColor whiteColor];
        self.strengthSlider.maximumTrackTintColor = [UIColor whiteColor];
        [self.strengthSlider setThumbImage:NvImageNamed(@"Nvslider") forState:UIControlStateNormal];
        [self.strengthSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.cheekThinningSlider = [UISlider new];
        [self.cheekThinningSlider setMinimumValue:-1.0];
        [self.cheekThinningSlider setMaximumValue:1.0];
        self.cheekThinningSlider.minimumTrackTintColor = [UIColor whiteColor];
        self.cheekThinningSlider.maximumTrackTintColor = [UIColor whiteColor];
        [self.cheekThinningSlider setThumbImage:NvImageNamed(@"Nvslider") forState:UIControlStateNormal];
        [self.cheekThinningSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.eyeEnlargingSlider = [UISlider new];
        [self.eyeEnlargingSlider setMinimumValue:-1.0];
        [self.eyeEnlargingSlider setMaximumValue:1.0];
        self.eyeEnlargingSlider.minimumTrackTintColor = [UIColor whiteColor];
        self.eyeEnlargingSlider.maximumTrackTintColor = [UIColor whiteColor];
        [self.eyeEnlargingSlider setThumbImage:NvImageNamed(@"Nvslider") forState:UIControlStateNormal];
        [self.eyeEnlargingSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.strengthSlider];
        [self addSubview:self.cheekThinningSlider];
        [self addSubview:self.eyeEnlargingSlider];

        [self.strengthSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.strengthLabel.mas_right).offset(8*SCREENSCALE);
            make.right.equalTo(self.strengthNum.mas_left).offset(-13*SCREENSCALE);
            make.centerY.equalTo(self.strengthLabel);
        }];
        [self.cheekThinningSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.cheekThinningLabel.mas_right).offset(8*SCREENSCALE);
            make.right.equalTo(self.cheekThinningNum.mas_left).offset(-13*SCREENSCALE);
            make.centerY.equalTo(self.cheekThinningLabel);
        }];
        [self.eyeEnlargingSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.eyeEnlargingLabel.mas_right).offset(8*SCREENSCALE);
            make.right.equalTo(self.eyeEnlargingNum.mas_left).offset(-13*SCREENSCALE);
            make.centerY.equalTo(self.eyeEnlargingLabel);
        }];
        
    }
    return self;
}


/// 设置磨皮，大眼，瘦脸
/// set the values of strength,eyeEnlarging and cheekThinning
/// @param strength 磨皮
/// @param eyeEnlarging 大眼
/// @param cheekThinning 瘦脸
- (void)setStrength:(float)strength eyeEnlarging:(float)eyeEnlarging cheekThinning:(float)cheekThinning {
    self.strengthNum.text = [NSString stringWithFormat:@"%d",(int)(strength*100)];
    [self.strengthSlider setValue:strength animated:YES];
    
    self.cheekThinningNum.text = [NSString stringWithFormat:@"%d",(int)(cheekThinning*100)];;
    [self.cheekThinningSlider setValue:cheekThinning animated:YES];
    
    self.eyeEnlargingNum.text = [NSString stringWithFormat:@"%d",(int)(eyeEnlarging*100)];;
    [self.eyeEnlargingSlider setValue:eyeEnlarging animated:YES];
}

- (void)sliderValueChanged:(UISlider *)slider {
    if (slider == self.strengthSlider) {
        self.strengthNum.text = [NSString stringWithFormat:@"%d",(int)(slider.value*100)];
        if ([self.delegate respondsToSelector:@selector(slider:valueChanged:)]) {
            [self.delegate slider:0 valueChanged:slider.value];
        }
    } else if (slider == self.eyeEnlargingSlider) {
        self.eyeEnlargingNum.text = [NSString stringWithFormat:@"%d",(int)(slider.value*100)];
        if ([self.delegate respondsToSelector:@selector(slider:valueChanged:)]) {
            [self.delegate slider:1 valueChanged:slider.value];
        }
    } else if (slider == self.cheekThinningSlider) {
        self.cheekThinningNum.text = [NSString stringWithFormat:@"%d",(int)(slider.value*100)];
        if ([self.delegate respondsToSelector:@selector(slider:valueChanged:)]) {
            [self.delegate slider:2 valueChanged:slider.value];
        }
    }
}


/// 设置是否包含AR
/// set whether contain AR
/// @param containtAR containtAR
- (void)setContaintAR:(BOOL)containtAR {
    _containtAR = containtAR;
    self.eyeEnlargingSlider.enabled = containtAR;
    self.cheekThinningSlider.enabled = containtAR;
}

@end
