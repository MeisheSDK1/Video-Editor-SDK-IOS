//
//  PixelBufferTool.m
//  NvCompositionDemo
//
//  Created by 美摄 on 2021/11/30.
//

#import "PixelBufferTool.h"
#import <CoreImage/CoreImage.h>
#import <OpenGLES/ES2/gl.h>
#import <Accelerate/Accelerate.h>

@implementation PixelBufferTool

+ (CVPixelBufferRef)pixelBufferWithVideoFrame:(NvsVideoFrameInfo)inputBuddyVideoFrame {
    if (inputBuddyVideoFrame.pixelFormat == NvsPixelFormat_Nv12) {
        size_t width = inputBuddyVideoFrame.frameWidth;
        size_t height = inputBuddyVideoFrame.frameHeight;
        CVPixelBufferRef pixelBuffer = nil;
        @autoreleasepool {
            size_t bytesPerRow0 = inputBuddyVideoFrame.planeRowPitch[0];
            size_t bytesPerRow1 = inputBuddyVideoFrame.planeRowPitch[1];
            size_t by[2] = {bytesPerRow0,bytesPerRow1};
            
            size_t widthPlan[2] = {width, width};
            
            size_t height0 = height;
            size_t height1 = height/2;
            size_t heightPlan[2] = {height0, height1};
            
            void * address0 = inputBuddyVideoFrame.planePtr[0];
            
            NSDictionary *pixelAttributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                                         @(width), kCVPixelBufferWidthKey,
                                                         @(height), kCVPixelBufferHeightKey,
                                                         @{},kCVPixelBufferIOSurfacePropertiesKey,
                                                         nil];
            
            size_t dataSize = width*height;
            
            CVPixelBufferCreateWithPlanarBytes(NULL, width, height, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, address0, dataSize, 2, inputBuddyVideoFrame.planePtr, widthPlan, heightPlan, by, nil, nil, (__bridge CFDictionaryRef)pixelAttributes, &pixelBuffer);
            CVBufferSetAttachment(pixelBuffer, kCVImageBufferColorPrimariesKey, kCVImageBufferColorPrimaries_ITU_R_709_2, kCVAttachmentMode_ShouldPropagate);
            CVBufferSetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, kCVImageBufferYCbCrMatrix_ITU_R_601_4, kCVAttachmentMode_ShouldPropagate);
            CVBufferSetAttachment(pixelBuffer, kCVImageBufferTransferFunctionKey, kCVImageBufferTransferFunction_ITU_R_709_2, kCVAttachmentMode_ShouldPropagate);
            
        }
        return pixelBuffer;
    }
//    else if (inputBuddyVideoFrame.pixelFormat == NvsPixelFormat_BGRA ||
//              inputBuddyVideoFrame.pixelFormat == NvsPixelFormat_RGBA) {
//        size_t width = inputBuddyVideoFrame.frameWidth;
//        size_t height = inputBuddyVideoFrame.frameHeight;
//        CVPixelBufferRef pixelBuffer = nil;
//        OSType format = kCVPixelFormatType_32BGRA;
//        // 不支持创建kCVPixelFormatType_32RGBA
//        NSDictionary *pixelAttributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:format], kCVPixelBufferPixelFormatTypeKey,
//                                                     @(width), kCVPixelBufferWidthKey,
//                                                     @(height), kCVPixelBufferHeightKey,
//                                                     @{},kCVPixelBufferIOSurfacePropertiesKey,
//                                                     nil];
//        
//        CVReturn ret =CVPixelBufferCreateWithBytes(NULL, width, height, format, inputBuddyVideoFrame.planePtr[0], inputBuddyVideoFrame.planeRowPitch[0], nil, nil, (__bridge CFDictionaryRef)pixelAttributes, &pixelBuffer);
//        
//        CVBufferSetAttachment(pixelBuffer, kCVImageBufferColorPrimariesKey, kCVImageBufferColorPrimaries_ITU_R_709_2, kCVAttachmentMode_ShouldPropagate);
//        CVBufferSetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, kCVImageBufferYCbCrMatrix_ITU_R_601_4, kCVAttachmentMode_ShouldPropagate);
//        CVBufferSetAttachment(pixelBuffer, kCVImageBufferTransferFunctionKey, kCVImageBufferTransferFunction_ITU_R_709_2, kCVAttachmentMode_ShouldPropagate);
//        return pixelBuffer;
//    }
    
    return nil;
}


