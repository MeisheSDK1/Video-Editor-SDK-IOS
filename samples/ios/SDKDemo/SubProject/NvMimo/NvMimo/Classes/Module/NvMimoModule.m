//
//  NvMimoModule.m
//  NvMimo
//
//  Created by rongwf on 2021/7/8.
//

#import "NvMimoModule.h"
#import "NvMimoListViewController.h"
#import <NvBaseCommon/NVDefineConfig.h>

@implementation NvMimoModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 12;
}


- (NSString *)moduleTitle {
    return @"Memo";
}

- (UIImage *)moduleCover {
    return NvImageNamed(@"NvHomeMimo");
}

- (void)startModule:(NSDictionary *)param {
    NvMimoListViewController *vc = [[NvMimoListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
