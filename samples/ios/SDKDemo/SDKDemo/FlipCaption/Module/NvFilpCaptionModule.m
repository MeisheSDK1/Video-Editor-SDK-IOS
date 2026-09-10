//
//  NvFilpCaptionModule.m
//  SDKDemo
//
//  Created by rongwf on 2021/7/12.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvFilpCaptionModule.h"
#import <NvAlbum/NvAlbumViewController.h>
#import "NvFlipCaptionViewController.h"

@interface NvFilpCaptionModule ()<NvAlbumViewControllerDelegate>

@end

@implementation NvFilpCaptionModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 5;
}

- (NSString *)moduleTitle {
    return [self localString:@"Flip subtitles" comment:@"翻转字幕"];
}

- (UIImage *)moduleCover {
    return [UIImage imageNamed:@"NvHomeFlipSubtitles"];
}

- (void)startModule:(NSDictionary *)param {    
    NvAlbumViewController *albumVC = [[NvAlbumViewController alloc] init];
    albumVC.delegate = self;
    albumVC.mutableSelect = YES;
    albumVC.isOnlyVideo = YES;
    [self.navigationController pushViewController:albumVC animated:YES];
}

#pragma mark - NvAlbumViewControllerDelegate
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    NvFlipCaptionViewController *vc = [NvFlipCaptionViewController new];
    vc.assets = assets;
    vc.editMode = NvEditMode9v16;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssetsOverMaxCountLimit:(NSMutableArray <NvAlbumAsset *>*)assets {
}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController didSelectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
}

- (UIView *)nvAlbumViewControllerCustomBottomButton {
    return nil;
}

@end
