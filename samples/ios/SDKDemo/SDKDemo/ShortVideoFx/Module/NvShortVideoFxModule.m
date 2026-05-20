//
//  NvShortVideoFxModule.m
//  SDKDemo
//
//  Created by rongwf on 2021/7/12.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvShortVideoFxModule.h"
#import "NvShortVideoCaptureViewController.h"

@interface NvShortVideoFxModule ()

@end

@implementation NvShortVideoFxModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 0;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)moduleTitle {
    return [self localString:@"ShortVideoFx" comment:@"短视频"];
}

- (UIImage *)moduleCover {
    return [UIImage imageNamed:@"NvHomeDuanShiPin"];
}

- (void)startModule:(NSDictionary *)param {
    NvShortVideoCaptureViewController *vc = [[NvShortVideoCaptureViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
