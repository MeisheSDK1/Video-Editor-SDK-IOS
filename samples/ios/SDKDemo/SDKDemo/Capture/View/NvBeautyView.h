//
//  NvBeautyView.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvSwitchView.h"
#import "NvBeautyTypeCViewCell.h"
#import "NvsMakeupEffectInfo.h"
#import "NvCaptureModularVM.h"
#import "NvMakeupToolModel.h"

@class NvBeautyView;
@class NvMakeupEffectModel;

/// 美型分类
typedef NS_ENUM(NSUInteger, NvBeautyType) {
    NvBeautyTypeSum,         ///< 整体美型 Overall beauty form
    NvBeautyTypeFirst,       ///< 美型1 Beauty type 1
    NvBeautyTypeSecond,      ///< 美型2 Beauty type 2
};

@protocol NvBeautyViewDelegate <NSObject>
@optional

/**
 选择或调节一个美颜、美型特效回调
 Select or adjust a beauty, beauty effect callback
 
 @param beautyView 当前NvBeautyView对象，self Current NvBeautyView object, self
 @param model 当前美颜、美型数据model Current beauty, beauty data model
 @param state 为true表示要记录数据，为false表示滑杆拖动中中，拖动结束再记录数据，如果只是一个开关，美颜滑杆，传true
             "true" means to record data, "false" means slider in the drag, drag the end of the record data, if only a switch, beautiful slider, pass true
 */
- (void)nvBeautyView:(NvBeautyView *)beautyView withModel:(NvBeautyTypeModel *)model withState:(BOOL)state;

/**
选择美型类别（策略）
Select the Beauty Category (Policy)

@param beautyView 当前NvBeautyView对象，self Current NvBeautyView object, self
@param type 当前美型策略 Current beauty strategy
*/
- (void)nvBeautyView:(NvBeautyView *)beautyView sumBeautyType:(NSInteger)type;

/**
 美型重置按钮点击的回调
 Beauty Reset button click on the callback

 @param beautyView 当前NvBeautyView对象，self Current NvBeautyView object, self
 @param array 回调的美型数据，一个NvBeautyTypeModel的数组 Callback beauty data, an array of NvBeautyTypeModel
 @param category 类型 type
 @param isCompare 是否是正在对比 Is it being compared?
 */
- (void)nvBeautyView:(NvBeautyView *)beautyView withModelArray:(NSMutableArray *)array withCategory:(NvBeautyViewCategory)category isCompare:(BOOL)isCompare;


/**
 切换轻颜美白\美白状态
 Toggle whitening/whitening status

 @param beautyView 当前NvBeautyView对象，self Current NvBeautyView object, self
 @param isLutWhiten 是否是模式B（轻颜美白） Is it Mode B (Light and whitening)?
 */
- (void)nvBeautyview:(NvBeautyView *)beautyView lutWhiten:(BOOL)isLutWhiten isBeauty:(BOOL)isBeauty;

/**
应用美妆效果
Apply beauty effects

@param beautyView 当前NvBeautyView对象，self Current NvBeautyView object, self
@param effectModel 美妆model Beauty makeup model
*/
- (void)nvBeautyview:(NvBeautyView *)beautyView applyMakeupEffect:(NvsMakeupEffectInfo *)effectModel withCustom:(BOOL)isCustom withReset:(BOOL)reset;

/**
应用美妆（组合妆容）中滤镜效果
Apply the filter effect in makeup (combination makeup)

@param beautyView 当前NvBeautyView对象，self Current NvBeautyView object, self
@param effectModel 美妆model Beauty makeup model
*/
- (void)nvBeautyview:(NvBeautyView *)beautyView applyMakeupFilterEffect:(NvMakeupEffectModel *)effectModel;

/// 应用风格 Application style
/// @param beautyView 当前NvBeautyView对象，self Current NvBeautyView object, self
/// @param styleModel
- (void)nvBeautyview:(NvBeautyView *)beautyView applyEffectsStyle:(NvEffectsStyleModel *)styleModel;

/**
切换美颜/美妆/美型 代理方法
Switch beauty/makeup/beauty agent method
 
@param beautyView 当前NvBeautyView对象，self Current NvBeautyView object, self
@param mode 美妆model Beauty makeup model
*/
- (void)nvBeautyview:(NvBeautyView *)beautyView changeMode:(NvBeautyViewCategory)mode;

/**
该特效数据在已应用整妆中被限定为不可修改
 This effect data is restricted to unmodifiable in applied makeup
 
@param beautyView 当前NvBeautyView对象，self Current NvBeautyView object, self
@param mode 美妆model Beauty makeup model
*/
- (void)nvBeautyview:(NvBeautyView *)beautyView forbiddenReplaceEffect:(NvBeautyTypeModel *)model;

@end

@interface NvBeautyView : UIView

@property (nonatomic, strong) NvCaptureModularVM *captureVM;

/// 美颜点击按钮——切换当前显示视图为美颜  Meiyan click the button to switch the current display view to Meiyan
@property (nonatomic, strong) UIButton *beautyBtn;

/// 美型点击按钮——切换当前显示视图为美型 Meixing click the button to switch the current display view to Meixing
@property (nonatomic, strong) UIButton *beautyTypeBtn;

/// 微整形点击按钮——切换当前显示视图为微整形 Meixing click the button to switch the current display view to Meixing
@property (nonatomic, strong) UIButton *microShapingTypeBtn;

/// 调节点击按钮——切换当前显示视图为调节
/// Adjust Click the button -- Toggle the current display view to Adjust
@property (nonatomic, strong) UIButton *adjustBtn;

/// 修容点击按钮——切换当前显示视图为修容
/// Click the button to change the current display view to a Contouring
@property (nonatomic, strong) UIButton *contouringBtn;

/// 当前美化类型  Current beautification type
@property (nonatomic, assign) NvBeautyViewCategory viewCategory;

/// 当前美型类型  Current American type
@property (nonatomic, assign) NvBeautyType currentBeautyType;

@property (nonatomic, assign) BOOL styleFlag;

@property (nonatomic, strong) NvMakeupEffectModel *currentVariableMakeup;

@property (nonatomic, strong) NvMakeupToolModel *currentMakeupVariableModel;

/// 是否禁用美型及微整形中美型特效   Whether to disable beauty and micro shaping beauty effects
@property (nonatomic, assign) BOOL forbiddenBeautyType;

/**
 配置美颜数据
 Configure beauty data
 
 @param array 一个NvBeautyTypeModel的数组
 An array of NvBeautyTypeModel
 */
- (void)configBeautyArray:(NSMutableArray*)array;

- (void)configBeautyByteArray:(NSMutableArray*)array;

- (void)configMicroShapingArray:(NSMutableArray *)array;

- (void)configAdjustArray:(NSMutableArray *)array;

- (void)configContouringArray:(NSMutableArray *)array;

- (void)configBeautyTemplateArray:(NSMutableArray *)array;

- (void)forbiddenBeautyTypeInMicroShapingView:(BOOL)forbidden;

/// 替换道具（不含美型）后重置美型和微整形中的美型数据 Reset Beauty stats in Beauty and Microshaping after replacing items (excluding Beauty stats)
- (void)resetBeautyTypeAfterProps;

/// 将所有特效重置
/// reset all fx to default value
- (void)resetAll;

- (UICollectionView *)getBeautyTemplateCollectionView;

/// 获取展示的美颜模版数量
///  get the count of beauty template in view
- (int)getBeautyTemplateCount;

@end
