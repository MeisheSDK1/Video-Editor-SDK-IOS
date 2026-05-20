//
//  NvCaptureModularVM.h
//  SDKDemo
//
//  Created by Meishe on 2022/8/10.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NvBaseModel;
@class NvAssetManager;
@class NvBeautyView;
@class NvSwitchView;
@class NvBeautyTypeModel;
@class NvBeautyTemplateModel;
@class NvEffectsStyleModel;
@class NvCaptureFilterModel;
@class NvAjustFxParamModel;
@class NvMakeupToolManager;

NS_ASSUME_NONNULL_BEGIN

/// 美化分类 Beautification classification
typedef NS_ENUM(NSUInteger, NvBeautyViewCategory) {
    NvBeautyCategory,          ///< 美颜 beauty
    NvBeautyTypeCategory,      ///< 美型 Beauty type
    NvBeautyMakeupCategory,    ///< 美妆 Beauty makeup
    NvMicroShapingCategory,    ///< 微整形 microshaping
    NvBeautyAdjustCategory,    ///< 调节 adjust
    NvBeautyShadowCategory,    ///< 修容 Shadow
    NvBeautyBeautyTemplate,    ///< 美颜模版 BeautyTemplate
};

typedef NS_ENUM(NSInteger, NvAudioInterruptionState) {
    NvAudioInterruptionStateNone,
    NvAudioInterruptionStateAffecting,
};

@protocol NvCaptureModularVMUIDelegate <NSObject>

@optional
@property (nonatomic, strong) NvBeautyView *beautyView;
// 是否是设置的第一个高级磨皮
// Is it the first advanced dermabrasion set
@property (nonatomic, assign) BOOL isFirstAdvancedBeautyType;

/**
 显示校色相关提示信息
 The color correction information is displayed
 
 @param open 是否开启校色 Whether to enable color verification
 */
- (void)showColorCorrectTips:(BOOL)open;

/**
 显示锐度相关提示信息
 The sharpness-related information is displayed
 
 @param open 是否开启锐度 Whether to enable sharpness
 */
- (void)showSharpenTips:(BOOL)open;

/**
 应用美妆特效情况下涉及不可以替换特效的提示信息
 A message that involves not substituting effects when applying beauty effects
 
 */
- (void)showUnReplaceableEffectTips;

/**
 当前sdk 不支持人脸提示
 The current sdk does not support face prompts
 */
- (void)showNoARScenePermissionAlert;

/**
 应用道具特效包含美型情况下涉及不可以人为应用美型的提示信息
 The application of prop effects includes a reminder that beauty should not be applied artificially
 */
- (void)showForbiddenBeautyTypeEffectTips;

/**
 根据选中滤镜特效模型来刷新美颜界面中涉及到的滤镜界面元素
 Refresh the filter interface elements involved in the beauty interface according to the selected filter effect model
 
 @param model 选中的滤镜模型 Selected filter model
 */
- (void)updateFilterElementsInBeautyView:(NvCaptureFilterModel *)model;

/**
 根据选中滤镜特效模型来刷新滤镜界面
 Refresh the filter interface by selecting the filter effect model
 
 @param model 选中的滤镜模型 Selected filter model
 @param needReplace 是否要交换元素位置 Whether to swap element positions
 @param destinationIndex 目标位置索引 Target location index
 */
- (void)updateFilterView:(NvEffectsStyleModel *)model needReplaceElements:(BOOL)needReplace destinationIndex:(NSInteger)destinationIndex;


/**
  在低端机上应用的美颜模版包中包含了GAN 美颜, 提示可能引发的性能问题
  Toast warning infos due the beauty template package applied on low-performance IPhone includes GAN beauty effect, which may cause potential performance issues
 */
- (void)showAdvacedBeautyThreeOverWeightNegativeToast;
@end

@interface NvCaptureModularVM : NSObject

@property (nonatomic, assign) id<NvCaptureModularVMUIDelegate> uiDelegate;
//素材管理类
// Material management class
@property (nonatomic, strong) NvAssetManager *assetManager;
//人脸特效
// Facial effects
@property (nonatomic, strong, nullable) NvsCaptureVideoFx *fxARFace;
//滤镜特效
// Filter effect
@property (nonatomic, strong, nullable) NvsCaptureVideoFx *fxFilter;
//是否包含人脸
// Whether a face is included
@property (nonatomic, assign) BOOL isContentAI;
//当前选中model(美颜、美型、微整形)
// Currently select model(Beauty, Beauty, Micro-plastic)
@property (nonatomic, strong) NvBeautyTypeModel *currentSelectedBeautyModel;
//当前滤镜
// Current filter
@property (nonatomic, strong) NvCaptureFilterModel *currentFilterModel;
//字体
// Font
@property (nonatomic, strong) NSMutableArray *fontDataSource;

