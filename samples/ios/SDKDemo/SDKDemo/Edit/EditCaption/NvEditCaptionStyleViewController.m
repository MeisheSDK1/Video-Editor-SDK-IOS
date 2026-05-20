//
//  NvEditCaptionStyleViewController.m
//  SDKDemo
//
//  Created by MS on 2019/7/17.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvEditCaptionStyleViewController.h"
#import "NvsStreamingContext.h"
#import "NvTimelineUtils.h"
#import "NvModularStyleView.h"
#import "NvModularStyleVM.h"
#import "NvMenuTextView.h"
#import "NvsCaptionSpan.h"

@interface NvEditCaptionStyleViewController ()
<NvAddCaptionViewDelegate,
NvRectViewDelegate,
NvCaptionDialogDelegate,
NvLiveWindowPanelViewDelegate,
NvsStreamingContextDelegate,
NvAssetManagerDelegate,
NvModularStyleVMDelegate,
UITextViewDelegate,
NvStyleViewDelegate,
NvModularStyleViewDelegate,
UITextDragDelegate>

@property (nonatomic, strong) NvRectView *rectView;
@property (nonatomic, strong) NvStyleView *styleView;
@property (nonatomic, strong) NvMenuTextView *textView;
@property (nonatomic, strong) NvModularStyleView *modularStyleView;
///当前字幕是否是被选中(用于区分是否需要弹框)
///Whether the current subtitle is selected (to distinguish whether a box is needed)
@property (nonatomic, assign) BOOL isSelect;
///字体列表
///Font list
@property (nonatomic, strong) NSMutableArray *fontDataSource;

@property (nonatomic, strong) NvModularStyleVM *modularStyleVM;
@property (nonatomic, assign) BOOL selectStyle;
@property (nonatomic, assign) NSRange textChangeRange;
@property (nonatomic, strong) NSString *replacementText;
@end

@implementation NvEditCaptionStyleViewController

- (void)dealloc {
    NSLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NvLocalString(@"Caption", @"字幕");
    
    [self initSubViews];
    [self addObservers];
    self.liveWindowPanel.frame = CGRectMake(0, NV_STATUSBARHEIGHT > 20?NV_STATUSBARHEIGHT:0, SCREENWIDTH, SCREENWIDTH);
    self.liveWindowPanel.dontNeedSeekCtl = YES;
    [self.liveWindowPanel setForceHiddenControlPanel:YES];
    self.liveWindowPanel.delegate = self;
}

- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

///设置默认数据
///Set default data
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    if (self.captionType == Normal) {
        [self.modularStyleVM searchStyle];
        [self showCaption];
    } else {
        [self.modularStyleVM searchCaptionRenderer];
        [self.modularStyleVM searchCaptionContext];
        [self.modularStyleVM searchCaptionAnimation];
        [self.modularStyleVM searchCaptionInAnimation];
        [self.modularStyleVM searchCaptionOutAnimation];
        [self showCaption];
    }
    [self.modularStyleVM searchFonts];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.captionType == Normal) {
        if (self.currentCaption == nil && self.selectedIndex == 1) {
            self.textView.text = NvLocalString(@"Enter text", @"输入文字");
            [self addCaption:self.textView.text];
        }
        self.styleView.selectedIndex = self.selectedIndex;
    }
   
    if (self.selectedIndex == 0) {
        [self.textView becomeFirstResponder];
    }
}

