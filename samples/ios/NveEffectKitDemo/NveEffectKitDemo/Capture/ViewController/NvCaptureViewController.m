//
//  NvCaptureViewController.m
//  NveEffectKitDemo
//
//  Created by meishe on 2023/5/9.
//

#import "NvCaptureViewController.h"
#import "EFCapture.h"
#import "EFContentView.h"
#import "NvDisplayView.h"
#import "EFFileWriter.h"
#import "NvCapturePopupView.h"
#import "NvLivePopView.h"
#import "NveRenderInput+Capture.h"
#import "NvLiveBeautyViewModel.h"
#import "NvLiveFilterViewModel.h"
#import "NvLivePropViewModel.h"
#import "NvLivePropViewModel.h"
#import "NvLiveMakeupViewModel.h"
#import "NvLiveARSceneFilterView.h"

#import "NvLiveEffectModule.h"
#import "NvTipsView.h"

@interface NvCaptureViewController () <EFCaptureDelegate, EFContentViewDelegate, NvLivePopViewDelegate, NvLiveARSceneFilterViewDelegate, NvsARSceneManipulateDelegate>

@property(nonatomic, strong) NveEffectKit *effectKit;
@property(nonatomic, assign) NveRenderMode renderMode;

@property(nonatomic, strong) EFCapture *capture;

@property(nonatomic, strong) UIView<NvDisplayProtocol> *preview;

@property(nonatomic, strong) EFFileWriter *fileWriter;

@property(nonatomic, strong) EFContentView *contentView;

// Effect
@property(nonatomic, strong) NvLiveBeautyViewModel *beautyViewModel;

@property(nonatomic, strong) NvLiveFilterViewModel *filterViewModel;
@property(nonatomic, strong) NvLivePropViewModel *propViewModel;
@property(nonatomic, strong) NvLiveMakeupViewModel *makeupViewModel;

@property(nonatomic, strong) EAGLContext *glContext;
//权限视图
//Permission view
@property(nonatomic, strong) NvTipsView *permissions;
@end

