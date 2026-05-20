//
//  EffectVideoSource.m
//  Agora iOS Tutorial Objective-C
//
//  Created by 美摄 on 2020/10/12.
//  Copyright © 2020 Agora.io. All rights reserved.
//

#import "EffectVideoRender.h"
#import "NvsEffectSdkContext.h"
#import "NvsARSceneManipulate.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <CoreMotion/CoreMotion.h>
#import "UIImage+Extension.h"
#import "NvBuffer.h"
#import "NvLog.h"

EAGLContext* videoProcessingContext = nil;

@interface TaskModel : NSObject
@property(nonatomic,assign) int64_t taskId;
@property(nonatomic,assign) CVPixelBufferRef pixelBuffer;
@property(nonatomic,assign) int64_t timelinePos;
@property(nonatomic,assign) int displayRotation;
@property(nonatomic,assign) int physicalOrientation;
@property(nonatomic,assign) BOOL flip;

@property(nonatomic,assign) BOOL photoTask;
///capture time
///采集时间
@property(nonatomic,assign) int64_t captureTimelinePos;

@property(nonatomic,strong) AVCapturePhoto *photo;

@property(nonatomic,copy)void (^ __nullable completion)(void);

@end

@implementation TaskModel
@end

@interface EffectVideoRender ()

@property (nonatomic, strong, readwrite) NvsEffectSdkContext *effectContext;

@property (nonatomic, strong, readwrite) NvsEffectRenderCore *renderCore;
@property (nonatomic, strong, readwrite) NvsEffectRenderCore *takePhotoRenderCore;
@property (nonatomic, strong, readwrite) dispatch_queue_t takePictureQueue;
@property (nonatomic, strong) NvsARSceneManipulate *manipulate2;

@property (nonatomic, strong, readwrite) EAGLContext *glContext;

@property (nonatomic, strong, readwrite) dispatch_queue_t videoProcessingQueue;
@property (nonatomic, strong, readwrite) NSString *queueSpecificKey;

@property (nonatomic, assign) BOOL hadInitRenderCore;


@property (nonatomic, strong) NvsARSceneManipulate *manipulate;

@property (nonatomic, assign) GLuint outputTexture;

@property (nonatomic, assign) int64_t renderCurrentTime;

@property (atomic, strong) NSMutableArray* taskArray;

@property (nonatomic, strong) CMMotionManager *coreMotionManager;
@property (nonatomic, assign) UIDeviceOrientation lastEffectiveDeviceOrientation;

@end

@implementation EffectVideoRender

-(instancetype)init{
    self = [super init];
    if (self) {
        [self setupEffectSdk];
        self.queueSpecificKey = @"Effect";
        self.takePictureQueue = dispatch_queue_create("com.meishe.Effect.takePictureQueue", DISPATCH_QUEUE_SERIAL);
        self.videoProcessingQueue = dispatch_queue_create("com.meishe.Effect.openGLESContextQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_videoProcessingQueue, (void *)[self.queueSpecificKey UTF8String], (void *)[@"Effect" UTF8String], NULL);
        
        self.glContext = [EAGLContext currentContext];
        if (!self.glContext) {
            self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
            [EAGLContext setCurrentContext:self.glContext];
        }
    }
    return self;
}

-(void)dealloc{
    NSLog(@"render: %s",__FUNCTION__);
    [self cleanUp];
}

-(void)setupEffectSdk{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // verifySdkLicenseFile
        NSString *licPath = [[NSBundle mainBundle] pathForResource:@"meishesdk" ofType:@"lic"];
        if (![NvsEffectSdkContext verifySdkLicenseFile:licPath]) {
            NSLog(@"Invalid license!");
        }
    });
#if __has_include("NvStreamingSdkCore.h")
//    [NvsStreamingContext sharedInstance];
#endif
        if([NvsEffectSdkContext hasARModule]){
#ifdef UseARScene_ST
            NSString *licSTPath = [[NSBundle mainBundle] pathForResource:@"SENSEME" ofType:@"lic"];
            NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"action5.0.0" ofType:@"model"];
            
            BOOL ret = [NvsEffectSdkContext initHumanDetection:modelPath licenseFilePath:licSTPath features:NvsHumanDetectionFeature_FaceLandmark|NvsHumanDetectionFeature_FaceAction|NvsHumanDetectionFeature_ImageMode|NvsHumanDetectionFeature_VideoMode];
            if (!ret) {
                NSLog(@"initHumanDetection error");
            }else{
                self.isInitializedARScene = YES;
            }
            /// Background segmentation model
            /// 背景分割模型
            NSString *segModel = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Segment_4.12.8" ofType:@"model"];
            ret = [NvsEffectSdkContext initHumanDetectionExt:segModel licenseFilePath:nil features:NvsEffectSdkHumanDetectionFeature_Background];
            if (!ret) {
                NSLog(@"initHumanDetectionExt error");
            }
            NSString *fakefacePath = [[NSBundle mainBundle] pathForResource:@"fakeface" ofType:@"dat"];
            [NvsEffectSdkContext setupHumanDetectionData:NvsEffectSdkHumanDetectionDataType_FakeFace dataFilePath:fakefacePath];
#else
            self.coreMotionManager = [[CMMotionManager alloc] init];
            [self.coreMotionManager startAccelerometerUpdates];
            self.lastEffectiveDeviceOrientation = UIDeviceOrientationUnknown;
