//
//  NvPositionListView.m
//  SDKDemo
//
//  Created by Meicam on 2018/6/6.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvPositionListView.h"
#import "NVHeader.h"

@interface NvPositionListView()
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIView *line;
@end

@implementation NvPositionListView

- (void)dealloc {

}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        _containFinishButton = NO;
        self.leftButton = [UIButton nv_buttonWithTitle:@"" textColor:nil fontSize:-1 image:NvImageNamed(@"NvLeftButton")];
        self.rightButton = [UIButton nv_buttonWithTitle:@"" textColor:nil fontSize:-1 image:NvImageNamed(@"NvRightButton")];
        self.upButton = [UIButton nv_buttonWithTitle:@"" textColor:nil fontSize:-1 image:NvImageNamed(@"NvUpButton")];
        self.downButton = [UIButton nv_buttonWithTitle:@"" textColor:nil fontSize:-1 image:NvImageNamed(@"NvDownButton")];
        self.verticalButton = [UIButton nv_buttonWithTitle:@"" textColor:nil fontSize:-1 image:NvImageNamed(@"NvVerticalButton")];
        self.horizontalButton = [UIButton nv_buttonWithTitle:@"" textColor:nil fontSize:-1 image:NvImageNamed(@"NvHorizontalButton")];
        [self addSubview:self.leftButton];
        [self addSubview:self.rightButton];
        [self addSubview:self.upButton];
        [self addSubview:self.downButton];
        [self addSubview:self.verticalButton];
        [self addSubview:self.horizontalButton];
        [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(60*SCREENSCALE));
            make.top.equalTo(@(19*SCREENSCALEHEIGHT));
            make.width.equalTo(@(38*SCREENSCALE));
            make.height.equalTo(@(23*SCREENSCALE));
        }];
        [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-60*SCREENSCALE));
            make.top.equalTo(@(19*SCREENSCALEHEIGHT));
            make.width.equalTo(@(38*SCREENSCALE));
            make.height.equalTo(@(23*SCREENSCALE));
        }];
        [self.verticalButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(19*SCREENSCALEHEIGHT));
            make.centerX.equalTo(self);
            make.width.equalTo(@(38*SCREENSCALE));
            make.height.equalTo(@(23*SCREENSCALE));
        }];
        [self.upButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(60*SCREENSCALE));
            make.top.equalTo(self.leftButton.mas_bottom).offset(17*SCREENSCALEHEIGHT);
            make.width.equalTo(@(38*SCREENSCALE));
            make.height.equalTo(@(23*SCREENSCALE));
        }];
        [self.horizontalButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.leftButton.mas_bottom).offset(17*SCREENSCALEHEIGHT);
            make.width.equalTo(@(38*SCREENSCALE));
            make.height.equalTo(@(23*SCREENSCALE));
        }];
        [self.downButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-60*SCREENSCALE));
            make.top.equalTo(self.leftButton.mas_bottom).offset(17*SCREENSCALEHEIGHT);
            make.width.equalTo(@(38*SCREENSCALE));
            make.height.equalTo(@(23*SCREENSCALE));
        }];
        __weak typeof(self)weakSelf = self;
        [self.leftButton nv_BtnClickHandler:^{
            weakSelf.type = NvCaptionTextAlignmentLeft;
            if ([weakSelf.delegate respondsToSelector:@selector(applyPositionWithType:)]) {
                [weakSelf.delegate applyPositionWithType:weakSelf.type];
            }
        }];
        [self.rightButton nv_BtnClickHandler:^{
            weakSelf.type = NvCaptionTextAlignmentRight;
            if ([weakSelf.delegate respondsToSelector:@selector(applyPositionWithType:)]) {
                [weakSelf.delegate applyPositionWithType:weakSelf.type];
            }
        }];
        [self.upButton nv_BtnClickHandler:^{
            weakSelf.type = NvCaptionTextAlignmentUp;
            if ([weakSelf.delegate respondsToSelector:@selector(applyPositionWithType:)]) {
                [weakSelf.delegate applyPositionWithType:weakSelf.type];
            }
        }];
        [self.downButton nv_BtnClickHandler:^{
            weakSelf.type = NvCaptionTextAlignmentDown;
            if ([weakSelf.delegate respondsToSelector:@selector(applyPositionWithType:)]) {
                [weakSelf.delegate applyPositionWithType:weakSelf.type];
            }
        }];
        [self.verticalButton nv_BtnClickHandler:^{
            weakSelf.type = NvCaptionTextAlignmentVertical;
            if ([weakSelf.delegate respondsToSelector:@selector(applyPositionWithType:)]) {
                [weakSelf.delegate applyPositionWithType:weakSelf.type];
            }
        }];
        [self.horizontalButton nv_BtnClickHandler:^{
            weakSelf.type = NvCaptionTextAlignmentHorizontal;
            if ([weakSelf.delegate respondsToSelector:@selector(applyPositionWithType:)]) {
                [weakSelf.delegate applyPositionWithType:weakSelf.type];
            }
        }];
        
        self.applyButton = [NvButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"NvNoApplyAll")];
        [self.applyButton setImage:NvImageNamed(@"NvApplyAll") forState:UIControlStateSelected];
        self.styleApplyLabel = [UILabel nv_labelWithText:NvLocalString(@"Apply all Position", @"将样式应用到所有字幕") fontSize:10 textColor:[UIColor whiteColor]];
        self.styleApplyLabel.font = [NvUtils regularFontWithSize:10];
        self.styleApplyLabel.alpha = 0.8;
        [self.applyButton nv_BtnClickHandler:^{
            weakSelf.applyButton.selected = !weakSelf.applyButton.selected;
            if (weakSelf.applyButton.selected) {
                weakSelf.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
            } else {
                weakSelf.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
            }
            if ([weakSelf.delegate respondsToSelector:@selector(applyPositionToAllCaption:)]) {
                [weakSelf.delegate applyPositionToAllCaption:weakSelf.applyButton.selected];
            }
        }];
        
        [self addSubview:self.applyButton];
        [self addSubview:self.styleApplyLabel];
        
        [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(13*SCREENSCALE));
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-36*SCREENSCALE);
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(self.mas_bottom).offset(-36*SCREENSCALE);
            }
            make.width.height.equalTo(@(15*SCREENSCALE));
        }];
        [self.styleApplyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.applyButton.mas_centerY);
            make.left.equalTo(self.applyButton.mas_right).offset(7*SCREENSCALE);
        }];
    }
    return self;
}

