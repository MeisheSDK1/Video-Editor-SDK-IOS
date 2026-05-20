//
//  NvRecordModel.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/8/8.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvRecordModel.h"

@implementation NvRecordModel

- (instancetype)init {
    if (self = [super init]) {
        self.volume = 1;
        self.audioNoiseSuppressionLevel = 0;
    }
    return self;
}

@end
