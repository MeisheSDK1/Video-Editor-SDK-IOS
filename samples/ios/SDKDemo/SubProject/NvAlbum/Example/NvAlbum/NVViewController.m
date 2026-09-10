//
//  NVViewController.m
//  NvAlbum
//
//  Created by chuyang009@163.com on 05/20/2021.
//  Copyright (c) 2021 chuyang009@163.com. All rights reserved.
//

#import "NVViewController.h"
#import <NvAlbum/NvAlbumViewController.h>
#import <NvAlbum/NvSizeViewController.h>

@interface NVViewController ()

@end

@implementation NVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)albumClick:(id)sender {
    NvAlbumViewController *album = [NvAlbumViewController new];
    album.delegate = self;
    [self.navigationController pushViewController:album animated:YES];
}

#pragma mark 相册回调
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    NvSizeViewController *sizeVC = [NvSizeViewController new];
    sizeVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.navigationController presentViewController:sizeVC animated:NO completion:NULL];
    __weak typeof(self)weakSelf = self;
    [sizeVC selectSizeTypeBlock:^(int type) {
        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
//        NvEditViewController *vc = [[NvEditViewController alloc] init];
//        vc.selectAssets = assets;
//        vc.editMode = type;
//        vc.isFromAlbum = YES;
//        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
