//
//  NvPropsView.h
//  SDKDemo
//
//  Created by MS on 2020/7/25.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvBaseModel.h"
NS_ASSUME_NONNULL_BEGIN
@class NvPropsView;
@protocol NvPropsViewDelegate <NSObject>
@optional

/**
 UICollectionView点击回调
 UICollectionView click callback

 @param view 当前对象 Current object
 @param model 当前model对象 Current model object
 */
- (void)NvPropsView:(NvPropsView *)view withFilterModel:(NvBaseModel *)model;

/**
 更多点击回调
 More click callbacks
 
 @param view 当前对象 当前对象 Current object
 @param sender 更多按钮 More buttons
 */
- (void)NvPropsView:(NvPropsView *)view  moreClick:(UIButton *)sender;

@end
@interface NvPropsView : UIView

/// 代理 delegate
@property (nonatomic, assign) id<NvPropsViewDelegate>delegate;

/// 配置数组
/// Configuration array
/// @param array 数据源 data source
- (void)configDataSource:(NSMutableArray <NvBaseModel *>*)array;

@end

NS_ASSUME_NONNULL_END
