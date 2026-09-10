//
//  NvListSearchViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2022/3/18.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvListSearchViewController.h"
#import <NvSDKCommon/NvAssetManager.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import <NvSDKCommon/NvHttpRequest.h>
#import "NvTipsView.h"
#import "MJRefresh.h"
#import "NvListItemCollectionViewCell.h"
#import "NvTitleListDataManger.h"
#import "NvFilterListViewController.h"

@interface NvListSearchViewController ()<NvAssetManagerDelegate,NvHttpRequestDelegate,UICollectionViewDelegate,UICollectionViewDataSource,NvSearchBarDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) BOOL isPull;

@property (nonatomic, strong) NvAssetManager *assetManager;

@property (nonatomic, strong) NvBaseModel *currentModel;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) BOOL isInitialize;

@property (nonatomic, strong) NvSearchBarOption *searchBarOption;
@property (nonatomic, strong) NSString *keyword;

@property (nonatomic, assign) BOOL currentRequest;

@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation NvListSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.dataArray = [NSMutableArray array];
    
    self.assetManager = [NvAssetManager sharedInstance];
    [self.assetManager.hashTable addObject:self];
    
    
}

#pragma mark - 初始化界面 Initialization interface
- (void)addSubViews{
    [self.view addSubview:self.searchBar];
    
    CGFloat bottomSafeDistance = (NV_STATUSBARHEIGHT>20)?10:0;
    CGFloat spanceY = CGRectGetMaxY(self.searchBar.frame);
    CGFloat itemSizeWidth = 50*SCREENSCALE;
    CGFloat itemSizeHeight = 76*SCREENSCALE;
    CGFloat collectionViewHeight = self.view.frame.size.height-spanceY - bottomSafeDistance;
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    if (self.type == ASSET_FILTER) {
        flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        if (collectionViewHeight > itemSizeHeight) {
            collectionViewHeight = itemSizeHeight+10*SCREENSCALE;
        }
        flow.minimumLineSpacing = 8*SCREENSCALE;
    }else{
        itemSizeWidth = 60*SCREENSCALE;
        itemSizeHeight = 86*SCREENSCALE;
        flow.scrollDirection = UICollectionViewScrollDirectionVertical;
        flow.minimumLineSpacing = 8*SCREENSCALE;
        flow.minimumInteritemSpacing = 0;
    }
    
    flow.itemSize = CGSizeMake(itemSizeWidth, itemSizeHeight);

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, spanceY, SCREENWIDTH, collectionViewHeight) collectionViewLayout:flow];
    self.collectionView.backgroundColor = UIColor.whiteColor;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerClass:[NvListItemCollectionViewCell class] forCellWithReuseIdentifier:@"NvListItemCollectionViewCell"];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 15*SCREENSCALE, 0, 15*SCREENSCALE);
    
    [self.view addSubview:self.collectionView];
    
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

- (NSString *)getSearchViewPlaceholder {
    if (self.type == ASSET_ANIMATED_STICKER) {
        return NvLocalString(@"Search for animatedSticker name or UUID", @"搜索贴纸名称或UUID");
    } else if (self.type == ASSET_COMPOUND_CAPTION) {
        return NvLocalString(@"Search for compoundCaption name or UUID", @"搜索组合字幕名称或UUID");
    } else if (self.type == ASSET_ARSCENE) {
        return NvLocalString(@"Search for prop name or UUID", @"搜索道具名称或UUID");
    }
    return NvLocalString(@"Search for filter name or UUID", @"搜索滤镜名称或UUID");
}

