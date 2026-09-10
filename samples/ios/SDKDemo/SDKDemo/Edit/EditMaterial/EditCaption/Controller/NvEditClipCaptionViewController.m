//
//  NvEditClipCaptionViewController.m
//  SDKDemo
//
//  Created by ms on 2021/8/25.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvEditClipCaptionViewController.h"
#import "NvAddCaptionView.h"
#import "NvRectView.h"
#import "NvCaptionDialog.h"
#import "NvsClipCaption.h"
#import <NvSDKCommon/NvAsset.h>
#import "NvTimelineUtils.h"
#import "NvTimelineData.h"
#import "NvInfoModel.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvCaptionDialogViewController.h"
#import "NvEditClipCaptionStyleViewController.h"
#import "NvKeyFrameView.h"
#import "NvClipKeyFrameManager.h"
#import "NvCaptionCurveView.h"
#import "NVHeader.h"
#import "NvCaptionCurveItem.h"
#import "NvCustomCaptionBezierView.h"
#import "NvsControlPointPair.h"
#import "NvsStreamingContext.h"
#import "NvStreamingSdkCore.h"

@interface NvEditClipCaptionViewController ()<NvAddCaptionViewDelegate, NvRectViewDelegate, NvCaptionDialogDelegate, NvLiveWindowPanelViewDelegate, NvsStreamingContextDelegate, NvKeyFrameViewDelegate>

@property (nonatomic, strong) NvAddCaptionView *addCaptionView;
@property (nonatomic, strong) NvRectView *rectView;
@property (nonatomic, strong) NvsClipCaption *currentCaption;
///视频操作的片段对象
///A fragment object for a video operation
@property (nonatomic, strong) NvsVideoClip *videoClip;

///用于存储timeSpan对象，滑动timelineEditor的时候如果有字幕需要让对应的timeSpan选中，删除字幕的时候要让对应的timeSpan也删除
///Use to store timeSpan objects. When sliding timelineEditor, make the corresponding timeSpan selected and delete the corresponding timeSpan when deleting subtitles
@property (nonatomic, strong) NSMutableArray <NvInfoModel *>*timeSpanArray;
///字幕数据
///Subtitle data
@property (nonatomic, strong) NSMutableArray <NvCaptionInfoModel *>*captionInfoArray;
@property (nonatomic, strong) NSMutableArray <NvCaptionInfoModel *>*originCaptionInfoArray;
///当前字幕是否是被选中(用于区分是否需要弹框)
///Whether the current subtitle is selected (to distinguish whether a box is needed)
@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, assign) int64_t currentTime;
///添加曲线运动的时间
///Add the time of the curve motion
@property (nonatomic, assign) int64_t curveTime;
@property (nonatomic, assign) NSUInteger selectCaptionIndex;
///0:Normal caption, 1:Modular caption
@property (nonatomic, assign) NSUInteger selectCaptionType;
@property (nonatomic, strong) NvKeyFrameView *captionKeyframeView;
@property (nonatomic, strong) NvKeyframeInfo *currentKeyframeInfo;
@property (nonatomic, strong) NvCaptionCurveView *captionKeyCurveView;
////字幕透明度
///Subtitle transparency
@property (nonatomic, strong) UISlider *opacitySlider;
@property (nonatomic, strong) UILabel *opacityLabel;
@property (nonatomic, strong) UILabel *opacityNumLabel;
@end

@implementation NvEditClipCaptionViewController

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"currentCaption"];
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NvLocalString(@"Caption", @"字幕");
    self.timeSpanArray = [NSMutableArray array];
    [self initTimeline];
    
    [self initSubViews];
    [self.liveWindowPanel setForceHiddenControlPanel:YES];
    self.liveWindowPanel.delegate = self;
    
    [self addObserver:self forKeyPath:@"currentCaption" options:NSKeyValueObservingOptionNew context:nil];
}

- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}
- (NSMutableArray *)getClipTimelineFilter:(NvEditDataModel *)clipInfo {
    NSUInteger index = [[NvTimelineData sharedInstance].editDataArray indexOfObject:clipInfo];
    NSMutableArray *filters = [[NvTimelineData sharedInstance] videoFxDataArray];
    NSMutableArray *clipFilters = NSMutableArray.new;
    if (filters.count > index) {
        NvTimeFilterInfoModel *filterModel = filters[index];
        NvTimeFilterInfoModel *clipFilter = [filterModel copy];
        clipFilter.inPoint = 0;
        clipFilter.outPoint = self.timeline.duration;
        [clipFilters addObject:clipFilter];
    } else {
        
    }
    return clipFilters;
}
///重新创建timeline和数据结构
///Re-create the timeline and data structure
- (void)initTimeline {
    self.timeline = [NvTimelineUtils createTimeline:self.editMode];
    [NvTimelineUtils resetEditData:self.timeline editDataArray:[NSArray arrayWithObject:_model]];
    [NvTimelineUtils resetVideoFx:self.timeline videoFxDataArray:[self getClipTimelineFilter:_model]];
    
    self.videoClip = [[self.timeline getVideoTrackByIndex:0] getClipWithIndex:0];
    [NvTimelineUtils removeClipCropAndTransformFx:self.videoClip];
    
    self.captionInfoArray = [[NSMutableArray alloc] initWithArray:self.model.captionDataArray copyItems:YES];
    [NvTimelineUtils resetClipCaption:self.videoClip captionDataArray:self.captionInfoArray];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self seekTimeline:self.currentTime];
    [self.addCaptionView.timelineEditor setTimelinePosition:self.currentTime];
    [self updateCaptionView:self.currentCaption];
    [self showCaption];
    [self getCurrentPosBorder:self.currentTime];
}

#pragma mark - 恢复timelineEditor
- (void)resetTimelineEditer {
    [self.addCaptionView.timelineEditor deleteAllTimeSpan];
    ///恢复数据
    ///Recover data
    NvsClipCaption *nextCaption = [self.videoClip getFirstCaption];
    self.currentCaption = nextCaption;
    [self.timeSpanArray removeAllObjects];
    do {
        NSLog(@"=======%d,%d,%@",nextCaption.category,nextCaption.roleInTheme,nextCaption.getText);
        if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
            
        }else{
            NvsCTimelineTimeSpan *timeSpan = [self.addCaptionView.timelineEditor addTimeSpan:nextCaption.inPoint outPoint:nextCaption.outPoint];
            if (nextCaption.isModular) {
                timeSpan.timeSpanColor = [UIColor nv_colorWithHexARGB:@"#99EA4359"];
            }
            [self.addCaptionView.timelineEditor selectTimeSpan:timeSpan];
            ///存储一个infoModel对象用于使timelineEditor高亮
            ///Stores an infoModel object for highlighting the timelineEditor
            NvInfoModel *infoModel = [NvInfoModel new];
            infoModel.currentClipCaption = nextCaption;
            infoModel.infoModel =  [self getCaptionInfoModel:nextCaption];
            infoModel.timeSpan = timeSpan;
            if (nextCaption) {
                [self.timeSpanArray addObject:infoModel];
            }
        }
        nextCaption = [self.videoClip getNextCaption:nextCaption];
    } while (nextCaption);
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentCaption"]) {
        BOOL isHiden = self.currentCaption ? NO : YES;
        self.addCaptionView.styleButton.hidden = isHiden;
        self.addCaptionView.keyframeButton.hidden = isHiden;
        [self nvAddCaptionViewShowKeyFrame: isHiden];
        if (self.currentCaption.isModular) {
            self.rectView.rectLineColor = [UIColor colorWithRed:234/255.0 green:67/255.0 blue:89/255.0 alpha:1.0];
        } else {
            self.rectView.rectLineColor = [UIColor colorWithRed:74.0 / 255.0 green:144.0 / 255.0 blue:226.0 / 255.0 alpha:1.0];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/**
 获取当前字幕的NvInfoModel
 Get the NvInfoModel of the current subtitle
 
 @param currentCaption 当前字幕信息
 @return 当前字幕的NvInfoModel
 NvInfoModel of the current subtitle
 */
- (NvInfoModel *)getCurrentTimeSpan:(NvsClipCaption *)currentCaption {
    NvInfoModel *infoModel = nil;
    for (int i = 0; i < self.timeSpanArray.count; i++) {
        infoModel = self.timeSpanArray[i];
        if (infoModel.currentClipCaption == self.currentCaption) {
            return infoModel;
        }
    }
    return infoModel;
}
///重现显示字幕及选中框
///Show the subtitles and check box again
- (void)showCaption {
    if (self.currentCaption == nil) {
        self.rectView.hidden = YES;
        self.opacitySlider.hidden = YES;
        self.opacityLabel.hidden = YES;
        self.opacityNumLabel.hidden = YES;
        return;
    }
    self.rectView.hidden = NO;
    self.opacitySlider.hidden = NO;
    self.opacityLabel.hidden = NO;
    self.opacityNumLabel.hidden = NO;
    self.opacitySlider.value = [self.currentCaption getOpacity];
    [self refreshOpacityLabel];
    [self updateCaptionView:self.currentCaption];
}

- (void)refreshOpacityLabel {
    self.opacityNumLabel.text = [NSString stringWithFormat:@"%.f",self.opacitySlider.value*100];
}
///更新字幕框的位置
///Update the location of the subtitle box
- (void)updateCaptionView: (NvsClipCaption*) caption {
    if (!caption) {
        return;
    }
    [self updateCaptionViewNOSeek:caption];
    [self seekTimeline];
}

- (void)updateCaptionViewNOSeek:(NvsClipCaption*) caption {
    NSArray *array = [caption getCaptionBoundingVertices:NvsBoundingType_Frame];
    NSValue *leftTopValue = array[0];
    NSValue *leftBottomValue = array[1];
    NSValue *rightBottomValue = array[2];
    NSValue *rightTopValue = array[3];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    CGPoint rightTopCorner = [rightTopValue CGPointValue];
    
    topLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:topLeftCorner];
    rightBottomCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightBottomCorner];
    bottomLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:bottomLeftCorner];
    rightTopCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightTopCorner];

    [self.rectView setPoints:@[[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:topLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:bottomLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightBottomCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightTopCorner toView:self.rectView]]]];
    NvsBoundingType textType = NvsBoundingType_Text;
    if (caption.captionStylePackageId && caption.captionStylePackageId.length>0) {
        NSArray *textPoints = [self getPointsOfCaptionOnRectView:caption boundingType:textType];
        [self.rectView setInnerPoints:[NSMutableArray arrayWithArray:textPoints]];
    } else {
        [self.rectView setInnerPoints:nil];
    }
    if ([caption getTextAlignment] == NvsTextAlignmentLeft) {
        [self.rectView setTextAlign:NvLeft];
    } else if ([caption getTextAlignment] == NvsTextAlignmentCenter) {
        [self.rectView setTextAlign:NvCenter];
    } else if ([caption getTextAlignment] == NvsTextAlignmentRight) {
        [self.rectView setTextAlign:NvRight];
    }
}

