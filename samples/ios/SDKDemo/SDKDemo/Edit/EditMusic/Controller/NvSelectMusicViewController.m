//
//  NvSelectMusicViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/2.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvSelectMusicViewController.h"
#import "NvLocalMusicViewController.h"
#import "NvMyMusicViewController.h"
#import "NvTabScrollView.h"
#import "NVHeader.h"
#import "NvAudioPlayerView.h"
#import "NvAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface NvSelectMusicViewController () {
    NvTabScrollView *view;
}

@property (nonatomic, strong) NvEditSelectMusicItem *myItem;
@property (nonatomic, strong) NvEditSelectMusicItem *localItem;
@property (nonatomic, strong) NvAudioPlayerView *audioPlayerView;
@property (nonatomic, strong) NvAudioPlayer *audioPlayer;
@property (nonatomic, strong) NvLocalMusicViewController *vc1;
@property (nonatomic, strong) NvMyMusicViewController *vc2;

@property (nonatomic, assign) float trimIn;
@property (nonatomic, assign) float trimOut;

@end

@implementation NvSelectMusicViewController

-(void)dealloc {
    [self.audioPlayerView removeObserver:self forKeyPath:@"hidden"];
    [self.audioPlayer pause];
    self.audioPlayer = nil;
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NvLocalString(@"selectMusic", @"选择音乐");
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;

    self.vc1 = [[NvLocalMusicViewController alloc]init];
    self.vc1.delegate = self;
    self.vc2 = [[NvMyMusicViewController alloc]init];
    self.vc2.delegate = self;
    
    view = [[NvTabScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-44-NV_STATUSBARHEIGHT)];
    view.delegate = self;
    ///设置滑动条的颜色
    ///Sets the color of the slider
    view.sliderViewColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    view.titileColror = [UIColor whiteColor];
    view.selectedColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    if (self.musiclyric) {
        [view createView:@[NvLocalString(@"MyMusic", @"我的音乐")] andViewArr:@[self.vc2] andRootVc:self hiddenHeader:self.musiclyric];
    } else {
        [view createView:@[NvLocalString(@"LocalMusic", @"本地音乐"),NvLocalString(@"MyMusic", @"我的音乐")] andViewArr:@[self.vc1,self.vc2] andRootVc:self hiddenHeader:NO];
    }
    
    [self.view addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(@0);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(self.view.mas_bottom);
        }
    }];
    
    ///自动滑动到第二页
    ///Automatically slides to the second page
    if (self.musiclyric) {
        [view sliderToViewIndex:0];
    } else {
        [view sliderToViewIndex:1];
    }
    
    [self.view addSubview:self.audioPlayerView];
    self.audioPlayerView.delegate = self;
    [self.audioPlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(self.view.mas_bottom);
        }
        make.left.right.equalTo(@0);
        make.height.equalTo(@(95*SCREENSCALE));
    }];
    
    self.audioPlayerView.hidden = YES;
    self.audioPlayer = [[NvAudioPlayer alloc] init];
    self.audioPlayer.delegate = self;
    [self.audioPlayerView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateNotMusicState)]) {
        UIButton *btn = (UIButton *)self.navigationItem.rightBarButtonItem.customView;
        BOOL state = [self.delegate updateNotMusicState];
        btn.enabled = state;
        if (state) {
            
        }else{
            [btn setTitleColor:[UIColor nv_colorWithHexRGB:@"#676767"] forState:UIControlStateNormal];
        }
    }
}

