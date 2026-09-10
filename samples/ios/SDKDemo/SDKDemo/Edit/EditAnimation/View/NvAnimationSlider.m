//
//  NvAnimationSlider.m
//  SDKDemo
//
//  Created by ms on 2020/8/27.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvAnimationSlider.h"
#import "NVHeader.h"
#import <AudioToolbox/AudioToolbox.h>

#define ValueFollow

@interface NvAnimationSlider ()
{
    UIView* _bgShapeView;
    CAShapeLayer* _valueShapeLayer;
    
    CAShapeLayer* _adsorbShapeLayer;
    
    CGFloat _sliderCenterY;
    CGFloat _sliderOriginX;
    
    CGFloat _cornerRadius;
    
    UIView* _thumbCenterView;
    
    BOOL _feedbackEnable;
}

@property(nonatomic,assign)CGPoint adsorbPoint;

@property(nonatomic,strong) UIView* thumbView;

@property (nonatomic, assign) CGFloat proportion;

@end

@implementation NvAnimationSlider

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews{
    self.backgroundColor = [UIColor clearColor];
    
    _feedbackEnable = YES;
    
    self.lineHeight = 2;
    _value = 0;
    _minValue = 0;
    _maxValue = 1;
    _adsorbWidth = 10;
    _adsorbPointWidth = 6;
    
    self.valueFormat = @"%.1fs";
    _minimumTrackTintColor = [UIColor whiteColor];
    _maximumTrackTintColor = [UIColor whiteColor];
    
    _sliderCenterY = self.bounds.size.height *2.f/3;
    _sliderOriginX = 15.f;
    _cornerRadius = 1.f;
    
    self.proportion = self.maxValue - self.minValue;
    
    CGSize viewSize = self.bounds.size;

    _bgShapeView = [[UIView alloc] initWithFrame:CGRectMake(_sliderOriginX - _cornerRadius, _sliderCenterY - _cornerRadius, viewSize.width - (_sliderOriginX - _cornerRadius)*2, _lineHeight)];
    [self addSubview:_bgShapeView];
    _bgShapeView.backgroundColor = self.minimumTrackTintColor;
    _bgShapeView.layer.cornerRadius = _lineHeight * 0.5;
    _bgShapeView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.12].CGColor;
    _bgShapeView.layer.shadowOffset = CGSizeMake(0,0);
    _bgShapeView.layer.shadowOpacity = 1;
    _bgShapeView.layer.shadowRadius = 4;
    
    _valueShapeLayer = [[CAShapeLayer alloc] init];
    _valueShapeLayer.fillColor = self.maximumTrackTintColor.CGColor;
    [self.layer addSublayer:_valueShapeLayer];
    
    ///吸附 adsorption
    self.adsorbPoint = CGPointZero;
    _adsorbPointColor = [UIColor whiteColor];
    _adsorbShapeLayer = [[CAShapeLayer alloc] init];
    _adsorbShapeLayer.fillColor = self.adsorbPointColor.CGColor;
    [self.layer addSublayer:_adsorbShapeLayer];
    
    CGFloat thumbWidth = 15;
    _thumbSeletedTintColor = UIColor.whiteColor;
    _thumbTintColor = [UIColor whiteColor];
    self.thumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, thumbWidth, thumbWidth)];
    self.thumbView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.thumbView];
    _thumbCenterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    _thumbCenterView.layer.cornerRadius = 9;
    _thumbCenterView.backgroundColor = self.thumbTintColor;
    [self.thumbView addSubview:_thumbCenterView];
    _thumbCenterView.center = CGPointMake(thumbWidth*0.5, thumbWidth*0.5);
    
    self.thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbWidth, thumbWidth)];
    self.thumbImageView.image = NvImageNamed(@"camera_progress_big");
    self.thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.thumbView addSubview:self.thumbImageView];
    self.thumbImageView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.12].CGColor;
    
    self.thumbImageView.layer.shadowOffset = CGSizeMake(0,0);
    self.thumbImageView.layer.shadowOpacity = 1;
    self.thumbImageView.layer.shadowRadius = 4;
    
    self.thumbView.center = CGPointMake(_sliderOriginX, _sliderCenterY);
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.thumbView addGestureRecognizer:panGesture];
    
#ifdef ValueFollow
    self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(_sliderOriginX, 5, 60, 16)];
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    self.valueLabel.alpha = 1;
    self.valueLabel.center = CGPointMake(_sliderOriginX+ (viewSize.width - (_sliderOriginX)*2) * (self.value / self.maxValue), _sliderCenterY - 25);
#else
    self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(_sliderOriginX, 5, self.frame.size.width - _sliderOriginX*2, 16)];
    self.valueLabel.textAlignment = NSTextAlignmentRight;
#endif
    self.valueLabel.font = [UIFont systemFontOfSize:16];
    self.valueLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.valueLabel];
    self.valueLabel.text = [NSString stringWithFormat:self.valueFormat,0];
}

