//
//  NvHotPixelAdjustView.m
//  SDKDemo
//
//  Created by ms on 2020/11/30.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvHotPixelAdjustView.h"
#import "UIColor+NvColor.h"
#import "NVHeader.h"
@interface NvHotPixelAdjustView()
@property (nonatomic, strong) UIButton *singleColorBtn;
@property (nonatomic, strong) UIButton *multicolourBtn;
@property (nonatomic, strong) UIView *singleColorLine;
@property (nonatomic, strong) UIView *multicolourLine;
@property (nonatomic, strong) UISlider *singleColorSlider;
@property (nonatomic, strong) UISlider *multicolourSlider;
@property (nonatomic, strong) UILabel *degreeLabel;
@property (nonatomic, strong) UILabel *densityLabel;
@end
@implementation NvHotPixelAdjustView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        [self configAutoLayout];
    }
    return self;
}

-(void)addSubviews{
    self.singleColorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.singleColorBtn setTitle:NvLocalString(@"SingleColor", @"单色") forState:UIControlStateNormal];
    [self.singleColorBtn addTarget:self action:@selector(singleColorBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.singleColorBtn.titleLabel.font = [NvUtils fontWithSize:10*SCREENSCALE];
    [self.singleColorBtn setTitleColor:[UIColor nv_colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    self.singleColorBtn.alpha = 1;
    [self addSubview:self.singleColorBtn];
    
    self.multicolourBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.multicolourBtn setTitle:NvLocalString(@"MultiColour", @"彩色") forState:UIControlStateNormal];
    [self.multicolourBtn addTarget:self action:@selector(multicolourBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.multicolourBtn.titleLabel.font = [NvUtils fontWithSize:10*SCREENSCALE];
    [self.multicolourBtn setTitleColor:[UIColor nv_colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    self.multicolourBtn.alpha = 0.6;
    [self addSubview:self.multicolourBtn];
    
    self.singleColorLine = [UIView new];
    self.singleColorLine.hidden = NO;
    self.singleColorLine.backgroundColor = [UIColor nv_colorWithHexString:@"ffffff" alpha:1];
    [self addSubview:self.singleColorLine];
    
    self.multicolourLine = [UIView new];
    self.multicolourLine.hidden = YES;
    self.multicolourLine.backgroundColor = [UIColor nv_colorWithHexString:@"ffffff" alpha:1];
    [self addSubview:self.multicolourLine];
    
    self.singleColorSlider = [UISlider new];
    self.singleColorSlider.minimumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    self.singleColorSlider.maximumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    [self.singleColorSlider setThumbImage:NvImageNamed(@"NvSliderIcon") forState:UIControlStateNormal];
    self.singleColorSlider.maximumValue = 1.0;
    self.singleColorSlider.minimumValue = 0.0;
    self.singleColorSlider.value = 0.0;
    [self.singleColorSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.singleColorSlider];
    
    self.multicolourSlider = [UISlider new];
    self.multicolourSlider.minimumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    self.multicolourSlider.maximumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    [self.multicolourSlider setThumbImage:NvImageNamed(@"NvSliderIcon") forState:UIControlStateNormal];
    self.multicolourSlider.maximumValue = 1.0;
    self.multicolourSlider.minimumValue = 0.0;
    self.multicolourSlider.value = 0.0;
    [self.multicolourSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.multicolourSlider];
    
    self.degreeLabel = [[UILabel alloc] init];
    self.degreeLabel.text = NvLocalString(@"EditStrength", @"程度");
    self.degreeLabel.textColor = UIColor.whiteColor;
    self.degreeLabel.font = [NvUtils fontWithSize:10*SCREENSCALE];
    self.degreeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.degreeLabel];
    
    self.densityLabel = [[UILabel alloc] init];
    self.densityLabel.text = NvLocalString(@"Density", @"密度");
    self.densityLabel.textColor = UIColor.whiteColor;
    self.densityLabel.font = [NvUtils fontWithSize:10*SCREENSCALE];
    self.densityLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.densityLabel];
}


- (void)sliderValueChanged:(UISlider *)slider{
    if (slider == self.singleColorSlider) {
        if (self.degreeeSlideValueChangeBlock) {
            self.degreeeSlideValueChangeBlock(slider.value);
        }
    }else if (slider == self.multicolourSlider){
        if (self.densitySlideValueChangeBlock) {
            self.densitySlideValueChangeBlock(slider.value);
        }
    }
    
}

-(void)singleColorBtnClick{
    self.singleColorBtn.alpha = 1;
    self.multicolourBtn.alpha = 0.6;
    self.singleColorLine.hidden = NO;
    self.multicolourLine.hidden = YES;
    if (self.colorSelectBlock) {
        self.colorSelectBlock(0);
    }
}

-(void)multicolourBtnClick{
    self.singleColorBtn.alpha = 0.6;
    self.multicolourBtn.alpha = 1;
    self.singleColorLine.hidden = YES;
    self.multicolourLine.hidden = NO;
    if (self.colorSelectBlock) {
        self.colorSelectBlock(1);
    }
}
-(void)configAutoLayout{
    [self.singleColorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(10.0);
        make.right.mas_equalTo(self.singleColorSlider.mas_centerX).offset(-15);
        make.left.mas_greaterThanOrEqualTo(0);
        make.height.mas_equalTo(10);
    }];
    [self.multicolourBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.singleColorBtn.mas_centerY);
        make.left.mas_equalTo(self.singleColorSlider.mas_centerX).offset(15);
        make.right.mas_lessThanOrEqualTo(0);
        make.height.mas_equalTo(10);
    }];
    [self.singleColorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.singleColorBtn.mas_centerX);
        make.top.mas_equalTo(self.singleColorBtn.mas_bottom).offset(8.0);
        make.width.mas_equalTo(10.0f);
        make.height.mas_equalTo(1.0f);
    }];
    [self.multicolourLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.multicolourBtn.mas_centerX);
        make.top.mas_equalTo(self.multicolourBtn.mas_bottom).offset(8.0);
        make.width.mas_equalTo(10.0f);
        make.height.mas_equalTo(1.0f);
    }];
    [self.degreeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-10);
        make.top.mas_equalTo(self.multicolourLine.mas_bottom).offset(15);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(14);
    }];
    
    [self.densityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.degreeLabel.mas_right);
        make.top.mas_equalTo(self.degreeLabel.mas_bottom).offset(20);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(14);
    }];

    [self.singleColorSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(5);
        make.centerY.mas_equalTo(self.degreeLabel.mas_centerY);
        make.height.mas_equalTo(10.0);
        make.right.mas_equalTo(self.degreeLabel.mas_left).offset(-10);
    }];
    [self.multicolourSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.singleColorSlider.mas_left);
        make.centerY.mas_equalTo(self.densityLabel.mas_centerY);
        make.height.mas_equalTo(self.singleColorSlider.mas_height);
        make.right.mas_equalTo(self.singleColorSlider.mas_right);
    }];
}

-(void)reset{
    self.singleColorSlider.value = 0.0;
    self.multicolourSlider.value = 0.0;
    self.singleColorBtn.alpha = 1;
    self.singleColorLine.hidden = NO;
    self.multicolourBtn.alpha = 0.6;
    self.multicolourLine.hidden = YES;
}

-(void)setWithColorType:(BOOL)isSingle Intensity:(float)intensityValue Density:(float)densityValue{
    if (isSingle) {
        self.singleColorBtn.alpha = 1;
        self.multicolourBtn.alpha = 0.6;
        self.singleColorLine.hidden = NO;
        self.multicolourLine.hidden = YES;
    }else{
        self.singleColorBtn.alpha = 0.6;
        self.multicolourBtn.alpha = 1;
        self.singleColorLine.hidden = YES;
        self.multicolourLine.hidden = NO;
    }
    self.singleColorSlider.value = intensityValue;
    self.multicolourSlider.value = densityValue;
}
@end
