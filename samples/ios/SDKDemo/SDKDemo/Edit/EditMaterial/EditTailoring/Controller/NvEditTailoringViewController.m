//
//  NvEditTailoringViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/13.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvEditTailoringViewController.h"
#import "NvsTimelineEditor.h"
#import "NvsTimelineTimeSpan.h"
#import "CLSlider.h"
#import "NvsVideoFx.h"
#import "NvsVideoTrack.h"
#import "NvsClip.h"
#import "NvEditBottomCollectionViewCell.h"
#import "NvEditClipLiveWindow.h"
#import "NvsAudioClip.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "NvCorrectionCViewCell.h"
#import "NvEditFilterView.h"
#import <NvSDKCommon/NvAssetManager.h>
#import "NvMoreFilterViewController.h"
#import "NvCaptureFilterModel.h"
#import "NvEditKeyFrameView.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvAdjustFxParamView.h"
#import <NvSDKCommon/NvInitArScence.h>

@interface NvEditTailoringViewController ()<NvsTimelineEditorDelegate, UICollectionViewDelegate, UICollectionViewDataSource,NvEditFilterViewDelegate,NvEditKeyFrameViewDelegate,NvEditClipLiveWindowDelegate,NvAdjustFxParamViewDelegate>

///所有模块统一控件
///All modules unified control
///标题控件
///Title control
@property (nonatomic, strong) UILabel *textLabel;
///播放控件
///Playback control
@property (nonatomic, strong) NvEditClipLiveWindow *clipLivewindow;

///裁剪、分割模块
///Cut and segment the module
@property (nonatomic, strong) NvsTimelineEditor *timeLineEdit;
@property (nonatomic, weak)   NvsTimelineTimeSpan *timeSpan;
///分割的时间线
///The split timeline
@property (nonatomic, assign) int64_t splitTime;
///视频裁剪的trimIn
///Video clipping trimIn
@property (nonatomic, assign) int64_t trimIn;
///视频裁剪的trimOut
///Video clipping trimOut
@property (nonatomic, assign) int64_t trimOut;
///是否修改过trimin
///Whether trimin has been modified
@property (nonatomic, assign) BOOL isModifyLeft;
///是否修改过trimout
///Whether trimout has been modified
@property (nonatomic, assign) BOOL isModifyRight;

///速度模块
///Speed module
@property (nonatomic, strong) UIView *speedControllView;
///速度滑杆
///Speed slide
@property (nonatomic, strong) CLSlider *mSlider;

///校色模块
///Color correction module
///亮度
///brightness
@property (nonatomic, strong) UISlider *brightnessSlider;
///对比度
///Contrast ratio
@property (nonatomic, strong) UISlider *contrastSlider;
///饱和度
///saturation
@property (nonatomic, strong) UISlider *saturationSlider;
///暗角
///Dark Angle
@property (nonatomic, strong) UISlider *VigetteSlider;
///锐度
///sharpness
@property (nonatomic, strong) UISlider *SharpenSlider;
///模块滑动数组
///Modular sliding array
@property (nonatomic, strong) NSMutableArray *moduleArray;
///模块滑视图
///Module slide view
@property (nonatomic, strong) UICollectionView *moduleCollectionView;
///当前滑动对象
///Current sliding object
@property (nonatomic, strong) NvCorrectionModel *currentCorrectionModel;

///滤镜模块
///Filter module
///滤镜视图
///Filter view
@property (nonatomic, strong) NvEditFilterView  *filterView;
@property (nonatomic, strong) NvAdjustFxParamView *filterPrmView;
///关键帧视图
///Keyframe view
@property (nonatomic, strong) NvEditKeyFrameView *keyFrameView;
@property (nonatomic, strong) NvAssetManager *assetManager;
@property (nonatomic, strong) NvTimeFilterInfoModel *currentInfoModel;

///音量模块
///Volume module
///音量滑杆
///Volume slide
@property (nonatomic, strong) UISlider *volumeSlider;
///音量显示
///Volume display
@property (nonatomic, strong) UILabel *volumeMaxlabel;

//-----------------sdk相关  sdk related----------------//
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
///数据结构
///Data structure
@property (nonatomic, strong) NvTimelineData *timelineData;
///裁剪需要用到
///Tailoring is needed
@property (nonatomic, strong) NvEditDataModel *originClipModel;
///视频操作的片段对象
///A fragment object for a video operation
@property (nonatomic, strong) NvsVideoClip *videoClip;
///片段颜色操作特效
///Segment color manipulation effects
@property (nonatomic, strong) NvsVideoFx *colorVideoFx;
///片段锐度特效
///Segment sharpness effect
@property (nonatomic, strong) NvsVideoFx *SharpenVideoFx;
///片段暗角特效
///Dark corner effects for clips
@property (nonatomic, strong) NvsVideoFx *VignetteVideoFx;
///片段旋转操作特效
///Segment rotation manipulation effects
@property (nonatomic, strong) NvsVideoFx *transVideoFx;
///缩放平移操作特效
///Panning operation effect
@property (nonatomic, strong) NvsVideoFx *scaleVideoFx;
///音频操作的片段对象
///Snippet objects for audio operations
@property (nonatomic, strong) NvsAudioClip *audioClip;
///这个时间线上只有一个片段
///There's only one fragment of this timeline
@property (nonatomic, strong) NvsTimeline *clipTimeline;
///是否分割
///Split or not
@property (nonatomic, assign) BOOL isSegmentation;
///当前应用滤镜
///Currently apply the filter
@property (nonatomic, strong) NvsVideoFx *currentFx;

@property (nonatomic, strong) UIView *bottomLineView;

@property (nonatomic, assign) BOOL isChange;
@property (nonatomic, assign) CGFloat scaleForSeek;
@end

@implementation NvEditTailoringViewController

