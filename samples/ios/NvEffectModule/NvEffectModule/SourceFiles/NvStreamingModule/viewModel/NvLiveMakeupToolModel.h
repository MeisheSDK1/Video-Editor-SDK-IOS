//
//  NvLiveMakeupToolModel.h
//  NvEffectModule
//
//  Created by ms20221114 on 2024/6/26.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NvLiveMakeupModulerMode) {
    NvLiveMakeupModulerModeCapture,
    NvLiveMakeupModulerModeEdit,
};

@interface NvLiveMakeupToolElementModel : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *type;
@end

@interface NvLiveMakeupToolElementStringModel : NvLiveMakeupToolElementModel
@property (nonatomic, strong) NSString *value;
@end

@interface NvLiveMakeupToolElementBOOLModel : NvLiveMakeupToolElementModel
@property (nonatomic, assign) BOOL value;
@end

@interface NvLiveMakeupToolElementIntModel : NvLiveMakeupToolElementModel
@property (nonatomic, assign) int value;
@end

@interface NvLiveMakeupToolElementFloatModel : NvLiveMakeupToolElementModel
@property (nonatomic, assign) float value;
@property (nonatomic, assign) float defaultValue;
@end

@interface NvLiveMakeupToolElementDoubleModel : NvLiveMakeupToolElementModel
@property (nonatomic, assign) double value;
@end

@interface NvLiveMakeupToolElementColorModel : NvLiveMakeupToolElementModel
@property (nonatomic, assign) float r;
@property (nonatomic, assign) float g;
@property (nonatomic, assign) float b;
@property (nonatomic, assign) float a;
@end

@interface NvLiveMakeupToolEffectModel : NSObject
@property (nonatomic, strong) NSString *type;
/// 效果能否被替换，根据包内的json字段获取，无关上层操作
/// Whether the effect can be replaced depends on the json field in the package, regardless of upper-layer operations
@property (nonatomic, assign) BOOL canReplace;
/// 效果被替换，上层手动替换了该效果，该字段在妆容调节程度时，需要用到
/// The effect is replaced. The upper layer manually replaces the effect. This field is needed to adjust the degree of makeup
@property (nonatomic, assign) BOOL beReplaced;
@property (nonatomic, strong) NSArray <NvLiveMakeupToolElementModel *>*params;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) double value;
@property (nonatomic, assign) double defaultValue;
@property (nonatomic, assign) BOOL isBuiltIn;
@end

@interface NvLiveMakeupToolEffectContentModel : NSObject
@property (nonatomic, strong) NSMutableArray <NvLiveMakeupToolEffectModel *>*makeup;
@property (nonatomic, strong) NSMutableArray <NvLiveMakeupToolEffectModel *>*beauty;
@property (nonatomic, strong) NSMutableArray <NvLiveMakeupToolEffectModel *>*shape;
@property (nonatomic, strong) NSMutableArray <NvLiveMakeupToolEffectModel *>*microShape;
@property (nonatomic, strong) NSMutableArray <NvLiveMakeupToolEffectModel *>*filter;
@property (nonatomic, strong) NSMutableArray <NvLiveMakeupToolEffectModel *>*adjust;
@end

//------代码上兼容旧版妆容info.json，如果使用的妆容包是新版本，则不需要做兼容
//------The code is compatible with the old version of makeup info.json. If the makeup pack is a new version, it does not need to be compatible
@interface NvLiveMakeupEffectBeautyContentOldInfoModel : NSObject<NSCopying,NSMutableCopying>
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

@interface NvLiveMakeupEffectOldInfoModel : NSObject<NSCopying,NSMutableCopying>
@property (nonatomic, strong) NSMutableArray <NvLiveMakeupEffectBeautyContentOldInfoModel *>*beauty;
@property (nonatomic, strong) NSMutableArray <NvLiveMakeupEffectBeautyContentOldInfoModel *>*shape;
@property (nonatomic, strong) NSMutableArray <NvLiveMakeupEffectBeautyContentOldInfoModel *>*microShape;
@property (nonatomic, strong) NSMutableArray <NvLiveMakeupEffectBeautyContentOldInfoModel *>*makeup;
@end

//------------------------------

@interface NvLiveMakeupToolTranslationModel : NSObject
@property (nonatomic, strong) NSString *originalText;
@property (nonatomic, strong) NSString *targetLanguage;
@property (nonatomic, strong) NSString *targetText;
@end

@interface NvLiveMakeupToolModel : NSObject
@property (nonatomic, copy) NSString *packagePath;
@property (nonatomic, copy) NSString *zipUrl;
@property (nonatomic, strong) NSString *packageFileName;//存储模版名称
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic, strong) NSString *minSdkVersion;
@property (nonatomic, strong) NSString *supportedAspectRatio;
@property (nonatomic, strong) NSArray <NvLiveMakeupToolTranslationModel *>*translation;
@property (nonatomic, strong) NvLiveMakeupToolEffectContentModel *effectContent;
@property (nonatomic, assign) CGFloat defaultValue;
@property (nonatomic, assign) CGFloat currentValue;
@property (nonatomic, assign) CGFloat filterDefaultValue;
@property (nonatomic, assign) CGFloat filterCurrentValue;
@end


NS_ASSUME_NONNULL_END
