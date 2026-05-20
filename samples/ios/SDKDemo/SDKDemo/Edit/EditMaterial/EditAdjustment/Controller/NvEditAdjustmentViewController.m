//
//  NvEditAdjustmentViewController.m
//  SDKDemo
//
//  Created by MS on 2020/12/2.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvEditAdjustmentViewController.h"
#import "NvEditAdjustmentView.h"
#import "NvsVideoClip.h"
#import "NvsVideoFx.h"
#import "NvTimelineUtils.h"
#import "SDKDemo-Swift.h"
#import <Masonry/Masonry.h>

@interface NvEditAdjustmentViewController ()<NvEditAdjustmentViewDelegate>
@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, strong) NvsVideoClip *clip;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) NvTimelineData *timelineData;
@property (nonatomic, strong) NvEditAdjustmentView *adjustmentView;
@property (nonatomic, assign) float assetRatio;
///片段旋转操作特效
///Segment rotation manipulation effects
@property (nonatomic, strong) NvsVideoFx *transVideoFx;
@property (nonatomic, strong) NvsVideoClip *videoClip;
@property (nonatomic, assign) double currentRotation;
@end

@implementation NvEditAdjustmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.assetRatio = [self getAssetRatio];
    [self addSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NvSourceInfo *sourceInfo = self.model.sourceInfo;
    BOOL keepChangedStatus = sourceInfo.mediaFilePath.length > 0 ? YES : NO;
    [self setScrollViewData:keepChangedStatus];
    
    [self.adjustmentView.liveWindowPanel setupExtraScaleX:self.model.scaleX];
    [self.adjustmentView.liveWindowPanel setupExtraScaleY:self.model.scaleY];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

- (void)setScrollViewData:(BOOL)keepChangedStatus {
    NvSourceInfo *sourceInfo = self.model.sourceInfo;
    NvCropperModel *cropperModel = self.model.cropperModel;
    if (!keepChangedStatus) {
        sourceInfo.mediaFilePath = self.model.videoPath;
        CGSize assetSize = [NvTimelineUtils getAVFileSize:self.model.videoPath];
        sourceInfo.pixelWidth = assetSize.width;
        sourceInfo.pixelHeight = assetSize.height;
        sourceInfo.trimIn = self.model.trimIn;
        sourceInfo.trimOut = self.model.trimOut;
        sourceInfo.duration = self.model.duration;
        cropperModel.cropperRatio = NvVideoEditAspectRatioModeNvVideoEditAspectRatioMode_Free;
        cropperModel.cropperAssetAspectRatio = self.assetRatio;
        cropperModel.rotation = 0;
        cropperModel.scaleX = 1;
        cropperModel.scaleY = 1;
        cropperModel.extraRotation = 0;
        cropperModel.extraScaleX = 1;
        cropperModel.extraScaleY = 1;
    }

    
    NvsSize size = [NvTimelineUtils calculateTimelineSize:self.editMode];
    NvsVideoResolution videoRes;
    videoRes.imageWidth = size.width;
    videoRes.imageHeight = size.height;
    
    self.timelineRatio = videoRes.imageWidth*1.0 / videoRes.imageHeight;
    self.adjustmentView.timelineVideoRes = videoRes;
    self.adjustmentView.timelineLivewindow = self.liveWindow;
    self.adjustmentView.sourceInfo = sourceInfo;
    
    [self.adjustmentView.liveWindowPanel setupDataWithSourceInfo:sourceInfo currentTime:0 crpperModel:cropperModel timelineVideoRes:videoRes editViewLiveWindow:self.liveWindow];
    [self.adjustmentView selectAspectRatio:cropperModel.cropperRatio];
}

- (void)addSubviews {
    if (!self.model.videoPath || self.model.videoPath.length <= 0) {
        return;
    }
    
    NvEditAdjustmentModel *model = [NvEditAdjustmentModel new];
    model.assetRatio = self.assetRatio;
    model.angle = self.model.cropperModel.rotation;
    self.adjustmentView = [[NvEditAdjustmentView alloc] initWithModel:model];
    self.adjustmentView.delegate = self;
    [self.view addSubview:self.adjustmentView];
    
    [self.adjustmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(self.view.mas_bottom);
        }
    }];
}

- (CGFloat)getAssetRatio {
    CGSize assetSize = [NvTimelineUtils getAVFileSize:self.model.videoPath];
    double assetRatio = assetSize.width / assetSize.height;
    return assetRatio;
}

