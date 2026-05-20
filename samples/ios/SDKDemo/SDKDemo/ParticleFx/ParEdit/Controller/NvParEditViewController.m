//
//  NvParEditViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/9/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvParEditViewController.h"
#import "NvsParticleSystemContext.h"
#import "NvTimelineUtils.h"
#import "NvParticleThumbnail.h"
#import "NvCanvasView.h"
#import <NvSDKCommon/NvCompileViewController.h>
#import "NvParCaptureViewController.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import <NvSDKCommon/NvAssetManager.h>

#import "NvParticleModel.h"
#import "NvParticleAssetCell.h"
#import "NvsTimelineVideoFx.h"

@interface NvParEditViewController ()<NvsStreamingContextDelegate,UICollectionViewDelegate,UICollectionViewDataSource,NvCanvasViewDelegate,NvParticleThumbnailDelegate,NvCompileViewControllerDelegate,NvAssetManagerDelegate>

///头视图
///Head view
@property (nonatomic, strong) UIView *headerView;
///退出
///exit
@property (nonatomic, strong) UIButton *backBtn;
///播放按钮
///Play button
@property (nonatomic, strong) UIButton *playBtn;
///生成按钮
///Generate button
@property (nonatomic, strong) UIButton *compileBtn;

///缩略图控件
///Thumbnail control
@property (nonatomic, strong) NvParticleThumbnail *effectWrapper;
///撤销
///revocation
@property (nonatomic, strong) UIButton *undoBtn;

///粒子视图
///Particle view
@property (nonatomic, strong) UIView *particlePanelView;
///速率，强度的面板视图
///Rate, intensity panel view
@property (nonatomic, strong) UIView *particleHeaderView;
///滤镜强度
///Filter strength
@property (nonatomic, strong) UISlider *filterStrengthSlider;
///强度
///strength
@property (nonatomic, strong) UILabel *filterStrengthLabel;
///滤镜速率
///Filter rate
@property (nonatomic, strong) UISlider *filterSpeeadSlider;
///速率
///speed
@property (nonatomic, strong) UILabel *filterSpeeadLabel;
///粒子特效滑动视图
///Particle effects slide view
@property (nonatomic, strong) UICollectionView *particleCollectionView;
///涂鸦特效数组
///Doodle effects array
@property (nonatomic, strong) NSMutableArray *graffitiFxArray;

///livewindow的外层view
///The outer view of the livewindow
@property (nonatomic, strong) UIView *liveWindowView;
@property (nonatomic, strong) NvsLiveWindow *liveWindow;
///画布
///canvas
@property (nonatomic, strong) NvCanvasView *canvasView;

//-----------------逻辑相关  Logical correlation -----------------//
///当前粒子特效
///Current particle effect
@property (nonatomic, strong) NvParticleModel *currentItem;
///裁入点时间
///Cut in time
@property (nonatomic, assign) int64_t startInpoint;
///添加到时间线上的粒子特效
///Particle effects added to the timeline
@property (nonatomic, strong) NSMutableArray *particleFxArray;
///当前时间线上的粒子特效
///Particle effects in the current timeline
@property (nonatomic, strong) NvParticleInfoModel *currentInfoModel;
///当前时间线特效
///Current timeline effects
@property (nonatomic, strong) NvsTimelineVideoFx *timelineVideo;
///生成路径
///Generating path
@property (nonatomic, strong) NSString *compileFilePath;

//-----------------sdk相关 SDK-related----------------//
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
///素材管理
///Material management
@property (nonatomic, strong) NvAssetManager *assetManager;
///粒子特效
///Particle effect
@property (nonatomic, strong) NvsCaptureVideoFx *videoFx;
///粒子上下文
///Particle context
@property (nonatomic, strong) NvsParticleSystemContext *particleContext;
///当前timeline
///Current timeline
@property (nonatomic, strong) NvsTimeline *timeline;

@property (nonatomic, assign) BOOL isChange;
@property (nonatomic, assign) CGFloat scaleForSeek;

@end

@implementation NvParEditViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s",__func__);
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.streamingContext stop];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.graffitiFxArray = [NSMutableArray array];
    self.particleFxArray = [NSMutableArray array];
    
    self.streamingContext = [NvSDKUtils getSDKContext];
    self.streamingContext.delegate = self;
    
    self.assetManager = [NvAssetManager sharedInstance];
    self.assetManager.delegate = self;
    
    [self addParticleArray];
    [self addSubViews];
    [self initTimeline];
    [self addThumbnail];
    [self addParticleView];
    [self addObservers];
    // Do any additional setup after loading the view.
}

