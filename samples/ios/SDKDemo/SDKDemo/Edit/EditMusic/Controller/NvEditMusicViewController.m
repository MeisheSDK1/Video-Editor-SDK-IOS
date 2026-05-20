//
//  NvEditMusicViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/2.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvEditMusicViewController.h"
#import "NvAddCaptionView.h"
#import "NvsTimelineCaption.h"
#import "NvSelectMusicViewController.h"
#import "NvsAudioTrack.h"
#import "NvTimelineUtils.h"
#import "NvTimelineData.h"
#import "NvMultiMusicViewController.h"
#import "NvUrlVideoMaterialVC.h"

@interface NvEditMusicViewController ()<NvsStreamingContextDelegate, NvLiveWindowPanelViewDelegate, NvUrlVideoMaterialVCDelegate> {
    BOOL isPlay;
}

@property (nonatomic, strong) NvAddCaptionView *addCaptionView;
@property (nonatomic, strong) UIButton *singleItemButton;
@property (nonatomic, strong) UILabel *singleLabel;
@property (nonatomic, strong) UIButton *multiItemButton;
@property (nonatomic, strong) UILabel *multiLabel;
@property (nonatomic, strong) NvMusicInfoModel *musicInfo;
@property (nonatomic, strong) NvTimelineData *timelineData;

@end

@implementation NvEditMusicViewController

-(void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NvLocalString(@"Music", @"音乐");
    NvsTimeline *timeline = [NvTimelineUtils createTimeline:self.editMode];
    [NvTimelineUtils recreateTimeline:timeline];
    self.timelineData = [NvTimelineData sharedInstance];
    self.timeline = timeline;
    [self initSubViews];
    self.liveWindowPanel.delegate = self;
    [self.liveWindowPanel hiddenVolumeButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.streamingContext stop];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NvTimelineUtils recreateTimeline:self.timeline];
    if (isPlay) {
        [self.liveWindowPanel playAtTime:0];
    }
}

- (void)leftNavButtonClick:(UIButton *)button {
    [self.streamingContext removeTimeline:self.timeline];
    [super leftNavButtonClick:button];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)singleItemClick:(UIButton *)itemButton {
    isPlay = NO;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"urlEdit"] boolValue]) {
        NvUrlVideoMaterialVC *vc = [[NvUrlVideoMaterialVC alloc] init];
        vc.isMusicEdit = true;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NvSelectMusicViewController *selectMusic = NvSelectMusicViewController.new;
        selectMusic.delegate = self;

        [self.navigationController pushViewController:selectMusic animated:YES];
    }
}

