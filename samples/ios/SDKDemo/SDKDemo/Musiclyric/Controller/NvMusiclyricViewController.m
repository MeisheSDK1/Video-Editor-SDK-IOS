//
//  NvMusiclyricViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/12/24.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMusiclyricViewController.h"
#import <NvSDKCommon/NvLiveWindowPanelView.h>
#import "NvAlbumItem.h"
#import "NvsVideoTrack.h"
#import "NvsVideoClip.h"
#import "NvTimelineUtils.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvSelectMusicViewController.h"
#import "NvCaptureFilterView.h"
#import "NvCaptionStyleModel.h"
#import <NvSDKCommon/NvAssetManager.h>
#import "NvsAudioClip.h"
#import <NvSDKCommon/NvCompileViewController.h>
#import <NvBaseCommon/NvToast.h>
#import "NvsEffectSdkContext.h"
#import "NvMusicLrc.h"

@interface NvMusiclyricViewController ()<NvSelectMusicViewControllerDelegate, NvCaptureFilterViewDelegate, NvLiveWindowPanelViewDelegate, NvCompileViewControllerDelegate>

@property (nonatomic, strong) NvCaptureFilterView *styleCollectionView;
@property (nonatomic, strong) NSMutableArray *lyricCaptionArray;
@property (nonatomic, strong) NSMutableArray *styleCaptionArray;
@property (nonatomic, strong) NvCaptionStyleModel *currentStyleModel;

@property (nonatomic, strong) UILabel *musicLabel;
@property (nonatomic, strong) UISlider *musicSlider;
@property (nonatomic, strong) UILabel *originLabel;
@property (nonatomic, strong) UISlider *originSlider;

@property (nonatomic, strong) NSString *compileFilePath;

@property (nonatomic, strong) NvMusicLrc *nvMusicLrc;
@property (nonatomic, strong) UIButton *compileButton;
//-----------------sdk相关 SDK-related----------------//
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) NvLiveWindowPanelView *windowPanelView;
@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, strong) NvAssetManager *assetManager;

@end

@implementation NvMusiclyricViewController

- (void)dealloc{
    NSLog(@"%s",__func__);
    [self.streamingContext removeTimeline:self.timeline];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nvMusicLrc = [[NvMusicLrc alloc]init];
    self.lyricCaptionArray = [[NSMutableArray alloc]init];
    self.styleCaptionArray = [[NSMutableArray alloc]init];
    self.title = NvLocalString(@"Lyrics subtitles", @"歌词字幕");
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.streamingContext = [NvsStreamingContext sharedInstance];
    
    [self addSubViews];
    [self initTimeline];
    
    self.assetManager = [NvAssetManager sharedInstance];
    NSString *packagePath = [[NSBundle mainBundle] pathForResource:@"MusiclyricPackage" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_CAPTION_STYLE bundlePath:packagePath];
    
    [self configDataSource];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addObservers];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.streamingContext stop];
}

- (UIView *)rightNavigationBarItemView {
    self.compileButton = [UIButton nv_buttonWithTitle:NvLocalString(@"Compile", @"生成") textColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] fontSize:16 image:nil];
    self.compileButton.frame = CGRectMake(0, 0, 30, 44);
    self.compileButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15*SCREENSCALE);
    [self.compileButton addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.compileButton.exclusiveTouch = YES;
    return self.compileButton;
}

#pragma mark - rightBtnClicked
- (void)rightBtnClicked {
    self.compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NvCompileViewController *compileViewController = [NvCompileViewController new];
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compileTimeline:_timeline outputPath:self.compileFilePath];
}

#pragma mark - NvCompileViewControllerDelegate
- (void)compileFinished:(BOOL)needDelete {
    [self connectLiveWindow];
    NVWeakSelf
    if (needDelete) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
            [[NSFileManager defaultManager] removeItemAtPath:weakSelf.compileFilePath error:nil];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
            UISaveVideoAtPathToSavedPhotosAlbum(weakSelf.compileFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        });
    }
}

- (void)connectLiveWindow {
    if (!self.timeline) {
        return;
    }
    [self.windowPanelView connectTimeline:self.timeline];
    [self seekTimeline];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}