#pragma mark 给粒子视图的数组添加数据
///Adds data to the array of particle views
- (void)addParticleArray{
    int large,minor,revision;
    [NvsStreamingContext getSdkVersion:&large minorVersion:&minor revisionNumber:&revision];
    [self.assetManager downloadRemoteAssetsInfo:ASSET_PARTICLE categoryId:2 page:1 pageSize:100 kind:0 modular:NvAssetModularAll ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NSString stringWithFormat:@"%d.%d.%d",large,minor,revision]];
    [self.assetManager searchLocalAssets:ASSET_PARTICLE];
    
    NvParticleModel *item = [NvParticleModel new];
    item.state = Finish;
    item.displayName = NvLocalString(@"None", @"无");
    item.coverName = @"NvsFilterNone";
    item.selected = YES;
    item.isParGraffiti = YES;
    [self.graffitiFxArray addObject:item];
    [self.particleCollectionView reloadData];
}

- (BOOL)isParticleExist:(NSString *)uuid {
    for (NvAsset *model in self.installedFinshArray) {
        if ([model.uuid isEqualToString:uuid])
            return YES;
    }
    return NO;
}

#pragma mark 添加子视图
///Add subview
- (void)addSubViews{
    self.headerView = [[UIView alloc]init];
    self.headerView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.headerView];
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn setImage:NvImageNamed(@"Nvback") forState:UIControlStateNormal];
    self.backBtn.exclusiveTouch = YES;
    [self.headerView addSubview:self.backBtn];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setImage:NvImageNamed(@"NvParticlePlay") forState:UIControlStateNormal];
    [self.playBtn setImage:NvImageNamed(@"NvParticleSuspend") forState:UIControlStateSelected];
    [self.playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.playBtn];
    
    self.compileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.compileBtn setTitle:NvLocalString(@"Compile", @"生成") forState:UIControlStateNormal];
    [self.compileBtn addTarget:self action:@selector(compileBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.compileBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    self.compileBtn.titleLabel.font = [UIFont systemFontOfSize:18 * SCREENSCALE];
    [self.headerView addSubview:self.compileBtn];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.offset(NV_NAV_BAR_HEIGHT + NV_STATUSBARHEIGHT);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView.mas_left).offset(13 * SCREENSCALE);
        make.bottom.equalTo(self.headerView.mas_bottom).offset(-10 * SCREENSCALE);
        make.width.offset(30 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headerView.mas_centerX);
        make.centerY.equalTo(self.backBtn.mas_centerY);
        make.width.offset(30 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    
    [self.compileBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.headerView.mas_right).offset(- 13 * SCREENSCALE);
        make.centerY.equalTo(self.backBtn.mas_centerY);
        make.height.offset(30 * SCREENSCALE);
    }];
    
    self.liveWindowView = [[UIView alloc]init];
    [self.view addSubview:self.liveWindowView];
    [self.liveWindowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.offset(400 * SCREENSCALE);
    }];
    
    self.liveWindow = [[NvsLiveWindow alloc]initWithFrame:CGRectZero];
    [self.liveWindowView addSubview:self.liveWindow];
    
    
}

#pragma mark 创建timeline，绘制livewindow
///Create the timeline to draw the livewindow
- (void)initTimeline{
    [self.liveWindow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.liveWindowView.mas_centerX);
        make.centerY.equalTo(self.liveWindowView.mas_centerY);
        if (self.editMode == NvEditMode16v9) {
            make.width.offset(SCREENWIDTH);
            make.height.offset(SCREENWIDTH * 9 /16);
        }else{
            make.width.offset(400 * SCREENSCALE * 9 / 16);
            make.height.equalTo(self.liveWindowView.mas_height);
        }
    }];
    
    self.canvasView = [[NvCanvasView alloc]init];
    self.canvasView.delegate = self;
    [self.liveWindow addSubview:self.canvasView];
    [self.canvasView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.liveWindow);
        make.right.equalTo(self.liveWindow);
        make.top.equalTo(self.liveWindow);
        make.bottom.equalTo(self.liveWindow);
    }];
    
    self.timeline = [NvTimelineUtils createTimelineOrdinary:self.editMode];
    [self.streamingContext connectTimeline:self.timeline withLiveWindow:self.liveWindow];
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    
    if (videoTrack == nil) {
        return;
    }
    
    for (int i = 0 ; i < self.selectAssets.count; i++) {
        NvAlbumAsset *asset = self.selectAssets[i];
        [videoTrack appendClip:asset.asset.localIdentifier];
    }
    [_streamingContext seekTimeline:_timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:0];
    
}

