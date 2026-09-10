//
//  EFCapture.m
//  EffectSdkDemo
//
//  Created by 美摄 on 2019/12/10.
//  Copyright © 2019 美摄. All rights reserved.
//

#import "EFCapture.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface EFCapture () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate> {
    AVCaptureConnection *_audioConnection;
    AVCaptureConnection *_videoConnection;
    AVCaptureVideoOrientation _videoBufferOrientation;
    AVCaptureDevice *_videoDevice;
    BOOL _startCaptureSessionOnEnteringForeground;
    id _applicationWillEnterForegroundNotificationObserver;
    NSDictionary *_videoCompressionSettings;
    NSDictionary *_audioCompressionSettings;

    dispatch_queue_t _dataOutputQueue;
}
@property(nonatomic, weak) id<EFCaptureDelegate> delegate;

@property(nonatomic, assign) dispatch_queue_t sampleBufferCallbackQueue;
@property(nonatomic, assign) OSType pixelFormatType;

@property(nonatomic, strong) AVCaptureDevice *camera;
@property(nonatomic, strong) AVCaptureDeviceInput *cameraInput;
@property(nonatomic, strong) AVCaptureDeviceInput *audioCaptureDeviceInput;
@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureVideoDataOutput *dataOutput;

@property(nonatomic, strong) AVCapturePhotoOutput *photoOutput;
@property(nonatomic, assign, readwrite) AVCaptureDevicePosition position;
@property(nonatomic, assign, readwrite) BOOL takePhotoEnable;

@property(strong, nonatomic, readwrite) AVCaptureSessionPreset captureSessionPreset;

@end

@implementation EFCapture

- (instancetype)initWithSessionPreset:(AVCaptureSessionPreset)sessionPreset
                       cameraPosition:(AVCaptureDevicePosition)cameraPosition
                      dataOutputQueue:(dispatch_queue_t)dataOutputQueue
                             delegate:(nullable id<EFCaptureDelegate>)delegate {
    self = [super init];
    if (self) {
        //kCVPixelFormatType_32BGRA
        //kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        self.pixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
        self.captureSessionPreset = sessionPreset;
        if (!dataOutputQueue) {
            _dataOutputQueue = dispatch_queue_create("com.meishe.Effect.camera", DISPATCH_QUEUE_SERIAL);
        } else {
            _dataOutputQueue = dataOutputQueue;
        }
        self.position = cameraPosition;
        self.delegate = delegate;
        self.startTime = -1;
        [self setupCamera:cameraPosition];
    }
    return self;
}

#pragma mark - setter & getter
- (void)setFlashOn:(BOOL)flashOn {
    _flashOn = flashOn;
    // 更改设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    // You must lock the device when you change the Settings, and then unlock it after the change, or it will crash
    [self.camera lockForConfiguration:nil];
    // 判断设备是否支持闪光灯
    // Determine if the device supports flash
    if ([self.camera hasFlash]) {
        if (flashOn) {
            if ([self.camera isTorchModeSupported:AVCaptureTorchModeOn]) {
                [self.camera setTorchMode:AVCaptureTorchModeOn];
            }

        } else {
            if ([self.camera isTorchModeSupported:AVCaptureTorchModeOff]) {
                [self.camera setTorchMode:AVCaptureTorchModeOff];
            }
        }
    } else {
        NSLog(@"该设备不支持闪光灯");
    }

    // 修改完毕解锁
    // Modification completed Unlock
    [self.camera unlockForConfiguration];
}

- (BOOL)supportFlash {
    BOOL result = [self.camera isTorchModeSupported:AVCaptureTorchModeOn];
    return result;
}

- (void)setZoomFactor:(CGFloat)zoomFactor {
    [self.camera lockForConfiguration:nil];
    if (zoomFactor <= self.camera.activeFormat.videoMaxZoomFactor && zoomFactor >= 1) {
        self.camera.videoZoomFactor = zoomFactor;
    } else {
        NSLog(@"焦距数据错误");
    }

    [self.camera unlockForConfiguration];
}

- (CGFloat)zoomFactor {
    return self.camera.videoZoomFactor;
}

- (void)setExposureBias:(float)exposureBias {
    [self.camera lockForConfiguration:nil];
    if ([self.camera isExposureModeSupported:AVCaptureExposureModeLocked]) {
        [self.camera setExposureMode:AVCaptureExposureModeLocked];
        if (exposureBias <= self.camera.maxExposureTargetBias && exposureBias >= self.camera.minExposureTargetBias) {
            //            [self.camera setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent
            //                                                       ISO:exposeFactor
            //                                         completionHandler:nil];
            [self.camera setExposureTargetBias:exposureBias completionHandler:nil];
        } else {
            NSLog(@"曝光值错误");
        }
    }
    [self.camera unlockForConfiguration];
}