- (void)dealloc{
    NSLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.moduleArray = [NSMutableArray array];
    self.streamingContext = [NvSDKUtils getSDKContext];
    self.clipTimeline = [NvTimelineUtils createTimeline:self.editMode];
    self.timelineData = [NvTimelineData sharedInstance];
    
    self.originClipModel = [NvEditDataModel new];
    self.originClipModel.trimIn = _model.trimIn;
    self.originClipModel.trimOut = _model.trimOut;
    self.originClipModel.duration = _model.trimOut - _model.trimIn;
    self.originClipModel.speed = self.model.speed;
    
    
    if ([self.title isEqualToString:NvLocalString(@"Crop", @"裁剪")]) {
        self.model.trimIn = _model.trimIn > 0 ? _model.trimIn : 0;
        self.model.trimOut = _model.trimOut > 0 ? _model.trimOut : _model.duration;
    }
    
    [NvTimelineUtils resetEditData:self.clipTimeline editDataArray:[NSArray arrayWithObject:_model]];
    [NvTimelineUtils resetVideoFx:self.clipTimeline videoFxDataArray:[self getClipTimelineFilter:_model]];
    self.videoClip = [[self.clipTimeline getVideoTrackByIndex:0] getClipWithIndex:0];
    [NvTimelineUtils removeClipCropAndTransformFx:self.videoClip];
    
    self.audioClip = [[self.clipTimeline getAudioTrackByIndex:0] getClipWithIndex:0];
    self.colorVideoFx = [self getVideoFx:self.videoClip name:@"Color Property"];
    self.transVideoFx = [self getVideoFx:self.videoClip name:@"Transform 2D"];
    self.scaleVideoFx = [self getVideoFx:self.videoClip name:@"Transform 2D"];
    self.SharpenVideoFx = [self getVideoFx:self.videoClip name:@"Sharpen"];
    self.VignetteVideoFx = [self getVideoFx:self.videoClip name:@"Vignette"];
    self.clipLivewindow = [[NvEditClipLiveWindow alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width)];
    [self.view addSubview:self.clipLivewindow];
    [self.clipLivewindow connectTimeline:self.clipTimeline];
    self.clipLivewindow.editMode = self.editMode;
//    self.clipLivewindow.model = self.originClipModel;
    [self.clipLivewindow setPlayRangeIn:0 rangeOut:self.originClipModel.trimOut/_originClipModel.speed];
    [self.clipLivewindow seekTimeline:0];
    self.clipLivewindow.delegate = self;
    [self addSubViews];
    
    if ([self.title isEqualToString:NvLocalString(@"Split", @"分割")]) {
        if (self.model.trimOut - self.model.trimIn <= 1000000) {
            
            NVWeakSelf
            [UIAlertController presentAlertFromVC:self
                                            title:NvLocalString(@"Tips" , @"提示")
                                          message:NvLocalString(@"Split limit", @"不可分割小于1秒的素材")
                                buttonTitleColors:nil
                                cancelButtonTitle:nil
                                 otherButtonTitle:NvLocalString(@"Know", @"知道了")
                               cancelButtonAction:nil
                                otherButtonAction:^(UIAlertAction * _Nonnull action) {
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
            [self.clipLivewindow seekTimeline:0];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.title isEqualToString:NvLocalString(@"Filter", @"滤镜")]) {
        if (self.model.filterKeyFrames.count > 0) {
            NvsVideoTrack *track = [self.clipTimeline getVideoTrackByIndex:0];
            NvsVideoClip *clip = [track getClipWithIndex:0];
            self.currentFx =[clip getRawFxByIndex:clip.getRawFxCount-1];
            
            if (clip.getRawFxCount>0 && self.currentFx) {
                for (int k=0; k<self.model.filterKeyFrames.count; k++) {
                    NvKeyFrameFilterModel *model = self.model.filterKeyFrames[k];
                    if (model.time - self.model.trimIn <= clip.outPoint && model.time - self.model.trimIn >= clip.inPoint) {

                        [self.currentFx setFloatValAtTime:@"Filter Intensity" val:model.value time:model.time - self.model.trimIn];
                    }

                }
            }
            
        }
       
        self.keyFrameView.timeline = self.clipTimeline;
        if (self.model.filterKeyFrames.count > 0) {
            self.filterView.hasKeyframes = YES;
        }else{
            self.filterView.hasKeyframes = NO;
        }
        [self.filterView reloadData];
        [self reloadDataWithSelectedModel];
        [self seekTimeline:0];
    }
    
}


- (void)reloadDataWithSelectedModel{
    [self.filterView reloadDataWithSelectedModel:self.currentInfoModel];
    self.filterView.strengthLabel.text = [NSString stringWithFormat:@"%@ %.f", NvLocalString(@"fxStrength", @"强度"),self.currentInfoModel.strength*100];
    if (self.currentInfoModel.categoryId == 2 && (self.currentInfoModel.kindId == 8||self.currentInfoModel.kindId == 9)){
        self.filterView.strengthSlider.hidden = YES;
        self.filterView.strengthLabel.hidden =  YES;
        self.filterView.keyFrameView.hidden = YES;
    }
}

- (NSMutableArray *)getClipTimelineFilter:(NvEditDataModel *)clipInfo {
    NSUInteger index = [[NvTimelineData sharedInstance].editDataArray indexOfObject:clipInfo];
    NSMutableArray *filters = [[NvTimelineData sharedInstance] videoFxDataArray];
    NSMutableArray *clipFilters = NSMutableArray.new;
    if (filters.count > index) {
        NvTimeFilterInfoModel *filterModel = filters[index];
        NvTimeFilterInfoModel *clipFilter = [filterModel copy];
        clipFilter.inPoint = 0;
        clipFilter.outPoint = _clipTimeline.duration;
        [clipFilters addObject:clipFilter];
    } else {
        
    }
    return clipFilters;
}

- (NvsVideoFx *)getVideoFx:(NvsVideoClip *)clip name:(NSString *)name {
    for (int i = 0; i < clip.fxCount; i++) {
        NvsVideoFx *videoFx = [clip getFxWithIndex:i];
        if ([videoFx.bultinVideoFxName isEqualToString:name])
            return videoFx;
    }
    return nil;
}

- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

- (void)addSubViews{
    if ([self.title isEqualToString:NvLocalString(@"Split", @"分割")]) {
        [self functionSplit];
    }else{
        UIButton *finsh = [UIButton buttonWithType:UIButtonTypeCustom];
        [finsh setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
        [finsh addTarget:self action:@selector(finshClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:finsh];
        [finsh mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.width.equalTo(@(25*SCREENSCALEHEIGHT));
            make.height.equalTo(@(20*SCREENSCALE));
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(@(-15*SCREENSCALE));
            }
        }];
        
        self.bottomLineView = [UIView new];
        self.bottomLineView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
        [self.view addSubview:self.bottomLineView];
        [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.height.equalTo(@1);
            make.bottom.equalTo(finsh.mas_top).offset(-12*SCREENSCALE);
        }];
        
        if ([self.title isEqualToString:NvLocalString(@"Crop", @"裁剪")]) {
            [self functionCrop];
        }else if ([self.title isEqualToString:NvLocalString(@"Color correction", @"校色")]){
            [self functionCorrection];
        }else if ([self.title isEqualToString:NvLocalString(@"Filter", @"滤镜")]){
            [self functionFilter];
        }else if ([self.title isEqualToString:NvLocalString(@"Speed", @"速度")]){
            [self functionSpeed];
        }else if ([self.title isEqualToString:NvLocalString(@"Volume", @"音量")]){
            [self functionVolume];
        }
        
        [self.view bringSubviewToFront:finsh];
        [self.view bringSubviewToFront:self.bottomLineView];
    }
    [self.clipLivewindow play];
}

#pragma mark 裁剪
///cutting
- (void)functionCrop{
    self.textLabel = [UILabel new];
    self.textLabel.textColor = UIColor.whiteColor;
    self.textLabel.alpha = 0.8;
    self.textLabel.font = [NvUtils fontWithSize:10 * SCREENSCALE];
    self.textLabel.text = [NSString stringWithFormat:NvLocalString(@"croppingTime", @"裁剪后总时长为%@"),[NvUtils convertTimecodePrecisional:self.originClipModel.duration/_originClipModel.speed]];
    [self.view addSubview:_textLabel];
    [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.clipLivewindow.mas_bottom).offset(12 * SCREENSCALE);
        make.centerX.equalTo(self.clipLivewindow.mas_centerX);
    }];
    
    self.timeLineEdit = [[NvsTimelineEditor alloc] initWithFrame:CGRectMake(13 * SCREENSCALE,426 * SCREENSCALE, 350 * SCREENSCALE,90 * SCREENSCALE)];
    self.timeLineEdit.caneditTimeSpan = YES;
    self.timeLineEdit.canOverlapTimeSpan = YES;
    self.timeLineEdit.timelinePosition = self.model.duration/_model.speed;
    [self.view addSubview:self.timeLineEdit];
    NvsTimelineEditorInfo *info = [[NvsTimelineEditorInfo alloc] init];
    
    info.mediaFilePath = self.model.videoPath;
    info.inPoint = 0;
    info.outPoint = self.model.duration/_model.speed;
    info.trimIn = self.model.trimIn;
    info.trimOut = self.model.trimOut;
    info.stillImageHint = false;
    [self.timeLineEdit initTimelineEditor:@[info] timelineDuration:self.model.duration/_model.speed];
    self.timeLineEdit.delegate = self;
    self.timeLineEdit.type = 0;
    ///添加两边滑块
    ///Add sliders on both sides
    self.timeSpan = [self.timeLineEdit addTimeSpan:0 outPoint:self.model.duration/_model.speed];
    
    self.timeSpan.inPoint = 0;
    self.timeSpan.outPoint = self.originClipModel.duration/_model.speed;
    [self.clipLivewindow seekTimeline:0];
    [self.clipLivewindow setPlayRangeIn:0 rangeOut:self.originClipModel.duration/_model.speed];
    
    [self.timeSpan setSelected:YES];
    self.timeSpan.editable = self.model.duration > NV_TIME_BASE ? YES : NO;
}

