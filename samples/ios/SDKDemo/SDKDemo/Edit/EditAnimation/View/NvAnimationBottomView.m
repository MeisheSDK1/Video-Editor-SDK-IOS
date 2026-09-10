//
//  NvAnimationBottomView.m
//  SDKDemo
//
//  Created by ms on 2020/8/24.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvAnimationBottomView.h"
#import "NVHeader.h"
#import "NvsTimeline.h"

@interface NvAnimationBottomView ()

@property (nonatomic, strong) UIButton *okButton;

@property (nonatomic, strong) UIView *line;

@end

@implementation NvAnimationBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.okButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvcheck - material")];
        [self addSubview:self.okButton];
        __weak typeof(self)weakSelf = self;
        [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.equalTo(@(25*SCREENSCALEHEIGHT));
            make.height.equalTo(@(20*SCREENSCALE));
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(@(-15*SCREENSCALE));
            }
        }];
        
        [self.okButton nv_BtnClickHandler:^{
            if (weakSelf.okBtnClick) {
                weakSelf.okBtnClick();
            }
        }];
        
        self.line = [UIView new];
        self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
        [self addSubview:self.line];
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.height.equalTo(@1);
            make.bottom.equalTo(self.okButton.mas_top).offset(-12*SCREENSCALE);
        }];
        
        self.outButton = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Out animation", @"出场动画") withImageNormal:@"out_animation" withImageSelected:@"out_animation"];
        [self.outButton setCustomImageSize:CGSizeMake(14*SCREENSCALE, 14*SCREENSCALE) offset:7.5*SCREENSCALE];
        [self.outButton setCustomFontSize:10];
        [self.outButton setAlpha:0.8];
        self.outButton.btnLabel.numberOfLines = 2;
        [self addSubview:self.outButton];
        [self.outButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.width.equalTo(@(64*SCREENSCALE));
            make.height.equalTo(@(43*SCREENSCALE));
            make.bottom.equalTo(self.okButton.mas_top).offset(-30*SCREENSCALE);
        }];
        
        [self.outButton nv_BtnClickHandler:^{
            if (weakSelf.selectAnimationTypeBlock) {
                weakSelf.selectAnimationTypeBlock(NVAnimationTypeOut);
            }
        }];
        
        self.inButton = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"In animation", @"入场动画") withImageNormal:@"in_animation" withImageSelected:@"in_animation"];
        [self.inButton setCustomImageSize:CGSizeMake(14*SCREENSCALE, 14*SCREENSCALE) offset:7.5*SCREENSCALE];
        [self.inButton setCustomFontSize:10];
        [self.inButton setAlpha:0.8];
        self.inButton.btnLabel.numberOfLines = 2;
        [self addSubview:self.inButton];
        [self.inButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.outButton.mas_left).offset(-30*SCREENSCALE);
            make.width.equalTo(@(64*SCREENSCALE));
            make.height.equalTo(@(43*SCREENSCALE));
            make.bottom.equalTo(self.okButton.mas_top).offset(-30*SCREENSCALE);
        }];
        
        [self.inButton nv_BtnClickHandler:^{
            if (weakSelf.selectAnimationTypeBlock) {
                weakSelf.selectAnimationTypeBlock(NVAnimationTypeIn);
            }
        }];
        

        self.combineButton = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Combina animation", @"组合动画") withImageNormal:@"combine_animation" withImageSelected:@"combine_animation"];
        [self.combineButton setCustomImageSize:CGSizeMake(14*SCREENSCALE, 14*SCREENSCALE) offset:7.5*SCREENSCALE];
        [self.combineButton setCustomFontSize:10];
        [self.combineButton setAlpha:0.8];
        self.combineButton.btnLabel.numberOfLines = 2;
        [self addSubview:self.combineButton];
        [self.combineButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.outButton.mas_right).offset(30*SCREENSCALE);
            make.width.equalTo(@(64*SCREENSCALE));
            make.height.equalTo(@(43*SCREENSCALE));
            make.bottom.equalTo(self.okButton.mas_top).offset(-30*SCREENSCALE);
        }];
        
        [self.combineButton nv_BtnClickHandler:^{
            if (weakSelf.selectAnimationTypeBlock) {
                weakSelf.selectAnimationTypeBlock(NVAnimationTypeCombine);
            }
        }];
    }
    return self;
}


@end
