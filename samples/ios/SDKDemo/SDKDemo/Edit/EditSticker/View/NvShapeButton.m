//
//  NvShapeButton.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/7/18.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvShapeButton.h"
#import <Masonry/Masonry.h>
#import <NvSDKCommon/NvUtils.h>
#import "UIColor+NvColor.h"

@implementation NvShapeButtonItem

@end

@implementation NvShapeButton {
    UIView *mask;
    NvShapeEnum shape;
}

- (id)initWithFrame:(CGRect)frame item: (NvShapeButtonItem *)item{
    self = [super initWithFrame:frame];
    
    self.image = UIImageView.new;
    self.image.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.image];
    [self.image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(45*SCREENSCALE));
        make.height.equalTo(@(45*SCREENSCALE));
        make.top.and.left.and.right.equalTo(self);
    }];
    
    mask = UIView.new;
    mask.layer.masksToBounds = YES;
    mask.layer.cornerRadius = 4;
    mask.backgroundColor = [UIColor nv_colorWithHexRGBA:@"#4A90E277"];
    [self.image addSubview:mask];
    [mask mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.and.left.and.right.equalTo(self.image);
    }];
    
    self.label = UILabel.new;
    self.label.alpha = 0.8;
    self.label.font = [NvUtils fontWithSize:12];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.image.mas_bottom).offset((2*SCREENSCALE));
        make.centerX.equalTo(self.image);
    }];
    
    [self.image setImage:[UIImage imageNamed:item.imagePath]];
    [self.label setText:item.text];
    self.label.textColor = item.selected ? [UIColor nv_colorWithHexRGB:@"#4A90E2"] : UIColor.whiteColor;
    mask.hidden = !item.selected;
    shape = item.shape;
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onButtonClicked)];
    [self addGestureRecognizer:tap];
    
    return self;
}

- (void)onButtonClicked {
    if ([self.delegate respondsToSelector:@selector(onButtonClicked:)]) {
        [self.delegate onButtonClicked:shape];
    }
}

- (void)setSelect:(BOOL)select {
    self.label.textColor = select ? [UIColor nv_colorWithHexRGB:@"#4A90E2"] : UIColor.whiteColor;
    mask.hidden = !select;
}

@end