+ (CVPixelBufferRef)copyPixelBufferWithVideoFrame:(NvsVideoFrameInfo)inputBuddyVideoFrame {
    if (inputBuddyVideoFrame.pixelFormat == NvsPixelFormat_Nv12) {
        size_t width = inputBuddyVideoFrame.frameWidth;
        size_t height = inputBuddyVideoFrame.frameHeight;
        CVPixelBufferRef pixelBuffer = nil;
        size_t bytesPerRow0 = width;
        size_t bytesPerRow1 = width;
        size_t by[2] = {bytesPerRow0,bytesPerRow1};
        
        size_t width0 = inputBuddyVideoFrame.planeRowPitch[0];
        size_t width1 = inputBuddyVideoFrame.planeRowPitch[0];
        size_t widthPlan[2] = {width0,width1};
        
        size_t height0 = height;
        size_t height1 = height/2;
        size_t heightPlan[2] = {height0,height1};
        
        NSDictionary *pixelAttributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                         @(width), kCVPixelBufferWidthKey,
                                         @(height), kCVPixelBufferHeightKey,
                                         @{},kCVPixelBufferIOSurfacePropertiesKey,
                                         nil];
        
        
        CVReturn status = CVPixelBufferCreateWithPlanarBytes(kCFAllocatorDefault, width, height, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, NULL, 0, 2, inputBuddyVideoFrame.planePtr, widthPlan, heightPlan, by, nil, nil, (__bridge CFDictionaryRef)pixelAttributes, &pixelBuffer);
        if (status != kCVReturnSuccess) {
            return nil;
        }
        CVBufferSetAttachment(pixelBuffer, kCVImageBufferColorPrimariesKey, kCVImageBufferColorPrimaries_ITU_R_709_2, kCVAttachmentMode_ShouldPropagate);
        CVBufferSetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, kCVImageBufferYCbCrMatrix_ITU_R_601_4, kCVAttachmentMode_ShouldPropagate);
        CVBufferSetAttachment(pixelBuffer, kCVImageBufferTransferFunctionKey, kCVImageBufferTransferFunction_ITU_R_709_2, kCVAttachmentMode_ShouldPropagate);
        
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        void *yPixelBufferData = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        uint8_t *srcLine = inputBuddyVideoFrame.planePtr[0];
        uint8_t *dstLine = (uint8_t *)yPixelBufferData;
        unsigned int row = inputBuddyVideoFrame.planeRowPitch[0]*inputBuddyVideoFrame.frameHeight;
        memcpy(dstLine, srcLine, row);
        CVPixelBufferGetBytesPerRowOfPlane (pixelBuffer, 1);
        void *uvPixelBufferData = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        size_t pitch1 = inputBuddyVideoFrame.planeRowPitch[1];//
        uint8_t *uvsrcLine = inputBuddyVideoFrame.planePtr[1];
        uint8_t *uvdstLine = (uint8_t *)uvPixelBufferData;
        size_t uvrow = pitch1*inputBuddyVideoFrame.frameHeight/2;
        memcpy(uvdstLine, uvsrcLine, uvrow);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        
        return pixelBuffer;
    }
    
    return nil;
}