#pragma mark 分割
///partition
- (void)functionSplit{
    _isSegmentation = YES;
    self.textLabel = [UILabel new];
    self.textLabel.alpha = 0.8;
    self.textLabel.textColor = UIColor.whiteColor;
    self.textLabel.font = [NvUtils fontWithSize:10 * SCREENSCALE];
    self.textLabel.text = [NSString stringWithFormat:@"%@/%@",[NvUtils convertTimecodePrecisional:(self.originClipModel.duration/self.originClipModel.speed)/2],[NvUtils convertTimecodePrecisional:(self.originClipModel.duration/self.originClipModel.speed)/2]];
    [self.view addSubview:_textLabel];
    [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.clipLivewindow.mas_bottom).offset(12 * SCREENSCALE);
        make.centerX.equalTo(self.clipLivewindow.mas_centerX);
    }];
    self.timeLineEdit = [[NvsTimelineEditor alloc] initWithFrame:CGRectMake(13 * SCREENSCALE,426 * SCREENSCALE, 350 * SCREENSCALE,90 * SCREENSCALE)];
    self.timeLineEdit.caneditTimeSpan = YES;
    self.timeLineEdit.canOverlapTimeSpan = YES;
    self.timeLineEdit.type = 1;
    self.timeLineEdit.timelinePosition = (self.model.trimOut - self.model.trimIn)/_model.speed;
    [self.view addSubview:self.timeLineEdit];
    NvsTimelineEditorInfo *info = [[NvsTimelineEditorInfo alloc] init];
    
    info.mediaFilePath = self.model.videoPath;
    info.inPoint = 0;
    info.outPoint = (self.model.trimOut - self.model.trimIn)/_model.speed;
    info.trimIn = self.model.trimIn;
    info.trimOut = self.model.trimOut;
    info.stillImageHint = false;
    [self.timeLineEdit initTimelineEditor:@[info] timelineDuration:(self.model.trimOut - self.model.trimIn)/_model.speed];
    self.timeLineEdit.delegate = self;
    
    self.splitTime = (self.model.trimOut - self.model.trimIn) / 2.0;
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setImage:NvImageNamed(@"NvSegmentationCancel") forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    [cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(@(-15*SCREENSCALE));
        }
        
        make.left.equalTo(self.view).offset(13 * SCREENSCALE);
    }];
    
    UIButton *finshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [finshBtn setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [finshBtn addTarget:self action:@selector(finshClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finshBtn];
    [finshBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(@(-15*SCREENSCALE));
        }
        
        make.right.equalTo(self.view).offset(-13 * SCREENSCALE);
    }];
    
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(finshBtn.mas_top).offset(-12*SCREENSCALE);
    }];
}

#pragma mark 校色
///校色
///Color correction
- (void)functionCorrection{
    UIButton *correctReset = [UIButton buttonWithType:UIButtonTypeCustom];
    [correctReset setImage:NvImageNamed(@"NvEditCorrectReset") forState:UIControlStateNormal];
    [correctReset addTarget:self action:@selector(correctResetClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:correctReset];
    [correctReset mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.clipLivewindow.mas_bottom).offset(15 * SCREENSCALE);
        make.right.equalTo(self.view.mas_right).offset(- 15 * SCREENSCALE);
    }];
    
    NSArray *valueArray = @[[NSString stringWithFormat:@"%f",self.model.brightness],
                            [NSString stringWithFormat:@"%f",self.model.contrast],
                            [NSString stringWithFormat:@"%f",self.model.saturation],
                            [NSString stringWithFormat:@"%f",self.model.Vignette],
                            [NSString stringWithFormat:@"%f",self.model.Sharpen],
                            ];
    NSArray *correctionTitle = @[NvLocalString(@"Brightness", @"亮度"), NvLocalString(@"Contrast", @"对比度"), NvLocalString(@"Saturation", @"饱和度"), NvLocalString(@"Degree", @"暗角"), NvLocalString(@"Amount", @"锐度")];
    NSArray *correctionTitle1 = @[@"Brightness", @"Contrast", @"Saturation", @"Degree", @"Amount"];
    for (int i = 0; i < correctionTitle.count; i++) {
        NvCorrectionModel *correctionModel = [NvCorrectionModel new];
        UISlider *correction_slider = [UISlider new];
        
        if ([correctionTitle[i] isEqualToString:NvLocalString(@"Degree", @"暗角")]) {
            [correction_slider setMinimumValue:0];
            [correction_slider setMaximumValue:1];
        }else if ([correctionTitle[i] isEqualToString:NvLocalString(@"Amount", @"锐度")]){
            [correction_slider setMinimumValue:0];
            [correction_slider setMaximumValue:5];
        }else{
            [correction_slider setMinimumValue:0];
            [correction_slider setMaximumValue:2];
        }
        
        correction_slider.minimumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#979797"];
        correction_slider.maximumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#979797"];
        [correction_slider setThumbImage:NvImageNamed(@"NvSliderIcon") forState:UIControlStateNormal];
        [correction_slider addTarget:self action:@selector(sliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:correction_slider];
        
        
        correction_slider.value = [valueArray[i] floatValue];
        correctionModel.text = correctionTitle[i];
        correctionModel.slider = correction_slider;
        correctionModel.typeString = correctionTitle1[i];
        
        [correction_slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.clipLivewindow.mas_bottom).offset(72 * SCREENSCALE);
            make.centerX.equalTo(self.view);
            make.width.offset(350 * SCREENSCALE);
            make.height.offset(10);
        }];
        
        [self.moduleArray addObject:correctionModel];
        if (i == 0) {
            self.currentCorrectionModel = correctionModel;
            correctionModel.select = YES;
            correction_slider.hidden = NO;
        }else{
            correctionModel.select = NO;
            correction_slider.hidden = YES;
        }
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(SCREENWIDTH/correctionTitle.count * SCREENSCALE, 60 * SCREENSCALE);
    layout.minimumLineSpacing = 10 * SCREENSCALE;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 10*SCREENSCALE, 0, 0);
    _moduleCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,0,0) collectionViewLayout:layout];
    _moduleCollectionView.delegate = self;
    _moduleCollectionView.dataSource = self;
    _moduleCollectionView.backgroundColor = [UIColor clearColor];
    _moduleCollectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_moduleCollectionView];
    [_moduleCollectionView registerClass:[NvCorrectionCViewCell class] forCellWithReuseIdentifier:@"NvCorrectionCViewCell"];
    [_moduleCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.clipLivewindow.mas_bottom).offset(100 * SCREENSCALE);
        make.centerX.equalTo(self.view);
        make.width.offset(SCREENWIDTH);
        make.height.offset(60 * SCREENSCALE);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.moduleCollectionView reloadData];
    });
}

#pragma mark 滤镜
///filter
- (void)functionFilter {
    [self.view layoutIfNeeded];
    self.filterView = [NvEditFilterView filterViewWithAspectRatio:AspectRatio_All delegate:self];
    [self.view addSubview:self.filterView];
    CGRect frame = self.filterView.frame;
    frame.origin.y = CGRectGetMaxY(self.clipLivewindow.frame);
    frame.size.height= CGRectGetMinY(self.bottomLineView.frame) - CGRectGetMaxY(self.clipLivewindow.frame) - NV_STATUSBARHEIGHT - NV_NAV_BAR_HEIGHT - INDICATOR;
    self.filterView.frame = frame;
    self.filterView.viewDelegate = self;
    [self.filterView backColor:UIColor.clearColor];
    
    [self.filterView replaceTopViewAndSetupSegmentView];
    
    self.assetManager = [NvAssetManager sharedInstance];
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"filter" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_FILTER bundlePath:itemPath];
    [self.assetManager searchLocalAssets:ASSET_FILTER];
    ///已有的滤镜效果，在数组中找到该model设置选中
    ///With the existing filter effect, find the model Settings in the array and select them
    NSArray *fxDataArray = [[NvTimelineData sharedInstance] videoFxDataArray];
    if ([fxDataArray count] > self.currentIndex) {
        self.currentInfoModel = fxDataArray[self.currentIndex];
    } else {
        self.currentInfoModel = nil;
    }
    
    [self.view addSubview:self.keyFrameView];
    [self.keyFrameView setTrimIn:self.model.trimIn trimOut:self.model.trimOut];
    
    CGFloat y = CGRectGetMaxY(self.clipLivewindow.frame);
    CGFloat height = self.filterView.frame.size.height - self.filterView.bottomTotalHeitht;
    self.filterPrmView = [[NvAdjustFxParamView alloc] initWithFrame:CGRectMake(0, y, SCREENWIDTH, height) fxParams:nil translation:nil];
    self.filterPrmView.backgroundColor = self.view.backgroundColor;
    self.filterPrmView.delegate = self;
    self.filterPrmView.hidden = YES;
    [self.view addSubview:self.filterPrmView];
    
    if (self.currentInfoModel) {
        if (![self.currentInfoModel.name isEqualToString:@"无"]) {
            [self checkAssetExpValueList:self.currentInfoModel type:NvsAssetPackageType_VideoFx with:YES];
        }
    }else{
        self.currentInfoModel = [[NvTimeFilterInfoModel alloc]init];
    }
    [self reloadDataWithSelectedModel];
    
    NvsVideoTrack *track = [self.clipTimeline getVideoTrackByIndex:0];
    NvsVideoClip *clip = [track getClipWithIndex:0];
    self.currentFx =[clip getRawFxByIndex:clip.getRawFxCount-1];
}