#pragma mark 添加缩略图控件
///Add a thumbnail control
- (void)addThumbnail{
    self.effectWrapper = [[NvParticleThumbnail alloc]init];
    self.effectWrapper.delegate = self;
    [self.view addSubview:self.effectWrapper];
    [self.effectWrapper mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.liveWindowView.mas_bottom).offset(10 * SCREENSCALE);
        make.left.equalTo(self.view.mas_left).offset(13 * SCREENSCALE);
        make.right.equalTo(self.view.mas_right).offset(-13 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    self.effectWrapper.sequenceView.descArray = [NvTimelineUtils getThumbnailSequenceDescArray:self.timeline];
    self.effectWrapper.sequenceView.pointsPerMicrosecond = (SCREENWIDTH - 26 * SCREENSCALE)/self.timeline.duration;
    self.effectWrapper.colorBarView.timelineDuration = self.timeline.duration;
    
    UILabel *tipLabel = [[UILabel alloc]init];
    tipLabel.text = NvLocalString(@"Picture painting", @"选择位置后，在画面上涂画");
    tipLabel.font = [UIFont systemFontOfSize:12 * SCREENSCALE];
    tipLabel.textColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    [self.view addSubview:tipLabel];
    
    self.undoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.undoBtn addTarget:self action:@selector(undoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.undoBtn setImage:NvImageNamed(@"revertBackgroud") forState:UIControlStateNormal];
    [self.view addSubview:self.undoBtn];
    self.undoBtn.layer.cornerRadius = 18 * SCREENSCALE/2.0;
    self.undoBtn.layer.masksToBounds = YES;
    [self.undoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tipLabel.mas_centerY);
        make.right.equalTo(self.effectWrapper.mas_right);
        make.height.offset(18 * SCREENSCALE);
    }];
    
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.effectWrapper.mas_bottom).offset(17 * SCREENSCALE);
        make.left.equalTo(self.effectWrapper.mas_left);
        make.right.lessThanOrEqualTo(self.undoBtn.mas_left).offset(-15);
    }];
}

