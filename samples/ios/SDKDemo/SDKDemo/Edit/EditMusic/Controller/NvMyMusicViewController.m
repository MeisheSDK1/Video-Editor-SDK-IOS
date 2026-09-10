//
//  NvMyMusicViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/2.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMyMusicViewController.h"
#import "NvMusicTableView.h"
#import "NvEditSelectMusicItem.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
#import <NvSDKCommon/NvUtils.h>

@interface NvMyMusicViewController ()

@property (nonatomic, strong) NvMusicTableView *music;
@property (nonatomic, strong) NSMutableArray *musicDataSource;

@end

@implementation NvMyMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.music = [NvMusicTableView new];
    self.music.delegate = self;
    [self.view addSubview:self.music];
    [self.music mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    [self fetchBundleMusic];
    self.music.dataSource = self.musicDataSource;
}

- (void)fetchBundleMusic {
    self.musicDataSource = [NSMutableArray array];
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"music" ofType:@"bundle"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *array = [fm contentsOfDirectoryAtPath:musicPath error:nil];
    for (NSString *name in array) {
        if ([name hasSuffix:@".lrc"]) {
            continue;
        }
        NvEditSelectMusicItem *item = [NvEditSelectMusicItem new];
        item.musicName = [name stringByDeletingPathExtension];
        item.musicPath = [musicPath stringByAppendingPathComponent:name];
        NSDictionary *dic = [self getMusicInfo:item.musicPath];
        item.authorName = [dic objectForKey:@"artist"];
        if (item.authorName == nil || item.authorName.length == 0) {
            item.authorName = @"null";
        }
        item.image = NvImageNamed(@"NvEditMusic");
        item.duration = CMTimeGetSeconds([AVURLAsset assetWithURL:[NSURL fileURLWithPath:item.musicPath]].duration);
        [self.musicDataSource addObject:item];
    }
}

 - (NSMutableDictionary *)getMusicInfo:(NSString *)musicPath {
     AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:musicPath] options:nil];
     NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
     
     for (NSString *format in [mp3Asset availableMetadataFormats]) {
         for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format]) {
             if([metadataItem.commonKey isEqualToString:@"artist"]) {
                 NSString *artist = (NSString *)metadataItem.value;
                 [infoDict setObject:artist forKey:@"artist"];
             } 
         }
     }
     return [infoDict copy];
}

- (void)reloadData {
    self.music.dataSource = self.musicDataSource;
}

- (void)playItem:(NvEditSelectMusicItem *)item {
    if ([self.delegate respondsToSelector:@selector(nvMyMusicViewController:playItem:)]) {
        [self.delegate nvMyMusicViewController:self playItem:item];
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
