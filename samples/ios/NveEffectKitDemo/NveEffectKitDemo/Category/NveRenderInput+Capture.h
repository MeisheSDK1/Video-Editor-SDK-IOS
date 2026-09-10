//
//  NveRenderInput+Capture.h
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/9.
//

#import <NveEffectKit/NveEffectKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NveRenderInput (Capture)

+ (NveRenderInput *_Nullable)inputWithSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

@end

NS_ASSUME_NONNULL_END
