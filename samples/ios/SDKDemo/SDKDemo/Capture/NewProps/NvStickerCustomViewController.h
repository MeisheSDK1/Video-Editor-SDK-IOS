//
//  NvStickerCustomViewController.h
//  SDKDemo
//
//  Created by 李勇 on 2022/3/28.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <JXPagingView/JXPagerView.h>
#import <JXCategoryView/JXCategoryView.h>
#import <NvSDKCommon/NvAssetManager.h>
#import <NvSDKCommon/NvHttpRequest.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvBaseViewController.h"
#import "NvAssetCellModel.h"

NS_ASSUME_NONNULL_BEGIN
@class NvStickerCustomViewController;

@protocol NvStickerCustomViewControllerDelegate <NSObject>

- (void)NvStickerCustomViewControllerDelegateAddCusstomSticker:(NvStickerCustomViewController *)vc;
- (void)NvStickerCustomViewControllerDelegateAddSticker:(NvStickerCustomViewController *)vc assetCellModel:(NvAssetCellModel*)model;

@end

@interface NvStickerCustomViewController : NvBaseViewController<JXCategoryListContentViewDelegate>
@property(nonatomic,weak)id<NvStickerCustomViewControllerDelegate> delegate;
- (void)UncheckStatus;
@end

NS_ASSUME_NONNULL_END
