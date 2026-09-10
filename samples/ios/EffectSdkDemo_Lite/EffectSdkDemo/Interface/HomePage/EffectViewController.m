//
//  EffectViewController.m
//  GPUImageEffectDemo
//
//  demo 2
//
//  Created by 美摄 on 2021/3/2.
//

#import "EffectViewController.h"
#import "EffectVideoRender.h"
#import "EFPreview.h"
#import "EFCapture.h"
#import "EFFileWriter.h"
#import <CoreVideo/CVPixelBuffer.h>
#import "NvsStreamingContext.h"

@interface EffectViewController ()
<EffectVideoRenderDelegate,
EFCaptureDelegate,
EFRectOperatorViewEditDelegate,
NvARScenePreviewViewDelegate>


//render
@property(nonatomic,strong) EffectVideoRender* videoRender;
//预览View
@property(nonatomic,strong) EFPreview* preview;
//相机capture
@property(nonatomic,strong) EFCapture* efCapture;
//录制 record
@property(nonatomic,strong) EFFileWriter* fileWriter;

@property (nonatomic, assign) BOOL isTakePhoto;
@property (nonatomic, assign) CGPoint focusPoint;

/// 调试视图，显示查看拍照渲染之后的图片
/// Debug the view and display the rendered image after the photo was taken
@property (nonatomic, strong) UIImageView *testImageView;
@property (nonatomic, strong) NvsVideoEffect* __nullable segEffect;
@property (nonatomic, strong) NvsVideoEffect *filterFx;
@property (nonatomic, strong) NvsVideoEffect *colorCorrectFilter;
@property (nonatomic, strong) NSMutableArray *makeupFilterPackageIdArray;
@property(nonatomic,strong) UIButton* renderModeBt;
@property (atomic, assign) BOOL renderMode;

@property (atomic, assign) BOOL isFirstDetection;
@end

@implementation EffectViewController

