//
//  NvUrlVideoEditingModule.m
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/2.
//  Copyright © 2024 meishe. All rights reserved.
//

#import "NvUrlVideoEditingModule.h"
#import "NvUrlVideoMaterialVC.h"

@implementation NvUrlVideoEditingModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 6;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)moduleTitle {
    return [self localString:@"urlEditing" comment:@"URL视音频编辑"];
}

- (UIImage *)moduleCover {
    return [UIImage imageNamed:@"NvHomeUrlEdit"];
}

- (void)startModule:(NSDictionary *)param {
    NvUrlVideoMaterialVC *vc = [[NvUrlVideoMaterialVC alloc] init];
//    vc.isMusicEdit = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
