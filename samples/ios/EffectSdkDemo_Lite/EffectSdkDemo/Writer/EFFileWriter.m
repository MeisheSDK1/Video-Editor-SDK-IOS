//
//  EFFileWriter.m
//  GPUImageEffectDemo
//
//  Created by 美摄 on 2021/3/8.
//

#import "EFFileWriter.h"
#import <OpenGLES/ES2/gl.h>
#import "EFBGRAProgram.h"

@interface EFFileWriter ()
{
    NSURL *_URL;
    BOOL _haveStartedSession;
    NSDictionary *_audioTrackSettings;
    AVAssetWriterInput *_audioInput;
    
    CGAffineTransform _videoTrackTransform;
    NSDictionary *_videoTrackSettings;
    AVAssetWriterInput *_videoInput;
    AVAssetWriterInputPixelBufferAdaptor *_adaptor;
    AVAssetWriterInputPixelBufferAdaptor *_audioAdaptor;
    int _bufferWidth;
    int _bufferHeight;
    
    
    GLuint movieFramebuffer, movieRenderbuffer;
    CVPixelBufferRef _renderTarget;
    CVOpenGLESTextureRef _renderTexture;
    CGSize _videoSize;
}

@property(nonatomic, strong) __attribute__((NSObject)) CMFormatDescriptionRef outputVideoFormatDescription;
@property(nonatomic, strong) __attribute__((NSObject)) CMFormatDescriptionRef outputAudioFormatDescription;
@property(nonatomic, strong) AVAssetWriter *assetWriter;

@property(atomic, assign, readwrite) BOOL isRecording;

@property (nonatomic, strong) EAGLContext *glContext;
@property (nonatomic,strong) EFBGRAProgram *bgraProgram;
@property (nonatomic, assign) CVOpenGLESTextureCacheRef cvTextureCache;

@property (nonatomic, strong, readwrite) dispatch_queue_t videoProcessingQueue;
@property (nonatomic, strong, readwrite) NSString *queueSpecificKey;

@property (assign, atomic) BOOL hasCleanUp;

@end

@implementation EFFileWriter