#endif
        }else{
            NSLog(@"EffectSdk has no ARModule");
        }
    // init sdk
    // 初始化sdk
    self.effectContext = [NvsEffectSdkContext sharedInstance:NvsEffectSdkContextFlag_NoFlag];
    self.renderCore = [self.effectContext createEffectRenderCore];
    self.hadInitRenderCore = NO;
    self.taskArray = [NSMutableArray array];
    self.filterArray = [NSMutableArray array];
}

-(void)enableBeautyFilter:(BOOL)enable{
    if (!self.isInitializedARScene) {
        NSLog(@"AR Scene uninitialized!");
        return;
    }
    if (enable) {
        self.manipulate = self.faceEffect.getARSceneManipulate;
        [self.manipulate setDetectionMode:NvsARSceneDetectionMode_SemiImage];
    }else{
        self.faceEffect = nil;
    }
}

-(void)applyARScennePackage:(NSString*)packageId{
    if (!self.faceEffect) {
        NSLog(@"applyARScennePackage error: First call the EnableBeautyFilter method");
    }
    if (self.faceEffect) {
        [self.faceEffect setStringVal:@"Scene Id" val:packageId];
    }
}

-(NvsVideoEffect*)appendBuildInFilter:(NSString*)buildInName{
    if (!buildInName || [buildInName isEqualToString:@""]) {
        return nil;
    }
    NvsEffectRational aspectRatio = {9, 16};
    NvsVideoEffect* filterEffect = [self.effectContext createVideoEffect:buildInName aspectRatio:aspectRatio];
    if (filterEffect) {
        [self.filterArray addObject:filterEffect];
    }
    return filterEffect;
}

-(NvsVideoEffect*)appendPackageFilter:(NSString*)packageId{
    if (!packageId || [packageId isEqualToString:@""]) {
        return nil;
    }
    NvsEffectRational aspectRatio = {9, 16};
    NvsVideoEffect* filterEffect = [self.effectContext createVideoEffect:packageId aspectRatio:aspectRatio];
    if (filterEffect) {
        [self.filterArray addObject:filterEffect];
    }
    return filterEffect;
}

-(void)removeBuildInFilter:(NSString*)buildInName{
    NvsVideoEffect* filterEffect = nil;
    for (NvsVideoEffect* filter in self.filterArray) {
        if (![filter isMemberOfClass:[NvsVideoEffect class]]) {
            continue;
        }
        if ([filter.builtinName isEqualToString:buildInName]) {
            filterEffect = filter;
            break;
        }
    }
    if (filterEffect) {
        [self.filterArray removeObject:filterEffect];
    }
}

-(void)removePackageFilter:(NSString*)packageId{
    NvsVideoEffect* filterEffect = nil;
    for (NvsVideoEffect* filter in self.filterArray) {
        if ([filter respondsToSelector:@selector(packageId)] && [filter.packageId isEqualToString:packageId]) {
            filterEffect = filter;
            break;
        }
    }
    if (filterEffect) {
        [self.filterArray removeObject:filterEffect];
    }
}
//clean
//清理
-(void)cleanUp{
    if(!self.renderCore) {
        return;
    }
    [self efRunSynchronouslyOnVideoProcessingQueue:^{
        [self cleanCore];
        dispatch_async(dispatch_get_main_queue(), ^{
            logInfo(@"***** NvsEffectSdkContext destroyInstance");
            [NvsEffectSdkContext destroyInstance];
            if([NvsEffectSdkContext hasARModule]){
                [NvsEffectSdkContext closeHumanDetection];
            }
        });
    }];
}

-(void)cleanCore{
    for (NvsEffect* effect in self.filterArray) {
        [self.renderCore clearEffectResources:effect];
    }
    [self.filterArray removeAllObjects];
    if (self.faceEffect) {
        [self.renderCore clearEffectResources:self.faceEffect];
        self.faceEffect = nil;
    }
    if (self.segEffect) {
        [self.renderCore clearEffectResources:self.segEffect];
        self.segEffect = nil;
    }
    [self.renderCore clearCacheResources];
    [self.renderCore cleanUp];
    self.renderCore = nil;
    self.hadInitRenderCore = NO;
}

