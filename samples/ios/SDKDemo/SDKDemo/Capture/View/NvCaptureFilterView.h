//
//  NvCaptureFilterView.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvBaseModel.h"
#import <NvSDKCommon/NvAsset.h>

@class NvCaptureFilterView;
@protocol NvCaptureFilterViewDelegate <NSObject>
@optional

/**
 选中点击回调
 Select click callback
 
 @param view 当前对象 Current object
 @param model 当前model对象 Current model object
 */
- (void)NvCaptureFilterView:(NvCaptureFilterView *)view withFilterModel:(NvBaseModel *)model;

/**
 滤镜强度调节回调
 Filter intensity adjustment callback

 @param view 当前对象 Current object
 @param slider 当前调节杆 Current UISlider
 */
- (void)NvCaptureFilterView:(NvCaptureFilterView *)view sliderValueChanged:(UISlider *)slider;

/**
 更多点击回调
 More click callbacks

 @param view 当前对象 Current object
 @param sender 更多按钮 More buttons
 */
- (void)NvCaptureFilterView:(NvCaptureFilterView *)view  moreClick:(UIButton *)sender;

@end

@interface NvCaptureFilterView : UIView

/// 代理 delegate
@property (nonatomic, weak) id<NvCaptureFilterViewDelegate> delegate;

/// 素材分类 Material classification
@property (nonatomic, assign) AssetType type;

/// 上半部分视图 Top view
@property (nonatomic, strong) UIView *topView;

/// 下半部分视图 Lower part view
@property (nonatomic, strong) UIView *bottomView;

/// 数据源 data source
@property (nonatomic, strong) NSMutableArray *dataArray;

/// 滤镜强度滑杆 Filter strength slider
@property (nonatomic, strong) UISlider *strengthSlider;

/// 滤镜强度label Filter strength label
@property (nonatomic, strong) UILabel *strengthLabel;

/// 滤镜视图 Filter view
@property (nonatomic, strong) UICollectionView *collectionView;

/**
 初始化
 initialization

 @param frame 视图的frame 如果有头视图，头视图的高度要一起算进去
 If the frame of the view has a header view, the height of the header view should be included together
 
 @param haveTop 是否有头视图 Whether there is a header view
 @param heightTop 头视图的高度 Height of head view
 @param have 是否有更多按钮 If there are more buttons
 @param layout 如果需要自定UICollectionViewLayout，自己写一个传进来，如果不需要，传空，它会默认创建一个layout，默认创建的layout适用于滤镜、道具、主题等滚动式图
 If you need to customize the UICollectionViewLayout, write one and pass it in. If you don’t need it, pass it blank and it will create a layout by default. The layout created by default is suitable for scrolling images such as filters, props, and themes.
 
 @return 返回当前视图对象 Returns the current view object
 */
- (instancetype)initWithFrame:(CGRect)frame HaveTopView:(BOOL)haveTop WithTopViewHeight:(CGFloat)heightTop withMore:(BOOL)have withlayout:(UICollectionViewFlowLayout *)layout;

/**
 子类覆盖实现，创建视图
 Subclass override implementation, create view

 @param frame 视图的frame 如果有头视图，头视图的高度要一起算进去
 If the frame of the view has a header view, the height of the header view should be included together
 
 @param haveTop 是否有头视图 Whether there is a header view
 @param heightTop 头视图的高度 Height of head view
 @param have 是否有更多按钮 If there are more buttons
 @param layout 如果需要自定UICollectionViewLayout，自己写一个传进来，如果不需要，传空，它会默认创建一个layout，默认创建的layout适用于滤镜、道具、主题等滚动式图
 If you need to customize the UICollectionViewLayout, write one and pass it in. If you don’t need it, pass it blank and it will create a layout by default. The layout created by default is suitable for scrolling images such as filters, props, and themes.
 
 @return 返回当前视图对象 Returns the current view object
 */
- (void)addSubviews:(CGRect)rect HaveTopView:(BOOL)haveTop WithTopViewHeight:(CGFloat)heightTop withMore:(BOOL)have withlayout:(UICollectionViewFlowLayout *)layout;

/**
 配置数据源,并且刷新视图
 Configure the data source and refresh the view
 
 @param array 数据源 data source
 */
- (void)configDataSource:(NSMutableArray *)array;

/**
 更新数据源，不刷新视图
 Update the data source without refreshing the view
 
 @param array 数据源 data source
 */
- (void)updateDataSource:(NSMutableArray *)array;

/**
 刷新视图
 Refresh view
 */
- (void)reloadDataSource;

/**
 配置Slider默认值,并且显示控件
 Configure Slider default values and display controls
 
 @param value 滤镜强度 Filter strength
 @param hidden 滤镜滑杆控件时候显示，yes显示，no不显示 Display when the filter slider control is displayed, yes displays, no does not display
 */
- (void)configSliderValue:(CGFloat)value withHidden:(BOOL)hidden;

/**
 设置背景颜色
 Set background color

 @param color 视图背景颜色 View background color
 */
- (void)backColor:(UIColor *)color;

@end