#pragma mark - 添加粒子特效滚动视图
///Added particle effects scrolling view
- (void)addParticleView{
    _particlePanelView = [[UIView alloc] init];
    _particlePanelView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#99000000"];
    [self.view addSubview:_particlePanelView];
    [_particlePanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.offset(105 * SCREENSCALE + INDICATOR);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(70*SCREENSCALE, floor(100*SCREENSCALE));
    layout.minimumLineSpacing = 10*SCREENSCALE;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 16*SCREENSCALE, 0, 0);
    _particleCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _particleCollectionView.delegate = self;
    _particleCollectionView.dataSource = self;
    _particleCollectionView.backgroundColor = [UIColor clearColor];
    _particleCollectionView.showsHorizontalScrollIndicator = NO;
    [_particlePanelView addSubview:_particleCollectionView];
    [_particleCollectionView registerClass:[NvParticleAssetCell class] forCellWithReuseIdentifier:@"NvParticleAssetCell"];
    [_particleCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.particlePanelView.mas_top).offset(5 * SCREENSCALE);
        make.height.mas_equalTo(100 * SCREENSCALE);
        make.left.equalTo(self.particlePanelView.mas_left);
        make.right.equalTo(self.particlePanelView.mas_right);
    }];
    
    _particleHeaderView = [[UIView alloc] init];
    _particleHeaderView.hidden = YES;
    _particleHeaderView.backgroundColor = UIColor.blackColor;
    [_particlePanelView addSubview:_particleHeaderView];
    [_particleHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.particlePanelView);
        make.bottom.equalTo(self.particlePanelView);
        make.left.equalTo(self.particlePanelView);
        make.right.equalTo(self.particlePanelView);
    }];
    
    self.filterSpeeadLabel = [[UILabel alloc]initWithFrame:CGRectMake(13 * SCREENSCALE, 17 * SCREENSCALE, 28 * SCREENSCALE, 20 * SCREENSCALE)];;
    _filterSpeeadLabel.text = NvLocalString(@"Number", @"数量");
    _filterSpeeadLabel.font = [UIFont systemFontOfSize:13 * SCREENSCALE];
    _filterSpeeadLabel.textColor = UIColor.whiteColor;
    [_filterSpeeadLabel sizeToFit];
    [_particleHeaderView addSubview:_filterSpeeadLabel];
    
    self.filterSpeeadSlider = [[UISlider alloc]initWithFrame:CGRectMake(55 * SCREENSCALE, 24 * SCREENSCALE, 308 * SCREENSCALE, 10 * SCREENSCALE)];
    [self.filterSpeeadSlider setMinimumValue:0.1];
    [self.filterSpeeadSlider setMaximumValue:6.0];
    self.filterSpeeadSlider.value = 1;
    self.filterSpeeadSlider.minimumTrackTintColor = [UIColor whiteColor];
    self.filterSpeeadSlider.maximumTrackTintColor = [UIColor whiteColor];
    [self.filterSpeeadSlider setThumbImage:NvImageNamed(@"Nvslider") forState:UIControlStateNormal];
    [self.filterSpeeadSlider addTarget:self action:@selector(sliderValueChangedFX:) forControlEvents:UIControlEventValueChanged];
    [_particleHeaderView addSubview:_filterSpeeadSlider];
    
    self.filterStrengthLabel = [[UILabel alloc]initWithFrame:CGRectMake(13 * SCREENSCALE, 43 * SCREENSCALE, 28 * SCREENSCALE, 20 * SCREENSCALE)];;
    _filterStrengthLabel.text = NvLocalString(@"P_Size", @"大小");
    _filterStrengthLabel.font = [UIFont systemFontOfSize:13 * SCREENSCALE];
    _filterStrengthLabel.textColor = UIColor.whiteColor;
    [_filterStrengthLabel sizeToFit];
    [_particleHeaderView addSubview:_filterStrengthLabel];
    
    self.filterStrengthSlider = [[UISlider alloc]initWithFrame:CGRectMake(55 * SCREENSCALE, 50 * SCREENSCALE, 308 * SCREENSCALE, 10 * SCREENSCALE)];
    [self.filterStrengthSlider setMinimumValue:0.1];
    [self.filterStrengthSlider setMaximumValue:6.0];
    self.filterStrengthSlider.value = 1;
    self.filterStrengthSlider.enabled = YES;
    self.filterStrengthSlider.minimumTrackTintColor = [UIColor whiteColor];
    self.filterStrengthSlider.maximumTrackTintColor = [UIColor whiteColor];
    [self.filterStrengthSlider setThumbImage:NvImageNamed(@"Nvslider") forState:UIControlStateNormal];
    [self.filterStrengthSlider addTarget:self action:@selector(sliderValueChangedFX:) forControlEvents:UIControlEventValueChanged];
    [_particleHeaderView addSubview:_filterStrengthSlider];
}

#pragma mark 蒙层——用于收起滤镜强度、速度强度调节控件
///Mask - for folding filter intensity, speed intensity control
- (void)addMontmorillonite{
    UIButton *MontmorilloniteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    MontmorilloniteBtn.backgroundColor = UIColor.clearColor;
    [MontmorilloniteBtn addTarget:self action:@selector(MontmorilloniteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:MontmorilloniteBtn];
    [MontmorilloniteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.particlePanelView.mas_top);
    }];
}

- (void)MontmorilloniteBtnClick:(UIButton *)sender{
    [sender removeFromSuperview];
    self.particleHeaderView.hidden = YES;
}

#pragma mark 滤镜强度、速度强度调节
///Filter strength, speed strength adjustment
- (void)sliderValueChangedFX:(UISlider *)slider{
    NSArray* emitter = [self.currentItem.parser getParticlePartitionEmitter:0];
    if ([slider isEqual:self.filterStrengthSlider]) {
        for (int i = 0; i < emitter.count; i++){
           [self.particleContext SetEmitterParticleSizeGain:emitter[i] emitterGain:slider.value];
        }
    }
    if ([slider isEqual:self.filterSpeeadSlider]) {
        for (int i = 0; i < emitter.count; i++){
            [self.particleContext setEmitterRateGain:emitter[i] emitterGain:slider.value];
        }
    }
}