#pragma mark - 配置数据 Configuration data
- (void)configData{
    __block int page = 1;
    int pageSize = 20;
    int large,minor,revision;
    [NvsStreamingContext getSdkVersion:&large minorVersion:&minor revisionNumber:&revision];
    __weak typeof(self) weakSelf = self;
    if (self.type == ASSET_FILTER) {
        MJRefreshNormalTrailer *trailer = [MJRefreshNormalTrailer trailerWithRefreshingBlock:^{
            weakSelf.isPull = YES;
            weakSelf.currentRequest = YES;
            page++;
            [weakSelf.assetManager newDownloadRemoteAssetsInfo:weakSelf.type categoryId:weakSelf.categoryId categoryList:weakSelf.categoryList keyword:weakSelf.keyword page:page pageSize:pageSize kind:weakSelf.kind ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NSString stringWithFormat:@"%d.%d.%d",large,minor,revision]];
        }];
        trailer.arrowView.hidden = YES;
        self.collectionView.mj_trailer = trailer;
    }else{
        if (self.type != ASSET_ARSCENE) {
            self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                weakSelf.isPull = YES;
                weakSelf.currentRequest = YES;
                page++;
                [weakSelf.assetManager newDownloadRemoteAssetsInfo:weakSelf.type categoryId:weakSelf.categoryId categoryList:weakSelf.categoryList keyword:weakSelf.keyword page:page pageSize:pageSize kind:weakSelf.kind ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NSString stringWithFormat:@"%d.%d.%d",large,minor,revision]];
            }];
        }
        
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvListItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvListItemCollectionViewCell" forIndexPath:indexPath];
    cell.type = self.type;
    [cell configData:self.dataArray[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NvBaseModel *model = self.dataArray[indexPath.item];
    [NvTitleListDataManger standardDefaults].lastClickPackId= model.packageId;
    if (model.state == Finish) {
        for (NvBaseModel *model in self.dataArray) {
            model.selected = NO;
        }
        
        self.currentModel = model;
        self.currentModel.selected = YES;
        [self applyEffects];
        [collectionView reloadData];
    }else if (model.state == Update) {
        [self downloadMaterial:model];
    }else if (model.state == Downloading) {
        
    }else if (model.state == DownloadError || model.state == NODownload) {
        [self downloadMaterial:model];
    }
}

#pragma mark - 下载素材 Download material
- (void)downloadMaterial:(NvBaseModel *)model{
    NSInteger index = [self.dataArray indexOfObject:model];
    NvListItemCollectionViewCell *cell = (NvListItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    model.state = Downloading;
    [cell configData:model];
    [self.assetManager downloadAsset:model.packageId];
}

#pragma mark - 应用特效 Applied special effect
- (void)applyEffects{
    NSLog(@"应用特效 Applied special effect=====================%@",self.currentModel.displayName);
    if (self.delegate && [self.delegate respondsToSelector:@selector(listSearchListVC:withApplyEffects:)]) {
        [self.delegate listSearchListVC:self withApplyEffects:self.currentModel];
    }
}

#pragma mark - 取消数组的选中状态 Uncheck the array
- (void)UncheckStatus{
    self.currentModel = nil;
    for (NvBaseModel *model in self.dataArray) {
        if ([model.packageId isEqualToString:[NvTitleListDataManger standardDefaults].lastClickPackId]) {
            model.selected = YES;
            self.currentModel = model;
        }else{
            model.selected = NO;
        }
    }
    
    [self.collectionView reloadData];
}

#pragma mark - NvHttpRequestDelegate
- (void)onRemoteAssetsChanged:(BOOL)hasNext {
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    [self.collectionView.mj_trailer endRefreshing];
    if (!self.currentRequest) {
        return;
    }
    self.currentRequest = NO;
    NSArray *array = [self.assetManager getRemoteAssets:self.type aspectRatio:AspectRatio_All categoryId:self.categoryId kindId:self.kind keyword:self.keyword];
    if (array && array.count > 0) {
        self.tipLabel.hidden = YES;
    }else{
        self.tipLabel.hidden = NO;
        [self setTipString:self.keyword];
    }
    
    if (array.count - self.dataArray.count == 0) {
        hasNext = NO;
    }else{
        hasNext = YES;
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
        model.kindId = asset.kind;
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
        if (self.type == ASSET_FILTER) {
            model.value = DefaultFilterStrength;
        }
        [self.dataArray addObject:model];
    }
    
    [self.collectionView reloadData];
    
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

- (void)onGetRemoteAssetsFailed {
    [self.collectionView reloadData];
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
}

#pragma mark - NvHttpRequestDelegate
- (void)onDonwloadAssetFailed:(NSString *)uuid{
    NSLog(@"素材下载失败 Material download failure=====================%@d",uuid);
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.dataArray.count; i++) {
            NvBaseModel *item = self.dataArray[i];
            if ([item.packageId isEqualToString:uuid]) {
                item.state = NODownload;
                NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                NSMutableArray *array = NSMutableArray.new;
                [array addObject:indexPath];
                [self.collectionView reloadItemsAtIndexPaths:array];
            }
        }
    });
}

