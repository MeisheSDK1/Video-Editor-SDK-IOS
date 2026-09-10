//
//  NvFilterListViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2022/3/17.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvFilterListViewController.h"
#import <NvSDKCommon/NvAssetManager.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import <NvSDKCommon/NvHttpRequest.h>
#import "NvTipsView.h"
#import "MJRefresh.h"
#import "NvListItemCollectionViewCell.h"
#import "NvTitleListDataManger.h"

@interface NvDownloadTaskInfo : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) void(^progressBlock)(float progress);
@property (nonatomic, strong) void(^complateBlock)(bool isFinish);

@end

@implementation NvDownloadTaskInfo

@end

@interface NvFilterListViewController ()<NvAssetManagerDelegate,NvHttpRequestDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) BOOL isPull;

@property (nonatomic, strong) NvAssetManager *assetManager;

@property (nonatomic, strong) NvBaseModel *currentModel;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) BOOL isInitialize;

@property (nonatomic, assign) BOOL currentRequest;

@property (nonatomic, copy) NSString *defaultFilter;

@property (nonatomic, assign) NSInteger destinationChangeIndex;

@property (nonatomic, strong) NSMutableArray <NvDownloadTaskInfo *>*tasks;

@end

@implementation NvFilterListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.tasks = [NSMutableArray array];
    self.dataArray = [NSMutableArray array];
    
    self.assetManager = [NvAssetManager sharedInstance];
    [self.assetManager.hashTable addObject:self];
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
            weakSelf.currentRequest = YES;
            weakSelf.isPull = YES;
            page++;
            [weakSelf.assetManager newDownloadRemoteAssetsInfo:weakSelf.type categoryId:weakSelf.categoryId categoryList:weakSelf.categoryList keyword:nil page:page pageSize:pageSize kind:weakSelf.kind ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NSString stringWithFormat:@"%d.%d.%d",large,minor,revision]];
        }];
        trailer.arrowView.hidden = YES;
        self.collectionView.mj_trailer = trailer;
    }else{
        self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            weakSelf.currentRequest = YES;
            weakSelf.isPull = YES;
            page++;
            [weakSelf.assetManager newDownloadRemoteAssetsInfo:weakSelf.type categoryId:weakSelf.categoryId categoryList:weakSelf.categoryList keyword:nil page:page pageSize:pageSize kind:weakSelf.kind ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NSString stringWithFormat:@"%d.%d.%d",large,minor,revision]];
        }];
    }
    
    self.isPull = NO;
    [self.dataArray removeAllObjects];
    [weakSelf.assetManager newDownloadRemoteAssetsInfo:weakSelf.type categoryId:weakSelf.categoryId categoryList:weakSelf.categoryList keyword:nil page:page pageSize:pageSize kind:weakSelf.kind ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NSString stringWithFormat:@"%d.%d.%d",large,minor,revision]];
    self.currentRequest = YES;
    
    NSLog(@"当前类型 Current type=====================%d,%d,%d",self.type,self.categoryId,self.kind);
}

- (void)changeAsset:(NSString *)uuid withDestinationIndex:(NSInteger)index {
    if (self.destinationChangeIndex != index) {
        self.destinationChangeIndex = index;
    }
    if (![self.defaultFilter isEqualToString:uuid] || !self.defaultFilter) {
        self.defaultFilter = uuid;
    }
    
    if(self.dataArray.count > 0){
        NSInteger sourceIndex = -1;
        for (NvBaseModel *model in self.dataArray) {
            if ([model.packageId isEqualToString:uuid]) {
                sourceIndex = [self.dataArray indexOfObject:model];
                model.selected = YES;
                break;
            }
        }
        if (sourceIndex != -1 && index != sourceIndex) {
            NvBaseModel *model = self.dataArray[index];
            model.selected = NO;
            [self.dataArray exchangeObjectAtIndex:index withObjectAtIndex:sourceIndex];
            [self.collectionView reloadData];
            [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        }
    }
}

#pragma mark - 配置本地数据 Configuring local data
- (void)configDataLocal{
    NSArray *array = [self.assetManager searchLocalMaterialAssets:self.type bundlePath:self.localMaterialPath];
    [self.dataArray removeAllObjects];
    for (NvAsset *asset in array) {
        NvBaseModel *model = [[NvBaseModel alloc]init];
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            model.displayName = asset.displayNamezhCN;
        }else{
            model.displayName = asset.displayName;
        }

        model.coverName = asset.coverUrl;
        model.packageId = asset.uuid;
        model.state = Finish;
        model.packagePath = asset.localDirPath;
        model.isAdjusted = asset.isAdjusted;
        if (self.type == ASSET_FILTER) {
            model.value = DefaultFilterStrength;
        }
        [self.dataArray addObject:model];
    }
    [self changeAsset:self.defaultFilter withDestinationIndex:self.destinationChangeIndex];
    [self.collectionView reloadData];
}

