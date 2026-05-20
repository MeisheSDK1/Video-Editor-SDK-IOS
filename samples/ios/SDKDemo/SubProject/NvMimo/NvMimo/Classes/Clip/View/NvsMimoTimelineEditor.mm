//
//  NvsTimelineEditor.m
//  NvsTimelineEditor
//
//  Created by LionLee on 2017/8/29.
//  Copyright © 2017年 CDV. All rights reserved.
//

#import "NvsMimoTimelineEditor.h"
#import "NvsMultiThumbnailSequenceView.h"
#import "NvMimoTimelineUtils.h"
#import "NVHeader.h"
#import <math.h>

@interface NvsMimoTimelineEditorInfo()
@end

@implementation NvsMimoTimelineEditorInfo
@end


@interface NvsMimoTimelineEditor () <UIScrollViewDelegate>
@property (nonatomic, assign) int64_t timelineDuration;
@property(nonatomic, assign)CGFloat trimIn;
@property(nonatomic, assign)CGFloat trimOut;
@end

@implementation NvsMimoTimelineEditor {
    NvsMultiThumbnailSequenceView* sequenceView;
    UIImageView* timeAxis;
    UIImageView* timeAxis1;
    UIView *viewBack;
    double pointsPerMicrosecond;
    int64_t minDraggedTimeSpanDuration;
    bool changingTimelinePosFromScrollingClipReel;
    UIView *leftMask;
    UIView *rightMask;
    UIView *cropMask;   //中间截取// Intercept in the middle
    int64_t segmentation;
    int64_t ooooooo;
    UILabel *trimInLabel;
    UILabel *trimOutLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        
    }
    
    return self;
}

- (void)initInternal:(int64_t)time {
    CGRect frame = CGRectMake(0, self.bounds.origin.y, self.bounds.size.width , 64 * SCREANSCALE);
    pointsPerMicrosecond = (self.bounds.size.width - 78 * SCREANSCALE - 78 * SCREANSCALE)/time;
    UIView *bottomView = [[UIView alloc] initWithFrame:frame];
    bottomView.backgroundColor = [UIColor blackColor];
    [self addSubview:bottomView];
    sequenceView = [[NvsMultiThumbnailSequenceView alloc] initWithFrame:frame];
    sequenceView.thumbnailAspectRatio = 0.5;
    sequenceView.pointsPerMicrosecond = pointsPerMicrosecond;
    sequenceView.startPadding = 78 * SCREANSCALE;
    sequenceView.endPadding = 78 * SCREANSCALE;
    sequenceView.scrollEnabled = YES;
    [self addSubview:sequenceView];

    self.timelineDuration = 0;
    _canOverlapTimeSpan = false;
    _caneditTimeSpan = false;
    minDraggedTimeSpanDuration = 1000000;
    _timelinePosition = 0;
    changingTimelinePosFromScrollingClipReel = false;
    sequenceView.delegate = self;
    
    leftMask = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.origin.y, sequenceView.startPadding, 64 * SCREANSCALE)];
    leftMask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    leftMask.userInteractionEnabled = NO;
    [self addSubview:leftMask];
    
    rightMask = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width - sequenceView.endPadding, self.bounds.origin.y,  sequenceView.endPadding, 64 * SCREANSCALE)];
    rightMask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    rightMask.userInteractionEnabled = NO;
    [self addSubview:rightMask];
    
    cropMask = [[UIView alloc] initWithFrame:CGRectMake(sequenceView.startPadding, self.bounds.origin.y, self.bounds.size.width - sequenceView.startPadding - sequenceView.endPadding, 64 * SCREANSCALE)];
    cropMask.layer.borderWidth = 2.f*SCREANSCALE;
    cropMask.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#0F6CFF"].CGColor;
    cropMask.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
    cropMask.userInteractionEnabled = NO;
    [self addSubview:cropMask];
    
    trimInLabel = [[UILabel alloc] initWithFrame:CGRectMake(sequenceView.startPadding, self.bounds.origin.y +64 * SCREANSCALE, 40,20)];
    trimInLabel.backgroundColor = [UIColor clearColor];
    trimInLabel.textColor = [UIColor whiteColor];
    trimInLabel.font = [UIFont systemFontOfSize:10.f];
    trimInLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:trimInLabel];
    
    trimOutLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width  - sequenceView.endPadding - 40, self.bounds.origin.y +64 * SCREANSCALE, 40,20)];
    trimOutLabel.backgroundColor = [UIColor clearColor];
    trimOutLabel.textColor = [UIColor whiteColor];
    trimOutLabel.font = [UIFont systemFontOfSize:10.f];
    trimOutLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:trimOutLabel];
        
    NvShotModel *copyModel = [self.model copy];
    self.trimIn = copyModel.trimIn;
    CGFloat duration;
    if (self.model.speed.count>0) {
        duration = [NvMimoTimelineUtils requiredDurationForShotModel:self.model];
        if (!self.model.isImage && duration > self.model.assetDuration) {
            duration = self.model.assetDuration;
        }
    }else {
        duration = copyModel.trimOut;
    }
    self.trimOut = duration;
    
    sequenceView.contentOffset = CGPointMake(self.trimIn*pointsPerMicrosecond, 0);
}

