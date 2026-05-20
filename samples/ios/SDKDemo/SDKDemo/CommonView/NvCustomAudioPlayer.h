//
//  NvCustomAudioPlayer.h
//  XBEchoCancellationTest
//
//  Created by Mac-Mini on 2024/5/25.
//  Copyright © 2024 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFAudio/AVAudioPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvCustomPlayer : AVPlayer

@property(readonly, getter=isPlaying) BOOL playing;

@end

@interface NvCustomAudioPlayer : AVAudioPlayer

@end

NS_ASSUME_NONNULL_END