#pragma mark 添加子视图
///Add subview
- (void)addSubViews{
    self.windowPanelView = [[NvLiveWindowPanelView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH)];
    self.windowPanelView.editMode = self.editMode;
    self.windowPanelView.liveWindow.hdrDisplayMode = NvsLiveWindowHDRDisplayMode_SDR;
    self.windowPanelView.delegate = self;
    [self.windowPanelView showControllPanel];
    [self.view addSubview:self.windowPanelView];
    
    UIView *bottomView = [[UIView alloc]init];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-22*SCREENSCALE);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    
    UIButton *musicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [musicBtn addTarget:self action:@selector(musicBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [musicBtn setImage:NvImageNamed(@"NvMusiclyricMusic") forState:UIControlStateNormal];
    [bottomView addSubview:musicBtn];
    [musicBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomView.mas_top);
        make.left.equalTo(bottomView.mas_left).offset(49 * SCREENSCALE);
        make.width.offset(49 * SCREENSCALE);
        make.height.offset(49 * SCREENSCALE);
    }];
    
    UILabel *musicLabel = [[UILabel alloc]init];
    musicLabel.textColor = UIColor.whiteColor;
    musicLabel.text = NvLocalString(@"Music", @"音乐");
    musicLabel.font = [NvUtils regularFontWithSize:12];
    musicLabel.alpha = 0.8;
    musicLabel.numberOfLines = 2;
    [bottomView addSubview:musicLabel];
    [musicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(musicBtn.mas_bottom).offset(8 * SCREENSCALE);
        make.centerX.equalTo(musicBtn.mas_centerX);
        make.bottom.equalTo(bottomView.mas_bottom);
    }];
    
    UIButton *styleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [styleBtn addTarget:self action:@selector(styleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [styleBtn setImage:NvImageNamed(@"NvMusiclyricStyle") forState:UIControlStateNormal];
    [bottomView addSubview:styleBtn];
    [styleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomView.mas_top);
        make.right.equalTo(bottomView.mas_right).offset(-49 * SCREENSCALE);
        make.width.offset(49 * SCREENSCALE);
        make.height.offset(49 * SCREENSCALE);
    }];
    
    UILabel *styleLabel = [[UILabel alloc]init];
    styleLabel.textColor = UIColor.whiteColor;
    styleLabel.text = NvLocalString(@"Style", @"样式");
    styleLabel.font = [NvUtils regularFontWithSize:12];
    styleLabel.alpha = 0.8;
    styleLabel.numberOfLines = 2;
    [bottomView addSubview:styleLabel];
    [styleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(styleBtn.mas_bottom).offset(8 * SCREENSCALE);
        make.centerX.equalTo(styleBtn.mas_centerX);
        make.bottom.equalTo(bottomView.mas_bottom);
    }];
    
    UIView *styleBottomView = [[UIView alloc]init];
    styleBottomView.backgroundColor = self.view.backgroundColor;
    styleBottomView.tag = 1001;
    styleBottomView.hidden = YES;
    [self.view addSubview:styleBottomView];
    [styleBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.top.equalTo(self.windowPanelView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    
    UIButton *finshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [finshBtn setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [finshBtn addTarget:self action:@selector(finshClick:) forControlEvents:UIControlEventTouchUpInside];
    [styleBottomView addSubview:finshBtn];
    [finshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(styleBottomView.mas_bottom).offset(-12 * SCREENSCALE);
        make.centerX.equalTo(styleBottomView.mas_centerX);
        make.width.offset(25 * SCREENSCALE);
        make.height.offset(20 * SCREENSCALE);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [styleBottomView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(finshBtn.mas_top).offset(- 12 * SCREENSCALE);
        make.width.offset(SCREENWIDTH);
        make.height.offset(0.5);
    }];
    
    //-------------样式按钮点击显示视图 Style button click Display View-----------------//
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(49*SCREENSCALE, 120*SCREENSCALE);
    layout.minimumLineSpacing = 24*SCREENSCALE;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 13, 0, 0);
    
    self.styleCollectionView = [[NvCaptureFilterView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 120 * SCREENSCALE) HaveTopView:NO WithTopViewHeight:0 withMore:NO withlayout:layout];
    self.styleCollectionView.delegate = self;
    [self.styleCollectionView backColor:self.view.backgroundColor];
    [styleBottomView addSubview:self.styleCollectionView];
    [self.styleCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(line.mas_top);
        make.width.offset(SCREENWIDTH);
        make.height.offset(120 * SCREENSCALE);
    }];
    //-----------------------------------------------//
    
    //---------------音量按钮点击显示视图 Volume button click Display view----------------//
    self.musicLabel = [[UILabel alloc]init];
    self.musicLabel.textColor = UIColor.whiteColor;
    self.musicLabel.text = NvLocalString(@"Music", @"音乐");
    self.musicLabel.font = [NvUtils regularFontWithSize:12];
    self.musicLabel.alpha = 0.8;
    [styleBottomView addSubview:self.musicLabel];
    [self.musicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(styleBottomView.mas_left).offset(14 * SCREENSCALE);
        make.bottom.equalTo(line.mas_top).offset(-53 * SCREENSCALE);
    }];
    
    self.musicSlider = [UISlider new];
    self.musicSlider.value = 1;
    [self.musicSlider setMinimumValue:0];
    [self.musicSlider setMaximumValue:1];
    self.musicSlider.minimumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    self.musicSlider.maximumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    [self.musicSlider setThumbImage:NvImageNamed(@"NvSliderIcon") forState:UIControlStateNormal];
    [self.musicSlider addTarget:self action:@selector(musicSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [styleBottomView addSubview:self.musicSlider];
    [self.musicSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.musicLabel.mas_right).offset(15 * SCREENSCALE);
        make.right.equalTo(styleBottomView.mas_right).offset(- 14 * SCREENSCALE);
        make.centerY.equalTo(self.musicLabel);
    }];
    
    self.originLabel = [[UILabel alloc]init];
    self.originLabel.textColor = UIColor.whiteColor;
    self.originLabel.text = NvLocalString(@"Origin", @"原声");
    self.originLabel.font = [NvUtils regularFontWithSize:12];
    self.originLabel.alpha = 0.8;
    [styleBottomView addSubview:self.originLabel];
    [self.originLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.musicLabel.mas_leading);
        make.bottom.equalTo(self.musicLabel.mas_top).offset(-25 * SCREENSCALE);
    }];
    
    self.originSlider = [UISlider new];
    self.originSlider.value = 1;
    [self.originSlider setMinimumValue:0];
    [self.originSlider setMaximumValue:1];
    self.originSlider.minimumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    self.originSlider.maximumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    [self.originSlider setThumbImage:NvImageNamed(@"NvSliderIcon") forState:UIControlStateNormal];
    [self.originSlider addTarget:self action:@selector(musicSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [styleBottomView addSubview:self.originSlider];
    [self.originSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.musicSlider.mas_leading);
        make.right.equalTo(styleBottomView.mas_right).offset(- 14 * SCREENSCALE);
        make.centerY.equalTo(self.originLabel);
    }];
    
    //-----------------------------------------------//
    
    [self.styleCollectionView configDataSource:self.styleCaptionArray];
}

