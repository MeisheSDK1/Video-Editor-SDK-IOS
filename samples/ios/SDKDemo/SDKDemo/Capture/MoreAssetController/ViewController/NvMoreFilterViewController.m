//
//  NvMoreFilterViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMoreFilterViewController.h"
#import "NvMoreFilterCollectionCell.h"
#import <NvSDKCommon/NvAssetManager.h>
#import "MJRefresh.h"
#import <NvSDKCommon/NvAsset.h>
#import "NvTipsView.h"
#import "AFNetworking.h"
#import "Reachability.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import <NvSDKCommon/NvHttpRequest.h>
#import "NvBaseModel.h"
#import "NvSearchBar.h"
#import "NvSearchViewController.h"
#import "NvFilterSearchResultViewController.h"
#import <NvBaseCommon/UIColor+NvColor.h>
#import <NvSDKCommon/NvUtils.h>

@interface NvMoreFilterViewController ()< NvAssetManagerDelegate,NvHttpRequestDelegate,UICollectionViewDelegate,UICollectionViewDataSource,NvMoreFilterCollectionCellDelegate, NvSearchBarDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) NvBaseModel *model;

@property (nonatomic, strong) UIView *failureView;

@property (nonatomic, assign) BOOL isPull;

@property (nonatomic, strong) NvAssetManager *assetManager;

@property (nonatomic, strong) NSMutableArray *filters;

@property (nonatomic, strong) NvSearchBar *searchBar;
@property (nonatomic, strong) NvSearchBarOption *searchBarOption;
@property (nonatomic, strong) NSString *keyword;
@end

@implementation NvMoreFilterViewController{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appear = [[UINavigationBarAppearance alloc] init];
        [appear configureWithOpaqueBackground];
        appear.titleTextAttributes = @{NSForegroundColorAttributeName:UIColor.whiteColor, NSFontAttributeName:[NvUtils fontWithSize:16]};
        appear.backgroundColor = [UIColor blackColor];
        appear.backgroundEffect = nil;
        appear.shadowColor = UIColor.clearColor;
        self.navigationController.navigationBar.scrollEdgeAppearance = appear;
        self.navigationController.navigationBar.standardAppearance = appear;
    }else{
        [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [NvUtils fontWithSize:16], NSFontAttributeName, nil]];
    }
    
    self.view.backgroundColor = [UIColor nv_colorWithHexRGB:@"#F8F8F8"];
    
    self.keyword = @"";
    self.title = [NvSDKUtils getMoreTitleName:self.type];
    NvsStreamingContext *streamingContext = [NvSDKUtils getSDKContext];
    if ([streamingContext getStreamingEngineState] == NvsStreamingEngineState_Playback) {
        [streamingContext stop];
    }
    [self addSubViews];
    // Do any additional setup after loading the view.
    
    self.filters = NSMutableArray.new;
    self.assetManager = [NvAssetManager sharedInstance];
    [self.assetManager.hashTable addObject:self];
    self.assetManager.delegate = self;

    _failureView = [[UIView alloc]initWithFrame:self.view.frame];
    _failureView.hidden = YES;
    _failureView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:_failureView];
    
    UILabel *labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 186 * SCREENSCALE, SCREENWIDTH, 30 * SCREENSCALE)];
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.text = NvLocalString(@"Failed to load", @"加载失败！");
    labelTitle.textColor = [UIColor nv_colorWithHexRGB:@"#D0021B"];
    labelTitle.font = [NvUtils fontWithSize:19 * SCREENSCALE];
    [_failureView addSubview:labelTitle];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(158 * SCREENSCALE, 256 * SCREENSCALE, SCREENWIDTH - 2 * 158 * SCREENSCALE, 30 * SCREENSCALE);
    [btn setTitle:NvLocalString(@"again", @"重试") forState:UIControlStateNormal];
    btn.titleLabel.font = [NvUtils fontWithSize:12 * SCREENSCALE];
    btn.layer.cornerRadius = 4;
    btn.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    [btn addTarget:self action:@selector(retry:) forControlEvents:UIControlEventTouchUpInside];
    [_failureView addSubview:btn];
}

