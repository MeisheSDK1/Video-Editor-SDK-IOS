//
//  NvAjustFxParamModel.m
//  SDKDemo
//
//  Created by Meishe on 2022/8/17.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvAjustFxParamModel.h"

@implementation NvAjustFxParamModel
- (id)copyWithZone:(NSZone *)zone {
    NvAjustFxParamModel *new = [NvAjustFxParamModel new];
    new.type = self.type;
    new.name = [NSString stringWithFormat:@"%@",self.name];
    new.translationName = [NSString stringWithFormat:@"%@",self.translationName];
    new.defaultValue = self.defaultValue;
    new.minValue = self.minValue;
    new.maxValue = self.maxValue;
    new.currentValue = self.currentValue;
    new.r = self.r;
    new.g = self.g;
    new.b = self.b;
    new.a = self.a;
    return new;
}
@end