- (void)resetApplyButton {
    self.type = None;
    self.applyButton.selected = NO;
    self.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(SCREENWIDTH, 87*SCREENSCALE);
}

- (void)setContainFinishButton:(BOOL)containFinishButton {
    _containFinishButton = containFinishButton;
    if (containFinishButton) {
        [self remakeupSubviews];
    }
}

- (void)remakeupSubviews {
    self.okButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvcheck - material")];
    [self addSubview:self.okButton];
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@(25*SCREENSCALEHEIGHT));
        make.height.equalTo(@(20*SCREENSCALEHEIGHT));
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALEHEIGHT);
        } else {
            make.bottom.equalTo(@(-15*SCREENSCALEHEIGHT));
        }
    }];
    __weak typeof(self)weakSelf = self;
    [self.okButton nv_BtnClickHandler:^{
        if ([weakSelf.delegate respondsToSelector:@selector(okClick)]) {
            [weakSelf.delegate okClick];
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
    
    [self.applyButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(13*SCREENSCALE));
        make.bottom.equalTo(self.line).offset(-20*SCREENSCALE);
        make.width.height.equalTo(@(15*SCREENSCALE));
    }];
    [self.styleApplyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.applyButton.mas_centerY);
        make.left.equalTo(self.applyButton.mas_right).offset(7*SCREENSCALE);
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