#pragma mark - 初始化界面 Initialization interface
- (void)addSubViews{
    CGFloat bottomSafeDistance = (NV_STATUSBARHEIGHT>20)?10:0;
    CGFloat spanceY = 10*SCREENSCALE;
    CGFloat itemSizeWidth = 50*SCREENSCALE;
    CGFloat itemSizeHeight = 76*SCREENSCALE;
    CGFloat collectionViewHeight = self.view.frame.size.height-spanceY-bottomSafeDistance;
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    if (self.type == ASSET_FILTER) {
        
        flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        if (![NvUtils currentLanguagesIsChinese]) {
            
            itemSizeWidth = 74*SCREENSCALE;
            itemSizeHeight = 100*SCREENSCALE;
        }
        if (collectionViewHeight > itemSizeHeight) {
            
            collectionViewHeight = itemSizeHeight + 10*SCREENSCALE;
            if(![NvUtils currentLanguagesIsChinese]){
                collectionViewHeight = itemSizeHeight + 18*SCREENSCALE;
            }
        }
        flow.minimumLineSpacing = 8*SCREENSCALE;
    }else{
        
        itemSizeWidth = 60*SCREENSCALE;
        itemSizeHeight = 86*SCREENSCALE;
        if (![NvUtils currentLanguagesIsChinese]) {
            itemSizeWidth = 74*SCREENSCALE;
            itemSizeHeight = 100*SCREENSCALE;
        }
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
    self.collectionView.contentInset = UIEdgeInsetsMake(2*SCREENSCALE, 15*SCREENSCALE, 0, 15*SCREENSCALE);
    
    [self.view addSubview:self.collectionView];
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
    [NvTitleListDataManger standardDefaults].lastClickPackId = model.packageId;
    NvListItemCollectionViewCell *cell = (NvListItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (model.state == Finish) {
        for (NvBaseModel *model in self.dataArray) {
            model.selected = NO;
        }
        
        self.currentModel = model;
        self.currentModel.selected = YES;
        [self applyEffects];
        [collectionView reloadData];
    }else if (model.state == Downloading) {
        
    }else if (model.state == DownloadError || model.state == NODownload || model.state == Update) {
        model.state = Downloading;
        [cell setState:model.state];
        [self downloadMaterial:model progress:^(float progressValue) {
            NSLog(@"progressValue: %f",progressValue);
        } complate:^(bool isFinish) {
            if (isFinish) {
                model.state = Finish;
            } else {
                model.state = DownloadError;
            }
            [cell setState:model.state];
        }];
    }
}

- (void)downloadMaterial:(NvBaseModel *)model progress:(void(^)(float progressValue))progressBlock complate:(void(^)(bool isFinish))complateBlock {
    NvDownloadTaskInfo *taskInfo = [[NvDownloadTaskInfo alloc] init];
    taskInfo.uuid = model.packageId;
    taskInfo.progressBlock = progressBlock;
    taskInfo.complateBlock = complateBlock;
    [self.tasks addObject:taskInfo];
    [self downloadMaterial:model];
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(filterListVC:withApplyEffects:)]) {
        [self.delegate filterListVC:self withApplyEffects:self.currentModel];
    }
}

#pragma mark - 取消数组的选中状态 Uncheck the array
- (void)UncheckStatus{
    self.currentModel = nil;
    for (NvBaseModel *model in self.dataArray) {
        if ([model.packageId isEqualToString:[NvTitleListDataManger standardDefaults].lastClickPackId]) {
            if (model.state != Finish || model.state != Update) {
                model.state = Finish;
            }
            model.selected = YES;
            self.currentModel = model;
        }else{
            model.selected = NO;
        }
    }
    
    [self.collectionView reloadData];
}