- (float)exposureBias {
    return self.camera.exposureTargetBias;
}

- (void)setFocusPoint:(CGPoint)focusPoint {
    _focusPoint = focusPoint;

    if (!self.camera) {
        NSLog(@"设备错误");
        return;
    }
    [self.camera lockForConfiguration:nil];
    if ([self.camera isFocusPointOfInterestSupported]) {
        [self.camera setFocusPointOfInterest:focusPoint];
    }
    [self.camera unlockForConfiguration];
}

- (BOOL)supportFocus {
    BOOL result = [self.camera isFocusPointOfInterestSupported];
    return result;
}

- (CGFloat)videoMaxZoomFactor {
    CGFloat result = self.camera.activeFormat.videoMaxZoomFactor;
    return result;
}

- (float)minExposureTargetBias {
    float result = self.camera.minExposureTargetBias;
    return result;
}

- (float)maxExposureTargetBias {
    float result = self.camera.maxExposureTargetBias;
    return result;
}
#pragma mark - 设置配置 / capture configure
- (void)setupCamera:(AVCaptureDevicePosition)position {
    if (self.camera) {
        // 重置曝光补偿 / Reset exposure compensation
        [self setExposureBias:0];
    }
    self.position = position;
    self.camera = [self videoDevice:position];
    if (!self.camera) {
        self.camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }

    if (!self.camera) {
        NSLog(@"Invalid camera device!");
        return;
    }

    self.session = [[AVCaptureSession alloc] init];
    [self.session beginConfiguration];

    NSError *error;
    self.cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.camera error:&error];
    if (error) {
        NSLog(@"Failed to add input device!");
        return;
    }
    [self.session addInput:self.cameraInput];

    [self setupRecording];

    self.dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [self.dataOutput setVideoSettings:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:(int)self.pixelFormatType], kCVPixelBufferPixelFormatTypeKey, nil]];

    [self.dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [self.dataOutput setSampleBufferDelegate:self queue:_dataOutputQueue];

    [self.session addOutput:self.dataOutput];
    self.session.sessionPreset = self.captureSessionPreset;
    // 设置采集方向并开始采集 不再自动设置
    // Setting the acquisition direction and starting the acquisition is no longer automatically set
    [self adjustVideoConnectionOrientation];
    [self.session commitConfiguration];
}

- (AVCaptureDevice *)videoDevice:(AVCaptureDevicePosition)position {
    AVCaptureDevice *resultDevice = nil;
    AVCaptureDeviceDiscoverySession *deviceDiscovery = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                                                                                              mediaType:AVMediaTypeVideo
                                                                                                               position:position];

    NSArray *devices = deviceDiscovery.devices;
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            resultDevice = device;
            break;
        }
    }
    return resultDevice;
}

- (void)setupRecording {
    //添加一个音频输入设备
    //Add an audio input device
    AVCaptureDeviceDiscoverySession *deviceDiscovery = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInMicrophone]
                                                                                                              mediaType:AVMediaTypeAudio
                                                                                                               position:AVCaptureDevicePositionUnspecified];
    AVCaptureDevice *audioCaptureDevice = [deviceDiscovery.devices firstObject];
    NSError *error = nil;
    self.audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
    if (error) {
        NSLog(@"Capture Device Input Error：%@", error.localizedDescription);
        return;
    }
    if ([self.session canAddInput:self.audioCaptureDeviceInput]) {
        [self.session addInput:self.audioCaptureDeviceInput];
    }

    AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
    [audioOut setSampleBufferDelegate:self queue:dispatch_queue_create("com.apple.sample.capturepipeline.audio", NULL)];
    if ([_session canAddOutput:audioOut]) {
        [_session addOutput:audioOut];
    }
    _audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
}

