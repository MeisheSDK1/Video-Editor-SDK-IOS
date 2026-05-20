//
//  NvCoverModule.m
//  SDKDemo
//
//  Created by rongwf on 2021/7/12.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvCoverModule.h"
#import <NvAlbum/NvAlbumViewController.h>
#import <NvAlbum/NvAlbumSizeViewController.h>
#import "NvCoverMakerViewController.h"

@interface NvCoverModule ()<NvAlbumViewControllerDelegate>

@end

@implementation NvCoverModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 11;
}

- (NSString *)moduleTitle {
    return [self localString:@"Cover" comment:@"封面"];
}

- (UIImage *)moduleCover {
    return [UIImage imageNamed:@"NvCoverMaker"];
}

- (void)startModule:(NSDictionary *)param {
    NvAlbumViewController *albumVC = [NvAlbumViewController new];
    albumVC.delegate = self;
    albumVC.isOnlyImage = YES;
    albumVC.mutableSelect = false;
    [self.navigationController pushViewController:albumVC animated:YES];
}

#pragma mark - NvAlbumViewControllerDelegate
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    NvAlbumSizeViewController *sizeVC = [NvAlbumSizeViewController new];
    sizeVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    ViewController *rootVc = (ViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    [self.navigationController presentViewController:sizeVC animated:NO completion:NULL];
    __weak typeof(self)weakSelf = self;
    [sizeVC selectSizeTypeBlock:^(int type) {
        NvCoverMakerViewController *vc = [[NvCoverMakerViewController alloc]init];
        vc.editMode = NvEditMode9v16;
        vc.selectAssets = assets;
        vc.editMode = (NvEditMode)type;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssetsOverMaxCountLimit:(NSMutableArray <NvAlbumAsset *>*)assets {
}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController didSelectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
}

- (UIView *)nvAlbumViewControllerCustomBottomButton {
    return nil;
}

@end
