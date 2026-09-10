//
//  NvFontRatioView.m
//  SDKDemo
//
//  Created by Meishe on 2022/9/14.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvFontRatioView.h"

@interface NvFontRatioView ()<BLItemSliderDelegate>
@property (nonatomic, strong) UILabel *fontRatioLabel;
@property (nonatomic, strong) UILabel *fontRatioNumLabel;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIView *line;
@end

@implementation NvFontRatioView

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.layer.masksToBounds = YES;
        self.fontRatioLabel = [UILabel nv_labelWithText:NvLocalString(@"FontRatio", @"字号") fontSize:12 textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"]];
        self.fontRatioLabel.alpha = 0.8;
        self.fontRatioLabel.numberOfLines = 2;
        self.fontRatioLabel.textAlignment = NSTextAlignmentCenter;
        self.fontRatioLabel.font = [NvUtils regularFontWithSize:12];
        [self addSubview:self.fontRatioLabel];
        [self.fontRatioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(10*SCREENSCALE));
            make.top.equalTo(self.mas_top).offset(66*SCREENSCALEHEIGHT);
            make.width.mas_equalTo(60*SCREENSCALEHEIGHT);
        }];
        
        self.fontRatioNumLabel = [UILabel nv_labelWithText:@"100" fontSize:12 textColor:[UIColor whiteColor]];
        self.fontRatioNumLabel.alpha = 0.8;
        self.fontRatioNumLabel.textAlignment = NSTextAlignmentCenter;
        self.fontRatioNumLabel.font = [NvUtils regularFontWithSize:12];
        [self addSubview:self.fontRatioNumLabel];
        [self.fontRatioNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-10*SCREENSCALE));
            make.centerY.equalTo(self.fontRatioLabel);
            make.width.equalTo(@(60*SCREENSCALE));
        }];
        
        CGRect sliderFrame = CGRectMake(80*SCREENSCALE, 70*SCREENSCALEHEIGHT, SCREENWIDTH - 160*SCREENSCALE, self.bounds.size.height);
        self.slider = [[BLItemSlider alloc] initWithFrame:sliderFrame];
        [self addSubview:self.slider];
        self.slider.delegate = self;
        self.slider.maximumTrackTintColor = [UIColor whiteColor];
        self.slider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#FF3B3B3B"];
        self.slider.thumbTintColor = [UIColor whiteColor];
        self.slider.thumbSeletedTintColor = [UIColor whiteColor];
        self.slider.valueLabel.hidden = YES;
        self.slider.minValue = 0.25;
        self.slider.maxValue = 7.75;
        self.slider.value = 1;
        self.slider.showTwoSidesLimitedValue = YES;
        __weak typeof(self)weakSelf = self;
        
        self.applyButton = [NvButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"NvNoApplyAll")];
        [self.applyButton setImage:NvImageNamed(@"NvApplyAll") forState:UIControlStateSelected];
        self.styleApplyLabel = [UILabel nv_labelWithText:NvLocalString(@"Apply all FontRatio", @"将字号应用到所有字幕") fontSize:10 textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"]];
        self.styleApplyLabel.font = [NvUtils regularFontWithSize:10];
        self.styleApplyLabel.alpha = 0.8;
        
        [self.applyButton nv_BtnClickHandler:^{
            weakSelf.applyButton.selected = !weakSelf.applyButton.selected;
            if (weakSelf.applyButton.selected) {
                weakSelf.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
            } else {
                weakSelf.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
            }
            if ([weakSelf.delegate respondsToSelector:@selector(applyFontRatioToAllCaption:)]) {
                [weakSelf.delegate applyFontRatioToAllCaption:weakSelf.applyButton.selected];
            }
        }];
        
        [self addSubview:self.applyButton];
        [self addSubview:self.styleApplyLabel];
        
        [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(13*SCREENSCALE));
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-36*SCREENSCALE);
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(self.mas_bottom).offset(-36*SCREENSCALE);
            }
            make.width.height.equalTo(@(15*SCREENSCALE));
        }];
        [self.styleApplyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.applyButton.mas_centerY);
            make.left.equalTo(self.applyButton.mas_right).offset(7*SCREENSCALE);
        }];
        self.fontRatioNumLabel.text = self.slider.valueLabel.text;
    }
    return self;
}

///刷新列表用于外界设置默认数据
///The refresh list is used to set default data for the outside world
- (void)setDefaultFontRatio:(float)value {
    self.slider.value = value;
    self.fontRatioNumLabel.text = self.slider.valueLabel.text;
    self.applyButton.selected = NO;
    self.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
    if ([self.delegate respondsToSelector:@selector(fontRatioChanged:)]) {
        [self.delegate fontRatioChanged:value];
    }
}

- (void)enableFontRatio:(BOOL)enable {
    self.slider.enable = enable;
    self.applyButton.enabled = enable;
    if(enable) {
        self.slider.maximumTrackTintColor = [UIColor whiteColor];
        self.slider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#FF3B3B3B"];
        self.styleApplyLabel.textColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
        self.fontRatioLabel.textColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
        self.fontRatioNumLabel.textColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    }else {
        self.slider.maximumTrackTintColor = [UIColor grayColor];
        self.slider.minimumTrackTintColor = [UIColor grayColor];
        self.styleApplyLabel.textColor = [UIColor grayColor];
        self.fontRatioLabel.textColor = [UIColor grayColor];
        self.fontRatioNumLabel.textColor = [UIColor grayColor];
    }
}

- (void)itemSliderDisabled:(BLItemSlider *)slider {
    if ([self.delegate respondsToSelector:@selector(disableFontRatio:)]) {
        [self.delegate disableFontRatio:YES];
    }
}

-(void)itemSlider:(BLItemSlider*)slider valueChanged:(float)value {
    self.fontRatioNumLabel.text = slider.valueLabel.text;
    if ([self.delegate respondsToSelector:@selector(fontRatioChanged:)]) {
        [self.delegate fontRatioChanged:value];
    }
}

@end
