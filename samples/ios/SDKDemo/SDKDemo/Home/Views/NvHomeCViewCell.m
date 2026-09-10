//
//  NvHomeCViewCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/15.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvHomeCViewCell.h"
#import "NvHeader.h"

@implementation NvHomeArrayModel

@end

@implementation NvHomeModel

@end

@interface NvHomeCViewCell()
///显示的文字
///Displayed text
@property (nonatomic, strong) UILabel *name;
///封面
///cover
@property (nonatomic, strong) UIImageView *cover;
@end

@implementation NvHomeCViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.cover = [[UIImageView alloc]init];
        self.cover.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.cover];
        [self.cover mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(KScale6s(4));
            make.right.mas_equalTo(-KScale6s(4));
            make.height.mas_equalTo(self.cover.mas_width);
        }];
        
        self.name = [[UILabel alloc]init];
        self.name.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
        self.name.font = [NvUtils mediumFontWithSize:12];
        self.name.numberOfLines = 2;
        self.name.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.name];
        [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.cover.mas_bottom).offset(KScale6s(16));
            make.left.mas_equalTo(-KScale6s(10));
            make.right.mas_equalTo(KScale6s(10));
        }];
    }
    return self;
}

- (void)renderCellWithItem:(NvHomeModel *)item {
    self.name.text = item.name;
    self.cover.image = item.coverImage;
}


- (void)gradientView:(UIView *)sender withColors:(NSArray *)colors{
    ///创建CAGradientLayer 对象
    ///Create the CAGradientLayer object
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    ///设置CAGradientLayer 对象的位置大小和承接视图等同
    ///Set the position size of the CAGradientLayer object to the same size as the undertaking view
    gradientLayer.frame = CGRectMake(0, 0, sender.frame.size.width, sender.frame.size.height);
    ///设置渐变色(即颜色数组)
    ///Set gradients (array of colors)
    gradientLayer.colors = colors;
    ///变化位置或变化点
    ///To change position or point
    gradientLayer.locations = @[@(0.0f),@(1.0f)];
    ///渐变方向
    ///Gradient direction
    gradientLayer.startPoint = CGPointMake(1, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    gradientLayer.masksToBounds = YES;
    gradientLayer.cornerRadius = 29 * SCREENSCALE;
    ///添加
    ///add
    [sender.layer addSublayer:gradientLayer];
}

@end
