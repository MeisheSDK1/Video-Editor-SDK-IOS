//
//  NvFileConvert.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/9/6.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvRecordingInfo.h"

@interface NvFileConvert : NSObject

/// 设置需要转码的视频文件信息
/// set the files that will be converted
/// @param files 需要转码的视频文件信息
/// the files that will be converted
- (void)convertFiles:(NSArray <NvRecordingInfo *>*)files;

/// 开始转码
/// start to convert
- (void)startConvert;

/// 结束转码回调方法
/// the call back block of ending convert
/// @param finishBlock 转码完成回调
/// the call back block of ending convert
- (void)finishBlock:(void(^)(BOOL isFinish))finishBlock;


/// 取消转码
/// cancel converting
- (void)cancel;

@end
