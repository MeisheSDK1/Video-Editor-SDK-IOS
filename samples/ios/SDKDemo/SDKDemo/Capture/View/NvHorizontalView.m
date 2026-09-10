//
//  NvHorizontalView.m
//  SDKDemo
//  该控件：左侧图片右侧label
//  The control: left picture right label
//  Created by MS on 2019/6/20.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvHorizontalView.h"
#import <Masonry/Masonry.h>
#import "NVHeader.h"

@interface NvHorizontalView ()
@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, copy)NSString *title;

@end

@implementation NvHorizontalView

- (instancetype)initWithImage:(NSString *)imageName title:(NSString *)title {
    self = [super init];
    _imageName = imageName;
    self.isSelected = NO;
    self.title = title ? title : @"";
    [self addSubviews];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInMethod)];
    [self addGestureRecognizer:tapGesture];
    return self;
}

#pragma mark - 添加子视图
/*
 添加子视图
 Add subview
 */
- (void)addSubviews {
    self.imageView = [[UIImageView alloc] init];
    [self addSubview:self.imageView];
    self.imageView.image = [UIImage imageNamed:self.imageName];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(0);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    self.titleLabel = [[UILabel alloc] init];
    [self addSubview:self.titleLabel];
    self.titleLabel.text = self.title;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView.mas_right);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(0);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat imageWidth = self.imageSize.width ? self.imageSize.width : self.frame.size.width/5;
    CGFloat imageHeight = self.imageSize.height ? self.imageSize.height : imageWidth;
    CGFloat itemSep = self.horizontalItemSep ? self.horizontalItemSep : 2.f;
    CGFloat titleWidth = self.frame.size.width - imageWidth - 2;
    CGFloat titleHeight = self.frame.size.height;
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.width.mas_equalTo(imageWidth);
        make.height.mas_equalTo(imageHeight);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView.mas_right).offset(itemSep);
        make.width.mas_equalTo(titleWidth);
        make.height.mas_equalTo(titleHeight);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
}

#pragma mark - 手势方法
/*
 手势方法
 Gesture method
 */
- (void)tapInMethod {
    self.isSelected = !self.isSelected;
    if ([self.delegate respondsToSelector:@selector(nvHorizontalViewClickedIsSelected:)]) {
        [self.delegate nvHorizontalViewClickedIsSelected:self.isSelected];
    }
}

#pragma mark - setter
- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    self.titleLabel.font = [NvUtils fontWithSize:self.fontSize];
}

- (void)setColorString:(NSString *)colorString {
    _colorString = colorString;
    self.titleLabel.textColor = [UIColor nv_colorWithHexString:colorString];
}

- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    self.imageView.image = [UIImage imageNamed:imageName];
}
@end
