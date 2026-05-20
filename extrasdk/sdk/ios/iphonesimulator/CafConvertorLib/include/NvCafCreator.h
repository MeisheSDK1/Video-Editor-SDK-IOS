//
//  NvCafCreator.h
//  gif
//
//  Created by 刘铁华 on 2019/3/6.
//  Copyright © 2019年 刘东旭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef struct {
    int num;
    int den;
} SNvRational;

typedef enum {
    NvCafLoopMode_Invalid = -1,
    NvCafLoopMode_None,
    NvCafLoopMode_Repeat,
    NvCafLoopMode_Mirror,
    NvCafLoopMode_RepeatLastFrame,
    NvCafLoopMode_Count
} NvCafLoopMode;

typedef enum {
    NvCafImageFormat_Invalid = -1,
    NvCafImageFormat_JPG,
    NvCafImageFormat_PNG,
    NvCafImageFormat_Count
} NvCafImageFormat;

typedef enum {
    NvCafCreateStatusUnknow = -1,
    NvCafCreateStatusFinish,
    NvCafCreateStatusRunning,
    NvCafCreateStatusSourceFileNotExist,
    NvCafCreateStatusGifNotSupport,
    NvCafCreateStatusParamInvalid
} NvCafCreateStatus;

NS_ASSUME_NONNULL_BEGIN
@class NvCafCreator;
@protocol NvCafCreatorDelegate <NSObject>

/**
 处理单独帧委托方法

 @param creator self
 @param image 单独帧image
 */
- (void)cafCreator:(NvCafCreator *)creator convertUIImage:(UIImage*)image;

/**
 转码结束委托方法

 @param creator self
 @param finished 是否转换成功
 */
- (void)cafCreator:(NvCafCreator *)creator convertFinished:(BOOL)finished;

@end

@interface NvCafCreator : NSObject
@property (nonatomic, weak) id<NvCafCreatorDelegate> delegate;
@property(nonatomic) NSInteger tag;

- (instancetype)init;

/**
 结束caf文件编码

 @return 是否完成
 */
- (BOOL)finishEncode;

/**
 获取生成caf文件时长

 @return caf文件时长
 */
- (int)getCafDuration;

/**
 执行处理起始方法

 @return 转码状态
 */
- (NvCafCreateStatus)start;

/**
 获取转码状态

 @return 转码状态
 */
- (NvCafCreateStatus)getConvertStatus;

/**
 编码caf图像数据

 @param imageData 图像数据
 @param imageDurationMS 相应的时长（单位ms）
 @return 是否编码成功
 */
- (BOOL)encodeImageData:(NSData*)imageData imageDurationMS:(long)imageDurationMS;

/**
 开始caf编码

 @param targetCafFilePath 目标文件路径
 @param width 目标图像宽度
 @param height 目标图像高度
 @param format 图像格式
 @param frameRate 编码帧率
 @param pixelAsprectRatio 像素比
 @param loopMode 循环模式
 @return 是否成功
 */
- (BOOL)startCafEncoder:(NSString*)targetCafFilePath width:(int)width height:(int)height format:(int)format frameRate:(SNvRational)frameRate pixelAsprectRatio:(SNvRational)pixelAsprectRatio loopMode:(int)loopMode;

/**
 转码配置方法

 @param originFilePath 源文件地址
 @param targetCafFilePath 目标文件地址
 @param width 目标文件生成宽度
 @param height 目标文件生成高度
 @param format 格式
 @param frameRate 编码帧率
 @param pixelAsprectRatio 像素比
 @param loopMode 循环模式
 */
-(void)convertFilePath:(NSString*)originFilePath targetCafFilePath:(NSString*)targetCafFilePath width:(int)width height:(int)height format:(int)format frameRate:(SNvRational)frameRate pixelAsprectRatio:(SNvRational)pixelAsprectRatio loopMode:(int)loopMode;

@end

NS_ASSUME_NONNULL_END
