//
//  NvPhotoAlbumModule.m
//  SDKDemo
//
//  Created by rongwf on 2021/7/13.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvPhotoAlbumModule.h"
#import "NvPhotoAlbumViewController.h"

@implementation NvPhotoAlbumModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 9;
}

- (NSString *)moduleTitle {
    return [self localString:@"PhotoAlbum" comment:@"照片影集"];
}

- (UIImage *)moduleCover {
    return [UIImage imageNamed:@"NvPhotoAlbum"];
}

- (void)startModule:(NSDictionary *)param {
    NvPhotoAlbumViewController *vc = [NvPhotoAlbumViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
