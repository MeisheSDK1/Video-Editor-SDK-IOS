//
//  NvNormalSpeedView.m
//  SDKDemo
//
//  Created by MS on 2020/11/30.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvNormalSpeedView.h"
#import "NVHeader.h"
#import "CLSlider.h"
@interface NvNormalSpeedView ()<CLSliderDelegate>
@property (nonatomic, strong) UIButton *audioButton;
///速度滑杆
///Speed slide
@property (nonatomic, strong) CLSlider *mSlider;
@end
@implementation NvNormalSpeedView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = UIColorFromRGB(0x242728);
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    UIButton *finsh = [UIButton buttonWithType:UIButtonTypeCustom];
    [finsh setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [finsh addTarget:self action:@selector(finshClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:finsh];
    [finsh mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@(25*SCREENSCALEHEIGHT));
        make.height.equalTo(@(25*SCREENSCALE));
        make.bottom.equalTo(@(-10*SCREENSCALE));
    }];
    
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(finsh.mas_top).offset(-12*SCREENSCALE);
    }];
    
    self.audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.audioButton setTitle:NvLocalString(@"Change audioPitch",@"变速变调") forState:UIControlStateNormal];
    [self.audioButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.audioButton addTarget:self action:@selector(audioButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.audioButton.titleLabel.font = [UIFont systemFontOfSize:10*SCREENSCALE];
    [self.audioButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.audioButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.audioButton setImage:NvImageNamed(@"nv_keep_audioPitch") forState:UIControlStateNormal];
    [self.audioButton setImage:NvImageNamed(@"nv_change_audioPitch") forState:UIControlStateSelected];
    self.audioButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [self addSubview:self.audioButton];
    [self.audioButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(13*SCREENSCALE);
        make.centerY.equalTo(finsh.mas_centerY);
        make.height.mas_equalTo(finsh.mas_height);
        make.width.mas_lessThanOrEqualTo(100*SCREENSCALE);
    }];
    
    UILabel *infoLabel = [[UILabel alloc] init];
    [self addSubview:infoLabel];
    infoLabel.textColor = [UIColor whiteColor];
    infoLabel.text = NvLocalString(@"Slide to adjust speed", @"滑动以调整速度");
    infoLabel.font = [UIFont systemFontOfSize:10*SCREENSCALE];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:infoLabel];
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(line.mas_top).offset(-120*SCREENSCALE);
        make.height.mas_equalTo(15*SCREENSCALE);
        make.left.right.equalTo(self);
    }];
    
    self.mSlider = [CLSlider new];
    self.mSlider.sliderStyle = CLSliderStyle_Cross;
    self.mSlider.thumbDiameter = 13;
    self.mSlider.scaleLineColor = [UIColor nv_colorWithHexString:@"#707070"];
    self.mSlider.scaleLineWidth = 3;
    self.mSlider.scaleLineHeight = 4;
    self.mSlider.scaleLineNumber = 5;
    [self.mSlider setSelectedIndex:0];
    self.mSlider.delegate = self;
    [self addSubview:self.mSlider];
    [self.mSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(250 * SCREENSCALE);
        make.height.mas_equalTo(30 * SCREENSCALE);
        make.bottom.mas_equalTo(line.mas_top).offset(-57*SCREENSCALE);
    }];
    CGFloat labelWidth = (250 * SCREENSCALE - self.mSlider.thumbDiameter)/5;
    self.mSlider.titleLayerWidth = labelWidth;
    for (int i = 0; i<6; i++) {
        UILabel *lable = [[UILabel alloc] init];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.textColor = [UIColor nv_colorWithHexString:@"#707070"];
        lable.alpha = 0.8;
        lable.font = [NvUtils fontWithSize:10 * SCREENSCALE];
        [self addSubview:lable];
        
        [lable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mSlider.mas_bottom).offset(2.5*SCREENSCALE);
            make.left.equalTo(self.mSlider.mas_left).offset(self.mSlider.thumbDiameter/2 + i*labelWidth - labelWidth/2);
            make.width.mas_equalTo(labelWidth);
            make.height.mas_equalTo(20*SCREENSCALE);
        }];
        switch (i) {
            case 0:
                lable.text = @"0.1X";
                break;
            case 1:
                lable.text = @"1X";
                break;
            case 2:
                lable.text = @"2X";
                break;
            case 3:
                lable.text = @"5X";
                break;
            case 4:
                lable.text = @"10X";
                break;
            case 5:
                lable.text = @"100X";
                break;
            default:
                break;
        }
    }
}

- (void)finshClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(nvFinishNormalSpeedView:)]) {
        [self.delegate nvFinishNormalSpeedView:self];
    }
}