#pragma mark 速度
///speed
- (void)functionSpeed{
    NSInteger index = 0;
    if (self.model.speed == 1.0/8) {
        index = 0;
    }else if (self.model.speed == 1.0/4){
        index = 1;
    }else if (self.model.speed == 1.0/2){
        index = 2;
    }else if (self.model.speed == 1){
        index = 3;
    }else if (self.model.speed == 1.5){
        index = 4;
    }else if (self.model.speed == 2){
        index = 5;
    }
    
    self.textLabel = [UILabel new];
    self.textLabel.textColor = UIColor.whiteColor;
    self.textLabel.alpha = 0.8;
    self.textLabel.font = [NvUtils fontWithSize:10 * SCREENSCALE];
    self.textLabel.text = [NSString stringWithFormat:@"%@", NvLocalString(@"Adjustment speed", @"按住滑块调整速度")];
    [self.view addSubview:_textLabel];
    [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.clipLivewindow.mas_bottom).offset(40 * SCREENSCALE);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    self.speedControllView = [[UIView alloc]init];
    [self.view addSubview:self.speedControllView];
    [self.speedControllView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textLabel.mas_bottom).offset(20);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.offset(250 * SCREENSCALE);
        make.height.offset(60 * SCREENSCALE);
    }];
    
    self.mSlider = [CLSlider new];
    self.mSlider.sliderStyle = CLSliderStyle_Point;
    self.mSlider.thumbDiameter = 13;
    self.mSlider.scaleLineColor = [UIColor whiteColor];
    self.mSlider.scaleLineWidth = 3;
    self.mSlider.scaleLineHeight = 4;
    self.mSlider.scaleLineNumber = 5;
    [self.mSlider setSelectedIndex:index];
    [self.mSlider addTarget:self action:@selector(sliderChangeAction:) forControlEvents:UIControlEventValueChanged];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [self.mSlider addGestureRecognizer:tap];
    self.mSlider.frame = CGRectMake(0, 0 * SCREENSCALE, 250 * SCREENSCALE, 30 * SCREENSCALE);
    [self.speedControllView addSubview:self.mSlider];
    
    for (int i = 0; i<6; i++) {
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake((i*(247* SCREENSCALE-10* SCREENSCALE)/5.0 * SCREENSCALE) - 15* SCREENSCALE, 40 * SCREENSCALE, 44 * SCREENSCALE, 20 * SCREENSCALE)];
        if (SCREENWIDTH == 320) {
            lable.frame = CGRectMake((i*(287* SCREENSCALE-10* SCREENSCALE)/5.0 * SCREENSCALE) - 15* SCREENSCALE, 40 * SCREENSCALE, 44 * SCREENSCALE, 20 * SCREENSCALE);
        }else if(SCREENWIDTH == 414){
            lable.frame = CGRectMake((i*(225* SCREENSCALE-10* SCREENSCALE)/5.0 * SCREENSCALE) - 15* SCREENSCALE, 40 * SCREENSCALE, 44 * SCREENSCALE, 20 * SCREENSCALE);
        }
        lable.textAlignment = NSTextAlignmentCenter;
        lable.textColor = UIColor.whiteColor;
        lable.alpha = 0.8;
        lable.font = [NvUtils fontWithSize:10 * SCREENSCALE];
        [self.speedControllView addSubview:lable];
        switch (i) {
            case 0:
                lable.text = @"1/8X";
                break;
            case 1:
                lable.text = @"1/4X";
                break;
            case 2:
                lable.text = @"1/2X";
                break;
            case 3:
                lable.text = @"1X";
                break;
            case 4:
                lable.text = @"1.5X";
                break;
            case 5:
                lable.text = @"2X";
                break;
            default:
                break;
        }
    }
}

#pragma mark 音量
///volume
- (void)functionVolume{
    UILabel *volumeLabel = [UILabel new];
    volumeLabel.text = NvLocalString(@"Volume", @"音量");
    volumeLabel.textColor = UIColor.whiteColor;
    volumeLabel.alpha = 0.8;
    volumeLabel.font = [NvUtils fontWithSize:12 * SCREENSCALE];
    [self.view addSubview:volumeLabel];
    
    UILabel *minlabel = [UILabel new];
    minlabel.text = @"0";
    minlabel.textColor = UIColor.whiteColor;
    minlabel.alpha = 0.8;
    minlabel.font = [NvUtils fontWithSize:12 * SCREENSCALE];
    [self.view addSubview:minlabel];
    
    self.volumeSlider = [UISlider new];
    [self.volumeSlider setMinimumValue:0];
    [self.volumeSlider setMaximumValue:100];
    self.volumeSlider.minimumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    self.volumeSlider.maximumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    [self.volumeSlider setThumbImage:NvImageNamed(@"Nvslider") forState:UIControlStateNormal];
    [self.volumeSlider addTarget:self action:@selector(sliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.volumeSlider];
    
    self.volumeMaxlabel = [UILabel new];
    self.volumeMaxlabel.text = [NSString stringWithFormat:@"%d",(int)(self.model.volume * 50)];
    self.volumeMaxlabel.textColor = UIColor.whiteColor;
    self.volumeMaxlabel.alpha = 0.8;
    self.volumeMaxlabel.font = [NvUtils fontWithSize:12 * SCREENSCALE];
    [self.view addSubview:self.volumeMaxlabel];
    
    [volumeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.clipLivewindow.mas_bottom).offset(72 * SCREENSCALE);
        make.left.equalTo(self.view).offset(13 * SCREENSCALE);
    }];
    
    [minlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(volumeLabel.mas_right).offset(18 * SCREENSCALE);
        make.centerY.equalTo(volumeLabel.mas_centerY);
    }];
    
    [self.volumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(minlabel.mas_right).offset(11 * SCREENSCALE);
        make.centerY.equalTo(volumeLabel.mas_centerY);
        make.width.offset(254 * SCREENSCALE);
        make.height.offset(10 * SCREENSCALE);
    }];
    
    [self.volumeMaxlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.volumeSlider.mas_right).offset(11 * SCREENSCALE);
        make.centerY.equalTo(volumeLabel.mas_centerY);
    }];
    
    self.volumeSlider.value = self.model.volume * 50;
}

#pragma mark 是否允许多个手势并发
///Whether to allow multiple gestures concurrently
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

#pragma mark 两点间的距离
///The distance between two points
- (BOOL)distancePreviousPoint:(CGPoint)previous point:(CGPoint)current{
    CGFloat distance = sqrtf(powf(previous.x - current.x, 2) + powf(previous.y - current.y, 2));
    if (distance > 10) {
        return YES;
    }
    return NO;
}

#pragma mark 坐标转换
///Coordinate transformation
- (CGPoint)conversionPoint:(CGPoint)point{
    CGPoint currtnetPoint = [_clipLivewindow.liveWindow mapViewToNormalized:point];
    return currtnetPoint;
}

