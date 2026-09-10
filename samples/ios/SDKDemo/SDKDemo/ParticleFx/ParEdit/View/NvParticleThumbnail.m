//
//  NvParticleThumbnail.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/12/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvParticleThumbnail.h"
#import <Masonry/Masonry.h>
#define NV_TIME_BASE 1000000

@implementation NvParticleThumbnail
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self initSequenceView:frame];
    [self initColorBarView:frame];
    [self initSliderView:frame];
    return self;
}

- (void)initSequenceView:(CGRect)frame {
    CGFloat width = frame.size.width;
    float pointsPerMicrosecond = width/NV_TIME_BASE; //default display one second
    self.sequenceView = [[NvsMultiThumbnailSequenceView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, frame.size.height)];
    self.sequenceView.thumbnailAspectRatio = 0.5;
    self.sequenceView.pointsPerMicrosecond = pointsPerMicrosecond;
    self.sequenceView.startPadding = 0;
    self.sequenceView.endPadding = self.sequenceView.startPadding;
    self.sequenceView.thumbnailImageFillMode = NvsThumbnailFillModeAspectCrop;
    [self addSubview:self.sequenceView];
    [self.sequenceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self);
        make.top.and.bottom.equalTo(self);
    }];
}

- (void)initColorBarView:(CGRect)frame {
    self.colorBarView = [[NvParticleColorBar alloc] initWithFrame:frame];
    [self addSubview:self.colorBarView];
    [self.colorBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self);
        make.top.and.bottom.equalTo(self);
    }];
}

- (void)initSliderView:(CGRect)frame {
    self.sliderView = [[NvParticleSlider alloc] initWithFrame:frame];
    [self addSubview:self.sliderView];
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self);
        make.top.and.bottom.equalTo(self);
    }];
    
    [self.sliderView addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.sliderView addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.sliderView addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)sliderValueChanged:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [self.delegate sliderValueChanged:slider];
    }
}

- (void)sliderValueEnd:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(sliderValueEnd:)]) {
        [self.delegate sliderValueEnd:slider];
    }
}

@end
