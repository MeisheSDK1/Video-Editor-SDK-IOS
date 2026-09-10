//
//  EFPreview.m
//  GPUImageEffectDemo
//
//  Created by 美摄 on 2021/3/2.
//

#import "EFPreview.h"
#import "EFBGRAProgram.h"
#import <OpenGLES/EAGLDrawable.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@interface EFPreview ()
{
    GLuint displayRenderbuffer, displayFramebuffer;
    
    CGSize inputImageSize;
    GLfloat imageVertices[8];
    GLfloat bufferVertices[8];
    GLfloat backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha;
    
    CGSize boundsSizeAtFrameBufferEpoch;
    
    CVOpenGLESTextureRef _cvCameraTexture;
    
    CVOpenGLESTextureRef _lumaTexture;
    CVOpenGLESTextureRef _chromaTexture;
}
@property (nonatomic,strong) EFBGRAProgram *bgraProgram;
@property (assign, nonatomic) NSUInteger aspectRatio;

@property (assign, atomic) BOOL hasCleanUp;

@property (nonatomic, assign) GLuint currentTextureId;
@property (nonatomic, assign) CVOpenGLESTextureCacheRef cvTextureCache;
@property (nonatomic, assign,readwrite) CGSize bufferAspectRatio;

@property (nonatomic, strong) EAGLContext *glContext;

// Initialization and teardown
- (void)commonInit;

// Managing the display FBOs
- (void)createDisplayFramebuffer;
- (void)destroyDisplayFramebuffer;

// Handling fill mode
- (void)recalculateViewGeometry;

@end

@implementation EFPreview

@synthesize aspectRatio;
@synthesize sizeInPixels = _sizeInPixels;

#pragma mark -
#pragma mark Initialization and teardown

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
                    glContext:(EAGLContext*)glContext{
    self = [super initWithFrame:frame];
    if (self) {
        self.glContext = glContext;
        _cvCameraTexture = NULL;
        self.bgraProgram = nil;
        [self commonInit];
    }
    return self;;
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])){
        return nil;
    }
    [self commonInit];
    return self;
}

-(id)initWithCoder:(NSCoder *)coder
{
    if (!(self = [super initWithCoder:coder])){
        return nil;
    }
    [self commonInit];
    return self;
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
    [self cleanUp];
}

