//
//  NvLiveMakeupItemModel.m
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/17.
//

#import "NvLiveMakeupItemModel.h"

@implementation NvLiveMakeupItemModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.effectType = -1;
        self.value = 1;
    }
    return self;
}

@end
