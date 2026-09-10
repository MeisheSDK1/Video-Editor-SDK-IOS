//
//  EFBufferDisplayView+NveEffectKit.m
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/9.
//

#import "EFBufferDisplayView+NveEffectKit.h"

@implementation EFBufferDisplayView (NveEffectKit)

- (void)displayRenderOutput:(NveRenderOutput *)output presentationTimeStamp:(CMTime)presentationTimeStamp duration:(CMTime)duration {
    if (self.displayLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
        [self.displayLayer flush];
    }
    CVPixelBufferRef pixelBuff = output.pixelBuffer;
    if (pixelBuff) {
        CVPixelBufferLockBaseAddress(pixelBuff, kCVPixelBufferLock_ReadOnly);
        OSStatus ret = 0;
        CMSampleBufferRef sample = NULL;
        CMVideoFormatDescriptionRef videoInfo = NULL;
        CMSampleTimingInfo timingInfo = kCMTimingInfoInvalid;
        timingInfo.presentationTimeStamp = presentationTimeStamp;
        timingInfo.duration = duration;
        ret = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuff, &videoInfo);
        if (ret != 0) {
            NSLog(@"CMVideoFormatDescriptionCreateForImageBuffer failed! %d", (int)ret);
        }
        ret = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuff, true, NULL, NULL, videoInfo, &timingInfo, &sample);
        if (ret != 0) {
            NSLog(@"CMSampleBufferCreateForImageBuffer failed! %d", (int)ret);
        }
        CVPixelBufferUnlockBaseAddress(pixelBuff, kCVPixelBufferLock_ReadOnly);
        if (sample) {
            [self.displayLayer enqueueSampleBuffer:sample];
            CFRelease(sample);
        }
        if (videoInfo) {
            CFRelease(videoInfo);
        }
    }
}

- (void)cleanUp {
    //
}

@end