@implementation NvCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self addObservers];
    /// The SDK authorization file is bound to the Bundle Identifier of the project. If you change the Bundle Identifier, you need to replace the corresponding authorization file.
    /// 美摄SDK授权文件和项目Bundle Identifier绑定，修改Bundle Identifier需要替换对应的授权文件。
    NSString *sdkLicFilePath = [[NSBundle mainBundle] pathForResource:@"meishesdk.lic" ofType:nil];
    if (![NveEffectKit verifySdkLicenseFile:sdkLicFilePath]) {
        NSLog(@"Sdk License File error");
    }

    // Human Detection Model
    [NvLiveEffectModule setupHumanDetection];

    // Kit
    self.effectKit = [NveEffectKit shareInstance];

    self.renderMode = NveRenderMode_buffer_buffer; // NveRenderMode_buffer_texture; //

    EAGLContext *glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    self.glContext = glContext;

    // Preview
    CGFloat viewWidth = self.view.frame.size.width;
    CGRect previewFrame = CGRectMake(0, 0, viewWidth, viewWidth / 9 * 16);
    if (self.renderMode == NveRenderMode_buffer_texture) {
        self.preview = [NvDisplayView textureDisplayViewWithFrame:previewFrame glContext:glContext];
    } else if (self.renderMode == NveRenderMode_buffer_buffer) {
        self.preview = [NvDisplayView bufferDisplayViewWithFrame:previewFrame];
    }
    [self.view addSubview:self.preview];

    // Writer
    self.fileWriter = [[EFFileWriter alloc] initWithGlContext:glContext];

    // Capture
    self.capture = [[EFCapture alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionFront dataOutputQueue:nil delegate:self];

    // Effect
    self.beautyViewModel = [[NvLiveBeautyViewModel alloc] init];

    NveBeauty *beauty = [self.beautyViewModel defaultBeauty];
    //    beauty.strength = 1;
    //    [beauty setEffectParam:@"Advanced Beauty Type" type:(NvEffectParamType_int) value:@(1)];
    self.effectKit.manipulateDelegate = self;
    self.effectKit.beauty = beauty;
    ///先设置false清理默认效果，然后重新开启，按照所设参数
    ///First set it to false to clear the default effect, then turn it back on and follow the set parameters
    self.effectKit.beauty.enable = false;
    self.effectKit.beauty.enable = true;

    NveShape *shape = [self.beautyViewModel defaultShap];
    //    shap.faceWidth = 1;
    self.effectKit.shape = shape;

    NveMicroShape *microShape = [self.beautyViewModel defaultMicroShap];
    self.effectKit.microShape = microShape;

    // lut示例
    //    NSString *lutFilePath = [[NSBundle mainBundle] pathForResource:@"feiyan.mslut" ofType:nil];
    //    [self.effectKit.beauty setEffectParam:@"Lut Data File Path" type:NveParamType_string value:@""];
    //    [self.effectKit.beauty setEffectParam:@"Lut Intensity" type:NveParamType_float value:@(0.5)]; // 0-4 默认1

    /*
    NveFilter *segFileFilter = [NveFilter filterWithEffectId:@"Segmentation Background Fill"];
    [segFileFilter setEffectParam:@"Stretch Mode" type:NveParamType_int value:@(2)];
    [segFileFilter setEffectParam:@"Detect Interval" type:NveParamType_int value:@(2)];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"imageBg.jpg" ofType:nil];
    [segFileFilter setEffectParam:@"Tex File Path" type:NveParamType_string value:imagePath];
    [segFileFilter setEffectParam:@"Segment Type" type:NveParamType_string value:@"Half Body"];
    [self.effectKit.rawFilterContainer append:segFileFilter];

    NSString *packagePath = [[NSBundle mainBundle] pathForResource:@"2F071EF3-F5FC-4C8A-95AB-24E53425390A.1.animatedsticker" ofType:nil];
    NSMutableString *packageId = [NSMutableString string];
    [self.effectKit installAssetPackage:packagePath license:nil type:NvsAssetPackageType_AnimatedSticker assetPackageId:packageId];
    NvsEffectSdkContext *context = [NvsEffectSdkContext sharedInstance:NvsEffectSdkContextFlag_NoFlag];
    NvsEffectRational aspectRatio = {9, 16};
    NvsVideoEffect *videoFx = [context createAnimatedSticker:0 duration:100000000 * 1000000000 isPanoramic:NO packageId:packageId aspectRatio:aspectRatio];
    [self.effectKit.customEffectArray addObject:videoFx];
*/
    self.filterViewModel = [[NvLiveFilterViewModel alloc] init];
    self.propViewModel = [[NvLivePropViewModel alloc] init];
    self.makeupViewModel = [[NvLiveMakeupViewModel alloc] init];
    /*
     检查摄像头权限
     Check camera permissions
     */
    __weak typeof(self) weakSelf = self;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                 completionHandler:^(BOOL granted) {
                                     if (granted) {
                                         AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
                                         if (audioAuthStatus == AVAuthorizationStatusNotDetermined) {
                                             [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                                                                      completionHandler:^(BOOL granted) {
                                                                          if (granted) {
                                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                                  // Start Running
                                                                                  [weakSelf.capture startRunning];
                                                                              });
                                                                          } else {
                                                                              /*
                             提示麦克风权限未获得
                             Prompt microphone permission not obtained
                             */
                                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                                  // Start Running
                                                                                  [weakSelf.capture startRunning];
                                                                                  [weakSelf.view addSubview:weakSelf.permissions];
                                                                              });
                                                                          }
                                                                      }];
                                         } else if (audioAuthStatus == AVAuthorizationStatusAuthorized) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 // Start Running
                                                 [weakSelf.capture startRunning];
                                             });
                                         } else if (audioAuthStatus == AVAuthorizationStatusDenied) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 // Start Running
                                                 [weakSelf.capture startRunning];
                                                 [weakSelf.view addSubview:weakSelf.permissions];
                                             });
                                         }
                                     } else {
                                         /*
                 提示摄像头权限未获得
                 Prompt that the camera permission is not obtained
                 */
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [weakSelf.view addSubview:weakSelf.permissions];
                                         });
                                     }
                                 }];
    } else if (authStatus == AVAuthorizationStatusDenied) {
        /*
         提示摄像头权限未获得
         Prompt that the camera permission is not obtained
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view addSubview:weakSelf.permissions];
        });
    } else {
        authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (authStatus == AVAuthorizationStatusDenied) {
            /*
             提示麦克风权限未获得
             Prompt microphone permission not obtained
             */
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view addSubview:weakSelf.permissions];
            });
        }
        // Start Running
        [weakSelf.capture startRunning];
    }

    // View
    self.contentView = [[EFContentView alloc] initWithFrame:self.view.bounds];
    self.contentView.delegate = self;
    [self.view addSubview:self.contentView];

    [self deviceIsSupportFlash];
}