+ (CVPixelBufferRef)convertRGBAToBGRA:(CVPixelBufferRef)pixelBuffer {
    // 获取输入的宽度、高度和像素数据
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);

    if (pixelFormat != kCVPixelFormatType_32RGBA && pixelFormat != kCVPixelFormatType_32BGRA) {
        // 确保像素格式为 RGBA
        return NULL;
    }

    // 锁定基址，以便访问像素数据
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    uint8_t *srcBaseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
    size_t srcBytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);

    // 创建一个新的 CVPixelBufferRef 用于存储 BGRA 数据
    CVPixelBufferRef bgraBuffer = NULL;
    NSDictionary *pixelAttributes = @{(__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey: @{}};
    CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)pixelAttributes, &bgraBuffer);

    // 锁定目标基址
    CVPixelBufferLockBaseAddress(bgraBuffer, 0);
    uint8_t *destBaseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(bgraBuffer);
    size_t destBytesPerRow = CVPixelBufferGetBytesPerRow(bgraBuffer);

    // 遍历像素数据，将 RGBA 转换为 BGRA
    for (size_t y = 0; y < height; y++) {
        for (size_t x = 0; x < width; x++) {
            // 获取源像素位置（RGBA）
            uint8_t *srcPixel = srcBaseAddress + y * srcBytesPerRow + x * 4;  // 每个像素 4 字节 (RGBA)

            // 获取目标像素位置（BGRA）
            uint8_t *destPixel = destBaseAddress + y * destBytesPerRow + x * 4;  // 每个像素 4 字节 (BGRA)

            // 将 R 和 B 通道交换，G 和 A 保持不变
            destPixel[0] = srcPixel[2];  // B <- R
            destPixel[1] = srcPixel[1];  // G <- G
            destPixel[2] = srcPixel[0];  // R <- B
            destPixel[3] = srcPixel[3];  // A <- A
        }
    }

    // 解锁像素缓冲区
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    CVPixelBufferUnlockBaseAddress(bgraBuffer, 0);

    // 返回转换后的 BGRA 格式的像素缓冲区
    return bgraBuffer;
}

+ (CVPixelBufferRef)create32BGRAPixelBufferFromNV12:(CVPixelBufferRef)nv12PixelBuffer {
    CVPixelBufferLockBaseAddress(nv12PixelBuffer, 0);
    
    size_t width = CVPixelBufferGetWidth(nv12PixelBuffer);
    size_t height = CVPixelBufferGetHeight(nv12PixelBuffer);
    
    // 创建 ARGB 格式的像素缓冲区
    NSDictionary *options = @{ (NSString *)kCVPixelBufferCGImageCompatibilityKey: @YES,
                               (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES };
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)options, &pixelBuffer);
    if (result != kCVReturnSuccess) {
        NSLog(@"Error: Unable to create BGRA pixel buffer");
        return NULL;
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    size_t aRgbPitch = CVPixelBufferGetBytesPerRow(pixelBuffer);
    // 获取 BGRA 分量的基地址
    uint8_t *argbBaseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    // 转换 NV12 到 BGRA
    uint8_t *yBuffer = CVPixelBufferGetBaseAddressOfPlane(nv12PixelBuffer, 0);
    size_t yPitch = CVPixelBufferGetBytesPerRowOfPlane(nv12PixelBuffer, 0);
    uint8_t *cbCrBuffer = CVPixelBufferGetBaseAddressOfPlane(nv12PixelBuffer, 1);
    size_t cbCrPitch = CVPixelBufferGetBytesPerRowOfPlane(nv12PixelBuffer, 1);
    
    vImage_Buffer srcYp = {yBuffer,height,width,yPitch};
    vImage_Buffer srcCbCr = {cbCrBuffer,height,width,cbCrPitch};
    vImage_Buffer dest = {argbBaseAddress,height,width,aRgbPitch};
    
    vImage_YpCbCrPixelRange pixelRange = { 16, 128, 235, 240, 235, 16, 240, 16 };
    vImage_YpCbCrToARGB infoYpCbCrToARGB = { };
    
    vImage_Error error = vImageConvert_YpCbCrToARGB_GenerateConversion(kvImage_YpCbCrToARGBMatrix_ITU_R_709_2,
                                                                       &pixelRange,
                                                                       &infoYpCbCrToARGB,
                                                                       kvImage420Yp8_CbCr8,
                                                                       kvImageARGB8888,
                                                                       kvImageNoFlags);
//    uint8_t permuteMap[4] = {0, 1, 2, 3};
    uint8_t permuteMap[4] = {3, 2, 1, 0};
    error = vImageConvert_420Yp8_CbCr8ToARGB8888(&srcYp, &srcCbCr, &dest, &infoYpCbCrToARGB, permuteMap, 255, kvImageNoFlags);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CVPixelBufferUnlockBaseAddress(nv12PixelBuffer, 0);
    return pixelBuffer;
}