- (instancetype)initWithGlContext:(EAGLContext*)glContext{
    self = [super init];
    if (self) {
        self.queueSpecificKey = @"Effect";
        self.videoProcessingQueue = dispatch_queue_create("com.meishe.Effect.openGLESContextQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_videoProcessingQueue, (void *)[self.queueSpecificKey UTF8String], (void *)[@"Effect" UTF8String], NULL);
        
        self.glContext = glContext;
        self.outputVideoFormatDescription = nil;
        self.outputAudioFormatDescription = nil;
        _videoTrackTransform = CGAffineTransformIdentity;
        _videoTrackSettings = nil;
        _audioTrackSettings = nil;
        self.isRecording = NO;
    }
    return self;
}

-(void)dealloc{
    NSLog(@"Writer: %s",__FUNCTION__);
}

-(void)setupFormatDescription:(CMSampleBufferRef)sampleBuffer{
//    if (!self.isRecording) {
//        return;
//    }
    
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    CMMediaType type = CMFormatDescriptionGetMediaType(formatDescription);
    
    if (type == kCMMediaType_Video) {
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if (!pixelBuffer) {
            return;
        }
        int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
        int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
        if (_bufferWidth != bufferWidth || _bufferHeight != bufferHeight) {
            self.outputVideoFormatDescription = nil;
        }else{
            return;
        }
    }
    
    if (self.outputVideoFormatDescription && self.outputAudioFormatDescription) {
        return;
    }
    
    CFRetain(sampleBuffer);
    [self efRunSynchronouslyOnVideoProcessingQueue:^{
        if (type == kCMMediaType_Video && self.outputVideoFormatDescription == nil) {
            self.outputVideoFormatDescription = formatDescription;
            CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
            int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
            self->_bufferWidth = bufferWidth;
            self->_bufferHeight = bufferHeight;
        }else if (type == kCMMediaType_Audio && self.outputAudioFormatDescription == nil){
            self.outputAudioFormatDescription = formatDescription;
        }
        CFRelease(sampleBuffer);
    }];
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

-(BOOL)startRecordWithFilePath:(NSString*)filePath{
    NSError *error = nil;
    _URL = [NSURL fileURLWithPath:filePath];
    if (!_URL) {
        return NO;
    }
    _assetWriter = [[AVAssetWriter alloc] initWithURL:_URL fileType:AVFileTypeMPEG4 error:&error];
    if ( ! error && self.outputVideoFormatDescription ) {
        [self setupAssetWriterVideoInputWithSourceFormatDescription:self.outputVideoFormatDescription transform:_videoTrackTransform settings:self->_videoTrackSettings error:&error];
    }else{
        NSLog(@"_videoTrackSourceFormatDescription  nil ");
        return NO;
    }
    
    if ( ! error && self.outputAudioFormatDescription ) {
        NSLog(@"执行添加音频 Perform add audio");
        [self setupAssetWriterAudioInputWithSourceFormatDescription:self.outputAudioFormatDescription settings:self->_audioTrackSettings error:&error];
    }else{
        NSLog(@"没有执行添加音频 Add audio is not performed");
        return NO;
    }
    
    if (error) {
        NSLog(@"录制失败 Recording failure%@",[error description]);
        return NO;
    }
    
    self.isRecording = YES;
    return YES;
}

-(void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    if (!self.isRecording) {
        return;
    }
    [self efRunSynchronouslyOnVideoProcessingQueue:^{
        if (self.assetWriter.status != AVAssetWriterStatusWriting ) {
            return;
        }
        if( self.assetWriter.status > AVAssetWriterStatusWriting ){
            NSLog(@"Warning: writer status is %ld", (long)self.assetWriter.status);
            if( self.assetWriter.status == AVAssetWriterStatusFailed ){
                NSLog(@"Error: %@", self.assetWriter.error);
            }
            return;
        }
        if ( sampleBuffer == NULL ) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL sample buffer" userInfo:nil];
            return;
        }
        
        CFRetain( sampleBuffer );
        @autoreleasepool
        {
            
            AVAssetWriterInput *input = self->_audioInput;
            if ( input.readyForMoreMediaData )
            {
                BOOL success = [input appendSampleBuffer:sampleBuffer];
                if ( ! success ) {
                    NSLog(@" appendSampleBuffer Failed");
                }
            }
            else
            {
                NSLog( @"audio input not ready for more media data, dropping buffer");
            }
            CFRelease(sampleBuffer);
        }
    }];
}

-(void)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer timelinePos:(int64_t)timelinePos{
    if (!self.isRecording) {
        return;
    }
    CVPixelBufferRetain(pixelBuffer);
    [self efRunSynchronouslyOnVideoProcessingQueue:^{
        CMTime timestamp = CMTimeMake(timelinePos, USEC_PER_SEC);
        if (self.assetWriter.status != AVAssetWriterStatusWriting ) {
            [self.assetWriter startWriting];
            [self.assetWriter startSessionAtSourceTime:timestamp];
        }
        if(self.assetWriter.status > AVAssetWriterStatusWriting ){
            NSLog(@"Warning: writer status is %ld", (long)self.assetWriter.status);
            if(self.assetWriter.status == AVAssetWriterStatusFailed ){
                NSLog(@"Error: %@", self.assetWriter.error);
            }
            return;
        }
        if (self->_videoInput.readyForMoreMediaData) {
            if (![self->_adaptor appendPixelBuffer:pixelBuffer withPresentationTime:timestamp]) {
                NSLog(@"adptor Failed");
            }
        }else{
            NSLog( @"video input not ready for more media data, dropping buffer" );
        }
        
        CVPixelBufferRelease(pixelBuffer);
    }];
}

-(void)stopRecordWithCompletionHandler:(void (^)(NSString*))handler{
    if (!self.isRecording) {
        return;
    }
    dispatch_sync(self.videoProcessingQueue, ^{
        AVAssetWriterStatus status = self.assetWriter.status;
        if (status != AVAssetWriterStatusUnknown) {
            [self.assetWriter finishWritingWithCompletionHandler:^{
                [self->_videoInput markAsFinished];
                [self->_audioInput markAsFinished];
                self->_assetWriter = nil;
                self->_videoInput = nil;
                self->_audioInput = nil;
                self->_adaptor = nil;
                if (handler) {
                    handler(self->_URL.path);
                    self->_URL = nil;
                }
            }];
        }else{
            NSLog(@"video failure==%@==%ld",self->_assetWriter.error,(long)status);
            if (handler) {
                self->_URL = nil;
                handler(self->_URL.path);
            }
        }
        self.isRecording = NO;
    });
}


#pragma mark 根据源描述信息设置audioInput
//audioInput is set according to the source description information
- (BOOL)setupAssetWriterAudioInputWithSourceFormatDescription:(CMFormatDescriptionRef)audioFormatDescription settings:(NSDictionary *)audioSettings error:(NSError **)errorOut
{
    if ( ! audioSettings ) {
        NSLog( @"No audio settings provided, using default settings" );
        audioSettings = @{ AVFormatIDKey : @(kAudioFormatMPEG4AAC) };
    }
    
    if ( [_assetWriter canApplyOutputSettings:audioSettings forMediaType:AVMediaTypeAudio] )
    {
        _audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioSettings sourceFormatHint:audioFormatDescription];
        _audioInput.expectsMediaDataInRealTime = YES;
        
        if ( [_assetWriter canAddInput:_audioInput] )
        {
            [_assetWriter addInput:_audioInput];
        }
        else
        {
            if ( errorOut ) {
                *errorOut = [[self class] cannotSetupInputError];
            }
            return NO;
        }
    }
    else
    {
        if ( errorOut ) {
            *errorOut = [[self class] cannotSetupInputError];
        }
        return NO;
    }
    
    return YES;
}