- (void)stylePlay {
    if (![NvTimelineUtils playbackTimeline:self.timeline startTime:0 endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
        NSLog(@"播放时间线失败！ Failed to play timeline!");
        return;
    }
}

///添加关键帧获取字幕边框
///Add a keyframe to get the subtitle border
- (void)getCurrentPosBorder:(int64_t)pos{
    if (self.captionInfo.keyFramesArray.count > 0) {
        __block BOOL flags = NO;
        [self.captionInfo.keyFramesArray enumerateObjectsUsingBlock:^(NvKeyframeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.time == pos) {
                flags = YES;
                *stop = YES;
            }
        }];
        if (!flags) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.currentCaption setCurrentKeyFrameTime:pos - self.captionInfo.inPoint];
                [self showCaption];
                [self.captionInfo.keyArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.currentCaption removeKeyframeAtTime:obj time:pos - self.captionInfo.inPoint];
                }];
            });
        }else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.currentCaption setCurrentKeyFrameTime:pos - self.captionInfo.inPoint];
                [self showCaption];
            });
        }
    }else {
        ///判断此时间点是否有关键帧
        ///Determines whether there are keyframes at this point in time
        ///有关键帧的话，获取当前贴纸位置画框
        ///If there is a keyframe, get the current sticker position frame
        ///无关键帧（考虑贴纸处于运动中），通过添加关键帧获取位置画框，然后将新加关键帧删除
        ///No keyframe (considering the sticker is in motion), get the position frame by adding the keyframe, and then delete the new keyframe
        BOOL hasKeyFrame = NO;
        for (NvKeyframeInfo *model in self.captionInfo.keyFramesArray) {
            if (model.time == (pos - self.captionInfo.inPoint)) {
                hasKeyFrame = YES;
                break;
            }
        }
        if (hasKeyFrame) {
            if (pos == 0) {
                [self.currentCaption setCurrentKeyFrameTime:pos - self.captionInfo.inPoint];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showCaption];
            });
        }else if (self.captionInfo.keyFramesArray.count > 0){
            [self.currentCaption setCurrentKeyFrameTime:pos - self.captionInfo.inPoint];
            [self showCaption];
            for (NSString *string in self.captionInfo.keyArray) {
                [self.currentCaption removeKeyframeAtTime:string time:pos-self.captionInfo.inPoint];
            }
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showCaption];
            });
        }
    }
}

///重现显示字幕及选中框
///Show the subtitles and check box again
- (void)showCaption {
    if (self.currentCaption == nil) {
        self.rectView.hidden = YES;
        return;
    }
    self.rectView.hidden = NO;
    [self updateCaptionView:self.currentCaption];
}

///更新字幕框的位置
///Update the location of the subtitle box
- (void)updateCaptionView: (NvsTimelineCaption*) caption {
    if (!caption) {
        return;
    }
    [self updateCaptionViewNOSeek:caption];
    [self seekTimeline];
}

- (void)updateCaptionViewNOSeek:(NvsTimelineCaption*) caption {
    NvsBoundingType frameType = NvsBoundingType_Frame;
    NSArray *framePoints = [self getPointsOfCaptionOnRectView:caption boundingType:frameType];
    [self.rectView setPoints:framePoints];
    NvsBoundingType textType = NvsBoundingType_Text;
    if (caption.captionStylePackageId && caption.captionStylePackageId.length>0) {
        NSArray *textPoints = [self getPointsOfCaptionOnRectView:caption boundingType:textType];
        [self.rectView setInnerPoints:[NSMutableArray arrayWithArray:textPoints]];
    } else {
        [self.rectView setInnerPoints:nil];
    }
    NSString *captionText = [caption getText];
    if (captionText != nil && captionText.length > 0 ) {
        self.rectView.hidden = NO;
    } else {
        self.rectView.hidden = YES;
    }
    
    if ([caption getTextAlignment] == NvsTextAlignmentLeft) {
        [self.rectView setTextAlign:NvLeft];
    } else if ([caption getTextAlignment] == NvsTextAlignmentCenter) {
        [self.rectView setTextAlign:NvCenter];
    } else if ([caption getTextAlignment] == NvsTextAlignmentRight) {
        [self.rectView setTextAlign:NvRight];
    }
}

- (CGFloat)getRadiusWithCaption:(NvsTimelineCaption*) caption {
    NSArray *array = [caption getCaptionBoundingVertices:NvsBoundingType_Text_Frame];
    NSValue *leftTopValue = array[0];
    NSValue *leftBottomValue = array[1];
    NSValue *rightTopValue = array[3];
    CGFloat height = [self distanceWithFirst:[leftTopValue CGPointValue] second:[leftBottomValue CGPointValue]];
    CGFloat width = [self distanceWithFirst:[leftTopValue CGPointValue] second:[rightTopValue CGPointValue]];
    return MIN(height/2, width/2);
}

- (NSArray <NSValue *>*)getPointsOfCaptionOnRectView:(NvsTimelineCaption*)caption boundingType:(NvsBoundingType)boundingType {
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

///获取两点之间距离
///Get the distance between two points
- (CGFloat)distanceWithFirst:(CGPoint)first second:(CGPoint)second {
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY );
};

- (CGPoint)getCenterWithArray:(NSArray*)array {
    NSValue *leftTopValue = array[0];
    NSValue *rightBottomValue = array[2];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    return CGPointMake((topLeftCorner.x+rightBottomCorner.x)/2, (topLeftCorner.y+rightBottomCorner.y)/2);
}