#pragma mark - 创建timeline
///Create timeline
- (void)initTimeline{
    self.timeline = [NvTimelineUtils createTimelineOrdinary:self.editMode];
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    if (videoTrack == nil) {
        return;
    }
    
    for (int i = 0 ; i < self.selectAssets.count; i++) {
        NvAlbumAsset *asset = self.selectAssets[i];
        [videoTrack appendClip:asset.asset.localIdentifier];
    }
    
    [self.windowPanelView connectTimeline:self.timeline];
    self.windowPanelView.currentTime = 0;
    [self seekTimeline:0];
}

#pragma mark - musicBtnClick
- (void)musicBtnClick:(UIButton *)sender{
    NvSelectMusicViewController *selectMusic = NvSelectMusicViewController.new;
    selectMusic.musiclyric = YES;
    selectMusic.delegate = self;
    [self.navigationController pushViewController:selectMusic animated:YES];
}

#pragma mark - styleBtn
- (void)styleBtnClick:(UIButton *)sender{
    [self configBottomView:0];
}

#pragma mark - NvLiveWindowPanelViewDelegate
- (void)volumnClicked{
    [self configBottomView:1];
}

#pragma mark - 配置底部视图
///Configuration bottom view
///type:0==样式，1==音量
///type:0== style, 1== volume
- (void)configBottomView:(NSInteger)type{
    [self.view viewWithTag:1001].hidden = NO;
    if (type == 0) {
        self.styleCollectionView.hidden = NO;
        self.musicLabel.hidden = YES;
        self.musicSlider.hidden = YES;
        self.originLabel.hidden = YES;
        self.originSlider.hidden = YES;
    }else{
        self.styleCollectionView.hidden = YES;
        self.musicLabel.hidden = NO;
        self.musicSlider.hidden = NO;
        self.originLabel.hidden = NO;
        self.originSlider.hidden = NO;
    }
}