-(void)dealBufferWithModel:(TaskModel*)task{
    @autoreleasepool
    {
    int64_t threshold = 60000;
    int64_t checkTime = [[NSDate date] timeIntervalSince1970] * 1000000;
    if (!task.photoTask && (checkTime - task.captureTimelinePos) > threshold) {
        if (task.completion) {
            task.completion();
        }
        NSLog(@"checkTime > %lld",threshold);
        return;
    }
    
        int bufferWidth = (int)CVPixelBufferGetWidth(task.pixelBuffer);
        int bufferHeight = (int)CVPixelBufferGetHeight(task.pixelBuffer);
        
        
        if (self.segEffect) {
            [self.taskArray addObject:self.segEffect];
        }
        if (self.faceEffect) {
            [self.taskArray addObject:self.faceEffect];
        }
        for (NvsEffect* effect in self.filterArray) {
            if(![effect isKindOfClass:[NvsVideoEffectTransition class]]) {
                [self.taskArray addObject:effect];
            }
        }
        
        [self useAsCurrentContext];
        if (!self.hadInitRenderCore) {
            BOOL ret = [self.renderCore initializeWithFlags:NvsInitializeFlag_SUPPORT_16K];
            if (!ret) {
                NSLog(@"initializeWithFlags error");
            }else{
                self.hadInitRenderCore = YES;
            }
        }
        if (self.renderStartTime == 0) {
            self.renderStartTime = task.timelinePos;
        }
        int64_t timestamp = task.timelinePos - self.renderStartTime;
        
        CVPixelBufferRef pixelBufferOutput =  nil;
        if (self.taskArray.count>0) {
            if (task.photoTask) {
                [self.manipulate setDetectionMode:NvsARSceneDetectionMode_Image];
                timestamp = self.renderCurrentTime + 10000;
            }else{
                [self.manipulate setDetectionMode:NvsARSceneDetectionMode_Video];
            }
#ifdef DEBUG
            NSDate* startDate = [NSDate date];
#endif
            NSDictionary* options = @{
                NVS_EFFECT_DISPLAY_ROTATION:@(task.displayRotation),
                NVS_EFFECT_PHYSICAL_ORIENTATION:@(task.physicalOrientation),
                NVS_EFFECT_FLIP_HORIZONTALLY:@(task.flip),
                NVS_EFFECT_TIMESTAMP:@(timestamp),
                NVS_EFFECT_FLAGS:@(0),
                NVS_EFFECT_OUTPUT_FRAME_FORMAT:@(NvsEffectPixelFormat_BGRA),
                NVS_EFFECT_IS_BT601:@(YES)
            };
            
            NvsEffectCoreError error = [self.renderCore renderEffects:self.taskArray inputImage:task.pixelBuffer outputImage:&pixelBufferOutput options:options.mutableCopy];
#ifdef DEBUG
            NSDate* endDate = [NSDate date];
            int64_t timeInterval = (int64_t)([endDate timeIntervalSinceDate:startDate] * 1000000);
            if(timeInterval>38000){
                logWarning(@"renderEffects elapsed time：%lld",timeInterval);
            }
#endif
            [self.taskArray removeAllObjects];
            if (error != NvsEffectCoreError_NoError) {
                pixelBufferOutput = nil;
                NSLog(@"renderEffects:%d",error);
            }
        }else{
            pixelBufferOutput = task.pixelBuffer;
        }
        if (task.photoTask) {
            UIImage* resultImage = nil;
            if (pixelBufferOutput == task.pixelBuffer) {
                if (@available(iOS 11.0, *)) {
                    NSNumber* orientationNumber = task.photo.metadata[(NSString*)kCGImagePropertyOrientation];
                    UIImageOrientation orientation = orientationNumber.integerValue;
                    resultImage = [UIImage imageWithCGImage:task.photo.CGImageRepresentation scale:1 orientation:orientation];
                } else {
                    // Fallback on earlier versions
                }
            }else{
                UIImage *image = [NvBuffer uiImageFromPixelBuffer:pixelBufferOutput];
                resultImage = [image drawRoundedRectImage:0 width:image.size.width height:image.size.height];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(photoResultImage:taskId:)]) {
                [self.delegate photoResultImage:resultImage taskId:task.taskId];
            }
        }else{
            self.outputTexture = [self createTextureWithWidth:bufferWidth height:bufferHeight];
            [self.renderCore uploadPixelBufferToTexture:pixelBufferOutput displayRotation:task.displayRotation horizontalFlip:pixelBufferOutput == task.pixelBuffer ? task.flip : NO outputTexId:self.outputTexture];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(newFramePixelBufferReady:bufferNeedFlip:texture:timelinePos:)]) {
                [self.delegate newFramePixelBufferReady:pixelBufferOutput bufferNeedFlip:pixelBufferOutput == task.pixelBuffer texture:self.outputTexture timelinePos:timestamp];
            }
            glDeleteTextures(1, &_outputTexture);
        }
        if (pixelBufferOutput && pixelBufferOutput != task.pixelBuffer) {
            CFRelease(pixelBufferOutput);
            pixelBufferOutput = nil;
        }
        if (task.completion) {
            task.completion();
        }
    }
}

-(int64_t)dealWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
                  renderBuffer:(BOOL)renderBuffer
                          flip:(BOOL)flip
                       isFront:(BOOL)isFront {
    return [self dealWithSampleBuffer:sampleBuffer
                         renderBuffer:renderBuffer
                                 flip:flip
                              isFront:isFront
                          orientation:(AVCaptureVideoOrientationPortrait)];
}
//3024, 4032

-(int64_t)dealWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
                  renderBuffer:(BOOL)renderBuffer
                          flip:(BOOL)flip
                       isFront:(BOOL)isFront
                   orientation:(AVCaptureVideoOrientation)orientation{
    if (sampleBuffer != nil) {
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if (pixelBuffer == nil) {
            return -2;
        }
        TaskModel* task = [[TaskModel alloc] init];
        CFRetain(sampleBuffer);
        CMTime newTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        int64_t timelinePos = (int64_t)(newTime.value / 1000);
        task.pixelBuffer = pixelBuffer;
        task.timelinePos = timelinePos;
        task.captureTimelinePos = [[NSDate date] timeIntervalSince1970] * 1000000;
        task.taskId = task.captureTimelinePos;
#ifdef UseARScene_ST
        task.physicalOrientation = 0;
#else
        // physicalOrientation: 人脸在inputBuddyBuffer中的角度
        task.physicalOrientation = [self calcRecordingVideoRotation:orientation invert:isFront];;
#endif
        task.flip = flip;
        task.completion = ^{
            CFRelease(sampleBuffer);
        };
        __weak typeof(self) weakSelf = self;
        [self efRunSynchronouslyOnVideoProcessingQueue:^{
            if (renderBuffer) {
                [weakSelf dealBufferWithModel:task];
            }else{
                [weakSelf dealWithModel:task];
            }
        }];
        return task.taskId;
    }else{
        return -1;
    }
    
}