#pragma mark - NvAddCaptionViewDelegate
- (void)nvAddCaptionViewdidAddCaptionClick {
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

- (void)nvseekTimeline {
    [self seekTimeline];
}

- (void)updateCaptionRect {
    [self updateCaptionViewNOSeek:self.currentCaption];
}

- (void)playTimeline:(int64_t)start end:(int64_t)end {
    ///这个地方多播放200000微妙是为了让动画播的更完整，可以看清播动画放后是什么样子
    ///This place plays 200000 more subtle in order to make the animation broadcast more complete, you can see what the animation is like after playing
    [NvTimelineUtils playbackTimeline:self.timeline startTime:start endTime:end + 200000 flags:NvsStreamingEnginePlaybackFlag_LowPipelineSize|NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}

///样式播放
///Style play
- (void)stylePlayFromTime:(int64_t)time {
    [self.liveWindowPanel playBackStart:time end:self.currentCaption.outPoint];
}

- (NvRectView *)getRectView {
    return self.rectView;
}

#pragma mark - NvRectViewDelegate
- (void)rectView:(NvRectView*)rectView close:(UIButton*)close {
    [self.streamingContext stop];
    if ([self.delegate respondsToSelector:@selector(editCaptionStyleViewController:closeCaption:)]) {
        [self.delegate editCaptionStyleViewController:self closeCaption:self.currentCaption];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rectView:(NvRectView *)rectView verticalSwitch:(BOOL)isVertical {
    if (self.currentCaption.getVerticalLayout) {
        [self.currentCaption setVerticalLayout:false];
    } else {
        [self.currentCaption setVerticalLayout:true];
    }
    self.captionInfo.isVerticalLayout = [self.currentCaption getVerticalLayout];
    [self seekTimeline];
    [self updateCaptionView:self.currentCaption];
}

- (void)rectView:(NvRectView *)rectView align:(UIButton *)align {
    self.captionInfo.isUserAlignment = YES;
    switch ([self.currentCaption getTextAlignment]) {
        case NvsTextAlignmentLeft:
            [self.currentCaption setTextAlignment:NvsTextAlignmentCenter];
            [rectView setTextAlign:NvCenter];
            self.captionInfo.alignment = NvsTextAlignmentCenter;
            break;
        case NvsTextAlignmentCenter:
            [self.currentCaption setTextAlignment:NvsTextAlignmentRight];
            [rectView setTextAlign:NvRight];
            self.captionInfo.alignment = NvsTextAlignmentRight;
            break;
        case NvsTextAlignmentRight:
            [self.currentCaption setTextAlignment:NvsTextAlignmentLeft];
            [rectView setTextAlign:NvLeft];
            self.captionInfo.alignment = NvsTextAlignmentLeft;
            break;
            
        default:
            [self.currentCaption setTextAlignment:NvsTextAlignmentLeft];
            [rectView setTextAlign:NvLeft];
            self.captionInfo.alignment = NvsTextAlignmentLeft;
            break;
    }
    [self seekTimeline];
    [self updateCaptionView:self.currentCaption];
}

- (void)rectView:(NvRectView *)rectView scale:(float)scale {
    if (self.captionInfo.keyFramesArray.count > 0) {
        [NvToast showInfoWithMessage:NvLocalString(@"Keyframe editing mode has been exited. If you want to change the position of the caption, please remove the keyframe first, then drag and move", @"已退出关键帧编辑模式，如果想要变化字幕的位置，请先移除关键帧，再拖拽移动")];
        return;
    }
    NSArray *array = [self.currentCaption getCaptionBoundingVertices:NvsBoundingType_Frame];
    CGPoint center = [self getCenterWithArray:array];
    [self.currentCaption scaleCaption:scale anchor:center];
    [self updateCaptionView:self.currentCaption];
    self.captionInfo.isUserScale = YES;
    self.captionInfo.scale = [self.currentCaption getScaleX];
    self.captionInfo.anchorPoint = center;
    if (self.captionInfo.keyFramesArray.count > 0) {
        [self.currentCaption setScaleX:self.captionInfo.scale];
        [self.currentCaption setScaleY:self.captionInfo.scale];
    }
}

- (void)rectView:(NvRectView*)rectView rotate:(float)rotate scale:(float)scale {
    if (self.captionInfo.keyFramesArray.count > 0) {
        [NvToast showInfoWithMessage:NvLocalString(@"Keyframe editing mode has been exited. If you want to change the position of the caption, please remove the keyframe first, then drag and move", @"已退出关键帧编辑模式，如果想要变化字幕的位置，请先移除关键帧，再拖拽移动")];
        return;
    }
    NSArray *array = [self.currentCaption getCaptionBoundingVertices:NvsBoundingType_Frame];
    CGPoint center = [self getCenterWithArray:array];

    [self.currentCaption scaleCaption:scale anchor:center];
    [self.currentCaption rotateCaption:rotate anchor:center];
    [self updateCaptionView:self.currentCaption];
    
    self.captionInfo.isUserScale = YES;
    self.captionInfo.isUserRotation = YES;
    self.captionInfo.isUserTranslation = YES;
    self.captionInfo.translation = [self.currentCaption getCaptionTranslation];
    self.captionInfo.rotation = [self.currentCaption getRotationZ];
    self.captionInfo.scale = [self.currentCaption getScaleX];
    self.captionInfo.anchorPoint = center;
    if (self.captionInfo.keyFramesArray.count > 0) {
        [self.currentCaption setScaleX:self.captionInfo.scale];
        [self.currentCaption setScaleY:self.captionInfo.scale];
        [self.currentCaption setRotationZ:self.captionInfo.rotation];
    }
}

- (void)rectView:(NvRectView*)rectView currentPoint:(CGPoint)currentPoint previousPoint:(CGPoint)previousPoint {
    if (self.captionInfo.keyFramesArray.count > 0) {
        [NvToast showInfoWithMessage:NvLocalString(@"Keyframe editing mode has been exited. If you want to change the position of the caption, please remove the keyframe first, then drag and move", @"已退出关键帧编辑模式，如果想要变化字幕的位置，请先移除关键帧，再拖拽移动")];
        return;
    }
    CGPoint p1 = [self.liveWindowPanel.liveWindow mapViewToCanonical:currentPoint];
    CGPoint p2 = [self.liveWindowPanel.liveWindow mapViewToCanonical:previousPoint];
    CGPoint newPoint = CGPointMake(p1.x-p2.x, p1.y-p2.y);
    [self.currentCaption translateCaption:newPoint];
    
    [self updateCaptionView:self.currentCaption];
    self.captionInfo.translation = [self.currentCaption getCaptionTranslation];
    self.captionInfo.isUserScale = YES;
    self.captionInfo.isUserRotation = YES;
    self.captionInfo.isUserTranslation = YES;
    if (self.captionInfo.keyFramesArray.count > 0) {
        [self.currentCaption setCaptionTranslation:self.captionInfo.translation];
    }

}

- (void)rectView:(NvRectView *)rectView touchUpInside:(CGPoint)point {
    if (self.currentCaption.isModular != self.captionType) {
        return;
    }
    if (self.currentCaption) {
        NSArray *array = [self.currentCaption getCaptionBoundingVertices:NvsBoundingType_Frame];
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
            [self.rectView setPoints:@[[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:topLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:bottomLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightBottomCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightTopCorner toView:self.rectView]]]];
            NvsBoundingType textType = NvsBoundingType_Text;
            if (self.currentCaption.captionStylePackageId && self.currentCaption.captionStylePackageId.length>0) {
                NSArray *textPoints = [self getPointsOfCaptionOnRectView:self.currentCaption boundingType:textType];
                [self.rectView setInnerPoints:[NSMutableArray arrayWithArray:textPoints]];
            } else {
                [self.rectView setInnerPoints:nil];
            }
            if (!self.isSelect) {
                self.isSelect = YES;
            } else {
                ///如果已选中就弹框修改文字
                ///If it is selected, pop the box to modify the text
                [self.textView becomeFirstResponder];
            }
        } else {
            ///如果点击的位置不在字幕上
            ///If the location of the click is not on the subtitles
            if ([NvsStreamingContext sharedInstance].getStreamingEngineState != NvsStreamingEngineState_Playback) {
                if (![NvTimelineUtils playbackTimeline:self.timeline startTime:self.liveWindowPanel.currentTime endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
                    NSLog(@"播放时间线失败！ Failed to play timeline!");
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

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    self.rectView.hidden = YES;
    __weak typeof(self)weakSelf = self;
    if (position > self.currentCaption.outPoint) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf seekTimeline:weakSelf.currentCaption.inPoint];
            if (weakSelf.currentCaption) {
                weakSelf.rectView.hidden = weakSelf.currentCaption?NO:YES;
                [weakSelf updateCaptionView:weakSelf.currentCaption];
                if (!weakSelf.rectView.hidden) {
                    [weakSelf getCurrentPosBorder:[weakSelf.streamingContext getTimelineCurrentPosition:timeline]];
                }
            }
        });
    }
}

- (void)didPlaybackStopped:(NvsTimeline *)timeline {
    int64_t currentTime = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    if (currentTime > self.currentCaption.outPoint || currentTime < self.currentCaption.inPoint) {
        self.rectView.hidden = YES;
    } else {
        self.rectView.hidden = self.selectStyle;
        if (self.modularStyleView.contextListView.hidden) {
            [self getCurrentPosBorder:currentTime];
        }
        
    }
    if (self.currentCaption) {
        if (!self.rectView.hidden) {
            [self updateCaptionViewNOSeek:self.currentCaption];
            if (self.modularStyleView.contextListView.hidden) {
                [self getCurrentPosBorder:currentTime];
            };
        }
    }
}

- (void)didTapLiveWindowStop{
    self.selectStyle = NO;
}

- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.currentCaption) {
            [weakSelf seekTimeline:weakSelf.currentCaption.inPoint];
            self.rectView.hidden = self.currentCaption?NO:YES;
            [self updateCaptionView:self.currentCaption];
            if (!self.rectView.hidden) {
                [self getCurrentPosBorder:[self.streamingContext getTimelineCurrentPosition:timeline]];
            }
        }else{
            [weakSelf seekTimeline:0];
            self.rectView.hidden = YES;
        }
    });
}


