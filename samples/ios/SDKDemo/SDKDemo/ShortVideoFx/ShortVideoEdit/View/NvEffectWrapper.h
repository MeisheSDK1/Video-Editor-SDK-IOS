//
//  NvEffectWrapper.h
//  wangyi
//
//  Created by shizhouhu on 2018/3/25.
//  Copyright © 2018年 meicam.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvSliderView.h"
#import "NvColorBarView.h"
#import "NvsMultiThumbnailSequenceView.h"

@protocol NvEffectWrapperDelegate <NSObject>
- (void)sliderValueChanged:(UISlider *)slider;
- (void)sliderValueEnd:(UISlider *)slider;

@end

@interface NvEffectWrapper : UIControl

@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) NvSliderView *sliderView;
@property (strong, nonatomic) NvColorBarView *colorBarView;
@property (strong, nonatomic) NvsMultiThumbnailSequenceView* sequenceView;
@end
