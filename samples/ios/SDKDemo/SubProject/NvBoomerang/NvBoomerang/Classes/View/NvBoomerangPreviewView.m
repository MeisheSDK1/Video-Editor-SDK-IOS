//
//  NvBoomerangPreviewView.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/12/19.
//  Copyright © 2018 meishe. All rights reserved.
//

#import "NvBoomerangPreviewView.h"
#import <NvStreamingSdkCore/NvsLiveWindow.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvBaseCommon/UIColor+NvColor.h>
#import <Masonry/Masonry.h>
#import <NvStreamingSdkCore/NvsStreamingContext.h>

@implementation NvBoomerangPreviewView {
    UIButton *backBtn;
    UIButton *exportBtn;
    UIView *progressView;
    UIActivityIndicatorView *indicator;
    UILabel *generatingLabel;
    UILabel *tipLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self initView:frame];
    self.status = NV_NOT_BEGIN;
    return self;
}

- (void)initView:(CGRect)frame {
    self.liveWindow = [[NvsLiveWindow alloc] initWithFrame:frame];
    [self addSubview:self.liveWindow];
    NvsStreamingContext *context = [NvsStreamingContext sharedInstance];
    [context connectCapturePreviewWithLiveWindow:self.liveWindow];
    
    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:backBtn];
    [backBtn setImage:NvImageNamedForBundle(@"Nvback",NvCurrentBundle) forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(NV_STATUSBARHEIGHT);
        make.left.equalTo(self).offset(13 * SCREENSCALE);
        make.width.offset(33 * SCREENSCALE);
        make.height.offset(33 * SCREENSCALE);
    }];
    
    exportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:exportBtn];
    [exportBtn setImage:NvImageNamedForBundle(@"NvBoomerangExport",NvCurrentBundle) forState:UIControlStateNormal];
    [exportBtn addTarget:self action:@selector(exportBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [exportBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(NV_STATUSBARHEIGHT+5*SCREENSCALE);
        make.right.equalTo(self).offset(-13 * SCREENSCALE);
        make.width.offset(16 * SCREENSCALE);
        make.height.offset(16 * SCREENSCALE);
    }];
    
    progressView = [UIView new];
    [self addSubview:progressView];
    progressView.backgroundColor = [UIColor nv_colorWithHexRGBA:@"#00000099"];
    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
    }];
    progressView.hidden = YES;
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [progressView addSubview:indicator];
    [indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(10 * SCREENSCALE);
    }];
    
    generatingLabel = UILabel.new;
    [progressView addSubview:generatingLabel];
    [generatingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self->indicator.mas_bottom).offset(10 * SCREENSCALE);
    }];
    generatingLabel.textColor = [UIColor nv_colorWithHexRGBA:@"#ffffff99"];
    generatingLabel.text = NvLocalStringFromTable([self class], @"Generated", @"生成中");
    
    tipLabel = UILabel.new;
    [progressView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(@(112 * SCREENSCALE));
        make.height.equalTo(@(45 * SCREENSCALE));
    }];
    tipLabel.textColor = [UIColor nv_colorWithHexRGBA:@"#ffffff99"];
    tipLabel.numberOfLines = 0;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = NvLocalStringFromTable([self class], @"Generated complete", @"请在相册中查看");
}

- (void)backBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(backBtnClick)]) {
        [self.delegate backBtnClick];
    }
}

- (void)exportBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(exportBtnClick)]) {
        [self.delegate exportBtnClick];
    }
}

- (void)setStatus:(NvGenerateStatus)status {
    _status = status;
    if (status == NV_NOT_BEGIN) {
        progressView.hidden = YES;
    } else if (status == NV_GENERATING) {
        progressView.hidden = NO;
        indicator.hidden = NO;
        generatingLabel.hidden = NO;
        tipLabel.hidden = YES;
        [indicator startAnimating];
    } else if (status == NV_GENERATED) {
        progressView.hidden = NO;
        indicator.hidden = YES;
        generatingLabel.hidden = YES;
        tipLabel.hidden = NO;
        [indicator stopAnimating];
        NSTimer *timer = [NSTimer timerWithTimeInterval:.5 target:self selector:@selector(resetStatus) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

- (void)resetStatus {
    progressView.hidden = YES;
    _status = NV_NOT_BEGIN;
}

@end
