//
//  NvMakeupModel.m
//  SDKDemo
//
//  Created by MS on 2020/2/28.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvMakeupModel.h"
#import "NvMakeupToolModel.h"

@implementation NvBeautyTypeModel
- (instancetype)init {
    self = [super init];
    self.canReplace = YES;
    self.typeTemplate = 1;
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    NvBeautyTypeModel *model = [NvBeautyTypeModel new];
    model.isBeauty = self.isBeauty;
    model.type = self.type;
    model.name = self.name;
    model.selectedCoverImg = self.selectedCoverImg;
    model.selected = self.selected;
    model.value = self.value;
    model.extValue = self.extValue;
    model.coverImage = self.coverImage;
    model.isOperation = self.isOperation;
    model.fxName = self.fxName;
    model.defaultValue = self.defaultValue;
    model.defaultExtValue = self.defaultExtValue;
    model.switchSelected = self.switchSelected;
    model.labelColor = self.labelColor;
    model.bgColor = self.bgColor;
    model.textColor = self.textColor;
    model.uuid = self.uuid;
    model.packageUrl = self.packageUrl;
    model.degreeName = self.degreeName;
    model.beautyLut = [[NSArray alloc] initWithArray:self.beautyLut copyItems:YES];
    model.canReplace = self.canReplace;
    model.nameEn = self.nameEn;
    model.subprojectArray = [[NSArray alloc] initWithArray:self.subprojectArray copyItems:YES];
    model.expansion = self.expansion;
    model.parentNode = self.parentNode;
    model.state = self.state;
    model.typeTemplate = self.typeTemplate;
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    NvBeautyTypeModel *model = [NvBeautyTypeModel new];
    model.isBeauty = self.isBeauty;
    model.type = self.type;
    model.name = self.name;
    model.selectedCoverImg = self.selectedCoverImg;
    model.selected = self.selected;
    model.value = self.value;
    model.extValue = self.extValue;
    model.coverImage = self.coverImage;
    model.isOperation = self.isOperation;
    model.fxName = self.fxName;
    model.defaultValue = self.defaultValue;
    model.defaultExtValue = self.defaultExtValue;
    model.switchSelected = self.switchSelected;
    model.labelColor = self.labelColor;
    model.bgColor = self.bgColor;
    model.textColor = self.textColor;
    model.uuid = self.uuid;
    model.packageUrl = self.packageUrl;
    model.degreeName = self.degreeName;
    model.beautyLut = [[NSArray alloc] initWithArray:self.beautyLut copyItems:YES];
    model.canReplace = self.canReplace;
    model.nameEn = self.nameEn;
    model.subprojectArray = [[NSArray alloc] initWithArray:self.subprojectArray copyItems:YES];
    model.expansion = self.expansion;
    model.parentNode = self.parentNode;
    model.state = self.state;
    model.typeTemplate = self.typeTemplate;
    return model;
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"coverImage" : @[@"coverImage",@"cover"],
        @"fxName" : @[@"fxName",@"className"],
    };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"beautyLut" : [NvMakeupBeautyWhitenModel class],
        @"subprojectArray" : [NvBeautyTypeModel class],
    };
}

@end

@implementation NvBeautyTemplateModel

- (id)copyWithZone:(nullable NSZone *)zone {
    NvBeautyTemplateModel *model = [NvBeautyTemplateModel new];
    model.beautyTemplate = self.beautyTemplate;
    model.beautyTemplateData = self.beautyTemplateData;
    model.displayChangedStatus = self.displayChangedStatus;
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    NvBeautyTemplateModel *model = [NvBeautyTemplateModel new];
    model.beautyTemplate = self.beautyTemplate;
    model.beautyTemplateData = self.beautyTemplateData;
    model.displayChangedStatus = self.displayChangedStatus;
    return model;
}

@end

@implementation NvMakeupTranslationModel
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvMakeupTranslationModel *model = [self yy_modelCopy];
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    NvMakeupTranslationModel *model = [NvMakeupTranslationModel new];
    model.originalText = self.originalText;
    model.targetText = self.targetText;
    model.targetLanguage = self.targetLanguage;
    return model;
}
@end

@implementation NvMakeupRecommendModel

@end