- (CGPoint)getCenterWithArray:(NSArray*)array {
    NSValue *leftTopValue = array[0];
    NSValue *rightBottomValue = array[2];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    return CGPointMake((topLeftCorner.x+rightBottomCorner.x)/2, (topLeftCorner.y+rightBottomCorner.y)/2);
}

- (NSArray <NSValue *>*)getPointsOfCaptionOnRectView:(NvsClipCaption*)caption boundingType:(NvsBoundingType)boundingType {
    NSArray *array = [caption getCaptionBoundingVertices:boundingType];
    NSValue *leftTopValue = array[0];
    NSValue *leftBottomValue = array[1];
    NSValue *rightBottomValue = array[2];
    NSValue *rightTopValue = array[3];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    CGPoint rightTopCorner = [rightTopValue CGPointValue];
    
    topLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:topLeftCorner];
    rightBottomCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightBottomCorner];
    bottomLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:bottomLeftCorner];
    rightTopCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightTopCorner];
    return @[[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:topLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:bottomLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightBottomCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightTopCorner toView:self.rectView]]];
}
#pragma mark - 关键帧编辑 Keyframe editing
- (void)nvAddCaptionViewShowKeyFrame:(BOOL)isHiden {
    if (self.captionKeyframeView != nil) {
        self.addCaptionView.keyframeButton.hidden = YES;
        self.addCaptionView.styleButton.hidden = YES;
    }
    if (isHiden && self.captionKeyframeView) {
        self.captionKeyframeView.enablePrebutton  = NO;
        self.captionKeyframeView.enableNextbutton = NO;
        self.captionKeyframeView.enableAddbutton  = NO;
        return;
    }
    if (self.captionKeyframeView != nil) {
        [self nvUpdateKeyframeStatus];
    }else {
        NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
        BOOL hasKeyFrame = [NvClipKeyFrameManager isExistKeyFrame:captionInfo.keyArray timelineVideoFx:self.currentCaption];
        [self.addCaptionView setKeyframeState:hasKeyFrame];
        if (!hasKeyFrame) {
            [self showCaption];
            [self getCurrentPosBorder:self.currentTime];
        }
    }
}


-(void)setSlideStatus{
    int64_t timePos = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    CGFloat value = [self.currentCaption getFloatValAtTime:@"Track Opacity" time:timePos] ;
    self.opacitySlider.value = value;
    [self refreshOpacityLabel];
}


#pragma mark - 界面刷新 Interface refresh
- (void)nvUpdateKeyframeStatus {
    int64_t timelinePos = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
    __block NvKeyframeInfo *keyframeModel = nil;
    [NvClipKeyFrameManager fetchKeyframeStatus:timelinePos inPoint:captionInfo.inPoint frameKeys:captionInfo.keyArray keyframeSource:captionInfo.keyFramesArray timelineVideoFx:self.currentCaption completeHandler:^(BOOL previous, BOOL next, NvKeyframeInfo * _Nullable keyModel, int index) {
        if (previous || next || keyModel) {
            [self.addCaptionView setKeyframeState:YES];
        }else {
            [self.addCaptionView setKeyframeState:NO];
            [self.currentCaption setCurrentKeyFrameTime:-1];
        }

        if (self.captionKeyframeView ) {
            [self.addCaptionView setKeyframeAddCurve];
            self.addCaptionView.keyframeButton.enabled = NO;
            self.addCaptionView.keyframeButton.alpha = 0.5;
            if (keyModel) {
                
            }else if(previous && next){
                self.addCaptionView.keyframeButton.enabled = YES;
                self.addCaptionView.keyframeButton.alpha = 1;
                self.curveTime = [self.streamingContext getTimelineCurrentPosition:self.timeline];
            }
        }
        
        self.captionKeyframeView.enablePrebutton  = previous;
        self.captionKeyframeView.enableNextbutton = next;
        self.captionKeyframeView.enableAddbutton  = YES;
        [self.captionKeyframeView resetOptKeyFrameButton: (keyModel== nil ? NO : YES)];
        if (keyModel != nil) {
            [self.addCaptionView.timelineEditor setTimelinePosition:keyModel.time];
            [self seekTimeline:keyModel.time];
            [self.addCaptionView.timelineEditor configSelectKeyFrames:index];
        }
        keyframeModel = keyModel;
    }];
    self.currentKeyframeInfo = keyframeModel;
    [self.addCaptionView.timelineEditor configKeyFrames:[self numberArray:captionInfo.keyFramesArray] withSpanInPoint:captionInfo.inPoint withOutPoint:captionInfo.outPoint];
    if (self.currentKeyframeInfo) {
        [self getCurrentPosBorder:self.currentKeyframeInfo.time];
    }else {
        [self getCurrentPosBorder:timelinePos];
    }
    
    [self setSlideStatus];

}

-(void)sliderValueEnd:(UISlider *)slider{
    [self refreshOpacityLabel];
}


- (void)hiddenORShowAddCaptionViewOnCurrentTime {
    int64_t currentTime = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    [self hiddenORShowAddCaptionView:currentTime];
}

- (void)hiddenORShowAddCaptionView:(int64_t)timeStamp {
    NvsClipCaption *captemp = [[self.videoClip getCaptionsByClipTimePosition:timeStamp] lastObject];
    if (captemp.category == NvsThemeCategory && captemp.roleInTheme != NvsRoleInThemeGeneral) {
        self.addCaptionView.styleButton.hidden = YES;
    }else{
        self.addCaptionView.styleButton.hidden = !captemp;
    }
    
    self.addCaptionView.keyframeButton.hidden = !captemp;
    if (self.captionKeyframeView != nil) {
        self.addCaptionView.styleButton.hidden = YES;
        self.addCaptionView.keyframeButton.hidden = YES;
    }
    
    if (!self.addCaptionView.keyframeButton.hidden) {
        BOOL hasKeyFrame = NO;
        if (self.currentCaption) {
            NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
            hasKeyFrame = [NvClipKeyFrameManager isExistKeyFrame:captionInfo.keyArray timelineVideoFx:self.currentCaption];
        }
        [self.addCaptionView setKeyframeState:hasKeyFrame];
    }
}

#pragma mark - NvKeyFrameViewDelegate
- (void)nvKeyFrameView:(NvKeyFrameView *)view didReceive:(KeyFrameRespone)response {
    __block CGFloat timeKeyPos = 0.0;
    if (response == KeyFrame_Previous) {
        ///上一帧
        ///Previous frame
        int64_t timePos = [self.streamingContext getTimelineCurrentPosition:self.timeline];
        NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
        __block NvKeyframeInfo *keyframeModel = nil;
        [NvClipKeyFrameManager getPreKeyFrame:captionInfo.keyArray timelinePos:timePos inPoint:captionInfo.inPoint keyframeSource:captionInfo.keyFramesArray timelineVideoFx:self.currentCaption completeHandler:^(NvKeyframeInfo * _Nonnull keyModel, int index, BOOL previous) {
            keyframeModel = keyModel;
            [self.addCaptionView.timelineEditor setTimelinePosition:keyModel.time];
            [self.addCaptionView.timelineEditor configSelectKeyFrames:index];
            [self seekTimeline:keyModel.time];
            [self.captionKeyframeView resetOptKeyFrameButton:YES];
            self.captionKeyframeView.enableNextbutton = YES;
            if (!previous && self.captionKeyframeView) {
                self.captionKeyframeView.enablePrebutton = NO;
            }
            timeKeyPos = keyModel.pos;
        }];
        self.currentKeyframeInfo = keyframeModel;
        [self getCurrentPosBorder:keyframeModel.time];
    }else if (response == KeyFrame_Next) {
        ///下一帧
        ///Next frame
        int64_t timePos = [self.streamingContext getTimelineCurrentPosition:self.timeline];
        NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
        __block NvKeyframeInfo *keyframeModel = nil;
        [NvClipKeyFrameManager getNextKeyFrame:captionInfo.keyArray timelinePos:timePos inPoint:captionInfo.inPoint keyframeSource:captionInfo.keyFramesArray timelineVideoFx:self.currentCaption completeHandler:^(NvKeyframeInfo * _Nonnull keyModel, int index, BOOL next) {
            keyframeModel = keyModel;
            [self.addCaptionView.timelineEditor setTimelinePosition:keyModel.time];
            [self.addCaptionView.timelineEditor configSelectKeyFrames:index];
            [self seekTimeline:keyModel.time];
            [self.captionKeyframeView resetOptKeyFrameButton:YES];
            self.captionKeyframeView.enablePrebutton = YES;
            if (!next && self.captionKeyframeView) {
                self.captionKeyframeView.enableNextbutton = NO;
            }
            timeKeyPos = keyModel.pos;
        }];
        self.currentKeyframeInfo = keyframeModel;
        [self getCurrentPosBorder:keyframeModel.time];
    }else if (response == KeyFrame_Add) {
        ///添加关键帧
        ///Add keyframe
        int64_t timePos = [self.streamingContext getTimelineCurrentPosition:self.timeline];
        NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
        __block NvKeyframeInfo *keyframeInfo = nil;
        [NvClipKeyFrameManager insertKeyframe:timePos inPoint:captionInfo.inPoint keyframeSource:captionInfo.keyFramesArray timelineVideoFx:self.currentCaption fxType:NvClipKeyframe_Caption completeHandler:^(NvKeyframeInfo * _Nonnull keyModel, int index) {
            keyframeInfo = keyModel;
            /// 记录当前字幕的位置、旋转、缩放
            /// Record the current subtitle position, rotation, and scaling
            if (keyframeInfo.translation.x == 0 && keyframeInfo.translation.y == 0) {
                if (keyframeInfo.rotation == 0 && keyframeInfo.scale == 1) {
                    keyframeInfo.rotation    = [self.currentCaption getRotationZ];
                    keyframeInfo.scale       = [self.currentCaption getScaleX];
                    keyframeInfo.translation = [self.currentCaption getCaptionTranslation];
                    keyframeInfo.opacity = [self.currentCaption getFloatValAtTime:@"Track Opacity" time:keyframeInfo.pos];
                    [self.currentCaption setScaleX:keyframeInfo.scale];
                    [self.currentCaption setScaleY:keyframeInfo.scale];
                    [self.currentCaption setRotationZ:keyframeInfo.rotation];
                    [self.currentCaption setCaptionTranslation:keyframeInfo.translation];
                    [self.currentCaption setFloatValAtTime:@"Track Opacity" val:keyframeInfo.opacity time:keyframeInfo.pos];

                }
            }
            [self.addCaptionView.timelineEditor configKeyFrames:[self numberArray:captionInfo.keyFramesArray] withSpanInPoint:captionInfo.inPoint withOutPoint:captionInfo.outPoint];
            [self.addCaptionView.timelineEditor configSelectKeyFrames:index];
            [self.captionKeyframeView resetOptKeyFrameButton:YES];
            [self removeKeyframeControlPoint];
            timeKeyPos = keyModel.pos;
        }];
        
        self.currentKeyframeInfo = keyframeInfo;
        [self getCurrentPosBorder:keyframeInfo.time];
    }else if (response == KeyFrame_Delete) {
        ///删除关键帧
        ///Delete key frame
        __weak typeof(self)weakSelf = self;
        NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
        [NvClipKeyFrameManager removeKeyFrame:captionInfo.keyArray keyframeSource:captionInfo.keyFramesArray keyframeTarget:self.currentKeyframeInfo timelineVideoFx:self.currentCaption completeHandler:^{
            [weakSelf.addCaptionView.timelineEditor configKeyFrames:[weakSelf numberArray: captionInfo.keyFramesArray] withSpanInPoint:captionInfo.inPoint withOutPoint:captionInfo.outPoint];
            /// 设置中间按钮
            /// Set the middle button
            BOOL previous = [NvClipKeyFrameManager isExistPreKeyFrame:weakSelf.currentKeyframeInfo.pos frameKeys:captionInfo.keyArray timelineVideoFx:weakSelf.currentCaption];
            BOOL next     = [NvClipKeyFrameManager isExistNextKeyFrame:weakSelf.currentKeyframeInfo.pos frameKeys:captionInfo.keyArray timelineVideoFx:weakSelf.currentCaption];
            [weakSelf.captionKeyframeView resetOptKeyFrameButton:NO];
            weakSelf.captionKeyframeView.enablePrebutton = previous;
            weakSelf.captionKeyframeView.enableNextbutton = next;
            /// 重置数据
            /// Reset data
            if (captionInfo.keyFramesArray.count == 0) {
                ///关键帧模式下点击竖版按钮，删除时强制性置为NO
                ///Click the vertical button in keyframe mode, and set to NO when deleting
                if (captionInfo.isVerticalKeyFrame) {
                    captionInfo.isVerticalKeyFrame = NO;
                    captionInfo.isVerticalLayout = NO;
                    [weakSelf.currentCaption setVerticalLayout:NO];
                }
                captionInfo.translation = CGPointZero;
                captionInfo.rotation = 0;
                captionInfo.scale = 1;
                captionInfo.opacity = 1;
                [weakSelf showCaption];
            }else {
                [self getCurrentPosBorder:self.currentKeyframeInfo.pos + captionInfo.inPoint];
            }
        }];
        [self removeKeyframeControlPoint];
        self.currentKeyframeInfo = nil;
        timeKeyPos = self.currentKeyframeInfo.pos;
    }
    CGFloat value = [self.currentCaption getFloatValAtTime:@"Track Opacity" time:timeKeyPos] ;
    self.opacitySlider.value = value;
    [self refreshOpacityLabel];

}