- (void)commonInit;
{
    // Set scaling to account for Retina display
    if ([self respondsToSelector:@selector(setContentScaleFactor:)]){
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
    }
    self.opaque = YES;
    self.hidden = NO;
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    __weak typeof(self) weakSelf = self;
    [weakSelf useAsCurrentContext];
    [self setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    weakSelf.fillMode = EFPreviewFillModePreserveAspectRatio;
    [self createDisplayFramebuffer];   
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // The frame buffer needs to be trashed and re-created when the view size changes.
    if (!CGSizeEqualToSize(self.bounds.size, boundsSizeAtFrameBufferEpoch) &&
        !CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        [self destroyDisplayFramebuffer];
        [self createDisplayFramebuffer];
        [self recalculateViewGeometry];
    }
}

-(void)cleanUp{
    [self destroyDisplayFramebuffer];
    self.hasCleanUp = YES;
    if (_cvTextureCache) {
        CFRelease(_cvTextureCache);
        _cvTextureCache = nil;
    }
}


#pragma mark -
#pragma mark Managing the display FBOs

- (void)useAsCurrentContext{
    if ([EAGLContext currentContext] != self.glContext){
        [EAGLContext setCurrentContext:self.glContext];
    }
}

- (void)createDisplayFramebuffer{
    [self useAsCurrentContext];
    
    glGenFramebuffers(1, &displayFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, displayFramebuffer);
    
    glGenRenderbuffers(1, &displayRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, displayRenderbuffer);
    
    [self.glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    
    GLint backingWidth, backingHeight;
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    if ( (backingWidth == 0) || (backingHeight == 0) )
    {
        [self destroyDisplayFramebuffer];
        return;
    }
    
    _sizeInPixels.width = (CGFloat)backingWidth;
    _sizeInPixels.height = (CGFloat)backingHeight;
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, displayRenderbuffer);
    
    GLuint framebufferCreationStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(framebufferCreationStatus == GL_FRAMEBUFFER_COMPLETE, @"Failure with display framebuffer generation for display of size: %f, %f", self.bounds.size.width, self.bounds.size.height);
    boundsSizeAtFrameBufferEpoch = self.bounds.size;
}

- (void)destroyDisplayFramebuffer;
{
    [self useAsCurrentContext];
    [self cleanTexture];
    if (displayFramebuffer){
        glDeleteFramebuffers(1, &displayFramebuffer);
        displayFramebuffer = 0;
    }
    
    if (displayRenderbuffer){
        glDeleteRenderbuffers(1, &displayRenderbuffer);
        displayRenderbuffer = 0;
    }
}

- (void)setDisplayFramebuffer;
{
    if (!displayFramebuffer)
    {
        [self createDisplayFramebuffer];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, displayFramebuffer);
    
    glViewport(0, 0, (GLint)_sizeInPixels.width, (GLint)_sizeInPixels.height);
}

- (void)presentFramebuffer;
{
    glBindRenderbuffer(GL_RENDERBUFFER, displayRenderbuffer);
    BOOL presentResult = [self.glContext presentRenderbuffer:GL_RENDERBUFFER];
    if (!presentResult) {
        NSLog(@"presentRenderbuffer error");
    }
    [self cleanTexture];
}

-(void)cleanTexture{
    self.currentTextureId = 0;
    if (_cvCameraTexture) {
        CFRelease(_cvCameraTexture);
        _cvCameraTexture = nil;
    }
    if (_chromaTexture) {
        CFRelease(_chromaTexture);
        _chromaTexture = nil;
    }
    if (_lumaTexture) {
        CFRelease(_lumaTexture);
        _lumaTexture = nil;
    }
}

#pragma mark -
#pragma mark Handling fill mode

- (void)recalculateViewGeometry;
{
    __weak typeof(self) weakSelf = self;
    CGFloat heightScaling, widthScaling;
    
    CGSize currentViewSize = boundsSizeAtFrameBufferEpoch;
    if (CGSizeEqualToSize(inputImageSize, CGSizeZero)) {
        return;
    }
    CGRect viewRect = CGRectMake(0, 0, currentViewSize.width, currentViewSize.height);
    CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(inputImageSize, viewRect);
    
    switch(weakSelf.fillMode)
    {
        case EFPreviewFillModeStretch:
        {
            widthScaling = 1.0;
            heightScaling = 1.0;
        }; break;
        case EFPreviewFillModePreserveAspectRatio:
        {
            widthScaling = insetRect.size.width / currentViewSize.width;
            heightScaling = insetRect.size.height / currentViewSize.height;
        }; break;
        case EFPreviewFillModePreserveAspectRatioAndFill:
        {
            //            CGFloat widthHolder = insetRect.size.width / currentViewSize.width;
            widthScaling = currentViewSize.height / insetRect.size.height;
            heightScaling = currentViewSize.width / insetRect.size.width;
        }; break;
    }
    
    imageVertices[0] = -widthScaling;
    imageVertices[1] = heightScaling;
    imageVertices[2] = widthScaling;
    imageVertices[3] = heightScaling;
    imageVertices[4] = -widthScaling;
    imageVertices[5] = -heightScaling;
    imageVertices[6] = widthScaling;
    imageVertices[7] = -heightScaling;
    
    
    bufferVertices[0] = -widthScaling;
    bufferVertices[1] = -heightScaling;
    bufferVertices[2] = widthScaling;
    bufferVertices[3] = -heightScaling;
    bufferVertices[4] = -widthScaling;
    bufferVertices[5] = heightScaling;
    bufferVertices[6] = widthScaling;
    bufferVertices[7] = heightScaling;
}

- (void)setBackgroundColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent alpha:(GLfloat)alphaComponent;
{
    backgroundColorRed = redComponent;
    backgroundColorGreen = greenComponent;
    backgroundColorBlue = blueComponent;
    backgroundColorAlpha = alphaComponent;
}


#pragma mark -
#pragma mark GPUInput protocol

static const GLfloat noRotationTextureCoordinates[] = {
    0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f,
};

- (void)newFrameReadyTexture:(GLuint)texture size:(CGSize)size{
    if (self.hasCleanUp) {
        return;
    }
    [self useAsCurrentContext];
    __weak typeof(self) weakSelf = self;
    [self setInputSize:size];
    if (!self.bgraProgram) {
        self.bgraProgram = [[EFBGRAProgram alloc] init];
    }
    [self.bgraProgram use];
    [self setDisplayFramebuffer];
    [self glCheckError];
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glVertexAttribPointer(weakSelf.bgraProgram.displayPositionAttribute, 2, GL_FLOAT, 0, 0, imageVertices);
    glVertexAttribPointer(weakSelf.bgraProgram.displayTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, noRotationTextureCoordinates);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self.bgraProgram unuse];
    [self presentFramebuffer];
}

