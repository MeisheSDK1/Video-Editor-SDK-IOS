//
//  NvCaptionCurveCell.m
//  SDKDemo
//
//  Created by ms on 2021/5/19.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvCaptionCurveCell.h"
#import "NVHeader.h"
@interface NvCaptionCurveCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel * nameLabel;

@end

@implementation NvCaptionCurveCell

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
    [self.contentView addSubview:self.iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
    
    self.nameLabel = [UILabel nv_labelWithText:NvLocalString(@"Custom", @"自定义") fontSize:8.0 textColor:UIColor.grayColor];
    self.nameLabel.numberOfLines = 2;
    self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.nameLabel.hidden = YES;
    [self.iconView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(KScale6s(15));
        make.right.mas_equalTo(-KScale6s(4));
    }];
}

-(void)setItem:(NvCaptionCurveItem *)item{
    _item = item;
    self.iconView.image = [UIImage imageNamed:item.image];
    if (item.isSelected) {
        self.iconView.layer.borderWidth = 2.0f;
        self.iconView.layer.borderColor = [UIColor nv_colorWithHexString:@"#63ABFF"].CGColor;
    }else{
        self.iconView.layer.borderWidth = 2.0f;
        self.iconView.layer.borderColor = [UIColor clearColor].CGColor;
    }
    self.nameLabel.hidden = item.type != CurveAnimationTypeCustom;
}
@end