- (void)nvDragHandleEnded:(int64_t)timePos isInPoint:(BOOL)flags {
    NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
    if (flags) {
        /// 移除关键帧
        /// Remove keyframe
        captionInfo.inPoint = timePos;
        [captionInfo.keyArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.currentCaption removeAllKeyframe:obj];
        }];
        NSMutableArray<NvKeyframeInfo *> *tempArray = @[].mutableCopy;
        for (int i = 0; i < captionInfo.keyFramesArray.count; i++) {
            NvKeyframeInfo *keyframe = captionInfo.keyFramesArray[i];
            if (timePos >= keyframe.time) {
                [tempArray addObject:keyframe];
            }else {
                keyframe.pos = keyframe.time - timePos;
                [self.currentCaption setCurrentKeyFrameTime:keyframe.pos];
                [self.currentCaption setScaleX:keyframe.scale];
                [self.currentCaption setScaleY:keyframe.scale];
                [self.currentCaption setRotationZ:keyframe.rotation];
                [self.currentCaption setCaptionTranslation:keyframe.translation];
            }
        }
        for (NvKeyframeInfo *obj in tempArray) {
            [captionInfo.keyFramesArray removeObject:obj];
        }
        [self showCaption];
        [self nvUpdateKeyframeStatus];
    }else {
        __block NSMutableArray<NvKeyframeInfo *> *tempArray = @[].mutableCopy;
        [captionInfo.keyFramesArray enumerateObjectsUsingBlock:^(NvKeyframeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (timePos <= obj.time) {
                [tempArray addObject:obj];
            }
        }];
        [tempArray enumerateObjectsUsingBlock:^(NvKeyframeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            for (NSString *str in captionInfo.keyArray) {
                [self.currentCaption removeKeyframeAtTime:str time:obj.pos];
            }
            [captionInfo.keyFramesArray removeObject:obj];
        }];
        [self.currentCaption setCurrentKeyFrameTime:-1];
        [self showCaption];
        [self nvUpdateKeyframeStatus];
    }
}

- (void)nvKeyFrameViewDidFinished:(NvKeyFrameView *)view {
    NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
    [self.addCaptionView.timelineEditor configKeyFrames:@[].mutableCopy withSpanInPoint:captionInfo.inPoint withOutPoint:captionInfo.outPoint];
    self.captionKeyframeView.delegate = nil;
    [self.captionKeyframeView nv_fadeOut];
    self.captionKeyframeView = nil;
    self.addCaptionView.styleButton.hidden = NO;
    self.addCaptionView.keyframeButton.hidden = NO;
    ///从关键帧界面出来应刷新关键帧状态
    ///The key frame status should be refreshed after the key frame interface is displayed
    [self nvUpdateKeyframeStatus];
  
    [self.addCaptionView.timelineEditor removeAllKeyFrameImageViews];
    
    BOOL hasKeyFrame = [NvClipKeyFrameManager isExistKeyFrame:captionInfo.keyArray timelineVideoFx:self.currentCaption];
    self.opacitySlider.hidden = hasKeyFrame;
    self.opacityLabel.hidden = hasKeyFrame;
    self.opacityNumLabel.hidden = hasKeyFrame;

    ///注：退出关键帧模式需要将当前关键帧时间设为-1
    ///Note: To exit keyframe mode, you need to set the current keyframe time to -1
    [self.currentCaption setCurrentKeyFrameTime:-1];
}

- (void)nvCaptionCurveViewDidFinished:(NvCaptionCurveView *)view{
    [self.captionKeyCurveView removeFromSuperview];
    self.captionKeyCurveView = nil;
}
///字幕曲线点击item
///Subtitles Curve Click item
- (void)nvCaptionCurveViewDidSelectModel:(NvCaptionCurveItem *)item{
    if (item.type == CurveAnimationTypeCustom) {
        NvCustomCaptionBezierView *view = [[NvCustomCaptionBezierView alloc] init];
        view.delegate = self;
        view.frame = self.captionKeyCurveView.frame = CGRectMake(0, self.view.viewHeight - 240 * SCREENSCALE - INDICATOR, kScreenWidth, 260 * SCREENSCALE + INDICATOR);
        [self.view addSubview:view];
        /*
         给曲线视图的控制点设置初始位置
         Sets the initial position of the control point for the curve view
         */
        int64_t timePos = self.curveTime;
        NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
        __block NvKeyframeInfo *preKeyframeModel = nil;
        [NvClipKeyFrameManager getPreKeyFrame:captionInfo.keyArray timelinePos:timePos inPoint:captionInfo.inPoint keyframeSource:captionInfo.keyFramesArray timelineVideoFx:self.currentCaption completeHandler:^(NvKeyframeInfo * _Nonnull keyModel, int index, BOOL previous) {
            preKeyframeModel = keyModel;
        }];
        preKeyframeModel.type = CurveAnimationTypeCustom;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [view setupSelectedDefault:preKeyframeModel.leftPoint with:preKeyframeModel.rightPoint];
        });
    }else{
        CGPoint leftControlP = CGPointMake(0, 0);
        CGPoint rightControlP = CGPointMake(0, 0);
        if (item.type == CurveAnimationType1) {
            leftControlP = CGPointMake(0.333333, 0.333333);
            rightControlP = CGPointMake(0.666667, 0.666667);
        }else if (item.type == CurveAnimationType2){
            leftControlP = CGPointMake(0.5, 0);
            rightControlP = CGPointMake(1.0, 0.5);
        }else if (item.type == CurveAnimationType3){
            leftControlP = CGPointMake(0, 0.75);
            rightControlP = CGPointMake(0.25, 1.0);
        }else if (item.type == CurveAnimationType4){
            leftControlP = CGPointMake(1, 0);
            rightControlP = CGPointMake(0, 1);
        }else if (item.type == CurveAnimationType5){
            leftControlP = CGPointMake(0.0, 1.0);
            rightControlP = CGPointMake(1.0, 0.0);
        }else if (item.type == CurveAnimationType6){
            leftControlP = CGPointMake(0.5, 0);
            rightControlP = CGPointMake(0.5, 1);
        }else if (item.type == CurveAnimationType7){
            leftControlP = CGPointMake(0.75, 0.0);
            rightControlP = CGPointMake(1.0, 0.0);
        }
        
        int64_t timePos = self.curveTime;
        NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
        __block NvKeyframeInfo *preKeyframeModel = nil;
        [NvClipKeyFrameManager getPreKeyFrame:captionInfo.keyArray timelinePos:timePos inPoint:captionInfo.inPoint keyframeSource:captionInfo.keyFramesArray timelineVideoFx:self.currentCaption completeHandler:^(NvKeyframeInfo * _Nonnull keyModel, int index, BOOL previous) {
            preKeyframeModel = keyModel;
        }];
        __block NvKeyframeInfo *nextKeyframeModel = nil;
        [NvClipKeyFrameManager getNextKeyFrame:captionInfo.keyArray timelinePos:timePos inPoint:captionInfo.inPoint keyframeSource:captionInfo.keyFramesArray timelineVideoFx:self.currentCaption completeHandler:^(NvKeyframeInfo * _Nonnull keyModel, int index, BOOL next) {
            nextKeyframeModel = keyModel;
        }];
        
        preKeyframeModel.type = item.type;
        
        [self setCurveAnimationWithLeftKeyframe:preKeyframeModel RightKeyframe:nextKeyframeModel LeftPoint:leftControlP RightPoint:rightControlP];
    }
}

