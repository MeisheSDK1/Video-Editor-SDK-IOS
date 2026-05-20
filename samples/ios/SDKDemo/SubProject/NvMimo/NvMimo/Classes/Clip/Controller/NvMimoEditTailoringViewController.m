//
//  NvEditTailoringViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/13.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMimoEditTailoringViewController.h"
#import "NvsMimoTimelineEditor.h"
#import "NvsVideoFx.h"
#import "NvsVideoTrack.h"
#import "NvsClip.h"
#import "NvMimoEditClipLiveWindow.h"
#import "NvMimoTipsView.h"
#import "NvsAudioClip.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "NvMimoSDKUtils.h"
#import <NvAlbum/NvAlbumViewController.h>
#import <NvBaseCommon/NVDefineConfig.h>

@interface NvMimoEditTailoringViewController ()<NvsMimoTimelineEditorDelegate>
// Play control
@property (nonatomic, strong) NvMimoEditClipLiveWindow *clipLivewindow;     //播放控件

//裁剪、分割模块
// Crop and split modules
@property (nonatomic, strong) NvsMimoTimelineEditor *timeLineEdit;
// Split timeline
@property (nonatomic, assign) int64_t splitTime;                    //分割的时间线
// trimIn for video cropping
@property (nonatomic, assign) int64_t trimIn;                       //视频裁剪的trimIn
// trimOut for video cropping
@property (nonatomic, assign) int64_t trimOut;                      //视频裁剪的trimOut
// Has trimin changed
@property (nonatomic, assign) BOOL isModifyLeft;                    //是否修改过trimin
// Has trimout been modified
@property (nonatomic, assign) BOOL isModifyRight;                   //是否修改过trimout


@property (nonatomic, strong) NvsStreamingContext *streamingContext;
// Data structure
@property (nonatomic, strong) NvMimoTimelineData *timelineData;             //数据结构
// Clipping required
@property (nonatomic, strong) NvShotModel *originClipModel;         //裁剪需要用到
// Clip object for video operation
@property (nonatomic, strong) NvsVideoClip *videoClip;                  //视频操作的片段对象
// Fragment color manipulation effect
@property (nonatomic, strong) NvsVideoFx *colorVideoFx;                 //片段颜色操作特效
// Fragment sharpness effect
@property (nonatomic, strong) NvsVideoFx *SharpenVideoFx;               //片段锐度特效
// Fragment dark corner effect
@property (nonatomic, strong) NvsVideoFx *VignetteVideoFx;              //片段暗角特效
// Fragment rotation effect
@property (nonatomic, strong) NvsVideoFx *transVideoFx;                 //片段旋转操作特效
// Zoom and translate effects
@property (nonatomic, strong) NvsVideoFx *scaleVideoFx;                 //缩放平移操作特效
// Snippet object for audio operations
@property (nonatomic, strong) NvsAudioClip *audioClip;                  //音频操作的片段对象
// There is only one segment on this timeline
@property (nonatomic, strong) NvsTimeline *clipTimeline;                //这个时间线上只有一个片段
// Split or not
@property (nonatomic, assign) BOOL isSegmentation;                      //是否分割

@property (nonatomic, assign) BOOL isChange;
@property (nonatomic, assign) CGFloat scaleForSeek;
@end

@implementation NvMimoEditTailoringViewController

- (void)dealloc{
    DLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self leftNavigationBarItemView]];

    self.navigationItem.leftBarButtonItem = leftBarButtonItem;

    self.view.backgroundColor = [UIColor nv_colorWithHexRGB:@"#1A1D24"];
    self.streamingContext = [NvsStreamingContext sharedInstance];
    self.clipTimeline = [NvMimoTimelineUtils createTimeline:self.editMode];

    self.originClipModel = [self.model copy];
    self.originClipModel.trimIn = 0;
    self.originClipModel.trimOut = self.model.assetDuration > self.model.duration ? self.model.assetDuration : self.model.duration;
    self.originClipModel.duration = self.originClipModel.trimOut;

    
    self.title = NvLocalStringFromTable([self class], @"Crop", @"裁剪");
    [NvMimoTimelineUtils resetRegularEditData:self.clipTimeline editDataArray:[NSArray arrayWithObject:self.originClipModel]];
    self.clipLivewindow = [[NvMimoEditClipLiveWindow alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width)];
    [self.view addSubview:self.clipLivewindow];
    [self.clipLivewindow connectTimeline:self.clipTimeline];
    self.clipLivewindow.editMode = self.editMode;
    self.clipLivewindow.model = self.model;

    [self functionCrop];
}

- (NvsVideoFx *)getVideoFx:(NvsVideoClip *)clip name:(NSString *)name {
    for (int i = 0; i < clip.fxCount; i++) {
        NvsVideoFx *videoFx = [clip getFxWithIndex:i];
        if ([videoFx.bultinVideoFxName isEqualToString:name])
            return videoFx;
    }
    return nil;
}

- (void)tipClick:(UIButton *)sender{
    [sender.superview removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)leftNavigationBarItemView {
    UIButton *backButton;
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 30, 44);
    return backButton;
}

