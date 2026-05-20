//
//  NvEffectsStyleModel.m
//  SDKDemo
//
//  Created by ms20180425 on 2022/3/23.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvEffectsStyleModel.h"

@implementation NvEffectsStyleModel

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvEffectsStyleModel *model = [self yy_modelCopy];
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    NvEffectsStyleModel *model = [NvEffectsStyleModel new];
    model.selected = self.selected;
    model.coverName = self.coverName;
    model.coverDefault = self.coverDefault;
    model.displayName = self.displayName;
    return model;
}

@end
