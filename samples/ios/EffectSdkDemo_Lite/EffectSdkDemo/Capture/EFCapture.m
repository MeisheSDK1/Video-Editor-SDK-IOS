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

@interface EFCapture ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
{
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
@property(nonatomic,weak)id<EFCaptureDelegate> delegate;

@property(nonatomic,assign) dispatch_queue_t sampleBufferCallbackQueue;
@property(nonatomic,assign) OSType pixelFormatType;

@property (nonatomic, strong) AVCaptureDevice *camera;
@property (nonatomic, strong) AVCaptureDeviceInput *cameraInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioCaptureDeviceInput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoDataOutput *dataOutput;

@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput;
@property(nonatomic,assign,readwrite)AVCaptureDevicePosition position;
@property(nonatomic,assign,readwrite)BOOL takePhotoEnable;

@property (strong, nonatomic, readwrite) AVCaptureSessionPreset captureSessionPreset;

@end

@implementation EFCapture

- (id)initWithSessionPreset:(AVCaptureSessionPreset)sessionPreset
             cameraPosition:(AVCaptureDevicePosition)cameraPosition
            dataOutputQueue:(dispatch_queue_t)dataOutputQueue
                   delegate:(nullable id<EFCaptureDelegate>)delegate{
    self = [super init];
    if (self) {
        //kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        //kCVPixelFormatType_32BGRA
        //kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        self.pixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
        self.captureSessionPreset = sessionPreset;
        _dataOutputQueue = dataOutputQueue;
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
    }else {
        NSLog(@"该设备不支持闪光灯 The device does not support flash");
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
    _zoomFactor = zoomFactor;
    [self.camera lockForConfiguration:nil];
    if (zoomFactor<= self.camera.activeFormat.videoMaxZoomFactor && zoomFactor>= 1) {
        self.camera.videoZoomFactor = zoomFactor;
    }else{
        NSLog(@"焦距数据错误 The focal length data is incorrect");
    }
    
    [self.camera unlockForConfiguration];
}

- (void)setExposeFactor:(float)exposeFactor {
    _exposeFactor = exposeFactor;
    [self.camera lockForConfiguration:nil];
    if([self.camera isExposureModeSupported:AVCaptureExposureModeLocked ]){
        [self.camera setExposureMode:AVCaptureExposureModeLocked];
        if(exposeFactor<=self.camera.activeFormat.maxISO && exposeFactor>=self.camera.activeFormat.minISO){
           [self.camera setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:exposeFactor completionHandler:^(CMTime syncTime) {
               
           }];
        }
        else {
            NSLog(@"曝光值错误 Exposure error");
        }
        
    }
    [self.camera unlockForConfiguration];
}

- (void)setFocusPoint:(CGPoint)focusPoint {
    _focusPoint = focusPoint;

    if(!self.camera){
        NSLog(@"设备错误 Equipment error");
        return;
    }
    [self.camera lockForConfiguration:nil];
    if ([self.camera isFocusPointOfInterestSupported])
    {
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

- (float)minISO {
    float result = self.camera.activeFormat.minISO;
    return result;
}

- (float)maxISO {
    float result = self.camera.activeFormat.maxISO;
    return result;
}
#pragma mark - 设置配置
// capture configure
- (void)setupCamera:(AVCaptureDevicePosition)position{
    self.position = position;
    if (@available(iOS 10.0, *)) {
        AVCaptureDeviceDiscoverySession *devicesIOS10 = [AVCaptureDeviceDiscoverySession  discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
        
        NSArray *devicesIOS  = devicesIOS10.devices;
        for (AVCaptureDevice *device in devicesIOS) {
            if ([device position] == position) {
                self.camera = device;
                break;
            }
        }
    }else{
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices) {
            if (device.position == position) {
                self.camera = device;
                break;
            }
        }
    }
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
#ifndef USING_AUDIO_ENGINE
    [self setupRecording];
#endif
    self.dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [self.dataOutput setVideoSettings:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:(int)self.pixelFormatType], kCVPixelBufferPixelFormatTypeKey, nil]];
    
    [self.dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [self.dataOutput setSampleBufferDelegate:self queue:_dataOutputQueue];
    
    [self.session addOutput:self.dataOutput];
    self.session.sessionPreset = self.captureSessionPreset;
    // 设置采集方向并开始采集 不再自动设置
    // Setting the acquisition direction and starting the acquisition is no longer automatically set
    [self AdjustVideoConnectionOrientation];
    [self.session commitConfiguration];
}

- (void)setupRecording {

    //添加一个音频输入设备
    //Add an audio input device
    AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    NSError *error=nil;
    self.audioCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因： Error obtaining device input object. Error cause:%@",error.localizedDescription);
        return;
    }
    if ([self.session canAddInput:self.audioCaptureDeviceInput]) {
        [self.session addInput:self.audioCaptureDeviceInput];
    }
    
    AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
    [audioOut setSampleBufferDelegate:self queue:dispatch_queue_create("com.apple.sample.capturepipeline.audio", NULL)];
    if ( [_session canAddOutput:audioOut] ) {
        [_session addOutput:audioOut];
    }
    _audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
}

//默认不开启
//Disabled by default.
-(void)enableTakePhoto:(BOOL)enable sessionPreset:(AVCaptureSessionPreset)sessionPreset{
    self.captureSessionPreset = sessionPreset;
    if (self.takePhotoEnable == enable) {
        return;
    }
    self.takePhotoEnable = enable;
    [self.session beginConfiguration];
    
    if (enable) {
        //拍照输出设置回调
        //Photo output setup callback
        if (@available(iOS 10.0, *)) {
            self.photoOutput = [[AVCapturePhotoOutput alloc] init];
            NSDictionary *setDic = @{(NSString*)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt:(int)self.pixelFormatType]
            };
            AVCapturePhotoSettings* setting = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
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
            // Fallback on earlier versions
        }
    }else{
        if (self.photoOutput) {
            [self.session removeOutput:self.photoOutput];
            self.photoOutput = nil;
        }
    }
    self.session.sessionPreset = self.captureSessionPreset;
//    [self configSessionPreset:self.position];
    // 设置采集方向并开始采集
    // Set the acquisition direction and start the acquisition
    [self AdjustVideoConnectionOrientation];
    [self.session commitConfiguration];
}

-(void)startRunning{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.session startRunning];
    });
}