#pragma mark - 底部按钮点击事件
// Bottom button click event
- (void)finshClick:(UIButton *)sender{
    self.model.trimIn = self.trimIn;
    self.model.trimOut = self.trimOut;
    [self.streamingContext removeTimeline:self.clipTimeline];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonClicked:(UIButton *)button {
    [self.streamingContext removeTimeline:self.clipTimeline];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)replaceButtonClicked:(UIButton *)button {
    for(UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isMemberOfClass:[NvAlbumViewController class]]) {
            if (self.replaceBlock) {
                self.replaceBlock(self.model);
            }
            
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
    
}

#pragma mark 裁剪(修改了point)
// Crop (changes point)
- (void)functionCrop {
    self.timeLineEdit = [[NvsMimoTimelineEditor alloc] initWithFrame:CGRectMake(0,426 * SCREANSCALE, SCREANWIDTH,SCREANHEIGHT - 426 * SCREANSCALE)];
    self.timeLineEdit.caneditTimeSpan = YES;
    self.timeLineEdit.canOverlapTimeSpan = YES;
    self.timeLineEdit.model = self.model;
    
    CGFloat duration = [self realTrimOutWithModel:self.model];
    if(self.model.isImage){
        self.timeLineEdit.timelinePosition = duration;
    }else if(self.model.assetDuration < duration){
        self.timeLineEdit.timelinePosition = self.model.assetDuration;
    }else{
        self.timeLineEdit.timelinePosition = duration ;
    }

    [self.view addSubview:self.timeLineEdit];
    NvsMimoTimelineEditorInfo *info = [[NvsMimoTimelineEditorInfo alloc] init];
    info.mediaFilePath = self.model.isImage ? self.model.localIdentifier : self.model.videoPath;
    info.inPoint = 0;
    info.outPoint =self.model.isImage ? duration : self.model.assetDuration;
    info.trimIn = 0;
    info.trimOut = self.model.isImage ? duration : self.model.assetDuration;
    info.stillImageHint = false;
    [self.timeLineEdit initTimelineEditor:@[info] timelineDuration:self.clipTimeline.duration];
    self.timeLineEdit.delegate = self;
    self.timeLineEdit.type = 0;

    [self.clipLivewindow seekTimeline:self.originClipModel.trimIn];
    if (self.model.speed.count >0) {
        CGFloat duration = [self realTrimOutWithModel:self.model];
        [self.clipLivewindow setPlayRangeIn:self.model.trimIn rangeOut:duration];
    }else{
        [self.clipLivewindow setPlayRangeIn:self.model.trimIn rangeOut:self.model.trimOut];
    }
    UIButton *finshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [finshBtn setImage:[NvMimoUtils imageWithName:@"NvCheckFinish_edit"] forState:UIControlStateNormal];
    [finshBtn addTarget:self action:@selector(finshClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finshBtn];
    [finshBtn mas_updateConstraints:^(MASConstraintMaker *make) {
       
        if(KIsiPhoneX){
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-39 * SCREANSCALE);
        }else{
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-15 * SCREANSCALE);
        }
          make.right.equalTo(self.view.mas_right).offset(-13 * SCREANSCALE);
    }];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:[NvMimoUtils imageWithName:@"NvTailoring_close"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    [cancelButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(finshBtn.mas_top);
        make.left.equalTo(self.view.mas_left).offset(13 * SCREANSCALE);
    }];
    
    UIButton *replaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [replaceButton setTitle:NvLocalStringFromTable([self class], @"Replace this part", @"替换此段") forState:UIControlStateNormal];
    [replaceButton addTarget:self action:@selector(replaceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:replaceButton];
    [replaceButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cancelButton.mas_centerY);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(finshBtn.mas_top).offset(-12*SCREANSCALE);
    }];

}

- (CGFloat)realTrimOutWithModel:(NvShotModel *)model {
    CGFloat duration;
    if (model.speed.count>0) {
        duration = [NvMimoTimelineUtils requiredDurationForShotModel:model];
    }else{
        duration = model.duration;
    }
    return duration;
}

#pragma mark 是否允许多个手势并发
//Whether multiple gestures are allowed to be concurrent
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

#pragma mark 坐标转换
//Coordinate conversion
- (CGPoint)conversionPoint:(CGPoint)point{
    CGPoint currtnetPoint = [_clipLivewindow.liveWindow mapViewToNormalized:point];
    return currtnetPoint;
}

#pragma mark 取消按钮点击事件
//Cancels the button click event
- (void)cancelClick:(UIButton *)sender{
    [NvMimoTimelineUtils removeTimeline:self.clipTimeline];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark timelineEditorDelegate
- (void)timelineEditor:(id)timelineEditor trimIn:(CGFloat)trimIn trimOut:(CGFloat)trimOut {
    self.trimIn = trimIn;
    self.trimOut = trimOut;
    int64_t start = trimIn;
    if (start < 0) {
        start = 0;
    }
    self.isChange = YES;
    [self seekTimeline:start];
    [self.clipLivewindow updateUI:start];
}

- (void)timelineEditorDidEndScroll:(id)timelineEditor {
    self.isChange = NO;
    [self seekTimeline:-1];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.clipLivewindow setPlayRangeIn:self.trimIn rangeOut:self.trimOut];
    });
    
}

- (void)seekTimeline:(int64_t)postion {
    if (postion < 0) {
        postion = [_streamingContext getTimelineCurrentPosition:self.clipTimeline];
    }
    int flags = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (self.isChange) {
        flags = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing;
        self.scaleForSeek = self.clipTimeline.duration / 1000000 / [self.timeLineEdit getTimelineEditorWidth] / UIScreen.mainScreen.scale;
        [_streamingContext setTimeline:self.clipTimeline scaleForSeek:self.scaleForSeek];
    }
    if (![_streamingContext seekTimeline:self.clipTimeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flags])
        DLog(@"定位时间线失败！");
}

@end
