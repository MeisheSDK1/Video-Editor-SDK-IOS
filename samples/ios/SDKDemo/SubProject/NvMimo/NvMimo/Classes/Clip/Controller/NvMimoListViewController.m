//
//  NvMimoListViewController.m
//  NvMimoDemo
//
//  Created by MS on 2019/9/10.
//  Copyright © 2019 MS. All rights reserved.
//

#import "NvMimoListViewController.h"
#import "NVMimoDefineConfig.h"
#import <UIColor+NvColor.h>
#import "NvMimoLiveWindowPanelView.h"
#import "NvMimoClipCollectionViewCell.h"
#import "NvThemeAssetManager.h"
#import "NvPreviewTemplateLayout.h"
#import "NvsVideoTrack.h"
#import "NvMimoHttpRequestManager.h"
#import "NvMimoSDKUtils.h"
#import "NvMimoPlayerView.h"
#import "NvMimoListModel.h"
#import "NvThemeModel.h"
#import "SSZipArchive.h"
#import "NvMimoPopView.h"
#import "YYModel.h"
#import "NvMimoWeakTimer.h"
#import "NvMimoToast.h"
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvAlbum/NvAlbumViewController.h>
#import "NvMimoAlbumSelectService.h"
#import "NvMimoAlbumCustomBottomView.h"