-(void)dragEndStartTime:(int64_t)startTime withEndTime:(int64_t)endTime{
    [NvTimelineUtils playbackTimeline:self.timeline startTime:startTime endTime:endTime flags:NvsStreamingEnginePlaybackFlag_LowPipelineSize|NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}

-(void)setCurveAnimationWithLeftKeyframe:(NvKeyframeInfo *)leftKeyframe RightKeyframe:(NvKeyframeInfo *)rightKeyframe LeftPoint:(CGPoint)leftPoint RightPoint:(CGPoint)rightPoint {
    
    [NvClipKeyFrameManager insertKeyframeControlPoint:leftKeyframe RightKeyframe:rightKeyframe LeftPoint:leftPoint RightPoint:rightPoint timelineVideoFx:self.currentCaption captionAttributeType:NvClipCaptionAttribute_Trans];
    [NvClipKeyFrameManager insertKeyframeControlPoint:leftKeyframe RightKeyframe:rightKeyframe LeftPoint:leftPoint RightPoint:rightPoint timelineVideoFx:self.currentCaption captionAttributeType:NvClipCaptionAttribute_Opacity];

    
    [self dragEndStartTime:leftKeyframe.time withEndTime:rightKeyframe.time];
}

- (void)removeKeyframeControlPoint{
    int64_t timePos = self.curveTime;
    NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
    __block NvKeyframeInfo *preKeyframeModel = nil;
    [NvClipKeyFrameManager getPreKeyFrame:captionInfo.keyArray timelinePos:timePos inPoint:captionInfo.inPoint keyframeSource:captionInfo.keyFramesArray timelineVideoFx:self.currentCaption completeHandler:^(NvKeyframeInfo * _Nonnull keyModel, int index, BOOL previous) {
        preKeyframeModel = keyModel;
    }];
    
    __block NvKeyframeInfo *nextKeyframeModel = nil;
    [NvClipKeyFrameManager getNextKeyFrame:captionInfo.keyArray timelinePos:timePos inPoint:captionInfo.inPoint keyframeSource:captionInfo.keyFramesArray timelineVideoFx:self.currentCaption completeHandler:^(NvKeyframeInfo * _Nonnull keyModel, int index, BOOL next) {
        nextKeyframeModel = keyModel;
    }];
    
    [NvClipKeyFrameManager removeKeyFrame:preKeyframeModel withIsForward:YES timelineVideoFx:self.currentCaption];
    [NvClipKeyFrameManager removeKeyFrame:nextKeyframeModel withIsForward:NO timelineVideoFx:self.currentCaption];
    
    [self nvUpdateKeyframeStatus];
}

- (void)nvAddCaptionViewdidAddKeyFrameClick {
    /// 关键帧编辑窗口
    /// Keyframe editing window
    self.captionKeyframeView = [[NvKeyFrameView alloc] init];
    self.captionKeyframeView.delegate = self;
    [self.captionKeyframeView nv_fadeIn:self.view];
    self.addCaptionView.keyframeButton.hidden = YES;
    self.addCaptionView.styleButton.hidden = YES;
    
    /// 查询关键帧状态
    /// Example Query the key frame status
    [self nvUpdateKeyframeStatus];
}


- (void)nvAddCaptionCurveAdjustmentClick{
    self.captionKeyCurveView = [[NvCaptionCurveView alloc] init];
    self.captionKeyCurveView.delegate = self;
    self.captionKeyCurveView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    self.captionKeyCurveView.frame = CGRectMake(0, self.view.viewHeight - 260 * SCREENSCALE - INDICATOR, kScreenWidth, 260 * SCREENSCALE + INDICATOR);
    int64_t timePos = self.curveTime;
    NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
    __block NvKeyframeInfo *preKeyframeModel = nil;
    [NvClipKeyFrameManager getPreKeyFrame:captionInfo.keyArray timelinePos:timePos inPoint:captionInfo.inPoint keyframeSource:captionInfo.keyFramesArray timelineVideoFx:self.currentCaption completeHandler:^(NvKeyframeInfo * _Nonnull keyModel, int index, BOOL previous) {
        preKeyframeModel = keyModel;
    }];
    [self.captionKeyCurveView setupSelectedDefault:preKeyframeModel.type];
    [self.view addSubview:self.captionKeyCurveView];
}

- (void)NvCustomCaptionBezierViewDidFinishedWithControlLeft:(CGPoint)controlLeft ControlRight:(CGPoint)controlRighty{

    int64_t timePos = self.curveTime;
    NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
    __block NvKeyframeInfo *preKeyframeModel = nil;
    [NvClipKeyFrameManager getPreKeyFrame:captionInfo.keyArray timelinePos:timePos inPoint:captionInfo.inPoint keyframeSource:captionInfo.keyFramesArray timelineVideoFx:self.currentCaption completeHandler:^(NvKeyframeInfo * _Nonnull keyModel, int index, BOOL previous) {
        preKeyframeModel = keyModel;
    }];
    __block NvKeyframeInfo *nextKeyframeModel = nil;
    [NvClipKeyFrameManager getNextKeyFrame:captionInfo.keyArray timelinePos:timePos inPoint:captionInfo.inPoint keyframeSource:captionInfo.keyFramesArray timelineVideoFx:self.currentCaption completeHandler:^(NvKeyframeInfo * _Nonnull keyModel, int index, BOOL next) {
        nextKeyframeModel = keyModel;
    }];
    [self setCurveAnimationWithLeftKeyframe:preKeyframeModel RightKeyframe:nextKeyframeModel LeftPoint:controlLeft RightPoint:controlRighty];
    
    preKeyframeModel.leftPoint = controlLeft;
    preKeyframeModel.rightPoint = controlRighty;
}


- (NSMutableArray *)numberArray:(NSMutableArray *)array{
    NSMutableArray *timeArr = [NSMutableArray array];
    for (NvKeyframeInfo *model in array) {
        NSNumber *num = [NSNumber numberWithLongLong:model.time];
        [timeArr addObject:num];
    }
    return timeArr;
}

- (void)getCurrentPosBorder:(int64_t)pos{
    NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
    if (self.captionKeyframeView != nil) {
        if (self.currentKeyframeInfo == nil) {
            [self.currentCaption setCurrentKeyFrameTime:pos - captionInfo.inPoint];
            [self showCaption];
            [captionInfo.keyArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.currentCaption removeKeyframeAtTime:obj time:pos - captionInfo.inPoint];
            }];
        }else {
            [self.currentCaption setCurrentKeyFrameTime:pos - captionInfo.inPoint];
            [self showCaption];
            
        }
    }else {
        ///判断此时间点是否有关键帧
        ///Determines whether there are keyframes at this point in time
        ///有关键帧的话，获取当前贴纸位置画框
        ///If there is a keyframe, get the current sticker position frame
        ///无关键帧（考虑贴纸处于运动中），通过添加关键帧获取位置画框，然后将新加关键帧删除
        ///No keyframe (considering the sticker is in motion), get the position frame by adding the keyframe, and then delete the new keyframe
        BOOL hasKeyFrame = NO;
        for (NvKeyframeInfo *model in captionInfo.keyFramesArray) {
            if (model.time == pos) {
                hasKeyFrame = YES;
                break;
            }
        }
        if (hasKeyFrame) {
            if (pos - captionInfo.inPoint == 0) {
                [self.currentCaption setCurrentKeyFrameTime:pos - captionInfo.inPoint];
            }
            [self showCaption];
            
        }else if (captionInfo.keyFramesArray.count > 0){
            [self.currentCaption setCurrentKeyFrameTime:pos - captionInfo.inPoint];
            [self showCaption];
            for (NSString *string in captionInfo.keyArray) {
                [self.currentCaption removeKeyframeAtTime:string time:pos-captionInfo.inPoint];
            }
        } else {
            [self showCaption];
        }
    }
}

///获取字幕位置
///Get subtitle location
- (NSArray *)getBoundingVerticesForCaption:(NvsClipCaption *)caption {
    /*获取字幕位置
     *1.如果字幕没有关键帧，直接获取字幕位置
     *2.如果字幕含有关键帧，为该字幕设置当前时间，然后获取字幕位置
        1.如果当前时刻没有关键帧，则设置完当前关键帧时间后记得删除
        2.如果有关键帧则不必删除
     
     * Get the title location
     *1. If the subtitle has no keyframe, obtain the subtitle position directly
     *2. If the subtitle contains keyframes, set the current time for the subtitle and then get the subtitle location
     1. If there is no keyframe at the current time, delete it after setting the keyframe time
     2. If keyframes exist, do not delete them
     */
    NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:caption];
    BOOL hasKeyFrame = [NvClipKeyFrameManager isExistKeyFrame:captionInfo.keyArray timelineVideoFx:caption];
    if (!hasKeyFrame) {
        NSArray *array = [caption getCaptionBoundingVertices:NvsBoundingType_Frame];
        return array;
    }
    int64_t currentTimeStamp = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    BOOL isExistNow = [NvClipKeyFrameManager isExistKeyFrame:captionInfo.keyFramesArray timelinePos:currentTimeStamp];
    [caption setCurrentKeyFrameTime:currentTimeStamp - captionInfo.inPoint];
    
    NSArray *array = [caption getCaptionBoundingVertices:NvsBoundingType_Frame];
    if (!isExistNow) {
        [captionInfo.keyArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [caption removeKeyframeAtTime:obj time:currentTimeStamp];
        }];
    }
    return array;
}

