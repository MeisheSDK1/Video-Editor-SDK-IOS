//
//  NvFilterView.h
//  SDKDemo
//
//  Created by 美摄 on 2019/8/29.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvCaptureFilterView.h"
#import "NvFilterSegTitleView.h"
NS_ASSUME_NONNULL_BEGIN

@protocol NvFilterViewDelegate <NSObject>
@optional

/// 刷新视图
/// refresh the view
-(void)reloadData;

/// 返回当前的数组的元素个数
/// Returns the number of elements in the current array
- (NSInteger)numberOfSections;

/// 返回滤镜标签数组
/// Returns an array of filter tags
-(NSArray*)titlesForSections;

/// 更新选中的滤镜模型
/// Update the selected filter model
/// @param model 滤镜模型数据     Filter model data
-(void)updateSelectedModelWithModel:(NvBaseModel*)model;

/// 返回数组中滤镜的个数
/// Returns the number of filters in the array
/// @param section 标签下标    Label subscript
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

/// 根据下标获取当前模型
/// Get the current model according to the subscript
/// @param indexPath 标签下标    Label subscript
-(NvBaseModel*)modelForIndexPath:(NSIndexPath *)indexPath;

/// 当前选中的下标
/// Currently selected subscript
/// @param indexPath 选中的下标 Selected subscript
-(void)didselectModelAtIndexPath:(NSIndexPath *)indexPath;

/// 刷新当前选中的模型
/// Refresh the currently selected model
/// @param model 当前选中的模型  Currently selected model
-(void)refreshSelectedModel:(NvBaseModel *)model;
@end

@interface NvFilterView : NvCaptureFilterView

/// 初始化滤镜视图和数据
/// Initialize filter view and data
/// @param ratio 展示的比例  Proportion of display
/// @param delegate 代理  Delegate
+(instancetype)filterViewWithAspectRatio:(AspectRatio)ratio delegate:(nullable id<NvCaptureFilterViewDelegate>)delegate;

/// 初始化封面制作滤镜视图和数据
/// Initialize filter view and data
/// @param ratio 展示的比例  Proportion of display
/// @param delegate 代理  Delegate
+(instancetype)coverFilterViewWithAspectRatio:(AspectRatio)ratio delegate:(nullable id<NvCaptureFilterViewDelegate>)delegate;

/// 初始化滤镜视图和数据
/// Initialize filter view and data
/// @param dataSource 代理  Delegate
-(instancetype)initWithDataSource:(id<NvFilterViewDelegate>) dataSource;

/// 代理
/// Delegate
@property(nonatomic,strong)id<NvFilterViewDelegate> dataSource;

/// 标签视图
/// Label view
@property(nonatomic,strong)NvFilterSegTitleView* segView;

/// 刷新视图
/// refresh the view
-(void)reloadData;

/// 更新选中的滤镜模型
/// Update the selected filter model
/// @param model 滤镜模型数据     Filter model data
-(void)updateSelectedModelWithModel:(id)model;

/// 更新选中的滤镜模型
/// Update the selected filter model
/// @param model 滤镜模型数据     Filter model data
-(void)reloadDataWithSelectedModel:(id)model;

/// 设置默认滤镜模型
/// Set default filter model
/// @param model 滤镜模型数据     Filter model data
-(void)setDefaultSelectedModel:(NvBaseModel* _Nullable)model;
@end

NS_ASSUME_NONNULL_END
