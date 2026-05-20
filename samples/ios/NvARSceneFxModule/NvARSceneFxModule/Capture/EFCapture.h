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

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error API_AVAILABLE(ios(11.0));

@end

@interface EFCapture : NSObject
- (id)initWithSessionPreset:(AVCaptureSessionPreset)sessionPreset
             cameraPosition:(AVCaptureDevicePosition)cameraPosition
            dataOutputQueue:(dispatch_queue_t)dataOutputQueue
                   delegate:(nullable id<EFCaptureDelegate>)delegate;

@property(nonatomic,readonly)AVCaptureDevicePosition position;

@property (readonly, nonatomic) AVCaptureSessionPreset captureSessionPreset;
/// 下面注释不需要翻译看英文变量即可
/// Comments don't need to be translated into English variables
@property (nonatomic, assign) BOOL flashOn; //是否开启闪光
@property (nonatomic, assign) BOOL supportFlash; //是否支持闪光
@property (nonatomic, assign) CGFloat zoomFactor; //焦距
@property (nonatomic, assign) float exposeFactor; //曝光
@property (nonatomic, assign) CGPoint focusPoint; //聚焦点
@property (nonatomic, assign) BOOL supportFocus; //是否支持聚焦
@property (nonatomic, assign) CGFloat videoMaxZoomFactor; //视频最大支持焦距值
@property (nonatomic, assign) float minISO; //最小支持曝光值
@property (nonatomic, assign) float maxISO; //最大支持曝光值
@property(nonatomic,readonly) BOOL takePhotoEnable;

@property (nonatomic, assign) int64_t startTime;

- (id)initWithSessionPreset:(AVCaptureSessionPreset)sessionPreset
             cameraPosition:(AVCaptureDevicePosition)cameraPosition
            dataOutputQueue:(dispatch_queue_t)dataOutputQueue
                   delegate:(nullable id<EFCaptureDelegate>)delegate;

-(void)switchCamera;

-(void)startRunning;

-(void)stopRunning;

//默认不开启
//Disabled by default.
-(void)enableTakePhoto:(BOOL)enable sessionPreset:(AVCaptureSessionPreset)sessionPreset;

-(void)capturePhoto;

@end

NS_ASSUME_NONNULL_END
