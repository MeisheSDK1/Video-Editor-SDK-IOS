//
//  NvSliderView.h
//  wangyi
//
//  Created by shizhouhu on 2018/3/25.
//  Copyright © 2018年 meicam.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvSliderView : UIControl

@property (strong, nonatomic) UIImageView *sliderKnob;
@property (assign, nonatomic) UIEdgeInsets knobTouchEdgeInsets;
@property (assign, nonatomic) float value;

@end
