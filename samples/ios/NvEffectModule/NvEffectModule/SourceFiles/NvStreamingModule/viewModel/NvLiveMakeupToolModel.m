//
//  NvLiveMakeupToolModel.m
//  NvEffectModule
//
//  Created by ms20221114 on 2024/6/26.
//

#import "NvLiveMakeupToolModel.h"

@implementation NvLiveMakeupToolElementModel

@end

@implementation NvLiveMakeupToolElementStringModel

@end

@implementation NvLiveMakeupToolElementBOOLModel

@end

@implementation NvLiveMakeupToolElementIntModel

@end

@implementation NvLiveMakeupToolElementFloatModel

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.defaultValue = self.value;
    return YES;
}

@end

@implementation NvLiveMakeupToolElementDoubleModel

@end

@implementation NvLiveMakeupToolElementColorModel

@end

@implementation NvLiveMakeupToolEffectModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"params" : [NvLiveMakeupToolElementModel class],
    };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.defaultValue = self.value;
    if (!dic[@"params"]) return NO;
    NSArray *arr = dic[@"params"];
    NSMutableArray *mutArr = [NSMutableArray array];
    for(NSDictionary *dic1 in arr) {
        NSString *type = dic1[@"type"];
        if ([type caseInsensitiveCompare:@"string"] == NSOrderedSame || [type caseInsensitiveCompare:@"path"] == NSOrderedSame) {
            NvLiveMakeupToolElementStringModel *effect = [NvLiveMakeupToolElementStringModel yy_modelWithJSON:dic1];
            [mutArr addObject:effect];
        }else if ([type caseInsensitiveCompare:@"float"] == NSOrderedSame || [type caseInsensitiveCompare:@"double"] == NSOrderedSame) {
            NvLiveMakeupToolElementFloatModel *effect = [NvLiveMakeupToolElementFloatModel yy_modelWithJSON:dic1];
            [mutArr addObject:effect];
        }else if ([type caseInsensitiveCompare:@"boolean"] == NSOrderedSame) {
            NvLiveMakeupToolElementBOOLModel *effect = [NvLiveMakeupToolElementBOOLModel yy_modelWithJSON:dic1];
            [mutArr addObject:effect];
        }else if ([type caseInsensitiveCompare:@"int"] == NSOrderedSame) {
            NvLiveMakeupToolElementIntModel *effect = [NvLiveMakeupToolElementIntModel yy_modelWithJSON:dic1];
            [mutArr addObject:effect];
        }
    }
    _params = [NSArray arrayWithArray:mutArr];
    return YES;
}
@end

@implementation NvLiveMakeupToolEffectContentModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"makeup" : [NvLiveMakeupToolEffectModel class],
        @"beauty" : [NvLiveMakeupToolEffectModel class],
        @"shape" : [NvLiveMakeupToolEffectModel class],
        @"microShape" : [NvLiveMakeupToolEffectModel class],
        @"filter" : [NvLiveMakeupToolEffectModel class],
        @"adjust" : [NvLiveMakeupToolEffectModel class],
    };
}
@end

@implementation NvLiveMakeupToolTranslationModel

@end

@implementation NvLiveMakeupToolModel
- (instancetype)init {
    if (self = [super init]) {
        self.defaultValue = 1;
        self.currentValue = 1;
        self.filterDefaultValue = 1;
        self.filterCurrentValue = 1;
        self.effectContent = [NvLiveMakeupToolEffectContentModel new];
    }
    return self;
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"packagePath" : @[@"packagePath",@"packageUrl"],
    };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"translation" : [NvLiveMakeupToolTranslationModel class],
    };
}
@end

@implementation NvLiveMakeupEffectBeautyContentOldInfoModel
- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvLiveMakeupEffectBeautyContentOldInfoModel *model = [self yy_modelCopy];
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    NvLiveMakeupEffectBeautyContentOldInfoModel *model = [NvLiveMakeupEffectBeautyContentOldInfoModel new];
    model.value = self.value;
    model.className = self.className;
    model.uuid = self.uuid;
    model.canReplace = self.canReplace;
    model.degreeName = self.degreeName;
    model.advancedBeautyType = self.advancedBeautyType;
    model.advancedBeautyEnable = self.advancedBeautyEnable;
    model.whiteningLutEnabled = self.whiteningLutEnabled;
    model.type = self.type;
    return model;
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"advancedBeautyType" : @[@"Advanced Beauty Type"],
        @"advancedBeautyEnable" : @[@"Advanced Beauty Enable"],
        @"whiteningLutEnabled" : @[@"Whitening Lut Enabled"],
        @"className" : @[@"fxName", @"className"],
    };
}
@end

@implementation NvLiveMakeupEffectOldInfoModel
- (instancetype)init {
    if (self = [super init]) {
        self.makeup = [NSMutableArray array];
        self.beauty = [NSMutableArray array];
        self.shape = [NSMutableArray array];
        self.microShape = [NSMutableArray array];
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvLiveMakeupEffectOldInfoModel *model = [self yy_modelCopy];
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    NvLiveMakeupEffectOldInfoModel *model = [NvLiveMakeupEffectOldInfoModel new];
    model.beauty = [[NSMutableArray alloc] initWithArray:self.beauty copyItems:YES];
    model.shape = [[NSMutableArray alloc] initWithArray:self.shape copyItems:YES];
    model.microShape = [[NSMutableArray alloc] initWithArray:self.microShape copyItems:YES];
    model.makeup = [[NSMutableArray alloc] initWithArray:self.makeup copyItems:YES];
    return model;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"beauty" : [NvLiveMakeupEffectBeautyContentOldInfoModel class],
        @"shape" : [NvLiveMakeupEffectBeautyContentOldInfoModel class],
        @"microShape" : [NvLiveMakeupEffectBeautyContentOldInfoModel class],
        @"makeup" : [NvLiveMakeupEffectBeautyContentOldInfoModel class],
    };
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"shape" : @[@"beautyType",@"shape"],
        @"makeup" : @[@"makeup",@"makeupArgs"],
    };
}
@end
