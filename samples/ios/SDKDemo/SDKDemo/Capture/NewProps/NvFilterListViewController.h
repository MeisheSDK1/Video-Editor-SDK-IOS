//
//  NvFilterListViewController.h
//  SDKDemo
//
//  Created by ms20180425 on 2022/3/17.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "ViewController.h"
#import <JXCategoryView.h>
#import <NvSDKCommon/NvAsset.h>
#import "NvBaseModel.h"

NS_ASSUME_NONNULL_BEGIN
@class NvFilterListViewController;

@protocol NvFilterListViewControllerDelegate <NSObject>

@optional

- (void)filterListVC:(NvFilterListViewController *)vc withApplyEffects:(NvBaseModel *)model;

@end

@interface NvFilterListViewController : NvBaseViewController<JXCategoryListContentViewDelegate>

@property (nonatomic, weak) id<NvFilterListViewControllerDelegate>delegate;

/// 素材一级分类 Material type
@property (nonatomic, assign) AssetType type;

/// 素材三级分类 Material type
@property (nonatomic, assign) int kind;

/// 素材二级分类 Material classification
@property (nonatomic, assign) int categoryId;

/// 素材二级分类数组 Material classification
@property (nonatomic, strong) NSString *categoryList;

/// 本地素材文件夹路径 Path to the local material folder
@property (nonatomic, strong) NSString *localMaterialPath;

- (void)UncheckStatus;

- (void)changeAsset:(NSString *)uuid withDestinationIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
