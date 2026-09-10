//
//  NvOriginSoundView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/16.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvOriginSoundView.h"
#import "NVHeader.h"

@interface NvOriginSoundView () {
    int maxSound;///最大音量倍数 Maximum volume multiple
}

@property (nonatomic, strong) UILabel *originSoundLabel;
@property (nonatomic, strong) UISlider *originSoundSlider;
@property (nonatomic, strong) UILabel *originSoundNumLabel;
@property (nonatomic, strong) UILabel *musicSoundLabel;
@property (nonatomic, strong) UISlider *musicSoundSlider;
@property (nonatomic, strong) UILabel *musicSoundNumLabel;
@property (nonatomic, strong) UILabel *dubbingLabel;
@property (nonatomic, strong) UISlider *dubbingSlider;
@property (nonatomic, strong) UILabel *dubbingNumLabel;
@property (nonatomic, strong) UIButton *applyButton;

@end

@implementation NvOriginSoundView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        maxSound = 4;
        self.originSoundLabel = [UILabel nv_labelWithText:NvLocalString(@"Origin", @"原声") fontSize:15 textColor:UIColor.whiteColor];
        self.musicSoundLabel = [UILabel nv_labelWithText:NvLocalString(@"Music", @"音乐") fontSize:15 textColor:UIColor.whiteColor];
        self.dubbingLabel = [UILabel nv_labelWithText:NvLocalString(@"Dubbing", @"配音") fontSize:15 textColor:UIColor.whiteColor];
        self.originSoundNumLabel = [UILabel nv_labelWithText:@"0" fontSize:15 textColor:UIColor.whiteColor];
        self.musicSoundNumLabel = [UILabel nv_labelWithText:@"0" fontSize:15 textColor:UIColor.whiteColor];
        self.dubbingNumLabel = [UILabel nv_labelWithText:@"0" fontSize:15 textColor:UIColor.whiteColor];
        self.originSoundSlider = [[UISlider alloc] init];
        self.originSoundSlider.minimumTrackTintColor = [UIColor whiteColor];
        [self.originSoundSlider setThumbImage:NvImageNamed(@"NvVolum30") forState:UIControlStateNormal];
        self.originSoundSlider.maximumValue = 100;
        self.musicSoundSlider = [[UISlider alloc] init];
        self.musicSoundSlider.minimumTrackTintColor = [UIColor whiteColor];
        [self.musicSoundSlider setThumbImage:NvImageNamed(@"NvVolum30") forState:UIControlStateNormal];
        self.musicSoundSlider.maximumValue = 100;
        self.dubbingSlider = [[UISlider alloc] init];