- (void)didSelecteStyle:(BOOL)selectStyle{
    self.selectStyle = selectStyle;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    UITextPosition * position = [textView positionFromPosition:textView.markedTextRange.start offset:0];
    if(position){
        return;
    }

    int64_t inPoint = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    int64_t duration = 5000000;
    if (inPoint + duration > self.timeline.duration) {
        duration = self.timeline.duration - inPoint;
    }
    if(!self.currentCaption){
        if (textView.text.length <= 0) {
            return;
        }
        [self addCaption:textView.text];
    }else{
        ///修改字幕
        ///Modify subtitles
        [self.currentCaption setText:textView.text];
        NvCaptionInfoModel *captionModel = (NvCaptionInfoModel *)[self.currentCaption getAttachment:@"captionInfoModel"];
        captionModel.text = textView.text;
        [self updateCaptionSpans];
        [self showCaption];
        self.captionInfo = (NvCaptionInfoModel *)[self.currentCaption getAttachment:@"captionInfoModel"];
        self.modularStyleVM.currentCaption = self.currentCaption;
        self.modularStyleVM.captionInfo = self.captionInfo;
        self.modularStyleVM.captionInfos = self.captionInfos;
    }
    
}

- (void)addCaption:(NSString *)text {
    ///添加字幕
    ///Add subtitles
    int64_t inPoint = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    int64_t duration = 5000000;
    if (inPoint + duration > self.timeline.duration) {
        duration = self.timeline.duration - inPoint;
    }
    NvCaptionInfoModel *captionModel = [NvCaptionInfoModel new];
    if(self.captionType == Normal) {
        self.currentCaption = [self.timeline addCaption:text inPoint:inPoint duration:duration captionStylePackageId:nil];
        captionModel.type = Normal;
    }else {
        self.currentCaption = [self.timeline addModularCaption:text inPoint:inPoint duration: duration];
        captionModel.type = Modular;
    }
    
    NSNumber *number = [[NSUserDefaults standardUserDefaults] valueForKey:@"defaultFontSize"];
    if (!number) {
        float defaultFontSize = [self.currentCaption getFontSize];
        number = [NSNumber numberWithFloat:defaultFontSize];
        [[NSUserDefaults standardUserDefaults] setValue:number forKey:@"defaultFontSize"];
    }
    captionModel.category = self.currentCaption.category;
    captionModel.text = text;
    captionModel.inPoint = inPoint;
    captionModel.outPoint = inPoint + duration;
    [self.currentCaption setAttachment:captionModel forKey:@"captionInfoModel"];
    [self.captionInfos addObject:captionModel];
    [self updateCaptionSpans];
    [self showCaption];
    self.captionInfo = (NvCaptionInfoModel *)[self.currentCaption getAttachment:@"captionInfoModel"];
    self.modularStyleVM.currentCaption = self.currentCaption;
    self.modularStyleVM.captionInfo = self.captionInfo;
    self.modularStyleVM.captionInfos = self.captionInfos;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    self.textChangeRange = NSMakeRange(range.location, range.length);
    self.replacementText = text;

    return YES;
}