-(void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (@available(iOS 15.0, *)) {
        self.navigationController.navigationBar.standardAppearance = [[UINavigationBarAppearance alloc] init];
    }
}

#pragma mark - 初始化界面
/*
 初始化界面
 Initialize the interface
 
 */
- (void)addSubViews{
    CGFloat leftSep = 15*SCREENSCALE;
    CGFloat cellWidth = (SCREENWIDTH - 3*leftSep)/2;
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake(cellWidth, 247*SCREENSCALE);
    flow.minimumLineSpacing = 17.5*SCREENSCALE;
    CGFloat startY = 0;
    if (self.type == ASSET_FILTER) {
        /// 滤镜添加搜索 Filter add search
        [self.view addSubview:self.searchBar];
        startY = self.searchBar.searchBarHeight;
        flow.sectionInset = UIEdgeInsetsMake(0, leftSep, 0, leftSep);
    }else {
        flow.sectionInset = UIEdgeInsetsMake(leftSep, leftSep, 0, leftSep);
    }
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, startY, SCREENWIDTH, SCREENHEIGHT - startY) collectionViewLayout:flow];
    self.collectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#F8F8F8"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[NvMoreFilterCollectionCell class] forCellWithReuseIdentifier:@"NvMoreFilterCollectionCell"];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, NV_STATUSBARHEIGHT + NV_NAV_BAR_HEIGHT, 0);
    
    [self.view addSubview:self.collectionView];
    __block int page = 1;
    __weak typeof(self) weakSelf = self;
    int large,minor,revision;
    [NvsStreamingContext getSdkVersion:&large minorVersion:&minor revisionNumber:&revision];
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        weakSelf.isPull = NO;
        [weakSelf.filters removeAllObjects];
        NvAssetModular modular = weakSelf.isCapture ? NvAssetModularCapture : NvAssetModularAll;
        if (weakSelf.keyword.length > 0) {
            [weakSelf.assetManager downloadRemoteAssetsInfo:weakSelf.type categoryId:weakSelf.categoryId keyword:weakSelf.keyword page:page pageSize:NV_FILTER_PAGE_SIZE kind:weakSelf.kind modular:modular ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NSString stringWithFormat:@"%d.%d.%d",large,minor,revision]];
        }else{
            [weakSelf.assetManager downloadRemoteAssetsInfo:weakSelf.type  categoryId:weakSelf.categoryId page:page pageSize:20 kind:weakSelf.kind modular:modular ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NSString stringWithFormat:@"%d.%d.%d",large,minor,revision]];
        }
    }];
    [self.collectionView.mj_header beginRefreshing];
    
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.isPull = YES;
        page++;
        NvAssetModular modular = weakSelf.isCapture ? NvAssetModularCapture : NvAssetModularAll;
        if (weakSelf.keyword.length > 0) {
            [weakSelf.assetManager downloadRemoteAssetsInfo:weakSelf.type categoryId:weakSelf.categoryId keyword:weakSelf.keyword page:page pageSize:NV_FILTER_PAGE_SIZE kind:weakSelf.kind modular:modular ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NSString stringWithFormat:@"%d.%d.%d",large,minor,revision]];
        }else{
            [weakSelf.assetManager downloadRemoteAssetsInfo:weakSelf.type  categoryId:weakSelf.categoryId page:page pageSize:NV_FILTER_PAGE_SIZE kind:weakSelf.kind modular:modular ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NSString stringWithFormat:@"%d.%d.%d",large,minor,revision]];
        }
        
    }];
    
    self.tipLabel = [[UILabel alloc]init];
    self.tipLabel.textColor = [UIColor nv_colorWithHexRGB:@"#777777"];
    self.tipLabel.font = FONT10;
    self.tipLabel.hidden = YES;
    [self.view addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView).offset(35*SCREENSCALE);
        make.centerX.equalTo(self.collectionView);
    }];
}