#pragma mark 播放点击事件
///Play click event
- (void)playBtnClick:(UIButton *)sender{
    if (sender.selected) {
        [self.streamingContext stop];
    }else{
        [NvTimelineUtils playbackTimeline:self.timeline startTime:[self.streamingContext getTimelineCurrentPosition:self.timeline] endTime:self.timeline.duration flags:0];
    }
}

#pragma mark 生成按钮点击事件
///Generate button click events
- (void)compileBtnClick:(UIButton *)sender{
    _compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NvCompileViewController *compileViewController = [NvCompileViewController new];
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compileTimeline:_timeline outputPath:_compileFilePath];
}

#pragma mark 退出
///exit
- (void)backBtnClick:(UIButton *)sender{
    [self.streamingContext stop];
    int index = (int)[[self.navigationController viewControllers]indexOfObject:self];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(index -2)] animated:YES];
}

- (void)connectLiveWindow {
    if (!self.timeline) {
        return;
    }
    
    [self connectTimeline];
    [self.streamingContext seekTimeline:self.timeline timestamp:[self.streamingContext getTimelineCurrentPosition:self.timeline] videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:0];
}

- (void)connectTimeline{
    if (![self.streamingContext connectTimeline:self.timeline withLiveWindow:_liveWindow]) {
        return;
    }
    self.streamingContext.delegate = self;
}

#pragma mark NvAssetManagerDelegate
///获取素材列表成功回调
///Callback successfully obtained material list
- (void)onRemoteAssetsChanged:(BOOL)hasNext {
    NSArray *temporaryArray = [self.assetManager getUsableAssets:ASSET_PARTICLE aspectRatio:AspectRatio_All categoryId:2 kindId:0];
    self.installedFinshArray = [NSMutableArray arrayWithArray:temporaryArray];
    
    for (NvAsset *asset in temporaryArray) {
        NvParticleModel *model = [NvParticleModel new];
        model.packageId = asset.uuid;
        
        model.displayName = asset.displayName;
        if ([model.packageId isEqualToString:@"34B095C8-628A-4E9D-B36D-093F9774DAF7"]) {
            model.displayName = NvLocalString(@"Neon lights", @"霓虹灯");
        }else if ([model.packageId isEqualToString:@"641C5CDE-BF3E-478D-A4C6-B5D5FA3AA9AD"]){
            model.displayName = NvLocalString(@"Golden flash", @"金色闪烁");
        }
        model.coverName = asset.coverUrl;
        model.categoryId = asset.category;
        if (asset.parser) {
            model.parser = asset.parser;
        }else{
            NSString *effectDesc = [self.streamingContext.assetPackageManager GetVideoFxAssetPackageDescription:asset.uuid];
            if (effectDesc == nil || [effectDesc isEqualToString:@""]) {
                NSLog(@"%@",asset.uuid);
                break;
            }
             model.parser = [[NvsAssetPackageParticleDescParser alloc] initWithEffectDesc:effectDesc];
        }
        
        if (asset.color) {
            model.color = asset.color;
        }else{
            model.color = [NvUtils randomColor];
        }
        
        model.isParGraffiti = YES;
        if ([asset isUsable]) {
            if ([asset hasUpdate]) {
                model.state = Update;
            }else{
                model.state = Finish;
            }
        }else{
            model.state = NODownload;
        }
        
        [self.graffitiFxArray addObject:model];
    }
    
    NSArray *array = [self.assetManager getRemoteAssets:ASSET_PARTICLE aspectRatio:AspectRatio_All categoryId:2 kindId:0];

    for (NvAsset *asset in array) {
        if ([self isParticleExist:asset.uuid]){
            continue;
        }
            NvParticleModel *model = [[NvParticleModel alloc]init];
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            model.displayName = asset.displayNamezhCN;
                }else{
                    model.displayName = asset.displayName;
                }
            model.coverDefault = @"NvParticleDefault";
            model.coverName = asset.coverUrl;
            model.size = [NvSDKUtils getAssetPackageSizeString:asset.packageSize];
            model.draw = [NvSDKUtils getAssetAspectRatioString:asset.aspectRatio];
            model.packageId = asset.uuid;
            if (asset.color) {
                model.color = asset.color;
            }else{
                model.color = [NvUtils randomColor];
            }
            
            model.isParGraffiti = YES;
            if ([asset isUsable]) {
                if ([asset hasUpdate]) {
                    model.state = Update;
                }else{
                    model.state = Finish;
                }
            }else{
                model.state = NODownload;
            }
            [self.graffitiFxArray addObject:model];
    }
    [self.particleCollectionView reloadData];
}