#pragma mark 配置字幕样式数据
///Configure the subtitle style data
- (void)configDataSource{
    NSArray *packageName = @[
        @"E895DACC-0AFC-48D0-A397-BBC416A5F8A5",
        @"E2A0505C-80DE-4AF3-8F4C-CFE7ECF67AC3",
        @"4B4348C0-33D5-459E-8003-A3A1FE2186B1",
        @[@"41CB346F-6111-4633-AA6B-DB6165E6804D",
          @"97D562AE-9D7D-4074-B912-B554B3EEE69A"],
        @"F67275C8-04E7-4717-9EC5-BF5B24A486BB",
        @"8AD8B89F-128F-488B-9A73-883680B2C0CF"];
    NSArray *displayName = @[
        NvLocalString(@"None", @"无") ,
        NvLocalString(@"Setting sun", @"斜阳"),
        NvLocalString(@"Smoke", @"烟云"),
        NvLocalString(@"Happy", @"嘻哈"),
        NvLocalString(@"Confession", @"告白"),
        NvLocalString(@"Time", @"时光")
    ];
    for (int i = 0; i < displayName.count; i++) {
        NvCaptionStyleModel * model = [[NvCaptionStyleModel alloc]init];
        model.selected = NO;
        model.coverName = @"NvEditMusic";
        if (i != 0 && i != 3) {
            model.packageArray = @[packageName[i]];
        }else{
            if (i == 0) {
                model.coverName = @"NvsFilterNone";
                model.packageArray = @[packageName[i]];
            }else if (i == 3){
                model.packageArray = packageName[i];
            }
        }
        model.displayName = displayName[i];
        model.state = Finish;
        [self.styleCaptionArray addObject:model];
    }
    self.currentStyleModel = [self.styleCaptionArray firstObject];
}

#pragma mark - finshClick
- (void)finshClick:(UIButton *)sender{
    [self.view viewWithTag:1001].hidden = YES;
}

#pragma mark - 音乐、原声统一回调事件
///Music, soundtrack unified callback event
- (void)musicSliderValueChanged:(UISlider *)slider{
    if ([slider isEqual:self.musicSlider]) {
        NvsAudioTrack *musicTrack = [self.timeline getAudioTrackByIndex:0];
        [musicTrack setVolumeGain:slider.value rightVolumeGain:slider.value];
    }else if([slider isEqual:self.originSlider]){
        NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
        [videoTrack setVolumeGain:slider.value rightVolumeGain:slider.value];
    }
}

#pragma mark NvCaptureFilterViewDelegate
- (void)NvCaptureFilterView:(NvCaptureFilterView *)view withFilterModel:(NvBaseModel *)model{
    NvCaptionStyleModel *captionStyleModel = (NvCaptionStyleModel *)model;
    NvsTimelineCaption* caption = [self.timeline getFirstCaption];
    while (caption) {
        caption = [self.timeline removeCaption:caption];
    }
    
    [self configCaptionStylePackageId:captionStyleModel.packageArray];
    
    self.currentStyleModel = captionStyleModel;
    [self playTimeline];
}

#pragma mark - seekTimeline
- (void)seekTimeline:(int64_t)postion {
    if (![_streamingContext seekTimeline:self.timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame]){
        
    }
}

#pragma mark - seekTimeline
- (void)seekTimeline{
    if (![_streamingContext seekTimeline:self.timeline timestamp:[self.streamingContext getTimelineCurrentPosition:self.timeline] videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame]){
        
    }
}

#pragma mark - playTimeline
- (void)playTimeline:(int64_t)postion{
    [self.windowPanelView playAtTime:postion];
}