#pragma mark - NvHttpRequestDelegate
- (void)onRemoteAssetsChanged:(BOOL)hasNext{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    [self.collectionView.mj_trailer endRefreshing];
    if (!self.currentRequest) {
        return;
    }
    self.currentRequest = NO;
    NSLog(@"当前类型 Current type=====================%d,%d,%d",self.type,self.categoryId,self.kind);
    
    NSArray *array = [self.assetManager getRemoteAssets:self.type aspectRatio:AspectRatio_All categoryId:self.categoryId kindId:self.kind];
    
    if (array.count - self.dataArray.count == 0) {
        hasNext = NO;
    }else{
        hasNext = YES;
    }
    
    [self.dataArray removeAllObjects];
    
    BOOL containDefaultFilter = NO;
    for (NvAsset *asset in array) {
        NvBaseModel *model = [[NvBaseModel alloc]init];
        if (self.kind == 1 && self.categoryId == 1) {
            if ([asset.uuid isEqualToString:self.defaultFilter]) {
                containDefaultFilter = YES;
            }
        }
        
        if ([NvUtils currentLanguagesIsChinese] && (asset.displayNamezhCN || asset.displayNameZhCn)){
            model.displayName = asset.displayNamezhCN.length > 0 ? asset.displayNamezhCN : asset.displayNameZhCn;
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
        if ([asset isReserved]) {
            model.packagePath = asset.bundledLocalDirPath;
        }else{
            model.packagePath = asset.localDirPath;
        }
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
        
        if (!containDefaultFilter){
            [self.dataArray addObject:model];
        }
        
        if ([model.packageId isEqualToString:[NvTitleListDataManger standardDefaults].lastClickPackId] && [NvTitleListDataManger standardDefaults].lastClickPackId.length > 0){
            model.selected = YES;
        }else{
            model.selected = NO;
        }
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
    [self.collectionView.mj_trailer endRefreshing];
}

#pragma mark - NvHttpRequestDelegate
- (void)onDonwloadAssetFailed:(NSString *)uuid{
    NSLog(@"素材下载失败 Material download failure=====================%@d",uuid);
    for (NvDownloadTaskInfo *info in self.tasks) {
        if ([info.uuid isEqualToString:uuid]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (info.complateBlock) {
                    info.complateBlock(false);
                }
                [self.tasks removeObject:info];
            });
            break;
        }
    }
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

- (void)onDownloadAssetProgress:(NSString *)uuid progress:(int)progress {
    for (NvDownloadTaskInfo *info in self.tasks) {
        if ([info.uuid isEqualToString:uuid]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (info.progressBlock) {
                    info.progressBlock(progress);
                }
            });
            break;
        }
    }
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.dataArray.count; i++) {
            NvListItemCollectionViewCell *cell = (NvListItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            NvBaseModel *item = cell.model;
            if ([item.packageId isEqualToString:uuid]) {

            }
        }
    });
     */
}

- (void)onDonwloadAssetSuccess:(NSString *)uuid withPath:(NSString *)path{
    NSLog(@"素材下载成功 Material download success=====================%@",uuid);
    for (NvDownloadTaskInfo *info in self.tasks) {
        if ([info.uuid isEqualToString:uuid]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (info.complateBlock) {
                    info.complateBlock(true);
                }
                [self.tasks removeObject:info];
            });
            break;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
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
                [self.collectionView reloadData];
            }
        }
    });
}

#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}

- (void)listDidAppear{
    if (!self.collectionView) {
        [self addSubViews];
        if (self.isInitialize) {
            [self.collectionView reloadData];
        }
    }
    if (self.isInitialize) {
        return;
    }
    self.isInitialize = YES;
    
    if (self.localMaterialPath && self.localMaterialPath.length > 0) {
        [self configDataLocal];
    }else{
        [self configData];
    }
}

- (void)listDidDisappear {
    if ([NvUtils lowPerformance]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collectionView removeFromSuperview];
            self.collectionView = nil;
        });
    }
}

@end

