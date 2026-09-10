//
//  NvFlashEffectModule.m
//  NvFlashEffect
//
//  Created by rongwf on 2021/7/9.
//

#import "NvFlashEffectModule.h"
#import "NvFlashEffectViewController.h"
#import <NvBaseCommon/NVDefineConfig.h>


@implementation NvFlashEffectModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 10;
}

- (NSString *)moduleTitle {
    return NvLocalStringFromTable([self class], @"NvFlashFx", @"闪光特效");
}

- (UIImage *)moduleCover {
    return NvImageNamed(@"NvFlashFx");
}

- (void)startModule:(NSDictionary *)param {
    NvFlashEffectViewController *vc = [[NvFlashEffectViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
