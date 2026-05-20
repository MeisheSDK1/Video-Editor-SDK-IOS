//
//  NVDescribeController.m
//  ThemeShooting
//
//  Created by ms on 2020/7/16.
//  Copyright © 2020 ms. All rights reserved.
//

#import "NVDescribeController.h"
#import <AVFoundation/AVFoundation.h>
#import "NvCaptureController.h"
#import "UIColor+NvColor.h"
#import "NVHeader.h"

@interface NVDescribeController ()

@property (nonatomic, strong) UIView *containView;

@property (nonatomic, strong) AVPlayerLayer *avLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *currentPlayerItem;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *numLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *selectFormatLabel;
@property (nonatomic, strong) UIView *horizontalView;
@property (nonatomic, strong) UILabel *horizontalLabel;
@property (nonatomic, strong) UIView *verticalView;
@property (nonatomic, strong) UILabel *verticalLabel;

@property (nonatomic, strong) UIButton *SixteenToNineBtn;
@property (nonatomic, strong) UIButton *nineToSixteenBtn;


@property (nonatomic, strong) UIButton *captureBtn;
@property (nonatomic, assign) NvEditMode editMode;

@property (nonatomic, strong) UIButton *backBtn;


@end

@implementation NVDescribeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor nv_colorWithHexString:@"#000000"];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"], NSForegroundColorAttributeName, [NvUtils fontWithSize:16], NSFontAttributeName, nil]];
    [self configAvPlayer];
    
    [self initUI];
    [self configLayout];
    NSString *ratio = self.model.packageInfoModel.supportedAspectRatio;
    
    if ([self supportedAspect: ratio] == 2) {
        // 16v9
        [self SixteenToNineBtnAction];
    }else if ([self supportedAspect: ratio] == 3) {
        // 9v16
        [self nineToSixteenBtn];
    }else {
        [self SixteenToNineBtnAction];
    }
}

#pragma mark 生命周期
///Life cycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    self.avLayer.hidden = NO;
    self.backBtn.hidden = NO;
    self.titleLabel.hidden = NO;
    [self.player play];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.player pause];
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

-(void)initUI{
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self leftNavigationBarItemView]];

    self.navigationItem.leftBarButtonItem = leftBarButtonItem;

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = self.model.packageInfoModel.name;
    _titleLabel.font = [UIFont systemFontOfSize:14*SCREENSCALE];
    _titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_titleLabel];
    
    _numLabel = [[UILabel alloc] init];
    _numLabel.textAlignment = NSTextAlignmentCenter;
    _numLabel.text = [NSString stringWithFormat:@"%@：%ld", NvLocalString(@"Clip", @"片段"),(long)self.model.packageInfoModel.shotsNumber];
    _numLabel.font = [UIFont systemFontOfSize:14*SCREENSCALE];
    _numLabel.textColor = [UIColor nv_colorWithHexRGB:@"#A3A3A3"];
    [self.view addSubview:_numLabel];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    NSUInteger min = self.model.packageInfoModel.musicDuration / NV_TIME_BASE / 60;
    NSUInteger sec = self.model.packageInfoModel.musicDuration / NV_TIME_BASE % 60;
    self.timeLabel.text = [NSString stringWithFormat:@"%@:%2lu:%2lu", NvLocalString(@"Time", @"时长"), (unsigned long)min, (unsigned long)sec];
    _timeLabel.font = [UIFont systemFontOfSize:14*SCREENSCALE];
    _timeLabel.textColor = [UIColor nv_colorWithHexRGB:@"#A3A3A3"];
    [self.view addSubview:_timeLabel];
    
    _selectFormatLabel = [[UILabel alloc] init];
    _selectFormatLabel.textAlignment = NSTextAlignmentCenter;
    _selectFormatLabel.hidden = YES;
    _selectFormatLabel.text = NvLocalString(@"Select format", @"选择格式");
    _selectFormatLabel.font = [UIFont systemFontOfSize:14*SCREENSCALE];
    _selectFormatLabel.textColor = [UIColor whiteColor];
    _selectFormatLabel.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1A1A1A"];
    [self.view addSubview:_selectFormatLabel];
    
    _verticalLabel = [[UILabel alloc] init];
    _verticalLabel.textAlignment = NSTextAlignmentCenter;
    _verticalLabel.text = @"9:16";
    _verticalLabel.font = [UIFont systemFontOfSize:12*SCREENSCALE];
    _verticalLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
    [self.view addSubview:_verticalLabel];
    
    _verticalView = [[UIView alloc] init];
    _verticalView.backgroundColor = UIColor.clearColor;
    _verticalView.layer.borderWidth = 1.5;
    _verticalView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"].CGColor;
    [self.view addSubview:_verticalView];
    
    _horizontalLabel = [[UILabel alloc] init];
    _horizontalLabel.textAlignment = NSTextAlignmentCenter;
    _horizontalLabel.text = @"16:9";
    _horizontalLabel.font = [UIFont systemFontOfSize:12*SCREENSCALE];
    _horizontalLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
    [self.view addSubview:_horizontalLabel];
    
    _horizontalView = [[UIView alloc] init];
    _horizontalView.backgroundColor = UIColor.clearColor;
    _horizontalView.layer.borderWidth = 1.5;
    _horizontalView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"].CGColor;
    [self.view addSubview:_horizontalView];
    
    _captureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _captureBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [_captureBtn setBackgroundColor:[UIColor nv_colorWithHexRGB:@"#4784E1"]];
    _captureBtn.layer.cornerRadius = 16.5*SCREENSCALE;
    [_captureBtn setTitle:NvLocalString(@"Start shooting", @"开始拍摄") forState:UIControlStateNormal];
    [_captureBtn addTarget:self action:@selector(captureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_captureBtn];
    
    self.SixteenToNineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.SixteenToNineBtn addTarget:self action:@selector(SixteenToNineBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.SixteenToNineBtn];
    
    self.nineToSixteenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nineToSixteenBtn addTarget:self action:@selector(nineToSixteenBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nineToSixteenBtn];
}
/**
 横屏拍摄
 Horizontal screen shooting
 */
