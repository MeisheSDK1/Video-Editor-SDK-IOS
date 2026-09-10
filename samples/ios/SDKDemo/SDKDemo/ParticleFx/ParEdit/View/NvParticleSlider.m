//
//  NvParticleSlider.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/12/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvParticleSlider.h"
#import <Masonry/Masonry.h>
#import <NvSDKCommon/NvUtils.h>
#define NV_SLIDER_BAR_WIDTH 6
@implementation NvParticleSlider
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    
    _value = 0;
    _sliderKnob = UIImageView.new;
    _sliderKnob.userInteractionEnabled = NO;
    _sliderKnob.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    [self addSubview:_sliderKnob];
    float height = 30*SCREENSCALE + 10;
    [_sliderKnob mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(-NV_SLIDER_BAR_WIDTH/2);
        make.top.equalTo(self).offset(-5);
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

@end