- (void)onDonwloadAssetSuccess:(NSString *)uuid withPath:(NSString *)path{
    NSLog(@"素材下载成功 Material download success=====================%@",uuid);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger selectedIndex = -1;
        if(self.currentModel && self.currentModel.packageId) {
            selectedIndex = [self.dataArray indexOfObject:self.currentModel];
        }
        for (int i = 0; i < self.dataArray.count; i++) {
            NvBaseModel *item = self.dataArray[i];
            if ([item.packageId isEqualToString:uuid]) {
                item.state = Finish;
                item.packagePath = path;
                if ([[NvTitleListDataManger standardDefaults].lastClickPackId isEqualToString:uuid]) {
                    for (NvBaseModel *model in self.dataArray) {
                        model.selected = NO;
                    }
                    
                    self.currentModel = item;
                    self.currentModel.selected = YES;
                    [self applyEffects];
                }
                
                NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                NSMutableArray *array = NSMutableArray.new;
                [array addObject:indexPath];
                if(selectedIndex != -1) {
                    [array addObject:[NSIndexPath indexPathForItem:selectedIndex inSection:0]];
                }
                [self.collectionView reloadItemsAtIndexPaths:array];
            }
        }
    });
}

#pragma mark - NvSearchBarDelegate
- (void)searchBarBeginEditing:(NvSearchBar *)searchBar {

}

- (void)searchBarTextInputDidChanged: (NvSearchBar *)searchBar {

}

- (void)searchBarDidCanceled:(NvSearchBar *)searchBar {
   
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
    [self.dataArray removeAllObjects];
    int large,minor,revision;
    [NvsStreamingContext getSdkVersion:&large minorVersion:&minor revisionNumber:&revision];
    [self.assetManager newDownloadRemoteAssetsInfo:self.type categoryId:self.categoryId categoryList:self.categoryList keyword:self.keyword page:1 pageSize:20 kind:self.kind ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NSString stringWithFormat:@"%d.%d.%d",large,minor,revision]];
    [self.searchBar resignFirstResponder];
    self.currentRequest = YES;
}

- (void)setTipString:(NSString *)string{
    if ([NvUtils currentLanguagesIsChinese]){
        self.tipLabel.text = [NSString stringWithFormat:@"抱歉，没有找到\"%@\"相关的素材",string];
    }else{
        self.tipLabel.text = [NSString stringWithFormat:@"Sorry, no material related to \"%@\" was found",string];
    }
}

#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}

- (void)listDidAppear{
    [self addSubViews];
    [self configData];
}

#pragma mark - 懒加载 Lazy loading
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
        _searchBarOption.barInsets = UIEdgeInsetsMake(10 * SCREENSCALE, 15 * SCREENSCALE, 10 * SCREENSCALE, 15* SCREENSCALE);
        _searchBarOption.barSize = CGSizeMake(SCREENWIDTH, 60 * SCREENSCALE);
        _searchBarOption.barTintColor = [UIColor nv_colorWithHexRGB:@"#F5F5F5"];
        _searchBarOption.barBackgroundColor = [UIColor whiteColor];
        _searchBarOption.searchImage = [UIImage imageNamed:@"searchIcon"];
        _searchBarOption.placeHolderText = [self getSearchViewPlaceholder];
        _searchBarOption.placeHolderFont = [NvUtils regularFontWithSize:11 * SCREENSCALE];
        _searchBarOption.placeHolderColor = [UIColor nv_colorWithHexRGB:@"#A4A4A4"];
        _searchBarOption.placeHolderOffset = 10 * SCREENSCALE;
        _searchBarOption.textColor = [UIColor nv_colorWithHexRGB:@"#1F1F1F"];
        _searchBarOption.textFont = [NvUtils regularFontWithSize:13 * SCREENSCALE];
        _searchBarOption.cancelWidth = 40 * SCREENSCALE;
        _searchBarOption.cancelText = NvLocalString(@"Cancel", @"取消");
        _searchBarOption.cancelTextFont = [NvUtils regularFontWithSize:13 * SCREENSCALE];
        _searchBarOption.cancelTextColor = [UIColor nv_colorWithHexRGB:@"#1F1F1F"];
    }
    return _searchBarOption;
}

@end