#define NV_MIMO_BASEPATH @"Documents/Mimo"
#define NV_MIMO_Cache_BASEPATH @"Documents/CacheMimo"
#define NV_MIMO_PAGESIZE 10
@interface NvMimoListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,NvMimoHttpRequestDelegate,NvAlbumViewControllerDelegate>
@property (nonatomic, assign) NvMimoEditMode editMode;
@property (nonatomic, strong) UICollectionView *clipCollectionView;
@property (nonatomic, strong) UIButton *certainButton;
// Category buttons array
@property (nonatomic, strong) NSMutableArray *itemArr;                 //类别按钮数组
// Select the template model
@property (nonatomic, strong) NvMimoListModel *currentModel;              //选中模版model
// Currently selected template index
@property (nonatomic, assign) NSInteger currentThemeIndex; //当前选中模版index
@property (nonatomic, copy) NSString *dirPath;
@property (nonatomic, strong) NvThemeAssetManager *manager;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property(nonatomic, strong) AVAsset *asset;
@property(nonatomic, strong) AVPlayerItem *playerItem;
@property(nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NvMimoPlayerView *playerView;
@property (nonatomic, strong) NvMimoPopView *popView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL hasNoMoreData;
@property (nonatomic, strong) UIView *controlPanelView;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIButton *playbackBtn;
@property (nonatomic, assign) int64_t currentTime;
@property (nonatomic, assign) int64_t duration;
@property (nonatomic ,weak)  id timeObser;
@property (nonatomic, assign) BOOL netAvailable;
@property (nonatomic, strong) NvMimoAlbumSelectService *albumService;
@property (nonatomic, strong) NvMimoAlbumCustomBottomView *albumCustomView;
@end

@implementation NvMimoListViewController {
    BOOL isDismiss;
    UILabel *_currentTimeLabel;
    UIButton *_volumnBtn;
    UILabel *_durationLabel;
    NvMimoWeakTimer *_timer;
    UITapGestureRecognizer *_tap;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor nv_colorWithHexRGB:@"#1A1D24"];
    self.navigationController.navigationBar.translucent = NO;
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self leftNavigationBarItemView]];

    self.navigationItem.leftBarButtonItem = leftBarButtonItem;

    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.dataSource = [NSMutableArray array];
    self.currentPage = 1;
    self.hasNoMoreData = NO;
    [self addSubviews];
    [self createFontPath];
    NvMimoHttpRequestManager *httpManager = [NvMimoHttpRequestManager sharedInstance];
    [httpManager checkNetwork:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [self addObserver];
    if (self.playerItem) {
        [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    }
    if (self.player) {
        [self.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
        [self processPlayerTime];
    }
    [super viewWillAppear:animated];
    isDismiss = NO;
    if (self.player && self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
        [self.player play];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    isDismiss = YES;
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
    }
    if (self.player) {
        [self.player removeObserver:self forKeyPath:@"rate"];
        [self.player removeTimeObserver:_timeObser];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIView *)leftNavigationBarItemView {
    UIButton *backButton;
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, 30, 44);
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15*SCREANSCALE, 0, 0);
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    return backButton;
}

- (void)back {
    NvMimoHttpRequestManager *httpManager = [NvMimoHttpRequestManager sharedInstance];
    [httpManager checkNetwork:nil];
    [_timer invalidate];
    _timer = nil;
    [self.player pause];
    [self.player removeObserver:self forKeyPath:@"rate"];
    self.player = nil;
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - initUI
- (void)addSubviews {
    [self.clipCollectionView registerClass:[NvMimoClipCollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
    [self.view addSubview:self.clipCollectionView];
    [self.clipCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-24*SCREANSCALEHEIGHT);
        } else {
            make.bottom.equalTo(@(-24*SCREANSCALEHEIGHT));
        }
        make.height.mas_equalTo(173*SCREANSCALEHEIGHT);
        make.left.right.equalTo(self.view);
    }];
    
    UIView *sepLine = [[UIView alloc] init];
    [self.view addSubview:sepLine];
    sepLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
    [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.clipCollectionView.mas_top);
        make.height.mas_equalTo(1.f);
        make.left.right.equalTo(self.view);
    }];
    
    self.playerView = [[NvMimoPlayerView alloc] init];
    [self.view addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(sepLine.mas_top).offset(-(SCREANHEIGHT - 200 - SCREANWIDTH*9/16)/2);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(SCREANWIDTH*9/16);
    }];
    
    //添加播放器控制界面
    // Add the player control screen
    _controlPanelView = [UIView new];
    _controlPanelView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#80000000"];
    [self.view addSubview:_controlPanelView];
    [_controlPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.top.equalTo(self.playerView.mas_bottom);
        make.height.equalTo(@(40 * SCREANSCALE));
    }];
    _playbackBtn = [UIButton new];
    [_playbackBtn setImage:[UIImage imageNamed:@"NvPlayback"] forState:UIControlStateNormal];
    [_controlPanelView addSubview:_playbackBtn];
    [_playbackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(@0);
        make.width.equalTo(self->_controlPanelView.mas_height);
    }];
    _currentTimeLabel = [UILabel new];
    _currentTimeLabel.text = @"00:00";
    _currentTimeLabel.textColor = [UIColor whiteColor];
    _currentTimeLabel.font = [UIFont systemFontOfSize:10];
    CGSize size = [_currentTimeLabel sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    [_controlPanelView addSubview:_currentTimeLabel];
    [_currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_playbackBtn.mas_right);
        make.centerY.equalTo(self->_controlPanelView);
        make.width.equalTo(@(size.width));
    }];
    _volumnBtn = [UIButton new];
    [_volumnBtn setImage:[UIImage imageNamed:@"NvVolumn"] forState:UIControlStateNormal];
    [_controlPanelView addSubview:_volumnBtn];
    _volumnBtn.hidden = YES;
    [_volumnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(@0);
        make.width.equalTo(self->_controlPanelView.mas_height);
    }];
    _durationLabel = [UILabel new];
    _durationLabel.text = @"00:00";
    _durationLabel.textColor = [UIColor whiteColor];
    _durationLabel.font = [UIFont systemFontOfSize:10];
    [_controlPanelView addSubview:_durationLabel];
    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10.0);
        make.centerY.equalTo(self->_controlPanelView);
        make.width.equalTo(@(size.width));
    }];
    _progressSlider = [UISlider new];
    [_progressSlider setThumbImage:[UIImage imageNamed:@"NvSliderHandle"] forState:UIControlStateNormal];
    [_progressSlider setMinimumTrackTintColor:[UIColor nv_colorWithHexARGB:@"#FF2A7DFF"]];
    [_progressSlider setMaximumTrackTintColor:[UIColor nv_colorWithHexARGB:@"#FF979797"]];
    [_controlPanelView addSubview:_progressSlider];
    [_progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_currentTimeLabel.mas_right).offset(7 * SCREANSCALE);
        make.right.equalTo(self->_durationLabel.mas_left).offset(-7 * SCREANSCALE);
        make.centerY.equalTo(self->_controlPanelView);
    }];
    
    [_playbackBtn addTarget:self action:@selector(playbackBtnClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [_progressSlider addTarget:self action:@selector(progressSliderValueChanged) forControlEvents:(UIControlEventValueChanged)];
    
    [_progressSlider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpInside];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.playerView addGestureRecognizer:_tap];
    [self showControllPanel];
}