-(void)resetAspectRatio:(CGSize)aspectRatio{
    if (!CGSizeEqualToSize(aspectRatio, self.bufferAspectRatio)) {
        self.bufferAspectRatio = aspectRatio;
    }
}
- (void)bindTexture:(GLint)texture {
    glBindTexture(GL_TEXTURE_2D, texture);
    [self glCheckError];
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}
- (BOOL)setupLumaTextureWithPixelBuffer:(CVPixelBufferRef)pixelBuffer{
    if (pixelBuffer == nil) {
        return NO;
    }
    int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    if (_cvCameraTexture) {
        CFRelease(_cvCameraTexture);
        _cvCameraTexture = nil;
    }
    OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    CVReturn cvRet;
    if (pixelFormat == kCVPixelFormatType_32BGRA) {
        cvRet = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                             _cvTextureCache,
                                                             pixelBuffer,
                                                             NULL,
                                                             GL_TEXTURE_2D,
                                                             GL_RGBA,
                                                             bufferWidth,
                                                             bufferHeight,
                                                             GL_BGRA,
                                                             GL_UNSIGNED_BYTE,
                                                             0,
                                                             &_cvCameraTexture);
        if (!_cvCameraTexture || kCVReturnSuccess != cvRet) {
            NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage %d" , cvRet);
            return NO;
        }
        self.currentTextureId = CVOpenGLESTextureGetName(_cvCameraTexture);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, self.currentTextureId);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        [self glCheckError];
    }else{
        CVOpenGLESTextureRef lumaTexture,chromaTexture;
        // Y
        glActiveTexture(GL_TEXTURE0);
        cvRet = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                             _cvTextureCache,
                                                             pixelBuffer,
                                                             NULL,
                                                             GL_TEXTURE_2D,
                                                             GL_LUMINANCE,
                                                             bufferWidth,
                                                             bufferHeight,
                                                             GL_LUMINANCE,
                                                             GL_UNSIGNED_BYTE,
                                                             0,
                                                             &lumaTexture);
        if (cvRet) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", cvRet);
        }else {
            _lumaTexture = lumaTexture;
        }
        self.currentTextureId = CVOpenGLESTextureGetName(_lumaTexture);
        glBindTexture(CVOpenGLESTextureGetTarget(lumaTexture), CVOpenGLESTextureGetName(lumaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        // UV
        glActiveTexture(GL_TEXTURE1);
        cvRet = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                             _cvTextureCache,
                                                             pixelBuffer,
                                                             NULL,
                                                             GL_TEXTURE_2D,
                                                             GL_LUMINANCE_ALPHA,
                                                             bufferWidth / 2,
                                                             bufferHeight / 2,
                                                             GL_LUMINANCE_ALPHA,
                                                             GL_UNSIGNED_BYTE,
                                                             1,
                                                             &chromaTexture);
        if (cvRet) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", cvRet);
        }else {
            _chromaTexture = chromaTexture;
        }
        
        glBindTexture(CVOpenGLESTextureGetTarget(chromaTexture), CVOpenGLESTextureGetName(chromaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
    
    return YES;
}

- (void)setInputSize:(CGSize)newSize{
    CGSize rotatedSize = newSize;
    if (!CGSizeEqualToSize(inputImageSize, rotatedSize)){
        inputImageSize = rotatedSize;
        [self recalculateViewGeometry];
    }
}

- (void)setFillMode:(EFPreviewFillModeType)newValue;{
    _fillMode = newValue;
    [self recalculateViewGeometry];
}

- (void)glCheckError {
    GLenum glErr = glGetError();
    if (glErr != GL_NO_ERROR) {
        NSLog(@"Render Core GL error:%d", glErr);
    }
}

@end