#pragma mark 根据源描述信息设置videoInput
//Set the videoInput based on the source description
- (BOOL)setupAssetWriterVideoInputWithSourceFormatDescription:(CMFormatDescriptionRef)videoFormatDescription transform:(CGAffineTransform)transform settings:(NSDictionary *)videoSettings error:(NSError **)errorOut
{
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions( videoFormatDescription );
    if ( ! videoSettings )
    {
        float bitsPerPixel = 0.0;
        
        
        int numPixels = dimensions.width * dimensions.height;
        int bitsPerSecond;

        // Assume that lower-than-SD resolutions are intended for streaming, and use a lower bitrate
        //假设低于sd的分辨率用于流媒体，并使用较低的比特率
        if ( numPixels <= ( 640 * 480 ) ) {
            bitsPerPixel = 4.05;
            // This bitrate approximately matches the quality produced by AVCaptureSessionPresetMedium or Low.
            //他的比特率大致与AVCaptureSessionPresetMedium或Low产生的质量相当。
        }else if( numPixels <= ( 1920 * 1080 ) ) {
            bitsPerPixel = 6.1;
        }else{
             bitsPerPixel = 10.1;
            // This bitrate approximately matches the quality produced by AVCaptureSessionPresetHigh.
            //他的比特率与avcapturesessionprese产生的质量大致相当。
        }
        
        bitsPerSecond = numPixels * bitsPerPixel;
        
        NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                                 AVVideoExpectedSourceFrameRateKey : @(30),
                                                 AVVideoMaxKeyFrameIntervalKey : @(30),
                                                 
        };
        
        videoSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                           AVVideoWidthKey : @(dimensions.width),
                           AVVideoHeightKey : @(dimensions.height),
                           AVVideoCompressionPropertiesKey : compressionProperties };
        
    }
    
    if ( [_assetWriter canApplyOutputSettings:videoSettings forMediaType:AVMediaTypeVideo] )
    {
        _videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoSettings sourceFormatHint:videoFormatDescription];
        _videoInput.expectsMediaDataInRealTime = YES;
        _videoInput.transform = transform;
        if ( [_assetWriter canAddInput:_videoInput] )
        {
            [_assetWriter addInput:_videoInput];
            
            NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                                                   [NSNumber numberWithInt:dimensions.width], kCVPixelBufferWidthKey,
                                                                   [NSNumber numberWithInt:dimensions.height], kCVPixelBufferHeightKey,
                                                                   nil];
            
            _adaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:_videoInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
        }
        else
        {
            if ( errorOut ) {
                *errorOut = [[self class] cannotSetupInputError];
            }
            return NO;
        }
    }
    else
    {
        if ( errorOut ) {
            *errorOut = [[self class] cannotSetupInputError];
        }
        return NO;
    }
    
    return YES;
}

+ (NSError *)cannotSetupInputError
{
    NSString *localizedDescription = NSLocalizedString( @"Recording cannot be started", nil );
    NSString *localizedFailureReason = NSLocalizedString( @"Cannot setup asset writer input.", nil );
    NSDictionary *errorDict = @{ NSLocalizedDescriptionKey : localizedDescription,
                                 NSLocalizedFailureReasonErrorKey : localizedFailureReason };
    return [NSError errorWithDomain:@"com.apple.dts.samplecode" code:0 userInfo:errorDict];
}


//MARK: -- supportsFastTextureUpload

-(void)appendTexture:(GLuint)texture videoSize:(CGSize)videoSize timelinePos:(int64_t)timelinePos{
    if (!self.isRecording) {
        return;
    }
    if (self.hasCleanUp) {
        return;
    }
    CMTime timestamp = CMTimeMake(timelinePos, USEC_PER_SEC);
    if (self.assetWriter.status != AVAssetWriterStatusWriting) {
        [self.assetWriter startWriting];
        [self.assetWriter startSessionAtSourceTime:timestamp];
    }
    
    _videoSize = videoSize;
    
    [self renderAtInternalSizeUsingTexture:texture];
    GLenum glErr = glGetError();
    if (glErr != GL_NO_ERROR) {
        NSLog(@"appendTexture GL error:%d", glErr);
    }else{
        [self appendPixelBuffer:_renderTarget timelinePos:timelinePos];
    }
}

