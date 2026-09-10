//
//  NvLocalMusicViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/2.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvLocalMusicViewController.h"
#import "NvMusicTableView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NvEditSelectMusicItem.h"
#import <Masonry/Masonry.h>
#import <NvBaseCommon/NvToast.h>
#import <NvBaseCommon/NvLocalString.h>
#import <NvSDKCommon/NvUtils.h>

@interface NvLocalMusicViewController ()

@property (nonatomic, strong) NvMusicTableView *music;
@property (nonatomic, strong) NSMutableArray *musicDataSource;

@end

@implementation NvLocalMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.music = [NvMusicTableView new];
    self.music.delegate = self;
    [self.view addSubview:self.music];
    [self.music mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(@0);
    }];
    [self requestAuthorization];
}

- (void)requestAuthorization {
    self.musicDataSource = [NSMutableArray array];
    if (@available(iOS 9.3, *)) {
        __weak typeof (self) weakSelf = self;
        [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
            if (status == MPMediaLibraryAuthorizationStatusAuthorized) {
                [weakSelf fetchLocalMusic];
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.music.dataSource = weakSelf.musicDataSource;
                });
            } else if (status == MPMediaLibraryAuthorizationStatusDenied) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NvToast showInfoWithMessage:NvLocalString(@"Media.permissions", @"媒体库权限被禁止") inView:weakSelf.music];
                });
            }
        }];
    } else {
        // Fallback on earlier versions
        [self fetchLocalMusic];
        self.music.dataSource = self.musicDataSource;
    }
}

- (void)fetchLocalMusic {
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    NSArray<MPMediaItem *> *items = query.items;
    for (int i = 0; i < items.count; i++) {
        NvEditSelectMusicItem *item = [NvEditSelectMusicItem new];
        item.musicName = [NSString stringWithFormat:@"%@", [items[i] valueForProperty: MPMediaItemPropertyTitle]];
        item.authorName = [NSString stringWithFormat:@"%@", [items[i] valueForProperty: MPMediaItemPropertyArtist]];
        item.musicPath = [NSString stringWithFormat:@"%@", [[items[i] valueForProperty: MPMediaItemPropertyAssetURL] absoluteString]];
        MPMediaItemArtwork *artwork = [items[i] valueForProperty: MPMediaItemPropertyArtwork];
        if(artwork){
            UIImage *artworkImage = [artwork imageWithSize: CGSizeMake(56, 56)];
            item.image = artworkImage;
        }else{
            item.image = NvImageNamed(@"NvEditMusic");
        }
        item.duration = [[NSString stringWithFormat:@"%@", [items[i] valueForProperty: MPMediaItemPropertyPlaybackDuration]] floatValue];
        [self.musicDataSource addObject:item];
    }
}

- (void)reloadData {
    self.music.dataSource = self.musicDataSource;
}

- (void)playItem:(NvEditSelectMusicItem *)item {
    if ([self.delegate respondsToSelector:@selector(nvLocalMusicViewController:playItem:)]) {
        [self.delegate nvLocalMusicViewController:self playItem:item];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