-(void)dealloc{
    [self cleanUp];
    NSLog(@"VC: %s",__FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirstDetection = YES;
    
    // Do any additional setup after loading the view.
    self.videoRender = [[EffectVideoRender alloc] init];
    self.videoRender.delegate = self;
    
    self.ARSceneFxOperator = [NvARSceneFxOperator sharedInstance];
    
#ifdef UseARScene_ST
    self.ARSceneFxOperator.effectContext = self.videoRender.effectContext;
    self.ARSceneFxOperator.renderCore = self.videoRender.renderCore;
    [self.ARSceneFxOperator creatARScene];
    if (self.ARSceneFxOperator.faceEffect) {
        self.videoRender.isInitializedARScene = YES;
        self.videoRender.faceEffect = self.ARSceneFxOperator.faceEffect;
        self.videoRender.ARSceneFxOperator = self.ARSceneFxOperator;
    }
#else
    if ([NvARSceneFxOperator initARFace]) {
        self.ARSceneFxOperator.effectContext = self.videoRender.effectContext;
        self.ARSceneFxOperator.renderCore = self.videoRender.renderCore;
        [self.ARSceneFxOperator creatARScene];
        if (self.ARSceneFxOperator.faceEffect) {
            self.videoRender.isInitializedARScene = YES;
            self.videoRender.faceEffect = self.ARSceneFxOperator.faceEffect;
            [self.videoRender.faceEffect setFloatVal:@"Face Mesh Forehead Degree" val:1];
            self.videoRender.ARSceneFxOperator = self.ARSceneFxOperator;
        }
    }
#endif
    [self.ARSceneFxOperator setupData];
    [self.videoRender enableBeautyFilter:YES];
    
    self.scenePreview = [[NvARScenePreview alloc]initWithFrame:self.view.bounds];
    self.scenePreview.extraHeight = SafeAreaBottomHeight;
    self.scenePreview.delegate = self;
    [self addScenePreview];
    self.makeupFilterPackageIdArray = [NSMutableArray array];
    self.videoRender.preView = self.scenePreview;

    self.preview = [[EFPreview alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH/9*16)
                                          glContext:self.videoRender.glContext];
    
    [self.view addSubview:self.preview];
    [self.view sendSubviewToBack:self.preview];
    
    self.fileWriter = [[EFFileWriter alloc] initWithGlContext:self.videoRender.glContext];

    self.efCapture = [[EFCapture alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720
                                               cameraPosition:AVCaptureDevicePositionFront
                                              dataOutputQueue:self.videoRender.videoProcessingQueue
                                                     delegate:self];
    [self.efCapture enableTakePhoto:YES sessionPreset:AVCaptureSessionPreset1280x720];
    
    self.isTakePhoto = YES;
    
    self.testImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width*0.5, self.view.bounds.size.width*0.5*640/480)];
    self.testImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.testImageView];
    self.testImageView.hidden = YES;
    
    [self setupSubviewWithDevice];
    
    self.rectView.editDelegate = self;
    
    self.renderModeBt = [[UIButton alloc] initWithFrame:CGRectMake(15, 105, 60, 50)];
    [self.renderModeBt setTitle:@"texture" forState:(UIControlStateNormal)];
    self.renderMode = NO;
    [self.renderModeBt addTarget:self action:@selector(switchModeBtClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.contentView addSubview:self.renderModeBt];
    [self.renderModeBt setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    [self.efCapture startRunning];
}

-(void)setupSubviewWithDevice{
    [self deviceIsSupportFlash];
    __weak typeof(self)weakSelf = self;
    
    [self.zoomView configMinimumValue:1 MaximumValue:2];
    self.zoomView.ValueBlock = ^(float value) {
        weakSelf.efCapture.zoomFactor = value;
    };
    
    [self.exposureView configMinimumValue:self.efCapture.minISO MaximumValue:self.efCapture.maxISO];
    self.exposureView.ValueBlock = ^(float value) {
        weakSelf.efCapture.exposeFactor = value;
    };
    
    [self.rectView setRectDisplayView:self.preview];
}

//视频
//video
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection isAudioConnection:(BOOL)isAudioConnection{
    [self.fileWriter setupFormatDescription:sampleBuffer];
    
    if (isAudioConnection) {
        [self.fileWriter appendAudioSampleBuffer:sampleBuffer];
    }else{
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if (pixelBuffer) {
            int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
            int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.rectView resetBufferSize:CGSizeMake(bufferWidth, bufferHeight)];
            });
        }
#ifdef UseARScene_ST
        [self.videoRender dealWithSampleBuffer:sampleBuffer renderBuffer:self.renderMode flip:self.efCapture.position == AVCaptureDevicePositionFront];
#else
        BOOL isFront = self.efCapture.position == AVCaptureDevicePositionFront;
        [self.videoRender dealWithSampleBuffer:sampleBuffer
                                  renderBuffer:self.renderMode
                                          flip:isFront
                                       isFront:isFront
                                   orientation:[connection videoOrientation]];
#endif
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isFirstDetection) {
                [self.scenePreview detectionCapability];
                self.isFirstDetection = NO;
            }
        });
    }
}

//拍照
//take picture
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error API_AVAILABLE(ios(11.0)){
    [self.videoRender processingPhoto:photo renderBuffer:self.renderMode output:output isFlipHorizontally:self.efCapture.position == AVCaptureDevicePositionFront];
}

- (void)newFrameTextureReady:(GLuint)outputTexture size:(CGSize)size timelinePos:(int64_t)timelinePos taskId:(int64_t)taskId{
    [self.preview newFrameReadyTexture:outputTexture size:size];

    if (self.fileWriter.isRecording) {
        self.efCapture.startTime= timelinePos;
        [self.fileWriter appendTexture:outputTexture videoSize:size timelinePos:timelinePos];
    }else{
        self.efCapture.startTime = -1.0;
    }
}