- (void)initTimelineWithAssetRatio:(float)assetRatio {
    self.timeline = [NvTimelineUtils createTimelineWithAssetRatio:assetRatio];
    self.timelineData = [NvTimelineData sharedInstance];
    [NvTimelineUtils resetEditData:self.timeline editDataArray:[NSArray arrayWithObject:_model]];
    [NvTimelineUtils resetVideoFx:self.timeline videoFxDataArray:[NvTimelineUtils getClipTimelineFilter:_model timeline:self.timeline]];
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    self.videoClip = [track getClipWithIndex:0];
}

- (NvsVideoFx *)getVideoFx:(NvsVideoClip *)clip name:(NSString *)name {
    for (int i = 0; i < clip.fxCount; i++) {
        NvsVideoFx *videoFx = [clip getFxWithIndex:i];
        if ([videoFx.bultinVideoFxName isEqualToString:name])
            return videoFx;
    }
    return nil;
}

- (void)seekTimeline:(int64_t)timestamp {
    if (![[NvsStreamingContext sharedInstance] seekTimeline:self.adjustmentView.liveWindowPanel.cropperTimeline timestamp:timestamp videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame])
        NSLog(@"定位时间线失败！Failed to seek timeline!");
}

- (int64_t)getCurrentPosition {
    int64_t position = [[NvsStreamingContext sharedInstance] getTimelineCurrentPosition:self.adjustmentView.liveWindowPanel.cropperTimeline];
    return position;
}

#pragma mark - NvEditAdjustmentViewDelegate
- (void)nvEditAdjustmentView:(NvEditAdjustmentView *)view selectIndex:(NSInteger)index {
    if (index == 0) {
        if (self.model.scaleX > 0) {
            self.model.scaleX = -1;
        }else{
            self.model.scaleX = 1;
        }
        ///水平
        ///Horizontal
        [self.adjustmentView.liveWindowPanel setupExtraScaleX:self.model.scaleX];
        
        
    }else if (index == 1){
        ///垂直
        ///vertical
        if (self.model.scaleY > 0) {
            self.model.scaleY = -1;
        }else{
            self.model.scaleY = 1;
        }
        [self.adjustmentView.liveWindowPanel setupExtraScaleY:self.model.scaleY];
    }else if (index == 2){
        ///旋转
        ///rotation
        self.currentRotation += 90;
        self.model.rotation += 90;
        [self.adjustmentView.liveWindowPanel setupExtraRotation:self.model.rotation];
    }else if (index == 3){
        ///复位
        ///reset
        [self setScrollViewData:NO];
        self.model.scaleX = 1;
        self.model.scaleY = 1;
        self.model.rotation = 0;
        
        [self.adjustmentView setSliderValue:0];
        [self.adjustmentView selectAspectRatio:NvVideoEditAspectRatioModeNvVideoEditAspectRatioMode_Free];
        [self.adjustmentView.liveWindowPanel setupExtraScaleX:self.model.scaleX];
        [self.adjustmentView.liveWindowPanel setupExtraScaleY:self.model.scaleY];
        [self.adjustmentView.liveWindowPanel setupExtraRotation:self.model.rotation];
    }
    int64_t position = [self getCurrentPosition];
    [self seekTimeline:position];
}

- (void)nvEditAdjustmentView:(NvEditAdjustmentView *)view rotate:(double)rotation {

}

- (void)nvEditAdjustmentViewFinished:(NvEditAdjustmentView *)view cropperModel:(NvCropperModel *)cropperModel {
    self.model.cropperModel = cropperModel;
    self.model.sourceInfo = self.adjustmentView.sourceInfo;
    if (self.model.maskInfoModel != nil) {
        CGSize cropSize = CGSizeMake(self.model.sourceInfo.pixelWidth, self.model.sourceInfo.pixelHeight);
        NvsSize size = [NvCropperHelper calculateTimelineSizeWithEditMode:cropperModel.cropperRatio
                                         originAspectRatio:cropperModel.cropperAssetAspectRatio];
        cropSize = [self liteBoxSize:cropSize assetAspectRatio:size.width * 1.0 / size.height];
        cropperModel.cropSize = cropSize;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGSize)liteBoxSize:(CGSize)boxSize assetAspectRatio:(CGFloat)assetAspectRatio {
    CGFloat assetWidth = 0;
    CGFloat assetHeight = 0;
    CGFloat boxSizeRate = boxSize.width / boxSize.height;
    if (boxSizeRate > assetAspectRatio) {
        assetHeight = boxSize.height;
        assetWidth = assetHeight * assetAspectRatio;
    } else {
        assetWidth = boxSize.width;
        assetHeight = assetWidth / assetAspectRatio;
    }
    return CGSizeMake(assetWidth, assetHeight);
}

@end