//默认不开启
//Disabled by default.
- (void)enableTakePhoto:(BOOL)enable sessionPreset:(AVCaptureSessionPreset)sessionPreset {
    self.captureSessionPreset = sessionPreset;
    if (self.takePhotoEnable == enable) {
        return;
    }
    self.takePhotoEnable = enable;
    [self.session beginConfiguration];

    if (enable) {
        //拍照输出设置回调
        //Photo output setup callback
        self.photoOutput = [[AVCapturePhotoOutput alloc] init];
        NSDictionary *setDic = @{(NSString *)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:(int)self.pixelFormatType]};
        AVCapturePhotoSettings *setting = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
        if (@available(iOS 13.0, *)) {
            setting.photoQualityPrioritization = AVCapturePhotoQualityPrioritizationSpeed;
        } else {
            // Fallback on earlier versions
        }
        setting.autoStillImageStabilizationEnabled = NO;

        [setting setHighResolutionPhotoEnabled:true];
        [self.photoOutput setPhotoSettingsForSceneMonitoring:setting];
        [self.session addOutput:self.photoOutput];
        [self.photoOutput setHighResolutionCaptureEnabled:YES];
    } else {
        if (self.photoOutput) {
            [self.session removeOutput:self.photoOutput];
            self.photoOutput = nil;
        }
    }
    self.session.sessionPreset = self.captureSessionPreset;
    // 设置采集方向并开始采集
    // Set the acquisition direction and start the acquisition
    [self adjustVideoConnectionOrientation];
    [self.session commitConfiguration];
}

- (void)startRunning {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.session startRunning];
    });
}

- (void)stopRunning {
    [self.session stopRunning];
}

- (void)switchCamera {
    [self.session stopRunning];
    [self.session beginConfiguration];
    AVCaptureDevicePosition position = self.position == AVCaptureDevicePositionFront ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    if (self.cameraInput) {
        [self.session removeInput:self.cameraInput];
    }
    self.camera = [self videoDevice:position];
    NSError *error;
    self.cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.camera error:&error];
    if (error) {
        NSLog(@"Failed to add input device!");
        return;
    }
    self.position = position;
    [self.session addInput:self.cameraInput];
    self.session.sessionPreset = self.captureSessionPreset;
    [self adjustVideoConnectionOrientation];
    [self.session commitConfiguration];
    [self.session startRunning];
}

- (void)adjustVideoConnectionOrientation {
    AVCaptureConnection *captureConnection = [self.dataOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!captureConnection) {
        return;
    }

    if (!captureConnection.supportsVideoOrientation)
        return;

    UIInterfaceOrientation screenOrientation = UIInterfaceOrientationPortrait;
    UIApplication *app = [UIApplication sharedApplication];
    if (@available(iOS 13.0, *)) {
        NSArray<UIScene *> *array = app.connectedScenes.allObjects;
        for (UIScene *scene in array) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                screenOrientation = windowScene.interfaceOrientation;
                break;
            }
        }
    } else {
        screenOrientation = app.statusBarOrientation;
    }

    switch (screenOrientation) {
        default:
        case UIInterfaceOrientationPortrait:
            captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationLandscapeRight:
            captureConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            captureConnection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            captureConnection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
    }
}

- (void)capturePhoto;
{
    if (self.photoOutput == nil)
        return;

    NSDictionary *setDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:(int)self.pixelFormatType], kCVPixelBufferPixelFormatTypeKey, nil];
    AVCapturePhotoSettings *setting = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
    [setting setHighResolutionPhotoEnabled:true];
    [self.photoOutput capturePhotoWithSettings:setting delegate:self];
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.delegate && [self.delegate respondsToSelector:@selector(captureOutput:didOutputSampleBuffer:fromConnection:isAudioConnection:)]) {
        if (connection == _audioConnection) {
            [self.delegate captureOutput:output didOutputSampleBuffer:sampleBuffer fromConnection:connection isAudioConnection:YES];
        } else {
            [self.delegate captureOutput:output didOutputSampleBuffer:sampleBuffer fromConnection:connection isAudioConnection:NO];
        }
    }
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error {
    //    if (self.delegate && [self.delegate respondsToSelector:@selector(captureOutput:didFinishProcessingPhoto:error:)]) {
    //        [self.delegate captureOutput:output didFinishProcessingPhoto:photo error:error];
    //    }
}

- (void)dealloc {
    // 停止采集、释放资源
    //Stop collecting and releasing resources
    if (self.session.isRunning == YES) {
        [self.session stopRunning];
    }

    if (self.camera) {
        // 重置曝光补偿 / Reset exposure compensation
        [self setExposureBias:0];
    }
    NSLog(@"capture：%s", __FUNCTION__);
}

#pragma - mark audioEngine
- (void)setStartTime:(int64_t)startTime {
    if (_startTime <= 0) {
        _startTime = startTime;
    }
}

@end
