//
//  EFAudioOperationView.m
//  EffectSdkDemo
//
//  Created by LiYong on 2021/12/21.
//  Copyright © 2021 美摄. All rights reserved.
//

#import "EFAudioOperationView.h"
#import "EFAudioListView.h"

@interface EFAudioOperationView ()
@property (nonatomic, strong) UISlider *volumSlider;
@property (nonatomic, strong) UIButton *selectAudio;
@property (nonatomic, strong) UIButton *audioBtn;
@property (nonatomic, strong) EFAudioListView *audioListView;

@end

@implementation EFAudioOperationView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.volumSlider];
        [self addSubview:self.selectAudio];
        [self addSubview:self.audioBtn];
    }
    return self;
}
- (void)volumSliderAction:(UISlider *)sender{
    if ([self.delegate respondsToSelector:@selector(EFAudioOperationViewDelegateChangeVolum:)]) {
        [self.delegate EFAudioOperationViewDelegateChangeVolum:sender.value];
    }
}
- (void)audioAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(EFAudioOperationViewDelegateAudioPlay)] && [self.delegate respondsToSelector:@selector(EFAudioOperationViewDelegateAudioPause)]) {
        if (sender.selected) {
            [self.delegate EFAudioOperationViewDelegateAudioPlay];
        }else{
            [self.delegate EFAudioOperationViewDelegateAudioPause];
        }
    }
    sender.selected = !sender.selected;
}
- (void)selectAudioAction:(UIButton *)sender{
    [self.superview addSubview:self.audioListView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.volumSlider.frame = CGRectMake(20, 0, self.frame.size.width-2*20-2*40-2*10, 40);
    self.audioBtn.frame = CGRectMake(CGRectGetMaxX(self.volumSlider.frame)+10, 0, 40, 40);
    self.selectAudio.frame = CGRectMake(CGRectGetMaxX(self.audioBtn.frame)+10, 0, 40, 40);
    self.audioListView.frame = CGRectMake(0, self.superview.frame.size.height-176, self.frame.size.width, 176);
}
#pragma -mark
- (UISlider *)volumSlider{
    if (!_volumSlider) {
        _volumSlider = [[UISlider alloc]init];
        _volumSlider.minimumValue = 0.0;
        _volumSlider.maximumValue = 1.0;
        _volumSlider.value = 0.5;
        [_volumSlider addTarget:self action:@selector(volumSliderAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _volumSlider;
}
- (UIButton *)audioBtn{
    if (!_audioBtn) {
        _audioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_audioBtn setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
        [_audioBtn setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateSelected];
        [_audioBtn addTarget:self action:@selector(audioAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _audioBtn;;
}
- (UIButton *)selectAudio{
    if (!_selectAudio) {
        _selectAudio = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectAudio setTitle:@"choose" forState:UIControlStateNormal];
        [_selectAudio setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_selectAudio addTarget:self action:@selector(selectAudioAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectAudio;;
}
- (EFAudioListView *)audioListView{
    if (!_audioListView) {
        _audioListView = [[EFAudioListView alloc]init];
        __weak typeof(self) weakSelf = self;
        _audioListView.selectBlock = ^(NSString * path) {
            if ([weakSelf.delegate respondsToSelector:@selector(EFAudioOperationViewDelegateChangeAudioWithPath:)]) {
                [weakSelf.delegate EFAudioOperationViewDelegateChangeAudioWithPath:path];
            }
            [weakSelf.audioListView removeFromSuperview];
        };
    }
    return _audioListView;;
}
@end
