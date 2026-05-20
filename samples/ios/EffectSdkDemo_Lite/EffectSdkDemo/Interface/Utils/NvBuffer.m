//
//  NvBuffer.m
//  EffectSdkDemo
//
//  Created by ms20180425 on 2020/5/12.
//  Copyright © 2020 美摄. All rights reserved.
//

#import "NvBuffer.h"
#import <CoreVideo/CoreVideo.h>

@implementation NvBuffer

#pragma mark 根据传入的比例进行buffer裁剪
//The buffer is trimmed according to the ratio passed in
+ (CVPixelBufferRef)modifyImage:(CMSampleBufferRef)sampleBuffer withProportion:(CGFloat)proportion{
    @synchronized (self) {
        
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        // Lock the image buffer
        CVPixelBufferLockBaseAddress(imageBuffer,kCVPixelBufferLock_ReadOnly);
        // Get information about the image
        void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
        
        CVPixelBufferRef pxbuffer;
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                                 [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                                 nil];
        
        NSInteger tempWidth = (NSInteger) (width);
        NSInteger tempHeight = (NSInteger) (height);
        if (proportion == 1) {
            tempHeight = tempWidth;
        }
        
        NSInteger baseAddressStart = 0;
        if (proportion == 1) {
           baseAddressStart = (height + width)/2.0 * tempWidth;
        }
        
        CVReturn status = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, tempWidth, tempHeight, kCVPixelFormatType_32BGRA, &baseAddress[baseAddressStart], bytesPerRow, NULL, NULL, (CFDictionaryRef)CFBridgingRetain(options), &pxbuffer);

        if (status != 0) {
            CVPixelBufferUnlockBaseAddress(imageBuffer,kCVPixelBufferLock_ReadOnly);
            return NULL;
        }

        CVPixelBufferUnlockBaseAddress(imageBuffer,kCVPixelBufferLock_ReadOnly);

        return pxbuffer;
    }
}

#pragma mark 根据传入的图片，输出对应的buffer
//Based on the image passed in, the corresponding buffer is output
+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image{
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    
    if (frameSize.width == 2316 && frameSize.height == 2316) {
        frameSize.width = 2320;
        frameSize.height = 2320;
    }else if (frameSize.width == 1836 && frameSize.height == 1836){
        frameSize.width = 1840;
        frameSize.height = 1840;
    }else if (frameSize.width == 2376 && frameSize.height == 2376){
        frameSize.width = 2384;
        frameSize.height = 2384;
    }else if (frameSize.width == 1908 && frameSize.height == 1908){
        frameSize.width = 1920;
        frameSize.height = 1920;
    }
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height,  kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    size_t bytesPerRow = 4*frameSize.width;
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                                  frameSize.height, 8,bytesPerRow , rgbColorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, frameSize.width,
                                           frameSize.height), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

#pragma mark 根据传入的buffer，输出图片
//Based on the buffer passed in, print out the image
+ (UIImage*)uiImageFromPixelBuffer:(CVPixelBufferRef)inputPixelBuffer{
    //    OSType pixelFormat = CVPixelBufferGetPixelFormatType(inputPixelBuffer);
    size_t width = CVPixelBufferGetWidth(inputPixelBuffer);
    size_t height = CVPixelBufferGetHeight(inputPixelBuffer);
    CIImage* ciImage = [CIImage imageWithCVPixelBuffer:inputPixelBuffer];
    CIContext* context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
    CGRect rect = CGRectMake(0, 0, width, height);
    CGImageRef videoImage = [context createCGImage:ciImage fromRect:rect];
    UIImage* image = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    return image;
}

#pragma mark 根据传入的buffer，输出图片
//Based on the buffer passed in, print out the image
+ (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef{
    
    CVPixelBufferLockBaseAddress(pixelBufferRef, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(pixelBufferRef);
    size_t width = CVPixelBufferGetWidth(pixelBufferRef);
    size_t height = CVPixelBufferGetHeight(pixelBufferRef);
    size_t bufferSize = CVPixelBufferGetDataSize(pixelBufferRef);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBufferRef, 0);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, rgbColorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault, provider, NULL, true, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(rgbColorSpace);
    
    CVPixelBufferUnlockBaseAddress(pixelBufferRef, 0);
    
    return image;
}

@end
