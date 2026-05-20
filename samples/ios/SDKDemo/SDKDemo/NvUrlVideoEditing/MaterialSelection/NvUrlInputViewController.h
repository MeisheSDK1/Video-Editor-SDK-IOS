//
//  NvUrlInputViewController.h
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/3.
//  Copyright © 2024 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import <JXCategoryView/JXCategoryView.h>
NS_ASSUME_NONNULL_BEGIN

@protocol NvUrlInputViewControllerDelegate <NSObject>
@optional

- (void)changeInputData;

- (void)hideEdit;

- (void)musicInputImport;

@end

@interface NvUrlInputViewController : NvBaseViewController <JXCategoryListContentViewDelegate>

@property (nonatomic, weak) id<NvUrlInputViewControllerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) float trimIn;

@property (nonatomic, assign) float trimOut;

@property (nonatomic, assign) BOOL isMusicEdit;

- (void)removeSelect;

- (BOOL)hideControl;

@end

NS_ASSUME_NONNULL_END
