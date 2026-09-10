//
//  NvUrlMaterialListViewController.h
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/3.
//  Copyright © 2024 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import <JXCategoryView/JXCategoryView.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NvUrlMaterialListViewControllerDelegate <NSObject>
@optional

- (void)changeSelectData;

- (void)musicImport;

@end

@interface NvUrlMaterialListViewController : NvBaseViewController<JXCategoryListContentViewDelegate>

@property (nonatomic, weak) id<NvUrlMaterialListViewControllerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *selectDataArray;

@property (nonatomic, assign) BOOL isMusicEdit;

@property (nonatomic, assign) float trimIn;

@property (nonatomic, assign) float trimOut;

- (void)removeSelect;

@end

NS_ASSUME_NONNULL_END