+ (CVPixelBufferRef)createPixelBuffer:(CVPixelBufferRef)pixelBuffer rotation:(float)rotation {
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    size_t rowPitch = CVPixelBufferGetBytesPerRow(pixelBuffer);
    void *srcAddr = CVPixelBufferGetBaseAddress(pixelBuffer);
    vImage_Buffer src = {srcAddr,height,width,rowPitch};
    
    // 创建 BGRA 格式的像素缓冲区
    NSDictionary *options = @{ (NSString *)kCVPixelBufferCGImageCompatibilityKey: @YES,
                               (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES };
    CVPixelBufferRef dstPixelBuffer = NULL;
    if (fabs(rotation) - M_PI_2 < 0.1 || fabs(rotation) - 3*M_PI_2 < 0.1) {
        width = CVPixelBufferGetHeight(pixelBuffer);
        height = CVPixelBufferGetWidth(pixelBuffer);
    }
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)options, &dstPixelBuffer);
    if (result == kCVReturnSuccess) {
        CVPixelBufferLockBaseAddress(dstPixelBuffer, 0);
        size_t width = CVPixelBufferGetWidth(dstPixelBuffer);
        size_t height = CVPixelBufferGetHeight(dstPixelBuffer);
        size_t rowPitch = CVPixelBufferGetBytesPerRow(dstPixelBuffer);
        void *destAddr = CVPixelBufferGetBaseAddress(dstPixelBuffer);
        vImage_Buffer dst = {destAddr,height,width,rowPitch};
        Pixel_8888 color = {0, 0, 0, 0};
        vImageRotate_ARGB8888(&src, &dst, nil, rotation, color, kvImageNoFlags);
        CVPixelBufferLockBaseAddress(dstPixelBuffer, 0);
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return dstPixelBuffer;
}