- (void)setTipString:(NSString *)string{
    if ([NvUtils currentLanguagesIsChinese]){
        self.tipLabel.text = [NSString stringWithFormat:@"抱歉，没有找到\"%@\"相关的素材",string];
    }else{
        self.tipLabel.text = [NSString stringWithFormat:@"Sorry, no material related to \"%@\" was found",string];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvMoreFilterCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvMoreFilterCollectionCell" forIndexPath:indexPath];
    cell.type = self.type;
    cell.indexPath = indexPath;
    cell.delegate = self;
    if (self.filters.count != 0) {
        cell.model = self.filters[indexPath.row];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)onRemoteAssetsChanged:(BOOL)hasNext {
    _failureView.hidden = YES;
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    NSArray *array ;
    if (self.keyword.length > 0) {
        array = [self.assetManager getRemoteAssets:self.type aspectRatio:AspectRatio_All categoryId:self.categoryId kindId:self.kind keyword:self.keyword];
        if (array.count == 20) {
            hasNext = NO;
        }else{
            hasNext = YES;
        }
    }else{
        array = [self.assetManager getRemoteAssets:self.type aspectRatio:AspectRatio_All categoryId:self.categoryId kindId:self.kind];
        
        if (array.count - self.filters.count == 0) {
            hasNext = NO;
        }else{
            hasNext = YES;
        }
        [self.filters removeAllObjects];
    }
    
    for (NvAsset *asset in array) {

        NvBaseModel *model = [[NvBaseModel alloc]init];
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            model.displayName = asset.displayNamezhCN;
        }else{
            model.displayName = asset.displayName;
        }

        model.coverName = asset.coverUrl;
        model.size = [NvSDKUtils getAssetPackageSizeString:asset.packageSize];
        model.draw = [NvSDKUtils getAssetAspectRatioString:asset.remoteAspectRatio];
        model.packageId = asset.uuid;
        model.categoryId = asset.category;
        model.isAdjusted = asset.isAdjusted;
        if ([asset isUsable]) {
            if ([asset hasUpdate]) {
                model.state = Update;
            }else{
                model.state = Finish;
            }
        }else{
            model.state = NODownload;
        }
        if (!self.isCapture && asset.ratioFlag != 1) {
            
            if (self.editModel == NvEditMode9v16) {
                if ((asset.remoteAspectRatio & AspectRatio_9v16) == 0) {
                    model.state = NoUser;
                }
            }else if (self.editModel == NvEditMode16v9){
                if ((asset.remoteAspectRatio & AspectRatio_16v9) == 0) {
                    model.state = NoUser;
                }
            }else if (self.editModel == NvEditMode1v1){
                if ((asset.remoteAspectRatio & AspectRatio_1v1) == 0) {
                    model.state = NoUser;
                }
            }else if (self.editModel == NvEditMode3v4) {
                if ((asset.remoteAspectRatio & AspectRatio_3v4) == 0) {
                    model.state = NoUser;
                }
            }else if (self.editModel == NvEditMode4v3){
                if ((asset.remoteAspectRatio & AspectRatio_4v3) == 0) {
                    model.state = NoUser;
                }
                
            }else if (self.editModel == NvEditMode21v9) {
                if ((asset.remoteAspectRatio & AspectRatio_21v9) == 0) {
                    model.state = NoUser;
                }
            }else if (self.editModel == NvEditMode9v21) {
                if ((asset.remoteAspectRatio & AspectRatio_9v21) == 0) {
                    model.state = NoUser;
                }
            }else if (self.editModel == NvEditMode18v9) {
                if ((asset.remoteAspectRatio & AspectRatio_18v9) == 0) {
                    model.state = NoUser;
                }
            }else if (self.editModel == NvEditMode9v18) {
                if ((asset.remoteAspectRatio & AspectRatio_9v18) == 0) {
                    model.state = NoUser;
                }
            }else if (self.editModel == NvEditMode7v6) {
                if ((asset.remoteAspectRatio & AspectRatio_7v6) == 0) {
                    model.state = NoUser;
                }
            }else if (self.editModel == NvEditMode6v7) {
                if ((asset.remoteAspectRatio & AspectRatio_6v7) == 0) {
                    model.state = NoUser;
                }
            }
            
        }
        if (self.isCapture) {
            if ([asset isSupportCapture]) {
                [self.filters addObject:model];
            } 
        } else {
            [self.filters addObject:model];
        }
    }
     [self.collectionView reloadData];
    if (self.filters && self.filters.count > 0) {
        self.tipLabel.hidden = YES;
    }else{
        self.tipLabel.hidden = NO;
        [self setTipString:self.keyword];
    }
    if (_isPull) {
        if (!hasNext) {
            NvTipsView *tip = [[NvTipsView alloc]initWithFrame:self.view.frame withTitle:NvLocalString(@"No more", @"没有更多了") withColor:[UIColor nv_colorWithHexRGB:@"#4D4F51"] withCenter:YES];
            [self.view addSubview:tip];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [tip removeFromSuperview];
            });
        }
    }
}

