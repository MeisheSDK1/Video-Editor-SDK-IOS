//
//  NvBuffer.h
//  EffectSdkDemo
//
//  Created by ms20180425 on 2020/5/12.
//  Copyright © 2020 美摄. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvBuffer : NSObject
///Trim the buffer according to the ratio passed in
/// 根据传入比例裁剪buffer
/// @param sampleBuffer 传入的原始sampleBuffer
/// @param proportion 传入的裁剪比例
+ (CVPixelBufferRef)modifyImage:(CMSampleBufferRef)sampleBuffer withProportion:(CGFloat)proportion;
/// Based on the image passed in, the corresponding buffer is output
/// 根据传入的图片，输出对应的buffer
/// @param image 图片
+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image;
/// Based on the buffer passed in, print out the image
/// 根据传入的buffer，输出图片
/// @param buffer buffer
+ (UIImage*)uiImageFromPixelBuffer:(CVPixelBufferRef)buffer;
/// Based on the buffer passed in, print out the image
/// 根据传入的buffer，输出图片
/// @param pixelBufferRef buffer
+ (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef;

@end

NS_ASSUME_NONNULL_END