+ (CVPixelBufferRef)rotatePixelBuffer:(CVPixelBufferRef)pixelBuffer
                      displayRotation:(int)displayRotation
                     flipHorizontally:(BOOL)flipHorizontally
              applyFlipBeforeRotation:(BOOL)applyFlipBeforeRotation {
    // 获取输入的宽度、高度和像素数据
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    
    if (pixelFormat != kCVPixelFormatType_32BGRA) {
        // 确保像素格式为 BGRA
        return NULL;
    }

    // 锁定基址，以便访问像素数据
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    uint8_t *srcBaseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
    size_t srcBytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);

    // 目标宽度和高度（旋转90度或270度时交换宽高）
    size_t destWidth = (displayRotation == 90 || displayRotation == 270) ? height : width;
    size_t destHeight = (displayRotation == 90 || displayRotation == 270) ? width : height;

    // 创建一个新的 CVPixelBufferRef 用于存储旋转后的数据
    CVPixelBufferRef rotatedBuffer = NULL;
    NSDictionary *pixelAttributes = @{(__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey: @{}};
    CVPixelBufferCreate(kCFAllocatorDefault, destWidth, destHeight, pixelFormat, (__bridge CFDictionaryRef)pixelAttributes, &rotatedBuffer);

    // 锁定目标基址
    CVPixelBufferLockBaseAddress(rotatedBuffer, 0);
    uint8_t *destBaseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(rotatedBuffer);
    size_t destBytesPerRow = CVPixelBufferGetBytesPerRow(rotatedBuffer);

    // 进行翻转和旋转的顺序控制
    bool flipFirst = applyFlipBeforeRotation;
    
    // 根据翻转和旋转的顺序处理像素拷贝
    for (size_t y = 0; y < height; y++) {
        for (size_t x = 0; x < width; x++) {
            // 获取源像素位置
            uint8_t *srcPixel = srcBaseAddress + y * srcBytesPerRow + x * 4;  // 4 字节/像素

            // 目标像素
            uint8_t *destPixel = NULL;

            // 计算翻转逻辑
            size_t newX = flipHorizontally ? (width - x - 1) : x;
            size_t newY = y;

            if (flipFirst) {
                // 先进行水平翻转再进行旋转
                switch (displayRotation) {
                    case 0:  // 无需旋转，只水平翻转
                        destPixel = destBaseAddress + newY * destBytesPerRow + newX * 4;
                        break;
                    case 90:  // 顺时针旋转 90 度
                        destPixel = destBaseAddress + newX * destBytesPerRow + (height - newY - 1) * 4;
                        break;
                    case 180:  // 顺时针旋转 180 度
                        destPixel = destBaseAddress + (height - newY - 1) * destBytesPerRow + (width - newX - 1) * 4;
                        break;
                    case 270:  // 顺时针旋转 270 度
                        destPixel = destBaseAddress + (width - newX - 1) * destBytesPerRow + newY * 4;
                        break;
                    default:
                        break;
                }
            } else {
                // 先进行旋转再进行水平翻转
                switch (displayRotation) {
                    case 0:  // 无需旋转，只水平翻转
                        destPixel = destBaseAddress + newY * destBytesPerRow + newX * 4;
                        break;
                    case 90:  // 顺时针旋转 90 度
                        destPixel = destBaseAddress + x * destBytesPerRow + (height - y - 1) * 4;
                        break;
                    case 180:  // 顺时针旋转 180 度
                        destPixel = destBaseAddress + (height - y - 1) * destBytesPerRow + (width - x - 1) * 4;
                        break;
                    case 270:  // 顺时针旋转 270 度
                        destPixel = destBaseAddress + (width - x - 1) * destBytesPerRow + y * 4;
                        break;
                    default:
                        break;
                }
                // 在旋转之后进行水平翻转
                destPixel = destBaseAddress + (flipHorizontally ? (destWidth - newX - 1) : newX) * 4 + newY * destBytesPerRow;
            }

            // 拷贝像素数据 (BGRA)
            if (destPixel) {
                destPixel[0] = srcPixel[0];  // B
                destPixel[1] = srcPixel[1];  // G
                destPixel[2] = srcPixel[2];  // R
                destPixel[3] = srcPixel[3];  // A
            }
        }
    }

    // 解锁像素缓冲区
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    CVPixelBufferUnlockBaseAddress(rotatedBuffer, 0);

    // 返回旋转后的像素缓冲区
    return rotatedBuffer;
}

+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
{
    
    NSDictionary *options = @{
                              (NSString*)kCVPixelBufferCGImageCompatibilityKey : @YES,
                              (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                              (NSString*)kCVPixelBufferIOSurfacePropertiesKey: [NSDictionary dictionary]
                              };

    
    CVPixelBufferRef pxbuffer = NULL;
    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           frameWidth,
                                           frameHeight),
                       image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

+ (CVPixelBufferRef)createPixelBuffer:(CVPixelBufferRef)pixelBuffer scale:(float)scale {
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    size_t rowPitch = CVPixelBufferGetBytesPerRow(pixelBuffer);
    void *srcAddr = CVPixelBufferGetBaseAddress(pixelBuffer);
    vImage_Buffer src = {srcAddr,height,width,rowPitch};
    
    size_t w = ((int)(width*scale) + 3) & ~3;
    size_t h = ((int)(height*scale) + 1) & ~1;
    
    // 创建 BGRA 格式的像素缓冲区
    NSDictionary *options = @{ (NSString *)kCVPixelBufferCGImageCompatibilityKey: @YES,
                               (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES };
    CVPixelBufferRef dstPixelBuffer = NULL;
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault, w, h, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)options, &dstPixelBuffer);
    if (result == kCVReturnSuccess) {
        CVPixelBufferLockBaseAddress(dstPixelBuffer, 0);
        size_t width = CVPixelBufferGetWidth(dstPixelBuffer);
        size_t height = CVPixelBufferGetHeight(dstPixelBuffer);
        size_t rowPitch = CVPixelBufferGetBytesPerRow(dstPixelBuffer);
        void *destAddr = CVPixelBufferGetBaseAddress(dstPixelBuffer);
        vImage_Buffer dst = {destAddr,height,width,rowPitch};
        vImageScale_ARGB8888(&src, &dst, nil, kvImageNoFlags);
        CVPixelBufferLockBaseAddress(dstPixelBuffer, 0);
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return dstPixelBuffer;
}

+ (UIImage*)imageFromPixelBuffer:(CVPixelBufferRef)buffer{
    return nil;
}

+ (UIImage*)imageFromVideoFrame:(NvsVideoFrameInfo)videoFrame{
    CVPixelBufferRef buffer = [self pixelBufferWithVideoFrame:videoFrame];
    return [self convert:buffer videoFrame:videoFrame];
}

+ (UIImage *)convert:(CVPixelBufferRef)pixelBuffer videoFrame:(NvsVideoFrameInfo)videoFrame{
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, ciImage, nil];
    [filter setDefaults];
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI*2 - videoFrame.displayRotation/180.f*M_PI);
    if (videoFrame.flipHorizontally) {
        transform = CGAffineTransformScale(transform, -1, 1);
    }
    [filter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    //根据滤镜设置图片
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    CVBufferRelease(pixelBuffer);
    
    return result;
}

