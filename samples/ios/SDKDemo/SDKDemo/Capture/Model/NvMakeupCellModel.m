//
//  NvMakeupCellModel.m
//  SDKDemo
//
//  Created by Meishe on 2022/11/9.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvMakeupCellModel.h"

@implementation NvMakeupCellModel

@end

@implementation NvMakeupLevelModel
- (instancetype)init {
    if (self = [super init]) {
        self.contents = [NSMutableArray array];
        self.requestPageNum = 1;
    }
    return self;
}
@end
