//
//  NvListSearchViewController.h
//  SDKDemo
//
//  Created by ms20180425 on 2022/3/18.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "ViewController.h"
#import <JXCategoryView.h>
#import <NvSDKCommon/NvAsset.h>
#import "NvBaseModel.h"
#import "NvSearchBar.h"

NS_ASSUME_NONNULL_BEGIN

@class NvListSearchViewController;

@protocol NvListSearchViewControllerDelegate <NSObject>

@optional

- (void)listSearchListVC:(NvListSearchViewController *)vc withApplyEffects:(NvBaseModel *)model;

@end

@interface NvListSearchViewController : NvBaseViewController<JXCategoryListContentViewDelegate>

@property (nonatomic, weak) id<NvListSearchViewControllerDelegate>delegate;

/// 素材类型 Material type
@property (nonatomic, assign) AssetType type;

/// 素材三级分类 Material type
@property (nonatomic, assign) int kind;

/// 素材分类 Material classification
@property (nonatomic, assign) int categoryId;

/// 素材总分类 Material classification
@property (nonatomic, strong) NSString *categoryList;

@property (nonatomic, strong) NvSearchBar *searchBar;

- (void)UncheckStatus;

@end

NS_ASSUME_NONNULL_END
