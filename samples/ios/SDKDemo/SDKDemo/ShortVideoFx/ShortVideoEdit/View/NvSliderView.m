//
//  NvSliderView.m
//  wangyi
//
//  Created by shizhouhu on 2018/3/25.
//  Copyright © 2018年 meicam.com. All rights reserved.
//

#import "NvSliderView.h"
#import <Masonry/Masonry.h>
#import <NvSDKCommon/NvUtils.h>

#define NV_SLIDER_BAR_WIDTH 6

@implementation NvSliderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    
    _value = 0;
    _sliderKnob = UIImageView.new;
    _sliderKnob.userInteractionEnabled = NO;
    _sliderKnob.layer.cornerRadius = NV_SLIDER_BAR_WIDTH/2;
    [_sliderKnob setImage:NvImageNamed(@"NvSliderBar")];
    [self addSubview:_sliderKnob];
    float height = 25*SCREENSCALE + 6*SCREENSCALE;
    [_sliderKnob mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(-NV_SLIDER_BAR_WIDTH/2);
        make.top.equalTo(self).offset(-3*SCREENSCALE);
        make.height.mas_equalTo(height);
        make.width.mas_equalTo(NV_SLIDER_BAR_WIDTH);
    }];
    
    _knobTouchEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    
    return self;
}

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    
    if(CGRectContainsPoint(UIEdgeInsetsInsetRect(_sliderKnob.frame, self.knobTouchEdgeInsets), touchPoint)) {
        _sliderKnob.highlighted = YES;
    }
    return YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!_sliderKnob.highlighted) {
        return YES;
    }
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint previousPoint = [touch previousLocationInView:self];
    
    if (_sliderKnob.highlighted) {
        CGAffineTransform trans = CGAffineTransformTranslate(_sliderKnob.transform, currentPoint.x - previousPoint.x, 0);
        
        if (trans.tx > self.frame.size.width) {
            trans.tx = self.frame.size.width;
        }
        if (trans.tx < 0) {
            trans.tx = 0;
        }
        _sliderKnob.transform = trans;
        
        _value = (_sliderKnob.frame.origin.x + NV_SLIDER_BAR_WIDTH/2)/self.frame.size.width;
        if (_value < 0)
            _value = 0;
        if (_value > self.frame.size.width)
            _value = self.frame.size.width;
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(!_sliderKnob.highlighted){
        return;
    }
    
    if (_sliderKnob.highlighted) {
        [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
    }
    
    _sliderKnob.highlighted = NO;
}

- (void)setValue:(float)value {
    _value = value;
    
    _sliderKnob.transform = CGAffineTransformMakeTranslation(self.frame.size.width*value, _sliderKnob.transform.ty);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