///检查当前时刻是否包含正在编辑的字幕
///Check whether the current moment contains the subtitles you are editing
- (BOOL)isContainCurrentCaptionInCurrentTimestamp {
    NSArray *captionArray = [self.videoClip getCaptionsByClipTimePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
    if ([captionArray containsObject:self.currentCaption]) {
        return YES;
    }
    return NO;
}

#pragma mark - 点击添加字幕 Click Add Subtitles
- (void)nvAddCaptionViewdidAddCaptionClick:(int)index {
    [self.streamingContext stop];
    self.selectCaptionType = index;
    ///距离末尾小于1秒时不加字幕
    ///No subtitles are added when the distance is less than 1 second from the end
    if (self.timeline.duration-[self.streamingContext getTimelineCurrentPosition:self.timeline] < 1000000) {
        [NvToast showInfoWithMessage:NvLocalString(@"Add caption restrictions", @"距离末尾小于1秒时不加字幕")];
        return;
    }
    NvCaptionDialogViewController *dialogVC = [NvCaptionDialogViewController new];
    dialogVC.delegate = self;
    [dialogVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];

    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.providesPresentationContextTransitionStyle = YES;
    self.definesPresentationContext = YES;
    [self presentViewController:dialogVC animated:YES completion:NULL];
}
#pragma mark - 点击样式 Click style
- (void)nvAddCaptionViewdidAddStyleClick {
    [self.streamingContext stop];
    self.currentTime = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    self.isSelect = YES;
    NvEditClipCaptionStyleViewController *styleVC = [NvEditClipCaptionStyleViewController new];
    if (self.currentCaption.isModular) {
        styleVC.captionType = Modular;
    } else {
        styleVC.captionType = Normal;
    }
    styleVC.timeline = self.timeline;
    styleVC.editMode = self.editMode;
    styleVC.delegate = self;
    styleVC.currentCaption = self.currentCaption;
    styleVC.captionInfo = [self getCaptionInfoModel:self.currentCaption];
    styleVC.captionInfos = self.captionInfoArray;
    __weak typeof(self) weakSelf = self;
    styleVC.popResetPos = ^(int64_t time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.currentTime = time;
        NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
        /// 切换字幕样式，重置关键帧
        /// Toggle subtitles style, reset keyframe
        if (captionInfo.keyFramesArray.count > 0) {
            /// 重置关键帧
            /// Reset keyframe
            [NvClipKeyFrameManager resetKeyFrame:captionInfo.keyArray keyframeSource:captionInfo.keyFramesArray fxType:NvClipKeyframe_Caption timelineVideoFx:strongSelf.currentCaption];
            [NvClipKeyFrameManager resetControlPointkeyframeSource:captionInfo.keyFramesArray fxType:NvClipKeyframe_CaptionControlPoint timelineVideoFx:strongSelf.currentCaption];
        }
    };
    [self.navigationController pushViewController:styleVC animated:YES];
}

- (NvRectView *)getRectView {
    return self.rectView;
}

#pragma mark 样式点击删除 Style hit delete
- (void)editCaptionStyleViewController:(NvEditClipCaptionStyleViewController *)editCaptionStyleViewController closeCaption:(NvsClipCaption *)caption {
    [self rectView:self.rectView close:nil];
}

#pragma mark -  添加/修改字幕文字 Add/modify subtitle text
- (void)captionDialog:(NvCaptionDialogViewController *)captionDialog clickButtonIndex:(NSInteger)index {
    ///添加字幕页面修改字幕
    ///Add subtitles page to modify subtitles
    if (captionDialog.isChangedText) {
        if (index == 0) {
            NSString* text = [captionDialog getCaptionText];
            NvCaptionInfoModel *model = [self getCaptionInfoModel:self.currentCaption];
            model.text = text;
            [self.currentCaption setText:text];
            [self updateCaptionView:self.currentCaption];
        } else {

        }
        
        [captionDialog dismissViewControllerAnimated:NO completion:NULL];
        return;
    }
    
    ///添加字幕
    ///Add subtitles
    if (index == 0) {
        ///确定
        ///determine
        NSString* text = [captionDialog getCaptionText];
        if(text.length == 0) {
            [NvToast showInfoWithMessage:NvLocalString(@"Subtitle is empty", @"您输入的字幕为空，请重新输入")];
        } else {
            ///添加字幕
            ///Add subtitles
            int64_t inPoint = [[NvsStreamingContext sharedInstance] getTimelineCurrentPosition:self.timeline];
            int64_t duration = 5000000;
            if (inPoint + duration > self.timeline.duration) {
                duration = self.timeline.duration - inPoint;
            }
           
            NvCaptionInfoModel *captionModel = [NvCaptionInfoModel new];
            NvsClipCaption* caption;
            if (self.selectCaptionType == 0) {
                caption = [self.videoClip addCaption:text inPoint:inPoint duration: duration captionStylePackageId:nil];
                
                captionModel.type = Normal;
            } else {
                caption = [self.videoClip addModularCaption:text inPoint:inPoint duration: duration];
                captionModel.type = Modular;
            }
            [caption setAbsoluteTimeUsed:true];
            self.currentCaption = caption;
            
            [caption setAttachment:captionModel forKey:@"captionInfoModel"];
            captionModel.category = caption.category;
            captionModel.text = text;
            captionModel.inPoint = inPoint;
            captionModel.outPoint = inPoint + duration;
            [self.captionInfoArray addObject:captionModel];
            [self showCaption];
            int64_t inpoint = [self.streamingContext getTimelineCurrentPosition:self.timeline];
            NvsCTimelineTimeSpan *timeSpan = [self.addCaptionView.timelineEditor addTimeSpan:inpoint outPoint:inpoint+duration];
            if (caption.isModular) {
                timeSpan.timeSpanColor = [UIColor nv_colorWithHexARGB:@"#99EA4359"];
            }
            ///选中某一个timeSpan
            ///Select a timeSpan
            [self.addCaptionView.timelineEditor selectTimeSpan:timeSpan];
            ///存储一个infoModel对象用于使timelineEditor高亮
            ///Stores an infoModel object for highlighting the timelineEditor
            NvInfoModel *infoModel = [NvInfoModel new];
            infoModel.currentClipCaption = self.currentCaption;
            infoModel.infoModel = captionModel;
            infoModel.timeSpan = timeSpan;
            if (self.currentCaption) {
                [self.timeSpanArray addObject:infoModel];
            }
            
        }
    } else {
        ///取消
        ///Cancel
    }
    [captionDialog dismissViewControllerAnimated:NO completion:NULL];
}

#pragma mark - NvRectViewDelegate
- (void)rectView:(NvRectView*)rectView close:(UIButton*)close {
    ///获取数据删除timelineEditor框
    ///Get data to delete the timelineEditor box
    if (self.captionKeyframeView != nil) {
        [NvToast showInfoWithMessage:NvLocalString(@"Captions cannot be deleted in key frame mode, please exit the change mode and delete", @"关键帧模式下无法删除字幕，请退出改模式下再删除")];
        return;
    }
    NvInfoModel *modelInfo = [self getCurrentTimeSpan:self.currentCaption];
    [self.addCaptionView.timelineEditor selectTimeSpan:modelInfo.timeSpan];
    [self.addCaptionView.timelineEditor deleteSelectedTimeSpan];
    ///删除字幕
    ///Delete subtitles
    [self.videoClip removeCaption:self.currentCaption];
    ///删除数据
    ///Delete data
    [self.captionInfoArray removeObject:modelInfo.infoModel];
    [self.timeSpanArray removeObject:modelInfo];
    
    self.currentCaption = [[self.videoClip getCaptionsByClipTimePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]] lastObject];
    if (self.currentCaption) {
        NvInfoModel *modelInfonext = [self getCurrentTimeSpan:self.currentCaption];
        [self.addCaptionView.timelineEditor selectTimeSpan:modelInfonext.timeSpan];
        [self showCaption];
    } else {
        self.rectView.hidden = YES;
    }
    
    int64_t curentTime = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    [self seekTimeline:curentTime];
}

- (void)rectView:(NvRectView *)rectView verticalSwitch:(BOOL)isVertical {
    NvCaptionInfoModel *infoModel = [self getCaptionInfoModel:self.currentCaption];
    if (self.currentCaption.getVerticalLayout) {
        [self.currentCaption setVerticalLayout:false];
    } else {
        [self.currentCaption setVerticalLayout:true];
    }
    if (self.captionKeyframeView != nil) {
        infoModel.isVerticalKeyFrame = YES;
    }
    infoModel.isVerticalLayout = [self.currentCaption getVerticalLayout];
    [self seekTimeline];
    [self.currentCaption setCaptionTranslation:CGPointZero];
    [self updateCaptionView:self.currentCaption];
}

- (void)rectView:(NvRectView *)rectView align:(UIButton *)align {
    NvInfoModel *modelInfo = [self getCurrentTimeSpan:self.currentCaption];
    modelInfo.infoModel.isUserAlignment = YES;
    switch ([self.currentCaption getTextAlignment]) {
        case NvsTextAlignmentLeft:
            [self.currentCaption setTextAlignment:NvsTextAlignmentCenter];
            [rectView setTextAlign:NvCenter];
            modelInfo.infoModel.alignment = NvsTextAlignmentCenter;
            break;
        case NvsTextAlignmentCenter:
            [self.currentCaption setTextAlignment:NvsTextAlignmentRight];
            [rectView setTextAlign:NvRight];
            modelInfo.infoModel.alignment = NvsTextAlignmentRight;
            break;
        case NvsTextAlignmentRight:
            [self.currentCaption setTextAlignment:NvsTextAlignmentLeft];
            [rectView setTextAlign:NvLeft];
            modelInfo.infoModel.alignment = NvsTextAlignmentLeft;
            break;
            
        default:
            [self.currentCaption setTextAlignment:NvsTextAlignmentLeft];
            [rectView setTextAlign:NvRight];
            modelInfo.infoModel.alignment = NvsTextAlignmentLeft;
            break;
    }
    [self seekTimeline];
    [self updateCaptionView:self.currentCaption];
}

- (void)rectView:(NvRectView*)rectView rotate:(float)rotate scale:(float)scale {
    ///存在关键帧，禁止拖拽
    ///Keyframes exist and drag is prohibited
    NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
    BOOL hasKeyFrame = [NvClipKeyFrameManager isExistKeyFrame:captionInfo.keyArray timelineVideoFx:self.currentCaption];
    if (self.captionKeyframeView == nil && hasKeyFrame) {
        [NvToast showInfoWithMessage:NvLocalString(@"Keyframe editing mode has been exited. If you want to change the position of the caption, please remove the keyframe first, then drag and move", @"已退出关键帧编辑模式，如果想要变化字幕的位置，请先移除关键帧，再拖拽移动")];
        return;
    }
    NvInfoModel *modelInfo = [self getCurrentTimeSpan:self.currentCaption];
    modelInfo.infoModel.isUserScale = YES;
    modelInfo.infoModel.isUserRotation = YES;
    modelInfo.infoModel.isUserTranslation = YES;
    NSArray *array = [self.currentCaption getCaptionBoundingVertices:NvsBoundingType_Frame];
    CGPoint center = [self getCenterWithArray:array];

    [self.currentCaption scaleCaption:scale anchor:center];
    [self.currentCaption rotateCaption:rotate anchor:center];
    [self updateCaptionView:self.currentCaption];
    
    modelInfo.infoModel.rotation = [self.currentCaption getRotationZ];
    modelInfo.infoModel.scale = [self.currentCaption getScaleX];
    modelInfo.infoModel.anchorPoint = center;
    modelInfo.infoModel.translation = [self.currentCaption getCaptionTranslation];
    modelInfo.infoModel.opacity = [self.currentCaption getFloatValAtTime:@"Track Opacity" time:self.currentKeyframeInfo.pos];

    if (self.captionKeyframeView) {
        self.currentKeyframeInfo.rotation    = modelInfo.infoModel.rotation;
        self.currentKeyframeInfo.scale       = modelInfo.infoModel.scale;
        self.currentKeyframeInfo.translation = modelInfo.infoModel.translation;
        self.currentKeyframeInfo.opacity = modelInfo.infoModel.opacity;

        [self.currentCaption setScaleX:modelInfo.infoModel.scale];
        [self.currentCaption setScaleY:modelInfo.infoModel.scale];
        [self.currentCaption setRotationZ:modelInfo.infoModel.rotation];

    }
}