///获取素材列表失败回调
///Callback failed to get the material list
- (void)onGetRemoteAssetsFailed{
    
}

///下载素材进度回调
///Download material progress callback
- (void)onDownloadAssetProgress:(NSString *)uuid progress:(int)progress{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.graffitiFxArray.count; i++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            NvParticleAssetCell *cell = (NvParticleAssetCell *)[self.particleCollectionView cellForItemAtIndexPath:indexPath];
            NvParticleModel *model = self.graffitiFxArray[i];
            if ([model.packageId isEqualToString:uuid]) {
                cell.downloadButton.progress = progress/100.f;
            }
        }
    });
}

///下载素材成功回调
///Download material successfully callback
- (void)onDonwloadAssetSuccess:(NSString *)uuid{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.graffitiFxArray.count; i++) {
            NvParticleModel *model = self.graffitiFxArray[i];
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            if ([model.packageId isEqualToString:uuid]) {
                
                NSString *effectDesc = [self.streamingContext.assetPackageManager GetVideoFxAssetPackageDescription:uuid];
                if (effectDesc == nil || [effectDesc isEqualToString:@""]) {
                    NSLog(@"%@",uuid);
                    model.state = NODownload;
                    continue;
                }
                NvsAssetPackageParticleDescParser* parser = [[NvsAssetPackageParticleDescParser alloc] initWithEffectDesc:effectDesc];
                model.state = Finish;
                model.parser = parser;
                if ([self.currentItem isEqual:model]) {
                    model.selected = YES;
                }
            }
            
            [UIView performWithoutAnimation:^{
                [self.particleCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
        }
    });
}

///下载素材失败回调
///Material download failure callback
- (void)onDonwloadAssetFailed:(NSString *)uuid{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.graffitiFxArray.count; i++) {
            NvParticleModel *model = self.graffitiFxArray[i];
            if ([model.packageId isEqualToString:uuid]) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                model.state = NODownload;
                
                if ([self.currentItem isEqual:model]) {
                    self.currentItem = nil;
                }
                
                [UIView performWithoutAnimation:^{
                    [self.particleCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                }];
            }
        }
    });
}

#pragma mark - NvCompileViewControllerDelegate
- (void)compileFinished:(BOOL)needDelete {
    [self connectLiveWindow];
    if (needDelete) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            [[NSFileManager defaultManager] removeItemAtPath:self.compileFilePath error:nil];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            UISaveVideoAtPathToSavedPhotosAlbum(self.compileFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        });
    }
}

#pragma mark 将拍摄的视频保存到本地相册
///Save the video you shot to your local album
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {

        [UIAlertController presentAlertFromVC:self
                                        title:NvLocalString(@"Save failed", @"保存失败")
                                      message:NvLocalString(@"storage", @"请检查手机存储空间")
                            buttonTitleColors:nil
                            cancelButtonTitle:nil
                             otherButtonTitle:NvLocalString(@"Know", @"知道了")
                           cancelButtonAction:nil
                            otherButtonAction:nil];
    }
}

#pragma mark 撤销按钮点击事件
///Undo button click event
- (void)undoBtnClick:(UIButton *)sender{
    if (self.particleFxArray.count != 0 && self.particleFxArray != nil) {
        NvParticleInfoModel *infoModel = [self.particleFxArray lastObject];
        [self seek:infoModel.inPoint];
        self.effectWrapper.sliderView.value = (float)infoModel.inPoint/_timeline.duration;
        self.startInpoint = infoModel.inPoint;
        [self.particleFxArray removeLastObject];
        [self updateColorBarView:self.particleFxArray];
        NvsTimelineVideoFx *lastFx = [self.timeline getLastTimelineVideoFx];
        [self.timeline removeTimelineVideoFx:lastFx];
    }
}