-(void)dealWithModel:(TaskModel*)task{
    @autoreleasepool
    {
        int64_t threshold = 60000;
        int64_t checkTime = [[NSDate date] timeIntervalSince1970] * 1000000;
        int64_t diffTime = checkTime - task.captureTimelinePos;
        if (!task.photoTask && diffTime > threshold) {
            if (task.completion) {
                task.completion();
            }
            logWarning(@"checkTime:%lld > %lld",diffTime,threshold);
            return;
        }
        if (self.segEffect) {
            [self.taskArray addObject:self.segEffect];
        }
        if (self.faceEffect) {
            [self.taskArray addObject:self.faceEffect];
        }
        [self.taskArray addObjectsFromArray:self.filterArray];
        [self useAsCurrentContext];
        if (!self.hadInitRenderCore) {
            BOOL ret = [self.renderCore initializeWithFlags:NvsInitializeFlag_SUPPORT_16K];
            if (!ret) {
                logError(@"initializeWithFlags error");
            }else{
                self.hadInitRenderCore = YES;
            }
        }
        int bufferWidth = (int)CVPixelBufferGetWidth(task.pixelBuffer);
        int bufferHeight = (int)CVPixelBufferGetHeight(task.pixelBuffer);
        //swap
        if(task.displayRotation == 90 || task.displayRotation == 270) {
            unsigned int temp = bufferWidth;
            bufferWidth = bufferHeight;
            bufferHeight = temp;
        }
//        if (task.photoTask) {
//            NSLog(@"initializeWithFlags");
//            NSLog(@"initializeWithFlags");
//        }
        GLuint _tmpOutputTexture = [self createTextureWithWidth:bufferWidth height:bufferHeight];
        GLuint _resultTexture = _tmpOutputTexture;
        if (self.taskArray.count == 0) {
            [self.renderCore uploadPixelBufferToTexture:task.pixelBuffer displayRotation:task.displayRotation horizontalFlip:task.flip outputTexId:_tmpOutputTexture];
        }else{
#ifdef DEBUG
            NSDate* startDate = [NSDate date];
#endif
            GLuint tmpTextureId = [self createTextureWithWidth:bufferWidth height:bufferHeight];
            [self.renderCore uploadPixelBufferToTexture:task.pixelBuffer displayRotation:task.displayRotation horizontalFlip:task.flip outputTexId:tmpTextureId];
            int cameraRotation = task.physicalOrientation;
            if (self.renderStartTime == 0) {
                self.renderStartTime = task.timelinePos;
            }
            int64_t timestamp = task.timelinePos - self.renderStartTime;
            if (task.photoTask) {
                [self.manipulate setDetectionMode:NvsARSceneDetectionMode_Image];
                timestamp = self.renderCurrentTime + 10000;
            }else{
                [self.manipulate setDetectionMode:NvsARSceneDetectionMode_Video];
            }
            self.renderCurrentTime = timestamp;
            
            NvsEffectVideoResolution videoEditRes;
            videoEditRes.imageWidth = bufferWidth;
            videoEditRes.imageHeight = bufferHeight;
            videoEditRes.imagePAR = (NvsEffectRational){1, 1};
            
            
            GLuint inputTextureId = tmpTextureId;
            GLuint outputTextureId = _tmpOutputTexture;
            NvsEffectVideoFrameInfo videoFrameInfo;
            if (self.segEffect || self.faceEffect) {
                CVPixelBufferRef buddyPixelBuffer = task.pixelBuffer;
                CVReturn ret = CVPixelBufferLockBaseAddress(buddyPixelBuffer, kCVPixelBufferLock_ReadOnly);
                [self fillVideoFrameInfoFromPixelBuffer:buddyPixelBuffer videoFrameInfo:&videoFrameInfo];
                if (ret != kCVReturnSuccess) {
                    if (task.completion) {
                        task.completion();
                    }
                    return;
                }
            }
            for (NSUInteger i = 0;i<self.taskArray.count;i++) {
                NvsVideoEffect* effect = (NvsVideoEffect*)self.taskArray[i];
                NvsEffectCoreError renderError = NvsEffectCoreError_NoError;
                if([effect isKindOfClass:[NvsVideoEffectTransition class]]) {
                    GLuint tmp = inputTextureId;
                    NSNumber *a1 = [NSNumber numberWithInt:(int)tmp];
                    NSNumber *a2 = [NSNumber numberWithInt:(int)tmp];
                    NSArray *array = @[a1, a2];
                    
                    renderError = [self.renderCore renderEffect:effect inputTexIds:array inputVideoResolution:&videoEditRes outputTexId:outputTextureId timestamp:timestamp flags: NvsRenderFlag_NoFlag];
                }else{
                    if ([effect respondsToSelector:@selector(builtinName)] && ([effect.builtinName isEqualToString:@"AR Scene"] || [effect.builtinName isEqualToString:@"Segmentation Background Fill"])) {
                        videoFrameInfo.flipHorizontally = task.flip;
                        videoFrameInfo.displayRotation = task.displayRotation;
                        renderError = [self.renderCore renderEffect:effect
                                                         inputTexId:inputTextureId
                                                   inputBuddyBuffer:&videoFrameInfo
                                                physicalOrientation:cameraRotation
                                               inputVideoResolution:&videoEditRes
                                                        outputTexId:outputTextureId
                                                          timestamp:timestamp
                                                              flags:NvsRenderFlag_NoFlag];
                    }else{
                        //INFO: -- 遇到的问题
                        //1: 设置 glPixelStorei(GL_UNPACK_ALIGNMENT, 1); 时 部分滤镜效果不对，出现彩色
                        
                        renderError = [self.renderCore renderEffect:effect inputTexId:inputTextureId inputVideoResolution:&videoEditRes outputTexId:outputTextureId timestamp:timestamp flags: NvsRenderFlag_NoFlag];
                    }
                }
                if (self.segEffect || self.faceEffect) {
                    CVPixelBufferUnlockBaseAddress(task.pixelBuffer, kCVPixelBufferLock_ReadOnly);
                }
                if(renderError != NvsEffectCoreError_NoError){
                    logError(@"renderEffect error：%d",renderError);
                    break;
                }
                _resultTexture = outputTextureId;
                if (outputTextureId == _tmpOutputTexture) {
                    inputTextureId = outputTextureId;
                    outputTextureId = _tmpOutputTexture;
                }else{
                    outputTextureId = inputTextureId;
                    inputTextureId = _tmpOutputTexture;
                }
            }
            if(_resultTexture != tmpTextureId){
                glDeleteTextures(1, &tmpTextureId);
            }
#ifdef DEBUG
            NSDate* endDate = [NSDate date];
            int64_t timeInterval = (int64_t)([endDate timeIntervalSinceDate:startDate] * 1000000);
            if(timeInterval>38000){
//                logWarning(@"Texture renderEffect elapsed time：%lld",timeInterval);
            }
#endif
        }
        if (task.photoTask) {
            //下传到buffer
            NvsEffectVideoResolution videoEditRes;
            videoEditRes.imageWidth = bufferWidth;
            videoEditRes.imageHeight = bufferHeight;
            videoEditRes.imagePAR = (NvsEffectRational){1, 1};
            CVPixelBufferRef pixelBufferOutput =  nil;
            [self.renderCore downloadPixelBufferFromTexture:_resultTexture inputVideoResolution:&videoEditRes outputFrameFormat:NvsEffectPixelFormat_BGRA isBT601:false outputFrame:&pixelBufferOutput];
            
            UIImage *image = [NvBuffer uiImageFromPixelBuffer:pixelBufferOutput];
            UIImage* cpImage = [image drawRoundedRectImage:0 width:image.size.width height:image.size.height];
            if (self.delegate && [self.delegate respondsToSelector:@selector(photoResultImage:taskId:)]) {
                [self.delegate photoResultImage:cpImage taskId:task.taskId];
            }
            CVPixelBufferRelease(pixelBufferOutput);
        }else{
            if (self.delegate && [self.delegate respondsToSelector:@selector(newFrameTextureReady:size:timelinePos:taskId:)]) {
                [self.delegate newFrameTextureReady:_resultTexture size:CGSizeMake(bufferWidth, bufferHeight) timelinePos:task.timelinePos taskId:task.taskId];
            }
        }
        if(_resultTexture != _tmpOutputTexture){
            glDeleteTextures(1, &_resultTexture);
        }
        glDeleteTextures(1, &_tmpOutputTexture);
        if (task.completion) {
            task.completion();
        }
        [self.taskArray removeAllObjects];
    }
}

