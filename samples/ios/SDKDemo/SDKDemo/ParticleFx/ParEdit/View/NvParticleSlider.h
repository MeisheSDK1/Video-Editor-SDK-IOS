//
//  NvParticleSlider.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/12/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvParticleSlider : UIControl

@property (strong, nonatomic) UIImageView *sliderKnob;
@property (assign, nonatomic) UIEdgeInsets knobTouchEdgeInsets;
@property (assign, nonatomic) float value;

@end