+ (void)fillVideoFrameInfoFromPixelBuffer:(CVPixelBufferRef)inputImage 
                           videoFrameInfo:(NvsVideoFrameInfo *)frameInfo
{
    OSType pixelFormat = CVPixelBufferGetPixelFormatType(inputImage);
    unsigned int width = (unsigned int)CVPixelBufferGetWidth(inputImage);
    unsigned int height = (unsigned int)CVPixelBufferGetHeight(inputImage);
    frameInfo->frameWidth = width;
    frameInfo->frameHeight = height;
    
    frameInfo->flipHorizontally = NO;
    
    if (pixelFormat == kCVPixelFormatType_32BGRA) {
        frameInfo->pixelFormat = NvsPixelFormat_BGRA;
        frameInfo->isFullRangeYUV = true;
        frameInfo->isRec601 = NO;
        frameInfo->displayRotation = 0;
    } else if (pixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        frameInfo->pixelFormat = NvsPixelFormat_Nv12;
        frameInfo->isFullRangeYUV = false;
        frameInfo->isRec601 = NO;
        frameInfo->displayRotation = 0;
    } else if (pixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        frameInfo->pixelFormat = NvsPixelFormat_Nv12;
        frameInfo->isFullRangeYUV = true;
        frameInfo->isRec601 = NO;
        frameInfo->displayRotation = 0;
    }
    for (int i = 0; i<4; i++) {
        frameInfo->planePtr[i] = NULL;
        frameInfo->planeRowPitch[i] = 0;
    }
    if (!CVPixelBufferIsPlanar(inputImage)) {
        frameInfo->planePtr[0] = CVPixelBufferGetBaseAddress(inputImage);
        frameInfo->planeRowPitch[0] = (int)CVPixelBufferGetBytesPerRow(inputImage);
    } else {
        for (int p = 0; p < CVPixelBufferGetPlaneCount(inputImage); p++) {
            void *ptr = CVPixelBufferGetBaseAddressOfPlane(inputImage, p);
            if (ptr == NULL) {
                NSLog(@"---");
            }
            frameInfo->planePtr[p] = ptr;
            frameInfo->planeRowPitch[p] = (int)CVPixelBufferGetBytesPerRowOfPlane(inputImage, p);
        }
    }
}

