//
//  NvLivePushConfigView.m
//  MeicamLive
//
//  Created by ms20180425 on 2020/3/16.
//  Copyright © 2020 ms20180425. All rights reserved.
//

#import "NvLivePushConfigView.h"
#import "UIColor+NvLiveColor.h"
#import "NvLiveAppEnv.h"
#import "Masonry.h"
#import "NvLiveARSceneUtils.h"
#import "NvLiveUserView.h"

@interface NvLivePushConfigView()

@property (nonatomic, strong) UIButton *switchBtn;

@property (nonatomic, strong) UIButton *liveBtn;

@end

@implementation NvLivePushConfigView

-(void)dealloc{
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addMainView];
        [self addMainBottomView];
    }
    return self;
}

- (void)addMainView{
    UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [exitBtn setImage:[NvLiveARSceneUtils imageNamed:@"MSExit"] forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(exitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:exitBtn];
    [exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.width.height.offset(20 * NvScreen(kScale));
    }];
    
    NvLiveUserView *userView = [[NvLiveUserView alloc]init];
    [self addSubview:userView];
    [userView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(exitBtn);
        make.left.equalTo(exitBtn.mas_right).offset(10 * NvScreen(kScale));
        make.height.offset(44 * NvScreen(kScale));
        make.width.offset(150 * NvScreen(kScale));
    }];
    
    self.switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.switchBtn setImage:[NvLiveARSceneUtils imageNamed:@"MSSwitch"] forState:UIControlStateNormal];
    [self.switchBtn addTarget:self action:@selector(switchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.switchBtn];
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.centerY.equalTo(exitBtn);
        make.width.height.offset(30 * NvScreen(kScale));
    }];
}

- (void)addMainBottomView{
    self.liveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.liveBtn.layer.masksToBounds = YES;
    self.liveBtn.layer.cornerRadius = 22 * NvScreen(kScale);
    [self.liveBtn addTarget:self action:@selector(liveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.liveBtn];
    [self.liveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.offset(44 * NvScreen(kScale));
    }];
    
    [self.liveBtn layoutIfNeeded];
    [NvLiveAppEnv gradientView:self.liveBtn withColors:@[(__bridge id)[UIColor nv_colorWithHexRGB:@"#9F7CFF"].CGColor,
                                                (__bridge id)[UIColor nv_colorWithHexRGB:@"#5784FF"].CGColor]];
    
    UILabel *startLabel = UILabel.new;
    startLabel.text = NvLocalString(@"Start live", @"开始直播");
    startLabel.font = [UIFont systemFontOfSize:18];
    startLabel.textColor = UIColor.whiteColor;
    [self.liveBtn addSubview:startLabel];
    [startLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.liveBtn);
    }];
}

#pragma mark 是否隐藏界面
- (void)interfaceisHidden:(BOOL)hidden{
    self.liveBtn.hidden = hidden;
    self.switchBtn.hidden = hidden;
}

#pragma mark 开始直播点击事件
- (void)liveBtnClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(start)]) {
        [self.delegate start];
        [self interfaceisHidden:YES];
    }
}

#pragma mark 美颜点击事件
- (void)beautifulBtnClick{
    [self interfaceisHidden:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(beauty)]) {
        [self.delegate beauty];
    }
}

#pragma mark 切换摄像头
- (void)switchBtnClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchCamera)]) {
        [self.delegate switchCamera];
    }
}

#pragma mark 退出
- (void)exitBtnClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(exit)]) {
        [self.delegate exit];
        [self removeFromSuperview];
    }
}

@end
