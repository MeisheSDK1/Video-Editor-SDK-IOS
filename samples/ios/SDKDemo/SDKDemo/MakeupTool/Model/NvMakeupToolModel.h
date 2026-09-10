//
//  NvMakeupToolModel.h
//  SDKDemo
//
//  Created by Meishe on 2022/11/7.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, NvMakeupModulerMode) {
    NvMakeupModulerModeCapture,
    NvMakeupModulerModeEdit,
};

@interface NvMakeupToolElementModel : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *type;
@end

@interface NvMakeupToolElementStringModel : NvMakeupToolElementModel
@property (nonatomic, strong) NSString *value;
@end

@interface NvMakeupToolElementBOOLModel : NvMakeupToolElementModel
@property (nonatomic, assign) BOOL value;
@end

@interface NvMakeupToolElementIntModel : NvMakeupToolElementModel
@property (nonatomic, assign) int value;
@end

@interface NvMakeupToolElementFloatModel : NvMakeupToolElementModel
@property (nonatomic, assign) float value;
@property (nonatomic, assign) float defaultValue;
@end

@interface NvMakeupToolElementDoubleModel : NvMakeupToolElementModel
@property (nonatomic, assign) double value;
@end

@interface NvMakeupToolElementColorModel : NvMakeupToolElementModel
@property (nonatomic, assign) float r;
@property (nonatomic, assign) float g;
@property (nonatomic, assign) float b;
@property (nonatomic, assign) float a;
@end

@interface NvMakeupToolEffectModel : NSObject
@property (nonatomic, strong) NSString *type;
/// 效果能否被替换，根据包内的json字段获取，无关上层操作
/// Whether the effect can be replaced depends on the json field in the package, regardless of upper-layer operations
@property (nonatomic, assign) BOOL canReplace;
/// 效果被替换，上层手动替换了该效果，该字段在妆容调节程度时，需要用到
/// The effect is replaced. The upper layer manually replaces the effect. This field is needed to adjust the degree of makeup
@property (nonatomic, assign) BOOL beReplaced;
@property (nonatomic, strong) NSArray <NvMakeupToolElementModel *>*params;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) double value;
@property (nonatomic, assign) double defaultValue;
@property (nonatomic, assign) BOOL isBuiltIn;
@end

@interface NvMakeupToolEffectContentModel : NSObject
@property (nonatomic, strong) NSMutableArray <NvMakeupToolEffectModel *>*makeup;
@property (nonatomic, strong) NSMutableArray <NvMakeupToolEffectModel *>*beauty;
@property (nonatomic, strong) NSMutableArray <NvMakeupToolEffectModel *>*shape;
@property (nonatomic, strong) NSMutableArray <NvMakeupToolEffectModel *>*microShape;
@property (nonatomic, strong) NSMutableArray <NvMakeupToolEffectModel *>*filter;
@property (nonatomic, strong) NSMutableArray <NvMakeupToolEffectModel *>*adjust;
@end

//------代码上兼容旧版妆容info.json，如果使用的妆容包是新版本，则不需要做兼容
//------The code is compatible with the old version of makeup info.json. If the makeup pack is a new version, it does not need to be compatible
@interface NvMakeupEffectBeautyContentOldInfoModel : NSObject<NSCopying,NSMutableCopying>
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) BOOL canReplace;
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) float value;
@property (nonatomic, assign) BOOL advancedBeautyEnable;
@property (nonatomic, assign) NSInteger advancedBeautyType;
@property (nonatomic, assign) BOOL whiteningLutEnabled;
@property (nonatomic, strong) NSString *degreeName;
@end

@interface NvMakeupEffectOldInfoModel : NSObject<NSCopying,NSMutableCopying>
@property (nonatomic, strong) NSMutableArray <NvMakeupEffectBeautyContentOldInfoModel *>*beauty;
@property (nonatomic, strong) NSMutableArray <NvMakeupEffectBeautyContentOldInfoModel *>*shape;
@property (nonatomic, strong) NSMutableArray <NvMakeupEffectBeautyContentOldInfoModel *>*microShape;
@property (nonatomic, strong) NSMutableArray <NvMakeupEffectBeautyContentOldInfoModel *>*makeup;
@end

//------------------------------

@interface NvMakeupToolTranslationModel : NSObject
@property (nonatomic, strong) NSString *originalText;
@property (nonatomic, strong) NSString *targetLanguage;
@property (nonatomic, strong) NSString *targetText;
@end

@interface NvMakeupToolModel : NSObject
@property (nonatomic, copy) NSString *packagePath;
@property (nonatomic, copy) NSString *zipUrl;
@property (nonatomic, strong) NSString *packageFileName;//存储模版名称
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic, strong) NSString *minSdkVersion;
@property (nonatomic, strong) NSString *supportedAspectRatio;
@property (nonatomic, strong) NSArray <NvMakeupToolTranslationModel *>*translation;
@property (nonatomic, strong) NvMakeupToolEffectContentModel *effectContent;
@property (nonatomic, assign) CGFloat defaultValue;
@property (nonatomic, assign) CGFloat currentValue;
@property (nonatomic, assign) CGFloat filterDefaultValue;
@property (nonatomic, assign) CGFloat filterCurrentValue;
@end

NS_ASSUME_NONNULL_END