- (void)setHiddenPanelTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NvMimoWeakTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideControlPanel:) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
}

- (void)singleTap:(UITapGestureRecognizer *)recognizer {
    if (_controlPanelView.hidden == YES) {
        _controlPanelView.hidden = NO;
        [self setHiddenPanelTimer];
    } else {
        [self playbackBtnClicked];
    }
}

- (void)showControllPanel {
    _controlPanelView.hidden = NO;
    [self setHiddenPanelTimer];
}

- (void)hideControlPanel:(NSTimer *)timer {
    if (!_controlPanelView.hidden)
        _controlPanelView.hidden = YES;
}

- (void)setCurrentTime:(int64_t)currentTime {
    _currentTime = currentTime;
    _currentTimeLabel.text = [NvMimoUtils convertTimecode:_currentTime];
}

- (void)setDuration:(int64_t)duration {
    _duration = duration;
    _durationLabel.text = [NvMimoUtils convertTimecode:duration];
}

- (void)playbackBtnClicked {
    if(self.player.rate == 0.0) {
        [self.player play];
    }else{
        [self.player pause];
    }
    [self setHiddenPanelTimer];
}

- (void)sliderValueEnd:(UISlider*)slider {
    [self.player pause];
    self.currentTime = self.duration * slider.value;
    [self.player seekToTime:CMTimeMake(self.currentTime, 1000000)];
    _timer = [NvMimoWeakTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideControlPanel:) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
}

- (void)progressSliderValueChanged {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [self.player pause];
    _controlPanelView.hidden = NO;
    self.currentTime = lround(_progressSlider.value * _duration);
}

#pragma mark - 点击使用某个确定模版
///click to use one template
- (void)certainTemplateConfirmed {
    //区分模版是否下载，模版未下载先进行下载操作
    //check the template has been downloaded whether or not
    //download it if it has not been downloaded
    NSString *memoPath = [[NSHomeDirectory() stringByAppendingPathComponent:NV_MIMO_Cache_BASEPATH] stringByAppendingPathComponent:@"Download"];
    NSString *dstPath = [[memoPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[self.currentModel.uuid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    
    NSString *memoLocalPath = [NSHomeDirectory() stringByAppendingPathComponent:NV_MIMO_BASEPATH];
    NSString *dstLocalPath = [memoLocalPath stringByAppendingPathComponent:[self.currentModel.uuid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dstPath isDirectory:nil]) {
        self.dirPath = [[NSHomeDirectory() stringByAppendingPathComponent:NV_MIMO_Cache_BASEPATH] stringByAppendingPathComponent:_currentModel.uuid];
        [self selectAlbum];
    }else if ([[NSFileManager defaultManager] fileExistsAtPath:dstLocalPath isDirectory:nil]){
        self.dirPath = [[NSHomeDirectory() stringByAppendingPathComponent:NV_MIMO_BASEPATH] stringByAppendingPathComponent:_currentModel.uuid];
        [self selectAlbum];
    }
    else{
        if (!self.netAvailable) {
            [NvMimoToast showErrorWithMessage:NvLocalStringFromTable([self class], @"CheckNetwork", @"请检查网络是否连接")];
            return;
        }
        self.dirPath = [[NSHomeDirectory() stringByAppendingPathComponent:NV_MIMO_Cache_BASEPATH] stringByAppendingPathComponent:_currentModel.uuid];
        //download the asset template
        if (![[NSFileManager defaultManager] fileExistsAtPath:memoPath isDirectory:nil]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:memoPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [self downloadPackageWithUrl:self.currentModel.packageUrl destinationUrl:memoPath downloadId:self.currentModel.uuid];
    }
}

#pragma mark - 获取模版数据
//Get the template data
- (void)getTemplateList {
    if (self.netAvailable) {
        //加载网络数据
        //load data from network
        DLog(@"----------加载网络数据------------");
        [self getLocalFiles];
        [self getNetworkFilesWithPage:self.currentPage];
    }else{
        DLog(@"----------加载本地数据------------");
        [self getCacheFiles];
        [self getLocalFiles];
    }
    
}

///获取网络数据
///get the template network list
- (void)getNetworkFilesWithPage:(NSInteger)page {
    [NvMimoToast showLoading];
    __weak typeof(self)weakSelf = self;
    [NvMimoHttpRequestManager RequestMimoMaterialListWithPage:page pageSize:NV_MIMO_PAGESIZE completionBlock:^(id  _Nonnull respondData) {
        if (page == 0) {
            [weakSelf.dataSource removeAllObjects];
        }
        NSDictionary *dic = (NSDictionary *)respondData;
        [weakSelf getListModelWithDic:dic page:page netWork:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [NvMimoToast dismiss];
        });
    } failureBlock:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NvMimoToast showErrorWithMessage:NvLocalStringFromTable([self class], @"Failed to load", @"加载失败！")];
            weakSelf.currentPage--;
            [weakSelf.clipCollectionView reloadData];
        });
    }];
}

