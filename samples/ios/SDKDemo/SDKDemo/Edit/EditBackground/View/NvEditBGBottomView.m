//
//  NvEditBGBottomView.m
//  SDKDemo
//
//  Created by MS on 2020/10/21.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvEditBGBottomView.h"
#import "NvGraphicBtn.h"
#import "NVHeader.h"
@interface NvEditBGBottomView ()
@property (nonatomic, strong) UIButton *applyButton;
@property (nonatomic, strong) NvGraphicBtn *leftButton;
@property (nonatomic, strong) NvGraphicBtn *centerButton;
@property (nonatomic, strong) NvGraphicBtn *rightButton;
@end

@implementation NvEditBGBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //底部应用按钮 Bottom apply button
        self.applyButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvcheck - material")];
        self.applyButton.backgroundColor = [UIColor clearColor];
        [self addSubview:self.applyButton];
        [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
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
        [self.applyButton addTarget:self action:@selector(applyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *bottomLine = [UIView new];
        bottomLine.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
        [self addSubview:bottomLine];
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.height.equalTo(@1);
            make.bottom.equalTo(self.applyButton.mas_top).offset(-12*SCREENSCALE);
        }];
        
        //上方三个按钮 Top three buttons
        self.centerButton = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"CanvasStyle", @"画布样式") withImageNormal:@"Nv_edit_canvasStyle" withImageSelected:@"in_animation"];
        self.centerButton.tag = 1;
        self.centerButton.btnLabel.numberOfLines = 2;
        [self.centerButton setCustomImageSize:CGSizeMake(17.5*SCREENSCALE, 17.5*SCREENSCALE) offset:7.5*SCREENSCALE];
        [self.centerButton setCustomFontSize:10];
        [self.centerButton setAlpha:0.8];
        [self addSubview:self.centerButton];
        [self.centerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.width.equalTo(@(64*SCREENSCALE));
            make.height.equalTo(@(63*SCREENSCALE));
            make.bottom.equalTo(self.applyButton.mas_top).offset(-10*SCREENSCALE);
        }];
        
        self.leftButton = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"CanvasColor", @"画布颜色") withImageNormal:@"Nv_edit_canvasColor" withImageSelected:@"Nv_edit_canvasColor"];
        self.leftButton.tag = 0;
        self.leftButton.btnLabel.numberOfLines = 2;
        [self.leftButton setCustomImageSize:CGSizeMake(17.5*SCREENSCALE, 17.5*SCREENSCALE) offset:7.5*SCREENSCALE];
        [self.leftButton setCustomFontSize:10];
        [self.leftButton setAlpha:0.8];
        [self addSubview:self.leftButton];
        [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.centerButton.mas_left).offset(-30*SCREENSCALE);
            make.width.equalTo(@(64*SCREENSCALE));
            make.height.equalTo(@(63*SCREENSCALE));
            make.bottom.equalTo(self.applyButton.mas_top).offset(-10*SCREENSCALE);
        }];

        self.rightButton = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"CanvasBlur", @"画布模糊") withImageNormal:@"Nv_edit_canvasBlur" withImageSelected:@"Nv_edit_canvasBlur"];
        self.rightButton.tag = 2;
        self.rightButton.btnLabel.numberOfLines = 2;
        [self.rightButton setCustomImageSize:CGSizeMake(17.5*SCREENSCALE, 17.5*SCREENSCALE) offset:7.5*SCREENSCALE];
        [self.rightButton setCustomFontSize:10];
        [self.rightButton setAlpha:0.8];
        [self addSubview:self.rightButton];
        [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.centerButton.mas_right).offset(30*SCREENSCALE);
            make.width.equalTo(@(64*SCREENSCALE));
            make.height.equalTo(@(63*SCREENSCALE));
            make.bottom.equalTo(self.applyButton.mas_top).offset(-10*SCREENSCALE);
        }];
        
        [self.leftButton addTarget:self action:@selector(canvasButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.centerButton addTarget:self action:@selector(canvasButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.rightButton addTarget:self action:@selector(canvasButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

//完成按钮点击方法 Complete the button click method
- (void)applyButtonClicked:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(nvEditBGBottomView:applyButtonClicked:)]) {
        [self.delegate nvEditBGBottomView:self applyButtonClicked:button];
    }
}

- (void)canvasButtonClicked:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(nvEditBGBottomView:canvasCategory:)]) {
        NSInteger index = button.tag;
        [self.delegate nvEditBGBottomView:self canvasCategory:index];
    }
}

@end