-(GLuint)createTextureWithWidth:(int)width height:(int)height
{
    GLuint textureId = 0;
    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);
    
    // 设置纹理过滤规则
    // 参考https://blog.csdn.net/me_badman/article/details/56666977
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_BYTE, 0);
    return textureId;
}

-(void)efRunSynchronouslyOnVideoProcessingQueue:(void (^)(void))block
{
    dispatch_queue_t videoProcessingQueue = _videoProcessingQueue;
    if (dispatch_get_specific((void *)[self.queueSpecificKey UTF8String]))
    {
        block();
    }else
    {
        dispatch_sync(videoProcessingQueue, block);
    }
}

- (void)useAsCurrentContext{
    if ([EAGLContext currentContext] != self.glContext)
    {
        [EAGLContext setCurrentContext:self.glContext];
    }
}

-(int64_t)processingPhoto:(AVCapturePhoto *)photo
             renderBuffer:(BOOL)renderBuffer
                    output:(AVCapturePhotoOutput *)output
    isFlipHorizontally:(BOOL)isFlip API_AVAILABLE(ios(11.0)){
    //isFlip该参数间接反映了是否为前置摄像头，返回yes是前置
    CGImagePropertyOrientation orientation = [[photo.metadata objectForKey:(NSString*)kCGImagePropertyOrientation] intValue];
    int imageRotation = 0;
    if (orientation == kCGImagePropertyOrientationRight || orientation == kCGImagePropertyOrientationRightMirrored)
        imageRotation = 90;
    else if (orientation == kCGImagePropertyOrientationDown || orientation == kCGImagePropertyOrientationDownMirrored)
        imageRotation = 180;
    else if (orientation == kCGImagePropertyOrientationLeft || orientation == kCGImagePropertyOrientationLeftMirrored)
        imageRotation = 270;
    
    unsigned int tempWidth = (unsigned int)CVPixelBufferGetWidth(photo.pixelBuffer);
    unsigned int tempHeight = (unsigned int)CVPixelBufferGetHeight(photo.pixelBuffer);
    BOOL needRelease = NO;
    CVPixelBufferRef buffer = NULL;
    if (self.proportion == 1.0) {
        //按1：1比例裁剪，手机支持拍照的分辨率没有1：1，所以需要对图片进行裁剪，画幅要裁剪成1：1
        NSData *data = photo.fileDataRepresentation;
        UIImage *tempImage = [UIImage imageWithData:data];
        UIImage *tempImage_1 = [tempImage modifyImageSize:CGSizeMake(tempHeight, tempHeight)];
        if ([self isTailoringBuffer:CGSizeMake(tempWidth, tempHeight)]) {
            if (isFlip) {
                CGImageRef temp = [tempImage_1 CGImage];
                buffer = [NvBuffer pixelBufferFromCGImage:temp];
            }else{
                UIImage *tempImage_2 = [tempImage_1 scaleImageSize:[self bufferSize]];
                CGImageRef temp = [tempImage_2 CGImage];
                buffer = [NvBuffer pixelBufferFromCGImage:temp];
            }
        }else{
            CGImageRef temp = [tempImage_1 CGImage];
            buffer = [NvBuffer pixelBufferFromCGImage:temp];
        }
        needRelease = YES;
    }else if ([self isTailoringBuffer:CGSizeMake(tempWidth, tempHeight)]){
         //按比例缩放，因为某些手机支持拍照的分辨率过大，影响性能，所以需要对大尺寸图片进行缩放，画幅比例要保持和预览的一致
        NSData *data = photo.fileDataRepresentation;
        UIImage *tempImage = [UIImage imageWithData:data];
        UIImage *image2 = [tempImage scaleImageSize:[self bufferSize]];
        CGImageRef temp = [image2 CGImage];
        imageRotation = 0;
        buffer = [NvBuffer pixelBufferFromCGImage:temp];
        needRelease = YES;
    }else{
        buffer = photo.pixelBuffer;
    }
    CVPixelBufferRef pixelBuffer = buffer;
    if (pixelBuffer == nil) {
        return -1;
    }
    TaskModel* task = [[TaskModel alloc] init];
    CMTime newTime = photo.timestamp;
    int64_t timelinePos = (int64_t)(newTime.value / 1000);
    CVPixelBufferRetain(pixelBuffer);
    task.pixelBuffer = pixelBuffer;
    task.timelinePos = timelinePos;
    task.captureTimelinePos = [[NSDate date] timeIntervalSince1970] * 1000000;
    task.taskId = task.captureTimelinePos;
    task.photo = photo;
//#ifdef UseARScene_ST
//    task.physicalOrientation = 0;
//    task.displayRotation = 0;
//#else
    BOOL isFrontCamera = isFlip;
    int capturedVideoAngle = 0;
    AVCaptureConnection *captureConnection = [output connectionWithMediaType:AVMediaTypeVideo];
     const AVCaptureVideoOrientation capturedVideoOrientation = [captureConnection videoOrientation];
     switch (capturedVideoOrientation) {
     default:
     case AVCaptureVideoOrientationPortrait:
         capturedVideoAngle = 0;
         break;
     case AVCaptureVideoOrientationLandscapeRight:
         capturedVideoAngle = 90;
         break;
     case AVCaptureVideoOrientationPortraitUpsideDown:
         capturedVideoAngle = 180;
         break;
     case AVCaptureVideoOrientationLandscapeLeft:
         capturedVideoAngle = 270;
         break;
     }
    int rotationAngle = [self calcRecordingVideoRotation:capturedVideoAngle invert:isFlip];
    rotationAngle = (imageRotation + rotationAngle) % 360;
    int displayAngle = imageRotation;
    if (isFrontCamera){
        displayAngle = 360 - displayAngle;
    }
    task.displayRotation = displayAngle;
#ifdef UseARScene_ST
    task.physicalOrientation = 0;
#else
    task.physicalOrientation = rotationAngle;
#endif
    task.flip = isFlip;
    task.photoTask = YES;
    task.completion = ^{
        CVPixelBufferRelease(pixelBuffer);
        if (needRelease) {
            CVPixelBufferRelease(pixelBuffer);
        }
    };
    __weak typeof(self) weakSelf = self;
    [self efRunSynchronouslyOnVideoProcessingQueue:^{
        if (renderBuffer) {
            [weakSelf dealBufferWithModel:task];
        }else{
            [weakSelf dealWithModel:task];
        }
    }];
//    __weak typeof(self) weakSelf = self;
//    self.takePhotoRenderCore = [self.effectContext createEffectRenderCore];
//    NvsVideoEffect * takePictureFaceEffect = [self.ARSceneFxOperator createTakePictureARScene:[self.preView getMakeUpInfo]];
//    if ([self.ARSceneFxOperator.takePictureInfo objectForKey:@"Scene Id"]) {
//        [takePictureFaceEffect setStringVal:@"Scene Id" val:[self.ARSceneFxOperator.takePictureInfo objectForKey:@"Scene Id"]];
//    }
//    self.manipulate2 = takePictureFaceEffect.getARSceneManipulate;
//    [self.manipulate2 setDetectionMode:NvsARSceneDetectionMode_Image];
//
//    dispatch_async(self.takePictureQueue, ^{
//        [weakSelf takePicture:task ef:takePictureFaceEffect];
//    });
    return task.taskId;
}
- (void)takePicture:(TaskModel *)task ef:(NvsEffect *)takePictureFaceEffect{
    @autoreleasepool
    {
        int64_t threshold = 60000;
        int64_t checkTime = [[NSDate date] timeIntervalSince1970] * 1000000;
        if (!task.photoTask && (checkTime - task.captureTimelinePos) > threshold) {
            if (task.completion) {
                task.completion();
            }
            NSLog(@"checkTime > %lld",threshold);
            return;
        }
        NSMutableArray * tmpArray = [NSMutableArray array];
        if(takePictureFaceEffect)        [tmpArray addObject:takePictureFaceEffect];
        
        for (NvsEffect* effect in self.filterArray) {
            if(![effect isKindOfClass:[NvsVideoEffectTransition class]]) {
                [tmpArray addObject:effect];
            }
        }
        [self.takePhotoRenderCore initializeWithFlags:NvsInitializeFlag_SUPPORT_16K|NvsInitializeFlag_CreateGLContextIfNeed];
        
        if (self.renderStartTime == 0) {
            self.renderStartTime = task.timelinePos;
        }
        int64_t timestamp = task.timelinePos - self.renderStartTime;
        
        CVPixelBufferRef pixelBufferOutput =  nil;
        if (tmpArray.count>0) {
            [self.manipulate2 setDetectionMode:NvsARSceneDetectionMode_Image];
            timestamp = self.renderCurrentTime + 10000;
#ifdef DEBUG
            NSDate* startDate = [NSDate date];
#endif
            NSDictionary* options = @{
                NVS_EFFECT_DISPLAY_ROTATION:@(task.displayRotation),
                NVS_EFFECT_PHYSICAL_ORIENTATION:@(task.physicalOrientation),
                NVS_EFFECT_FLIP_HORIZONTALLY:@(task.flip),
                NVS_EFFECT_TIMESTAMP:@(timestamp),
                NVS_EFFECT_FLAGS:@(0),
                NVS_EFFECT_OUTPUT_FRAME_FORMAT:@(NvsEffectPixelFormat_BGRA),
                NVS_EFFECT_IS_BT601:@(YES)
            };
            NSLog(@"take picture thread:%@",[NSThread currentThread]);
            NvsEffectCoreError error = [self.takePhotoRenderCore renderEffects:tmpArray inputImage:task.pixelBuffer outputImage:&pixelBufferOutput options:options.mutableCopy];
            NSLog(@"take picture renderEffects error: %d",error);
#ifdef DEBUG
            NSDate* endDate = [NSDate date];
            int64_t timeInterval = (int64_t)([endDate timeIntervalSinceDate:startDate] * 1000000);
            if(timeInterval>38000){
                logWarning(@"renderEffects elapsed time：%lld",timeInterval);
            }
#endif
            [tmpArray removeAllObjects];
            if (error != NvsEffectCoreError_NoError) {
                pixelBufferOutput = nil;
                NSLog(@"renderEffects:%d",error);
            }
        }else{
            pixelBufferOutput = task.pixelBuffer;
        }
        UIImage* resultImage = nil;
        if (pixelBufferOutput == task.pixelBuffer) {
            if (@available(iOS 11.0, *)) {
                NSNumber* orientationNumber = task.photo.metadata[(NSString*)kCGImagePropertyOrientation];
                UIImageOrientation orientation = orientationNumber.integerValue;
                resultImage = [UIImage imageWithCGImage:task.photo.CGImageRepresentation scale:1 orientation:orientation];
            } else {
                // Fallback on earlier versions
            }
        }else{
            UIImage *image = [NvBuffer uiImageFromPixelBuffer:pixelBufferOutput];
            resultImage = [image drawRoundedRectImage:0 width:image.size.width height:image.size.height];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoResultImage:taskId:)]) {
            [self.delegate photoResultImage:resultImage taskId:task.taskId];
        }
        if (pixelBufferOutput && pixelBufferOutput != task.pixelBuffer) {
            CFRelease(pixelBufferOutput);
            pixelBufferOutput = nil;
        }
        if (task.completion) {
            task.completion();
            [self.takePhotoRenderCore clearEffectResources:takePictureFaceEffect];
            takePictureFaceEffect = nil;
            [self.takePhotoRenderCore cleanUp];
            self.takePhotoRenderCore = nil;
        }
    }
}
#pragma mark 是否需要对buffer进行裁剪
- (BOOL)isTailoringBuffer:(CGSize)size{
    if ([[NvUtils iphoneType] isEqualToString:@"iPhone 6 Plus"] && (size.width > 3000 || size.height > 3000 )) {
        return YES;
    }
    return NO;
}