- (void)onDonwloadAssetFailed:(NSString *)uuid{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.filters.count; i++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            NvMoreFilterCollectionCell *cell = (NvMoreFilterCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            NvBaseModel *item = cell.model;
            if ([item.packageId isEqualToString:uuid]) {
                item.state = DownloadError;
                NSMutableArray *array = NSMutableArray.new;
                [array addObject:indexPath];
                [self.collectionView reloadItemsAtIndexPaths:array];
            }
        }
        NvTipsView *tip = [[NvTipsView alloc]initWithFrame:self.view.frame withTitle:NvLocalString(@"Download failed", @"下载失败，请检查网络设置") withColor:[UIColor nv_colorWithHexRGB:@"#4D4F51"] withCenter:YES];
        [self.view addSubview:tip];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [tip removeFromSuperview];
        });
    });
}

- (void)onDownloadAssetProgress:(NSString *)uuid progress:(int)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.filters.count; i++) {
            NvMoreFilterCollectionCell *cell = (NvMoreFilterCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            NvBaseModel *item = cell.model;
            if ([item.packageId isEqualToString:uuid]) {
                cell.download.progress = progress/100.f;
            }
        }
    });
}

- (void)onDonwloadAssetSuccess:(NSString *)uuid {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.filters.count; i++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            NvMoreFilterCollectionCell *cell = (NvMoreFilterCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            NvBaseModel *item = cell.model;
            if ([item.packageId isEqualToString:uuid]) {
                item.state = Finish;
                NSMutableArray *array = NSMutableArray.new;
                [array addObject:indexPath];
                [self.collectionView reloadItemsAtIndexPaths:array];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:DOLOADPACKAGEFINISH object:nil];
    });
}

- (void)onGetRemoteAssetsFailed {
    if(self.keyword.length <=0 || !self.keyword){
        [self.filters removeAllObjects];
    }
    [self.collectionView reloadData];
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    _failureView.hidden = NO;
}

#pragma mark - 重试按钮点击事件
/*
 重试按钮点击事件
 Retry button click event
 
 @param sender 重试按钮
 Retry button
 
 */
- (void)retry:(UIButton *)sender{
    [self.collectionView.mj_header beginRefreshing];
    _failureView.hidden = YES;
}

- (void)nvMoreFilterCollectionCell:(NvMoreFilterCollectionCell *)nvMoreFilterCell nvBaseModel:(NvBaseModel *)baseModel {
    if ([self isNetwork]) {
        nvMoreFilterCell.download.progress = 0;
        baseModel.state = Downloading;
        [self.assetManager downloadAsset:baseModel.packageId];
    }else{
        NvTipsView *tip = [[NvTipsView alloc]initWithFrame:self.view.frame withTitle:NvLocalString(@"Download failed", @"下载失败，请检查网络设置") withColor:[UIColor nv_colorWithHexRGB:@"#4D4F51"] withCenter:YES];
        [self.view addSubview:tip];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [tip removeFromSuperview];
        });
    }
}

#pragma mark - 检查网络并返回状态
/*
 检查网络并返回状态
 Check network and return status
 
 return 返回BOOL值。YES表示有网络，NO表示无网络。
 Returns the BOOL value. YES means there is a network, NO means there is no network.
 
 */