#pragma mark 取消按钮点击事件
///Cancel button click event
- (void)cancelClick:(UIButton *)sender{
    [NvTimelineUtils removeTimeline:self.clipTimeline];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 完成按钮点击事件
///Complete the button click event
- (void)finshClick:(UIButton *)sender{
    if ([self.title isEqualToString:NvLocalString(@"Crop", @"裁剪")]) {
        if (_isModifyLeft) {
            self.model.trimIn = self.originClipModel.trimIn + self.trimIn*_model.speed;
            self.model.isLoading = NO;
        }else{
            self.model.trimIn = self.originClipModel.trimIn;
        }

        if (_isModifyRight) {
            self.model.trimOut = self.originClipModel.trimOut - (self.originClipModel.duration - self.trimOut*_model.speed);
            self.model.isLoading = NO;
        }else{
            self.model.trimOut = self.originClipModel.trimOut;
        }
        self.model.duration = self.model.trimOut - self.model.trimIn;
        
        for (NvCaptionInfoModel *model in self.model.captionDataArray) {
            int64_t duration = model.outPoint - model.inPoint;
            if (model.inPoint - (self.model.trimIn - self.originClipModel.trimIn) > 0) {
                model.inPoint = model.inPoint - (self.model.trimIn - self.originClipModel.trimIn);
            }else{
                duration = duration - (self.model.trimIn - self.originClipModel.trimIn - model.inPoint);
                model.inPoint = 0;
            }
            if (duration  > self.model.trimOut - self.model.trimIn - model.inPoint) {
                duration = self.model.trimOut - self.model.trimIn - model.inPoint;
            }
            model.outPoint = model.inPoint + duration;
        }
        
        for (NvStickerInfoModel *model in self.model.stickerDataArray) {
            int64_t duration = model.outPoint - model.inPoint;
            if (model.inPoint - (self.model.trimIn - self.originClipModel.trimIn) > 0) {
                model.inPoint = model.inPoint - (self.model.trimIn - self.originClipModel.trimIn);
            }else{
                duration = duration - (self.model.trimIn - self.originClipModel.trimIn - model.inPoint);
                model.inPoint = 0;
            }
            if (duration  > self.model.trimOut - self.model.trimIn - model.inPoint) {
                duration = self.model.trimOut - self.model.trimIn - model.inPoint;
            }
            model.outPoint = model.inPoint + duration;
        }
        
        
        NSMutableArray *toBeDelete = [NSMutableArray array];
        for (NvKeyFrameFilterModel *model in self.model.filterKeyFrames) {
            if (model.time <= self.model.trimOut && model.time >= self.model.trimIn) {
                
            }else{
                [toBeDelete addObject:model];
            }
        }
        [self.model.filterKeyFrames removeObjectsInArray:toBeDelete];
        self.editBlock(self.model,0);
    } else if ([self.title isEqualToString:NvLocalString(@"Split", @"分割")]) {
        if (_isSegmentation) {
            ///分割出来的视频
            ///The segmented video
            NvEditDataModel *dataModel = [self.model copy];
            dataModel.trimIn = self.splitTime + self.model.trimIn;
            dataModel.duration = dataModel.trimOut - dataModel.trimIn;
            dataModel.isLoading = NO;
            dataModel.filterKeyFrames = [NSMutableArray array];
            [dataModel.filterKeyFrames removeAllObjects];
            
            [self.model.filterKeyFrames removeAllObjects];
            ///原视频
            ///Original video
            self.model.trimOut = self.splitTime + self.model.trimIn;
            self.model.duration = self.model.trimOut - self.model.trimIn;
            
            if (self.model.animationInfoModel.animationEnd - self.model.animationInfoModel.animationStart > self.model.trimOut - self.model.trimIn) {
                self.model.animationInfoModel.animationStart = 0;
                self.model.animationInfoModel.animationEnd = self.model.trimOut - self.model.trimIn;
            }
            
            if (dataModel.animationInfoModel.animationEnd - dataModel.animationInfoModel.animationStart > dataModel.trimOut - dataModel.trimIn) {
                dataModel.animationInfoModel.animationStart = 0;
                dataModel.animationInfoModel.animationEnd = dataModel.trimOut - dataModel.trimIn;
            }
            
            [self.timelineData.editDataArray insertObject:dataModel atIndex:self.currentIndex + 1];
            self.editBlock(dataModel,1);
        }
    } else if ([self.title isEqualToString:NvLocalString(@"Filter", @"滤镜")]) {
        NSMutableArray *fxDataArray = [[NvTimelineData sharedInstance] videoFxDataArray];
        if ([fxDataArray count] > self.currentIndex) {
            [fxDataArray replaceObjectAtIndex:self.currentIndex withObject:self.currentInfoModel];
        } else {
            [fxDataArray addObject:self.currentInfoModel];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 校色重置correctResetClick点击事件
///correctResetClick CorrectresetClick event
- (void)correctResetClick:(UIButton *)sender{
    for (int i = 0; i < self.moduleArray.count; i++) {
        NvCorrectionModel *model = self.moduleArray[i];
        if ([model.text isEqualToString:NvLocalString(@"Brightness", @"亮度")]) {
            model.slider.value = 1;
            self.model.brightness = 1;
            [_colorVideoFx setFloatVal:model.typeString val:1];
        }else if ([model.text isEqualToString:NvLocalString(@"Contrast", @"对比度")]){
            model.slider.value = 1;
            self.model.contrast = 1;
            [_colorVideoFx setFloatVal:model.typeString val:1];
        }else if ([model.text isEqualToString:NvLocalString(@"Saturation", @"饱和度")]){
            model.slider.value = 1;
            self.model.saturation = 1;
            [_colorVideoFx setFloatVal:model.typeString val:1];
        }else if ([model.text isEqualToString:NvLocalString(@"Degree", @"暗角")]){
            model.slider.value = 0;
            self.model.Vignette = 0;
            [_VignetteVideoFx setFloatVal:model.typeString val:0];
        }else if ([model.text isEqualToString:NvLocalString(@"Amount", @"锐度")]){
            model.slider.value = 0;
            self.model.Sharpen = 0;
            [_SharpenVideoFx setFloatVal:model.typeString val:0];
        }
    }
}

#pragma mark 校色，音量，调整slider统一回调事件
///Adjust the color, volume, adjust slider unified callback event
- (void)sliderValueChangedAction:(UISlider *)slider{
    if ([slider isEqual:self.volumeSlider]) {
        int volume = slider.value;
        self.model.volume = volume/50.0;
        self.volumeMaxlabel.text = [NSString stringWithFormat:@"%d",volume];
        [_videoClip setVolumeGain:self.model.volume rightVolumeGain:self.model.volume];
    }else{
        if ([self.currentCorrectionModel.text isEqualToString:NvLocalString(@"Brightness", @"亮度")]) {
            self.model.brightness = slider.value;
            [_colorVideoFx setFloatVal:self.currentCorrectionModel.typeString val:slider.value];
        }else if ([self.currentCorrectionModel.text isEqualToString:NvLocalString(@"Contrast", @"对比度")]){
            self.model.contrast = slider.value;
            [_colorVideoFx setFloatVal:self.currentCorrectionModel.typeString val:slider.value];
        }else if ([self.currentCorrectionModel.text isEqualToString:NvLocalString(@"Saturation", @"饱和度")]){
            self.model.saturation = slider.value;
            [_colorVideoFx setFloatVal:self.currentCorrectionModel.typeString val:slider.value];
        }else if ([self.currentCorrectionModel.text isEqualToString:NvLocalString(@"Degree", @"暗角")]){
            self.model.Vignette = slider.value;
            [_VignetteVideoFx setFloatVal:self.currentCorrectionModel.typeString val:slider.value];
        }else if ([self.currentCorrectionModel.text isEqualToString:NvLocalString(@"Amount", @"锐度")]){
            self.model.Sharpen = slider.value;
            [_SharpenVideoFx setFloatVal:self.currentCorrectionModel.typeString val:slider.value];
        }
    }
    if (self.clipLivewindow.isPause) {
        [self.clipLivewindow play];
    }
}

#pragma mark timelineEditorDelegate
///滑动一直改变
///Sliding change
- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint{
    self.isChange = YES;
    if (isInPoint) {
        self.isModifyLeft = YES;
        self.trimIn = timestamp;
    }else{
        self.isModifyRight = YES;
        self.trimOut = timestamp;
    }
    [self seekTimeline:timestamp];
    [self.clipLivewindow updateUI:timestamp];
    [self.clipLivewindow setPlayRangeIn:self.trimIn rangeOut:self.trimOut];
    if (self.trimOut == 0.0) {
        self.trimOut = self.model.duration/_model.speed;
    }
    self.textLabel.text = [NSString stringWithFormat:NvLocalString(@"croppingTime", @"裁剪后总时长为%@"),[NvUtils convertTimecodePrecisional:self.trimOut - self.trimIn]];
}

///滑动改变停止
///Sliding change stop
- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)timestamp isInPoint:(bool)isInPoint{
    self.isChange = NO;
    [self seekTimeline:timestamp];
}

///分割功能：时码线控件回调事件
///Split function: time code line control callback event
- (void)timelineEditor:(id)timelineEditor handlePan:(int64_t)timestamp{
    self.textLabel.text = [NSString stringWithFormat:@"%@/%@",[NvUtils convertTimecodePrecisional:timestamp],[NvUtils convertTimecodePrecisional:(self.originClipModel.duration/_model.speed-timestamp)]];
    if (timestamp <= 0 || timestamp >= self.model.duration) {
        _isSegmentation = NO;
    }else{
        _isSegmentation = YES;
    }
    
    self.isChange = YES;
    self.splitTime = timestamp;
    [self seekTimeline:timestamp];
    [self.clipLivewindow updateUI:timestamp];
}

- (void)timelineEditor:(id)timelineEditor handlePanEnded:(int64_t)timestamp{
    self.isChange = NO;
    [self seekTimeline:timestamp];
}

#pragma mark - 定位某一时间戳的图像
///seekTimeline
- (void)seekTimeline:(int64_t)postion {
    int64_t pos = postion;
    if (pos > (self.clipTimeline.duration - 40000)) {
        pos = self.clipTimeline.duration - 40000;
    }
    int flags = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (self.isChange) {
        flags = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing;
        self.scaleForSeek = self.clipTimeline.duration / 1000000 /  [self.timeLineEdit getTimelineEditorWidth] / UIScreen.mainScreen.scale;
        [_streamingContext setTimeline:self.clipTimeline scaleForSeek:self.scaleForSeek];
    }
    
    if (![_streamingContext seekTimeline:self.clipTimeline
                               timestamp:pos
                           videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize
                                   flags:flags])
        NSLog(@"定位时间线失败！Failed to seek timeline!");
    
    if ([self.title isEqualToString:NvLocalString(@"Filter", @"滤镜")]) {
        self.keyFrameView.timelineEditor.timelinePosition = postion;
        BOOL hasPreFrame = [self hasPreKeyFrame:postion];
        BOOL hasNextFrame = [self hasNextKeyFrame:postion];
        BOOL hasKeyFrame = NO;
        for (NvKeyFrameFilterModel *model in self.model.filterKeyFrames) {
            if (model.time - self.model.trimIn == postion) {
                hasKeyFrame = YES;
                break;
            }
        }
        [self.keyFrameView setKeyFrameStatus:postion hasKeyFrame:hasKeyFrame hasPreKeyFrame:hasPreFrame hasNextKeyFrame:hasNextFrame];
        if (self.keyFrameView.frame.origin.y < SCREENHEIGHT) {
            [self updateFilterKeyFrameSlider:self.keyFrameView time:postion];
        }
    }
}

#pragma mark 速度模块回调事件
///Speed module callback event
///速度滑杆控件，滑动时回调事件
///Speed slider control, when sliding callback event
- (void)sliderChangeAction:(CLSlider*)clSlider {
    NSInteger index = clSlider.currentIdx;
    float speed = 1;
    switch (index) {
        case 0:
            speed = 1.0/8;
            break;
        case 1:
            speed = 1.0/4;
            break;
        case 2:
            speed = 1.0/2;
            break;
        case 3:
            speed = 1;
            break;
        case 4:
            speed = 1.5;
            break;
        case 5:
            speed = 2;
            break;
        default:
            break;
    }
    self.model.speed = speed;
    self.originClipModel.speed = speed;
    [NvTimelineUtils resetEditData:self.clipTimeline editDataArray:@[_model]];
    [self.clipLivewindow setPlayRangeIn:0 rangeOut:self.originClipModel.trimOut/_originClipModel.speed];
    [self.clipLivewindow seekTimeline:0];
    [self.clipLivewindow play];
}

///速度滑杆控件，点击按钮回调事件
///Speed slider control, click button callback event
- (void)tapClick:(UITapGestureRecognizer *)tapGestureRecognizer {
    CGPoint tapPoint = [tapGestureRecognizer locationInView:self.mSlider];
    for (int i = 0; i < 6; i++) {
        CGRect rect = CGRectMake((i*(250-10) * SCREENSCALE/5.0 * SCREENSCALE) - 15, 0, 44, 30);
        if (SCREENWIDTH == 320) {
            rect = CGRectMake((i*(287* SCREENSCALE-10* SCREENSCALE)/5.0 * SCREENSCALE) - 15* SCREENSCALE, 0 * SCREENSCALE, 44 * SCREENSCALE, 30 * SCREENSCALE);
        }else if(SCREENWIDTH == 414){
            rect = CGRectMake((i*(225* SCREENSCALE-10* SCREENSCALE)/5.0 * SCREENSCALE) - 15* SCREENSCALE, 0 * SCREENSCALE, 44 * SCREENSCALE, 30 * SCREENSCALE);
        }
        if (CGRectContainsPoint(rect,tapPoint)) {
            [self.mSlider setSelectedIndex:i];
            [self sliderChangeAction:self.mSlider];
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.moduleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvCorrectionCViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvCorrectionCViewCell" forIndexPath:indexPath];
    [cell renderCellWithModel:self.moduleArray[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([collectionView isEqual:_moduleCollectionView]) {
        self.currentCorrectionModel = self.moduleArray[indexPath.item];
        for (NvCorrectionModel *model in _moduleArray) {
            model.select = NO;
            model.slider.hidden = YES;
        }
        self.currentCorrectionModel.select = YES;
        [collectionView reloadData];
        self.currentCorrectionModel.slider.hidden = NO;
    }
}

#pragma mark - NvEditFilterViewDelegate
- (void)NvEditFilterViewAddKeyFrameView:(NvEditFilterView *)view {
    CGFloat yValue = CGRectGetMinY(self.filterView.frame);
    [UIView animateWithDuration:0.3 animations:^{
        self.keyFrameView.frame = CGRectMake(0, yValue, SCREENWIDTH, SCREENHEIGHT - INDICATOR - yValue);
        [self.view bringSubviewToFront:self.keyFrameView];
    } completion:^(BOOL finished) {
        if (finished) {
            self.keyFrameView.keyFrameArr = self.model.filterKeyFrames;
            
        }
    }];
}

- (void)NvEditFilterView:(NvEditFilterView *)view withFilterModel:(NvBaseModel *)model{
//    NSString *name = model.builtinName ? model.builtinName : model.packageId;
    if(self.model.filterKeyFrames.count > 0) {
        
        NVWeakSelf
        [UIAlertController presentAlertFromVC:self
                                        title:NvLocalString(@"Replace keyFrame Effects" , @"确定要替换关键帧内容?")
                                      message:nil
                            buttonTitleColors:nil
                            cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"album.cancel",@"NvAlbum",[NSBundle bundleForClass:self.class],nil)
                             otherButtonTitle:NSLocalizedStringFromTableInBundle(@"album.ok",@"NvAlbum",[NSBundle bundleForClass:self.class],nil)
                           cancelButtonAction:^(UIAlertAction * _Nonnull action) {
            
            [weakSelf.filterView refreshSelectedModel:weakSelf.currentInfoModel];
            
        } otherButtonAction:^(UIAlertAction * _Nonnull action) {
            
            [weakSelf applyFilterWithModel:model];
        }];
    }else {
        
        [self applyFilterWithModel:model];
    }
}

- (void)applyFilterWithModel:(NvBaseModel *)model {
    NvCaptureFilterModel *filterModel = (NvCaptureFilterModel *)model;
//    BOOL isHasDetection = [self.streamingContext.assetPackageManager hasDetectionInAssetPackage:filterModel.packageId type:NvsAssetPackageType_VideoFx];
//    if (isHasDetection){
        if (![NvInitArScence getInitArFace]) {
            if (ARSCENE_MS){
                [NvInitArScence initARFace:NvFaceMode_106];
            }else if (ARSCENE_MS_240){
                [NvInitArScence initARFace:NvFaceMode_240];
            }
        }
//    }
    
    NSString *nName;
    if (![model.displayName isEqualToString:NvLocalString(@"None", @"无")]) {
        nName = model.builtinName?model.builtinName:model.packageId;
    }else{
        nName = NvLocalString(@"None", @"无");
    }
    if ([self.currentInfoModel.name isEqualToString:nName]) {
//        return;
    }
    
    self.currentInfoModel.inPoint = 0;
    self.currentInfoModel.outPoint = self.clipTimeline.duration;
    self.currentInfoModel.grayscale = filterModel.grayscale;
    self.currentInfoModel.strokeOnly = filterModel.strokeOnly;
    self.currentInfoModel.strength = 1;
    self.currentInfoModel.categoryId = filterModel.categoryId;
    self.currentInfoModel.kindId = filterModel.kindId;
    [self.model.filterKeyFrames removeAllObjects];
    self.filterView.hasKeyframes = NO;
    self.currentInfoModel.name = nName;
    
    [self checkAssetExpValueList:self.currentInfoModel type:NvsAssetPackageType_VideoFx with:NO];
    
    NSMutableArray *videoFxDataArray = [NSMutableArray array];
    [videoFxDataArray addObject:self.currentInfoModel];
    [NvTimelineUtils resetVideoFx:self.clipTimeline videoFxDataArray:videoFxDataArray];
    NvsVideoTrack *track = [self.clipTimeline getVideoTrackByIndex:0];
    NvsVideoClip *clip = [track getClipWithIndex:0];
    self.currentFx = [clip getRawFxByIndex:clip.getRawFxCount-1];
    
    if (self.streamingContext.getStreamingEngineState != NvsStreamingEngineState_Playback) {
        [self.clipLivewindow setPlayRangeIn:0 rangeOut:self.originClipModel.trimOut/_originClipModel.speed];
        [NvTimelineUtils playbackTimeline:self.clipTimeline startTime:0 endTime:self.clipTimeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
    }
    
    if (filterModel.categoryId == 2 && (filterModel.kindId == 8||filterModel.kindId == 9)){
        self.filterView.strengthSlider.hidden = YES;
        self.filterView.strengthLabel.hidden =  YES;
        self.filterView.keyFrameView.hidden = YES;
    }
}

- (void)NvEditFilterView:(NvEditFilterView *)view sliderValueChanged:(UISlider *)slider{
    self.currentInfoModel.strength = slider.value;
    NvsVideoTrack *videoTrack = [self.clipTimeline getVideoTrackByIndex:0];
    NvTimelineData *timelineData = [NvTimelineData sharedInstance];
    for (int i = 0; i < videoTrack.clipCount; i++) {
        NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
        __block BOOL isSrcVideoAsset = NO;
        [timelineData.editDataArray enumerateObjectsUsingBlock:^(NvEditDataModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.localIdentifier isEqualToString:clip.filePath] || [obj.videoPath isEqualToString:clip.filePath]) {
                isSrcVideoAsset = YES;
            }
        }];
        if (!isSrcVideoAsset) {
            continue;
        }

        int fxCount = clip.getRawFxCount;
        for (int j = 0; j < fxCount; j++) {
            NvsVideoFx *videoFx = [clip getRawFxByIndex:j];
            NSString *name = [videoFx bultinVideoFxName];
            if([name isEqualToString:@"Transform 2D"] || [name isEqualToString:@"Color Property"] || [name isEqualToString:@"Sharpen"] || [name isEqualToString:@"Vignette"]|| [name isEqualToString:@"Crop"]) {
                continue;
            }
            [videoFx setFilterIntensity:slider.value];
        }
    }

    if (self.streamingContext.getStreamingEngineState != NvsStreamingEngineState_Playback) {
        [self seekTimeline:[self.streamingContext getTimelineCurrentPosition:self.clipTimeline]];
    }
}

- (void)NvEditFilterView:(NvEditFilterView *)view moreClick:(UIButton *)sender{
    NvMoreFilterViewController *vc = [[NvMoreFilterViewController alloc]init];
    vc.editModel = self.editMode;
    vc.type = ASSET_FILTER;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)checkAssetExpValueList:(NvTimeFilterInfoModel *)model type:(NvsAssetPackageType)type with:(BOOL)enterPage{
    NvsAssetPackageManager *assetPackageManager = self.streamingContext.assetPackageManager;
    NSArray <NvsExpressionParam *>* expArr = [assetPackageManager getExpValueList:model.name type:type];
    NSDictionary<NSString*, NSString*>* translation = [assetPackageManager getTranslationMap:model.name type:type];
    if (type == NvsAssetPackageType_VideoFx) {
        self.filterPrmView.hidden = expArr.count > 0 ? NO : YES;
        self.filterView.strengthSlider.hidden = !self.filterPrmView.hidden;
        self.filterView.strengthLabel.hidden = self.filterView.strengthSlider.hidden;
        if(expArr.count > 0){
            CGFloat y = CGRectGetMaxY(_clipLivewindow.frame) + 4*SCREENSCALE;
            CGRect segRect = [self.filterView convertRect:self.filterView.segView.frame toView:self.view];
            CGFloat height =  CGRectGetMinY(segRect) - y;
            self.filterPrmView.frame = CGRectMake(0, y, SCREENWIDTH, height);
            [self.filterPrmView updateFxParams:expArr translation:translation];
            if (enterPage && self.currentInfoModel.expModels.count > 0) {
                [self.filterPrmView updateInfoFxParams:self.currentInfoModel.expModels];
            }else if (!enterPage){
                [self updateDatasource:expArr translation:translation];
            }
        }
    }
}

- (void)updateDatasource:(NSArray *)fxParams translation:(NSDictionary *)translation{
    [self.currentInfoModel.expModels removeAllObjects];
    for (NvsExpressionParam *item in fxParams) {
        NvAjustFxParamModel *model = [NvAjustFxParamModel new];
        model.type = (NvAjustFxParamCategory)item.type;
        model.name = item.name;
        model.translationName = translation[item.name];
        if (model.type == NvAjustFxParamCategoryInt) {
            NvsExpressionIntParam *expression = (NvsExpressionIntParam *)item;
            model.defaultValue = expression.intParam.defaultValue;
            model.minValue = expression.intParam.minValue;
            model.maxValue = expression.intParam.maxValue;
            model.currentValue = model.defaultValue;
        }else if (model.type == NvAjustFxParamCategoryFloat){
            NvsExpressionFloatParam *expression = (NvsExpressionFloatParam *)item;
            model.defaultValue = expression.floatParam.defaultValue;
            model.minValue = expression.floatParam.minValue;
            model.maxValue = expression.floatParam.maxValue;
            model.currentValue = model.defaultValue;
        }else if (model.type == NvAjustFxParamCategoryColor){
            NvsExpressionColorParam *expression = (NvsExpressionColorParam *)item;
            model.r = expression.colorParam.defaultColor.r;
            model.g = expression.colorParam.defaultColor.g;
            model.b = expression.colorParam.defaultColor.b;
            model.a = expression.colorParam.defaultColor.a;
        }
        
        [self.currentInfoModel.expModels addObject:model];
    }
}

#pragma mark - NvAdjustFxParamViewDelegate
- (void)nvAdjustFxParamView:(NvAdjustFxParamView *)view valueChanged:(nonnull NSArray<NvAjustFxParamModel *> *)models {
    if (view == self.filterPrmView) {
        for(NvAjustFxParamModel *model in models) {
            if (model.type == NvAjustFxParamCategoryColor) {
                NvsColor color;
                color.r = model.r;
                color.g = model.g;
                color.b = model.b;
                color.a = model.a;
                [self.currentFx setColorExprVar:model.name varValue:&color];
            }
            else if (model.type == NvAjustFxParamCategoryInt || model.type == NvAjustFxParamCategoryFloat) {
                [self.currentFx setExprVar:model.name varValue:model.currentValue];
            }
        }
        self.currentInfoModel.expModels = [NSMutableArray arrayWithArray:models];
        if (self.streamingContext.getStreamingEngineState != NvsStreamingEngineState_Playback) {
            [self seekTimeline:[self.streamingContext getTimelineCurrentPosition:self.clipTimeline]];
        }
    }
}

- (void)nvAdjustFxParamView:(NvAdjustFxParamView *)view endChange:(NSArray<NvAjustFxParamModel *> *)models {
    if (view == self.filterPrmView) {
        for(NvAjustFxParamModel *model in models) {
            if (model.type == NvAjustFxParamCategoryColor) {
                NvsColor color;
                color.r = model.r;
                color.g = model.g;
                color.b = model.b;
                color.a = model.a;
                [self.currentFx setColorExprVar:model.name varValue:&color];
            }
            else if (model.type == NvAjustFxParamCategoryInt || model.type == NvAjustFxParamCategoryFloat) {
                [self.currentFx setExprVar:model.name varValue:model.currentValue];
            }
        }
        self.currentInfoModel.expModels = [NSMutableArray arrayWithArray:models];
        if (self.streamingContext.getStreamingEngineState == NvsStreamingEngineState_Playback) {
            [self.streamingContext stop];
        }
        [self.clipLivewindow play];
    }
}

#pragma mark - NvEditKeyFrameViewDelegate
- (void)nvEditKeyFrameViewFinishButtonClicked:(NvEditKeyFrameView *)keyFrameView {
    CGSize size = self.keyFrameView.frame.size;
    [UIView animateWithDuration:0.3 animations:^{
        self.keyFrameView.frame = CGRectMake(0, SCREENHEIGHT + INDICATOR, size.width, size.height);
        if (self.model.filterKeyFrames.count > 0) {
            self.filterView.hasKeyframes = YES;
        }else{
            self.filterView.hasKeyframes = NO;
        }
    }];
}

- (void)nvEditKeyFrameViewAddKeyFrame:(NvEditKeyFrameView *)keyFrameView val:(CGFloat)value time:(int64_t)time {
    NvKeyFrameFilterModel *model = [NvKeyFrameFilterModel new];
    model.value = value;
    model.time = self.model.trimIn + time;
    model.fxParam = @"Filter Intensity";
    model.isBuiltIn = self.currentFx.videoFxPackageId.length > 0 ? NO : YES;
    model.packageId = self.currentFx.videoFxPackageId;
    model.name = self.currentFx.bultinVideoFxName;
    model.grayscale = self.currentInfoModel.grayscale;
    model.strokeOnly = self.currentInfoModel.strokeOnly;
    [self.model.filterKeyFrames addObject:model];
    self.keyFrameView.keyFrameArr = self.model.filterKeyFrames;
    [self.currentFx setFloatValAtTime:@"Filter Intensity" val:value time:time];
    [self seekTimeline:time];
}

- (void)nvEditKeyFrameViewDeleteKeyFrame:(NvEditKeyFrameView *)keyFrameView time:(int64_t)time {
    NvKeyFrameFilterModel *deleteModel;
    for (NvKeyFrameFilterModel *model in self.model.filterKeyFrames) {
        if (model.time == time + self.model.trimIn) {
            [self.currentFx removeKeyframeAtTime:@"Filter Intensity" time:time];
            deleteModel = model;
            break;
        }
    }
    [self.model.filterKeyFrames removeObject:deleteModel];
    self.keyFrameView.keyFrameArr = self.model.filterKeyFrames;
    [self seekTimeline:time];
}

- (void)nvEditKeyFrameViewPreButtonClicked:(NvEditKeyFrameView *)keyFrameView {
    
    int64_t times = [self.currentFx findKeyframeTime:@"Filter Intensity" time:keyFrameView.timelineEditor.timelinePosition flags:NvsKeyFrameFindModeFlag_Before];

    [self refreshKeyFrameTimeline:times];
}

- (void)nvEditKeyFrameViewNextButtonClicked:(NvEditKeyFrameView *)keyFrameView {
    int64_t times = [self.currentFx findKeyframeTime:@"Filter Intensity" time:keyFrameView.timelineEditor.timelinePosition flags:NvsKeyFrameFindModeFlag_After];

    [self refreshKeyFrameTimeline:times];
}

- (void)nvEditKeyFrameViewDragTimeline:(NvEditKeyFrameView *)keyFrameView time:(int64_t)time {
    [self refreshKeyFrameTimeline:time];
}

- (void)nvEditKeyFrameViewDragTimelineEnded:(NvEditKeyFrameView *)keyFrameView time:(int64_t)time {
    int64_t preTime = [self.currentFx findKeyframeTime:@"Filter Intensity" time:keyFrameView.timelineEditor.timelinePosition flags:NvsKeyFrameFindModeFlag_Before];
    if ([keyFrameView.timelineEditor isInKeyframeView:preTime time:time]) {
        [self refreshKeyFrameTimeline:preTime];
        return;
    }
    
    int64_t nextTime = [self.currentFx findKeyframeTime:@"Filter Intensity" time:keyFrameView.timelineEditor.timelinePosition flags:NvsKeyFrameFindModeFlag_After];
    if ([keyFrameView.timelineEditor isInKeyframeView:nextTime time:time]) {
        [self refreshKeyFrameTimeline:nextTime];
        return;
    }
    
}

- (void)nvEditKeyFrameViewSliderChanged:(NvEditKeyFrameView *)keyFrameView val:(CGFloat)value time:(int64_t)time {
    dispatch_semaphore_t smp = dispatch_semaphore_create(0);
    NvKeyFrameFilterModel *targetModel;
    for (NvKeyFrameFilterModel *model in self.model.filterKeyFrames) {
        if ((model.time - self.model.trimIn) == time) {
            model.value = value;
            targetModel = model;
            break;
        }
    }
    if (!targetModel) {
        ///该时刻尚未添加关键帧，执行数据操作
        ///No keyframe is added at this time, and data operation is performed
        NvKeyFrameFilterModel *model = [NvKeyFrameFilterModel new];
        model.value = value;
        model.time = time + self.model.trimIn;
        model.fxParam = @"Filter Intensity";
        model.isBuiltIn = self.currentFx.videoFxPackageId.length > 0 ? NO : YES;
        model.packageId = self.currentFx.videoFxPackageId;
        model.name = self.currentFx.bultinVideoFxName;
        model.grayscale = self.currentInfoModel.grayscale;
        model.strokeOnly = self.currentInfoModel.strokeOnly;
        [self.model.filterKeyFrames addObject:model];
        self.keyFrameView.keyFrameArr = self.model.filterKeyFrames;
        [self.currentFx setFloatValAtTime:@"Filter Intensity" val:value time:time];
        [self seekTimeline:time];
    }else{
        [self.currentFx setFloatValAtTime:@"Filter Intensity" val:value time:time];
        [self refreshKeyFrameTimeline:time];
    }
    dispatch_semaphore_signal(smp);
    
    dispatch_semaphore_wait(smp, DISPATCH_TIME_FOREVER);
    
}

- (BOOL)hasPreKeyFrame:(int64_t)time {
    int64_t preTime = [self.currentFx findKeyframeTime:@"Filter Intensity" time:time flags:NvsKeyFrameFindModeFlag_Before];
    if (preTime>=0 && preTime<self.clipTimeline.duration) {
        return YES;
    }
    return NO;
}
 
- (BOOL)hasNextKeyFrame:(int64_t)time {
    int64_t nextTime = [self.currentFx findKeyframeTime:@"Filter Intensity" time:time flags:NvsKeyFrameFindModeFlag_After];
    if (nextTime>=0 && nextTime<self.clipTimeline.duration) {
        return YES;
    }
    return NO;
}

- (void)refreshKeyFrameTimeline:(int64_t)time {
    if (time >=0 && time <= self.clipTimeline.duration) {
        [self.clipLivewindow seekTimeline:time];
        [self seekTimeline:time];
    }
}

- (void)updateFilterKeyFrameSlider:(NvEditKeyFrameView *)keyFrameView time:(int64_t)time {
    double currentValue = [self.currentFx getFloatValAtTime:@"Filter Intensity" time:time];
    [keyFrameView updateFilterSliderStrength:currentValue];
}
#pragma mark - NvEditClipLiveWindowDelegate
- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    if ([self.title isEqualToString:NvLocalString(@"Filter", @"滤镜")]) {
        self.keyFrameView.timelineEditor.timelinePosition = position;
        self.keyFrameView.assetStatus = YES;
        if (self.keyFrameView.frame.origin.y < SCREENHEIGHT) {
            [self updateFilterKeyFrameSlider:self.keyFrameView time:position];
        }
    }
}

- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state{
    if (state != NvsStreamingEngineState_Playback) {
        if ([self.title isEqualToString:NvLocalString(@"Filter", @"滤镜")]) {
            self.keyFrameView.assetStatus = NO;
            // !!!: --  回调方法里不能修改sdk状态
//            [self seekTimeline:[self.streamingContext getTimelineCurrentPosition:self.clipTimeline]];
        }
    }
}

- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    if (timeline.duration < 1.0 * NV_TIME_BASE) {
        [self.clipLivewindow seekTimeline:0];
    }
}

#pragma mark - lazyload
- (NvEditKeyFrameView *)keyFrameView {
    if (!_keyFrameView) {
        _keyFrameView = [[NvEditKeyFrameView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 253*SCREENSCALE)];
        _keyFrameView.backgroundColor = UIColorFromRGB(0x242728);
        _keyFrameView.delegate = self;
    }
    return _keyFrameView;
}

@end
