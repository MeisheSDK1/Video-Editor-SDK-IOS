//
//  NvBeautySlider.m
//  NvBeautySliderDemo
//
//  Created by 董凌晓 on 2019/10/30.
//  Copyright © 2019 董凌晓. All rights reserved.
//

#import "NvBeautySliderView.h"
#import "NvARSceneMacro.h"
#import "NvARSceneUtils.h"
#import "Masonry.h"
#import "UIColor+NvColor.h"

@interface NvBeautySliderView ()
@property (nonatomic, strong) UIImageView *indicatorView;
@property (nonatomic, strong) UILabel *indicatorLabel;
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation NvBeautySliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.maxValue = 1.0;
        self.minValue = 0.f;
    }
    return self;
}

- (void)addSubviews {
    self.slider = [[UISlider alloc] init];
    [self addSubview:self.slider];
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    self.slider.frame = CGRectMake(0, height - 20, width, 20);
    self.slider.minimumTrackTintColor = [UIColor whiteColor];
    self.slider.maximumTrackTintColor = [UIColor whiteColor];
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpOutside];
    [self.slider setThumbImage:[NvARSceneUtils imageWithName:@"Nv_beauty_thumb"] forState:UIControlStateNormal];
    [self.slider setMaximumValue:self.maxValue];
    [self.slider setMinimumValue:self.minValue];
    self.indicatorView = [[UIImageView alloc] init];
    self.indicatorView.image = [NvARSceneUtils imageWithName:@"Nv_beauty_indicator"];
    [self addSubview:self.indicatorView];
    
    self.indicatorLabel = [[UILabel alloc] init];
    [self.indicatorView addSubview:self.indicatorLabel];
    self.indicatorLabel.font = [UIFont systemFontOfSize:10.f*SCREENSCALE];
    self.indicatorLabel.textAlignment = NSTextAlignmentCenter;
    self.indicatorLabel.textColor = [UIColor grayColor];
}

- (void)setMaxValue:(CGFloat)maxValue {
    _maxValue = maxValue;
    [self.slider setMaximumValue:maxValue];
}

- (void)setMinValue:(CGFloat)minValue {
    _minValue = minValue;
    [self.slider setMinimumValue:minValue];
}

- (void)setValue:(CGFloat)value {
    _value = value;
    self.slider.value = value;
    [self refreshView];
}

- (CGFloat)getValue {
    return _value;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (![self.subviews containsObject:self.slider]) {
        [self addSubviews];
    }
}

-(void)sliderValueChanged:(UISlider *)paramSender{
    [self refreshView];
    if ([self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [self.delegate sliderValueChanged:paramSender];
    }
}

- (void)setupTextLabel:(NSString *)text{
    if (!self.textLabel) {
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.font = [UIFont systemFontOfSize:12];
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.textLabel];
    }
    
    self.textLabel.text = text;
    [self.textLabel sizeToFit];
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    self.textLabel.frame = CGRectMake(0, height - 20, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    
    self.slider.frame = CGRectMake(CGRectGetMaxX(self.textLabel.frame)+5*SCREENSCALE, height - 20, width - CGRectGetMaxX(self.textLabel.frame)-5*SCREENSCALE, 20);
    
    [self refreshView];
}

- (void)refreshView {
    UISlider *paramSender = self.slider;
    CGFloat temp = paramSender.maximumValue - paramSender.minimumValue;
    CGFloat temp1 = temp/(paramSender.frame.size.width-paramSender.currentThumbImage.size.width);
    CGFloat x = (paramSender.value - paramSender.minimumValue)/temp1;
    
    CGFloat height = self.bounds.size.height;
    if (self.textLabel) {
        x += CGRectGetMaxX(self.textLabel.frame)+5*SCREENSCALE;
    }
    self.indicatorView.frame = CGRectMake(0, height - 51.23*SCREENSCALE, 23*SCREENSCALE, 30*SCREENSCALE);
    self.indicatorView.center = CGPointMake(x+paramSender.currentThumbImage.size.width/2.0, self.indicatorView.center.y);
    self.indicatorLabel.frame = CGRectMake(0, 0, 23*SCREENSCALE, 30*SCREENSCALE);
    self.indicatorLabel.text = [NSString stringWithFormat:@"%.f",paramSender.value*100];
}

-(void)sliderValueEnd:(UISlider *)paramSender{
    if ([self.delegate respondsToSelector:@selector(sliderValueEnd:)]) {
        [self.delegate sliderValueEnd:paramSender];
    }
}
@end
