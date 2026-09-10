//
//  NvStickerCustomViewController.m
//  SDKDemo
//
//  Created by 李勇 on 2022/3/28.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvStickerCustomViewController.h"
#import "NvTitleListDataManger.h"
#import "NvCaptureStickerMoreStyleCell.h"
#import "NvCaptureStickerStyleCell.h"
#import "NvAssetManager.h"

@interface NvStickerCustomViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) NSMutableArray *customStickerArray;
@property(nonatomic, strong) NvBaseModel *currentModel;
@property(nonatomic, strong) UICollectionView *customCollectionView;
@property(nonatomic, strong) NvAssetManager *assetManager;

@end

@implementation NvStickerCustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.assetManager = [NvAssetManager sharedInstance];
    self.view.backgroundColor = UIColor.whiteColor;
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addCustomSticker];
    
}
- (BOOL)isCustomStickerExist:(NSString *)uuid {
    for (NvAssetCellModel *item in self.customStickerArray) {
        if ([item.package isEqualToString:uuid])
            return YES;
    }
    return NO;
}
-(void)addCustomSticker{
    self.customStickerArray = [NSMutableArray array];
    NvAssetCellModel *model = NvAssetCellModel.new;
    model.displayName = NvLocalString(@"Add", @"添加");
    model.cover = @"add_custom_sticker";
    [self.customStickerArray addObject:model];
    NSMutableDictionary *customStickers = self.assetManager.customStickerDict;
    for (NSString *key in customStickers) {
        if ([self isCustomStickerExist:key])
            continue;
        NvCustomStickerInfo *info = customStickers[key];
        NvAssetCellModel *assetModel = NvAssetCellModel.new;
        assetModel.displayName = @"";
        assetModel.cover = info.imagePath;
        assetModel.package = info.uuid;
        assetModel.templateId = info.templateUuid;
        if (info.tempImage) {
            assetModel.covergif = info.tempImage;
        }
        [self.customStickerArray insertObject:assetModel atIndex:self.customStickerArray.count];
    }
    [self.customCollectionView reloadData];
}

- (void)UncheckStatus{
    self.currentModel = nil;
    for (NvBaseModel *model in self.customStickerArray) {
        if ([model isKindOfClass:[NvBaseModel class]]) {
            if ([model.packageId isEqualToString:[NvTitleListDataManger standardDefaults].lastClickPackId]) {
                model.selected = YES;
                self.currentModel = model;
            }else{
                model.selected = NO;
            }
        }else if ([model isKindOfClass:[NvAssetCellModel class]]){
            NvAssetCellModel * tmp = (NvAssetCellModel *)model;
            if ([tmp.packID isEqualToString:[NvTitleListDataManger standardDefaults].lastClickPackId]) {
                tmp.selected = YES;
                self.currentModel = model;
            }else{
                model.selected = NO;
            }
        }
    }
    
    [self.customCollectionView reloadData];
}

#pragma mark collectionDelegate & datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.customStickerArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        NvCaptureStickerMoreStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvCaptureStickerMoreStyleCell" forIndexPath:indexPath];
        cell.assetModel = self.customStickerArray[indexPath.row];
        return cell;
    }else{
        NvCaptureStickerStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvStyleCollectionViewCell" forIndexPath:indexPath];
        cell.assetModel = self.customStickerArray[indexPath.row];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        if ([self.delegate respondsToSelector:@selector(NvStickerCustomViewControllerDelegateAddCusstomSticker:)]) {
            [self.delegate NvStickerCustomViewControllerDelegateAddCusstomSticker:self];
        }
        return;
    }
    
    for (NvAssetCellModel *item in self.customStickerArray) {
        item.selected = NO;
    }

    NvAssetCellModel *item = self.customStickerArray[indexPath.item];
    item.selected = YES;

    if ([self.delegate respondsToSelector:@selector(NvStickerCustomViewControllerDelegateAddSticker:assetCellModel:)]) {
        [self.delegate NvStickerCustomViewControllerDelegateAddSticker:self assetCellModel:item];
    }
    [self.customCollectionView reloadData];
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.customCollectionView.frame = self.view.bounds;
}
#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}

- (void)changeAsset:(NSString *)uuid withDestinationIndex:(NSInteger)index {
    
}
#pragma -mark getter
- (UICollectionView *)customCollectionView {
    if (!_customCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        CGFloat itemSizeWidth = 60*SCREENSCALE;
        CGFloat itemSizeHeight = 60*SCREENSCALE;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.minimumLineSpacing = 8*SCREENSCALE;
        flowLayout.minimumInteritemSpacing = (SCREENWIDTH - 30*SCREENSCALE- itemSizeWidth*5)/4.0;
        
        flowLayout.itemSize = CGSizeMake(itemSizeWidth, itemSizeHeight);
        _customCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        
        _customCollectionView.delegate = self;
        _customCollectionView.dataSource = self;
        _customCollectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#ffffff"];
        [_customCollectionView registerClass:[NvCaptureStickerStyleCell class] forCellWithReuseIdentifier:@"NvStyleCollectionViewCell"];
        [_customCollectionView registerClass:[NvCaptureStickerMoreStyleCell class] forCellWithReuseIdentifier:@"NvCaptureStickerMoreStyleCell"];
        [_customCollectionView setShowsHorizontalScrollIndicator:NO];
        [self.view addSubview:_customCollectionView];
        _customCollectionView.contentInset = UIEdgeInsetsMake(0, 15*SCREENSCALE, 0, 15*SCREENSCALE);

    }
    return  _customCollectionView;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 0, 0, 0);
}
@end
