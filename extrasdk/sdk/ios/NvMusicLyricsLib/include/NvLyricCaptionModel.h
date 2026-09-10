//
//  NvLyricCaptionModel.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NvLyricCaptionModel : NSObject

@property (nonatomic, strong) NSString *captionText;    //歌词字幕
@property (nonatomic, assign) int64_t startTime;        //歌词字幕开始时间
@property (nonatomic, assign) int64_t continuousTime;   //歌词字幕持续时间
@property (nonatomic, assign) int64_t inPoint;          //歌词字幕在时间线上的入点
@property (nonatomic, assign) int64_t duration;         //歌词字幕在时间线上的持续时间

@end

