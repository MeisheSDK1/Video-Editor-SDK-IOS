//
//  NvMakeupModel.h
//  SDKDemo
//
//  Created by MS on 2020/2/28.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>
#import "NvBaseModel.h"
NS_ASSUME_NONNULL_BEGIN
/// 美颜、美型都是这个model
/// Beauty, beauty type is this model
@class NvMakeupBeautyWhitenModel;
@class NvMakeupToolModel;

@interface NvBeautyTypeModel : NSObject<NSCopying,NSMutableCopying>
/// 判断这个model是否是美颜
/// Judge whether this model is beautiful or not
@property (nonatomic, assign) BOOL isBeauty;
@property (nonatomic, assign) NSUInteger type;
/// 外部显示中文文字
/// External display of Chinese text
@property (nonatomic, strong) NSString *name;
/// 外部显示英文文字
/// English text is displayed externally
@property (nonatomic, strong) NSString *nameEn;
/// 是否选中
/// Whether to check
@property (nonatomic, assign) BOOL selected;
/// 锐度、校色开关
/// Sharpness, color switch
@property (nonatomic, assign) BOOL switchSelected;
/// 效果程度
/// Degree of effect
@property (nonatomic, assign) float value;
/// 效果程度
/// 效果程度
@property (nonatomic, assign) float extValue;
/// 效果默认程度
/// Effect default degree
@property (nonatomic, assign) float defaultValue;
/// 效果默认程度
/// Effect default degree
@property (nonatomic, assign) float defaultExtValue;
/// 封面图片
/// Cover picture
@property (nonatomic, strong) NSString *coverImage;
/// 封面图片
/// Cover picture
@property (nonatomic, strong) NSString *selectedCoverImg;
/// 是否是开启了美型、美颜
/// Whether to open the beauty type, beauty
@property (nonatomic, assign) BOOL isOperation;
/// 特效参数名
/// Special effect parameter name
@property (nonatomic, strong) NSString *fxName;
/// cell label背景颜色（rgba)
/// cell label Background Color (rgba)
@property (nonatomic, strong) NSString *labelColor;
/// cell 背景颜色（rgba)
/// cell Background Color (rgba)
@property (nonatomic, strong) NSString *bgColor;
/// cell label文本颜色（rgba)
/// cell label Text Color (rgba)
@property (nonatomic, strong) NSString *textColor;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *packageUrl;
@property (nonatomic, strong) NSString *degreeName;
/// 美白B lut/png 文件名称
/// Whitening B lut/png file name
@property (nonatomic, strong) NSArray <NvMakeupBeautyWhitenModel *>* beautyLut;
@property (nonatomic, assign) BOOL canReplace;

/// 关联的子项目，比如磨皮：有多个子磨皮，但是他们有一个共同的父类
/// Related child items, such as peels: There are multiple child peels, but they share a common parent class
@property (nonatomic, strong) NSArray <NvBeautyTypeModel *>* subprojectArray;
@property (nonatomic, assign) BOOL expansion;
@property (nonatomic, assign) BOOL parentNode;
@property (nonatomic, assign) DownloadState state;
/// 模版类型 0 = 无，1 = 普通，2= 自定义
/// Template type 0 = none, 1 = common, 2= Custom
@property (nonatomic, assign) NSInteger typeTemplate;
@end

@interface NvBeautyTemplateModel : NvBeautyTypeModel<NSCopying,NSMutableCopying>
/// 美颜模版原始数据
/// Beauty template raw data
@property (nonatomic, strong) NvMakeupToolModel *beautyTemplate;
/// 美颜模版界面数据
/// Beauty template interface data
@property (nonatomic, strong, nullable) NSMutableArray *beautyTemplateData;
///是否需要显示改变状态
///Whether to display the changed status
@property (nonatomic, assign) BOOL displayChangedStatus;

@end

@interface NvMakeupTranslationModel : NSObject<NSCopying,NSMutableCopying>
@property (nonatomic, strong) NSString *originalText;
@property (nonatomic, strong) NSString *targetLanguage;
@property (nonatomic, strong) NSString *targetText;
@end

/*---------------------美妆应用效果model Beauty application effect model---------------*/
@interface NvMakeupRecommendModel : NSObject
@property (nonatomic, strong) NSString *makeupColor;
@end

@interface NvMakeupLayerModel : NSObject<NSCopying,NSMutableCopying>
@property (nonatomic, assign) NSInteger layer;
@property (nonatomic, strong) NSString *layerId;
@property (nonatomic, assign) BOOL isLUT;
@property (nonatomic, assign) float intensity;
@property (nonatomic, strong) NSString *texFilePath;
@property (nonatomic, strong) NSString *texColor;
@property (nonatomic, strong) NSString *blendingMode;
@property (nonatomic, strong) NSString *lutFilePath;
@end