-(void)stopRunning{
    [self.session stopRunning];
}

-(void)switchCamera{
    [self.session stopRunning];
    [self.session beginConfiguration];
    AVCaptureDevicePosition position = self.position == AVCaptureDevicePositionFront?AVCaptureDevicePositionBack:AVCaptureDevicePositionFront;
    if (self.cameraInput) {
        [self.session removeInput:self.cameraInput];
    }
    if (@available(iOS 10.0, *)) {
        AVCaptureDeviceDiscoverySession *devicesIOS10 = [AVCaptureDeviceDiscoverySession  discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
        
        NSArray *devicesIOS  = devicesIOS10.devices;
        for (AVCaptureDevice *device in devicesIOS) {
            if ([device position] == position) {
                self.camera = device;
                break;
            }
        }
    }else{
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices) {
            if (device.position == position) {
                self.camera = device;
                break;
            }
        }
    }
    NSError *error;
    self.cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.camera error:&error];
    if (error) {
        NSLog(@"Failed to add input device!");
        return;
    }
    self.position = position;
    [self.session addInput:self.cameraInput];
//    [self configSessionPreset:position];
    self.session.sessionPreset = self.captureSessionPreset;
    [self AdjustVideoConnectionOrientation];
    [self.session commitConfiguration];
    [self.session startRunning];
    self.flashOn = false;
}

- (void)AdjustVideoConnectionOrientation {
    AVCaptureConnection *captureConnection = [self.dataOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!captureConnection) {
        return;
    }
    
    if (!captureConnection.supportsVideoOrientation)
        return;
    
    UIInterfaceOrientation screenOrientation = UIInterfaceOrientationPortrait;
    UIApplication *app = [UIApplication sharedApplication];
    if (@available(iOS 13.0, *)) {
        NSArray<UIScene *>* array = app.connectedScenes.allObjects;
        for (UIScene* scene in array) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                screenOrientation = windowScene.interfaceOrientation;
                break;
            }
        }
    }else{
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

-(void)capturePhoto;{
    if (self.photoOutput == nil)
        return;
    
    if (@available(iOS 10.0, *)) {
        NSDictionary *setDic = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:(int)self.pixelFormatType], kCVPixelBufferPixelFormatTypeKey, nil];
        AVCapturePhotoSettings* setting = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
        [setting setHighResolutionPhotoEnabled:true];
        [self.photoOutput capturePhotoWithSettings:setting delegate:(id<AVCapturePhotoCaptureDelegate>)self];
    } else {
        // Fallback on earlier versions
    }
}


- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (self.delegate && [self.delegate respondsToSelector:@selector(captureOutput:didOutputSampleBuffer:fromConnection:isAudioConnection:)]) {
        if (connection == _audioConnection) {
            [self.delegate captureOutput:output didOutputSampleBuffer:sampleBuffer fromConnection:connection isAudioConnection:YES];
        }else{
            [self.delegate captureOutput:output didOutputSampleBuffer:sampleBuffer fromConnection:connection isAudioConnection:NO];
        }
    }
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error API_AVAILABLE(ios(11.0)){
    if (self.delegate && [self.delegate respondsToSelector:@selector(captureOutput:didFinishProcessingPhoto:error:)]) {
        [self.delegate captureOutput:output didFinishProcessingPhoto:photo error:error];
    }
}

- (void)configSessionPreset:(AVCaptureDevicePosition)position{
    if (self.takePhotoEnable) {
        AVCaptureDeviceFormat* selectFormat = nil;
        int width = 0;
        int hight = 0;
        CMMediaType meditype = CMFormatDescriptionGetMediaType(selectFormat.formatDescription);
        if (meditype == kCMMediaType_Video) {
            CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions((CMVideoFormatDescriptionRef)selectFormat.formatDescription);
            width  = dimension.width;
            hight  = dimension.height;
        }
        
        [self.session beginConfiguration];
        [self.camera lockForConfiguration:nil];
        
        self.camera.activeFormat = selectFormat;
        
        [self.camera unlockForConfiguration];
        self.session.sessionPreset = AVCaptureSessionPresetInputPriority;
        NSLog(@"选取的分辨率 Selected resolutionselectFormat=%@",selectFormat);
        [self.session commitConfiguration];
    }else{
        [self.session beginConfiguration];
        if (((SCREENHEIGHT >= 812.0) && [[UIDevice currentDevice].model isEqualToString:@"iPhone"])) {
            [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
        }else{
            [self.session setSessionPreset:AVCaptureSessionPreset1280x720];
        }
        [self.session commitConfiguration];
    }
}

- (void)dealloc {
    // 停止采集、释放资源
    //Stop collecting and releasing resources
    [self.session stopRunning];
    NSLog(@"%s",__FUNCTION__);
}
#pragma -mark audioEngine
- (void)setStartTime:(int64_t)startTime{
    if (_startTime<=0) {
        _startTime = startTime;
    }
}
- (CMSampleBufferRef)createAudioSampleBufferFrom:(AVAudioPCMBuffer *) pcmBuffer mSampleTime:(int64_t)mSampleTime {
    AudioBufferList *audioBufferList = [pcmBuffer mutableAudioBufferList];
    AudioStreamBasicDescription asbd = *pcmBuffer.format.streamDescription;
    AVAudioChannelLayout *channelLayout = pcmBuffer.format.channelLayout;

    CMSampleBufferRef sampleBuffer = NULL;
    CMFormatDescriptionRef format = NULL;

    OSStatus error = CMAudioFormatDescriptionCreate(kCFAllocatorDefault, &asbd, sizeof(AudioChannelLayout), channelLayout.layout, 0, NULL, NULL, &format);
    if (error != noErr) {
        return nil;
    }

    CMSampleTimingInfo timing = { CMTimeMake(1, asbd.mSampleRate), CMTimeMake(self.startTime, 1000000), kCMTimeInvalid };
    error = CMSampleBufferCreate(kCFAllocatorDefault,
                                 NULL, false, NULL, NULL, format,
                                 pcmBuffer.frameLength,
                                 1, &timing, 0, NULL, &sampleBuffer);
    if (error != noErr) {
        CFRelease(format);
        NSLog(@"CMSampleBufferCreate returned error: %d", (int)error);
        return nil;
    }

    error = CMSampleBufferSetDataBufferFromAudioBufferList(sampleBuffer, kCFAllocatorDefault, kCFAllocatorDefault, 0, audioBufferList);
    if (error != noErr) {
        CFRelease(format);
        NSLog(@"CMSampleBufferSetDataBufferFromAudioBufferList returned error: %d", (int)error);
        return nil;
    }

    CFRelease(format);
    return sampleBuffer;
}
- (AudioEngine *)audioEngine{
    if (!_audioEngine) {
        _audioEngine = [[AudioEngine alloc]init];
        __weak typeof(self) weakSelf = self;
        _audioEngine.block = ^(AVAudioPCMBuffer * _Nonnull buffer,int64_t mSampleTime) {
            
            CMSampleBufferRef sampleBuffer = [weakSelf createAudioSampleBufferFrom:buffer mSampleTime:mSampleTime];
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(captureOutput:didOutputSampleBuffer:fromConnection:isAudioConnection:)]) {
                [weakSelf.delegate captureOutput:nil didOutputSampleBuffer:sampleBuffer fromConnection:nil isAudioConnection:YES];
            }

            CFRelease(sampleBuffer);
        };
    }
    return _audioEngine;
}
@end

