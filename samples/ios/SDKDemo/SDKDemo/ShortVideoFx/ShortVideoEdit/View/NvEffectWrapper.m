//
//  NvEffectWrapper.m
//  wangyi
//
//  Created by shizhouhu on 2018/3/25.
//  Copyright © 2018年 meicam.com. All rights reserved.
//

#import "NvEffectWrapper.h"
#import <Masonry/Masonry.h>
#define NV_TIME_BASE 1000000

@implementation NvEffectWrapper

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self initSequenceView:self.bounds];
    [self initColorBarView:self.bounds];
    [self initSliderView:self.bounds];
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
    self.colorBarView = [[NvColorBarView alloc] initWithFrame:frame];
    [self addSubview:self.colorBarView];
    [self.colorBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self);
        make.top.and.bottom.equalTo(self);
    }];

}

- (void)initSliderView:(CGRect)frame {
    self.sliderView = [[NvSliderView alloc] initWithFrame:frame];
    [self addSubview:self.sliderView];

    
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