-(void)SixteenToNineBtnAction{
    if ([self supportedAspect:self.model.packageInfoModel.supportedAspectRatio] == 3) {
        [NvToast showInfoWithMessage:NvLocalString(@"Disable 16:9 vertical screen shooting", @"不支持16:9竖屏拍摄")];
        return;
    }
    self.editMode = NvEditMode16v9;
    self.horizontalLabel.textColor = [UIColor nv_colorWithHexString:@"#4A90E2"];
    _horizontalView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
    self.verticalLabel.textColor = [UIColor nv_colorWithHexString:@"#8B8B8B"];
    self.verticalView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#8B8B8B"].CGColor;
    self.containView.frame = CGRectMake(0, NV_STATUSBARHEIGHT + NV_NAV_BAR_HEIGHT + 50, kScreenWidth, kScreenWidth / 16.0f * 9.0);
    self.avLayer.frame = self.containView.bounds;
    [self.view updateConstraints];
}
/**
 竖屏拍摄
 Vertical screen shooting
 */
-(void)nineToSixteenBtnAction{
    if ([self supportedAspect:self.model.packageInfoModel.supportedAspectRatio] == 2) {
        [NvToast showInfoWithMessage:NvLocalString(@"Disable 9:16 vertical screen shooting", @"不支持9:16竖屏拍摄")];
        return;
    }
    self.editMode = NvEditMode9v16;
    self.verticalLabel.textColor = [UIColor nv_colorWithHexString:@"#4A90E2"];
    self.verticalView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
    self.horizontalLabel.textColor = [UIColor nv_colorWithHexString:@"#8B8B8B"];
    _horizontalView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#8B8B8B"].CGColor;
    self.containView.frame = CGRectMake(0, NV_STATUSBARHEIGHT + NV_NAV_BAR_HEIGHT , kScreenWidth * 9 / 10.0 / 16.0f * 9.0, kScreenWidth * 9 / 10.0);
    self.containView.centerX = self.view.centerX;
    self.avLayer.frame = self.containView.bounds;
    [self.view updateConstraints];
}

-(void)captureBtnAction{
    [self.player pause];
    self.avLayer.hidden = YES;
    self.backBtn.hidden = YES;
    self.titleLabel.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NvCaptureController *vc = [NvCaptureController new];
        vc.model = self.model;
        vc.editMode = self.editMode;
        [self.navigationController pushViewController:vc animated:NO];
    });
 
}

- (UIView *)leftNavigationBarItemView {
    UIButton *backButton;
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"Nvback"] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, 30, 44);
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15*SCREENSCALE, 0, 0);
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.backBtn = backButton;
    return backButton;
}

