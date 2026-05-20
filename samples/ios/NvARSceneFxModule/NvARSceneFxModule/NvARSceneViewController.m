//
//  NvARSceneViewController.m
//  NvARSceneFxModule
//
//  Created by ms20180425 on 2022/8/30.
//

//#define TXLiteAVSDK

#import "NvARSceneViewController.h"
#import "NvsEffectSdkContext.h"
#import <OpenGLES/ES2/glext.h>
#import "EFPreview.h"
#import "EFCapture.h"

#import "NvARSceneFxOperator.h"
#import "NvARScenePreview.h"

#import "NvARLocalString.h"

@interface NvARSceneViewController ()

/// EAGLContext
@property (nonatomic, strong) EAGLContext *glContext;
/// CIContext
@property (nonatomic, strong) CIContext *ciContext;
/// sdk
@property (nonatomic, strong) NvsEffectSdkContext *effectContext;
/// 渲染类 Rendering classes
@property (nonatomic, strong) NvsEffectRenderCore *renderHandle;
/// 渲染大小 Render size
@property (nonatomic, assign) CGSize bufferSize;
/// 相机 camera
@property(nonatomic,strong) EFCapture* efCapture;
/// 预览视图 Preview view
@property(nonatomic,strong) EFPreview* preview;
/// 渲染之后输出的纹理 Rendered texture output
@property(nonatomic,assign) GLuint outputTextureId;

@property (nonatomic, strong) NvARSceneFxOperator *ARSceneFxOperator;

@property (nonatomic, strong) NvARScenePreview *scenePreview;

@end

@implementation NvARSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatOpenGL];
    
    /*
     开启摄像头
     Turn on the camera
     */
    self.efCapture = [[EFCapture alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720
                                               cameraPosition:AVCaptureDevicePositionFront
                                              dataOutputQueue:dispatch_get_main_queue()
                                                     delegate:self];
    /*
     创建纹理承载视图
     Create a texture bearing view
     */
    self.preview = [[EFPreview alloc] initWithFrame:self.view.frame
                                          glContext:_glContext];
    [self.view addSubview:self.preview];
    
    /*
     sdk授权
     sdk Licensing
     */
    
    NSString *bundlePath = [[[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"license.bundle"] stringByAppendingPathComponent:@"license"];
    NSString *licPath = [bundlePath stringByAppendingPathComponent:@"meishesdk.lic"];
    if (![NvsEffectSdkContext verifySdkLicenseFile:licPath]) {
        NSLog(@"Invalid license!");
        return;
    }
    
    /*
     打印sdk版本号
     Print the sdk version number
     */
    int a,b,c = 0;
    [NvsEffectSdkContext getSdkVersion:&a minorVersion:&b revisionNumber:&c];
    NSLog(@"%d.%d.%d",a,b,c);
    
    /*
     初始化sdk环境
     Initialize the sdk environment
     */
    self.effectContext = [NvsEffectSdkContext sharedInstance:NvsEffectSdkContextFlag_NoFlag];
    self.renderHandle = [self.effectContext createEffectRenderCore];
    [self.renderHandle initializeWithFlags:NvsInitializeFlag_SUPPORT_16K];
    
    /*
     开启预览
     Enable Preview
     */
    [self.efCapture startRunning];
    
    /*
     初始化界面、人脸特效
     Initialize interface and face effects
     */
    
    [self config];
}

#pragma mark - 初始化界面、人脸特效
// Initialize interface and face effects
- (void)config{
    NSString *bundlePath = [[[NSBundle mainBundle] pathForResource:@"license" ofType:@"bundle"] stringByAppendingPathComponent:@"license"];
    
    self.ARSceneFxOperator = [NvARSceneFxOperator sharedInstance];
    [self.ARSceneFxOperator verifySdkLicenseFile:[bundlePath stringByAppendingPathComponent:@"meishesdk.lic"]];
    [self.ARSceneFxOperator setupData];

    if (self.ARSceneFxOperator.verifySuccessful) {
        if ([NvARSceneFxOperator initARFace]) {

            self.ARSceneFxOperator.effectContext = self.effectContext;
            [self.ARSceneFxOperator creatARScene];
        }
    }

    self.scenePreview = [[NvARScenePreview alloc]initWithFrame:self.view.bounds];
    self.scenePreview.ARSceneFxOperator = self.ARSceneFxOperator;
    [self.view addSubview:self.scenePreview];

    [self.scenePreview addBeautyView];
    [self.scenePreview addFilterView];
    [self.scenePreview addMakeupView];

    [self.scenePreview showBeautyView:NO];
    [self.scenePreview showFilterView:NO];
    [self.scenePreview showMakeupView:NO];

    NSArray *array = @[NvBundleLocalString(@"美颜", @"beauty", [self class]),NvBundleLocalString(@"滤镜", @"filter", [self class]),NvBundleLocalString(@"美妆", @"makeup", [self class])];
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:array[i] forState:UIControlStateNormal];
        btn.tag = 1000+i;
        btn.frame = CGRectMake(70*i, SCREEN_HEIGHT - SafeAreaBottomHeight - 80, 60, 30);
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = UIColor.orangeColor;
        [self.view addSubview:btn];
    }
}