- (void)newFramePixelBufferReady:(CVPixelBufferRef)pixelBuffer
                  bufferNeedFlip:(BOOL)flip
                         texture:(GLuint)texture
                     timelinePos:(int64_t)timelinePos{
    int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    [self newFrameTextureReady:texture size:CGSizeMake(bufferWidth, bufferHeight) timelinePos:timelinePos taskId:0];
}

- (void)photoResultImage:(UIImage*)resultImage taskId:(int64_t)taskId{
    if (resultImage != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.testImageView.hidden) {
                self.testImageView.image = resultImage;
            }else{
                UIImageWriteToSavedPhotosAlbum(resultImage, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            }
        });
    }else{
        NSLog(@"拍照错误 Photo error");
    }
}

-(void)switchModeBtClicked:(UIButton*)bt{
    self.renderMode = !self.renderMode;
    [bt setTitle:self.renderMode ? @"Buffer":@"texture" forState:(UIControlStateNormal)];
}

- (IBAction)startRecording {
    self.videoRender.renderStartTime = 0;
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [NSString stringWithFormat:@"%@/%f.mp4",docDir,[[NSDate date] timeIntervalSince1970]];
    self.efCapture.audioEngine.state = AudioEngineState_playAndRecord;
    if(![self.fileWriter startRecordWithFilePath:filePath]){
        NSLog(@"开启录制失败 Failed to start recording");
    }
}

- (IBAction)stopRecording {
    self.efCapture.audioEngine.state = AudioEngineState_normal;
    [self.fileWriter stopRecordWithCompletionHandler:^(NSString * filePath) {
        if (filePath) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            });
        }
    }];
}

#pragma mark - 保存相册的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"保存相册 Save photo album%@,%@",error,videoPath);
}

#pragma mark - NvARScenePreviewViewDelegate
- (void)filterDictionary:(NSDictionary *)dict{
    NSString *packageId = dict[@"packageId"];
    NSNumber *value = dict[@"value"];
    if (packageId.length > 0) {
        if (!self.filterFx) {
            self.filterFx = [self.videoRender appendPackageFilter:packageId];
        }
        if ([packageId isEqualToString:self.filterFx.packageId]) {
            [self.filterFx setFilterIntensity:value.floatValue];
        }else{
            if (self.filterFx) {
                [self.videoRender removePackageFilter:self.filterFx.packageId];
                self.filterFx = nil;
            }
            self.filterFx = [self.videoRender appendPackageFilter:packageId];
        }
    }else{
        if (self.filterFx) {
            [self.videoRender removePackageFilter:self.filterFx.packageId];
            self.filterFx = nil;
        }
    }
}

- (void)correctionFilterDictionary:(NSDictionary *)dict{
    NSString *packageId = dict[@"uuid"];
    NSNumber *value = dict[@"value"];
    NSNumber *open = dict[@"open"];
    if (open.boolValue && packageId.length > 0) {
        if (!self.colorCorrectFilter) {
            self.colorCorrectFilter = [self.videoRender appendPackageFilter:packageId];
        }
        [self.colorCorrectFilter setFilterIntensity:value.floatValue];
    }else{
        if (self.colorCorrectFilter) {
            [self.videoRender removePackageFilter:self.colorCorrectFilter.packageId];
            self.colorCorrectFilter = nil;
        }
    }
}

- (void)makeupFilterArray:(NSMutableArray *)array{
    for (NSString *uuid in self.makeupFilterPackageIdArray) {
        [self.videoRender removePackageFilter:uuid];
    }
    [self.makeupFilterPackageIdArray removeAllObjects];
    NSString *uuid = @"";
    NSNumber *value = @(0);
    for (NSDictionary *dict in array) {
        uuid = dict[@"uuid"];
        value = dict[@"value"];
        if (uuid && value) {
            NvsVideoEffect *videoEffect = [self.videoRender appendPackageFilter:uuid];
            [videoEffect setFilterIntensity:value.floatValue];
            [self.makeupFilterPackageIdArray addObject:uuid];
        }
    }
}