@property (nonatomic, strong, nullable) NvBeautyTemplateModel *currentTemplatemodel;

/// 当前数据
/// Current data
@property (nonatomic, strong) NSMutableArray *beautyFxArray;
@property (nonatomic, strong) NSMutableArray *shapeFxArray;
@property (nonatomic, strong) NSMutableArray *microShapingFxArray;
@property (nonatomic, strong) NSMutableArray *adjustArray;
@property (nonatomic, strong) NSMutableArray *contouringArray;

/// 原始数据
/// source data
@property (nonatomic, strong) NSMutableArray *originalBeautyFxArray;
@property (nonatomic, strong) NSMutableArray *originalShapeFxArray;
@property (nonatomic, strong) NSMutableArray *originalMicroShapingFxArray;
@property (nonatomic, strong) NSMutableArray *originalAdjustArray;
@property (nonatomic, strong) NSMutableArray *originalContouringArray;

/// 美妆管理对象
/// Beauty makeup Manager object
@property (nonatomic, strong) NvMakeupToolManager *makeupManager;

/*
 初始化人脸授权
 Initialize face authorization
 */
- (void)initARFace;

/*
 加载滤镜和道具包
 Loading filters and props
 */
- (void)installFilterAndPropsAsset;

/*
 获取内置字体数据
 get font data embedded in project
 */
- (void)getFontDatas;

/*
 配置美肤数据
 set the beauty data
 */
- (void)configBeautifulSkinParameter;

/*
 重新设置美型默认值
 Reset the default value of beautyShape model
 */
- (void)setBeautyTypeDefaultValues;

/*
 配置微整形数据
 Reset the default value of microShaping model
 */
- (void)configMicroShapingTypeParameter;

/// 配置调节数据
/// Configuration adjustment data
- (void)configAdjustArray;

/// 配置修容数据
/// Configure capacity modification data
- (void)configContouringArray;

/// 配置美颜模版数据
/// Configure Beauty template data
- (void)configBeautyTemplateArray;

- (void)applyBeautyModel:(NvBeautyTypeModel *)model withChange:(BOOL)change;

- (void)resetBeautyTemplateData;

- (void)discardCurrentEffect:(BOOL)discard;

/**
 该特效数据在已应用整妆中被限定为不可修改
 This effect data is restricted to unmodifiable in applied makeup
 */
- (void)applyBeautyWithForbiddenReplaceEffect:(NvBeautyTypeModel *_Nullable)model;

/**
 已应用道具中包含美型，所有美型不准再被使用
 Applied items contain beauty shapes. All beauty shapes can no longer be used
 */
- (void)forbiddenApplyBeautyTypeEffectWithProps:(NvBeautyTypeModel *_Nullable)model;

/**
 是否开启人脸特效应用
 Whether to open the face effects application
 
 @param open 是否开启默认效果
 Whether to enable the default effect
 */
- (void)applyBeautyEffectsStyleWith:(BOOL)open;

/// 应用美颜模版数据
/// Apply the beauty template data
- (void)applyBeautyTemplateData;

/// 当应用妆容的时候，调用这个接口，内部根据再次之前应用的美颜模版基础上，再加妆容
/// When applying makeup, call this interface and internally add makeup based on the beauty template applied again
/// - Parameter isBeautyTemplate: 是否是要替换美颜模版
/// Whether to replace the beauty template
- (void)applyMakeupAndBeautyTemplate:(BOOL)isBeautyTemplate;

/**
 弹框显示该特效无授权
 The box shows that the effect is not authorized
 
 */
- (void)applyBeautyWithNoPermissionAlert;

/**
 应用滤镜特效
 Apply filter effects
 
 @param model 滤镜模型数据
 */
- (void)applyFilter:(NvBaseModel *_Nullable)model;

/**
 应用默认滤镜特效
 Apply the default filter effect
 
 */
- (void)applyDefaultFilter;

/**
 素材是否包含可调节表达式
 Whether the material contains tunable expressions
 
 */
- (BOOL)containExpParam:(NvBaseModel *)model;

/**
 设置滤镜可调节表达式参数
 Set filter adjustable expression parameters
 
 */
- (void)setFilterExpValue:(NSArray <NvAjustFxParamModel *> *)models;

/**
 重新应用滤镜，并设置滤镜可调节表达式参数
 Reapply the filter and set the Filter adjustable expression parameters
 
 */
- (void)applyFilterAndSetExpValue:(NSArray <NvAjustFxParamModel *> *)models;

/*
 美颜和美型开启、关闭换事件处理
 Event handling of Meiyan and Meixing switching on and off
 
 @param sender 
 Switch control
 */
- (void)switchAction:(NvSwitchView* )sender;

@end

NS_ASSUME_NONNULL_END