@interface NvMakeupBeautyWhitenModel : NSObject<NSCopying,NSMutableCopying>
@property (nonatomic, strong) NSString *lutKey;
@property (nonatomic, strong) NSString *lutValue;
@end

@interface NvMakeupEffectBeautyContentModel : NSObject<NSCopying,NSMutableCopying>
@property (nonatomic, assign) float value;
@property (nonatomic, strong) NSString *fxName;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *degreeName;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) BOOL canReplace;
/// 是否是美颜
/// Whether beautiful or not
@property (nonatomic, assign) BOOL isBeauty;
/// 是否是高级磨皮
/// Whether it is advanced dermabrasion
@property (nonatomic, assign) BOOL advancedBeautyEnable;
/// 高级磨皮type 值
/// Advanced dermabrasion type value
@property (nonatomic, assign) NSInteger advancedBeautyType;
/// 美白是否支持lut(false 为美白A)
/// Does whitening support lut(false for whitening A)
@property (nonatomic, assign) BOOL whiteningLutEnabled;
/// 美型格式是否为facemesh
/// Whether the beauty format is facemesh
@property (nonatomic, assign) BOOL isFacemesh;
/// 美白B lut/png 文件名称
/// Whitening B lut/png file name
@property (nonatomic, strong) NSArray <NvMakeupBeautyWhitenModel *>* beautyLut;
@end

@interface NvMakeupEffectFilterContentModel : NSObject<NSCopying,NSMutableCopying>
@property (nonatomic, assign) BOOL isBuiltIn;
@property (nonatomic, assign) BOOL canReplace;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) float value;
@end

@interface NvMakeupEffectContentModel : NSObject<NSCopying,NSMutableCopying>
@property (nonatomic, strong) NSArray <NvMakeupLayerModel *>*makeupLayers;
@property (nonatomic, strong) NSArray <NvMakeupRecommendModel *>*makeupRecommendColors;
@property (nonatomic, strong) NSString *makeupValueStr;
@property (nonatomic, strong) NSString *makeupId;
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, copy) NSString *packagePath;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) float intensity;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSArray <NvMakeupTranslationModel *>*translation;
@property (nonatomic, assign) BOOL canReplace;
@end

@interface NvMakeupEffectModel : NSObject<NSCopying,NSMutableCopying>
@property (nonatomic, strong) NSMutableArray <NvMakeupEffectFilterContentModel *>*filter;
@property (nonatomic, strong) NSMutableArray <NvMakeupEffectBeautyContentModel *>*beauty;
@property (nonatomic, strong) NSMutableArray <NvMakeupEffectBeautyContentModel *>*shape;
@property (nonatomic, strong) NSMutableArray <NvMakeupEffectBeautyContentModel *>*microShape;
@property (nonatomic, strong) NSMutableArray <NvMakeupEffectContentModel *>*makeup;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *makeupId;
@property (nonatomic, assign) BOOL isComposeMakeup;
@property (nonatomic, assign) BOOL isComposeReplaceSingle;
@end

/*---------------------美妆界面model Beauty interface model---------------*/
@interface NvMakeupContentModel : NvBeautyTypeModel<NSCopying,NSMutableCopying>
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *displayNameZhCn;
@property (nonatomic, assign) float xValue;
@property (nonatomic, assign) BOOL hasSelectedCustomColor;
@property (nonatomic, assign) NSInteger selectedButtonIndex;
@property (nonatomic, strong) NSString *selectedColorStr;

@property (nonatomic, assign) BOOL isComposeMakeup;
@property (nonatomic, strong) NSString *effectFileName;
@property (nonatomic, strong) NvMakeupEffectModel *effectContent;
@property (nonatomic, strong) NSString *resourceDir;
@property (nonatomic, strong) NSString *bgColorStr;
@property (nonatomic, strong) NSString *labelColorStr;
@property (nonatomic, strong) NSString *textColorStr;
@property (nonatomic, assign) BOOL hasBgColor;
@property (nonatomic, assign) NSInteger conLevel;
@property (nonatomic, copy) NSString *packagePath;
@property (nonatomic, copy) NSString *zipUrl;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, strong) NSString *minSdkVersion;
@property (nonatomic, strong) NSString *supportedAspectRatio;
@property (nonatomic, strong) NSArray <NvMakeupTranslationModel *>*translation;
@end

@interface NvMakeupModel : NSObject
@property (nonatomic, assign) NSInteger contentLevel;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray <NvMakeupContentModel *>*contents;
@property (nonatomic, assign) BOOL needAddContent;
@property (nonatomic, strong) NSArray <NSString *>*addContentFile;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *displayNameZhCn;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) NSInteger kind;
@property (nonatomic, assign) NSInteger category;
@property (nonatomic, assign) NSInteger materialType;
@property (nonatomic, assign) BOOL hasRequested;
@property (nonatomic, assign) NSInteger requestPageNum;
@end

NS_ASSUME_NONNULL_END
