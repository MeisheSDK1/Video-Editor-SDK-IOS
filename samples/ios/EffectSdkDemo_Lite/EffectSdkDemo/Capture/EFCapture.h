//
//  EFCapture.h
//  EffectSdkDemo
//
//  Created by 美摄 on 2019/12/10.
//  Copyright © 2019 美摄. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioEngine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EFCaptureDelegate <NSObject>

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection isAudioConnection:(BOOL)isAudioConnection;

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error API_AVAILABLE(ios(11.0));

@end

@interface EFCapture : NSObject
- (id)initWithSessionPreset:(AVCaptureSessionPreset)sessionPreset
             cameraPosition:(AVCaptureDevicePosition)cameraPosition
            dataOutputQueue:(dispatch_queue_t)dataOutputQueue
                   delegate:(nullable id<EFCaptureDelegate>)delegate;

@property(nonatomic,readonly)AVCaptureDevicePosition position;

@property (readonly, nonatomic) AVCaptureSessionPreset captureSessionPreset;

@property (nonatomic, assign) BOOL flashOn;
@property (nonatomic, assign) BOOL supportFlash;
@property (nonatomic, assign) CGFloat zoomFactor;
@property (nonatomic, assign) float exposeFactor;
@property (nonatomic, assign) CGPoint focusPoint;
@property (nonatomic, assign) BOOL supportFocus;
@property (nonatomic, assign) CGFloat videoMaxZoomFactor;
@property (nonatomic, assign) float minISO;
@property (nonatomic, assign) float maxISO; 
@property(nonatomic,readonly) BOOL takePhotoEnable;

@property (nonatomic, assign) int64_t startTime;
@property (nonatomic, strong) AudioEngine *audioEngine;

- (id)initWithSessionPreset:(AVCaptureSessionPreset)sessionPreset
             cameraPosition:(AVCaptureDevicePosition)cameraPosition
            dataOutputQueue:(dispatch_queue_t)dataOutputQueue
                   delegate:(nullable id<EFCaptureDelegate>)delegate;

-(void)switchCamera;

-(void)startRunning;

-(void)stopRunning;

//默认不开启
-(void)enableTakePhoto:(BOOL)enable sessionPreset:(AVCaptureSessionPreset)sessionPreset;

-(void)capturePhoto;

@end

NS_ASSUME_NONNULL_END