///获取本地缓存数据
///get the template in cache
- (void)getCacheFiles {
    [self.dataSource removeAllObjects];
    NSString *basePath = [NSHomeDirectory() stringByAppendingPathComponent:NV_MIMO_Cache_BASEPATH];
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    if (![myFileManager fileExistsAtPath:basePath isDirectory:nil]) {
        [myFileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:basePath error:nil];
    if (dirArray.count <=0) {
        return ;
    }
    NSDirectoryEnumerator *myDirectoryEnumerator = [myFileManager enumeratorAtPath:basePath];
    for (NSString *path in myDirectoryEnumerator.allObjects) {
        if ([path.pathExtension isEqualToString:@"json"] && ![path containsString:@"/"]) {
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", basePath, path];
            NSString *jsonStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            if(err)
            {
                DLog(@"json解析失败：%@",err);
                return ;
            }
            [self getListModelWithDic:dic page:[path stringByDeletingPathExtension].integerValue netWork:NO];
        }
    }
}

///获取设计测试模版数据
///get the template for designer
- (void)getLocalFiles {
    NSString *basePath = [NSHomeDirectory() stringByAppendingPathComponent:NV_MIMO_BASEPATH];
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    if (![myFileManager fileExistsAtPath:basePath isDirectory:nil]) {
        [myFileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:basePath error:nil];
    if (dirArray.count <=0) {
        return ;
    }
    
    //没有缓存网络请求情况下获取本地文件夹数据
    // Fetch local folder data without caching network request
    NSDirectoryEnumerator *directoryEnumerator = [myFileManager enumeratorAtPath:basePath];
        for (NSString *path in directoryEnumerator.allObjects) {
            if ([path.pathExtension isEqualToString:@"json"] && [path containsString:@"/"]) {
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", basePath, path];
                NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NvThemeModel *model = [NvThemeModel yy_modelWithJSON:dict];
                if (model) {
                    NvMimoListModel *listModel = [NvMimoListModel new];
                    NSArray *arr = [path componentsSeparatedByString:@"/"];
                    if (arr.count > 1) {
                        NSString *localDir = [basePath stringByAppendingPathComponent:arr[0]];
                        listModel.localPath = localDir;
                        listModel.uuid = arr[0];
                        listModel.packageInfo = model;
                    }
                    [self.dataSource insertObject:listModel atIndex:0];
                }
                
            }
        }
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!weakSelf.currentModel){
                weakSelf.currentModel = weakSelf.dataSource[0];
                weakSelf.currentModel.isSelected = YES;
                [weakSelf replaceAVPlayerItem];
            }
            weakSelf.hasNoMoreData = YES;
            [weakSelf.clipCollectionView reloadData];
        });
    
}

///创建设计存放字体文件路径
///create the font path for designer
- (void)createFontPath
{
    NSString *fontPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Asset/MIMOFontAsset"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fontPath isDirectory:nil]) {
           [[NSFileManager defaultManager] createDirectoryAtPath:fontPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)getListModelWithDic:(NSDictionary *)dic page:(NSInteger)page netWork:(BOOL)fromNet {
    __weak typeof(self)weakSelf = self;
    NSArray *arr = dic[@"data"][@"elements"];
    if (arr.count<NV_MIMO_PAGESIZE) {
        weakSelf.hasNoMoreData = YES;
    }
    if (arr.count<=0) {
        self.currentPage--;
    }
    for (int i=0; i<arr.count; i++) {
        NSDictionary *item = arr[i];
        NvMimoListModel *model = [[NvMimoListModel alloc] init];
        model.coverUrl = item[@"coverUrl"];
        model.uuid = item[@"id"];
        model.videoUrl = item[@"previewVideoUrl"];
        model.packageUrl = item[@"zipUrl"];
        model.packageInfo = [NvThemeModel yy_modelWithJSON:item[@"infoJson"]] ;
        [self.dataSource addObject:model];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (fromNet) {
          [weakSelf saveResponseInfoInLocal:dic page:page];
        }
        
        if(!weakSelf.currentModel && weakSelf.dataSource.count > 0){
            weakSelf.currentModel = weakSelf.dataSource[0];
            weakSelf.currentModel.isSelected = YES;
            [weakSelf replaceAVPlayerItem];
        }
        [weakSelf.clipCollectionView reloadData];
    });
}