- (void)updateCaptionSpans {
    if (self.replacementText.length == 0 && self.textChangeRange.length > 0) {
        [self deleteCaptionSpans:self.textChangeRange.location length:self.textChangeRange.length];
    }else{
        if([self.replacementText isEqualToString:@" "]) {
            return;
        }
        [self appendCaptionSpans:self.textChangeRange.location length:self.replacementText.length];
    }
}

- (void)appendCaptionSpans:(NSInteger)start length:(NSInteger)length {
    NSArray *spanArr = [self.currentCaption getTextSpanList];
    NSMutableArray *applyCaptionSpans = [NSMutableArray arrayWithArray:spanArr];
    for (NvsCaptionSpan *span in applyCaptionSpans) {
        if (span.start >= start) {
            span.start += length;
            span.end += length;
        }else if (span.end >= start && span.start < start){
            span.end += length;
        }
    }
    NvCaptionInfoModel *captionModel = (NvCaptionInfoModel *)[self.currentCaption getAttachment:@"captionInfoModel"];
    for (NvCaptionSpan *span in captionModel.textSpanArray) {
        if (span.start >= start) {
            //spans in the spanArr followed the caption span which would be appended
            span.start += length;
            span.end += length;
        }else if (span.end >= start && span.start < start){
            //the span in the spanArr ruled the caption span which would be appended
            //to apply the same span effects
            span.end += length;
        }
    }
    [self.currentCaption setTextSpanList:applyCaptionSpans];
}