#pragma mark - setter & getter
- (void)setTrimIn:(CGFloat)trimIn {
    _trimIn = trimIn;
    trimInLabel.text = [NvMimoUtils convertTimecode:trimIn];
}

- (void)setTrimOut:(CGFloat)trimOut {
    _trimOut = trimOut;
    trimOutLabel.text = [NvMimoUtils convertTimecode:trimOut];
}

- (void)setTimelinePosition:(int64_t)timelinePosition {
    _timelinePosition = timelinePosition;
    if (!changingTimelinePosFromScrollingClipReel){
        segmentation = timelinePosition/2;
        [self initInternal:timelinePosition];
        
    }
}

#pragma mark - 初始化timelineEditor
- (void)initTimelineEditor:(NSArray*) timelineEditorInfos timelineDuration:(int64_t)timelineDuration {
    if (timelineEditorInfos == nil)
        return;
    NSMutableArray* descArray = [NSMutableArray array];
    for (int i=0; i<timelineEditorInfos.count; i++) {
        NvsMimoTimelineEditorInfo* info = (NvsMimoTimelineEditorInfo*)timelineEditorInfos[i];
        NvsThumbnailSequenceDesc* desc = [[NvsThumbnailSequenceDesc alloc] init];
        desc.mediaFilePath = info.mediaFilePath;
        desc.inPoint = info.inPoint;
        desc.outPoint = info.outPoint;
        desc.trimIn = info.trimIn;
        desc.trimOut = info.trimOut;
        desc.stillImageHint = info.stillImageHint;
        [descArray addObject:desc];
    }
    _timelinePosition = 0;
    sequenceView.descArray = descArray;
    self.timelineDuration = timelineDuration;
}

- (CGFloat)getTimelineEditorWidth{
    return sequenceView.contentSize.width;
}

#pragma mark - scroll delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"-----%@", [NSThread currentThread]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self resetCropWithContentoffsetOfScrollview:scrollView];
    });
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"-----%@", [NSThread currentThread]);
    if (!decelerate) {
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
            [self scrollViewDidEndScroll];
        }else {
            [self resetCropWithContentoffsetOfScrollview:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"-----%@", [NSThread currentThread]);
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [self scrollViewDidEndScroll];
    }else {
        [self resetCropWithContentoffsetOfScrollview:scrollView];
    }
}

- (void)scrollViewDidEndScroll {
    NSLog(@"-----%@", [NSThread currentThread]);
    if (self.delegate && [self.delegate respondsToSelector:@selector(timelineEditorDidEndScroll:)]) {
        [self.delegate timelineEditorDidEndScroll:self];
    }
}

//根据scrollView 偏移量计算裁剪范围
// Calculate the clipping range based on the scroller offset
- (void)resetCropWithContentoffsetOfScrollview:(UIScrollView *)scrollView {
    self.trimIn = scrollView.contentOffset.x/pointsPerMicrosecond;
    self.trimOut = (scrollView.contentOffset.x + cropMask.frame.size.width)/pointsPerMicrosecond;
    if([self.delegate respondsToSelector:@selector(timelineEditor:trimIn:trimOut:)]){
        [self.delegate timelineEditor:self trimIn:self.trimIn trimOut:self.trimOut];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint tp = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, tp)) {
                view = subView;
            }
        }
    }
    return view;
}



@end
