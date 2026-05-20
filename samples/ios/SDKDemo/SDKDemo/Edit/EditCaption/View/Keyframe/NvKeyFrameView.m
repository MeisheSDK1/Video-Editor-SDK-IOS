//
//  NvKeyFrameView.m
//  SDKDemo
//
//  Created by chengww on 2020/8/21.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvKeyFrameView.h"
#import "NvGraphicBtn.h"
#import <NvSDKCommon/NvUtils.h>
#import "NVHeader.h"

@interface NvKeyFrameView ()
@property (nonatomic, strong) NvGraphicBtn *preButton;
@property (nonatomic, strong) NvGraphicBtn *nextButton;
@property (nonatomic, strong) NvGraphicBtn *optButton;
@property (nonatomic, strong) UIButton *finishBtn;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, assign) CGSize viewSize;
@end

@implementation NvKeyFrameView
- (instancetype)init {
    if (self = [super init]) {
        self.viewSize = CGSizeZero;
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        [self addSubview:self.finishBtn];
        [self addSubview:self.lineView];
        [self addSubview:self.optButton];
        [self addSubview:self.preButton];
        [self addSubview:self.nextButton];
    }
    return self;
}

- (void)nvAddCaptionViewTouchEvent:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nvKeyFrameView:didReceive:)]) {
        [self.delegate nvKeyFrameView:self didReceive:sender.tag];
    }
}

- (void)nvAddCaptionViewFinishEvent:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nvKeyFrameViewDidFinished:)]) {
        [self.delegate nvKeyFrameViewDidFinished:self];
    }
}
- (void)resetOptKeyFrameButton:(BOOL)isDelete {
    if (!isDelete) {
        self.optButton.btnLabel.text = NvLocalString(@"Add frame", @"添加帧");
        self.optButton.btnImageView.image = [UIImage imageNamed:@"nv_edit_addFrame"];
        self.optButton.tag = 2;
    }else {
        self.optButton.btnLabel.text = NvLocalString(@"Delete frame", @"删除帧");
        self.optButton.btnImageView.image = [UIImage imageNamed:@"nv_edit_deleteFrame"];
        self.optButton.tag = 3;
    }
}

- (void)nv_fadeIn:(UIView *)onView {
    self.viewSize = onView.frame.size;
    self.frame = CGRectMake(0, self.viewSize.height, self.viewSize.width, 110 * SCREENSCALE + INDICATOR);
    [onView addSubview:self];
    [onView bringSubviewToFront:self];
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(0, self.viewSize.height - 110 * SCREENSCALE - INDICATOR, self.viewSize.width, 110 * SCREENSCALE + INDICATOR);
    } completion:^(BOOL finished) {
    }];
}

- (void)nv_fadeOut {
    [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        self.frame = CGRectMake(0, self.viewSize.height, self.viewSize.width, 104 * SCREENSCALE + INDICATOR);
    } completion:^(BOOL finished) {
        self.viewSize = CGSizeZero;
        [self removeFromSuperview];
    }];
}

#pragma mark - Setter
- (void)setEnablePrebutton:(BOOL)enablePrebutton {
    _enablePrebutton = enablePrebutton;
    self.preButton.enabled = enablePrebutton;
    self.preButton.alpha   = enablePrebutton ? 1.0 : 0.5;
}
- (void)setEnableNextbutton:(BOOL)enableNextbutton {
    _enableNextbutton = enableNextbutton;
    self.nextButton.enabled = enableNextbutton;
    self.nextButton.alpha   = enableNextbutton ? 1.0 : 0.5;
}
- (void)setEnableAddbutton:(BOOL)enableAddbutton {
    _enableAddbutton = enableAddbutton;
    self.optButton.enabled = enableAddbutton;
    self.optButton.alpha   = enableAddbutton ? 1.0 : 0.5;
}

#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@(25*SCREENSCALEHEIGHT));
        make.height.equalTo(@(20*SCREENSCALE));
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
        } else {
            make.bottom.equalTo(@(-15*SCREENSCALE));
        }
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(self.finishBtn.mas_top).offset(-12 * SCREENSCALE);
    }];
    [self.optButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.height.equalTo(@(43 * SCREENSCALE));
        make.width.equalTo(@(74 * SCREENSCALE));
        make.bottom.equalTo(self.finishBtn.mas_top).offset(-22 * SCREENSCALE);
    }];
    [self.preButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.height.width.equalTo(self.optButton);
        make.right.equalTo(self.optButton.mas_left).mas_offset(-5 * SCREENSCALE);
    }];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.height.width.equalTo(self.optButton);
        make.left.equalTo(self.optButton.mas_right).mas_offset(5 * SCREENSCALE);
    }];
}
#pragma mark - LAZY
- (UIButton *)finishBtn {
    if (!_finishBtn) {
        _finishBtn = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvcheck - material")];
        [_finishBtn addTarget:self action:@selector(nvAddCaptionViewFinishEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishBtn;
}
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    }
    return _lineView;
}
- (NvGraphicBtn *)preButton {
    if (!_preButton) {
        _preButton = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Previous frame", @"上一帧") withImageNormal:@"nv_edit_preFrame" withImageSelected:nil];
        [_preButton setCustomImageSize:CGSizeMake(14*SCREENSCALE, 20*SCREENSCALE) offset:7.5*SCREENSCALE];
        _preButton.btnLabel.font = [UIFont systemFontOfSize:8*SCREENSCALE];
        _preButton.showsTouchWhenHighlighted = NO;
        _preButton.tag = 0;
        [_preButton addTarget:self action:@selector(nvAddCaptionViewTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _preButton;
}
- (NvGraphicBtn *)nextButton {
    if (!_nextButton) {
        _nextButton = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Next frame", @"下一帧") withImageNormal:@"nv_edit_nextFrame" withImageSelected:nil];
        [_nextButton setCustomImageSize:CGSizeMake(14*SCREENSCALE, 20*SCREENSCALE) offset:7.5*SCREENSCALE];
        _nextButton.btnLabel.font = [UIFont systemFontOfSize:8*SCREENSCALE];
        _nextButton.showsTouchWhenHighlighted = NO;
        _nextButton.tag = 1;
        [_nextButton addTarget:self action:@selector(nvAddCaptionViewTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}
- (NvGraphicBtn *)optButton {
    if (!_optButton) {
        _optButton = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Add key frame", @"增加关键帧") withImageNormal:@"nv_edit_addFrame" withImageSelected:nil];
        [_optButton setCustomImageSize:CGSizeMake(14*SCREENSCALE, 20*SCREENSCALE) offset:7.5*SCREENSCALE];
        _optButton.btnLabel.font = [UIFont systemFontOfSize:8*SCREENSCALE];
        _optButton.showsTouchWhenHighlighted = NO;
        _optButton.tag = 2;
        [_optButton addTarget:self action:@selector(nvAddCaptionViewTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _optButton;
}

@end