- (void)deleteCaptionSpans:(NSInteger)start length:(NSInteger)length {
    NSArray *spanArr = [self.currentCaption getTextSpanList];
    NSMutableArray *applyCaptionSpans = [NSMutableArray arrayWithArray:spanArr];
    for (int i = 0; i < applyCaptionSpans.count; i++) {
        NvsCaptionSpan *span = applyCaptionSpans[i];
        if (span.end >= start+1 && span.start <= start){
            //the span in the spanArr ruled the caption span which would be appended
            //to apply the same span effects
            if (span.end - length <= span.start) {
                [applyCaptionSpans removeObject:span];
                i--;
            }else {
                span.end -= length;
            }
        }else if (span.start > start) {
            //spans in the spanArr followed the caption span which would be appended
            if (span.end - span.start > length) {
                span.start -= length;
                span.end -= length;
                
            }
        }
    }

    NvCaptionInfoModel *captionModel = (NvCaptionInfoModel *)[self.currentCaption getAttachment:@"captionInfoModel"];
    for (int i = 0; i < captionModel.textSpanArray.count; i++) {
        NvCaptionSpan *span = captionModel.textSpanArray[i];
        if (span.end >= start+1 && span.start <= start){
            //the span in the spanArr ruled the caption span which would be appended
            //to apply the same span effects
            if (span.end - length <= span.start) {
                [captionModel.textSpanArray removeObject:span];
                i--;
            }else {
                span.end -= length;
            }
        }else if (span.start > start) {
            //spans in the spanArr followed the caption span which would be appended
            if (span.end - span.start > length) {
                span.start -= length;
                span.end -= length;
                
            }
        }
    }
    [self.currentCaption setTextSpanList:applyCaptionSpans];
}

#pragma mark - 样式点击确定
///Style hit OK
- (void)styleOkClick {
    [self.navigationController popViewControllerAnimated:YES];
    if (self.popResetPos != nil) {
        self.popResetPos([self.streamingContext getTimelineCurrentPosition:self.timeline],self.currentCaption);
    }
    
}