@implementation NvMakeupLayerModel
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvMakeupLayerModel *model = [self yy_modelCopy];
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    NvMakeupLayerModel *model = [NvMakeupLayerModel new];
    model.layer = self.layer;
    model.layerId = self.layerId;
    model.isLUT = self.isLUT;
    model.intensity = self.intensity;
    model.texFilePath = self.texFilePath;
    model.texColor = self.texColor;
    model.blendingMode = self.blendingMode;
    model.lutFilePath = self.lutFilePath;
    return model;
}
@end

@implementation NvMakeupBeautyWhitenModel

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvMakeupBeautyWhitenModel *model = [self yy_modelCopy];
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    NvMakeupBeautyWhitenModel *model = [NvMakeupBeautyWhitenModel new];
    model.lutKey = [NSString stringWithString:self.lutKey];
    model.lutValue = [NSString stringWithString:self.lutValue];
    return model;
}

@end

@implementation NvMakeupEffectBeautyContentModel
- (instancetype)init {
    if (self = [super init]) {
        self.isFacemesh = NO;
        self.isBeauty = NO;
    }
    return self;
}
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvMakeupEffectBeautyContentModel *model = [self yy_modelCopy];
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    NvMakeupEffectBeautyContentModel *model = [NvMakeupEffectBeautyContentModel new];
    model.value = self.value;
    model.fxName = self.fxName;
    model.isBeauty = self.isBeauty;
    model.isFacemesh = self.isFacemesh;
    model.uuid = self.uuid;
    model.canReplace = self.canReplace;
    model.degreeName = self.degreeName;
    model.advancedBeautyType = self.advancedBeautyType;
    model.advancedBeautyEnable = self.advancedBeautyEnable;
    model.whiteningLutEnabled = self.whiteningLutEnabled;
    model.type = self.type;
    model.beautyLut = [[NSArray alloc] initWithArray:self.beautyLut copyItems:YES];
    return model;
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"advancedBeautyType" : @[@"Advanced Beauty Type"],
        @"advancedBeautyEnable" : @[@"Advanced Beauty Enable"],
        @"fxName" : @[@"fxName", @"className"],
        @"whiteningLutEnabled" : @[@"Whitening Lut Enabled"],
    };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"beautyLut" : [NvMakeupBeautyWhitenModel class],
    };
}
@end

@implementation NvMakeupEffectFilterContentModel
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvMakeupEffectFilterContentModel *model = [self yy_modelCopy];
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    NvMakeupEffectFilterContentModel *model = [NvMakeupEffectFilterContentModel new];
    model.isBuiltIn = self.isBuiltIn;
    model.uuid = self.uuid;
    model.value = self.value;
    model.canReplace = self.canReplace;
    return model;
}
@end

@implementation NvMakeupEffectContentModel
- (instancetype)init {
    if (self = [super init]) {
        self.intensity = 0.6;
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvMakeupEffectContentModel *model = [self yy_modelCopy];
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    NvMakeupEffectContentModel *model = [NvMakeupEffectContentModel new];
    model.makeupLayers = [[NSArray alloc] initWithArray:self.makeupLayers copyItems:YES];
    model.makeupRecommendColors = [[NSArray alloc] initWithArray:self.makeupRecommendColors copyItems:YES];
    model.makeupValueStr = self.makeupValueStr;
    model.makeupId = self.makeupId;
    model.intensity = self.intensity;
    model.color = [NSString stringWithString:self.color] ;
    model.className = self.className;
    model.uuid = self.uuid;
    model.translation = self.translation;
    model.canReplace = self.canReplace;
    return model;
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"intensity" : @[@"intensity",@"value"],
        @"makeupId" : @[@"makeupId",@"type"],
        @"fileName" : @[@"fileName",@"packageFileName"],
    };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"makeupLayers" : [NvMakeupLayerModel class],
        @"makeupRecommendColors" : [NvMakeupRecommendModel class],
        @"translation" : [NvMakeupTranslationModel class],
    };
}
@end