#pragma mark 手机性能不佳，返回一个适合的大小进行拍照
- (CGSize)bufferSize{
    if ([[NvUtils iphoneType] isEqualToString:@"iPhone 6 Plus"]) {
        if (self.proportion == 3.0/4) {
            return CGSizeMake(960, 1280);
        }else if (self.proportion == 9.0/16){
            return CGSizeMake(720, 1280);
        }else if (self.proportion == 1){
            return CGSizeMake(960, 960);
        }
    }
    return CGSizeZero;
}

#pragma mark -- Rotation Angle calculation

- (int)calcRecordingVideoRotation:(AVCaptureVideoOrientation)capturedVideoOrientation invert:(BOOL)invert{
    const int capturedVideoAngle = [self getVideoConnectionOrientation:capturedVideoOrientation];
    const int deviceAngle = [self getUiDeviceOrientationAngle];
//    NSLog(@"calcRecordingVideoRotation:%d ## %d",capturedVideoAngle,deviceAngle);
    return [self calcRotationAngleBetween:capturedVideoAngle andgle2:deviceAngle invert:invert];
}

- (int)getVideoConnectionOrientation:(AVCaptureVideoOrientation)capturedVideoOrientation {
     int capturedVideoAngle = 0;
      switch (capturedVideoOrientation) {
      default:
      case AVCaptureVideoOrientationPortrait:
          capturedVideoAngle = 0;
          break;
      case AVCaptureVideoOrientationLandscapeRight:
          capturedVideoAngle = 90;
          break;
      case AVCaptureVideoOrientationPortraitUpsideDown:
          capturedVideoAngle = 180;
          break;
      case AVCaptureVideoOrientationLandscapeLeft:
          capturedVideoAngle = 270;
          break;
      }
      return capturedVideoAngle;
}