- (void)btnClick:(UIButton *)sender{
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [self.view viewWithTag:1000+i];
        btn.hidden = YES;
    }
    if (sender.tag == 1000) {
        [self.scenePreview showBeautyView:YES];
    }else if (sender.tag == 1001) {
        [self.scenePreview showFilterView:YES];
    }else if (sender.tag == 1002) {
        [self.scenePreview showMakeupView:YES];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [self.view viewWithTag:1000+i];
        btn.hidden = NO;
    }
}

#pragma mark - 创建OpenGL环境
//Create an OpenGL environment
- (void)creatOpenGL{
    EAGLSharegroup *group = [[EAGLSharegroup alloc]init];
    _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3 sharegroup:group];
    _ciContext = [CIContext contextWithEAGLContext:_glContext options:@{kCIContextWorkingColorSpace: [NSNull null]}];
    
    if ([EAGLContext currentContext] != _glContext) {
        [EAGLContext setCurrentContext:_glContext];
    }
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection isAudioConnection:(BOOL)isAudioConnection{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CGFloat bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
    CGFloat bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
    
    if (self.outputTextureId <= 0 && [NSThread isMainThread]) {
        self.bufferSize = CGSizeMake(bufferWidth, bufferHeight);
        self.outputTextureId = [self createTextureWithWidth:(int)self.bufferSize.width height:(int)self.bufferSize.height];
    }
    
    if ([NSThread isMainThread]) {
        CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        int64_t timelinePos = (int64_t)(time.value / 1000);
        [self renderEffect:self.bufferSize withbuffer:pixelBuffer with:timelinePos];
    }
}

-(void)renderEffect:(CGSize)size withbuffer:(CVPixelBufferRef)buffer with:(int64_t)timelinePos{
    if ([EAGLContext currentContext] != _glContext) {
        [EAGLContext setCurrentContext:_glContext];
    }
    
    if (self.ARSceneFxOperator.faceEffect) {
        NvsEffectVideoResolution videoEditRes;
        videoEditRes.imageWidth = size.width;
        videoEditRes.imageHeight = size.height;
        videoEditRes.imagePAR = (NvsEffectRational){1, 1};
        
        CVPixelBufferRef outbuffer = nil;
        NvsEffectCoreError renderError;
        
//        renderError = [self.renderHandle renderEffect:self.ARSceneFxOperator.faceEffect inputImage:buffer displayRotation:0 isFlipHorizontally:NO timestamp:timelinePos flags:NvsRenderFlag_NoFlag outputFrameFormat:NvsEffectPixelFormat_BGRA outputFrameIsBT601:NO outputImage:&outbuffer];
        renderError = [self.renderHandle renderEffects:@[self.ARSceneFxOperator.faceEffect] inputImage:buffer outputImage:&outbuffer options:nil];
        if (renderError != NvsEffectCoreError_NoError){
            NSLog(@"%d",renderError);
        }
        
        [self.renderHandle uploadPixelBufferToTexture:outbuffer displayRotation:0 horizontalFlip:YES outputTexId:self.outputTextureId];
        CVBufferRelease(outbuffer);
    }else{
        [self.renderHandle uploadPixelBufferToTexture:buffer displayRotation:0 horizontalFlip:YES outputTexId:self.outputTextureId];
    }
    
    [self.preview newFrameReadyTexture:self.outputTextureId size:self.bufferSize];
}

- (GLuint)createTextureWithWidth:(int)width height:(int)height {
    GLuint textureId = 0;
    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);
    [self checkGlError:@"glerror"];
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    [self checkGlError:@"glerror"];
    return textureId;
}

- (void)checkGlError:(NSString *)op {
    int error;
    while ((error = glGetError()) != GL_NO_ERROR) {
        NSLog(@"%@: glError %d", op, error);
    }
}

@end

