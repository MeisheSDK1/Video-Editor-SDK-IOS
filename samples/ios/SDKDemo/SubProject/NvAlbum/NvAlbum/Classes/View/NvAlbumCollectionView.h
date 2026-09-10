//
//  NvAlbumCollectionView.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvFetchAlbum.h"
#import "PHAsset+NvAlbum.h"
@class NvAlbumCollectionView;

@protocol NvAlbumCollectionViewDelegate

//全选
//select all
- (void)nvAlbumCollectionView:(NvAlbumCollectionView *)nvAlbumCollectionView selectAssets:(NSMutableArray <PHAsset *>*)selectAssets completionBlock:(void(^)(void))block;
//反全选
//deselect all
- (void)nvAlbumCollectionView:(NvAlbumCollectionView *)nvAlbumCollectionView deselectAssets:(NSMutableArray <PHAsset *>*)selectAssets;
//单选
//select
- (void)nvAlbumCollectionView:(NvAlbumCollectionView *)nvAlbumCollectionView selectAsset:(PHAsset *)selectAsset;

@end

@interface NvAlbumCollectionView : UIView

@property (weak, nonatomic) id delegate;

@property (nonatomic, strong) NSMutableArray<PHAsset *> *assetDataSource;
// Multi-select, default YES, no number mark for radio
@property (nonatomic, assign) BOOL mutableSelect; //是否多选，默认YES,单选不会有数字标记
// Whether to hide the all-select button
@property (nonatomic, assign) BOOL hiddenSelectAll; //是否隐藏全选按钮
@property (nonatomic, strong) NSMutableArray <PHAsset *>*selectAssetSource;//被选择的资源
@property (nonatomic, strong) NSMutableArray <NSString *>*useOriginalAssetSource;

- (instancetype)initWithFrame:(CGRect)frame withMediaType:(NvAlbumAssetType)type;

- (void)reloadData;

- (void)reloadVisibleCellData;
@end
