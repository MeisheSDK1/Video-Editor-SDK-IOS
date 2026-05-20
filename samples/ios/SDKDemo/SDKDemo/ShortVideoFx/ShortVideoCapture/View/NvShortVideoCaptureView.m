//
//  NvShortVideoCaptureView.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/8/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvShortVideoCaptureView.h"
#import "NvsRecordingButton.h"
#import <NvSDKCommon/NvUtils.h>
#import "UIColor+NvColor.h"
#import <Masonry/Masonry.h>
#import <NvSDKCommon/NvWeakTimer.h>

@interface NvShortVideoCaptureView ()<NvsRecordingButtonDelegate>

@property (nonatomic, strong) UIButton *shootingBtn;
@property (nonatomic, strong) UIImageView *focusImageView;
@property (nonatomic, strong) NvWeakTimer *weakTimer;
@property (nonatomic, strong) NvGraphicBtn *propsBtn;

@end

@implementation NvShortVideoCaptureView {
    
    UIButton *backBtn;
    NvGraphicBtn *cameraBtn;
    NvGraphicBtn *filterBtn;
    
    UILabel *cameraLabel;
    UILabel *flashLabel;
    UILabel *cutMusicLabel;
    UILabel *faceLabel;
    UILabel *filterLabel;
    
    UIView *_speedPanelView;
    ///极慢，0.5倍速按钮
    ///Very slow, 0.5 times speed button
    UIButton *_speed13Btn;
    ///慢，0.75倍速按钮
    ///Slow, 0.75x button
    UIButton *_speed12Btn;
    ///正常，1倍速按钮
    ///Normal, double speed button
    UIButton *_speed1Btn;
    ///快，1.5倍速按钮
    ///Fast, 1.5 times speed button
    UIButton *_speed32Btn;
    ///极快，2倍速按钮
    ///Extremely fast, 2x speed button
    UIButton *_speed3Btn;
    float _currentSpeed;
    ///表示录制倍速
    ///Indicates double the recording speed
    NSString *speedStr;
    UIImageView *selectView;
    
    NvsRecordingButton *recordingButton;
    bool isRecording;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    [self initProgressView];
    
    [self initBackBtn];
    [self initRightView];
    [self initFocusImageView];
    [self initBottomView];
    
    self.selectMusic = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectMusic setTitle:NvLocalString(@"selectMusic", @"选择音乐") forState:UIControlStateNormal];
    self.selectMusic.titleLabel.font = [NvUtils regularFontWithSize:12];
    [self.selectMusic setImage:NvImageNamed(@"NvSelectMusic") forState:UIControlStateNormal];
    [self.selectMusic addTarget:self action:@selector(selectMusicClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.selectMusic];
    [self.selectMusic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self->backBtn.mas_centerY);
        make.width.equalTo(@(150*SCREENSCALE));
    }];
    self.selectMusic.alpha = 0.7;
    self.selectMusic.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -5);
    
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFocus:)]];
    
    return self;
}
#pragma mark - 创建子视图
///Create a subview
- (void)initProgressView {
    recordingProgress = [[NvsRecordingProgress alloc] initWithFrame:CGRectMake(12*SCREENSCALE,
                                                                               30*SCREENSCALE,
                                                                               SCREENWIDTH-24*SCREENSCALE,
                                                                               6*SCREENSCALE)];
    [self addSubview:recordingProgress];
}