- (void)notifyFaceBoundingRectWithId:(int *)faceIds boundingRect:(NvsRect *)boundingRects faceCount:(int)count {
    //    NSLog(@"faceCount:%d", count);
}

//MARK: -- EFCaptureDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection isAudioConnection:(BOOL)isAudioConnection {
    if (sampleBuffer == nil) {
        return;
    }
    [self.fileWriter setupFormatDescription:sampleBuffer];

    if (isAudioConnection) {
        [self.fileWriter appendAudioSampleBuffer:sampleBuffer];
    } else {
        EAGLContext *currentContext = [EAGLContext currentContext];
        if (currentContext != self.glContext) {
            [EAGLContext setCurrentContext:self.glContext];
        }

        // Render
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if (pixelBuffer == nil) {
            return;
        }
        NveRenderInput *input = [[NveRenderInput alloc] init];
        // 填数据
        NveImageBuffer *imageBuffer = [[NveImageBuffer alloc] init];
        imageBuffer.pixelBuffer = pixelBuffer;
        input.imageBuffer = imageBuffer;
        input.imageBuffer.mirror = self.capture.position == AVCaptureDevicePositionFront;
        // 渲染模式
        input.config.renderMode = self.renderMode;
        // Render / 渲染
        NveRenderOutput *output = [[NveEffectKit shareInstance] renderEffect:input];
        if (output.errorCode != NveRenderError_noError) {
            [self.effectKit recycleOutput:output];
            return;
        }
        // Display
        CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        CMTime duration = CMSampleBufferGetDuration(sampleBuffer);
        [self.preview displayRenderOutput:output presentationTimeStamp:presentationTimeStamp duration:duration];
        // write file
        CMTime bufferTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        int64_t timelinePos = (int64_t)(bufferTime.value / 1000);
        if (output.pixelBuffer != nil) {
            [self.fileWriter appendPixelBuffer:output.pixelBuffer timelinePos:timelinePos];
        } else {
            [self.fileWriter appendTexture:output.texture.textureId videoSize:output.texture.size timelinePos:timelinePos];
        }
        // recycle / 回收释放资源
        [self.effectKit recycleOutput:output];
    }
}

