//
//  NvEditBottomCollectionViewCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/12.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvEditBottomCollectionViewCell.h"


@interface NvEditBottomCollectionViewCell ()


@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation NvEditBottomCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews{
    
    self.iconView = [[UIImageView alloc]init];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.alpha = 0.8;
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.font = [NvUtils fontWithSize:11 * SCREENSCALE];
    
    [self addSubview:self.iconView];
    [self addSubview:self.titleLabel];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top);
        make.width.offset(45  * SCREENSCALE);
        make.height.offset(45 * SCREENSCALE);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.mas_equalTo(0);
        make.centerY.equalTo(self.iconView.mas_bottom).offset(18 * SCREENSCALE);
    }];
}

- (void)setDict:(NSDictionary *)dict{
    _dict = dict;
    self.titleLabel.text = [dict allKeys].lastObject;
    self.iconView.image = NvImageNamed([dict allValues].lastObject);
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
}

-(void)setModel:(NvEditCorrectColorItem *)model{
    _model = model;
    self.titleLabel.text = model.name;
    if (model.isSelected) {
        self.iconView.image = NvImageNamed(model.slecteImage);
        self.titleLabel.textColor = [UIColor nv_colorWithHexString:@"#63ABFF"];
    }else{
        self.iconView.image = NvImageNamed(model.unslecteImage);
        self.titleLabel.textColor = [UIColor nv_colorWithHexString:@"#FFFFFF"];
    }
    
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
}
@end
