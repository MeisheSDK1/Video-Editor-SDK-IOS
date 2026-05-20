//
//  NvFeatureCollectionViewCell.m
//  SDKDemo
//
//  Created by meishe01 on 2018/6/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvFeatureCollectionViewCell.h"
#import "NVHeader.h"

@interface NvFeatureCollectionViewCell () {
    UIImageView *_image;
    UILabel *_name;
}

@end

@implementation NvFeatureCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _image = [UIImageView new];
        [self addSubview:_image];
        [_image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.width.height.equalTo(@(49 * SCREENSCALE));
            make.centerX.equalTo(self);
        }];
        _name = [UILabel new];
        [self addSubview:_name];
        [_name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.centerY.equalTo(_image.mas_bottom).offset(17 * SCREENSCALE);
        }];
        _name.textAlignment = NSTextAlignmentCenter;
        _name.alpha = 0.8;
        _name.numberOfLines = 2;
        _name.lineBreakMode = NSLineBreakByTruncatingTail;
        _name.textColor = [UIColor whiteColor];
        _name.font = [NvUtils fontWithSize:12];
    }
    return self;
}

- (void)renderCellWithItem:(NvFeatureItem *)item {
    _image.image = NvImageNamed(item.image);
    _name.text = item.name;
}

@end
