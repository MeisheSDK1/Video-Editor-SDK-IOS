//
//  NvTimeLabelView.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/7/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvTimeLabelView.h"
#import "NvButton.h"
#import <NvSDKCommon/NvUtils.h>
#import "UIButton+NvButton.h"
#import "UILabel+NvLabel.h"
#import "UIColor+NvColor.h"
#import <Masonry/Masonry.h>

@implementation NvTimeLabelView 

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    NvButton *minusButton = [NvButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvminus")];
    [self addSubview:minusButton];
    [minusButton addTarget:self action:@selector(onMinusButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [minusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(120*SCREENSCALE);
        make.top.equalTo(self).offset(4*SCREENSCALE);
        make.width.equalTo(@(12*SCREENSCALE));
        make.height.equalTo(@(12*SCREENSCALE));
    }];
    
    NvButton *addButton = [NvButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvadd")];
    [self addSubview:addButton];
    [addButton addTarget:self action:@selector(onAddButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(243*SCREENSCALE);
        make.top.equalTo(self).offset(4*SCREENSCALE);
        make.width.equalTo(@(12*SCREENSCALE));
        make.height.equalTo(@(12*SCREENSCALE));
    }];
    
    timeLabel = [UILabel nv_labelWithText:[NSString stringWithFormat:@"%@/%@", [NvUtils getFormattedTime:_currentPos], [NvUtils getFormattedTime:_duration]] fontSize:10*SCREENSCALE textColor:[UIColor nv_colorWithHexRGB:@"#FFFFFF"]];
    timeLabel.font = [NvUtils regularFontWithSize:10*SCREENSCALE];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:timeLabel];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(addButton);
        make.height.equalTo(@(14*SCREENSCALE));
    }];
    
    return self;
}

- (void)onMinusButtonClicked {
    if ([self.delegate respondsToSelector:@selector(onZoomOutClicked)]) {
        [self.delegate onZoomOutClicked];
    }
}

- (void)onAddButtonClicked {
    if ([self.delegate respondsToSelector:@selector(onZoomInClicked)]) {
        [self.delegate onZoomInClicked];
    }
}

- (void)updateLabel {
    timeLabel.text = [NSString stringWithFormat:@"%@/%@", [NvUtils getFormattedTime:_currentPos], [NvUtils getFormattedTime:_duration]];
}

@end
