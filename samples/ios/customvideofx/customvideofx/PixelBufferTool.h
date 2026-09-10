//
//  PixelBufferTool.h
//  NvCompositionDemo
//
//  Created by 美摄 on 2021/11/30.
//

#import <Foundation/Foundation.h>
#import "NvsCustomVideoFx.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PixelBufferTool : NSObject

+ (CVPixelBufferRef)convertRGBAToBGRA:(CVPixelBufferRef)pixelBuffer;

+ (CVPixelBufferRef)rotatePixelBuffer:(CVPixelBufferRef)pixelBuffer
                      displayRotation:(int)displayRotation
                     flipHorizontally:(BOOL)flipHorizontally
              applyFlipBeforeRotation:(BOOL)applyFlipBeforeRotation;

+ (CVPixelBufferRef)pixelBufferWithVideoFrame:(NvsVideoFrameInfo)inputBuddyVideoFrame;

+ (CVPixelBufferRef)copyPixelBufferWithVideoFrame:(NvsVideoFrameInfo)inputBuddyVideoFrame;

+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image;

+ (UIImage*)imageFromPixelBuffer:(CVPixelBufferRef)buffer;
+ (CVPixelBufferRef)create32BGRAPixelBufferFromNV12:(CVPixelBufferRef)nv12PixelBuffer;
+ (CVPixelBufferRef)createPixelBuffer:(CVPixelBufferRef)pixelBuffer rotation:(float)rotation;
+ (CVPixelBufferRef)createPixelBuffer:(CVPixelBufferRef)pixelBuffer scale:(float)scale;

+ (UIImage*)imageFromVideoFrame:(NvsVideoFrameInfo)videoFrame;

+ (void)fillVideoFrameInfoFromPixelBuffer:(CVPixelBufferRef)inputImage
                           videoFrameInfo:(NvsVideoFrameInfo *)frameInfo;

+ (void)convertUpsideDownTextureToBottomUp:(GLuint)inputTextureID
                                    output:(GLuint)outputTextureID
                                     width:(GLsizei)width
                                    height:(GLsizei)height;

@end

NS_ASSUME_NONNULL_END
