//
//  NvCustomAudioPlayer.m
//  XBEchoCancellationTest
//
//  Created by Mac-Mini on 2024/5/25.
//  Copyright © 2024 xxb. All rights reserved.
//

#import "NvCustomAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#include <sys/sysctl.h>

/// https://forums.developer.apple.com/forums/thread/721535
/// 延迟设置AudioSession
/// - Parameter msec: 毫秒数
/// 在做回声消除的时候，如果你使用系统的播放器播放音乐或视频，声音会很低，必须等声音播起来后把audiosession的outputAudioPort
/// 先设置为AVAudioSessionPortOverrideNone后设置为AVAudioSessionPortOverrideSpeaker声音才会变的正常。这里采用监听
/// 播放器的状态，等到ready的时候再设置。
///
/// - Parameter msec: milliseconds
/// When doing echo cancellation, if you use the system player to play music or video, the sound will be very low.
/// You must wait until the sound starts playing and then set the outputAudioPort of the audiosession to
///  AVAudioSessionPortOverrideNone and then to AVAudioSessionPortOverrideSpeaker to make the sound normal.
///  Here we use the monitoring player status and wait until it is ready before setting it.
///

/// 回声消除时会将audiosession的category设置为AVAudioSessionCategoryPlayAndRecord，
/// 因此如果不是AVAudioSessionCategoryPlayAndRecord状态，不必设置AVAudioSessionPortOverrideSpeaker
/// When echo cancellation is in progress, the category of audiosession will be set to AVAudioSessionCategoryPlayAndRecord.
/// Therefore, if it is not in the AVAudioSessionCategoryPlayAndRecord state, there is no need to set AVAudioSessionPortOverrideSpeaker
void NvConfigAudioSession() {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if (session.category == AVAudioSessionCategoryPlayAndRecord) {
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
}

@interface NvCustomPlayer ()
@property(assign, getter=isPlaying) BOOL playing;
@end

@implementation NvCustomPlayer {
    BOOL isObserver;
}

- (void)dealloc
{
    if (self.currentItem) {
        [self.currentItem removeObserver:self forKeyPath:@"status"];
    }
}

- (void)setRate:(float)rate {
    [super setRate:rate];
    if (rate > 0) {
        [self setPlaying:true];
        if (!isObserver) {
            [self.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:(void *)self];
            isObserver = true;
        }
    } else {
        [self setPlaying:false];
    }
}

- (void)play {
    [super play];
    [self setPlaying:true];
    if (!isObserver) {
        [self.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:(void *)self];
        isObserver = true;
    }
}

- (void)pause {
    [super pause];
    [self setPlaying:false];
}

- (void)replaceCurrentItemWithPlayerItem:(nullable AVPlayerItem *)item {
    [self.currentItem removeObserver:self forKeyPath:@"status"];
    [super replaceCurrentItemWithPlayerItem:item];
    [self.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:(void *)self];
    isObserver = true;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == ((__bridge void *)self) && [keyPath isEqualToString:@"status"]) {
        if (((AVPlayerItem *)object).status == AVPlayerItemStatusReadyToPlay) {
            NvConfigAudioSession();
        } 
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

/// AVAudioPlayer 在播放之后直接修改Audio Session即可。
@implementation NvCustomAudioPlayer

- (BOOL)play {
    BOOL isPlay = [super play];
    [self prepareToPlay];
    NvConfigAudioSession();
    return isPlay;
}

- (BOOL)playAtTime:(NSTimeInterval)time {
    BOOL isPlay = [super playAtTime:time];
    NvConfigAudioSession();
    return isPlay;
}

- (void)setRate:(float)rate {
    [super setRate:rate];
    if (rate > 0) {
        NvConfigAudioSession();
    }
}

@end
