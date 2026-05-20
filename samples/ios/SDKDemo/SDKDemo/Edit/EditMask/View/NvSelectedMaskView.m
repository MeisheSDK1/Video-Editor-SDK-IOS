//
//  NvSelectedMaskView.m
//  SDKDemo
//
//  Created by ms on 2021/3/4.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvSelectedMaskView.h"
#import "NvGraphicBtn.h"
#import "NVHeader.h"
@interface NvSelectedMaskView ()
@property (nonatomic, strong) NvGraphicBtn *maskButton;
@property (nonatomic, strong) UIButton *okButton;

@property (nonatomic, strong) UIView *line;

@end

@implementation NvSelectedMaskView

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
        
        self.maskButton = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Add Mask", @"添加蒙版") withImageNormal:@"NvAddMask" withImageSelected:@"NvAddMask"];
        [self.maskButton setCustomImageSize:CGSizeMake(40*SCREENSCALE, 40*SCREENSCALE) offset:7.5*SCREENSCALE];
        [self.maskButton setCustomFontSize:10];
        [self.maskButton setAlpha:0.8];
        self.maskButton.btnLabel.numberOfLines = 2;
        [self addSubview:self.maskButton];
        [self.maskButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.width.equalTo(@(64*SCREENSCALE));
            make.height.equalTo(@(45*SCREENSCALE));
            make.bottom.equalTo(self.okButton.mas_top).offset(-60*SCREENSCALE);
        }];

        
        [self.maskButton nv_BtnClickHandler:^{
            if (weakSelf.addMaskBtnClick) {
                weakSelf.addMaskBtnClick();
            }
        }];
  
    }
    return self;
}




@end
