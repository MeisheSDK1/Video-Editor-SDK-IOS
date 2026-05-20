//
//  NvSizeView.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMimoSizeView.h"
#import <Masonry/Masonry.h>
#import <UILabel+NvLabel.h>
#import <UIButton+NvButton.h>
#import <NvBaseCommon/NVDefineConfig.h>

@interface NvMimoSizeView()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *horizontalLine;
@property (nonatomic, strong) UIView *horizontalLine2;
@property (nonatomic, strong) UIView *verticalLine;
@property (nonatomic, strong) UIButton *button16X9;
@property (nonatomic, strong) UIButton *button1X1;
@property (nonatomic, strong) UIButton *button9X16;
@property (nonatomic, strong) UIButton *button3X4;
@property (nonatomic, strong) UIButton *button4X3;


@end

@implementation NvMimoSizeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4D4F51"];
        self.titleLabel = [UILabel nv_labelWithText:NvLocalStringFromTableInBundle(@"album.ratio", @"NvAlbum", [NSBundle bundleForClass:self.class], @"选择制作比例") fontSize:14 textColor:[UIColor colorWithWhite:1 alpha:0.8]];
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(@(8*SCREANSCALE));
            make.height.equalTo(@(24*SCREANSCALE));
        }];
        
        self.topLine = [UIView new];
        [self addSubview:self.topLine];
        self.topLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
        [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(8*SCREANSCALE);
            make.left.equalTo(@(8*SCREANSCALE));
            make.right.equalTo(@(-8*SCREANSCALE));
            make.height.equalTo(@1);
        }];
        
        self.horizontalLine = [UIView new];
        [self addSubview:self.horizontalLine];
        self.horizontalLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
        [self.horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(125*SCREANSCALE));
            make.left.equalTo(@(13*SCREANSCALE));
            make.right.equalTo(@(-13*SCREANSCALE));
            make.height.equalTo(@1);
        }];
        
        self.horizontalLine2 = [UIView new];
        [self addSubview:self.horizontalLine2];
        self.horizontalLine2.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
        [self.horizontalLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(221*SCREANSCALE));
            make.left.equalTo(@(13*SCREANSCALE));
            make.right.equalTo(@(-13*SCREANSCALE));
            make.height.equalTo(@1);
        }];
        
        self.verticalLine = [UIView new];
        [self addSubview:self.verticalLine];
        self.verticalLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
        [self.verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topLine.mas_bottom).offset(13*SCREANSCALE);
            make.bottom.equalTo(self).offset(-13*SCREANSCALE);
            make.width.equalTo(@1);
            make.centerX.equalTo(self);
        }];
        
        self.button16X9 = [UIButton nv_buttonWithTitle:@"16:9" textColor:[UIColor colorWithWhite:1 alpha:0.8] fontSize:14];
        self.button1X1 = [UIButton nv_buttonWithTitle:@"1:1" textColor:[UIColor colorWithWhite:1 alpha:0.8] fontSize:14];
        self.button9X16 = [UIButton nv_buttonWithTitle:@"9:16" textColor:[UIColor colorWithWhite:1 alpha:0.8] fontSize:14];
        self.button3X4 = [UIButton nv_buttonWithTitle:@"2.39:1" textColor:[UIColor colorWithWhite:1 alpha:0.8] fontSize:14];
        self.button4X3 = [UIButton nv_buttonWithTitle:@"2.55:1" textColor:[UIColor colorWithWhite:1 alpha:0.8] fontSize:14];

        [self addSubview:self.button16X9];
        [self addSubview:self.button1X1];
        [self addSubview:self.button9X16];
        [self addSubview:self.button3X4];
        [self addSubview:self.button4X3];
        
            [self.button16X9 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.button16X9 setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
            [self.button1X1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.button1X1 setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
            [self.button9X16 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.button9X16 setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
            [self.button3X4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.button3X4 setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
            [self.button4X3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.button4X3 setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];

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
        [self.button1X1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horizontalLine2.mas_bottom);
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
                [self.delegate nvSizeView:self selectType:NvEditMode2d39v1];
            }
        }];
        
        [self.button4X3 nv_BtnClickHandler:^{
            if ([self.delegate respondsToSelector:@selector(nvSizeView:selectType:)]) {
                [self.delegate nvSizeView:self selectType:NvEditMode2d55v1];
            }
        }];
        
    }
    return self;
}

- (void)setSupportedAspectRatio:(NSString *)supportedAspectRatio {
    _supportedAspectRatio = supportedAspectRatio;
    for (UIButton *button in self.subviews) {
        button.enabled = NO;
    }
    if ([supportedAspectRatio containsString:@"|"]) {
        NSArray *rationArr = [supportedAspectRatio componentsSeparatedByString:@"|"];
        if ([rationArr containsObject:@"16v9"]) {
            self.button16X9.enabled = YES;
        }
        if ([rationArr containsObject:@"1v1"]) {
            self.button1X1.enabled = YES;
        }
        if ([rationArr containsObject:@"9v16"]) {
            self.button9X16.enabled = YES;
        }
        if ([rationArr containsObject:@"2d39v1"]) {
            self.button3X4.enabled = YES;
        }
        if ([rationArr containsObject:@"2d55v1"]) {
            self.button4X3.enabled = YES;
        }
    }else{
        if([supportedAspectRatio isEqualToString:@"16v9"]){
            self.button16X9.enabled = YES;
        }else if([supportedAspectRatio isEqualToString:@"1v1"]){
            self.button1X1.enabled = YES;
        }else if([supportedAspectRatio isEqualToString:@"9v16"]){
            self.button9X16.enabled = YES;
        }else if([supportedAspectRatio isEqualToString:@"2d39v1"]){
            self.button3X4.enabled = YES;
        }else if([supportedAspectRatio isEqualToString:@"2d55v1"]){
            self.button4X3.enabled = YES;
        }
    }
}

@end
