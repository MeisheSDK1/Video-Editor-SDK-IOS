//
//  NvTranDurationView.m
//  SDKDemo
//
//  Created by ms20180425 on 2020/4/8.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvTranDurationView.h"
#import "NVHeader.h"

@interface NvTranDurationSlider : UISlider

@end

@interface NvTranDurationView()

@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) NvTranDurationSlider *slider;
@end

@implementation NvTranDurationView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0x242728);
        [self addMainView];
    }
    return self;
}

- (void)addMainView{
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = @"转场时长";
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:13];
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY).offset(-25 * SCREENSCALE);
        make.left.equalTo(self).offset(15 * SCREENSCALE);
    }];
    
    UILabel *minLabel = [[UILabel alloc]init];
    minLabel.text = @"0.3s";
    minLabel.textColor = UIColor.whiteColor;
    minLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:11];
    minLabel.alpha = 0.5;
    [self addSubview:minLabel];
    [minLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLabel);
        make.left.equalTo(titleLabel.mas_right).offset(12 * SCREENSCALE);
    }];
    
    UILabel *maxLabel = [[UILabel alloc]init];
    maxLabel.text = @"2s";
    maxLabel.textColor = UIColor.whiteColor;
    maxLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:11];
    maxLabel.alpha = 0.5;
    [self addSubview:maxLabel];
    [maxLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLabel);
        make.right.equalTo(self).offset(-15 * SCREENSCALE);
    }];
    
    self.slider = [[NvTranDurationSlider alloc]init];
    self.slider.minimumValue = 0.3;
    self.slider.maximumValue = 2.0;
    self.slider.minimumTrackTintColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    self.slider.maximumTrackTintColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    [self.slider setThumbImage:[UIImage imageNamed:@"Nv_beauty_thumb"] forState:UIControlStateNormal];
    [self.slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(valueEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self action:@selector(valueEnd:) forControlEvents:UIControlEventTouchUpOutside];
    [self addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLabel);
        make.left.equalTo(minLabel.mas_right).offset(10 * SCREENSCALE);
        make.right.equalTo(maxLabel.mas_left).offset(-10* SCREENSCALE);
    }];
    
    self.valueLabel = [[UILabel alloc]init];
    self.valueLabel.text = @"0.5s";
    self.valueLabel.textColor = UIColor.whiteColor;
    self.valueLabel.font = [UIFont systemFontOfSize:11];
    self.valueLabel.alpha = 0.5;
    [self addSubview:self.valueLabel];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.slider);
        make.bottom.equalTo(self.slider.mas_top).offset(-5 * SCREENSCALE);
    }];
    
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = UIColor.whiteColor;
    lineView.alpha = 0.1;
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(0.5);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).offset(-INDICATOR - 50 * SCREENSCALE);
    }];

    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setImage:NvImageNamed(@"NvSegmentationCancel") forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(30 * SCREENSCALE);
        make.top.equalTo(lineView.mas_bottom).offset(10 *SCREENSCALE);
        make.left.equalTo(lineView).offset(10 *SCREENSCALE);
    }];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:saveBtn];
    [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(30 * SCREENSCALE);
        make.centerY.equalTo(cancelBtn);
        make.right.equalTo(lineView).offset(-10 *SCREENSCALE);
    }];
}

- (void)updateValue:(CGFloat)value{
    self.slider.value = value;
    self.valueLabel.text = [NSString stringWithFormat:@"%.1fs",value];
}

- (void)valueChanged:(UISlider *)slider{
    self.valueLabel.text = [NSString stringWithFormat:@"%.1fs",slider.value];
}

- (void)valueEnd:(UISlider *)slider{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateValue:withState:)]) {
        [self.delegate updateValue:[self.valueLabel.text floatValue] withState:UIControlEventTouchUpOutside];
    }
}

- (void)saveBtnClick{
    self.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(saveValue:withSave:)]) {
        [self.delegate saveValue:[self.valueLabel.text floatValue] withSave:YES];
    }
}

- (void)cancelBtnClick{
    self.hidden = YES;
}

@end

@implementation NvTranDurationSlider

- (CGRect)trackRectForBounds:(CGRect)bounds {
    return CGRectMake(0, (self.frame.size.height - 1.5*SCREENSCALE) * 0.5, self.frame.size.width, 1.5*SCREENSCALE);
}

@end
