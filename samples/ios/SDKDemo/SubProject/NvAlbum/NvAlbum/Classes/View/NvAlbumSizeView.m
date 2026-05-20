//
//  NvSizeView.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvAlbumSizeView.h"
#import <Masonry/Masonry.h>
#import "UILabel+NvLabel.h"
#import "UIButton+NvButton.h"
#import "UIColor+NvColor.h"
#import "NVDefineConfig.h"

@interface NvAlbumSizeView()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *horizontalLine;
@property (nonatomic, strong) UIView *horizontalLine2;
@property (nonatomic, strong) UIView *horizontalLine3;
@property (nonatomic, strong) UIView *horizontalLine4;
@property (nonatomic, strong) UIView *horizontalLine5;
@property (nonatomic, strong) UIView *verticalLine;
@property (nonatomic, strong) UIButton *button16X9;
@property (nonatomic, strong) UIButton *button1X1;
@property (nonatomic, strong) UIButton *button9X16;
@property (nonatomic, strong) UIButton *button3X4;
@property (nonatomic, strong) UIButton *button4X3;
@property (nonatomic, strong) UIButton *button21X9;
@property (nonatomic, strong) UIButton *button9X21;
@property (nonatomic, strong) UIButton *button18X9;
@property (nonatomic, strong) UIButton *button9X18;
@property (nonatomic, strong) UIButton *button7X6;
@property (nonatomic, strong) UIButton *button6X7;


@end

