//
//  NvPsTitleCollectionViewCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/8/6.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvPsTitleCollectionViewCell.h"
#import "Masonry.h"
#import "UIColor+NvLiveColor.h"

@implementation NvPsTitleModel

@end

@interface NvPsTitleCollectionViewCell ()

@property(nonatomic, strong) UILabel *titleLabel;

@end

@implementation NvPsTitleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

#pragma mark - 添加子视图
/*
 添加子视图
 Add subview
 */
- (void)addSubviews {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
}

- (void)renderCellWithString:(NvPsTitleModel *)model {
    //    if (model.selected) {
    //        self.titleLabel.textColor = UIColor.redColor;
    //    }else{
    //        self.titleLabel.textColor = UIColor.whiteColor;
    //    }
    self.titleLabel.text = model.name;
    if (model.colorStr.length > 0) {
        self.titleLabel.textColor = [UIColor nv_colorWithHexRGB:model.colorStr];
    }
    if (model.selected) {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    } else {
        self.titleLabel.font = [UIFont systemFontOfSize:14];
    }
}

@end