- (void)rectView:(NvRectView*)rectView currentPoint:(CGPoint)currentPoint previousPoint:(CGPoint)previousPoint {
    if (![self isContainCurrentCaptionInCurrentTimestamp]) {
        NSLog(@"不包含当前字幕 Does not include current subtitles");
        return;
    }
    ///存在关键帧，禁止拖拽
    ///Keyframes exist and drag is prohibited
    NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
    BOOL hasKeyFrame = [NvClipKeyFrameManager isExistKeyFrame:captionInfo.keyArray timelineVideoFx:self.currentCaption];
    if (self.captionKeyframeView == nil && hasKeyFrame) {
        [NvToast showInfoWithMessage:NvLocalString(@"Keyframe editing mode has been exited. If you want to change the position of the caption, please remove the keyframe first, then drag and move", @"已退出关键帧编辑模式，如果想要变化字幕的位置，请先移除关键帧，再拖拽移动")];
        return;
    }
    CGPoint p1 = [self.liveWindowPanel.liveWindow mapViewToCanonical:currentPoint];
    CGPoint p2 = [self.liveWindowPanel.liveWindow mapViewToCanonical:previousPoint];
    CGPoint newPoint = CGPointMake(p1.x-p2.x, p1.y-p2.y);
    [self.currentCaption translateCaption:newPoint];
    if (self.captionKeyframeView == nil) {
        [self updateCaptionView:self.currentCaption];
    }

    NvInfoModel *modelInfo = [self getCurrentTimeSpan:self.currentCaption];
    modelInfo.infoModel.translation = [self.currentCaption getCaptionTranslation];
    modelInfo.infoModel.opacity = [self.currentCaption getFloatValAtTime:@"Track Opacity" time:self.currentKeyframeInfo.pos];
    modelInfo.infoModel.rotation = [self.currentCaption getRotationZ];
    modelInfo.infoModel.scale = [self.currentCaption getScaleX];
    modelInfo.infoModel.isUserTranslation = YES;
    modelInfo.infoModel.isUserRotation = YES;
    modelInfo.infoModel.isUserScale = YES;
    modelInfo.infoModel.isUserOpacity = YES;

    if (self.captionKeyframeView) {
        self.currentKeyframeInfo.rotation    = modelInfo.infoModel.rotation;
        self.currentKeyframeInfo.scale       = modelInfo.infoModel.scale;
        self.currentKeyframeInfo.translation = modelInfo.infoModel.translation;
        self.currentKeyframeInfo.opacity = modelInfo.infoModel.opacity;
        [self.currentCaption setCaptionTranslation:modelInfo.infoModel.translation];
        [self updateCaptionView:self.currentCaption];
    }
}

- (void)rectView:(NvRectView *)rectView touchUpInside:(CGPoint)point {
    if (self.currentCaption) {
        NSArray *array = [self getBoundingVerticesForCaption:self.currentCaption];
        NSValue *leftTopValue = array[0];
        NSValue *leftBottomValue = array[1];
        NSValue *rightBottomValue = array[2];
        NSValue *rightTopValue = array[3];
        CGPoint topLeftCorner = [leftTopValue CGPointValue];
        CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
        CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
        CGPoint rightTopCorner = [rightTopValue CGPointValue];
        
        topLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:topLeftCorner];
        rightBottomCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightBottomCorner];
        bottomLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:bottomLeftCorner];
        rightTopCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightTopCorner];
        
        CGMutablePathRef pathRef=CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, topLeftCorner.x, topLeftCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, bottomLeftCorner.x, bottomLeftCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, rightBottomCorner.x, rightBottomCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, rightTopCorner.x, rightTopCorner.y);
        CGPathCloseSubpath(pathRef);
        bool isIn = CGPathContainsPoint(pathRef, nil, point, false);
        CGPathRelease(pathRef);
        if(isIn){
            NvsBoundingType textType = NvsBoundingType_Text;
            if (self.currentCaption.captionStylePackageId && self.currentCaption.captionStylePackageId.length>0) {
                NSArray *textPoints = [self getPointsOfCaptionOnRectView:self.currentCaption boundingType:textType];
                [self.rectView setInnerPoints:[NSMutableArray arrayWithArray:textPoints]];
            } else {
                [self.rectView setInnerPoints:nil];
            }
            if (!self.isSelect) {
                ///如果不是被选中则选中它
                ///If it is not selected, select it
                self.isSelect = YES;
                [self.rectView setPoints:@[[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:topLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:bottomLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightBottomCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightTopCorner toView:self.rectView]]]];
            } else {
                ///如果已选中就弹框修改文字
                ///If it is selected, pop the box to modify the text
                [self.rectView setPoints:@[[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:topLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:bottomLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightBottomCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightTopCorner toView:self.rectView]]]];
                NvCaptionDialogViewController *dialogVC = [NvCaptionDialogViewController new];
                dialogVC.delegate = self;
                dialogVC.isChangedText = YES;
                [dialogVC setCaptionText:[self.currentCaption getText]];
                [dialogVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
                
                self.modalPresentationStyle = UIModalPresentationCurrentContext;
                self.providesPresentationContextTransitionStyle = YES;
                self.definesPresentationContext = YES;
                [self presentViewController:dialogVC animated:YES completion:NULL];
            }
        } else {
            ///如果点击的位置不在字幕上
            ///If the location of the click is not on the subtitles
            if ([NvsStreamingContext sharedInstance].getStreamingEngineState != NvsStreamingEngineState_Playback) {
                if (![NvTimelineUtils playbackTimeline:self.timeline startTime:self.liveWindowPanel.currentTime endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
                    NSLog(@"播放时间线失败！Failed to play timeline!");
                    return;
                }
            } else {
                [[NvsStreamingContext sharedInstance] stop];
            }
        }
    }
}

- (void)rectView:(NvRectView *)rectView isHidden:(BOOL)isHidden {
    if (isHidden) {
        [self.liveWindowPanel addTapScreenPause];
    } else {
        [self.liveWindowPanel removeTapScreenPause];
    }
}

- (void)rectView:(NvRectView*)rectView touchBeganPoint:(CGPoint)point{
    
    NSArray *captionArray = [self.videoClip getCaptionsByClipTimePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
    captionArray = [self removeThemeCaption:captionArray];
    for (int i = 0; i < captionArray.count; i++) {
        NvsClipCaption *cap = captionArray[i];
        NSArray *array = [self getBoundingVerticesForCaption:cap];
        NSValue *leftTopValue = array[0];
        NSValue *leftBottomValue = array[1];
        NSValue *rightBottomValue = array[2];
        NSValue *rightTopValue = array[3];
        CGPoint topLeftCorner = [leftTopValue CGPointValue];
        CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
        CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
        CGPoint rightTopCorner = [rightTopValue CGPointValue];
        
        topLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:topLeftCorner];
        rightBottomCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightBottomCorner];
        bottomLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:bottomLeftCorner];
        rightTopCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightTopCorner];
        
        CGMutablePathRef pathRef=CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, topLeftCorner.x, topLeftCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, bottomLeftCorner.x, bottomLeftCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, rightBottomCorner.x, rightBottomCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, rightTopCorner.x, rightTopCorner.y);
        CGPathCloseSubpath(pathRef);
        bool isIn = CGPathContainsPoint(pathRef, nil, point, false);
        CGPathRelease(pathRef);
        if(isIn){
            if (self.currentCaption && self.currentCaption != cap && self.captionKeyframeView != nil){
                self.isSelect = YES;
                return;
            }
            else if (self.currentCaption == cap) {
                self.isSelect = YES;
            } else {
                self.isSelect = NO;
            }
            
            [self.rectView setPoints:@[[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:topLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:bottomLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightBottomCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightTopCorner toView:self.rectView]]]];
            NvsBoundingType textType = NvsBoundingType_Text;
            if (cap.captionStylePackageId && cap.captionStylePackageId.length>0) {
                NSArray *textPoints = [self getPointsOfCaptionOnRectView:cap boundingType:textType];
                [self.rectView setInnerPoints:[NSMutableArray arrayWithArray:textPoints]];
            } else {
                [self.rectView setInnerPoints:nil];
            }
            self.currentCaption = cap;
            NvInfoModel *info = [self getCurrentTimeSpan:cap];
            ///选中timeSpan
            ///Select timeSpan
            [self.addCaptionView.timelineEditor selectTimeSpan:info.timeSpan];
            break;
        }
    }
}

- (void)rectView:(NvRectView *)rectView rotationEnded:(CGPoint)point {
    [self rectView:rectView touchesEnded:point];
}

- (void)rectView:(NvRectView *)rectView touchesEnded:(CGPoint)point {
    if (self.captionKeyframeView == nil) {
        return;
    }
    int64_t timePos = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
    __block NvKeyframeInfo *keyframeInfo = [NvClipKeyFrameManager isExistKeyFrame:captionInfo.keyFramesArray timelinePos:timePos];
    if (keyframeInfo == nil) {
        /// 添加关键帧
        /// Add keyframe
        [NvClipKeyFrameManager insertKeyframe:timePos inPoint:captionInfo.inPoint keyframeSource:captionInfo.keyFramesArray timelineVideoFx:self.currentCaption fxType:NvClipKeyframe_Caption completeHandler:^(NvKeyframeInfo * _Nonnull keyModel, int index) {
            keyframeInfo = keyModel;
            /// 记录当前字幕的位置、旋转、缩放
            /// Record the current subtitle position, rotation, and scaling
            if (keyframeInfo.translation.x == 0 && keyframeInfo.translation.y == 0) {
                if (keyframeInfo.rotation == 0 && keyframeInfo.scale == 1) {
                    keyframeInfo.rotation    = [self.currentCaption getRotationZ];
                    keyframeInfo.scale       = [self.currentCaption getScaleX];
                    keyframeInfo.translation = [self.currentCaption getCaptionTranslation];
                    keyframeInfo.opacity = [self.currentCaption getFloatValAtTime:@"Track Opacity" time:keyframeInfo.pos];

                    [self.currentCaption setScaleX:keyframeInfo.scale];
                    [self.currentCaption setScaleY:keyframeInfo.scale];
                    [self.currentCaption setRotationZ:keyframeInfo.rotation];
                    [self.currentCaption setCaptionTranslation:keyframeInfo.translation];
                    [self.currentCaption setFloatValAtTime:@"Track Opacity" val:keyframeInfo.opacity time:keyframeInfo.pos];

                }
            }
            [self.addCaptionView.timelineEditor configKeyFrames:[self numberArray:captionInfo.keyFramesArray] withSpanInPoint:captionInfo.inPoint withOutPoint:captionInfo.outPoint];
            [self.addCaptionView.timelineEditor configSelectKeyFrames:index];
            [self.captionKeyframeView resetOptKeyFrameButton:YES];
            [self removeKeyframeControlPoint];
        }];
    }else {
        keyframeInfo.rotation    = [self.currentCaption getRotationZ];
        keyframeInfo.scale       = [self.currentCaption getScaleX];
        keyframeInfo.translation = [self.currentCaption getCaptionTranslation];
        keyframeInfo.opacity = [self.currentCaption getFloatValAtTime:@"Track Opacity" time:keyframeInfo.pos];
        keyframeInfo.translationPairX = nil;
        keyframeInfo.translationPairY = nil;
        keyframeInfo.type = CurveAnimationType1;
        keyframeInfo.leftPoint = CGPointZero;
        keyframeInfo.rightPoint = CGPointZero;
    }
    self.currentKeyframeInfo = keyframeInfo;
}

