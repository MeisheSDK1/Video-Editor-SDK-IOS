//
//  NvAlbumCollectionView.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvAlbumCollectionView.h"
#import "NvAllAssetCell.h"
#import "NvAlbumItem.h"
#import "NvAlbumUtils.h"
#import "NvAlbumViewController.h"
#import <Masonry/Masonry.h>
#import "UIButton+NvButton.h"
#import "UIColor+NvColor.h"
#import "NVDefineConfig.h"
@import Photos;

@interface NvAlbumCollectionView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *allAssetColloection;

@property (nonatomic, strong) NvFetchAlbum *fetchAlbum;
@property (nonatomic, assign) NvAlbumAssetType type;

@end

static NSString *kAllPHAssetIdentify = @"kAllPHAssetIdentify";
static NSString *kHeaderPHAssetIdentify = @"kHeaderPHAssetIdentify";

@implementation NvAlbumCollectionView

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame withMediaType:NvAlbumAssetAll];
}

- (instancetype)initWithFrame:(CGRect)frame withMediaType:(NvAlbumAssetType)type {
    if (self = [super initWithFrame:frame]) {
        self.mutableSelect = YES;
        self.type = type;
        [self initData];
        [self initSubViews];

    }
    return self;
}

// MARK: 初始化数据
// Initializing data
- (void)initData {
    self.assetDataSource = [NSMutableArray new];
}

- (void)reloadData {
    [self.allAssetColloection reloadData];
}

- (void)reloadVisibleCellData {
    [self.allAssetColloection reloadItemsAtIndexPaths:self.allAssetColloection.indexPathsForVisibleItems];
}


// MARK: UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetDataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvAllAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAllPHAssetIdentify forIndexPath:indexPath];
    cell.mutableSelect = self.mutableSelect;
    PHAsset *asset = self.assetDataSource[indexPath.item];
    asset.isShowLayer = [self.selectAssetSource containsObject:asset];
    if (asset.isShowLayer) {
        NSUInteger index = [self.selectAssetSource indexOfObject:asset];
        PHAsset *selectAsset = self.selectAssetSource[index];
        asset.number = selectAsset.number;
    }
    cell.fileSwitch.on = [self.useOriginalAssetSource containsObject:asset.localIdentifier];
    cell.delegate = self;
    [cell renderCellWithAsset:asset];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    PHAsset *asset = self.assetDataSource[indexPath.item];
    asset.isShowLayer = !asset.isShowLayer;
    if([self.delegate respondsToSelector:@selector(nvAlbumCollectionView:selectAsset:)]) {
        [self.delegate nvAlbumCollectionView:self selectAsset:asset];
    }
}

- (void)cellSwitchValueChanged:(BOOL)on asset:(PHAsset *)asset {
    if (!on) {
        [self.useOriginalAssetSource removeObject:asset.localIdentifier];
    } else {
        [self.useOriginalAssetSource addObject:asset.localIdentifier];
    }
}

- (void)initSubViews {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 4*SCREENSCALE;
    flowLayout.minimumInteritemSpacing = 5*SCREENSCALE;
    CGFloat itemWidth = (SCREENWIDTH - flowLayout.minimumInteritemSpacing*2 - 5*SCREENSCALE) / 3 - 2;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 2.5*SCREENSCALE, 0, 2.5*SCREENSCALE);
    self.allAssetColloection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.allAssetColloection.delegate = self;
    self.allAssetColloection.dataSource = self;
    self.allAssetColloection.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    [self.allAssetColloection registerClass:[NvAllAssetCell class] forCellWithReuseIdentifier:kAllPHAssetIdentify];
    
    [self.allAssetColloection registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderPHAssetIdentify];
    
    [self addSubview:self.allAssetColloection];
    [self.allAssetColloection mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.top.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
