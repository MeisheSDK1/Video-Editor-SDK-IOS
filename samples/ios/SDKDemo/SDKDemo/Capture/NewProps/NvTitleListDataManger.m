//
//  NvTitleListDataManger.m
//  SDKDemo
//
//  Created by ms20180425 on 2022/3/21.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvTitleListDataManger.h"

@implementation NvTitleListDataManger

+ (NvTitleListDataManger *)standardDefaults{
    static dispatch_once_t once;
    static NvTitleListDataManger *dataManager;
    dispatch_once(&once, ^{
        dataManager = [[NvTitleListDataManger alloc] init];
    });
    return dataManager;
}

@end
