//
//  NvParticleFxModule.m
//  SDKDemo
//
//  Created by rongwf on 2021/7/12.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvParticleFxModule.h"
#import "NvParCaptureViewController.h"

@interface NvParticleFxModule ()

@end

@implementation NvParticleFxModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 1;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)moduleTitle {
    return [self localString:@"ParticleFx" comment:@"粒子特效"];
}

- (UIImage *)moduleCover {
    return [UIImage imageNamed:@"NvHomeParticle"];
}

- (void)startModule:(NSDictionary *)param {
    NvParCaptureViewController *vc = [[NvParCaptureViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
