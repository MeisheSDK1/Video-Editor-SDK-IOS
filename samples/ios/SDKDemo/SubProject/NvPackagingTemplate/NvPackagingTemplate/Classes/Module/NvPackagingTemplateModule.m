//
//  NvPackagingTemplateModule.m
//  NvPackagingTemplate-NvPackagingTemplate
//
//  Created by ms on 2021/7/28.
//

#import "NvPackagingTemplateModule.h"
#import <NvAlbum/NvAlbumViewController.h>
#import <NvAlbum/NvAlbumSizeViewController.h>
#import <UIKit/UIKit.h>
#import "NvPackagingTemplateViewController.h"
#import <NvBaseCommon/NVDefineConfig.h>

@interface NvPackagingTemplateModule ()<NvAlbumViewControllerDelegate>

@end

@implementation NvPackagingTemplateModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 15;
}

- (NSString *)moduleTitle {
    return NvLocalStringFromTable([self class], @"Packaging template", @"包装模板");
}

- (UIImage *)moduleCover {
    return NvImageNamed(@"NvPackagingTemplate");
}

- (void)startModule:(NSDictionary *)param {
    NvAlbumViewController *albumVC = [NvAlbumViewController new];
    albumVC.delegate = self;
    albumVC.mutableSelect = YES;
    albumVC.isOnlyVideo = YES;
    [self.navigationController pushViewController:albumVC animated:YES];
}

#pragma mark - NvAlbumViewControllerDelegate
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    NvAlbumSizeViewController *sizeVC = [NvAlbumSizeViewController new];
    sizeVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.navigationController presentViewController:sizeVC animated:NO completion:NULL];
    __weak typeof(self)weakSelf = self;
    [sizeVC selectSizeTypeBlock:^(int type) {
        NvPackagingTemplateViewController *vc = [[NvPackagingTemplateViewController alloc]init];
        vc.selectAssets = assets;
        vc.editMode = (NvEditMode)type;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssetsOverMaxCountLimit:(NSMutableArray <NvAlbumAsset *>*)assets {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NvLocalString(@"Tips", @"提示") message:NvLocalString( @"Select up to 2 materials", @"最多选2个素材") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:NvLocalString( @"Know", @"知道了") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
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