- (void)moreStyleClick {
    NvMoreFilterViewController *vc = [[NvMoreFilterViewController alloc]init];
    vc.editModel = self.editMode;
    vc.type = ASSET_CAPTION_STYLE;
    vc.categoryId = 1;
    vc.kind = 0;
    vc.isCapture = NO;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

///更多气泡
///More bubbles
- (void)moreContextClick {
    [self popToMoreFilterController:NV_KIND_ID_CAPTION_CONTEXT type:ASSET_CAPTION_CONTEXT];
}

///更多花字
///More Modular caption
- (void)moreRendererClick {
    [self popToMoreFilterController:NV_KIND_ID_CAPTION_RENDER type:ASSET_CAPTION_RENDERER];
}

///更多字幕组合动画
///More captions combined animation
- (void)moreAnimationClick {
    [self popToMoreFilterController:NV_KIND_ID_CAPTION_ANIMATION type:ASSET_CAPTION_ANIMATION];
}

///更多字幕入动画
///More subtitles into the animation
- (void)moreInAnimationClick {
    [self popToMoreFilterController:NV_KIND_ID_CAPTION_INANIMATION type:ASSET_CAPTION_INANIMATION];
}

///更多字幕出动画
///More subtitles for out animation
- (void)moreOutAnimationClick {
    [self popToMoreFilterController:NV_KIND_ID_CAPTION_OUTANIMATION type:ASSET_CAPTION_OUTANIMATION];
}

- (void)popToMoreFilterController:(int)kindId type:(AssetType)assetType {
    NvMoreFilterViewController *vc = [[NvMoreFilterViewController alloc]init];
    vc.editModel = self.editMode;
    vc.type = assetType;
    vc.isCapture = NO;
    vc.categoryId = 2;
    vc.kind = kindId;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

// MARK: initSubviews
- (void)initSubViews {
    self.rectView = [[NvRectView alloc] init];
    self.rectView.delegate = self;
    self.rectView.layer.masksToBounds = YES;
    [self.liveWindowPanel.liveWindow addSubview:self.rectView];
    [self.rectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    self.isSelect = YES;
    
    self.modularStyleVM = [NvModularStyleVM new];
    self.modularStyleVM.editMode = self.editMode;
    self.modularStyleVM.delegate = self;
    self.modularStyleVM.timeline = self.timeline;
    self.modularStyleVM.currentCaption = self.currentCaption;
    self.modularStyleVM.captionInfo = self.captionInfo;
    self.modularStyleVM.captionInfos = self.captionInfos;
    
    self.textView = [[NvMenuTextView alloc] init];
    self.textView.delegate = self;
    self.textView.backgroundColor = [UIColor nv_colorWithHexString:@"#2F2F2F"];
    self.textView.textColor = [UIColor grayColor];
    [self.view addSubview:self.textView];
    if (self.currentCaption) {
        self.textView.text = [self.currentCaption getText];
    }
    UIView *styleView;
    if (self.captionType == Normal) {
        self.styleView = [[NvStyleView alloc] initWithStyleVM:self.modularStyleVM];
        self.styleView.delegate = self;
        [self.view addSubview:self.styleView];
        [self.styleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(SCREENWIDTH));
            make.left.right.bottom.equalTo(@0);
            make.height.equalTo(@(234*SCREENSCALE + INDICATOR));
        }];
        styleView = self.styleView;
    } else {
        self.rectView.rectLineColor = [UIColor colorWithRed:234/255.0 green:67/255.0 blue:89/255.0 alpha:1.0];
        self.modularStyleView = [[NvModularStyleView alloc] initWithStyleVM:self.modularStyleVM];
        [self.view addSubview:self.modularStyleView];
        self.modularStyleView.delegate = self;
        [self.modularStyleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(SCREENWIDTH));
            make.left.right.bottom.equalTo(@0);
            make.height.equalTo(@(234*SCREENSCALE + INDICATOR));
        }];
        styleView = self.modularStyleView;
    }
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(styleView.mas_top);
        make.left.equalTo(self.view.mas_left).offset(12.5*SCREENSCALE);
        make.right.equalTo(self.view.mas_right).offset(-12.5*SCREENSCALE);
        make.height.mas_equalTo(38*SCREENSCALE);
    }];
    
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"编辑样式" action:@selector(chooseEditStyleItem)];
    UIMenuController *menuCtl = [UIMenuController sharedMenuController];
    menuCtl.arrowDirection = UIMenuControllerArrowLeft;
    [menuCtl setMenuItems:[NSArray arrayWithObject:menuItem]];
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(chooseEditStyleItem))
    {
        if(self.textView.selectedRange.length>0)
        {
            return YES;
        }
    }
    
    if ([@"makeTextWritingDirectionRightToLeft:" isEqualToString:NSStringFromSelector(action)]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(textViewMakeTextWritingDirectionRightToLeft) object:nil];
        [self performSelector:@selector(textViewMakeTextWritingDirectionRightToLeft) withObject:nil afterDelay:0.2];
    }
    return NO;
}

- (void)textViewMakeTextWritingDirectionRightToLeft {
//    [self.modularStyleVM cancelAllSelected];
}

- (void)chooseEditStyleItem {
    if(self.captionType == Normal) {
        self.styleView.selectedIndex = 1;
    }else {
        [self.modularStyleView changeSelectedItem:1];
    }
}

