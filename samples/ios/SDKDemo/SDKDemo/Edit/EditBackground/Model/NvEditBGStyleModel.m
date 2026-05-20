//
//  NvEditBGStyleModel.m
//  SDKDemo
//
//  Created by MS on 2020/10/22.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvEditBGStyleModel.h"
#import "YYModel.h"

@implementation NvEditBGStyleModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"packageNameEn" : @[@"packageName-en"],
    };
}

@end