- (void)multiItemClick:(UIButton *)itemButton {
    NvMultiMusicViewController *vc = NvMultiMusicViewController.new;
    vc.editMode = self.editMode;
    vc.title = NvLocalString(@"Multi-segment music", @"多段音乐");
    NSMutableArray *musicDataArray = [[NvTimelineData sharedInstance] musicDataArray];
    for (NvMusicInfoModel *musicInfo in musicDataArray) {
        if (musicInfo.isBGM) {
            musicInfo.isBGM = NO;
            musicInfo.outPoint = self.timeline.duration;
        }
    }
    [[NvTimelineData sharedInstance] setMusicDataArray:musicDataArray];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark tipView按钮点击事件
///tipView button click event
- (void)knowClick:(UIButton *)sender{
    [sender.superview.superview removeFromSuperview];
}

// MARK: initSubviews
- (void)initSubViews {
    self.singleItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.singleItemButton setImage:NvImageNamed(@"NvEditMusic") forState:UIControlStateNormal];
    [self.view addSubview:self.singleItemButton];
    [self.singleItemButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(70*SCREENSCALE));
        make.height.equalTo(@(70*SCREENSCALE));
        make.centerX.equalTo(self.view.mas_centerX).offset(-49 * SCREENSCALE);
        make.bottom.equalTo(self.view.mas_bottom).offset(-INDICATOR-89 * SCREENSCALE);
    }];
    [self.singleItemButton addTarget:self action:@selector(singleItemClick:) forControlEvents:UIControlEventTouchUpInside];
    self.singleLabel = [[UILabel alloc] init];
    self.singleLabel.text = NvLocalString(@"SingleMusic", @"单段音乐");
    self.singleLabel.textColor = [UIColor whiteColor];
    self.singleLabel.alpha = 0.8;
    self.singleLabel.font = [NvUtils fontWithSize:12];
    self.singleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.singleLabel];
    [self.singleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.singleItemButton);
        make.width.greaterThanOrEqualTo(self.singleItemButton);
        make.top.equalTo(self.singleItemButton.mas_bottom).offset(11 * SCREENSCALE);
        make.centerX.equalTo(self.singleItemButton.mas_centerX);
    }];
    
    self.multiItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.multiItemButton setImage:NvImageNamed(@"NvEditMusic_1") forState:UIControlStateNormal];
    [self.view addSubview:self.multiItemButton];
    [self.multiItemButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(70*SCREENSCALE));
        make.height.equalTo(@(70*SCREENSCALE));
        make.centerX.equalTo(self.view.mas_centerX).offset(49 * SCREENSCALE);
        make.centerY.equalTo(self.singleItemButton.mas_centerY);
    }];
    [self.multiItemButton addTarget:self action:@selector(multiItemClick:) forControlEvents:UIControlEventTouchUpInside];
    self.multiLabel = [[UILabel alloc] init];
    self.multiLabel.alpha = 0.8;
    self.multiLabel.textAlignment = NSTextAlignmentCenter;
    self.multiLabel.text = NvLocalString(@"Multi-segment music", @"多段音乐");
    self.multiLabel.textColor = [UIColor whiteColor];
    self.multiLabel.font = [NvUtils fontWithSize:12];
    [self.view addSubview:self.multiLabel];
    [self.multiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.multiItemButton);
        make.width.greaterThanOrEqualTo(self.multiItemButton);
        make.top.equalTo(self.multiItemButton.mas_bottom).offset(11 * SCREENSCALE);
        make.centerX.equalTo(self.multiItemButton.mas_centerX);
    }];
}

// MARK: NvSelectMusicViewControllerDelegate
- (void)selectMusicViewController:(NvSelectMusicViewController *)selectMusicViewController withItem:(NvEditSelectMusicItem *)item trimIn:(float)trimIn trimOut:(float)trimOut {
    [[[NvTimelineData sharedInstance] musicDataArray] removeAllObjects];
    
    self.musicInfo = [NvMusicInfoModel new];
    self.musicInfo.musicPath = item.musicPath;
    self.musicInfo.trimIn = trimIn*NV_TIME_BASE;
    self.musicInfo.trimOut = trimOut*NV_TIME_BASE;
    self.musicInfo.musicName = item.musicName;
    self.musicInfo.volume = 1;
    self.musicInfo.isBGM = YES;
    [[[NvTimelineData sharedInstance] musicDataArray] addObject:self.musicInfo];
    [NvTimelineUtils resetMusicTrack:self.timeline musicDataArray:[[NvTimelineData sharedInstance] musicDataArray]];
    isPlay = YES;
}

- (void)selectNoneMusic {
    [[[NvTimelineData sharedInstance] musicDataArray] removeAllObjects];
    [NvTimelineUtils resetMusicTrack:self.timeline musicDataArray:[[NvTimelineData sharedInstance] musicDataArray]];
    isPlay = YES;
}

#pragma mark - NvUrlVideoMaterialVCDelegate
- (void)selectMusicItem:(NvListMediaInfoModel *)item trimIn:(float)trimIn trimOut:(float)trimOut{
    [[[NvTimelineData sharedInstance] musicDataArray] removeAllObjects];
    
    self.musicInfo = [NvMusicInfoModel new];
    self.musicInfo.musicPath = item.url;
    self.musicInfo.trimIn = trimIn*NV_TIME_BASE;
    self.musicInfo.trimOut = trimOut*NV_TIME_BASE;
    self.musicInfo.musicName = item.displayName;
    self.musicInfo.volume = 1;
    self.musicInfo.isBGM = YES;
    [[[NvTimelineData sharedInstance] musicDataArray] addObject:self.musicInfo];
    [NvTimelineUtils resetMusicTrack:self.timeline musicDataArray:[[NvTimelineData sharedInstance] musicDataArray]];
    isPlay = YES;
}

@end
