//
//  NvBoomerangModule.m
//  NvBoomerang
//
//  Created by rongwf on 2021/7/9.
//

#import "NvBoomerangModule.h"
#import "NvBoomerangViewController.h"
#import <NvBaseCommon/NVDefineConfig.h>

@implementation NvBoomerangModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 8;
}

- (NSString *)moduleTitle {
    return NvLocalStringFromTable([self class], @"Flash back", @"闪回");
}

- (UIImage *)moduleCover {
    return NvImageNamed(@"NvHomeBoomrang");
}

- (void)startModule:(NSDictionary *)param {
    NvBoomerangViewController *vc = [[NvBoomerangViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