#pragma mark seek
- (void)seek:(int64_t)pos {
    int flags = 0;
    int64_t currentPosition = pos;
    if (pos < 0) {
        currentPosition = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    }
    if (self.isChange) {
        flags = NvsStreamingEngineSeekFlag_AllowFastScrubbing;
        self.scaleForSeek = _timeline.duration / 1000000 /  self.effectWrapper.sequenceView.contentSize.width / UIScreen.mainScreen.scale;
        [self.streamingContext setTimeline:self.timeline scaleForSeek:self.scaleForSeek];
    }
    [self.streamingContext seekTimeline:self.timeline timestamp:currentPosition videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flags];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.graffitiFxArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvParticleAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvParticleAssetCell" forIndexPath:indexPath];
    [cell renderCellWithModel:self.graffitiFxArray[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NvParticleModel *model = self.graffitiFxArray[indexPath.item];
    if (model.state == NvDownloading ||
        model.state == NoUser ||
        model.state == Update ||
        model.state == DownloadError) {
        return;
    }
    for (NvParticleModel *model in self.graffitiFxArray) {
        model.selected = NO;
    }
    if (model.state == NvNoDownload) {
        self.currentItem = model;
        model.state = Downloading;
        [self.assetManager downloadAsset:model.packageId];
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }else if(model.state == Finish){
        model.selected = YES;
        if (indexPath.item != 0) {
            if (self.currentItem) {
                if ([self.currentItem isEqual:model]) {
                    self.particleHeaderView.hidden = NO;
                    [self addMontmorillonite];
                    return;
                }else{
                    self.filterSpeeadSlider.value = 1;
                    self.filterStrengthSlider.value = 1;
                }
            }
            self.currentItem = model;
        }else{
            self.currentItem = nil;
        }
        [collectionView reloadData];
    }
}

#pragma mark NvCanvasViewDelegate
///此次触摸开始,创建出粒子特效对象,加入到数组中
///This touch starts by creating a particle effect object and adding it to the array
- (void)canvasViewState:(CGPoint)statePoint{
    if (!self.currentItem) {
        return;
    }
    if (self.startInpoint < self.timeline.duration) {
        self.effectWrapper.colorBarView.timelineStartPosition = self.startInpoint;
        float posX = self.effectWrapper.sliderView.value * (SCREENWIDTH - 26 * SCREENSCALE);
        [self.effectWrapper.colorBarView addBar:posX width:0 color:self.currentItem.color fxUuid:self.currentItem.packageId];
        
        NvParticleInfoModel *infoModel = [NvParticleInfoModel new];
        infoModel.uuid = self.currentItem.packageId;
        infoModel.name = self.currentItem.displayName;
        infoModel.inPoint = self.startInpoint;
        infoModel.color = self.currentItem.color;
        infoModel.particleRateValue = self.filterSpeeadSlider.value;
        infoModel.particleSizeValue = self.filterStrengthSlider.value;
        infoModel.emitterName = [NSMutableArray arrayWithArray:[self.currentItem.parser getParticlePartitionEmitter:0]];
        self.currentInfoModel = infoModel;
        [self.particleFxArray addObject:infoModel];
        self.timelineVideo = [self.timeline addPackagedTimelineVideoFx:self.startInpoint duration:_timeline.duration videoFxPackageId:infoModel.uuid];
        [_timelineVideo setFloatVal:@"Tail Fading Duration" val:0.5];
    }
}

///此次触摸时间的时长
///The duration of the touch
- (void)canvasViewDuration:(int64_t)duration withPosition:(CGPoint)position{
    if (!self.currentItem) {
        return;
    }
    if ((duration + self.startInpoint) < self.timeline.duration) {
        self.isChange = YES;
        [self seek:self.startInpoint + duration];
        self.effectWrapper.sliderView.value = (float)(self.startInpoint + duration)/_timeline.duration;
        [self setParser:self.currentItem.parser withPoint:position withDuration:duration];
    } else {
        self.effectWrapper.sliderView.value = 1.0;
    }
}

///此次触摸结束
///End of touch
- (void)canvasViewEnd:(int64_t)duration{
    self.isChange = NO;
    [self seek:-1];
    if (!self.currentItem) {
        return;
    }
    if ((duration + self.startInpoint) < self.timeline.duration) {
        self.currentInfoModel.outPoint = self.startInpoint + duration;
        self.startInpoint = self.currentInfoModel.outPoint;
    }else{
         self.currentInfoModel.outPoint = self.timeline.duration;
        self.startInpoint = self.timeline.duration;
    }
    int64_t position = [_streamingContext getTimelineCurrentPosition:_timeline];
    [self.timelineVideo changeOutPoint:position];
    [self updateColorBarView:self.particleFxArray];
//    [self seek:position];
}

#pragma mark 在livewindow上添加粒子特效
///Added particle effects to livewindow
- (void)setParser:(NvsAssetPackageParticleDescParser *)parser withPoint:(CGPoint)point withDuration:(int64_t)duration{
    NvsParticleSystemContext *particleContext = [self.timelineVideo getParticleSystemContext];
    NSArray* emitters = [parser getParticlePartitionEmitter:0];
    CGPoint p1 = [_liveWindow mapViewToCanonical:point];
    CGPoint p = [_timelineVideo mapPointFromCanonicalToParticleSystem:p1];
    
    for(int i = 0; i < emitters.count; i++){
        
        [particleContext appendPositionToEmitterPositionCurve:emitters[i] curveTime:duration/1000000.0 emitterPositionX:p.x emitterPositionY:p.y];
        [particleContext SetEmitterParticleSizeGain:emitters[i] emitterGain:self.currentInfoModel.particleSizeValue];
        [particleContext setEmitterRateGain:emitters[i] emitterGain:self.currentInfoModel.particleRateValue];
    }
    self.effectWrapper.colorBarView.timelineCurrentPosition = self.effectWrapper.colorBarView.timelineStartPosition + duration;
    [self.effectWrapper.colorBarView updateLastBar:NO];
}

#pragma mark 在缩略图添加对应的视图
///Add the corresponding view to the thumbnail
- (void)updateColorBarView:(NSMutableArray *)fxNewArray {
    [self.effectWrapper.colorBarView clearCurrentArray];
    NSMutableArray *colorArray = [NSMutableArray array];
    for (int i = 0; i < fxNewArray.count; i++) {
        NvParticleInfoModel *info = [fxNewArray objectAtIndex:i];
        int64_t inPoint = info.inPoint;
        int64_t outPoint = info.outPoint;
        NSString *fxUUID = info.uuid;
        [self.effectWrapper.colorBarView addToCurrentArray:fxUUID inPoint:inPoint outPoint:outPoint];
        [colorArray addObject:info.color];
    }
    [self.effectWrapper.colorBarView updateSubviewsByCurrentArray:NO withColor:colorArray];
}

#pragma mark - NvEffectWrapperDelegate
- (void)sliderValueChanged:(UISlider *)slider{
    self.startInpoint = lround(slider.value * self.timeline.duration);
    self.isChange = YES;
    [self seek:lround(slider.value * self.timeline.duration)];
}

- (void)sliderValueEnd:(UISlider *)slider{
    self.isChange = NO;
    [self seek:-1];
}

#pragma mark NvsStreamingContextDelegate
- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    self.effectWrapper.sliderView.value = (float)position/timeline.duration;
    self.startInpoint = position;
}

- (void)didPlaybackPreloadingCompletion:(NvsTimeline *)timeline{
    [self didStreamingEngineStateChanged:self.streamingContext.getStreamingEngineState];
}

- (void)didPlaybackStopped:(NvsTimeline *)timeline {
    [self didStreamingEngineStateChanged:self.streamingContext.getStreamingEngineState];
}

- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    self.startInpoint = 0;
    self.effectWrapper.sliderView.value = 0;
    [self seek:0];
    [self didStreamingEngineStateChanged:self.streamingContext.getStreamingEngineState];
}

- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state {
    if (state == NvsStreamingEngineState_Playback) {
        self.playBtn.selected = YES;
    } else {
        self.playBtn.selected = NO;
    }
}

#pragma mark 注册应用前台后台通知事件
///Register application foreground background notification events
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

///应用进入后台，停止采集
///The application enters the background and stops collecting data
- (void)applicationWillResignActive:(NSNotification*)notification {
    if ([_streamingContext getStreamingEngineState] == NvsStreamingEngineState_Playback) {
        [_streamingContext stop];
    }
}

///应用进入前台，开始采集
///The application enters the foreground and starts collecting
- (void)applicationDidBecomeActive:(NSNotification*)notification {

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
