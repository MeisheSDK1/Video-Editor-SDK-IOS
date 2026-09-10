//
//  EFCapture.h
//  EffectSdkDemo
//
//  Created by 美摄 on 2019/12/10.
//  Copyright © 2019 美摄. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EFCaptureDelegate <NSObject>

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection isAudioConnection:(BOOL)isAudioConnection;

@end

@interface EFCapture : NSObject

@property(nonatomic, readonly) AVCaptureDevicePosition position;

@property(nonatomic, readonly) AVCaptureSessionPreset captureSessionPreset;

@property(nonatomic, assign) BOOL flashOn;
@property(nonatomic, assign) BOOL supportFlash;
@property(nonatomic, readwrite) CGFloat zoomFactor;
@property(nonatomic, readwrite) float exposureBias;
@property(nonatomic, assign) CGPoint focusPoint;
@property(nonatomic, assign) BOOL supportFocus;
@property(nonatomic, readonly) CGFloat videoMaxZoomFactor;
@property(nonatomic, readonly) float minExposureTargetBias;
@property(nonatomic, readonly) float maxExposureTargetBias;

@property(nonatomic, assign) int64_t startTime;

- (instancetype)initWithSessionPreset:(AVCaptureSessionPreset)sessionPreset
                       cameraPosition:(AVCaptureDevicePosition)cameraPosition
                      dataOutputQueue:(dispatch_queue_t _Nullable)dataOutputQueue
                             delegate:(id<EFCaptureDelegate> _Nullable)delegate;

- (void)switchCamera;

- (void)startRunning;

- (void)stopRunning;

@end

NS_ASSUME_NONNULL_END