- (void)audioButtonClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    _keepAudioPitch = !sender.selected;
    
    if ([self.delegate respondsToSelector:@selector(nvNormalSpeedView:keepAudioPitch:)]) {
        [self.delegate nvNormalSpeedView:self keepAudioPitch:_keepAudioPitch];
    }
}

- (void)clSlider:(CLSlider *)slider selectRatio:(CGFloat)ratio {
    ///分段计算具体speed
    ///Calculate the specific speed in sections
    CGFloat minusRatio = 0.f;;
    CGFloat segMinSpeed = 0.f;
    CGFloat segMaxSpeed = 0.f;
    if (ratio<=1/5.0) {
        segMinSpeed = 0.1;
        segMaxSpeed = 1.0;
        minusRatio = 0;
    }else if (ratio<=2/5.0) {
        segMinSpeed = 1.0;
        segMaxSpeed = 2.0;
        minusRatio = 0.2;
    }else if (ratio<=3/5.0) {
        segMinSpeed = 2.0;
        segMaxSpeed = 5.0;
        minusRatio = 0.4;
    }else if (ratio<=4/5.0) {
        segMinSpeed = 5.0;
        segMaxSpeed = 10.0;
        minusRatio = 0.6;
    }else if (ratio<=1.0) {
        segMinSpeed = 10.0;
        segMaxSpeed = 100.0;
        minusRatio = 0.8;
    }

    if ([NvUtils convertValue:ratio - minusRatio pointNum:3] > 0.2) {
        NSLog(@"速度比例计算错误!! Speed ratio calculation error ratio%f   minusRatio%f++seg max%f  min%f",ratio,minusRatio,segMaxSpeed,segMinSpeed);
        return;
    }
    CGFloat finalSpeed = [NvUtils convertValue:(([NvUtils convertValue:ratio pointNum:3] - [NvUtils convertValue:minusRatio pointNum:3])*5.0*([NvUtils convertValue:segMaxSpeed pointNum:3] - [NvUtils convertValue:segMinSpeed pointNum:3]) + segMinSpeed) pointNum:3];
    if (finalSpeed <segMinSpeed || finalSpeed > segMaxSpeed) {
        NSLog(@"速度计算错误!! Speed calculation error ratio%f   minusRatio%f++seg max%f  min%f",ratio,minusRatio,segMaxSpeed,segMinSpeed);
        return;
    }
    [self.mSlider setText:[NSString stringWithFormat:@"%.1fX",finalSpeed]];
    
    if ([self.delegate respondsToSelector:@selector(nvNormalSpeedView:speed:)]) {
        [self.delegate nvNormalSpeedView:self speed:finalSpeed];
    }
}

- (void)clSliderEndChanged:(CLSlider *)slider {
    if ([self.delegate respondsToSelector:@selector(nvNormalSpeedViewChangedEnd:)]) {
        [self.delegate nvNormalSpeedViewChangedEnd:self];
    }
}

- (void)setSpeed:(double)speed {
    ///根据speed设置slider 滑块位置
    ///Set the slider position based on speed
    ///分段计算具体speed
    ///Calculate the specific speed in sections
    CGFloat segMinSpeed = 0.f;
    CGFloat segMaxSpeed = 0.f;
    CGFloat segMinRatio = 0.f;
    CGFloat segMaxRatio = 0.f;
    CGFloat ratio;
    if (speed>=0.1 && speed < 1.0) {
        segMinRatio = 0;
        segMaxRatio = 0.2;
        segMinSpeed = 0.1;
        segMaxSpeed = 1.0;
    }else if (speed>=1.0 && speed < 2.0) {
        segMinRatio = 0.2;
        segMaxRatio = 0.4;
        segMinSpeed = 1.0;
        segMaxSpeed = 2.0;
    }else if (speed>=2.0 && speed < 5.0) {
        segMinRatio = 0.4;
        segMaxRatio = 0.6;
        segMinSpeed = 2.0;
        segMaxSpeed = 5.0;
    }else if (speed>=5.0 && speed < 10.0) {
        segMinRatio = 0.6;
        segMaxRatio = 0.8;
        segMinSpeed = 5.0;
        segMaxSpeed = 10.0;
    }else if (speed>=10.0 && speed <= 100.0) {
        segMinRatio = 0.8;
        segMaxRatio = 1.0;
        segMinSpeed = 10.0;
        segMaxSpeed = 100.0;
    }
    ///分段比例
    ///Segment ratio
    CGFloat segRatio = (speed - segMinSpeed)/(segMaxSpeed - segMinSpeed)*0.2;
    ///真实比例
    ///True proportion
    ratio = segRatio + segMinRatio;
    [self.mSlider setThumbRatio:ratio];
}

- (void)setKeepAudioPitch:(BOOL)keepAudioPitch {
    _keepAudioPitch = keepAudioPitch;
    self.audioButton.selected = !keepAudioPitch;
}
@end
