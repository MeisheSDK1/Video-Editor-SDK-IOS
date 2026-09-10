//
//  NvTestEditModule.m
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/12.
//  Copyright © 2024 meishe. All rights reserved.
//

#import "NvTestEditModule.h"
#import "NvTestEditVC.h"

@implementation NvTestEditModule

+ (void)load {
//    [self registerModule];
}

+ (int)moduleIndex {
    return 17;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)moduleTitle {
    return @"从沙盒读取素材";
}

- (UIImage *)moduleCover {
    return [UIImage imageNamed:@"NvHomeParticle"];
}

- (void)startModule:(NSDictionary *)param {
    NvTestEditVC *vc = [[NvTestEditVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