#pragma mark - EnterBackground
- (void)applicationDidEnterBackground
{
    if (self.fileWriter.isRecording) {
        [self.fileWriter stopRecordWithCompletionHandler:^(NSString * filePath) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            });
        }];
    }
}

#pragma mark EnterForeground
- (void)applicationWillEnterForeground
{
    
}

#pragma mark - addNotifications
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(applicationDidEnterBackground)
        name:UIApplicationDidEnterBackgroundNotification
      object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(applicationWillEnterForeground)
        name:UIDeviceOrientationDidChangeNotification
      object:[UIApplication sharedApplication]];
    
}

-(void)cleanUp{
    self.colorCorrectFilter = nil;
    self.filterFx = nil;
    self.rectView.currentEffect = nil;
    self.rectView.delegate = nil;
    [self.efCapture stopRunning];
    [self.preview cleanUp];
    [self.fileWriter cleanUp];
    /// videoRender 释放时会销毁opengl环境，需要放在最后销毁
    /// This will destroy the opengl environment and should be done last
    [self.videoRender cleanUp];
    [NvARSceneFxOperator dellocInstance];
}

#pragma mark -- EFContentViewDelegate

-(void)segmentSwitchValueChanged:(UISwitch*)segmentSwitch{
    if (segmentSwitch.on) {
        if(!self.segEffect){
            //        NvsVideoEffect* segmentationVideoFx = [self.videoRender appendBuildInFilter:@"Segmentation"];
            //        [segmentationVideoFx setBooleanVal:@"Inverse Segment" val:YES];
            
            NvsEffectRational aspectRatio = {9, 16};
            NvsVideoEffect* videoFx = [self.videoRender.effectContext createVideoEffect:@"Segmentation Background Fill" aspectRatio:aspectRatio];
            [videoFx setIntVal:@"Stretch Mode" val:2];
            [videoFx setIntVal:@"Detect Interval" val:2];
//            NvsEffectColor color = (NvsEffectColor){0,0.5,1,1};
//            [videoFx setColorVal:@"Background Color" val:&color];
            NSString* imagePath = [[NSBundle mainBundle] pathForResource:@"imageBg.jpg" ofType:nil];
            [videoFx setStringVal:@"Tex File Path" val:imagePath];
            
            [videoFx setMenuVal:@"Segment Type" val:@"Half Body"];
            self.segEffect = videoFx;
        }
        self.videoRender.segEffect = self.segEffect;
    }else{
//        [self.videoRender removeBuildInFilter:@"Segmentation"];
        self.videoRender.segEffect = nil;
    }
}