- (UIView *)rightNavigationBarItemView {
    UIButton *backButton = [UIButton nv_buttonWithTitle:NvLocalString(@"NoMusic", @"无音乐") textColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] fontSize:15 image:nil];
    backButton.frame = CGRectMake(0, 0, 65, 44);
    __weak typeof(self)weakSelf = self;
    [backButton nv_BtnClickHandler:^{
        if ([weakSelf.delegate respondsToSelector:@selector(selectNoneMusic)]) {
            [weakSelf.delegate selectNoneMusic];
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    return backButton;
}

- (void)setHiddenTrimButton:(BOOL)hiddenTrimButton {
    _hiddenTrimButton = hiddenTrimButton;
    [self.audioPlayerView hiddenHandleButton];
}

- (void)showCutHandleImage {
    [self.audioPlayerView showCutHandleImage];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"hidden"]) {
        BOOL hidden = [change[NSKeyValueChangeNewKey] boolValue];
        if (hidden) {
            [self.audioPlayer pause];
            [view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(@0);
                if (@available(iOS 11.0, *)) {
                    make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
                } else {
                    // Fallback on earlier versions
                    make.bottom.equalTo(self.view.mas_bottom);
                }
            }];
        } else {
            [view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(@0);
                make.bottom.equalTo(self.audioPlayerView.mas_top);
            }];
            [self.audioPlayer play];
            if (self.myItem.isPlay) {
                [self.audioPlayerView renderViewWithItem:self.myItem];
            } else {
                [self.audioPlayerView renderViewWithItem:self.localItem];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// MARK: NvTabScrollViewDelegate
-(void)sliderViewAndReloadData:(NSInteger)index {
    if (index == 0) {
        [self.vc1 reloadData];
    } else {
        [self.vc2 reloadData];
    }
}

#pragma mark - NvMyMusicViewControllerDelegate
///切换播放的回调
///Toggle playback callbacks
- (void)nvMyMusicViewController:(NvMyMusicViewController *)nvMyMusicViewController playItem:(NvEditSelectMusicItem *)item {
    if (self.myItem != item) {
        self.myItem.isPlay = NO;
    }
    
    self.myItem = item;
    self.localItem.isPlay = NO;
    [nvMyMusicViewController reloadData];
    if (self.myItem.isPlay) {
        [self.audioPlayer setUrlString:self.myItem.musicPath];
        [self.audioPlayerView setLeftValue:0 rightValue:100];
        self.trimOut = self.audioPlayer.duration;
        self.audioPlayerView.hidden = NO;
    } else {
        self.audioPlayerView.hidden = YES;
    }
    
    if (self.hiddenTrimButton) {
        [self.audioPlayerView hiddenHandleButton];
        [self.audioPlayerView setCutHandleImageValue:0];
    }
}

- (void)nvLocalMusicViewController:(NvLocalMusicViewController *)nvLocalMusicViewController playItem:(NvEditSelectMusicItem *)item {
    if (self.localItem != item) {
        self.localItem.isPlay = NO;
    }
    
    self.localItem = item;
    self.myItem.isPlay = NO;
    [nvLocalMusicViewController reloadData];
    if (self.localItem.isPlay) {
        [self.audioPlayer setUrlString:self.localItem.musicPath];
        
        [self.audioPlayerView setLeftValue:0 rightValue:100];
        self.trimOut = self.audioPlayer.duration;
        self.audioPlayerView.hidden = NO;
    } else {
        self.audioPlayerView.hidden = YES;
    }
    
    if (self.hiddenTrimButton) {
        [self.audioPlayerView hiddenHandleButton];
        [self.audioPlayerView setCutHandleImageValue:0];
    }
}

#pragma mark - NvAudioPlayerDelegate
///当前播放的位置
///The current playing position
- (void)nvAudioPlayer:(NvAudioPlayer *)player currentTime:(double)currentTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.audioPlayerView.currentValue = currentTime;
        if (currentTime>self.trimOut) {
            [self.audioPlayer seekToTime:self.trimIn];
        }
    });
}
///播放到末尾
///Play to the end
- (void)nvAudioPlayerPlayEOF:(NvAudioPlayer *)player {
    [self.audioPlayer seekToTime:self.trimIn];
    [self.audioPlayer play];
}

#pragma mark - NvAudioPlayerViewDelegate
///裁剪时拖动左滑块
///Drag the left slider while cropping
- (void)audioPlayerView:(NvAudioPlayerView *)audioPlayerView leftValueChanged:(float)value {
    [self.audioPlayer seekToTime:value];
    if (self.trimOut == 0) {
        if (self.localItem.isPlay) {
            self.trimOut = self.localItem.duration;
        } else {
            self.trimOut = self.myItem.duration;
        }
    }
    self.trimIn = value;
    [self.audioPlayer play];
}
///裁剪时拖动右滑块
///Drag the right slider while cropping
- (void)audioPlayerView:(NvAudioPlayerView *)audioPlayerView rightValueChanged:(float)value {
    self.trimOut = value;
    NSLog(@"%f",value);
}
///(trimIn,trimOut为秒)
///(trimIn,trimOut is seconds)
- (void)audioPlayerView:(NvAudioPlayerView *)audioPlayerView withItem:(NvEditSelectMusicItem *)item trimIn:(float)trimIn trimOut:(float)trimOut {
    self.audioPlayerView.hidden = YES;
    item.isPlay = NO;
    [self.vc1 reloadData];
    [self.vc2 reloadData];
    if ([self.delegate respondsToSelector:@selector(selectMusicViewController:withItem:trimIn:trimOut:)]) {
        [self.delegate selectMusicViewController:self withItem:item trimIn:trimIn trimOut:trimOut];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)audioPlayerView:(NvAudioPlayerView *)audioPlayerView imageHandlePanChanged:(float)value {
    self.trimIn = value;
    self.trimOut = self.trimIn + 15*NV_TIME_BASE;
    [self.audioPlayer seekToTime:self.trimIn];
    [self.audioPlayer play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: Getter
-(NvAudioPlayerView *)audioPlayerView {
    if (!_audioPlayerView) {
        _audioPlayerView = [NvAudioPlayerView new];
    }
    return _audioPlayerView;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