- (void)useAsCurrentContext{
    if ([EAGLContext currentContext] != self.glContext){
        [EAGLContext setCurrentContext:self.glContext];
    }
}

- (void)createDataFBO;
{
    // 创建采集纹理环境
    if (_cvTextureCache == 0) {
        CVReturn ret = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.glContext, NULL, &(self->_cvTextureCache));
        if (ret != kCVReturnSuccess){
            NSLog(@"Failed to create OpenGL texture cache! errno=%d.", ret);
            return;
        }
    }
    
    glActiveTexture(GL_TEXTURE1);
    glGenFramebuffers(1, &movieFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, movieFramebuffer);
    
    // Code originally sourced from http://allmybrain.com/2011/12/08/rendering-to-a-texture-with-ios-5-texture-cache-api/
    
    
    CVPixelBufferPoolCreatePixelBuffer (NULL, [_adaptor pixelBufferPool], &_renderTarget);
    
    /* AVAssetWriter will use BT.601 conversion matrix for RGB to YCbCr conversion
     * regardless of the kCVImageBufferYCbCrMatrixKey value.
     * Tagging the resulting video file as BT.601, is the best option right now.
     * Creating a proper BT.709 video is not possible at the moment.
     * AVAssetWriter将使用BT.601转换矩阵进行RGB到YCbCr的转换
     *不考虑kCVImageBufferYCbCrMatrixKey的值。
     *将生成的视频文件标记为BT.601，是目前最好的选择。
     *目前无法创建一个合适的BT.709视频。
     */
    CVBufferSetAttachment(_renderTarget, kCVImageBufferColorPrimariesKey, kCVImageBufferColorPrimaries_ITU_R_709_2, kCVAttachmentMode_ShouldPropagate);
    CVBufferSetAttachment(_renderTarget, kCVImageBufferYCbCrMatrixKey, kCVImageBufferYCbCrMatrix_ITU_R_601_4, kCVAttachmentMode_ShouldPropagate);
    CVBufferSetAttachment(_renderTarget, kCVImageBufferTransferFunctionKey, kCVImageBufferTransferFunction_ITU_R_709_2, kCVAttachmentMode_ShouldPropagate);
    
    CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault, _cvTextureCache, _renderTarget,
                                                  NULL, // texture attributes
                                                  GL_TEXTURE_2D,
                                                  GL_RGBA, // opengl format
                                                  (int)_videoSize.width,
                                                  (int)_videoSize.height,
                                                  GL_BGRA, // native iOS format
                                                  GL_UNSIGNED_BYTE,
                                                  0,
                                                  &_renderTexture);
    
    glBindTexture(CVOpenGLESTextureGetTarget(_renderTexture), CVOpenGLESTextureGetName(_renderTexture));
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(_renderTexture), 0);
    
    
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
}

- (void)destroyDataFBO;
{
    [self useAsCurrentContext];
    
    if (movieFramebuffer)
    {
        glDeleteFramebuffers(1, &movieFramebuffer);
        movieFramebuffer = 0;
    }
    
    if (movieRenderbuffer)
    {
        glDeleteRenderbuffers(1, &movieRenderbuffer);
        movieRenderbuffer = 0;
    }
    
    if (_renderTexture)
    {
        CFRelease(_renderTexture);
        _renderTexture = nil;
    }
    if (_renderTarget)
    {
        CVPixelBufferRelease(_renderTarget);
        _renderTarget = nil;
    }
}

- (void)setFilterFBO;
{
    if (!movieFramebuffer)
    {
        [self createDataFBO];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, movieFramebuffer);
    
    glViewport(0, 0, (int)_videoSize.width, (int)_videoSize.height);
}

- (void)renderAtInternalSizeUsingTexture:(GLuint)texture;
{
    [self useAsCurrentContext];
    [self setFilterFBO];
    
    if (!self.bgraProgram) {
        self.bgraProgram = [[EFBGRAProgram alloc] init];
    }
    [self.bgraProgram use];
    
    glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // This needs to be flipped to write out to video correctly
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(self.bgraProgram.displayInputTextureUniform, 4);
    
    glVertexAttribPointer(self.bgraProgram.displayPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(self.bgraProgram.displayTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, noRotationTextureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glFlush();
}

static const GLfloat noRotationTextureCoordinates[] = {
    0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f,
};


-(void)cleanUp{
    self.hasCleanUp = YES;
    [self destroyDataFBO];
    if (_cvTextureCache) {
        CFRelease(_cvTextureCache);
        _cvTextureCache = nil;
    }
    self.bgraProgram = nil;
}

@end
