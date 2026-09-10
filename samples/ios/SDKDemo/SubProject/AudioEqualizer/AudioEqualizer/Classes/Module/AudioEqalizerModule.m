//
//  AudioEqalizerModule.m
//  AudioEqualizer
//
//  Created by rongwf on 2021/7/12.
//

#import "AudioEqalizerModule.h"
#import <NvAlbum/NvAlbumViewController.h>
#import <NvAlbum/NvAlbumSizeViewController.h>
#import "NvAudioEqualizerViewController.h"
#import <UIKit/UIKit.h>
#import <NvBaseCommon/NVDefineConfig.h>

@interface AudioEqalizerModule ()<NvAlbumViewControllerDelegate>

@end

@implementation AudioEqalizerModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 14;
}

- (NSString *)moduleTitle {
    return NvLocalStringFromTable([self class],@"Audio equalizer", @"音频均衡器");
}

- (UIImage *)moduleCover {
    return NvImageNamed(@"NvAudioEqualizer");
}

- (void)startModule:(NSDictionary *)param {
    NvAlbumViewController *albumVC = [NvAlbumViewController new];
    albumVC.delegate = self;
    albumVC.mutableSelect = YES;
    albumVC.isOnlyVideo = YES;
//    albumVC.maxSelectCount = 2;
    [self.navigationController pushViewController:albumVC animated:YES];
}

#pragma mark - NvAlbumViewControllerDelegate
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    NvAlbumSizeViewController *sizeVC = [NvAlbumSizeViewController new];
    sizeVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.navigationController presentViewController:sizeVC animated:NO completion:NULL];
    __weak typeof(self)weakSelf = self;
    [sizeVC selectSizeTypeBlock:^(int type) {
        NvAudioEqualizerViewController *vc = [[NvAudioEqualizerViewController alloc]init];
        vc.selectAssets = assets;
        vc.editMode = (NvEditMode)type;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssetsOverMaxCountLimit:(NSMutableArray <NvAlbumAsset *>*)assets {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NvLocalStringFromTable([self class],@"Tips", @"提示") message:NvLocalStringFromTable([self class],@"Select up to 2 materials", @"最多选2个素材") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:NvLocalStringFromTable([self class],@"Know", @"知道了") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:sureAction];
    [self.navigationController presentViewController:alertVC animated:YES completion:NULL];
}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController didSelectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
}

- (UIView *)nvAlbumViewControllerCustomBottomButton {
    return nil;
}

@end
