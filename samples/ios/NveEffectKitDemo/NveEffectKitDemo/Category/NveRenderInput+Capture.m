//
//  NveRenderInput+Capture.m
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/9.
//

#import "NveRenderInput+Capture.h"

@implementation NveRenderInput (Capture)

+ (NveRenderInput *)inputWithSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer == nil) {
        return nil;
    }
    NveRenderInput *input = [[NveRenderInput alloc] init];
    NveImageBuffer *imageBuffer = [[NveImageBuffer alloc] init];
    imageBuffer.pixelBuffer = pixelBuffer;
    input.imageBuffer = imageBuffer;

    return input;
}

@end