- (int)getUiDeviceOrientationAngle
{
    UIDeviceOrientation deviceOrientation = UIDeviceOrientationUnknown;
       if (self.coreMotionManager != nil) {
           CMAccelerometerData *accData = self.coreMotionManager.accelerometerData;
           if (accData != nil) {
               // Convert from G to m/s2, and flip axes:
               CMAcceleration acc = accData.acceleration;
               // skip update if NaN
               if (acc.x == acc.x && acc.y == acc.y && acc.z == acc.z) {
                   static const float G = 9.8066;
                   const float x = (float)(acc.x) * G * -1;
                   const float y = (float)(acc.y) * G * -1;
                   const float z = (float)(acc.z) * G * -1;

                   if (y > 7.35)
                       deviceOrientation = UIDeviceOrientationPortrait;
                   else if (y < -7.35)
                       deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
                   else if (x > 7.35)
                       deviceOrientation = UIDeviceOrientationLandscapeLeft;
                   else if (x < -7.35)
                       deviceOrientation = UIDeviceOrientationLandscapeRight;
                   else if (z > 7.35)
                       deviceOrientation = UIDeviceOrientationFaceUp;
                   else if (z < -7.35)
                       deviceOrientation = UIDeviceOrientationFaceDown;
               }
           }
       }

       if (deviceOrientation == UIDeviceOrientationPortrait ||
           deviceOrientation == UIDeviceOrientationPortraitUpsideDown ||
           deviceOrientation == UIDeviceOrientationLandscapeLeft ||
           deviceOrientation == UIDeviceOrientationLandscapeRight)
           self.lastEffectiveDeviceOrientation = deviceOrientation;
       else if (self.lastEffectiveDeviceOrientation != UIDeviceOrientationUnknown)
           deviceOrientation = self.lastEffectiveDeviceOrientation;
       else
           deviceOrientation = UIDeviceOrientationPortrait;

       switch (deviceOrientation) {
       default:
       case UIDeviceOrientationPortrait:
           return 0;
       case UIDeviceOrientationPortraitUpsideDown:
           return 180;
       case UIDeviceOrientationLandscapeLeft:
           return 90;
       case UIDeviceOrientationLandscapeRight:
           return 270;
       }
}

