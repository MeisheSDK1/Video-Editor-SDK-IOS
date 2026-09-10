//
//  NvVirtualModule.m
//  SDKDemo
//
//  Created by rongwf on 2021/7/12.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvVirtualModule.h"
#import "NvVKeyerViewController.h"
#import <NvBaseCommon/NVDefineConfig.h>
@implementation NvVirtualModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 3;
}

- (NSString *)moduleTitle {
    return NvLocalStringFromTable([self class], @"VirtualKeyer", @"背景抠像");
}

- (UIImage *)moduleCover {
    return NvImageNamed(@"NvHomeVirtualKeyer");
}

- (void)startModule:(NSDictionary *)param {
    NvVKeyerViewController *vc = [[NvVKeyerViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
