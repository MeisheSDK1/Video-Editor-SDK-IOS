//
//  NvMakeupToolMakeupModuler.m
//  SDKDemo
//
//  Created by Meishe on 2022/11/7.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvMakeupToolMakeupModuler.h"

@implementation NvMakeupToolMakeupModuler
- (void)applyMakeupPackage:(NvMakeupToolEffectContentModel *)effectModel makeupKindArr:(NSArray *)makeupKindArr {
    NSMutableArray *kindArr = [[NSMutableArray alloc] initWithArray:makeupKindArr copyItems:YES];
    NSMutableArray *containKindArr = [NSMutableArray array];
    
    //处理效果
    //Treatment effect
    if(effectModel.makeup.count > 0){
        for (NvMakeupToolEffectModel *model in effectModel.makeup) {
            for(NvMakeupToolElementModel *item in model.params) {
                if ([item.type caseInsensitiveCompare:@"string"] == NSOrderedSame) {
                    NvMakeupToolElementStringModel *effect = (NvMakeupToolElementStringModel *)item;
                    [self.fxARFace setStringVal:effect.key val:effect.value];
                    [containKindArr addObject:effect.key];
                }else if ([item.type caseInsensitiveCompare:@"float"] == NSOrderedSame || [item.type caseInsensitiveCompare:@"double"] == NSOrderedSame) {
                    NvMakeupToolElementFloatModel *effect = (NvMakeupToolElementFloatModel *)item;
                    [self.fxARFace setFloatVal:effect.key val:effect.value];
                }else if ([item.type caseInsensitiveCompare:@"color"] == NSOrderedSame) {
                    NvMakeupToolElementColorModel *effect = (NvMakeupToolElementColorModel *)item;
                    NvsColor color = {effect.r,effect.g,effect.b,effect.a};
                    [self.fxARFace setColorVal:effect.key val:&color];
                }
            }
        }
    }
    for (NSString *item in kindArr) {
        NSString *baseStr = [@"Makeup " stringByAppendingString:item];
        NSString *packageId = [baseStr stringByAppendingString:@" Package Id"];
        if ([containKindArr containsObject:packageId]) {
            continue;
        }
        [self.fxARFace setStringVal:packageId val:@""];
        NSString *intensityStr = [baseStr stringByAppendingString:@" Intensity"];
        [self.fxARFace setFloatVal:intensityStr val:0];
        
        NvsColor color;
        color.r = 0;
        color.g = 0;
        color.b = 0;
        color.a = 0;
        NSString *colorStr = [baseStr stringByAppendingString:@" Color"];
        [self.fxARFace setColorVal:colorStr val:&color];
    }
    
    [self.fxARFace setFloatVal:@"Makeup Intensity" val: containKindArr.count > 0 ? 1 : 0];
}

- (void)applySingMakeupPackage:(NvMakeupToolEffectContentModel *)effectModel{
    [self.fxARFace setStringVal:@"Makeup Compound Package Id" val:@""];
    NvMakeupToolEffectModel *model = effectModel.makeup.firstObject;
    
    if (model.params.count > 0){
        NvMakeupToolElementStringModel *stringModel = model.params.firstObject;
        [self.fxARFace setStringVal:stringModel.key val:stringModel.value];
        
        NSString *baseStr = [@"Makeup " stringByAppendingString:model.type];
        NSString *intensityStr = [baseStr stringByAppendingString:@" Intensity"];
        [self.fxARFace setFloatVal:intensityStr val:1.0];
    }else{
        //单妆选择无
        //Single makeup option no
        NSString *baseStr = [@"Makeup " stringByAppendingString:model.type];
        NSString *packageId = [baseStr stringByAppendingString:@" Package Id"];
        [self.fxARFace setStringVal:packageId val:@""];
        NSString *intensityStr = [baseStr stringByAppendingString:@" Intensity"];
        [self.fxARFace setFloatVal:intensityStr val:0];
        
        NSString *colorStr = [baseStr stringByAppendingString:@" Color"];
        NvsColor color = [self nvsColorWithValue:@""];
        [self.fxARFace setColorVal:colorStr val:&color];
    }

    [self.fxARFace setFloatVal:@"Makeup Intensity" val:1];
}

- (NvsColor)nvsColorWithValue:(NSString *)value {
    NSArray *arr = [value componentsSeparatedByString:@","];
    NvsColor color;
    color.r = 0;
    color.g = 0;
    color.b = 0;
    color.a = 0;
    if (arr.count == 4) {
        color.r = [arr[0] floatValue];
        color.g = [arr[1] floatValue];
        color.b = [arr[2] floatValue];
        color.a = [arr[3] floatValue];
    }
    return color;
}

@end