- (void)addObservers {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    __weak typeof(self)weakSelf = self;
    [defaultCenter addObserverForName:UIKeyboardWillShowNotification object:nil queue:queue usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *userInfo = note.userInfo;
        double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        NSValue *frameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardRect = [frameValue CGRectValue];
        
        [UIView animateWithDuration:duration animations:^{
            if (weakSelf.captionType == Normal) {
                CGFloat titleHeight = [weakSelf.styleView getTitleHeight];
                CGFloat height = keyboardRect.size.height + titleHeight;
                [weakSelf.styleView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(weakSelf.view.mas_bottom).offset(-1.0 * height);
                }];
            }else{
                CGFloat titleHeight = [weakSelf.modularStyleView getTitleHeight];
                CGFloat height = keyboardRect.size.height + titleHeight;
                [weakSelf.modularStyleView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(weakSelf.view.mas_bottom).offset(-1.0 * height);
                }];
            }
        } completion:^(BOOL finished) {
            
        }];
    }];
    
    [defaultCenter addObserverForName:UIKeyboardWillHideNotification object:nil queue:queue usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *userInfo = note.userInfo;
        double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        if (!duration) {
            duration = 0.3;
        }
        [UIView animateWithDuration:duration animations:^{
            if (weakSelf.captionType == Normal) {
                [weakSelf.styleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@(SCREENWIDTH));
                    make.left.right.bottom.equalTo(@0);
                    make.height.equalTo(@(234*SCREENSCALE + INDICATOR));
                }];
            }else {
                [weakSelf.modularStyleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@(SCREENWIDTH));
                    make.left.right.bottom.equalTo(@0);
                    make.height.equalTo(@(234*SCREENSCALE + INDICATOR));
                }];
            }
        } completion:^(BOOL finished) {
            
        }];
    }];
    [defaultCenter addObserver:self selector:@selector(didSelectIndex:) name:@"NvPagerViewSelected" object:nil];
}

- (void)didSelectIndex:(NSNotification *)noti {
    NSNumber *num = noti.object;
    NSInteger index = [num integerValue];
    if (!self.currentCaption && index != 0) {
        [NvToast showInfoWithMessage:NvLocalString(@"Please add caption first", @"请先添加字幕")];
        return;
    }
    self.selectedIndex = index;
    NSString *text = [self.currentCaption getText];
    if(text.length > 0){
        if (index != 0) {
            [self.textView setEditable:NO];
            [self.textView becomeFirstResponder];
            NSRange selectedRange = self.textView.selectedRange;
            UITextRange *selectedTextRange = self.textView.selectedTextRange;
            self.textView.clearsOnInsertion = YES;
            self.textView.selectedRange = selectedRange;
            self.textView.selectedTextRange = selectedTextRange;
            if (self.captionType == Normal && index == 9) {
                ///字号界面逻辑判断
                ///Size interface logic judgment
                [self.modularStyleVM checkIsFrameCaption];
            }
        } else {
            self.textView.clearsOnInsertion = NO;
            [self.textView setEditable:YES];
            [self.textView becomeFirstResponder];
        }
    }else if (index != 0) {
        [NvToast showInfoWithMessage:NvLocalString(@"Please add caption first", @"请先添加字幕")];
    }
}

- (void)checkCanApply:(NSInteger)index {
    BOOL canApply = YES;
    BOOL selectedPartText = self.textView.selectedRange.length > 0 ? YES : NO;
    if (selectedPartText && self.captionType == Normal && (index == 4 || index == 6 || index == 7)) {
        canApply = NO;
    }else if (selectedPartText && self.captionType == Modular && (index == 2 || index == 3 || index == 6 || index == 8 || index == 9)) {
        canApply = NO;
    }
    if (!canApply) {
        [NvToast showInfoWithMessage:NvLocalString(@"Please uncheck the part", @"请取消部分选中")];
    }
}

- (NSRange)selectedPartialText {
    return self.textView.selectedRange;
}

#pragma mark - NvModularStyleVMDelegate
- (void)alertDisabledFontRatio:(BOOL)disable {
    if (disable) {
        [NvToast showInfoWithMessage:NvLocalString(@"FontRatio only Support selected caption", @"仅支持部分选中可调字号")];
    }
}

#pragma mark - NvStyleViewDelegate
- (void)fixedItemClicked {
    NSString *text = [self.currentCaption getText];
    if (!text) {
        self.textView.text = nil;
    }
    [self styleOkClick];
}

@end


