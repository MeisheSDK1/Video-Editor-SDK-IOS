//
//  NvAudioPlayer.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/3.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NvAudioPlayer;

@protocol NvAudioPlayerDelegate

- (void)nvAudioPlayer:(NvAudioPlayer *)player currentTime:(double)currentTime;
- (void)nvAudioPlayerPlayEOF:(NvAudioPlayer *)player;

@end

@interface NvAudioPlayer : NSObject

@property (nonatomic, assign, readonly)float duration;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign, readonly)float currentTime;


/// 设置播放url
/// Set the play url
/// - Parameter urlString: url
- (void)setUrlString:(NSString *)urlString;
- (void)seekToTime:(float)time;
- (void)play;
- (void)pause;
- (void)rate:(float)rate;
- (void)setVolume:(float)volume;

@end