- (void)initRightView{
    UIView *rightView = [[UIView alloc] init];
    [self addSubview:rightView];
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-13*SCREENSCALE));
        make.top.equalTo(@(self->recordingProgress.frame.origin.y + self->recordingProgress.frame.size.height + 27*SCREENSCALE));
    }];
    cameraBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"flip", @"切换") withImageNormal:@"Nvdevice" withImageSelected:nil];
    [cameraBtn addTarget:self action:@selector(cameraButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:cameraBtn];
    [cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(rightView);
        make.top.equalTo(rightView);
    }];
    
    faceBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"beauty", @"美化") withImageNormal:@"Nvbeauty" withImageSelected:nil];
    [faceBtn addTarget:self action:@selector(faceBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:faceBtn];
    [faceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(rightView);
        make.top.equalTo(self->cameraBtn.mas_bottom).offset(24*SCREENSCALE);
    }];
    
    filterBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Filter", @"滤镜") withImageNormal:@"Nvfilter" withImageSelected:nil];
    [filterBtn addTarget:self action:@selector(filterBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [filterBtn.layer setBorderWidth:.0];
    [filterBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [rightView addSubview:filterBtn];
    [filterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(rightView);
        make.top.equalTo(self->faceBtn.mas_bottom).offset(24*SCREENSCALE);
    }];
    
    self.countDownBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Timer", @"倒计时") withImageNormal:@"NvcountDown" withImageSelected:nil];
    [self.countDownBtn addTarget:self action:@selector(countDownBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:self.countDownBtn];
    [self.countDownBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(rightView);
        make.top.equalTo(self->filterBtn.mas_bottom).offset(24*SCREENSCALE);
    }];

    self.propsBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Props", @"道具") withImageNormal:@"Nvprops" withImageSelected:nil];
    [self.propsBtn addTarget:self action:@selector(propsBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:self.propsBtn];
    [self.propsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(rightView);
        make.top.equalTo(self.countDownBtn.mas_bottom).offset(24*SCREENSCALE);
        make.bottom.equalTo(rightView);
    }];
}

- (void)initBottomView {
    self.shootingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shootingBtn setImage:NvImageNamed(@"NvShortVideoRecording") forState:UIControlStateNormal];
    [self.shootingBtn setImage:NvImageNamed(@"Nvsuspended") forState:UIControlStateSelected];
    [self.shootingBtn addTarget:self action:@selector(shootingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.shootingBtn];
    [self.shootingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(- 20 * SCREENSCALE);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(self.mas_bottom).offset(- 20 * SCREENSCALE);
        }
        make.centerX.equalTo(self.mas_centerX);
        make.width.offset(64 * SCREENSCALE);
        make.height.offset(64 * SCREENSCALE);
    }];
    deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(25*SCREENSCALE,
                                                           SCREENHEIGHT - 95*SCREENSCALE,
                                                           44*SCREENSCALE,
                                                           30*SCREENSCALE)];
    [deleteBtn setBackgroundImage:NvImageNamed(@"Nvdelete") forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:deleteBtn];
    deleteBtn.enabled = NO;
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.shootingBtn.mas_left).offset(-28*SCREENSCALE);
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
        make.width.offset(44 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 69*SCREENSCALE,
                                                         SCREENHEIGHT - 95*SCREENSCALE,
                                                         44*SCREENSCALE,
                                                         44*SCREENSCALE)];
    [nextBtn setBackgroundImage:NvImageNamed(@"Nvfinish") forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:nextBtn];
    nextBtn.enabled = NO;
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.shootingBtn.mas_right).offset(28*SCREENSCALE);
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
        make.width.offset(44 * SCREENSCALE);
        make.height.offset(44 * SCREENSCALE);
    }];
    
    self.album = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"album", @"相册") withImageNormal:@"NvShortVideoAlbum" withImageSelected:nil];
    [self.album addTarget:self action:@selector(albumClick) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:self.album];
    [self.album mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.shootingBtn.mas_right).offset(28*SCREENSCALE);
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
        make.height.offset(47 * SCREENSCALE);
    }];
    
    _currentSpeed = 1;
    int buttonWidth = 60*SCREENSCALE;
    int buttonHeight = 40*SCREENSCALE;
    int poxY = SCREENHEIGHT - 170*SCREENSCALE;
    _speedPanelView = [[UIView alloc] initWithFrame:CGRectMake(46*SCREENSCALE, poxY, buttonWidth*5, buttonHeight)];
    _speedPanelView.layer.cornerRadius = 2;
    _speedPanelView.layer.masksToBounds = YES;
    _speedPanelView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#4D000000"];
    [self addSubview:_speedPanelView];
    
    [_speedPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(46*SCREENSCALE));
        make.bottom.equalTo(self.shootingBtn.mas_top).offset(-18*SCREENSCALE);
        make.width.equalTo(@(5*buttonWidth));
        make.height.equalTo(@(buttonHeight));
    }];
    
    _speed13Btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    _speed12Btn = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth, 0, buttonWidth, buttonHeight)];
    _speed1Btn = [[UIButton alloc] initWithFrame:CGRectMake(2*buttonWidth, 0, buttonWidth, buttonHeight)];
    _speed32Btn = [[UIButton alloc] initWithFrame:CGRectMake(3*buttonWidth, 0, buttonWidth, buttonHeight)];
    _speed3Btn = [[UIButton alloc] initWithFrame:CGRectMake(4*buttonWidth, 0, buttonWidth, buttonHeight)];
    
    _speed13Btn.layer.cornerRadius = 2;
    _speed13Btn.layer.masksToBounds = YES;
    _speed12Btn.layer.cornerRadius = 2;
    _speed12Btn.layer.masksToBounds = YES;
    _speed1Btn.layer.cornerRadius = 2;
    _speed1Btn.layer.masksToBounds = YES;
    _speed32Btn.layer.cornerRadius = 2;
    _speed32Btn.layer.masksToBounds = YES;
    _speed3Btn.layer.cornerRadius = 2;
    _speed3Btn.layer.masksToBounds = YES;
    
    [self resetSpeedBtnColor];
    [_speed1Btn setTitleColor:[UIColor nv_colorWithHexARGB:@"#FF4D4F51"] forState:UIControlStateNormal];
    _speed1Btn.backgroundColor = [UIColor nv_colorWithHexARGB:@"#FFD8D8D8"];
    
    [_speed13Btn setTitle:NvLocalString(@"Epic", @"极慢") forState:UIControlStateNormal];
    _speed13Btn.titleLabel.numberOfLines = 2;
    _speed13Btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _speed13Btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _speed13Btn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    
    [_speed12Btn setTitle:NvLocalString(@"Slow", @"慢") forState:UIControlStateNormal];
    _speed12Btn.titleLabel.numberOfLines = 2;
    _speed12Btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _speed12Btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _speed12Btn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    
    [_speed1Btn setTitle:NvLocalString(@"Norm", @"标准") forState:UIControlStateNormal];
    _speed1Btn.titleLabel.numberOfLines = 2;
    _speed1Btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _speed1Btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _speed1Btn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    
    [_speed32Btn setTitle:NvLocalString(@"Fast", @"快") forState:UIControlStateNormal];
    _speed32Btn.titleLabel.numberOfLines = 2;
    _speed32Btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _speed32Btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _speed32Btn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    
    [_speed3Btn setTitle:NvLocalString(@"Lapse", @"极快") forState:UIControlStateNormal];
    _speed3Btn.titleLabel.numberOfLines = 2;
    _speed3Btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _speed3Btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _speed3Btn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    
    _speed13Btn.titleLabel.font = [NvUtils fontWithSize:12];
    _speed12Btn.titleLabel.font = [NvUtils fontWithSize:12];
    _speed1Btn.titleLabel.font = [NvUtils fontWithSize:12];
    _speed32Btn.titleLabel.font = [NvUtils fontWithSize:12];
    _speed3Btn.titleLabel.font = [NvUtils fontWithSize:12];
    
    selectView = [[UIImageView alloc] initWithFrame:CGRectMake(56.6*5/2*SCREENSCALE-5*SCREENSCALE, 32*SCREENSCALE, 10*SCREENSCALE, 8*SCREENSCALE)];
    selectView.image = NvImageNamed(@"Triangle");
    [_speedPanelView addSubview:selectView];
    
    [_speed13Btn addTarget:self action:@selector(speed13BtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [_speed12Btn addTarget:self action:@selector(speed12BtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [_speed1Btn addTarget:self action:@selector(speed1BtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [_speed32Btn addTarget:self action:@selector(speed32BtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [_speed3Btn addTarget:self action:@selector(speed3BtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
    
    [_speedPanelView addSubview:_speed13Btn];
    [_speedPanelView addSubview:_speed12Btn];
    [_speedPanelView addSubview:_speed1Btn];
    [_speedPanelView addSubview:_speed32Btn];
    [_speedPanelView addSubview:_speed3Btn];
 
}

- (void)initFocusImageView {
    self.focusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50*SCREENSCALE, 50*SCREENSCALE)];
    self.focusImageView.image = NvImageNamed(@"NvsCaptureFocus");
    self.focusImageView.alpha = 0;
    self.focusImageView.center = self.center;
    [self addSubview:self.focusImageView];
}

#pragma mark -按钮点击事件
///Button click event
- (void)countDownBtnClick {
    if ([self.delegate respondsToSelector:@selector(countDownBtnClick)]) {
        [self.delegate countDownBtnClick];
    }
}

- (void)selectMusicClick {
    if ([self.delegate respondsToSelector:@selector(selectMusicClick)]) {
        [self.delegate selectMusicClick];
    }
}

- (void)propsBtnClicked {
    if ([self.delegate respondsToSelector:@selector(propsBtnClicked)]) {
        [self.delegate propsBtnClicked];
    }
}

- (void)faceBtnClicked {
    if ([self.delegate respondsToSelector:@selector(faceBtnClicked)]) {
        [self.delegate faceBtnClicked];
    }
}

- (void)cutMusicClicked {
    if ([self.delegate respondsToSelector:@selector(cutMusicClicked)]) {
        [self.delegate cutMusicClicked];
    }
}

- (void)cameraButtonClicked {
    if ([self.delegate respondsToSelector:@selector(cameraButtonClicked)]) {
        [self.delegate cameraButtonClicked];
    }
}

- (void)initBackBtn {
    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(13*SCREENSCALE,self->recordingProgress.frame.origin.y + self->recordingProgress.frame.size.height + 27*SCREENSCALE,33*SCREENSCALE,33*SCREENSCALE);
    [backBtn addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:NvImageNamed(@"Nvback") forState:UIControlStateNormal];
    [self addSubview:backBtn];
}

- (void)backButtonClicked {
    if ([self.delegate respondsToSelector:@selector(backButtonClicked)]) {
        [self.delegate backButtonClicked];
    }
}

- (void)albumClick {
    if ([self.delegate respondsToSelector:@selector(albumClick)]) {
        [self.delegate albumClick];
    }
}

- (void)speed13BtnClicked {
    _currentSpeed = 0.5;
    [self resetSpeedBtnColor];
    [_speed13Btn setTitleColor:[UIColor nv_colorWithHexARGB:@"#FF4D4F51"] forState:UIControlStateNormal];
    _speed13Btn.backgroundColor = [UIColor nv_colorWithHexARGB:@"#FFD8D8D8"];
    speedStr = @"0.5";
    selectView.center = CGPointMake(_speed13Btn.center.x, selectView.center.y);
    if ([self.delegate respondsToSelector:@selector(shortVideoCaptureView:selectSpeed:)]) {
        [self.delegate shortVideoCaptureView:self selectSpeed:_currentSpeed];
    }
}

- (void)speed12BtnClicked {
    _currentSpeed = 0.75;
    [self resetSpeedBtnColor];
    [_speed12Btn setTitleColor:[UIColor nv_colorWithHexARGB:@"#FF4D4F51"] forState:UIControlStateNormal];
    _speed12Btn.backgroundColor = [UIColor nv_colorWithHexARGB:@"#FFD8D8D8"];
    speedStr = @"0.75";
    selectView.center = CGPointMake(_speed12Btn.center.x, selectView.center.y);
    if ([self.delegate respondsToSelector:@selector(shortVideoCaptureView:selectSpeed:)]) {
        [self.delegate shortVideoCaptureView:self selectSpeed:_currentSpeed];
    }
}

- (void)speed1BtnClicked {
    _currentSpeed = 1;
    [self resetSpeedBtnColor];
    [_speed1Btn setTitleColor:[UIColor nv_colorWithHexARGB:@"#FF4D4F51"] forState:UIControlStateNormal];
    _speed1Btn.backgroundColor = [UIColor nv_colorWithHexARGB:@"#FFD8D8D8"];
    speedStr = @"1";
    selectView.center = CGPointMake(_speed1Btn.center.x, selectView.center.y);
    if ([self.delegate respondsToSelector:@selector(shortVideoCaptureView:selectSpeed:)]) {
        [self.delegate shortVideoCaptureView:self selectSpeed:_currentSpeed];
    }
}

- (void)speed32BtnClicked {
    _currentSpeed = 1.5;
    [self resetSpeedBtnColor];
    [_speed32Btn setTitleColor:[UIColor nv_colorWithHexARGB:@"#FF4D4F51"] forState:UIControlStateNormal];
    _speed32Btn.backgroundColor = [UIColor nv_colorWithHexARGB:@"#FFD8D8D8"];
    speedStr = @"1.5";
    selectView.center = CGPointMake(_speed32Btn.center.x, selectView.center.y);
    if ([self.delegate respondsToSelector:@selector(shortVideoCaptureView:selectSpeed:)]) {
        [self.delegate shortVideoCaptureView:self selectSpeed:_currentSpeed];
    }
}

- (void)speed3BtnClicked {
    _currentSpeed = 2;
    [self resetSpeedBtnColor];
    [_speed3Btn setTitleColor:[UIColor nv_colorWithHexARGB:@"#FF4D4F51"] forState:UIControlStateNormal];
    _speed3Btn.backgroundColor = [UIColor nv_colorWithHexARGB:@"#FFD8D8D8"];
    speedStr = @"2";
    selectView.center = CGPointMake(_speed3Btn.center.x, selectView.center.y);
    if ([self.delegate respondsToSelector:@selector(shortVideoCaptureView:selectSpeed:)]) {
        [self.delegate shortVideoCaptureView:self selectSpeed:_currentSpeed];
    }
}

- (void)deleteBtnClicked {
    self.countDownBtn.alpha = 1;
    [recordingProgress prepareDelete];
    
    [recordingProgress deleteProgress];
    
    int64_t recordDuration = [recordingProgress getValue];
    if (recordDuration < [recordingProgress getMinRecordTime]) {
        nextBtn.enabled = NO;
    }
    if ([recordingProgress getCount]==0) {
        deleteBtn.enabled = NO;
        nextBtn.enabled = NO;
    }
    if (recordingProgress.value<15000000) {
        self.countDownBtn.enabled = YES;
    }
    if ([self.delegate respondsToSelector:@selector(deleteBtnClicked)]) {
        [self.delegate deleteBtnClicked];
    }
}

- (void)nextBtnClicked {
    if ([self.delegate respondsToSelector:@selector(nextBtnClicked)]) {
        [self.delegate nextBtnClicked];
    }
}


- (void)filterBtnClicked {
    if ([self.delegate respondsToSelector:@selector(filterBtnClicked)]) {
        [self.delegate filterBtnClicked];
    }
}

- (void)shootingBtnClick:(UIButton *)button {
    if (isRecording) {
        [self touchEnd];
        button.selected = NO;
        button.userInteractionEnabled = YES;
        button.alpha = 1;
    } else {
        ///录制大于15秒不要再进行录制
        ///Do not record longer than 15 seconds
        if ([recordingProgress value] >= TotalTime) {
            if ([self.delegate respondsToSelector:@selector(overFifteenSecond)]) {
                [self.delegate overFifteenSecond];
            }
            return;
        }
        button.selected = YES;
        button.userInteractionEnabled = NO;
        button.alpha = 0.6;
        [self touchBegin];
        
    }
    
}

#pragma mark 点击livewindow
///Click on livewindow
- (void)tapFocus:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    ///是否支持聚焦
    ///Support focus or not
    if ([self.delegate respondsToSelector:@selector(supportAutoFocus)]) {
        if ([self.delegate supportAutoFocus]) {
            if ([self.delegate respondsToSelector:@selector(focusOnPoint:)]) {
                [self.delegate focusOnPoint:point];
                [self showFocusToPoint:point];
            }
        }
    }
    ///是否支持聚焦
    ///Support focus or not
    if ([self.delegate respondsToSelector:@selector(supportAutoExposure)]) {
        if ([self.delegate supportAutoExposure]) {
            if ([self.delegate respondsToSelector:@selector(exposureOnPoint:)]) {
                [self.delegate exposureOnPoint:point];
                [self showFocusToPoint:point];
            }
        }
    }
}

- (void)showFocusToPoint:(CGPoint)point {
    self.focusImageView.center = point;

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.8;
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue   = @1;
    alphaAnimation.repeatCount = 1;
    alphaAnimation.duration = .8;
    
    CABasicAnimation *focusAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    focusAnimation.fromValue = @1.7;
    focusAnimation.toValue   = @1;
    focusAnimation.repeatCount = 1;
    focusAnimation.duration = .3;
    
    CABasicAnimation *focusAnimation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    focusAnimation1.fromValue = @1;
    focusAnimation1.toValue   = @1;
    focusAnimation1.repeatCount = 1;
    focusAnimation1.beginTime = 0.3;
    focusAnimation1.duration = 0.5;
    
    [group setAnimations:@[alphaAnimation,focusAnimation,focusAnimation1]];
    [self.focusImageView.layer addAnimation:group forKey:@"transform.scale"];
}

- (void)hiddenFocusImage {
//    self.focusImageView.hidden = YES;
}

- (void)resetSpeedBtnColor {
    _speed13Btn.backgroundColor = [UIColor clearColor];
    _speed12Btn.backgroundColor = [UIColor clearColor];
    _speed3Btn.backgroundColor = [UIColor clearColor];
    _speed32Btn.backgroundColor = [UIColor clearColor];
    _speed1Btn.backgroundColor = [UIColor clearColor];
    [_speed13Btn setTitleColor:[UIColor nv_colorWithHexARGB:@"#FFEAEBEB"] forState:UIControlStateNormal];
    [_speed12Btn setTitleColor:[UIColor nv_colorWithHexARGB:@"#FFEAEBEB"] forState:UIControlStateNormal];
    [_speed1Btn setTitleColor:[UIColor nv_colorWithHexARGB:@"#FFEAEBEB"] forState:UIControlStateNormal];
    [_speed32Btn setTitleColor:[UIColor nv_colorWithHexARGB:@"#FFEAEBEB"] forState:UIControlStateNormal];
    [_speed3Btn setTitleColor:[UIColor nv_colorWithHexARGB:@"#FFEAEBEB"] forState:UIControlStateNormal];
}

- (void)countDownStartRecording {
    [self shootingBtnClick:self.shootingBtn];
}

- (void)enableRecordingButton {
    self.shootingBtn.userInteractionEnabled = YES;
    self.shootingBtn.alpha = 1;
}

- (void)touchBegin {
    isRecording = YES;
    if ([self.delegate respondsToSelector:@selector(startRecord)]) {
        [recordingProgress beginProgress];
        [self.delegate startRecord];
    }
}

- (void)touchEnd {
    isRecording = NO;
    if ([self.delegate respondsToSelector:@selector(endRecord)]) {
        [recordingProgress endProgress];
        [self.delegate endRecord];
    }
}

- (void)recordingEnd {
    [self touchEnd];
    self.shootingBtn.selected = NO;
    self.shootingBtn.userInteractionEnabled = YES;
    self.shootingBtn.alpha = 1;
    nextBtn.enabled = YES;
    deleteBtn.enabled = YES;
    self.countDownBtn.alpha = 0.6;
}

- (void)updateCaptureClipDuration:(int64_t)duration {
    if (!isRecording) {
        return;
    }
    
    [recordingProgress currentValue: [recordingProgress getValue] + duration/_currentSpeed];
    if ([recordingProgress getValue] + duration/_currentSpeed > [recordingProgress getMinRecordTime]) {
        nextBtn.enabled = YES;
    } else {
        nextBtn.enabled = NO;
    }
    deleteBtn.enabled = YES;

}

- (void)hiddenAllButtonExceptRecordingButton {
    backBtn.hidden = YES;
    cameraBtn.hidden = YES;
    flashBtn.hidden = YES;
    faceBtn.hidden = YES;
    filterBtn.hidden = YES;
    _speedPanelView.hidden = YES;
    deleteBtn.hidden = YES;
    nextBtn.hidden = YES;
    self.countDownBtn.hidden = YES;
    self.propsBtn.hidden = YES;
    self.selectMusic.hidden = YES;
}

- (void)showAllButton {
    backBtn.hidden = NO;
    cameraBtn.hidden = NO;
    flashBtn.hidden = NO;
    faceBtn.hidden = NO;
    filterBtn.hidden = NO;
    _speedPanelView.hidden = NO;
    deleteBtn.hidden = NO;
    nextBtn.hidden = NO;
    self.countDownBtn.hidden = NO;
    self.propsBtn.hidden = NO;
    self.selectMusic.hidden = NO;
}

@end
