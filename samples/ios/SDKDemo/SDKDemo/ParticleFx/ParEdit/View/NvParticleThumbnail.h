//
//  NvParticleThumbnail.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/12/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvParticleSlider.h"
#import "NvParticleColorBar.h"
#import "NvsMultiThumbnailSequenceView.h"

@protocol NvParticleThumbnailDelegate <NSObject>
- (void)sliderValueChanged:(UISlider *)slider;
- (void)sliderValueEnd:(UISlider *)slider;

@end


@interface NvParticleThumbnail : UIControl

@property (weak, nonatomic) id<NvParticleThumbnailDelegate> delegate;
@property (strong, nonatomic) NvParticleSlider *sliderView;
@property (strong, nonatomic) NvParticleColorBar *colorBarView;
@property (strong, nonatomic) NvsMultiThumbnailSequenceView* sequenceView;

@end


