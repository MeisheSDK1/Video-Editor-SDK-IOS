//
//  NvDouVideoFxModule.m
//  SDKDemo
//
//  Created by rongwf on 2021/7/12.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvDouVideoFxModule.h"
#import "NvDouVideoCaptureViewController.h"
#import "NvDownloadLic.h"

@interface NvDouVideoFxModule ()

@property (nonatomic, strong) NvDownloadLic *downloadLic;

@end

@implementation NvDouVideoFxModule

+ (void)load {
    [self registerModule];
}

+ (int)moduleIndex {
    return 0;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.downloadLic = [[NvDownloadLic alloc] init];
        [self.downloadLic loadLic:^(NSString * _Nullable licPath, NSError * _Nullable error) {
            [NvToast dismiss];
            if (error) {
                [NvToast showInfoWithMessage:error.localizedDescription];
            } else {
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                [userDefault setObject:[licPath stringByReplacingOccurrencesOfString:@"file://" withString:@""] forKey:@"NvLisence_st"];
            }
        }];
    }
    return self;
}

- (NSString *)moduleTitle {
    return [self localString:@"ShortVideoFx" comment:@"短视频"];
}

- (UIImage *)moduleCover {
    return [UIImage imageNamed:@"NvHomeDuanShiPin"];
}

- (void)startModule:(NSDictionary *)param {
    if (ARSCENE_ST || ARSCENE_ST_240 || ARSCENE_ST_106_Advanced) {
        if (self.downloadLic.status == NvFinish) {
            NvDouVideoCaptureViewController *vc = [[NvDouVideoCaptureViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (self.downloadLic.status == NvFail) {
            [NvToast showLoadingWithMessage:NvLocalString(@"Loading", @"下载中...")];
            __weak typeof(self)weakSelf = self;
            [self.downloadLic loadLic:^(NSString * _Nullable licPath, NSError * _Nullable error) {
                [NvToast dismiss];
                if (error) {
                    [NvToast showInfoWithMessage:error.localizedDescription];
                } else {
                    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                    [userDefault setObject:[licPath stringByReplacingOccurrencesOfString:@"file://" withString:@""] forKey:@"NvLisence_st"];
                    NvDouVideoCaptureViewController *vc = [[NvDouVideoCaptureViewController alloc] init];
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
            }];
        } else {
            [NvToast showLoadingWithMessage:NvLocalString(@"Loading", @"下载中...")];
        }
    } else {
        NvDouVideoCaptureViewController *vc = [[NvDouVideoCaptureViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
