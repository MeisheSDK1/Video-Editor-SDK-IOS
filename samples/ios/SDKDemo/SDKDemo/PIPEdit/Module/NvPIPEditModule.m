//
//  NvPIPEditModule.m
//  SDKDemo
//
//  Created by rongwf on 2021/7/12.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvPIPEditModule.h"
#import <NvAlbum/NvAlbumViewController.h>
#import "NvPIPEditViewController.h"

@interface NvPIPEditModule ()<NvAlbumViewControllerDelegate>

@property (nonatomic, weak) UIButton *custumButton;
@property (nonatomic, strong) NSMutableArray<NvAlbumAsset *> *assets;

@end

@implementation NvPIPEditModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 4;
}

- (NSString *)moduleTitle {
    return [self localString:@"PIP" comment:@"画中画"];
}

- (UIImage *)moduleCover {
    return [UIImage imageNamed:@"NvHomePIP"];
}

- (void)startModule:(NSDictionary *)param {
    NvAlbumViewController *albumVC = [[NvAlbumViewController alloc] init];
    albumVC.delegate = self;
    albumVC.mutableSelect = YES;
    albumVC.minSelectCount = 2;
    albumVC.maxSelectCount = 2;
    albumVC.hiddenSelectAll = YES;
    albumVC.alwaysShowCustomBottom = YES;
    [self.navigationController pushViewController:albumVC animated:YES];
}

#pragma mark - NvAlbumViewControllerDelegate
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssetsOverMaxCountLimit:(NSMutableArray <NvAlbumAsset *>*)assets {
    
    [UIAlertController presentAlertFromVC:self.navigationController
                                    title:NvLocalString(@"Tips", @"提示")
                                  message:NvLocalString(@"Select up to 2 materials", @"最多选2个素材")
                        buttonTitleColors:nil
                        cancelButtonTitle:nil
                         otherButtonTitle:NvLocalString(@"Know", @"知道了")
                       cancelButtonAction:nil
                        otherButtonAction:nil];

}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController didSelectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    self.assets = assets;
    if (assets.count == 1) {
        [self.custumButton setTitle:NvLocalString(@"Select the second material", @"选择第2个素材") forState:UIControlStateNormal];
        [self.custumButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#FFA3A3A3"] forState:UIControlStateNormal];
    } else if (assets.count == 2) {
        [self.custumButton setTitle:NvLocalString(@"Start Make", @"开始制作") forState:UIControlStateNormal];
        [self.custumButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    } else if (assets.count == 0) {
        [self.custumButton setTitle:NvLocalString(@"Choose 2 materials to make", @"选择2个素材进行制作") forState:UIControlStateNormal];
        [self.custumButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#FFA3A3A3"] forState:UIControlStateNormal];
    }
}

- (void)customButtonClick:(UIButton *)button {
    if (self.assets.count < 2) {

        [UIAlertController presentAlertFromVC:self.navigationController
                                        title:NvLocalString(@"Tips", @"提示")
                                      message:NvLocalString(@"Select the second material", @"请选择两个素材")
                            buttonTitleColors:nil
                            cancelButtonTitle:nil
                             otherButtonTitle:NvLocalString(@"Know", @"知道了")
                           cancelButtonAction:nil
                            otherButtonAction:nil];
    } else {
        NvPIPEditViewController *pipEdit = [NvPIPEditViewController new];
        pipEdit.selectAsset = self.assets;
        [self.navigationController pushViewController:pipEdit animated:YES];
    }
    
}

- (UIView *)nvAlbumViewControllerCustomBottomButton {
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#363738"];
    UIButton *custumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.custumButton = custumButton;
    custumButton.frame = CGRectMake(0, 0, SCREENWIDTH, 49*SCREENSCALE);
    [custumButton addTarget:self action:@selector(customButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [custumButton setTitle:NvLocalString(@"Select the second material Make", @"选择2个素材进行制作") forState:UIControlStateNormal];
    [custumButton setTitleColor:[UIColor nv_colorWithHexARGB:@"#FFA3A3A3"] forState:UIControlStateNormal];
    custumButton.titleLabel.font = [NvUtils fontWithSize:16];
    [bottomView addSubview:custumButton];
    return bottomView;
}

@end