#pragma mark - playTimeline
- (void)playTimeline{
    [self.windowPanelView playAtTime:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
}


#pragma mark - NvSelectMusicViewControllerDelegate
- (void)selectMusicViewController:(NvSelectMusicViewController *)selectMusicViewController withItem:(NvEditSelectMusicItem *)item trimIn:(float)trimIn trimOut:(float)trimOut {
    [self.lyricCaptionArray removeAllObjects];
    NvsTimelineCaption* caption = [self.timeline getFirstCaption];
    while (caption) {
        caption = [self.timeline removeCaption:caption];
    }
    
    NvsAudioTrack *musicTrack = [self.timeline getAudioTrackByIndex:0];
    [musicTrack setVolumeGain:self.musicSlider.value rightVolumeGain:self.musicSlider.value];
    [musicTrack removeAllClips];
    NvsAudioClip *clip = [musicTrack appendClip:item.musicPath
                                         trimIn:trimIn*NV_TIME_BASE
                                        trimOut:trimOut*NV_TIME_BASE];
    [clip setVolumeGain:1 rightVolumeGain:1];
    
    [self configMusicCaption:item.musicName withTrimIn:trimIn*NV_TIME_BASE withTrimOut:trimOut*NV_TIME_BASE withDuration:item.duration * NV_TIME_BASE];
    
    [self playTimeline:0];
}

- (void)selectNoneMusic {
    [self dismissViewControllerAnimated:YES completion:NULL];
    NvsAudioTrack *musicTrack = [self.timeline getAudioTrackByIndex:0];
    [musicTrack removeAllClips];
    [self.lyricCaptionArray removeAllObjects];
    NvsTimelineCaption* caption = [self.timeline getFirstCaption];
    while (caption) {
        caption = [self.timeline removeCaption:caption];
    }
    [self playTimeline:0];
}

#pragma mark - 分析歌词文件，给timeline添加歌词字幕
///分析歌词文件，给timeline添加歌词字幕
///Analyze the lyrics file and add lyrics subtitles to the timeline
- (void)configMusicCaption:(NSString *)musicName withTrimIn:(int64_t)trimIn withTrimOut:(int64_t)trimOut withDuration:(int64_t)duration{
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"music" ofType:@"bundle"];
    musicPath = [musicPath stringByAppendingPathComponent:[musicName stringByAppendingString:@".lrc"]];
    if(musicPath == nil) {
        NSLog(@"%@", @"lrcFilePath is nil");
        return;
    }
    NSFileManager* fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:musicPath]) {
        NSLog(@"%@", @"file is not exist");
        return;
    }
    
    NSMutableArray *mutableArray = [self.nvMusicLrc configMusicPath:musicPath withTrimIn:trimIn withTrimOut:trimOut withduration:duration];
   
    [self trimMusiclyricCaption:mutableArray withTrimIn:0 withTrimOut:self.timeline.duration withMusicTrim:trimIn != 0 ? YES:NO];
    [self configCaptionStylePackageId:self.currentStyleModel.packageArray];
}

#pragma mark 根据timeline的TrimIn、TrimOut，第二次筛选歌词字幕
/**
 根据timeline的TrimIn、TrimOut，第二次筛选歌词字幕
 According to TrimIn and TrimOut of timeline, the lyrics subtitles are screened for the second time

 @param array 歌词字幕数组
 Lyric subtitle array
 @param trimIn 视频的裁入点
 The crop point of the video
 @param trimOut 视频的裁出点
 The cropping point of the video
 */
- (void)trimMusiclyricCaption:(NSMutableArray *)array withTrimIn:(int64_t)trimIn withTrimOut:(int64_t)trimOut withMusicTrim:(BOOL)isTrim{
    int64_t duration = trimOut - trimIn;
    int64_t cuttentDuration = 0;
    for (int i = 0; i < array.count; i++) {
        NvLyricCaptionModel *captionModel = array[i];
        cuttentDuration += captionModel.continuousTime;
        if (cuttentDuration <= duration) {
            if (i == 0) {
                if (isTrim) {
                    captionModel.inPoint = trimIn;
                }else{
                    captionModel.inPoint = trimIn + captionModel.startTime;
                    cuttentDuration += captionModel.startTime;
                }
            }else{
                captionModel.inPoint = cuttentDuration - captionModel.continuousTime + trimIn;
            }
            captionModel.duration = captionModel.continuousTime;
            [self.lyricCaptionArray addObject:captionModel];
        }else{
            if (i == 0) {
                captionModel.inPoint = trimIn;
                captionModel.duration = duration;
            }else{
                captionModel.inPoint = cuttentDuration - captionModel.continuousTime + trimIn;
                captionModel.duration = duration - captionModel.inPoint;
            }
            [self.lyricCaptionArray addObject:captionModel];
        }
        
        NSLog(@"%lld",captionModel.inPoint);
    }
}

