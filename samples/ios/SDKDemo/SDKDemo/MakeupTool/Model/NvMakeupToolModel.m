//
//  NvMakeupToolModel.m
//  SDKDemo
//
//  Created by Meishe on 2022/11/7.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvMakeupToolModel.h"
@implementation NvMakeupToolElementModel

@end

@implementation NvMakeupToolElementStringModel

@end

@implementation NvMakeupToolElementBOOLModel

@end

@implementation NvMakeupToolElementIntModel

@end

@implementation NvMakeupToolElementFloatModel

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.defaultValue = self.value;
    return YES;
}

@end

@implementation NvMakeupToolElementDoubleModel

@end

@implementation NvMakeupToolElementColorModel

@end

@implementation NvMakeupToolEffectModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"params" : [NvMakeupToolElementModel class],
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
            NvMakeupToolElementStringModel *effect = [NvMakeupToolElementStringModel yy_modelWithJSON:dic1];
            [mutArr addObject:effect];
        }else if ([type caseInsensitiveCompare:@"float"] == NSOrderedSame || [type caseInsensitiveCompare:@"double"] == NSOrderedSame) {
            NvMakeupToolElementFloatModel *effect = [NvMakeupToolElementFloatModel yy_modelWithJSON:dic1];
            [mutArr addObject:effect];
        }else if ([type caseInsensitiveCompare:@"boolean"] == NSOrderedSame) {
            NvMakeupToolElementBOOLModel *effect = [NvMakeupToolElementBOOLModel yy_modelWithJSON:dic1];
            [mutArr addObject:effect];
        }else if ([type caseInsensitiveCompare:@"int"] == NSOrderedSame) {
            NvMakeupToolElementIntModel *effect = [NvMakeupToolElementIntModel yy_modelWithJSON:dic1];
            [mutArr addObject:effect];
        }
    }
    _params = [NSArray arrayWithArray:mutArr];
    return YES;
}
@end

@implementation NvMakeupToolEffectContentModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"makeup" : [NvMakeupToolEffectModel class],
        @"beauty" : [NvMakeupToolEffectModel class],
        @"shape" : [NvMakeupToolEffectModel class],
        @"microShape" : [NvMakeupToolEffectModel class],
        @"filter" : [NvMakeupToolEffectModel class],
        @"adjust" : [NvMakeupToolEffectModel class],
    };
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"makeup" : @[@"makeup",@"makeupArgs"],
    };
}
@end

@implementation NvMakeupToolTranslationModel

@end

@implementation NvMakeupToolModel
- (instancetype)init {
    if (self = [super init]) {
        self.defaultValue = 1;
        self.currentValue = 1;
        self.filterDefaultValue = 1;
        self.filterCurrentValue = 1;
        self.effectContent = [NvMakeupToolEffectContentModel new];
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
        @"translation" : [NvMakeupToolTranslationModel class],
    };
}
@end

@implementation NvMakeupEffectBeautyContentOldInfoModel
- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvMakeupEffectBeautyContentOldInfoModel *model = [self yy_modelCopy];
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    NvMakeupEffectBeautyContentOldInfoModel *model = [NvMakeupEffectBeautyContentOldInfoModel new];
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

@implementation NvMakeupEffectOldInfoModel
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
    NvMakeupEffectOldInfoModel *model = [self yy_modelCopy];
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    NvMakeupEffectOldInfoModel *model = [NvMakeupEffectOldInfoModel new];
    model.beauty = [[NSMutableArray alloc] initWithArray:self.beauty copyItems:YES];
    model.shape = [[NSMutableArray alloc] initWithArray:self.shape copyItems:YES];
    model.microShape = [[NSMutableArray alloc] initWithArray:self.microShape copyItems:YES];
    model.makeup = [[NSMutableArray alloc] initWithArray:self.makeup copyItems:YES];
    return model;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"beauty" : [NvMakeupEffectBeautyContentOldInfoModel class],
        @"shape" : [NvMakeupEffectBeautyContentOldInfoModel class],
        @"microShape" : [NvMakeupEffectBeautyContentOldInfoModel class],
        @"makeup" : [NvMakeupEffectBeautyContentOldInfoModel class],
    };
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"shape" : @[@"beautyType",@"shape"],
        @"makeup" : @[@"makeup",@"makeupArgs"],
    };
}
@end

