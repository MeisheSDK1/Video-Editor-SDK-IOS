//
//  NvEditMakeUpView.h
//  SDKDemo
//
//  Created by ms on 2021/12/1.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsMakeupEffectInfo.h"
#import "NvMakeupModel.h"
#import "NvMakeupToolModel.h"

NS_ASSUME_NONNULL_BEGIN
@class NvEditMakeUpView;
typedef NS_ENUM(NSInteger,NvEditMakeUpFunction) {
    NvEditMakeUpFunctionCapture, //拍摄
    NvEditMakeUpFunctionEdit, // 编辑
};

@protocol NvEditMakeUpViewDelegate <NSObject>
@optional

- (void)nvEditMakeUpView:(NvEditMakeUpView *)makeupView applyMakeupPackage:(NvMakeupEffectModel *)effectModel withCustom:(BOOL)isCustom withReset:(BOOL)reset;

/**
 应用美妆效果
 Apply beauty effect
 
 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param effectModel 美妆model  makeup model
*/
- (void)nvEditMakeUpView:(NvEditMakeUpView *)makeupView applyMakeupEffect:(NvsMakeupEffectInfo *)effectModel withCustom:(BOOL)isCustom withReset:(BOOL)reset;

/**
 应用美妆（组合妆容）中滤镜效果
 Apply the filter effect in the beauty (combination makeup)
 
 @param makeupView 当前NvMakeupViewDelegate 对象，self
 @param effectModel 美妆model  makeup model
*/
- (void)nvEditMakeUpView:(NvEditMakeUpView *)makeupView applyMakeupFilterEffect:(NvMakeupEffectModel *)effectModel;

/**
 应用美妆（组合妆容）中美颜效果
 Apply the beauty effect in the makeup (combination makeup)

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param effectModel 美妆model  makeup model
*/
- (void)nvEditMakeUpView:(NvEditMakeUpView *)makeupView applyMakeupBeautyEffect:(NvMakeupEffectModel *)effectModel;

/**
 应用美妆（组合妆容）中美型效果
 Apply the beauty effect in the beauty type (combination makeup)

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param effectModel 美妆model  makeup model
*/
- (void)nvEditMakeUpView:(NvEditMakeUpView *)makeupView applyMakeupBeautyTypeEffect:(NvMakeupEffectModel *)effectModel;

/**
 应用美妆（组合妆容）中微整型效果
 Apply the microShape effect in the beauty type (combination makeup)

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param effectModel 美妆model  makeup model
*/
- (void)nvEditMakeUpView:(NvEditMakeUpView *)makeupView applyMakeupMicroShapeEffect:(NvMakeupEffectModel *)effectModel;

/**
 应用组合妆容
 Apply the variable makeup effects

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param path 妆容路径
*/
- (void)nvEditMakeUpView:(NvEditMakeUpView *)makeupView applyVariableMakeupEffect:(NSString *)path;

/**
 应用单妆
 Apply the single makeup effects

 @param makeupView 当前NvMakeupViewDelegate 对象，self  The current NvMakeupViewDelegate object, self
 @param effectModel 美妆model  makeup model
*/
- (void)nvEditMakeUpView:(NvEditMakeUpView *)makeupView applySingleKindMakeupEffect:(NvMakeupEffectModel *)effectModel;

/**
 该单妆在已应用妆容中被限定为不可修改
 This single makeup is limited to be non modifiable(replaceable) in the applied variable makeup effects
 
 @param makeupView 当前NvMakeupViewDelegate 对象
 @param effectModel 单妆model  makeup model
*/
- (void)nvEditMakeUpView:(NvEditMakeUpView *)makeupView forbiddenReplaceMakeupEffect:(NvMakeupEffectModel *)makeupModel;

/// 获取最新应用的妆容总数据
/// Get total makeup data for the latest application
/// @param makeupView self
- (NvMakeupToolModel *)nvEditMakeUpViewGetCurrentMakeupTotalModel:(NvEditMakeUpView *)makeupView;

@end
@interface NvEditMakeUpView : UIView

/// 代理 delegate
@property (nonatomic, weak) id<NvEditMakeUpViewDelegate>delegate;

-(instancetype)initWithFunctionUse:(NvEditMakeUpFunction)functionUse Frame:(CGRect)frame;

- (NSMutableArray *)getKindArr;

@end

NS_ASSUME_NONNULL_END