//        self.dubbingSlider.enabled = NO;
        self.dubbingSlider.minimumTrackTintColor = UIColor.whiteColor;
        [self.dubbingSlider setThumbImage:NvImageNamed(@"NvVolum30") forState:UIControlStateNormal];
        self.dubbingSlider.maximumValue = 100;
        self.applyButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvcheck - material")];
        
        [self.originSoundSlider addTarget:self action:@selector(originSoundChanged:) forControlEvents:UIControlEventValueChanged];
        [self.musicSoundSlider addTarget:self action:@selector(musicSoundChanged:) forControlEvents:UIControlEventValueChanged];
        [self.dubbingSlider addTarget:self action:@selector(dubbingChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.originSoundLabel];
        [self addSubview:self.musicSoundLabel];
        [self addSubview:self.dubbingLabel];
        [self addSubview:self.originSoundNumLabel];
        [self addSubview:self.musicSoundNumLabel];
        [self addSubview:self.dubbingNumLabel];
        [self addSubview:self.originSoundSlider];
        [self addSubview:self.musicSoundSlider];
        [self addSubview:self.dubbingSlider];
        [self addSubview:self.applyButton];
        
        [self.originSoundLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(31*SCREENSCALE));
            make.left.equalTo(@(12*SCREENSCALE));
            make.height.equalTo(@(21*SCREENSCALE));
        }];
        [self.musicSoundLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.originSoundLabel.mas_bottom).offset(20*SCREENSCALE);
            make.left.equalTo(@(12*SCREENSCALE));
            make.height.equalTo(@(21*SCREENSCALE));
            make.width.equalTo(self.originSoundLabel.mas_width);
        }];
        [self.dubbingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.musicSoundLabel.mas_bottom).offset(20*SCREENSCALE);
            make.left.equalTo(@(12*SCREENSCALE));
            make.height.equalTo(@(21*SCREENSCALE));
            make.width.equalTo(self.originSoundLabel.mas_width);
        }];
        
        [self.originSoundNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.originSoundLabel);
            make.right.equalTo(@(-12*SCREENSCALE));
            make.height.equalTo(@(21*SCREENSCALE));
        }];
        [self.musicSoundNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.musicSoundLabel);
            make.right.equalTo(@(-12*SCREENSCALE));
            make.height.equalTo(@(21*SCREENSCALE));
        }];
        [self.dubbingNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.dubbingLabel);
            make.right.equalTo(@(-12*SCREENSCALE));
            make.height.equalTo(@(21*SCREENSCALE));
        }];
        
        [self.originSoundSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.originSoundLabel);
            make.left.equalTo(self.originSoundLabel.mas_right).offset(21*SCREENSCALE);
            make.height.equalTo(@(21*SCREENSCALE));
            make.right.equalTo(self.originSoundNumLabel.mas_left).offset(-12*SCREENSCALE);
        }];
        [self.musicSoundSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.musicSoundLabel);
            make.left.equalTo(self.musicSoundLabel.mas_right).offset(21*SCREENSCALE);
            make.height.equalTo(@(21*SCREENSCALE));
            make.right.equalTo(self.musicSoundNumLabel.mas_left).offset(-12*SCREENSCALE);
        }];
        [self.dubbingSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.dubbingLabel);
            make.left.equalTo(self.dubbingLabel.mas_right).offset(21*SCREENSCALE);
            make.height.equalTo(@(21*SCREENSCALE));
            make.right.equalTo(self.dubbingNumLabel.mas_left).offset(-12*SCREENSCALE);
        }];
        __weak typeof(self)weakSelf = self;
        [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.equalTo(@(25*SCREENSCALEHEIGHT));
            make.height.equalTo(@(20*SCREENSCALEHEIGHT));
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALEHEIGHT);
            } else {
                make.bottom.equalTo(@(-15*SCREENSCALEHEIGHT));
            }
        }];
        
        [self.applyButton nv_BtnClickHandler:^{
            if ([weakSelf.delegate respondsToSelector:@selector(applyClick:)]) {
                [weakSelf.delegate applyClick:weakSelf];
            }
        }];
    }
    return self;
}

- (void)setOriginSound:(float)originSound musicSound:(float)musicSound dubbing:(float)dubbing {
    self.originSoundSlider.value = originSound/8.0*100;
    self.musicSoundSlider.value = musicSound/8.0*100;
    self.dubbingSlider.value = dubbing/8.0*100;
    self.originSoundNumLabel.text = [NSString stringWithFormat:@"%d",(int)originSound*100/8];
    self.musicSoundNumLabel.text = [NSString stringWithFormat:@"%d",(int)musicSound*100/8];
    self.dubbingNumLabel.text = [NSString stringWithFormat:@"%d",(int)dubbing*100/8];
}

- (void)originSoundChanged:(UISlider *)slider {
    self.originSoundNumLabel.text = [NSString stringWithFormat:@"%d",(int)slider.value];
    if ([self.delegate respondsToSelector:@selector(originSoundView:originSound:)]) {
        [self.delegate originSoundView:self originSound:slider.value/100.0*8];
    }
}

- (void)musicSoundChanged:(UISlider *)slider {
    self.musicSoundNumLabel.text = [NSString stringWithFormat:@"%d",(int)slider.value];
    if ([self.delegate respondsToSelector:@selector(originSoundView:musicSound:)]) {
        [self.delegate originSoundView:self musicSound:slider.value/100.0*8];
    }
}

- (void)dubbingChanged:(UISlider *)slider {
    self.dubbingNumLabel.text = [NSString stringWithFormat:@"%d",(int)slider.value];
    if ([self.delegate respondsToSelector:@selector(originSoundView:dubbing:)]) {
        [self.delegate originSoundView:self dubbing:slider.value/100.0*8];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