#pragma mark - 返回按钮事件 Back button event
- (void)nvAddCaptionViewdidAddOkClick {
    NvsClipCaption *nextCaption = [self.videoClip getFirstCaption];
    while (nextCaption) {
        NvCaptionInfoModel *infoModel = [self getCaptionInfoModel:nextCaption];
        infoModel.translation = [nextCaption getCaptionTranslation];
        infoModel.scale = [nextCaption getScaleX];
        infoModel.rotation = [nextCaption getRotationZ];
        infoModel.category = [nextCaption category];
        infoModel.roleInTheme = [nextCaption roleInTheme];
        infoModel.textColor = [nextCaption getTextColor];
        infoModel.anchorPoint = [nextCaption getAnchorPoint];
        infoModel.fontSize = [nextCaption getFontSize];
        infoModel.inPoint = nextCaption.inPoint;
        infoModel.outPoint = nextCaption.outPoint;
        infoModel.isDrawOutline = [nextCaption getDrawOutline];
        infoModel.outlineColor = [nextCaption getOutlineColor];
        infoModel.outlineWidth = [nextCaption getOutlineWidth];
        infoModel.fontFilePath = [nextCaption getFontFilePath];
        infoModel.alignment = [nextCaption getTextAlignment];
        infoModel.letterSpace = [nextCaption getLetterSpacing];
        infoModel.boundaryMargin = [nextCaption getBoundaryPaddingRatio];
        infoModel.isBold = [nextCaption getBold];
        infoModel.opacity = [nextCaption getOpacity];
        infoModel.isItalic = [nextCaption getItalic];
        infoModel.isDrawShadow = [nextCaption getDrawShadow];
        infoModel.isUnderLine = [nextCaption getUnderline];
        infoModel.shadowOffset = CGPointMake(10, -10);
        infoModel.shadowColor = [nextCaption getShadowColor];
        infoModel.isVerticalLayout = [nextCaption getVerticalLayout];
        
        nextCaption = [self.videoClip getNextCaption:nextCaption];
    }
    self.model.captionDataArray = self.captionInfoArray;
    NSMutableArray *order = [[NvTimelineData sharedInstance] dataOrder];
    [order removeObject:@"Caption"];
    [order addObject:@"Caption"];
    [self.streamingContext removeTimeline:self.timeline];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 缩放timelineEditor  zoom timelineEditor
- (void)captionTimelineEditorZoomIn {
    [self.addCaptionView.timelineEditor zoomIn];
    [self.addCaptionView setcurrentTime:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
}
- (void)captionTimelineEditorZoomOut {
    [self.addCaptionView.timelineEditor zoomOut];
    [self.addCaptionView setcurrentTime:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
}

#pragma mark - NvAddCaptionViewDelegate
- (void)dragTimelineEditor:(int64_t)timestamp {
    self.liveWindowPanel.progressSlider.value = 1.0*timestamp/self.timeline.duration;
    self.liveWindowPanel.currentTime = timestamp;
    self.rectView.hidden = YES;
    
    ///拖动过程中显示时间
    ///Show the time while dragging
    [self.addCaptionView setcurrentTime:timestamp];
    self.isChange = YES;
    self.scaleForSeek = self.timeline.duration / 1000000 /  [self.addCaptionView.timelineEditor getTimelineEditorWidth] / UIScreen.mainScreen.scale;
    [self seekTimeline:timestamp];
    [self setSlideStatus];

}

///timespan滑块拖拽过程中
///timespan slider during drag
- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint {
    self.isChange = YES;
    self.scaleForSeek = self.timeline.duration / 1000000 /  [self.addCaptionView.timelineEditor getTimelineEditorWidth] / UIScreen.mainScreen.scale;
    ///更改出入点
    ///Change access point
    NvInfoModel *model = [self getCurrentTimeSpan:self.currentCaption];
    if (isInPoint) {
        model.infoModel.inPoint = timestamp;
        [self seekTimeline:timestamp];
        ///播放过程中显示时间
        ///The time is displayed during playback
        [self.addCaptionView setcurrentTime:timestamp];
    } else {
        model.infoModel.outPoint = timestamp;
        [self seekTimeline:timestamp-10000];
        ///播放过程中显示时间
        ///The time is displayed during playback
        [self.addCaptionView setcurrentTime:timestamp-10000];
    }
}

///timespan滑块拖拽结束
///The timespan slider drag is over
- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)timestamp isInPoint:(bool)isInPoint {
    self.isChange = NO;
    [self.addCaptionView.timelineEditor setTimelinePosition:timestamp];
    NvInfoModel *modelnext = [self getCurrentTimeSpan:self.currentCaption];
    if (self.currentCaption) {
        [self updateCaptionViewNOSeek:self.currentCaption];
        [self.addCaptionView.timelineEditor selectTimeSpan:modelnext.timeSpan];
    }
    if (isInPoint) {
        [self.currentCaption changeInPoint:timestamp];
        [self seekTimeline:timestamp];
        [self nvDragHandleEnded:timestamp isInPoint:YES];
    } else {
        [self.currentCaption changeOutPoint:timestamp];
        [self seekTimeline:timestamp-10000];
        [self nvDragHandleEnded:timestamp - 10000 isInPoint:NO];
    }
}

///拖拽timelineEditor结束回调
///Drag timelineEditor to end the callback
- (void)dragScrollTimelineEnded:(int64_t)timestamp {
    self.isChange = NO;
    NvInfoModel *model = [self getCurrentTimeSpan:self.currentCaption];
    [self.addCaptionView.timelineEditor selectTimeSpan:model.timeSpan];
    [self targetSeekToTimeStamp:timestamp];
}

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    [self.addCaptionView.timelineEditor selectTimeSpan:nil];
    self.addCaptionView.playButton.selected = YES;
    [self hiddenORShowAddCaptionViewOnCurrentTime];
    [self.addCaptionView.timelineEditor setTimelinePosition:position];
    self.rectView.hidden = YES;
    
    [self.addCaptionView setcurrentTime:position];
    ///播放过程中关闭字幕关键帧编辑
    ///Turn off subtitle keyframe editing during playback
    if (self.captionKeyframeView) {
        self.captionKeyframeView.enablePrebutton  = NO;
        self.captionKeyframeView.enableNextbutton = NO;
        self.captionKeyframeView.enableAddbutton  = NO;
    }
    self.addCaptionView.styleButton.hidden = YES;
    self.addCaptionView.keyframeButton.hidden = YES;
    CGFloat value = [self.currentCaption getFloatValAtTime:@"Track Opacity" time:position] ;
    self.opacitySlider.value = value;
    [self refreshOpacityLabel];
}

- (void)didPlaybackStopped:(NvsTimeline *)timeline {
    int64_t timeStamp = [self.streamingContext getTimelineCurrentPosition:timeline];
    if (self.captionKeyframeView != nil && self.currentCaption) {
        NvInfoModel *model = [self getCurrentTimeSpan:self.currentCaption];
        [self.addCaptionView.timelineEditor selectTimeSpan:model.timeSpan];
    }
    [self.addCaptionView.timelineEditor setTimelinePosition:timeStamp];
    self.addCaptionView.playButton.selected = NO;
    [self targetSeekToTimeStamp:timeStamp];
}

- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    __block int64_t timePos = 0;
    if (self.captionKeyCurveView) {
        timePos = self.curveTime;
        NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
        __block NvKeyframeInfo *preKeyframeModel = nil;
        [NvClipKeyFrameManager getPreKeyFrame:captionInfo.keyArray timelinePos:timePos inPoint:captionInfo.inPoint keyframeSource:captionInfo.keyFramesArray timelineVideoFx:self.currentCaption completeHandler:^(NvKeyframeInfo * _Nonnull keyModel, int index, BOOL previous) {
            preKeyframeModel = keyModel;
        }];
        timePos = preKeyframeModel.time;
    }
    
    [self.addCaptionView.timelineEditor setTimelinePosition:timePos];
    [self seekTimeline:timePos];
    [self targetSeekToTimeStamp:timePos];
}

