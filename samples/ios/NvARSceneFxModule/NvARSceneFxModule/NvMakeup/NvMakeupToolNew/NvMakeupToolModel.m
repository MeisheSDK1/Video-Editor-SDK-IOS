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
    if (!dic[@"params"]) return NO;
//    NSDictionary *dic1 = [NSJSONSerialization JSONObjectWithData:[dic[@"params"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
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
    };
}
@end

@implementation NvMakeupToolTranslationModel

@end

@implementation NvMakeupToolModel
- (instancetype)init {
    if (self = [super init]) {
        self.effectContent = [NvMakeupToolEffectContentModel new];
    }
    return self;
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"packagePath" : @[@"packagePath",@"packageUrl"],
        @"cover" : @[@"cover",@"coverImage"],
        @"uuid" : @[@"uuid",@"singlePackageId"],
    };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"translation" : [NvMakeupToolTranslationModel class],
    };
}

@end

@implementation NvMakeupToolDataModel

@end