-(void)didSelectedBtTag:(NSInteger)tag{
    [super didSelectedBtTag:tag];
    switch (tag) {
        case 0:{
//            [self.videoRender appendBuildInFilter:@"Segmentation"];
////            [self.videoRender appendBuildInFilter:@"Sage"];
//            return;
            [self.efCapture switchCamera];
            [self deviceIsSupportFlash];
            [self.zoomView configMinimumValue:1 MaximumValue:self.efCapture.videoMaxZoomFactor];
            [self.exposureView configMinimumValue:self.efCapture.minISO MaximumValue:self.efCapture.maxISO];
            [self.rectView setRectDisplayView:self.preview];
            break;
        }
        case 2:{
            break;
        }
        case 6:{
            self.efCapture.flashOn = !self.efCapture.flashOn;
            break;
        }
        case 11:{
            [self cleanUp];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 1000:{
            if (self.isTakePhoto) {
                [self.efCapture capturePhoto];
            }else{
                [self.contentView hiddenInterface:!self.fileWriter.isRecording];
                if(self.fileWriter.isRecording){
                    [self stopRecording];
                }else{
                    //开启录制
                    [self startRecording];
                }
            }
        }
            break;
  
        default:{
            
        }
            break;
    }
}
- (void)changeVolum:(CGFloat)value{
    [self.efCapture.audioEngine changePlayVolume:value];
}
- (void)audioPause{
    [self.efCapture.audioEngine audioPause];
}
- (void)audioPlay{
    [self.efCapture.audioEngine audipPlay];
}
- (void)changeAudioWithPath:(NSString *)path{
    [self.efCapture.audioEngine changeAudioWithPath:path];
}
//当前device是否支持闪光灯
//Whether flash is supported on the current device
- (void)deviceIsSupportFlash {
    //根据当前device是否支持闪光灯来做界面处理
    //Interface processing based on whether the current device supports flash or not
    if (self.efCapture.supportFlash) {
        [self.contentView enabledFlash];
    }else{
        [self.contentView disabledFlash];
    }
}

#pragma mark - 点击屏幕界面改变聚焦点
//Tap the screen interface to change focus
- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    //改变聚焦点
    CGPoint point = [gesture locationInView:self.view];
    CGPoint newPoint = [self.contentView.layer convertPoint:point fromLayer:self.view.layer];
    self.focusPoint = newPoint;
    if (self.efCapture.supportFocus) {
        [self animateFocusView:point];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayaf) object:nil];
        [self performSelector:@selector(delayaf) withObject:nil afterDelay:3.0];
        
    }else{

    }
    
}

#pragma mark 对焦延迟执行
//Focus delay execution
- (void)delayaf{
    self.efCapture.focusPoint = self.focusPoint;
}

#pragma mark -- EFStickerViewDelegate

-(void)stickerViewDidDismiss:(EFStickerView*)stickerView{
    self.contentView.hidden = NO;
}

-(void)didSeletedItem:(id<NvStickerModelDelegate>)item stickerView:(EFStickerView*)stickerView{
    self.videoRender.renderStartTime = 0;
    if ([stickerView isEqual:self.compoundCaptionView]){
        NvFilterItem* fxItem = (NvFilterItem*)item;
        NSString* packageId = [self installEffectAssetPackage:fxItem.package license:nil type:(NvsAssetPackageType_CompoundCaption)];
        if (!packageId) {
            return;
        }
        NvsEffectRational aspectRatio = {9, 16};
        NvsVideoEffectCompoundCaption *fx =[self.videoRender.effectContext createCompoundCaption:0 duration:3000000000 packageId:fxItem.packageId aspectRatio:aspectRatio];
        [self.videoRender.filterArray addObject:fx];
        self.rectView.hidden = NO;
        [self.rectView updateEffectShow:fx];
        
    }else if ([stickerView isEqual:self.stickerView]){
        NvFilterItem* fxItem = (NvFilterItem*)item;
        NSString* packageId = [self installEffectAssetPackage:fxItem.package license:nil type:(NvsAssetPackageType_AnimatedSticker)];
        if (!packageId) {
            return;
        }
        NvsEffectRational aspectRatio = {9, 16};
        NvsVideoEffectAnimatedSticker *fx = [self.videoRender.effectContext createAnimatedSticker:0 duration:3000000000 isPanoramic:NO packageId:fxItem.packageId aspectRatio:aspectRatio];
        [self.videoRender.filterArray addObject:fx];
        self.rectView.hidden = NO;
        [self.rectView updateEffectShow:fx];
    }else if([stickerView isEqual:self.propsView]){
        NvStickerModel *propsModel = (NvStickerModel*)item;
        NSString* packageId = [self installEffectAssetPackage:propsModel.package license:nil type:(NvsAssetPackageType_ARScene)];
        self.rectView.hidden = YES;
        if (packageId && packageId.length > 0) {
            [self.videoRender.faceEffect setStringVal:@"Scene Id" val:packageId];
            [self.ARSceneFxOperator.takePictureInfo setObject:packageId forKey:@"Scene Id"];
        }else{
            [self.videoRender.faceEffect setStringVal:@"Scene Id" val:@""];
            [self.ARSceneFxOperator.takePictureInfo setObject:@"" forKey:@"Scene Id"];
        }
    }else if ([stickerView isEqual:self.transitionView]){
        self.rectView.hidden = YES;
        NvFilterItem* fxItem = (NvFilterItem*)item;
        NSString* packageId = [self installEffectAssetPackage:fxItem.package license:nil type:(NvsAssetPackageType_VideoTransition)];
        if (!packageId) {
            return;
        }
        NvsEffectRational aspectRatio = {9, 16};
        
        NvsVideoEffectTransition *fx = [self.videoRender.effectContext createVideoTransition:fxItem.packageId aspectRatio:aspectRatio];
        NSMutableArray* mutArray = [NSMutableArray array];
        for (NvsVideoEffect* effect in self.videoRender.filterArray) {
            if ([effect isKindOfClass:[NvsVideoEffectTransition class]]) {
                [mutArray addObject:effect];
            }
        }
        [self.videoRender.filterArray removeObjectsInArray:mutArray];
        [self.videoRender.filterArray addObject:fx];
        if (fx) {
            [fx setVideoTransitionDuration: 5000000];
        }
    }
}

