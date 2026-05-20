//
//  NvMusiclyricModule.m
//  SDKDemo
//
//  Created by rongwf on 2021/7/12.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvMusiclyricModule.h"
#import <NvAlbum/NvAlbumViewController.h>
#import "NvMusiclyricViewController.h"

@interface NvMusiclyricModule ()<NvAlbumViewControllerDelegate>

@end

@implementation NvMusiclyricModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 7;
}

- (NSString *)moduleTitle {
    return [self localString:@"Music lyric" comment:@"音乐唱词"];
}

- (UIImage *)moduleCover {
    return [UIImage imageNamed:@"NvHomeMusicLyrics"];
}

- (void)startModule:(NSDictionary *)param {
    NvAlbumViewController *albumVC = [NvAlbumViewController new];
    albumVC.delegate = self;
    albumVC.isOnlyVideo = YES;
    [self.navigationController pushViewController:albumVC animated:YES];
}

#pragma mark - NvAlbumViewControllerDelegate
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    NvMusiclyricViewController *vc = [[NvMusiclyricViewController alloc]init];
    vc.editMode = NvEditMode9v16;
    vc.selectAssets = assets;
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