///将网络请求返回数据保存到本地
///save the response info in local
- (void)saveResponseInfoInLocal:(NSDictionary *)dic page:(NSInteger)page {
    NSString *memoPath = [[[NSHomeDirectory() stringByAppendingPathComponent:NV_MIMO_Cache_BASEPATH] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",(long)page]] stringByAppendingPathExtension:@"json"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:memoPath]) {
        [manager removeItemAtPath:memoPath error:nil];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[memoPath stringByDeletingLastPathComponent] isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[memoPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:nil error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    BOOL result = [jsonString writeToFile:memoPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (result) {
        DLog(@"保存请求数据成功");
    }else{
        DLog(@"保存请求数据失败");
    }
}

///下载模版
///download the template
- (void)downloadPackageWithUrl:(NSString *)sourceUrl destinationUrl:(NSString *)destinationUrl downloadId:(NSString *)downloadId {
    NvMimoHttpRequestManager *request = [NvMimoHttpRequestManager sharedInstance];
    [request downloadAsset:sourceUrl destFileDir:destinationUrl withDelegate:self downloadID:downloadId];
    self.popView = [[NvMimoPopView alloc] init];
    self.popView.title = NvLocalStringFromTable([self class], @"Downloading", @"模板正在下载");
    [self.popView showWithDirection:NvMimoPopDirection_Center completion:nil];
    [self.player pause];
}

///下载预览视频
///download the cover video for template
- (void)downLoadCoverVideoWithUrl:(NSString *)url {
    NSString *basePath = [NSHomeDirectory() stringByAppendingPathComponent:NV_MIMO_Cache_BASEPATH];
    [[NvMimoHttpRequestManager sharedInstance] downloadVideo:url destFileDir:basePath withDelegate:self downloadID:url.lastPathComponent];
}

#pragma mark - 进入相册界面
///push the albumController
- (void)selectAlbum {
    [self.player pause];
    self.albumService = nil;
    self.albumService = [NvMimoAlbumSelectService new];
    NvAlbumViewController *albumVC = [[NvAlbumViewController alloc] init];
    albumVC.selectStrategy = self.albumService;
    self.albumService.albumCustomView = self.albumCustomView;
    self.albumService.firstCreatTimeline = YES;
    self.albumService.themeModel = self.currentModel.packageInfo;
    self.albumService.dirPath = self.dirPath;
    self.albumCustomView.delegate = self.albumService;
    albumVC.delegate = self;
    albumVC.alwaysShowCustomBottom = YES;
    [self.navigationController pushViewController:albumVC animated:YES];
}

#pragma mark - 切换播放源
///replace the avplayer item
- (void)replaceAVPlayerItem {
    [self.player pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    NvMimoListModel *model = self.dataSource[self.currentThemeIndex];
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
    }
    NSURL *url = [self urlOfTemplate:model];
    //如果是网络数据，则将预览视频下载到本地
    // If it is network data, download the preview video locally
    if([[url absoluteString] containsString:@"http"]) {
        if(self.netAvailable){
            [self downLoadCoverVideoWithUrl:[url absoluteString]];
        }else{
            [NvMimoToast showErrorWithMessage:NvLocalStringFromTable([self class], @"CheckNetwork", @"请检查网络是否连接")];
            if (self.player) {
                [self.player removeObserver:self forKeyPath:@"rate"];
            }
            self.playerItem = nil;
            self.playerView.player = nil;
            self.player = nil;
            self.duration = 0;
            return;
        }
    }
    
    AVPlayerItem *avItem = [AVPlayerItem playerItemWithURL:url];
    self.playerItem = avItem;
    
    if (!self.player) {
        self.player = [AVPlayer playerWithPlayerItem:avItem];
        [self.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
        self.playerView.player = self.player;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord
                 withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                       error:nil];
    }else{
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    }

    if(self.playerItem) {
        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    
    //预览视频时长
    // Preview the video duration
    CMTime duration = self.playerItem.asset.duration;
    float sec = CMTimeGetSeconds(duration);
    self.duration = sec*1000000;
    //处理播放进度
    [self processPlayerTime];
    self.player.muted = NO;

}

///获取模版预览视频地址
///get the cover video url of template
- (NSURL *)urlOfTemplate:(NvMimoListModel *)model {
    NSURL *url = [NSURL URLWithString:model.videoUrl];
    NSString *basePath = [NSHomeDirectory() stringByAppendingPathComponent:NV_MIMO_Cache_BASEPATH];
    NSString *memoPath = [basePath stringByAppendingPathComponent:model.uuid];
    if ([model.localPath containsString:NV_MIMO_BASEPATH]) {
        memoPath = model.localPath;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![[NSFileManager defaultManager] fileExistsAtPath:memoPath isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDirectoryEnumerator *directoryEnumerator = [manager enumeratorAtPath:basePath];
    BOOL isExist = NO;
    for (NSString *path in directoryEnumerator.allObjects) {
        if ([path isEqualToString:[model.videoUrl lastPathComponent]]){
            url = [NSURL fileURLWithPath:[basePath stringByAppendingPathComponent:path]];
            isExist = YES;
            break;
        }
    }
    
    if ([manager fileExistsAtPath:memoPath] && !isExist) {
        NSDirectoryEnumerator *myDirectoryEnumerator = [manager enumeratorAtPath:memoPath];
        BOOL isDir = NO;
        BOOL isExists = NO;
        for (NSString *path in myDirectoryEnumerator.allObjects) {
            if ([path isEqualToString:@"cover.mp4"]) {
                
                NSString *coverPath = [NSString stringWithFormat:@"%@/%@", memoPath, path];
                isExists = [manager fileExistsAtPath:coverPath isDirectory:&isDir];
                if (isExists && !isDir) {
                    url = [NSURL fileURLWithPath:coverPath];
                    break;
                }
            }
        }
    }
    return url;
}

///处理预览视频播放进度
///the cover video play progress
- (void)processPlayerTime {
    __weak typeof(self)weakSelf = self;
    _timeObser = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1000)
                                                queue:NULL
                                           usingBlock:^(CMTime time) {
        //进度 当前时间/总时间
        // Progress current time/total time
        CGFloat progress = CMTimeGetSeconds(weakSelf.player.currentItem.currentTime) / CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressSlider.value = progress;
            weakSelf.currentTime = lround(progress * _duration);
        });
        
    }];
}

- (void)seekToStart:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player pause];
        AVPlayerItem *item = [notification object];
        [item seekToTime:kCMTimeZero];
        [self.player play];
    });
}