- (BOOL)isNetwork{
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    if (status == NotReachable) {
        return NO;
    } else if (status == ReachableViaWiFi) {
        return YES;
    } else {
        return YES;
    }
}

#pragma mark - 搜索 search
- (void)searchBarBeginEditing:(NvSearchBar *)searchBar {

}

- (void)searchBarTextInputDidChanged: (NvSearchBar *)searchBar {

}

- (void)searchBarDidCanceled:(NvSearchBar *)searchBar {
    self.keyword = @"";
    int large,minor,revision;
    [NvsStreamingContext getSdkVersion:&large minorVersion:&minor revisionNumber:&revision];
    NvAssetModular modular = self.isCapture ? NvAssetModularCapture : NvAssetModularAll;
    [self.assetManager downloadRemoteAssetsInfo:self.type  categoryId:self.categoryId page:1 pageSize:NV_FILTER_PAGE_SIZE kind:self.kind modular:modular ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NSString stringWithFormat:@"%d.%d.%d",large,minor,revision]];
}

- (void)searchBarBeginSearch:(NvSearchBar *)searchBar {
    NSString* str=searchBar.inputText;
    /*
     1. 去掉首尾空格和换行符
     1. Remove leading and trailing spaces and line breaks
     */
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    /*
     2. 去掉所有空格和换行符
     2. Remove all spaces and newlines
     */
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    self.keyword = str;
    [self.filters removeAllObjects];
    int large,minor,revision;
    [NvsStreamingContext getSdkVersion:&large minorVersion:&minor revisionNumber:&revision];
    NvAssetModular modular = self.isCapture ? NvAssetModularCapture : NvAssetModularAll;
    [self.assetManager downloadRemoteAssetsInfo:self.type categoryId:self.categoryId keyword:self.keyword page:1 pageSize:NV_FILTER_PAGE_SIZE kind:self.kind modular:modular ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NSString stringWithFormat:@"%d.%d.%d",large,minor,revision]];
    [self.searchBar resignFirstResponder];
}


- (NvSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[NvSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.searchBarOption.barSize.width, self.searchBarOption.barSize.height) options: self.searchBarOption];
        _searchBar.isEnableSearch = YES;
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (NvSearchBarOption *)searchBarOption {
    if (!_searchBarOption) {
        _searchBarOption = [[NvSearchBarOption alloc] init];
        _searchBarOption.barInsets = UIEdgeInsetsMake(10 * SCREENSCALE, 14 * SCREENSCALE, 7 * SCREENSCALE, 14 * SCREENSCALE);
        _searchBarOption.barSize = CGSizeMake(SCREENWIDTH, 53 * SCREENSCALE);
        _searchBarOption.barTintColor = [UIColor whiteColor];
        _searchBarOption.barBackgroundColor = [UIColor nv_colorWithHexRGB:@"#F8F8F8"];
        // 搜索图标 Search icon
        _searchBarOption.searchImage = [UIImage imageNamed:@"searchIcon"];
        // 搜索占位属性 Search for placeholder properties
        _searchBarOption.placeHolderText = NvLocalString(@"Search for filter name or UUID", @"搜索滤镜名称或UUID");
        _searchBarOption.placeHolderFont = [NvUtils regularFontWithSize:11 * SCREENSCALE];
        _searchBarOption.placeHolderColor = [UIColor nv_colorWithHexRGB:@"#A4A4A4"];
        _searchBarOption.placeHolderOffset = 10 * SCREENSCALE;
        _searchBarOption.textColor = [UIColor nv_colorWithHexRGB:@"#1F1F1F"];
        _searchBarOption.textFont = [NvUtils regularFontWithSize:13 * SCREENSCALE];
        /// 取消按钮 Cancel button
        _searchBarOption.cancelWidth = 40 * SCREENSCALE;
        _searchBarOption.cancelText = NvLocalString(@"Cancel", @"取消");
        _searchBarOption.cancelTextFont = [NvUtils regularFontWithSize:13 * SCREENSCALE];
        _searchBarOption.cancelTextColor = [UIColor nv_colorWithHexRGB:@"#1F1F1F"];
    }
    return _searchBarOption;
}

@end
