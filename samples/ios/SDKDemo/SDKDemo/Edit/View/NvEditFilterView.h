//
//  NvEditFilterView.h
//  SDKDemo
//
//  Created by MS on 2020/6/8.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvFilterView.h"
#import "NvFilterSegTitleView.h"

NS_ASSUME_NONNULL_BEGIN
@class NvEditFilterView;
@protocol NvEditFilterViewDelegate <NSObject>
@optional
- (void)NvEditFilterViewAddKeyFrameView:(NvEditFilterView *)view;
- (void)NvEditFilterView:(NvEditFilterView *)view withFilterModel:(NvBaseModel *)model;
- (void)NvEditFilterView:(NvEditFilterView *)view sliderValueChanged:(UISlider *)slider;
- (void)NvEditFilterView:(NvEditFilterView *)view moreClick:(UIButton *)sender;
@end

@interface NvEditFilterView : UIView
@property (nonatomic, assign) AssetType type;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UISlider *strengthSlider;
@property (nonatomic, strong) NvFilterSegTitleView* segView;
@property (nonatomic, strong) UILabel *strengthLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) CGFloat bottomTotalHeitht;

///关键帧界面
///Keyframe interface
@property (nonatomic, strong) UIView *keyFrameView;

///当前滤镜是否存在关键帧
///current filter contain keyframe or not
@property (nonatomic, assign) BOOL hasKeyframes;

@property(nonatomic,weak) id<NvEditFilterViewDelegate> viewDelegate;
@property(nonatomic,strong) id<NvFilterViewDelegate> dataSource;

+(instancetype)filterViewWithAspectRatio:(AspectRatio)ratio delegate:(id<NvEditFilterViewDelegate>)delegate;

///子类覆盖实现
///Subclass coverage implementation
- (void)addSubviews:(CGRect)rect HaveTopView:(BOOL)haveTop WithTopViewHeight:(CGFloat)heightTop withMore:(BOOL)have withlayout:(UICollectionViewFlowLayout *_Nullable)layout;

/**
 配置数据源,并且刷新视图
 config the datasource and refresh this view
 @param array 数据源
 Data source
 */
- (void)configDataSource:(NSMutableArray *)array;

/**
 更新数据源，不刷新视图
 update datasource of this view
 @param array 数据源
 Data source
 */
- (void)updateDataSource:(NSMutableArray *)array;

/**
 刷新视图
 reload datasource
 */
- (void)reloadDataSource;

/**
 配置Slider默认值,并且显示控件
 Set the Slider default and display the control
 @param value 滤镜强度
 value the strength value of filter
 @param hidden 滤镜滑杆控件是否隐藏
 hidden set the slider state as hidden or not
 */
- (void)configSliderValue:(CGFloat)value withHidden:(BOOL)hidden;

/**
 设置背景颜色
 set the background color of this view
 @param color 视图背景颜色
 View background color
 */
- (void)backColor:(UIColor *)color;

-(void)reloadData;

-(void)updateSelectedModelWithModel:(id)model;

-(void)reloadDataWithSelectedModel:(id)model;

-(void)refreshSelectedModel:(id)model ;

-(void)replaceTopViewAndSetupSegmentView;
@end
NS_ASSUME_NONNULL_END