-(void)back{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)configLayout{
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containView.mas_bottom).offset(13.0f*SCREENSCALE);
        make.centerX.mas_equalTo(self.containView);
        make.height.mas_equalTo(20.0f*SCREENSCALE);
        make.width.mas_equalTo(100.0f);
    }];
  
    [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(23.0f*SCREENSCALE);
        make.centerX.mas_equalTo(self.containView);
        make.height.mas_equalTo(20.0f*SCREENSCALE);
        make.width.mas_equalTo(100.0f*SCREENSCALE);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.numLabel.mas_bottom).offset(10*SCREENSCALE);
        make.centerX.mas_equalTo(self.containView);
        make.height.mas_equalTo(20.0f*SCREENSCALE);
        make.width.mas_equalTo(100.0f*SCREENSCALE);
    }];
    [self.captureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-(INDICATOR + 20));
        make.centerX.mas_equalTo(self.containView);
        make.width.mas_equalTo(223.0f/2*SCREENSCALE);
        make.height.mas_equalTo(33.0f*SCREENSCALE);
    }];
    [self.verticalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.horizontalLabel.mas_centerY);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(80.0f*SCREENSCALE);
        make.width.mas_equalTo(40.0f*SCREENSCALE);
        make.height.mas_equalTo(20.0f*SCREENSCALE);
    }];
    [self.verticalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.verticalLabel.mas_top).offset(-16.0f*SCREENSCALE);
        make.centerX.mas_equalTo(self.verticalLabel.mas_centerX);
        make.width.mas_equalTo(34.0f*SCREENSCALE);
        make.height.mas_equalTo(58.0f*SCREENSCALE);
    }];
    
    [self.horizontalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.captureBtn.mas_top).offset(-50.0f*SCREENSCALE);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(-80.0f*SCREENSCALE);
        make.width.mas_equalTo(40*SCREENSCALE);
        make.height.mas_equalTo(20*SCREENSCALE);
    }];
    [self.horizontalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.verticalView.mas_centerY);
        make.centerX.mas_equalTo(self.horizontalLabel.mas_centerX);
        make.width.mas_equalTo(58.0f*SCREENSCALE);
        make.height.mas_equalTo(34.0*SCREENSCALE);
    }];
    
    [self.selectFormatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.verticalView.mas_top).offset(-25.0f*SCREENSCALE);
        make.centerX.mas_equalTo(self.containView);
        make.width.mas_equalTo(SCREENWIDTH);
        make.height.mas_equalTo(44.0f*SCREENSCALE);
    }];
    
    [self.SixteenToNineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.horizontalView.mas_top);
        make.left.mas_equalTo(self.horizontalView.mas_left);
        make.bottom.mas_equalTo(self.horizontalLabel.mas_bottom);
        make.right.mas_equalTo(self.horizontalView.mas_right);
    }];
    [self.nineToSixteenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.verticalView.mas_top);
        make.left.mas_equalTo(self.verticalView.mas_left);
        make.bottom.mas_equalTo(self.verticalLabel.mas_bottom);
        make.right.mas_equalTo(self.verticalView.mas_right);
    }];
    
}

/**
 初始化播放器
 Initialize player
 */
-(void)configAvPlayer{
    
    UIView *containView = [[UIView alloc] initWithFrame:CGRectMake(0, NV_STATUSBARHEIGHT + NV_NAV_BAR_HEIGHT + 50, kScreenWidth, kScreenWidth / 16.0f * 9.0)];
    [self.view addSubview:containView];
    containView.backgroundColor = [UIColor clearColor];
    self.containView = containView;

    if (self.model.videoUrl && self.model.videoUrl.length > 0) {
        self.player = [AVPlayer playerWithURL:[NSURL URLWithString:self.model.videoUrl]];
    }else{
        NSString * dirPath = [[NSHomeDirectory() stringByAppendingPathComponent:self.model.isLocal ? @"Documents/LocalThemeShoot": @"Documents/ThemeShoot"] stringByAppendingPathComponent:self.model.uuid ? self.model.uuid : self.model.packageInfoModel.ID];
        self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:[dirPath stringByAppendingPathComponent:@"cover.mp4"]]];
    }
    
    
    self.avLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.containView.layer addSublayer:self.avLayer];
    self.avLayer.frame = self.containView.bounds;
    self.avLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:
(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey]intValue];
        switch (status) {
            case AVPlayerItemStatusFailed:
                break;
            case AVPlayerItemStatusReadyToPlay:
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.player play];
                });
            }
                break;
            case AVPlayerItemStatusUnknown:
                break;
            default:
                break;
        }
    }
}

-(void)dealloc{
    self.player = nil;
    self.avLayer = nil;
}


- (void)moviePlayDidEnd:(NSNotification *)note
{
    
    [_player seekToTime:CMTimeMake(0, 1)];
    [_player play];
}

- (int)supportedAspect:(NSString *)ratio {
    if ([ratio containsString:@"|"]) {
        return 1;
    }
    if ([ratio isEqualToString:@"16v9"]) {
        return 2;
    }
    if ([ratio isEqualToString:@"9v16"]) {
        return 3;
    }
    return 0;
}

- (BOOL)shouldAutorotate {
    return NO;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return  UIInterfaceOrientationPortrait;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}


@end