//MARK: -- EFContentViewDelegate
- (void)didSelectedBtTag:(EFContentBtTag)tag button:(UIButton *)button {
    switch (tag) {
        case EFContentBtTag_back:
            {
                [self cleanUp];
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        case EFContentBtTag_device:
            {
                [self.capture switchCamera];
                [self deviceIsSupportFlash];
            }
            break;
        case EFContentBtTag_zoom:
            {
                self.contentView.hidden = YES;
                CGRect viewFrame = CGRectMake(0, 0, NvScreen(kWidth), 126 * NvScreen(kScale) + NvScreen(kSafeAreaBottomHeight));
                NvCapturePopupView *zoomView = [[NvCapturePopupView alloc] initWithFrame:viewFrame withType:CapturePopupTypeZoom];
                zoomView.defaultValue = self.capture.zoomFactor;
                [zoomView configMinimumValue:1 MaximumValue:self.capture.videoMaxZoomFactor];
                __weak typeof(self) weakSelf = self;
                zoomView.valueBlock = ^(float value) {
                    weakSelf.capture.zoomFactor = value;
                };
                [NvLivePopView showView:zoomView direction:NvLivePopDirection_Bottom completion:nil dismissDelegate:self];
            }
            break;
        case EFContentBtTag_exposure:
            {
                self.contentView.hidden = YES;
                CGRect viewFrame = CGRectMake(0, 0, NvScreen(kWidth), 126 * NvScreen(kScale) + NvScreen(kSafeAreaBottomHeight));
                NvCapturePopupView *exposureView = [[NvCapturePopupView alloc] initWithFrame:viewFrame withType:CapturePopupTypeExposure];
                exposureView.defaultValue = self.capture.exposureBias;
                [exposureView configMinimumValue:self.capture.minExposureTargetBias MaximumValue:self.capture.maxExposureTargetBias];
                __weak typeof(self) weakSelf = self;
                exposureView.valueBlock = ^(float value) {
                    weakSelf.capture.exposureBias = value;
                };
                [NvLivePopView showView:exposureView direction:NvLivePopDirection_Bottom completion:nil dismissDelegate:self];
            }
            break;
        case EFContentBtTag_flash:
            {
                self.capture.flashOn = !self.capture.flashOn;
                button.selected = self.capture.flashOn;
            }
            break;
        case EFContentBtTag_makeup:
            {
                NvLiveARSceneMakeupView *makeupView = [self.makeupViewModel createMakeupView];
                [NvLivePopView showView:makeupView direction:NvLivePopDirection_Bottom completion:nil dismissDelegate:self];
            }
            break;
        case EFContentBtTag_beauty:
            {
                CGRect viewFrame = CGRectMake(0, 0, NvScreen(kWidth), 285 * NvScreen(kScale) + NvScreen(kSafeAreaBottomHeight));
                NvLiveBeautyView *beautyView = [[NvLiveBeautyView alloc] initWithFrame:viewFrame];
                beautyView.viewModel = self.beautyViewModel;
                [self.beautyViewModel configBeautyView:beautyView];
                [NvLivePopView showView:beautyView direction:NvLivePopDirection_Bottom completion:nil dismissDelegate:self];
            }
            break;
        case EFContentBtTag_filter:
            {
                NvLiveARSceneFilterView *filterView = [self.filterViewModel createFilterView];
                [NvLivePopView showView:filterView direction:NvLivePopDirection_Bottom completion:nil dismissDelegate:self];
            }
            break;
        case EFContentBtTag_props:
            {
                NvLiveARSceneFilterView *filterView = [self.propViewModel createFilterView];
                [NvLivePopView showView:filterView direction:NvLivePopDirection_Bottom completion:nil dismissDelegate:self];
            }
            break;
        case EFContentBtTag_record:
            {
                //                [self.contentView hiddenInterface:!self.fileWriter.isRecording];
                if (self.fileWriter.isRecording) {
                    button.selected = NO;
                    [self.fileWriter stopRecordWithCompletionHandler:^(NSString *filePath) {
                        if (filePath) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                            });
                        }
                    }];
                } else {
                    button.selected = YES;
                    //开启录制
                    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString *filePath = [NSString stringWithFormat:@"%@/%f.mp4", docDir, [[NSDate date] timeIntervalSince1970]];
                    if (![self.fileWriter startRecordWithFilePath:filePath]) {
                        NSLog(@"start record error");
                    }
                }
            }
            break;
    }
}

//MARK: -- NvLivePopViewDelegate
- (void)popViewDismissWithContentView:(UIView *)contentView {
    self.contentView.hidden = NO;
    [self.contentView hiddenInterface:NO];
}

#pragma mark - Saved Photos Album
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"Saved Photos Album:%@,%@", error, videoPath);
}

//当前device是否支持闪光灯
//Whether the current device supports flash
- (void)deviceIsSupportFlash {
    if (self.capture.supportFlash) {
        [self.contentView enabledFlash];
        [self.contentView setFlashSelected:NO];
    } else {
        [self.contentView disabledFlash];
    }
}

- (void)cleanUp {
    [self.capture stopRunning];
    [self.preview cleanUp];
    [self.fileWriter cleanUp];
    [NveEffectKit destroyInstance];
}

- (NvTipsView *)permissions {
    if (!_permissions) {
        _permissions = [[NvTipsView alloc] initWithFrame:self.view.frame
                                              withPrompt:NSLocalizedString(@"Tips", @"提示")
                                           describeTitle:NSLocalizedString(@"camera.microphone.permissions", @"需要打开摄像头和麦克风权限 请在手机设置中进行允许")
                                         describeContent:nil
                                              buttonText:NSLocalizedString(@"Know", @"知道了")
                                              withCenter:YES];
        [_permissions.clickBtn addTarget:self action:@selector(knowClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _permissions;
}

#pragma mark 权限按钮点击事件
/*
 权限按钮点击事件
 Permission button click event
 */
- (void)knowClick {
    [_permissions removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 注册应用前台后台通知事件
/*
 注册应用前台后台通知事件
 Register application foreground and background notification events
 */
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - 应用进入后台，停止采集
/*
 应用进入后台，停止采集
 The application enters the background and stops collecting
 */
- (void)applicationWillResignActive:(NSNotification *)notification {
    [self deviceIsSupportFlash];
    if (self.fileWriter.isRecording) {
        self.contentView.shootingBtn.selected = NO;
        [self.fileWriter stopRecordWithCompletionHandler:^(NSString *filePath) {
            if (filePath) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                });
            }
        }];
    }
}

#pragma mark - 应用进入前台，开始采集
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self deviceIsSupportFlash];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