#pragma mark - 拖动、停止、播放结束时需要做的工作
///Drag, stop, and end of play
- (void)targetSeekToTimeStamp:(int64_t)timeStamp {
    BOOL hasCaption = [self seekTimelineRectViewStatus];
    [self hiddenORShowAddCaptionView:timeStamp];
    if (self.currentCaption && hasCaption) {
        [self updateCaptionViewNOSeek:self.currentCaption];
        NvInfoModel *modelInfo = [self getCurrentTimeSpan:self.currentCaption];
        [self.addCaptionView.timelineEditor selectTimeSpan:modelInfo.timeSpan];
        if (self.captionKeyframeView != nil) {
            [self seekTimeline:timeStamp];
            [self nvUpdateKeyframeStatus];
        }else {
            [self getCurrentPosBorder:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
        }
    } else {
        [self.addCaptionView.timelineEditor selectTimeSpan:nil];
        if (self.captionKeyframeView != nil) {
            [self nvAddCaptionViewShowKeyFrame:YES];
        }
        [self seekTimeline];
    }
}

- (BOOL)seekTimelineRectViewStatus {
    BOOL hasCaption = YES;
    NSArray *captionArr = [self.videoClip getCaptionsByClipTimePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
    if (![captionArr containsObject:self.currentCaption]) {
        if (self.captionKeyframeView == nil) {
            _currentCaption = [[self.videoClip getCaptionsByClipTimePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]] lastObject];
        }else{
            hasCaption = NO;
        }
    }
    self.rectView.hidden = (self.currentCaption && hasCaption)?NO:YES;
    return hasCaption;
}

-(void)opacitySliderValueChanged:(UISlider *)slider{
    [self refreshOpacityLabel];
    if (![self isContainCurrentCaptionInCurrentTimestamp]) {
        NSLog(@"不包含当前字幕 Does not include current subtitles");
        return;
    }

    if (self.captionKeyframeView) {
        int64_t timePos = [self.streamingContext getTimelineCurrentPosition:self.timeline];
        NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
        __block NvKeyframeInfo *keyframeInfo = [NvClipKeyFrameManager isExistKeyFrame:captionInfo.keyFramesArray timelinePos:timePos];
        if (keyframeInfo == nil) {
            /// 添加关键帧
            /// Add keyframe
            [NvClipKeyFrameManager insertKeyframe:timePos inPoint:captionInfo.inPoint keyframeSource:captionInfo.keyFramesArray timelineVideoFx:self.currentCaption fxType:NvClipKeyframe_Caption completeHandler:^(NvKeyframeInfo * _Nonnull keyModel, int index) {
                keyframeInfo = keyModel;
                /// 记录当前字幕的位置、旋转、缩放
                /// Record the current subtitle position, rotation, and scaling
                if (keyframeInfo.translation.x == 0 && keyframeInfo.translation.y == 0) {
                    if (keyframeInfo.rotation == 0 && keyframeInfo.scale == 1) {
                        keyframeInfo.rotation    = [self.currentCaption getRotationZ];
                        keyframeInfo.scale       = [self.currentCaption getScaleX];
                        keyframeInfo.translation = [self.currentCaption getCaptionTranslation];
                        keyframeInfo.opacity = [self.currentCaption getFloatValAtTime:@"Track Opacity" time:keyframeInfo.pos];
                        [self.currentCaption setScaleX:keyframeInfo.scale];
                        [self.currentCaption setScaleY:keyframeInfo.scale];
                        [self.currentCaption setRotationZ:keyframeInfo.rotation];
                        [self.currentCaption setCaptionTranslation:keyframeInfo.translation];
                        [self.currentCaption setFloatValAtTime:@"Track Opacity" val:keyframeInfo.opacity time:keyframeInfo.pos];
                    }
                }
                [self.addCaptionView.timelineEditor configKeyFrames:[self numberArray:captionInfo.keyFramesArray] withSpanInPoint:captionInfo.inPoint withOutPoint:captionInfo.outPoint];
                [self.addCaptionView.timelineEditor configSelectKeyFrames:index];
                [self.captionKeyframeView resetOptKeyFrameButton:YES];
                [self removeKeyframeControlPoint];
            }];
        }else {
            [self.currentCaption setFloatValAtTime:@"Track Opacity" val:slider.value time:keyframeInfo.pos];
            keyframeInfo.rotation    = [self.currentCaption getRotationZ];
            keyframeInfo.scale       = [self.currentCaption getScaleX];
            keyframeInfo.translation = [self.currentCaption getCaptionTranslation];
            keyframeInfo.opacity = [self.currentCaption getFloatValAtTime:@"Track Opacity" time:keyframeInfo.pos];
            keyframeInfo.translationPairX = nil;
            keyframeInfo.translationPairY = nil;
            keyframeInfo.type = CurveAnimationType1;
            keyframeInfo.leftPoint = CGPointZero;
            keyframeInfo.rightPoint = CGPointZero;
        }
        self.currentKeyframeInfo = keyframeInfo;
        [self seekTimeline];
    }else{
        ///存在关键帧，禁止拖拽
        ///Keyframes exist and drag is prohibited
        NvCaptionInfoModel *captionInfo = [self getCaptionInfoModel:self.currentCaption];
        BOOL hasKeyFrame = [NvClipKeyFrameManager isExistKeyFrame:captionInfo.keyArray timelineVideoFx:self.currentCaption];
        if (hasKeyFrame) {
            [NvToast showInfoWithMessage:NvLocalString(@"Keyframe editing mode has been exited. If you want to change the position of the caption, please remove the keyframe first, then drag and move", @"已退出关键帧编辑模式，如果想要变化字幕的位置，请先移除关键帧，再拖拽移动")];
            return;
        }
        
        NvInfoModel *modelInfo = [self getCurrentTimeSpan:self.currentCaption];
        modelInfo.infoModel.isUserOpacity = YES;
        [self.currentCaption setOpacity:slider.value];
        [self seekTimeline];
    }

}

- (void)initSubViews {
    self.rectView = [[NvRectView alloc] init];
    self.rectView.delegate = self;
    self.rectView.layer.masksToBounds = YES;
    [self.liveWindowPanel.liveWindow addSubview:self.rectView];
    [self.rectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    self.rectView.hidden = YES;
    self.addCaptionView = [NvAddCaptionView new];
    self.addCaptionView.delegate = self;
    self.addCaptionView.timeline = self.timeline;
    self.addCaptionView.styleButton.hidden = YES;
    self.addCaptionView.keyframeButton.hidden = YES;
    [self.view addSubview:self.addCaptionView];
    [self.addCaptionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(SCREENWIDTH));
        make.left.right.bottom.equalTo(@0);
        make.height.equalTo(@(234*SCREENSCALE + INDICATOR));
    }];
    
    [self.addCaptionView setcurrentTime:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
    
    
    self.opacitySlider = [[UISlider alloc]init];
    [self.opacitySlider setMinimumValue:0.0];
    [self.opacitySlider setMaximumValue:1.0];
    [self.opacitySlider setValue:1.0];
    self.opacitySlider.minimumTrackTintColor = [UIColor nv_colorWithHexString:@"#4A90E2"];
    self.opacitySlider.maximumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    [self.opacitySlider setThumbImage:NvImageNamed(@"NvsliderWhite") forState:UIControlStateNormal];
    [self.opacitySlider addTarget:self action:@selector(opacitySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.opacitySlider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.opacitySlider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpOutside];

    [self.view addSubview:self.opacitySlider];
    [self.opacitySlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.addCaptionView.mas_top).offset(-20.0 * SCREENSCALE);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.offset(240 * SCREENSCALE);
        make.height.offset(5 * SCREENSCALE);
    }];
    
    
    self.opacityLabel = [UILabel nv_labelWithText:NvLocalString(@"Opacity", @"不透明度") fontSize:12 textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"]];
    self.opacityLabel.alpha = 0.8;
    self.opacityLabel.font = [NvUtils regularFontWithSize:12];
    [self.view addSubview:self.opacityLabel];
    [self.opacityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(13*SCREENSCALE);
        make.bottom.mas_equalTo(self.addCaptionView.mas_top).offset(-25.0 * SCREENSCALE);
        make.centerY.equalTo(self.opacitySlider.mas_centerY);
    }];
    
    self.opacityNumLabel = [UILabel nv_labelWithText:@"100" fontSize:12 textColor:[UIColor whiteColor]];
    self.opacityNumLabel.alpha = 0.8;
    self.opacityNumLabel.font = [NvUtils regularFontWithSize:12];
    [self.view addSubview:self.opacityNumLabel];
    [self.opacityNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-17*SCREENSCALE);
        make.centerY.equalTo(self.opacityLabel);
        make.width.equalTo(@(25*SCREENSCALE));
    }];
    
    ///恢复数据
    ///Recover data
    NvsClipCaption *nextCaption = [self.videoClip getFirstCaption];
    self.currentCaption = nextCaption;
    do {
        if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
            
        }else{
            NvsCTimelineTimeSpan *timeSpan = [self.addCaptionView.timelineEditor addTimeSpan:nextCaption.inPoint outPoint:nextCaption.outPoint];
            if (nextCaption.isModular) {
                timeSpan.timeSpanColor = [UIColor nv_colorWithHexARGB:@"#99EA4359"];
            }
            [self.addCaptionView.timelineEditor selectTimeSpan:timeSpan];
            ///存储一个infoModel对象用于使timelineEditor高亮
            ///Stores an infoModel object for highlighting the timelineEditor
            NvInfoModel *infoModel = [NvInfoModel new];
            infoModel.currentClipCaption = nextCaption;
            infoModel.infoModel =  [self getCaptionInfoModel:nextCaption];
            infoModel.timeSpan = timeSpan;
            if (nextCaption) {
                [self.timeSpanArray addObject:infoModel];
            }
        }
        nextCaption = [self.videoClip getNextCaption:nextCaption];
    } while (nextCaption);
    
    self.currentCaption = [[self.videoClip getCaptionsByClipTimePosition:0] firstObject];
    if (self.currentCaption) {
        self.isSelect = YES;
        NvInfoModel *infoModel =  [self getCurrentTimeSpan:self.currentCaption];
        [self.addCaptionView.timelineEditor selectTimeSpan:infoModel.timeSpan];
        __weak typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.rectView.hidden = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf updateCaptionView:weakSelf.currentCaption];
            });
            weakSelf.addCaptionView.styleButton.hidden = NO;
            weakSelf.addCaptionView.keyframeButton.hidden = NO;
            [weakSelf nvAddCaptionViewShowKeyFrame: YES];
        });
    } else {
        self.rectView.hidden = YES;
        self.addCaptionView.styleButton.hidden = YES;
        self.addCaptionView.keyframeButton.hidden = YES;
        [self.addCaptionView.timelineEditor selectTimeSpan:nil];
    }
    
}
///获取字幕对应的infoModel对象
///Obtain the infoModel object corresponding to the subtitle
- (NvCaptionInfoModel *)getCaptionInfoModel:(NvsClipCaption *) nextCaption {
    return (NvCaptionInfoModel *)[nextCaption getAttachment:@"captionInfoModel"];
}

- (void)setCurrentCaption:(NvsClipCaption *)currentCaption{
    if (currentCaption.category == NvsThemeCategory && currentCaption.roleInTheme != NvsRoleInThemeGeneral) {
        _currentCaption = nil;
    }else{
        _currentCaption = currentCaption;
    }
}

- (NSArray *)removeThemeCaption:(NSArray *)captionArray {
    NSMutableArray *array = [NSMutableArray array];
    [captionArray enumerateObjectsUsingBlock:^(NvsClipCaption*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.category == NvsThemeCategory && obj.roleInTheme != NvsRoleInThemeGeneral) {
            
        } else {
            [array addObject:obj];
        }
    }];
    return [array copy];
}

@end
