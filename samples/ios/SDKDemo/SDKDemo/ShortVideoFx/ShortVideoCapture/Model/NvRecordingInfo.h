//
//  NvRecordingInfo.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/9/5.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsVideoClip.h"
@import Photos;

@interface NvRecordingInfo : NSObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) NvsExtraVideoRotation rotaion;
@property (nonatomic, strong) NSString *recordingPath;
@property (nonatomic, strong) NSString *convertPath;
@property (nonatomic, assign) int64_t trimIn,trimOut;
///每段录制时音乐播放的结束时间点
///The end point in time for music playback during each recording
@property (nonatomic, assign) float musicEndPos;
///每段录制时音乐播放的开始时间点
///The point at which the music starts to play during each recording
@property (nonatomic, assign) float musicStartPos;
///每段录制的速度
///The speed of each recording
@property (nonatomic, assign) float speed;
@property (nonatomic, assign) BOOL isRecordSuccess;

@end
