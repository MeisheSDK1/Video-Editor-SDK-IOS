//
//  NvThemeShootingModule.m
//  SDKDemo
//
//  Created by rongwf on 2021/7/12.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvThemeShootingModule.h"
#import "NVPhotoThemeController.h"

@implementation NvThemeShootingModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 13;
}

- (NSString *)moduleTitle {
    return [self localString:@"ThemeShooting" comment:@"主题拍摄"];
}

- (UIImage *)moduleCover {
    return [UIImage imageNamed:@"NvThemeShooting"];
}

- (void)startModule:(NSDictionary *)param {
    NVPhotoThemeController *vc = [[NVPhotoThemeController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
