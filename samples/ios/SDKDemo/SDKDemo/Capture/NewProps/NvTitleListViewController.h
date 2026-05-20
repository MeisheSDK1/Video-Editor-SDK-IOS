//
//  NvTitleListViewController.h
//  SDKDemo
//
//  Created by ms20180425 on 2022/3/16.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "ViewController.h"
#import <NvSDKCommon/NvAsset.h>
#import "NvFilterListViewController.h"
#import "NvAssetCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@class NvTitleListViewController;
@class NvBaseModel;


@protocol NvTitleListViewControllerDelegate <NSObject>

@optional

- (void)titleListVC:(NvTitleListViewController *)vc withApplyEffects:(NvBaseModel * _Nullable)model;

- (void)titleListVC:(NvTitleListViewController *)vc withKeyboardShow:(BOOL)show;
//sticker
- (void)titleListVC:(NvTitleListViewController *)vc stickerAddWithAssetCellModel:(NvAssetCellModel * _Nullable)model;
- (void)titleListVC:(NvTitleListViewController * _Nullable)vc stickerAddWithBaseModel:(NvBaseModel * _Nullable)model;
- (void)titleListVC:(NvTitleListViewController *)vc stickerAddCusstom:(NvAssetCellModel * _Nullable)model;

@end

@interface NvTitleListViewController : NvBaseViewController

@property (nonatomic, weak) id<NvTitleListViewControllerDelegate>delegate;

/// 素材类型 Material type
@property (nonatomic, assign) AssetType type;

/// 取消搜索第一响应者 Cancel search for first responder
- (void)cancelSearchResponder;

/// 根据uuid选中素材 Select the material based on uuid
/// @param uuid 素材的uuid The uuid of the material
- (void)selecteMaterial:(NSString *)uuid;

/// 将指定素材与指定index地方的素材交换 Swap the specified story with the story at the specified index place
- (void)changeAsset:(NSString *)uuid withDestinationIndex:(NSInteger)index;

/// view视图显示和隐藏 view Displays or hides the view
/// @param show 是否显示 Show or not
- (void)viewAppearOrDisappear:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
