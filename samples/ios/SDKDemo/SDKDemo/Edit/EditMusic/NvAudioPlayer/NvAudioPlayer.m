//
//  NvAudioPlayer.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/3.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <NvSDKCommon/NvWeakTimer.h>
#import "NvCustomAudioPlayer.h"

#define NV_TIME_BASE 1000000

@interface NvAudioPlayer()

@property (nonatomic, strong) NvCustomPlayer *avPlayer;
@property (nonatomic, assign) float duration;
@property (nonatomic, strong) NvWeakTimer *timer;

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) id observer;

@end

@implementation NvAudioPlayer

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_avPlayer && self.observer) {
        [self.avPlayer removeTimeObserver:self.observer];
    }
    NSLog(@"%s",__func__);
}

- (instancetype)init {
    if (self = [super init]) {
        self.avPlayer = [[NvCustomPlayer alloc] init];
//        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//        NSError *err = nil;
//        [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
    }
    return self;
}


- (void)setUrlString:(NSString *)urlString {
    NSURL *playerurl = nil;
    if ([urlString containsString:@"http://"]||[urlString containsString:@"ipod-library://"]) {
        playerurl = [NSURL URLWithString:urlString];
    } else {
        playerurl = [NSURL fileURLWithPath:urlString];
    }
    AVAsset *asset = [AVAsset assetWithURL:playerurl];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    self.playerItem = [AVPlayerItem playerItemWithURL:playerurl];
    [self.avPlayer replaceCurrentItemWithPlayerItem:self.playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
    self.duration = CMTimeGetSeconds(asset.duration);
    if (self.observer) {
        [self.avPlayer removeTimeObserver:self.observer];
    }
    __weak typeof(self) weakSelf = self;
    self.observer = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        Float64 currentSeconds = CMTimeGetSeconds(time);
        if (weakSelf.duration!=0 && [weakSelf.delegate respondsToSelector:@selector(nvAudioPlayer:currentTime:)]) {
            [weakSelf.delegate nvAudioPlayer:weakSelf currentTime:currentSeconds];
        }
    }];
}

- (float)currentTime {
    return CMTimeGetSeconds(self.avPlayer.currentTime);
}

- (void)seekToTime:(float)time {
    [self.avPlayer seekToTime:CMTimeMake((int64_t)(time*NV_TIME_BASE), NV_TIME_BASE)];
}

- (void)play {
    [self.avPlayer play];
}

- (void)pause {
    [self.avPlayer pause];
}

- (void)rate:(float)rate {
    self.avPlayer.rate = rate;
}

- (void)setVolume:(float)volume {
    [self.avPlayer setVolume:volume];
}

- (void)playbackFinished {
    if ([self.delegate respondsToSelector:@selector(nvAudioPlayerPlayEOF:)]) {
        [self.delegate nvAudioPlayerPlayEOF:self];
    }
}

@end