#pragma mark - 解压缩方法
//Decompression method
-(void)uSSZipArchiveWithFilePath:(NSString *)path destinationPath:(NSString *)destinationPath {
   BOOL isSuccess =  [SSZipArchive unzipFileAtPath:path toDestination:destinationPath progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {

    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
        
        if (error) {
//            DLog(@"解压失败:%@",[error description]);
        }else{
            //删除下载的压缩包
            // Delete the downloaded archive
            NSFileManager *manager = [NSFileManager defaultManager];
            BOOL result = [manager removeItemAtPath:path error:nil];
            if (result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self selectAlbum];
                });
            }
           
        }
    }];
    
    //如果解压成功则获取解压后文件列表
    // Get a list of unpacked files if unpacked successfully
    if (!isSuccess) {
        DLog(@"解压失败！");
    }
    
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                [(AVPlayerLayer *)[weakSelf.playerView layer] setVideoGravity:AVLayerVideoGravityResizeAspect];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(seekToStart:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
                
                [self.player play];
            }
        });
    }else if ([keyPath isEqualToString:@"rate"]) {
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.player.rate > 0) {
                [weakSelf.playbackBtn setImage:[NvMimoUtils imageWithName:@"NvPause"] forState:UIControlStateNormal];
            }else{
                [weakSelf.playbackBtn setImage:[NvMimoUtils imageWithName:@"NvPlayback"] forState:UIControlStateNormal];
            }
        });
        
    }
}

