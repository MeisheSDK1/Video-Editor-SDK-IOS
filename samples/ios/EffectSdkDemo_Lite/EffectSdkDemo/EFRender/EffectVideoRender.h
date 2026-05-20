//
//  EffectVideoRender.h
//  Agora iOS Tutorial Objective-C
//
//  Created by 美摄 on 2020/10/12.
//  Copyright © 2020 Agora.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsEffectSdkContext.h"
#import <NvARSceneFx/NvARScenePreview.h>

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN


//#define UseARScene_ST

@protocol EffectVideoRenderDelegate <NSObject>

- (void)newFrameTextureReady:(GLuint)outputTexture size:(CGSize)size timelinePos:(int64_t)timelinePos taskId:(int64_t)taskId;

- (void)photoResultImage:(UIImage*)resultImage taskId:(int64_t)taskId;

- (void)newFramePixelBufferReady:(CVPixelBufferRef)pixelBuffer
                  bufferNeedFlip:(BOOL)flip
                         texture:(GLuint)texture
                     timelinePos:(int64_t)timelinePos;

@end

@interface EffectVideoRender : NSObject

@property (nonatomic,weak) id<EffectVideoRenderDelegate> delegate;

@property (nonatomic, readonly) EAGLContext *glContext;

@property (nonatomic,readonly) dispatch_queue_t videoProcessingQueue;
@property (nonatomic, readonly) NSString *queueSpecificKey;

@property (nonatomic, assign) int64_t renderStartTime;
@property (nonatomic, readonly) NvsEffectSdkContext *effectContext;
@property (nonatomic, readonly) NvsEffectRenderCore *renderCore;
@property (nonatomic, assign) BOOL isInitializedARScene;
@property (nonatomic, strong) NvsVideoEffect* __nullable segEffect;
@property (nonatomic, strong) NvsVideoEffect* __nullable faceEffect;
@property (nonatomic, strong) NvARSceneFxOperator *ARSceneFxOperator;
@property (nonatomic, strong) NvARScenePreview *preView;

@property (atomic,strong) NSMutableArray<NvsEffect*>* filterArray;

//Picture frame ratio Cropping ratio
/// 拍照画幅比例裁剪比例
@property (nonatomic, assign) CGFloat proportion;


- (instancetype)init;

- (void)enableBeautyFilter:(BOOL)enable;

- (void)applyARScennePackage:(NSString*)packageId;

- (NvsVideoEffect* __nullable)appendBuildInFilter:(NSString*)buildInName;
- (NvsVideoEffect* __nullable)appendPackageFilter:(NSString*)packageId;

- (void)removeBuildInFilter:(NSString*)buildInName;
- (void)removePackageFilter:(NSString*)packageId;
// Clean up
//清理
-(void)cleanUp;

#ifdef UseARScene_ST
-(int64_t)dealWithSampleBuffer:(CMSampleBufferRef)sampleBuffer renderBuffer:(BOOL)renderBuffer flip:(BOOL)flip;
#else
-(int64_t)dealWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
                  renderBuffer:(BOOL)renderBuffer
                          flip:(BOOL)flip
                       isFront:(BOOL)isFront
                   orientation:(AVCaptureVideoOrientation)orientation;

#endif

-(int64_t)processingPhoto:(AVCapturePhoto *)photo
             renderBuffer:(BOOL)renderBuffer
                   output:(AVCapturePhotoOutput *)output
       isFlipHorizontally:(BOOL)isFlip API_AVAILABLE(ios(11.0));

-(GLuint)createTextureWithWidth:(int)width height:(int)height;

@end

NS_ASSUME_NONNULL_END