#pragma mark -  添加/修改字幕文字
//add/edit text
- (void)captionDialog:(NvCaptionDialogViewController *)captionDialog clickButtonIndex:(NSInteger)index {
    //添加字幕页面修改字幕
    //Add caption page to modify caption
    if (captionDialog.isChangedText) {
        if (index == 0) {
            NSString* text = [captionDialog getCaptionText];
            text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self resetText:text captionIndex:captionDialog.captionIndex];
        } else {
            //不做处理
            //none
        }
        
        [captionDialog dismissViewControllerAnimated:NO completion:^{
            self.contentView.hidden = NO;
        }];
        
        return;
    }
    
    //添加字幕
    //add caption
    if (index == 0) {
        NSString* text = [captionDialog getCaptionText];
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(text.length == 0) {
            return;
        } else {
            NvsEffectRational aspectRatio = {9, 16};
            NvsVideoEffectCaption *fx=[self.videoRender.effectContext createCaption:text inPoint:0 duration:30000000000 captionStylePackageId:nil aspectRatio:aspectRatio];
            
            [fx setExprVar:@"timeStamp" varValue:[self getCurrentTim]];
            [self.videoRender.filterArray addObject:fx];
            self.rectView.hidden = NO;
            [self.rectView updateEffectShow:fx];

        }
    } else {//取消 cancel
        //不作处理
        //none
    }
    [captionDialog dismissViewControllerAnimated:NO completion:NULL];
    self.contentView.hidden = NO;
}
- (uint64_t) getCurrentTim
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970]*1000;
    uint64_t ui64Time = [[NSNumber numberWithDouble:time] longLongValue];
    
    return ui64Time;
}

#pragma mark - EFRectOperatorViewEditDelegate
- (void)deleteEffectOperatorView:(EFRectOperatorView *)rectOperatorView{
    [self.videoRender.filterArray removeObject:rectOperatorView.currentEffect];
    [self.videoRender.renderCore clearEffectResources:rectOperatorView.currentEffect];
}