@implementation NvMakeupEffectModel
- (instancetype)init {
    if (self = [super init]) {
        self.makeup = [NSMutableArray array];
        self.beauty = [NSMutableArray array];
        self.filter = [NSMutableArray array];
        self.shape = [NSMutableArray array];
        self.microShape = [NSMutableArray array];
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvMakeupEffectModel *model = [self yy_modelCopy];
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    NvMakeupEffectModel *model = [NvMakeupEffectModel new];
    model.filter = [[NSMutableArray alloc] initWithArray:self.filter copyItems:YES];
    model.beauty = [[NSMutableArray alloc] initWithArray:self.beauty copyItems:YES];
    model.shape = [[NSMutableArray alloc] initWithArray:self.shape copyItems:YES];
    model.microShape = [[NSMutableArray alloc] initWithArray:self.microShape copyItems:YES];
    model.makeup = [[NSMutableArray alloc] initWithArray:self.makeup copyItems:YES];
    model.name = self.name;
    model.makeupId = self.makeupId;
    model.isComposeMakeup = self.isComposeMakeup;
    return model;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"filter" : [NvMakeupEffectFilterContentModel class],
        @"beauty" : [NvMakeupEffectBeautyContentModel class],
        @"shape" : [NvMakeupEffectBeautyContentModel class],
        @"microShape" : [NvMakeupEffectBeautyContentModel class],
        @"makeup" : [NvMakeupEffectContentModel class],
    };
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"shape" : @[@"beautyType",@"shape"],
        @"makeup" : @[@"makeup",@"makeupArgs"],
    };
}

@end

@implementation NvMakeupContentModel

- (instancetype)init{
    if (self = [super init]) {
        self.isOperation = YES;
        self.effectContent = [NvMakeupEffectModel new];
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    NvMakeupContentModel *model = [NvMakeupContentModel new];
    model.isBeauty = self.isBeauty;
    model.name = self.name;
    model.selected = self.selected;
    model.value = self.value;
    model.coverImage = self.coverImage;
    model.isOperation = self.isOperation;
    model.fxName = self.fxName;
    model.xValue = self.xValue;
    model.hasSelectedCustomColor = self.hasSelectedCustomColor;
    model.selectedButtonIndex = self.selectedButtonIndex;
    model.selectedColorStr = self.selectedColorStr;
    model.isComposeMakeup = self.isComposeMakeup;
    model.effectFileName = self.effectFileName;
    model.effectContent = [self.effectContent copy];
    model.resourceDir = self.resourceDir;
    model.bgColorStr = self.bgColorStr;
    model.labelColorStr = self.labelColorStr;
    model.hasBgColor = self.hasBgColor;
    model.conLevel = self.conLevel;
    model.displayName = self.displayName;
    model.displayNameZhCn = self.displayNameZhCn;
    model.uuid = self.uuid;
    model.packageUrl = self.packageUrl;
    model.packagePath = self.packagePath;
    model.version = self.version;
    model.minSdkVersion = self.minSdkVersion;
    model.supportedAspectRatio = self.supportedAspectRatio;
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    NvMakeupContentModel *model = [NvMakeupContentModel new];
    model.isBeauty = self.isBeauty;
    model.name = self.name;
    model.selected = self.selected;
    model.value = self.value;
    model.coverImage = self.coverImage;
    model.isOperation = self.isOperation;
    model.fxName = self.fxName;
    model.xValue = self.xValue;
    model.hasSelectedCustomColor = self.hasSelectedCustomColor;
    model.selectedButtonIndex = self.selectedButtonIndex;
    model.selectedColorStr = self.selectedColorStr;
    model.isComposeMakeup = self.isComposeMakeup;
    model.effectFileName = self.effectFileName;
    model.effectContent = [self.effectContent mutableCopy];
    model.resourceDir = self.resourceDir;
    model.bgColorStr = self.bgColorStr;
    model.labelColorStr = self.labelColorStr;
    model.hasBgColor = self.hasBgColor;
    model.conLevel = self.conLevel;
    model.displayName = self.displayName;
    model.displayNameZhCn = self.displayNameZhCn;
    model.uuid = self.uuid;
    model.packageUrl = self.packageUrl;
    model.packagePath = self.packagePath;
    model.version = self.version;
    model.minSdkVersion = self.minSdkVersion;
    model.supportedAspectRatio = self.supportedAspectRatio;
    return model;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"translation" : [NvMakeupTranslationModel class],
             };
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"coverImage" : @[@"imageName",@"cover",@"coverUrl"],
        @"packageUrl" : @[@"packageUrl",@"url"],
        @"uuid" : @[@"uuid",@"id"],
    };
}

@end

@implementation NvMakeupModel
- (instancetype)init {
    if (self = [super init]) {
        self.hasRequested = NO;
        self.contents = [NSMutableArray array];
        self.requestPageNum = 1;
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"contents" : [NvMakeupContentModel class],
             @"addContentFile" : [NSString class],
             };
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"contentLevel" : @[@"level",],
        @"contents" : @[@"contents",@"effectList"],
        @"kind" : @[@"id"],
    };
}
@end