+ (CVPixelBufferRef)convertNv12ToBgra:(CVPixelBufferRef)nv12PixelBuffer {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:nv12PixelBuffer];
    
    // 创建一个CIContext来渲染CIImage
    CIContext *context = [CIContext contextWithOptions:nil];
    
    // 输出的BGRA格式的PixelBuffer
    CVPixelBufferRef bgraPixelBuffer = NULL;
    
    // 配置目标PixelBuffer的属性
    NSDictionary *outputPixelBufferAttributes = @{
        (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
        (NSString *)kCVPixelBufferWidthKey : @(CVPixelBufferGetWidth(nv12PixelBuffer)),
        (NSString *)kCVPixelBufferHeightKey : @(CVPixelBufferGetHeight(nv12PixelBuffer)),
        (NSString *)kCVPixelBufferIOSurfacePropertiesKey : @{}
    };
    
    // 创建目标PixelBuffer
    CVPixelBufferCreate(kCFAllocatorDefault,
                        CVPixelBufferGetWidth(nv12PixelBuffer),
                        CVPixelBufferGetHeight(nv12PixelBuffer),
                        kCVPixelFormatType_32BGRA,
                        (__bridge CFDictionaryRef)outputPixelBufferAttributes,
                        &bgraPixelBuffer);
    
    if (bgraPixelBuffer) {
        // 渲染CIImage到目标PixelBuffer
        [context render:ciImage toCVPixelBuffer:bgraPixelBuffer];
    }
    
    return bgraPixelBuffer;
}

// 顶点着色器代码
const GLchar *vertexShaderSource =
"#version 100\n"
"attribute vec4 position;\n"
"attribute vec2 texCoord;\n"
"varying vec2 vTexCoord;\n"
"void main() {\n"
"    gl_Position = position;\n"
"    vTexCoord = texCoord;\n"
"}\n";

// 片段着色器代码
const GLchar *fragmentShaderSource =
"#version 100\n"
"precision mediump float;\n"
"varying vec2 vTexCoord;\n"
"uniform sampler2D texture;\n"
"void main() {\n"
"    gl_FragColor = texture2D(texture, vTexCoord);\n"
"}\n";

// 将上下颠倒的纹理转换为从底部向上的纹理，并将结果写入指定的输出纹理
+ (void)convertUpsideDownTextureToBottomUp:(GLuint)inputTextureID
                                    output:(GLuint)outputTextureID
                                     width:(GLsizei)width
                                    height:(GLsizei)height {
    // 创建和编译顶点着色器
    GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
    glCompileShader(vertexShader);

    // 创建和编译片段着色器
    GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
    glCompileShader(fragmentShader);

    // 创建着色器程序并链接
    GLuint shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);

    // 使用着色器程序
    glUseProgram(shaderProgram);

    // 定义顶点数据和纹理坐标
    GLfloat vertices[] = {
        -1.0f, -1.0f, 0.0f, 0.0f, 1.0f,  // 左下角
         1.0f, -1.0f, 0.0f, 1.0f, 1.0f,  // 右下角
        -1.0f,  1.0f, 0.0f, 0.0f, 0.0f,  // 左上角
         1.0f,  1.0f, 0.0f, 1.0f, 0.0f   // 右上角
    };

    // 创建顶点缓冲对象 (VBO)
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    // 获取顶点属性位置
    GLint posAttrib = glGetAttribLocation(shaderProgram, "position");
    glEnableVertexAttribArray(posAttrib);
    glVertexAttribPointer(posAttrib, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), 0);

    // 获取纹理坐标属性位置
    GLint texAttrib = glGetAttribLocation(shaderProgram, "texCoord");
    glEnableVertexAttribArray(texAttrib);
    glVertexAttribPointer(texAttrib, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (void*)(3 * sizeof(GLfloat)));

    // 绑定输出纹理到帧缓冲对象
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, outputTextureID, 0);

    // 设置视口大小为纹理大小
    glViewport(0, 0, width, height);

    // 清除帧缓冲区
    glClear(GL_COLOR_BUFFER_BIT);

    // 激活并绑定输入纹理
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, inputTextureID);

    // 设置纹理采样器
    GLint texUniform = glGetUniformLocation(shaderProgram, "texture");
    glUniform1i(texUniform, 0);

    // 绘制四边形
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    // 解除帧缓冲对象绑定
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    // 清理资源
    glDeleteBuffers(1, &VBO);
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    glDeleteProgram(shaderProgram);
    glDeleteFramebuffers(1, &framebuffer);
    const uint glErr = glGetError();
    if (glErr != GL_NO_ERROR) {
        NSLog(@"Failed convert UpsideDownTexture To BottomUp! errno=0x%x", glErr);
    }
    
}

@end