-(void)rectOperatorView:(EFRectOperatorView*)rectOperatorView touchUpInside:(NSInteger)captionIndex point:(CGPoint)point{
    
        if([rectOperatorView.currentEffect isKindOfClass:[NvsVideoEffectAnimatedSticker class]]){
        //贴纸
        //sticker
        }else{
            if (!rectOperatorView.currentEffect) {
                return;
            }
            if (![rectOperatorView isInRect:point]) {
                return;
            }
            self.contentView.hidden = YES;
            NvCaptionDialogViewController *dialogVC = [NvCaptionDialogViewController new];
            dialogVC.delegate = self;
            dialogVC.isChangedText = YES;
            
            if ([rectOperatorView.currentEffect isKindOfClass:[NvsVideoEffectCompoundCaption class]]) {
                NvsVideoEffectCompoundCaption* comCaption = (NvsVideoEffectCompoundCaption*)rectOperatorView.currentEffect;
                [dialogVC setCaptionText:[comCaption getText:captionIndex]];
                dialogVC.captionIndex = captionIndex;
            }else if ([rectOperatorView.currentEffect isKindOfClass:[NvsVideoEffectCaption class]]) {
                NvsVideoEffectCaption* caption = (NvsVideoEffectCaption*)rectOperatorView.currentEffect;
                [dialogVC setCaptionText:caption.getText];
            }
            
            [dialogVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
            //必要配置
            //must configure
            self.modalPresentationStyle = UIModalPresentationCurrentContext;
            self.providesPresentationContextTransitionStyle = YES;
            self.definesPresentationContext = YES;
            [self presentViewController:dialogVC animated:YES completion:NULL];
        }
}

-(void)resetText:(NSString*)text captionIndex:(NSInteger)captionIndex{
    EFRectOperatorView* rectOperatorView = self.rectView;
    if ([rectOperatorView.currentEffect isKindOfClass:[NvsVideoEffectCompoundCaption class]]) {
        NvsVideoEffectCompoundCaption* comCaption = (NvsVideoEffectCompoundCaption*)rectOperatorView.currentEffect;
        [comCaption setText:captionIndex text:text];
    }else if ([rectOperatorView.currentEffect isKindOfClass:[NvsVideoEffectCaption class]]) {
        NvsVideoEffectCaption* caption = (NvsVideoEffectCaption*)rectOperatorView.currentEffect;
        [caption setText:text];
    }
    [rectOperatorView updateEffectShow:rectOperatorView.currentEffect];
}

#pragma mark - take photo or record
-(void)selectedCapture:(NSInteger)index{
    if (index == 0) {
        //拍照
        //take photo
        self.isTakePhoto = YES;
#ifdef USING_AUDIO_ENGINE
        [self.efCapture.audioEngine stopAudioRecord];
#endif
    }else if (index == 1){
        //录制
        //record
        self.isTakePhoto = NO;
#ifdef USING_AUDIO_ENGINE

        self.efCapture.audioEngine.state = AudioEngineState_playAndRecord;
//        [self.efCapture.audioEngine addUnitEQ];
//        [self.efCapture.audioEngine addUnitDelay];
//        [self.efCapture.audioEngine addUnitReverb];
//        [self.efCapture.audioEngine addUnitDistortion];
        
        [self.efCapture.audioEngine startAudioRecord];
#endif
    }
    [self.efCapture enableTakePhoto:self.isTakePhoto sessionPreset:self.isTakePhoto?AVCaptureSessionPreset1280x720:AVCaptureSessionPreset1280x720];
    [self.exposureView configMinimumValue:self.efCapture.minISO MaximumValue:self.efCapture.maxISO];
    [self.rectView setRectDisplayView:self.preview];
}

////安装资源
///install resources
- (NSString*)installEffectAssetPackage:(NSString *)assetPackageFilePath license:(NSString * _Nullable)licenseFilePath type:(NvsAssetPackageType)type{
    NSMutableString* sceneId = [[NSMutableString alloc] initWithString:@""];
    NvsAssetPackageManagerError error = [self.videoRender.effectContext.assetPackageManager installAssetPackage:assetPackageFilePath license:licenseFilePath type:type sync:YES assetPackageId:sceneId];
    if (error != NvsAssetPackageManagerError_NoError && error != NvsAssetPackageManagerError_AlreadyInstalled) {
        NSLog(@"包裹安装失败 Package installation failure:%d",error);
        return nil;
    }else if(error == NvsAssetPackageManagerError_AlreadyInstalled){
        [self.videoRender.effectContext.assetPackageManager upgradeAssetPackage:assetPackageFilePath license:licenseFilePath type:type sync:YES assetPackageId:sceneId];
    }
    return sceneId;
}

@end