@implementation NvAlbumSizeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4D4F51"];
        self.titleLabel = [UILabel nv_labelWithText:NvLocalStringFromTableInBundle(@"album.ratio",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) fontSize:14 textColor:[UIColor colorWithWhite:1 alpha:0.8]];
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(@(8*SCREENSCALE));
            make.height.equalTo(@(24*SCREENSCALE));
        }];
        
        self.topLine = [UIView new];
        [self addSubview:self.topLine];
        self.topLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
        [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(8*SCREENSCALE);
            make.left.equalTo(@(8*SCREENSCALE));
            make.right.equalTo(@(-8*SCREENSCALE));
            make.height.equalTo(@1);
        }];
        
        self.horizontalLine = [UIView new];
        [self addSubview:self.horizontalLine];
        self.horizontalLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
        [self.horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topLine.mas_bottom).offset(50 * SCREENSCALE);
            make.left.equalTo(@(13*SCREENSCALE));
            make.right.equalTo(@(-13*SCREENSCALE));
            make.height.equalTo(@1);
        }];
        
        self.horizontalLine2 = [UIView new];
        [self addSubview:self.horizontalLine2];
        self.horizontalLine2.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
        [self.horizontalLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horizontalLine.mas_bottom).offset(50*SCREENSCALE);
            make.left.equalTo(@(13*SCREENSCALE));
            make.right.equalTo(@(-13*SCREENSCALE));
            make.height.equalTo(@1);
        }];
        self.horizontalLine3 = [UIView new];
        [self addSubview:self.horizontalLine3];
        self.horizontalLine3.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
        [self.horizontalLine3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horizontalLine2.mas_bottom).offset(50*SCREENSCALE);
            make.left.equalTo(@(13*SCREENSCALE));
            make.right.equalTo(@(-13*SCREENSCALE));
            make.height.equalTo(@1);
        }];
        self.horizontalLine4 = [UIView new];
        [self addSubview:self.horizontalLine4];
        self.horizontalLine4.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
        [self.horizontalLine4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horizontalLine3.mas_bottom).offset(50*SCREENSCALE);
            make.left.equalTo(@(13*SCREENSCALE));
            make.right.equalTo(@(-13*SCREENSCALE));
            make.height.equalTo(@1);
        }];
        self.horizontalLine5 = [UIView new];
        [self addSubview:self.horizontalLine5];
        self.horizontalLine5.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
        [self.horizontalLine5 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horizontalLine4.mas_bottom).offset(50*SCREENSCALE);
            make.left.equalTo(@(13*SCREENSCALE));
            make.right.equalTo(@(-13*SCREENSCALE));
            make.height.equalTo(@1);
        }];

        self.verticalLine = [UIView new];
        [self addSubview:self.verticalLine];
        self.verticalLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
        [self.verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topLine.mas_bottom).offset(13*SCREENSCALE);
            make.bottom.equalTo(self).offset(-13*SCREENSCALE);
            make.width.equalTo(@1);
            make.centerX.equalTo(self);
        }];
        
        self.button16X9 = [UIButton nv_buttonWithTitle:@"16:9" textColor:[UIColor colorWithWhite:1 alpha:0.8] fontSize:14];
        self.button1X1 = [UIButton nv_buttonWithTitle:@"1:1" textColor:[UIColor colorWithWhite:1 alpha:0.8] fontSize:14];
        self.button9X16 = [UIButton nv_buttonWithTitle:@"9:16" textColor:[UIColor colorWithWhite:1 alpha:0.8] fontSize:14];
        self.button3X4 = [UIButton nv_buttonWithTitle:@"3:4" textColor:[UIColor colorWithWhite:1 alpha:0.8] fontSize:14];
        self.button4X3 = [UIButton nv_buttonWithTitle:@"4:3" textColor:[UIColor colorWithWhite:1 alpha:0.8] fontSize:14];
        self.button21X9 = [UIButton nv_buttonWithTitle:@"21:9" textColor:[UIColor colorWithWhite:1 alpha:0.8] fontSize:14];
        self.button9X21 = [UIButton nv_buttonWithTitle:@"9:21" textColor:[UIColor colorWithWhite:1 alpha:0.8] fontSize:14];
        self.button18X9 = [UIButton nv_buttonWithTitle:@"18:9" textColor:[UIColor colorWithWhite:1 alpha:0.8] fontSize:14];
        self.button9X18 = [UIButton nv_buttonWithTitle:@"9:18" textColor:[UIColor colorWithWhite:1 alpha:0.8] fontSize:14];
        self.button7X6 = [UIButton nv_buttonWithTitle:@"7:6" textColor:[UIColor colorWithWhite:1 alpha:0.8] fontSize:14];
        self.button6X7 = [UIButton nv_buttonWithTitle:@"6:7" textColor:[UIColor colorWithWhite:1 alpha:0.8] fontSize:14];

        [self addSubview:self.button16X9];
        [self addSubview:self.button1X1];
        [self addSubview:self.button9X16];
        [self addSubview:self.button3X4];
        [self addSubview:self.button4X3];
        [self addSubview:self.button21X9];
        [self addSubview:self.button9X21];
        [self addSubview:self.button18X9];
        [self addSubview:self.button9X18];
        [self addSubview:self.button7X6];
        [self addSubview:self.button6X7];
        
        [self.button16X9 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topLine.mas_bottom);
            make.left.equalTo(self);
            make.right.equalTo(self.verticalLine.mas_left);
            make.bottom.equalTo(self.horizontalLine.mas_top);
        }];
        [self.button9X16 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topLine.mas_bottom);
            make.left.equalTo(self.verticalLine.mas_right);
            make.right.equalTo(self);
            make.bottom.equalTo(self.horizontalLine.mas_top);
        }];
        [self.button4X3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horizontalLine.mas_bottom);
            make.left.equalTo(self);
            make.right.equalTo(self.verticalLine.mas_left);
            make.bottom.equalTo(self.horizontalLine2.mas_top);
        }];
        [self.button3X4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horizontalLine.mas_bottom);
            make.left.equalTo(self.verticalLine.mas_right);
            make.right.equalTo(self);
            make.bottom.equalTo(self.horizontalLine2.mas_top);
        }];
        
        [self.button21X9 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horizontalLine2.mas_bottom);
            make.left.equalTo(self);
            make.right.equalTo(self.verticalLine.mas_left);
            make.bottom.equalTo(self.horizontalLine3.mas_top);
        }];
        
        [self.button9X21 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horizontalLine2.mas_bottom);
            make.left.equalTo(self.verticalLine.mas_right);
            make.right.equalTo(self);
            make.bottom.equalTo(self.horizontalLine3.mas_top);
        }];
        
        [self.button18X9 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horizontalLine3.mas_bottom);
            make.left.equalTo(self);
            make.right.equalTo(self.verticalLine.mas_left);
            make.bottom.equalTo(self.horizontalLine4.mas_top);
        }];
        
        [self.button9X18 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horizontalLine3.mas_bottom);
            make.left.equalTo(self.verticalLine.mas_right);
            make.right.equalTo(self);
            make.bottom.equalTo(self.horizontalLine4.mas_top);
        }];
        [self.button7X6 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horizontalLine4.mas_bottom);
            make.left.equalTo(self);
            make.right.equalTo(self.verticalLine.mas_left);
            make.bottom.equalTo(self.horizontalLine5.mas_top);
        }];
        
        [self.button6X7 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horizontalLine4.mas_bottom);
            make.left.equalTo(self.verticalLine.mas_right);
            make.right.equalTo(self);
            make.bottom.equalTo(self.horizontalLine5.mas_top);
        }];
        [self.button1X1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horizontalLine5.mas_bottom);
            make.left.equalTo(self);
            make.right.equalTo(self.verticalLine.mas_left);
            make.bottom.equalTo(self);
        }];
        
        
        [self.button16X9 nv_BtnClickHandler:^{
            if ([self.delegate respondsToSelector:@selector(nvSizeView:selectType:)]) {
                [self.delegate nvSizeView:self selectType:NvEditMode16v9];
            }
        }];
        
        [self.button1X1 nv_BtnClickHandler:^{
            if ([self.delegate respondsToSelector:@selector(nvSizeView:selectType:)]) {
                [self.delegate nvSizeView:self selectType:NvEditMode1v1];
            }
        }];
        
        [self.button9X16 nv_BtnClickHandler:^{
            if ([self.delegate respondsToSelector:@selector(nvSizeView:selectType:)]) {
                [self.delegate nvSizeView:self selectType:NvEditMode9v16];
            }
        }];
        
        [self.button3X4 nv_BtnClickHandler:^{
            if ([self.delegate respondsToSelector:@selector(nvSizeView:selectType:)]) {
                [self.delegate nvSizeView:self selectType:NvEditMode3v4];
            }
        }];
        
        [self.button4X3 nv_BtnClickHandler:^{
            if ([self.delegate respondsToSelector:@selector(nvSizeView:selectType:)]) {
                [self.delegate nvSizeView:self selectType:NvEditMode4v3];
            }
        }];
        [self.button21X9 nv_BtnClickHandler:^{
            if ([self.delegate respondsToSelector:@selector(nvSizeView:selectType:)]) {
                [self.delegate nvSizeView:self selectType:NvEditMode21v9];
            }
        }];
        [self.button9X21 nv_BtnClickHandler:^{
            if ([self.delegate respondsToSelector:@selector(nvSizeView:selectType:)]) {
                [self.delegate nvSizeView:self selectType:NvEditMode9v21];
            }
        }];
        [self.button18X9 nv_BtnClickHandler:^{
            if ([self.delegate respondsToSelector:@selector(nvSizeView:selectType:)]) {
                [self.delegate nvSizeView:self selectType:NvEditMode18v9];
            }
        }];
        [self.button9X18 nv_BtnClickHandler:^{
            if ([self.delegate respondsToSelector:@selector(nvSizeView:selectType:)]) {
                [self.delegate nvSizeView:self selectType:NvEditMode9v18];
            }
        }];
        [self.button7X6 nv_BtnClickHandler:^{
            if ([self.delegate respondsToSelector:@selector(nvSizeView:selectType:)]) {
                [self.delegate nvSizeView:self selectType:NvEditMode7v6];
            }
        }];
        [self.button6X7 nv_BtnClickHandler:^{
            if ([self.delegate respondsToSelector:@selector(nvSizeView:selectType:)]) {
                [self.delegate nvSizeView:self selectType:NvEditMode6v7];
            }
        }];
        
    }
    return self;
}

@end
