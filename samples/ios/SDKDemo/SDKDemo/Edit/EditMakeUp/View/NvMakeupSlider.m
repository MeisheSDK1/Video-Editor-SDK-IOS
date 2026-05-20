//
//  NvMakeupSlider.m
//  SDKDemo
//
//  Created by ms on 2021/12/2.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvMakeupSlider.h"
#import "NVHeader.h"

@interface NvThinSlider : UISlider

@end
@implementation NvThinSlider

- (CGRect)trackRectForBounds:(CGRect)bounds {
    return CGRectMake(0, (self.frame.size.height - 1.5*SCREENSCALE) * 0.5, self.frame.size.width, 1.5*SCREENSCALE);
}

@end

@interface NvMakeupSlider ()
@property (nonatomic, strong) UIImageView *indicatorView;
@property (nonatomic, strong) UILabel *indicatorLabel;
@end

@implementation NvMakeupSlider

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}


- (instancetype)init {
    if (self = [super init]) {
        self.maxValue = 1.0;
        self.minValue = 0.f;
        _hiddenIndicatorView = NO;
    }
    return self;
}

#pragma mark - 添加子视图
/*
 添加子视图
 Add subview
 */
- (void)addSubviews {
    self.slider = [[NvThinSlider alloc] init];
    [self addSubview:self.slider];
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    self.slider.frame = CGRectMake(0, height - 20, width, 20);
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpOutside];
    [self.slider setThumbImage:[UIImage imageNamed:self.thumbImage ? self.thumbImage : @"Nv_beauty_thumb"] forState:UIControlStateNormal];
    [self.slider setMaximumValue:self.maxValue];
    [self.slider setMinimumValue:self.minValue];
    [self.slider setMaximumTrackTintColor:[UIColor nv_colorWithHexRGB:@"#D8D8D8"]];
    [self.slider setMinimumTrackTintColor:[UIColor nv_colorWithHexRGB:@"#D8D8D8"]];
    
    self.indicatorView = [[UIImageView alloc] init];
    self.indicatorView.image = [UIImage imageNamed:@"Nv_beauty_indicator"];
    [self addSubview:self.indicatorView];
    
    self.indicatorLabel = [[UILabel alloc] init];
    [self.indicatorView addSubview:self.indicatorLabel];
    self.indicatorLabel.font = [UIFont systemFontOfSize:11.f*SCREENSCALE];
    self.indicatorLabel.textAlignment = NSTextAlignmentCenter;
    self.indicatorLabel.textColor = self.indicatorTextColor ? self.indicatorTextColor : [UIColor whiteColor];
    if (self.value!=0) {
        self.slider.value = self.value;
        [self refreshView];
    }
}


- (void)setMaxValue:(CGFloat)maxValue {
    _maxValue = maxValue;
    if (self.slider) {
        self.slider.maximumValue = maxValue;
    }
}

- (void)setMinValue:(CGFloat)minValue {
    _minValue = minValue;
    if (self.slider) {
        self.slider.minimumValue = minValue;
    }
}

- (void)setValue:(CGFloat)value {
    _value = value;
    self.slider.value = value;
    [self refreshView];
}

- (void)setHiddenIndicatorView:(BOOL)hiddenIndicatorView {
    _hiddenIndicatorView = hiddenIndicatorView;
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

#pragma mark - 滑动回调
/*
 滑动回调
 Sliding callback
 
 @param paramSender 当前滑杆 Current slider
 
 */
-(void)sliderValueChanged:(UISlider *)paramSender{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayAction) object:nil];
    self.indicatorLabel.hidden = NO;
    [self refreshView];
    if ([self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [self.delegate sliderValueChanged:paramSender];
    }
}

#pragma mark - 滑动结束回调
/*
 滑动结束回调
 Sliding end callback
 
 @param paramSender 当前滑杆 Current slider
 
 */
-(void)sliderValueEnd:(UISlider *)paramSender{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayAction) object:nil];
    [self performSelector:@selector(delayAction) withObject:nil afterDelay:3.0];
    if ([self.delegate respondsToSelector:@selector(sliderValueEnd:)]) {
        [self.delegate sliderValueEnd:paramSender];
    }
}

- (void)refreshView {
    UISlider *paramSender = self.slider;
    CGFloat x = (paramSender.value - paramSender.minimumValue)/(paramSender.maximumValue - paramSender.minimumValue)*(paramSender.frame.size.width - paramSender.currentThumbImage.size.width) - 15*SCREENSCALE+paramSender.currentThumbImage.size.width/2;
    CGFloat height = self.bounds.size.height;
    self.indicatorView.frame = CGRectMake(x, height - 51.23*SCREENSCALE, 30*SCREENSCALE, 26.23*SCREENSCALE);
    self.indicatorLabel.frame = CGRectMake(0, 15, 30*SCREENSCALE, 26.23*SCREENSCALE);
    self.indicatorLabel.text = self.pointForamt ? [NSString stringWithFormat:self.pointForamt,paramSender.value] :[NSString stringWithFormat:@"%.f",paramSender.value];
    if (self.hiddenIndicatorView) {
        self.indicatorView.image = nil;
    }
}

#pragma mark - 延迟执行隐藏
/*
 延迟执行隐藏
 Delayed execution hiding
 
 */
- (void)delayAction {
    self.indicatorLabel.hidden = YES;
}

@end