#pragma mark - collectionView Delegate & Datasoure
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    NvMimoClipCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    NvMimoListModel *model = self.dataSource[indexPath.item];
    cell.model = model;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_currentModel != self.dataSource[indexPath.item]) {
        _currentModel.isSelected = NO;
        _currentModel = self.dataSource[indexPath.item];
        self.currentThemeIndex = indexPath.item;
        _currentModel.isSelected = YES;
        [self.clipCollectionView reloadData];
        [self replaceAVPlayerItem];
    }else{
        [self certainTemplateConfirmed];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.dataSource.count-1) {
        if (!self.hasNoMoreData) {
            self.currentPage++;
            [self getNetworkFilesWithPage:self.currentPage];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.currentThemeIndex && [self.dataSource containsObject:self.currentModel]) {
        return CGSizeMake(125*SCREANSCALE, 150*SCREANSCALE);
    }else{
        return CGSizeMake(125*SCREANSCALE, 125*SCREANSCALE);
    }
}

#pragma mark - NvMimoHttpRequestDelegate
- (void)onDonwloadAssetProgress:(int32_t)progress
                     downloadID:(NSString*)downloadID {
    DLog(@"下载进度%@:----%d",downloadID,progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.popView.progressValue = progress;
    });
    
}

- (void)onDonwloadAssetSuccess:(BOOL) isSuccess
              downloadFilePath:(NSString*)downloadFilePath
                    downloadID:(NSString*)downloadID {
    DLog(@"下载成功%@:%@",downloadID,downloadFilePath);
    if (![downloadFilePath.pathExtension isEqualToString:@"zip"] && ![downloadFilePath.pathExtension isEqualToString:@"rar"]) {
        return;
    }
    NSString *memoPath = [NSHomeDirectory() stringByAppendingPathComponent:NV_MIMO_Cache_BASEPATH];
    downloadFilePath = [downloadFilePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    __weak typeof(self)weakSelf = self;
    [self.popView dismissCompletion:^{
        [weakSelf uSSZipArchiveWithFilePath:downloadFilePath destinationPath:memoPath];
    }];
}

- (void)onDonwloadAssetFailed:(NSError *) error
             downloadFilePath:(NSString*)downloadFilePath
                   downloadID:(NSString*)downloadID {
    DLog(@"下载失败%@:%@",downloadID,[error description]);
    if (![downloadFilePath.pathExtension isEqualToString:@"zip"] && ![downloadFilePath.pathExtension isEqualToString:@"rar"]) {
        return;
    }
    [self.popView dismissCompletion:nil];
    
}

- (void)onCheckNetworkState:(BOOL)isNetAvailable {
    self.netAvailable = isNetAvailable;
    if (self.dataSource.count == 0) {
        [self getTemplateList];
    }
    if (!isNetAvailable) {
        [NvMimoToast showInfoWithMessage:NvLocalStringFromTable([self class], @"CheckNetwork", @"Check Network")];
    }
}

#pragma mark - NvAlbumViewControllerDelegate
- (UIView *)nvAlbumViewControllerCustomBottomButton {
    return self.albumCustomView;
}

- (CGFloat)nvAlbumViewControllerUsefulCustomBottomHeight {
    return 64*SCREANSCALE;
}

- (BOOL)nvAlbumViewControllerAdjustAlbumCollectionFrameAsCustomBottomViewHeightAtInitialization:(NvAlbumViewController *)albumViewController {
    return YES;
}

- (void)nvAlbumViewControllerCancelClick:(NvAlbumViewController *)albumViewController {
    [self.albumService clearCache];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - lazyload
- (UICollectionView *)clipCollectionView {
    if (!_clipCollectionView) {
        NvPreviewTemplateLayout *flowLayout = [[NvPreviewTemplateLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 8*SCREANSCALE;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 15.f, 0, 0);
        _clipCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _clipCollectionView.delegate = self;
        _clipCollectionView.dataSource = self;
        _clipCollectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#1A1D24"];
    }
    return  _clipCollectionView;
    
}

- (NvMimoAlbumCustomBottomView *)albumCustomView {
    if (!_albumCustomView) {
        _albumCustomView = [[NvMimoAlbumCustomBottomView alloc] initWithFrame:CGRectMake(0, self.view.height - NV_STATUSBARHEIGHT - 44 - (64*SCREANSCALE + INDICATOR), SCREANWIDTH, 64*SCREANSCALE + INDICATOR)];
    }
    return _albumCustomView;
}

- (void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification*)notification {
    [self.player pause];
}

- (void)applicationBecomeActive:(NSNotification*)notification {
    [self.player play];
}

@end
