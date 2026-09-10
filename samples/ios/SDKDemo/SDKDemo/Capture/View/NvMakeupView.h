//
//  NvMakeupView.h
//  SDKDemo
//
//  Created by MS on 2020/7/16.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsMakeupEffectInfo.h"
#import "NvMakeupModel.h"
NS_ASSUME_NONNULL_BEGIN
@class NvMakeupView;

@protocol NvMakeupViewDelegate <NSObject>
@optional

- (void)nvMakeupView:(NvMakeupView *)makeupView applyMakeupPackage:(NvMakeupEffectModel *)effectModel withCustom:(BOOL)isCustom withReset:(BOOL)reset;

/**
 应用美妆效果
 Apply beauty effect
 
 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param effectModel 美妆model  makeup model
*/
- (void)nvMakeupView:(NvMakeupView *)makeupView applyMakeupEffect:(NvsMakeupEffectInfo *)effectModel withCustom:(BOOL)isCustom withReset:(BOOL)reset;

/**
 应用美妆（组合妆容）中滤镜效果
 Apply the filter effect in the beauty (combination makeup)
 
 @param makeupView 当前NvMakeupViewDelegate 对象，self
 @param effectModel 美妆model  makeup model
*/
- (void)nvMakeupView:(NvMakeupView *)makeupView applyMakeupFilterEffect:(NvMakeupEffectModel *)effectModel;

/**
 应用美妆（组合妆容）中美颜效果
 Apply the beauty effect in the makeup (combination makeup)

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param effectModel 美妆model  makeup model
*/
- (void)nvMakeupView:(NvMakeupView *)makeupView applyMakeupBeautyEffect:(NvMakeupEffectModel *)effectModel;

/**
 应用美妆（组合妆容）中美型效果
 Apply the beauty effect in the beauty type (combination makeup)

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param effectModel 美妆model  makeup model
*/
- (void)nvMakeupView:(NvMakeupView *)makeupView applyMakeupBeautyTypeEffect:(NvMakeupEffectModel *)effectModel;

/**
 应用美妆（组合妆容）中微整型效果
 Apply the microShape effect in the beauty type (combination makeup)

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param effectModel 美妆model  makeup model
*/
- (void)nvMakeupView:(NvMakeupView *)makeupView applyMakeupMicroShapeEffect:(NvMakeupEffectModel *)effectModel;

/**
 应用组合妆容
 Apply the variable makeup effects

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param path 妆容路径 Makeup path
*/
- (void)nvMakeupView:(NvMakeupView *)makeupView applyVariableMakeupEffect:(NSString *)path;

/**
 应用单妆
 Apply the single makeup effects

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param effectModel 美妆model  makeup model
*/
- (void)nvMakeupView:(NvMakeupView *)makeupView applySingleKindMakeupEffect:(NvMakeupEffectModel *)effectModel;

/**
 该单妆在已应用妆容中被限定为不可修改
 This single makeup is limited to be non modifiable(replaceable) in the applied variable makeup effects
 
 @param makeupView 当前NvMakeupViewDelegate 对象
 @param effectModel 单妆model  makeup model
*/
- (void)nvMakeupView:(NvMakeupView *)makeupView forbiddenReplaceMakeupEffect:(NvMakeupEffectModel *)makeupModel;

/**
 调节组合妆容的整体效果值，只调整美妆相关效果值，滤镜、美颜、美型不做修改
 Adjust the overall effect value of the combination makeup，Only adjust the beauty related effect values, filters, beauty, beauty type do not change

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param value value
 @param filter 是否是修改滤镜
 Whether to modify the filter
*/
- (void)nvMakeupView:(NvMakeupView *)makeupView changeVariableMakeup:(CGFloat)value with:(BOOL)filter;


@end

@interface NvMakeupView : UIView

/// 代理 delegate
@property (nonatomic, weak) id<NvMakeupViewDelegate>delegate;

- (NSMutableArray *)getKindArr;

- (void)hiddenMakeupSlider;

- (void)showMakeupSliderInCondition;

// 获取选中的单妆数据
// get the selected single makeup data array
- (NSArray <NvMakeupContentModel *>*)getSelectedSingleElements;
@end

NS_ASSUME_NONNULL_END
