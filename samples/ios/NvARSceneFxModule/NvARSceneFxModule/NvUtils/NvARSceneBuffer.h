//
//  NvARSceneBuffer.h
//  NvTest
//
//  Created by ms20180425 on 2022/8/19.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvARSceneBuffer : NSObject

/// 根据传入比例裁剪buffer
/// Trim the buffer according to the ratio passed in
/// @param sampleBuffer 传入的原始sampleBuffer
/// @param proportion 传入的裁剪比例
+ (CVPixelBufferRef)modifyImage:(CMSampleBufferRef)sampleBuffer withProportion:(CGFloat)proportion;

/// 根据传入的图片，输出对应的buffer
/// Based on the image passed in, the corresponding buffer is output
/// @param image 图片
+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image;

/// 根据传入的buffer，输出图片
/// Based on the buffer passed in, print out the image
/// @param buffer buffer
+ (UIImage*)uiImageFromPixelBuffer:(CVPixelBufferRef)buffer;

/// 根据传入的buffer，输出图片
/// Based on the buffer passed in, print out the image
/// @param pixelBufferRef buffer
+ (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef;


@end

NS_ASSUME_NONNULL_END
