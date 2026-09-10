//
//  NvMusicLrc.h
//  NvMusicLyricsLib
//
//  Created by ms20180425 on 2019/3/21.
//  Copyright © 2019年 ms20180425. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvLyricCaptionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvMusicLrc : NSObject

/**
 传入音乐的裁入点和裁出点，歌词字幕数组

 @param path 歌词文件路径
 @param trimIn 音乐的裁入点
 @param trimOut 音乐的裁出点
 @param duration 音乐未裁剪的总时长
 @return 歌词字幕数组
 */
- (NSMutableArray *)configMusicPath:(NSString *)path withTrimIn:(int64_t)trimIn withTrimOut:(int64_t)trimOut withduration:(int64_t)duration;


/**
 获取原始歌词字幕数组

 @return 返回歌词字幕数组
 */
- (NSMutableArray *)getMusicLrc;

@end

NS_ASSUME_NONNULL_END
