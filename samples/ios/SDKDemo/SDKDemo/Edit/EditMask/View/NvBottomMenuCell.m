//
//  NvBottomMenuCell.m
//  SDKDemo
//
//  Created by ms on 2021/3/5.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvBottomMenuCell.h"

@interface NvBottomMenuCell ()


@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation NvBottomMenuCell

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
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconView.layer.borderWidth = 1.0;
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.alpha = 0.8;
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.font = [NvUtils fontWithSize:12 * SCREENSCALE];
    
    [self addSubview:self.iconView];
    [self addSubview:self.titleLabel];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top);
        make.width.offset(45  * SCREENSCALE);
        make.height.offset(45 * SCREENSCALE);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_lessThanOrEqualTo(self.contentView.mas_width);
        make.centerY.equalTo(self.iconView.mas_bottom).offset(18 * SCREENSCALE);
    }];
}

-(void)setModel:(NvMaskMenuItem *)model{
    _model = model;
    self.titleLabel.text = model.name;
    self.iconView.image = NvImageNamed(model.image);
    if (model.isSelected) {
        self.iconView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#63ABFF"].CGColor;
    }else{
        self.iconView.layer.borderColor = UIColor.clearColor.CGColor;
    }

}
@end