-(void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor{
    _minimumTrackTintColor = minimumTrackTintColor;
    _bgShapeView.backgroundColor = self.minimumTrackTintColor;
}

-(void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor{
    _maximumTrackTintColor = maximumTrackTintColor;
    _valueShapeLayer.fillColor = maximumTrackTintColor.CGColor;
}

-(void)setThumbTintColor:(UIColor *)thumbTintColor{
    _thumbTintColor = thumbTintColor;
    _thumbCenterView.backgroundColor = thumbTintColor;
}

-(void)setLineHeight:(float)lineHeight{
    if (_lineHeight != lineHeight) {
        _lineHeight = lineHeight;
        
        CGSize viewSize = self.bounds.size;
        _bgShapeView.frame = CGRectMake(_sliderOriginX - _cornerRadius, _sliderCenterY - _cornerRadius, viewSize.width - (_sliderOriginX - _cornerRadius)*2, _lineHeight);
        [self addSubview:_bgShapeView];
        _bgShapeView.layer.cornerRadius = _lineHeight * 0.5;
        
        UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(_sliderOriginX - _cornerRadius, _sliderCenterY - _cornerRadius, (viewSize.width - (_sliderOriginX)*2) * ((CGFloat)self.value / self.maxValue) + (_cornerRadius * 2), _lineHeight) cornerRadius:_cornerRadius];
        _valueShapeLayer.path = path.CGPath;
    }
}

-(void)handlePanGesture:(UIPanGestureRecognizer*)gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            _thumbCenterView.backgroundColor = self.thumbSeletedTintColor;
#ifdef ValueFollow
            [UIView animateWithDuration:0.3 animations:^{
                self.valueLabel.alpha = 1;
            }];
#endif
        }
            break;
        case UIGestureRecognizerStateChanged:{
            CGPoint locationPoint = [gesture locationInView:self];
            self.value = [self calculateValue:locationPoint.x];
            if (self.delegate && [self.delegate respondsToSelector:@selector(itemSlider:valueChanged:)]) {
                [self.delegate itemSlider:self valueChanged:self.value];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:{
            _thumbCenterView.backgroundColor = self.thumbTintColor;
            if (self.delegate && [self.delegate respondsToSelector:@selector(itemSliderTouchEnd:)]) {
                [self.delegate itemSliderTouchEnd:self];
            }
#ifdef ValueFollow
            [UIView animateWithDuration:0.3 animations:^{
                self.valueLabel.alpha = 1;
            }];
#endif
        }
            break;
            
        default:
            break;
    }
}

-(float)calculateValue:(CGFloat)locationPointX{
    
    if (!CGPointEqualToPoint(self.adsorbPoint, CGPointZero) && fabs(locationPointX - self.adsorbPoint.x) < _adsorbWidth) {
        locationPointX = self.adsorbPoint.x;
        if (_feedbackEnable) {
            _feedbackEnable = NO;
            [NvAnimationSlider impactFeedback];
        }
    }else{
        _feedbackEnable = YES;
    }
    
    if (locationPointX<=_sliderOriginX) {
        return self.minValue;
    }
    CGSize viewSize = self.bounds.size;
    if (locationPointX>=(viewSize.width - _sliderOriginX)) {
        return self.maxValue;
    }
    
    return self.minValue + (locationPointX - _sliderOriginX)/(viewSize.width - _sliderOriginX*2) * (self.maxValue - self.minValue);
}

-(void)setValue:(float)value{
        _value = value;
        CGSize viewSize = self.bounds.size;
    CGFloat rate = ((CGFloat)(value - self.minValue)) * 1.0 / (self.maxValue - self.minValue);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(_sliderOriginX * 1.0 - _cornerRadius * 1.0 , _sliderCenterY - _cornerRadius, (viewSize.width * 1.0 - (_sliderOriginX)*2.0) * rate + (_cornerRadius * 2.0), _lineHeight) cornerRadius:_cornerRadius];
        _valueShapeLayer.path = path.CGPath;
    
    _valueShapeLayer.backgroundColor = [UIColor redColor].CGColor;
        if (value > 0.50f) {
             _adsorbShapeLayer.hidden = YES;
        }else{
             _adsorbShapeLayer.hidden = NO;
        }
        
        self.thumbView.center = CGPointMake(_sliderOriginX  * 1.0 + (viewSize.width * 1.0 - (_sliderOriginX)*2 * 1.0) * rate, _sliderCenterY);
#ifdef ValueFollow
    self.valueLabel.center = CGPointMake(_sliderOriginX  * 1.0+ (viewSize.width * 1.0 - (_sliderOriginX)*2.0) * rate, _sliderCenterY - 25 );
#endif
        
        self.valueLabel.text = [NSString stringWithFormat:self.valueFormat,value * 1.0 *self.proportion];
}

-(void)adsorb:(BOOL)enable adsorbValue:(float)value{
    if (enable){
        CGSize viewSize = self.bounds.size;
        CGFloat rate = (value - self.minValue) / (self.maxValue - self.minValue);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake((viewSize.width - (_sliderOriginX)*2) * rate + _sliderOriginX, _sliderCenterY) radius:_adsorbPointWidth/2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
        _adsorbShapeLayer.path = path.CGPath;
        
        self.adsorbPoint = CGPointMake((viewSize.width - (_sliderOriginX)*2) * rate + _sliderOriginX, _sliderCenterY);
    }else{
        self.adsorbPoint = CGPointZero;
        _adsorbShapeLayer.path = nil;
    }
}

+(void)impactFeedback{
    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator* feedBack = [[UIImpactFeedbackGenerator alloc] initWithStyle:(UIImpactFeedbackStyleLight)];
        [feedBack impactOccurred];
    } else {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    CGPoint tempPoint =  [self convertPoint:point toView:self.thumbImageView];
    
    
    CGRect rect = CGRectMake(self.thumbImageView.viewX - 10, self.thumbImageView.viewY -10, self.thumbImageView.viewWidth + 20, self.thumbImageView.viewHeight + 20);
    
    
    if (CGRectContainsPoint(rect, tempPoint)) {
        return self.thumbImageView;
    }
    
    return view;
}


@end