- (int)calcRotationAngleBetween:(int)angle1 andgle2:(int)angle2 invert:(BOOL)invert
{
    angle1 = angle1 % 360;
    if (angle1 < 0)
        angle1 += 360;

    angle2 = angle2 % 360;
    if (angle2 < 0)
        angle2 += 360;

    int rotationAngle = (angle1 - angle2 + 360) % 360;
    if (invert)
        rotationAngle = (360 - rotationAngle) % 360;

    return rotationAngle;
}


- (void)fillVideoFrameInfoFromPixelBuffer:(CVPixelBufferRef)inputImage videoFrameInfo:(NvsEffectVideoFrameInfo*)frameInfo
{
    OSType pixelFormat = CVPixelBufferGetPixelFormatType(inputImage);
    unsigned int width = (unsigned int)CVPixelBufferGetWidth(inputImage);
    unsigned int height = (unsigned int)CVPixelBufferGetHeight(inputImage);
    frameInfo->frameWidth = width;
    frameInfo->frameHeight = height;
    
    if (pixelFormat == kCVPixelFormatType_32BGRA) {
        frameInfo->pixelFormat = NvsEffectPixelFormat_BGRA;
        frameInfo->isFullRangeYUV = true;
        frameInfo->isRec601 = NO;
        frameInfo->displayRotation = 0;
    } else if (pixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        frameInfo->pixelFormat = NvsEffectPixelFormat_Nv12;
        frameInfo->isFullRangeYUV = false;
        frameInfo->isRec601 = NO;
        frameInfo->displayRotation = 0;
    } else if (pixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        frameInfo->pixelFormat = NvsEffectPixelFormat_Nv12;
        frameInfo->isFullRangeYUV = true;
        frameInfo->isRec601 = NO;
        frameInfo->displayRotation = 0;
    }
    if (!CVPixelBufferIsPlanar(inputImage)) {
        frameInfo->planePtr[0] = CVPixelBufferGetBaseAddress(inputImage);
        frameInfo->planeRowPitch[0] = (int)CVPixelBufferGetBytesPerRow(inputImage);
    } else {
        for (int p = 0; p < CVPixelBufferGetPlaneCount(inputImage); p++) {
            frameInfo->planePtr[p] = CVPixelBufferGetBaseAddressOfPlane(inputImage, p);
            frameInfo->planeRowPitch[p] = (int)CVPixelBufferGetBytesPerRowOfPlane(inputImage, p);
        }
    }
}

@end