#pragma mark - 传一个字幕样式数组，根据timeline，添加歌词字幕
///Pass an array of caption styles and add lyrics to the caption according to timeline
- (void)configCaptionStylePackageId:(NSArray *)packageIdArray {
    if (![NvsEffectSdkContext functionalityAuthorised:@"lyrics"]) {
        NSLog(@"Functionality lyrics is not authorised!");
        return;
    }
    for (int i = 0; i < self.lyricCaptionArray.count; i++) {
        NvLyricCaptionModel *captionModel = self.lyricCaptionArray[i];
        for (NSString *packageId in packageIdArray) {
            [self.timeline addCaption:captionModel.captionText inPoint:captionModel.inPoint duration:captionModel.duration captionStylePackageId:packageId];
        }
    }
}

- (NSMutableArray*)parseWithPath:(NSString*)path {
    NSMutableArray* list = [[NSMutableArray alloc] init];
    NSFileManager* fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:path]) {
        return nil;
    }
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray* arr = [content componentsSeparatedByString:@"\n"];
    NSString* regex = @"\\[(\\d{1,2}):(\\d{1,2}).(\\d{1,2})\\]";
    NSError* error;
    NSRegularExpression* exp = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:&error];
    if(!error) {
        for(NSString* oneLine in arr) {
            NSTextCheckingResult* match = [exp firstMatchInString:oneLine options:0 range:NSMakeRange(0, [oneLine length])];
            
            if(match) {
                NSString* result = [oneLine substringWithRange:match.range];
                NSString* text = [oneLine stringByReplacingOccurrencesOfString:result withString:@""];
                
                result = [[result stringByReplacingOccurrencesOfString:@"[" withString:@""] stringByReplacingOccurrencesOfString:@"]" withString:@""];
                NSArray *timeComponent = [result componentsSeparatedByString:@":"];
            
                NSArray *array = [timeComponent.lastObject componentsSeparatedByString:@"."];
                NSString* min =timeComponent[0];
                NSString* sec =array[0];
                NSString* mill =[array[1] stringByAppendingString:@"0"];
                
                int64_t time = [self getLongTime:min sec:sec mill:mill];
                text = [text stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                if (text) {
                    if (text.length != 0 && ![text isEqualToString:@""]) {
                        NSMutableDictionary* map = [[NSMutableDictionary alloc] init];
                        [map setObject:text forKey:@(time)];
                        [list addObject:map];
                    }
                }
            }
        }
        return list;
    } else {
        NSLog(@"error - %@", error);
    }
    
    return nil;
}

- (int64_t)getLongTime:(NSString*)min sec:(NSString*)sec mill:(NSString*)mill {
    int m = [min intValue];
    int s = [sec intValue];
    int ms = [mill intValue];
    
    if(s >= 60) {
        NSLog(@"s >= 60");
    }
    int64_t time = (m*60*1000 + s*1000 + ms) * 1000;
    return time;
}

#pragma mark - 注册应用前台后台通知事件
///Register application foreground background notification events
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

///应用进入后台，停止引擎
///The application enters the background and stops the engine
- (void)applicationWillResignActive:(NSNotification*)notification {
    if ([_streamingContext getStreamingEngineState] == NvsStreamingEngineState_Playback) {
        [_streamingContext stop];
    }
}

///应用进入前台，开始播放
///The app enters the foreground and starts playing
- (void)applicationWillEnterForeground:(NSNotification*)notification {
    if (![self.windowPanelView isUserPause]) {
        if ([_streamingContext getStreamingEngineState] == NvsStreamingEngineState_Stopped) {
            [self playTimeline];
        }
    }
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
