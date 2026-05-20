//
//  NvsTimelineEditor.m
//  NvsTimelineEditor
//
//  Created by LionLee on 2017/8/29.
//  Copyright © 2017年 CDV. All rights reserved.
//

#import "NvTimelineEditor.h"
#import "NvsMultiThumbnailSequenceView.h"
#import "UIView+Dimension.h"
#import <NvSDKCommon/NvUtils.h>
#import <Masonry/Masonry.h>
#import <math.h>


@interface NvTimelineEditorInfo()
@end

@implementation NvTimelineEditorInfo
@end


@interface NvTimelineEditor () <NvsTimelineTimeSpanDelegate, UIScrollViewDelegate>

@end

@implementation NvTimelineEditor {
    NvsMultiThumbnailSequenceView* sequenceView;
    UIView *maskTrimIn;
    UIView *maskTrimOut;
    UIView *timeAxisArea;
    UIImageView* timeAxis;
    NSMutableArray* timeSpanItemArray;
    double pointsPerMicrosecond;
    int64_t minDraggedTimeSpanDuration;
    int64_t minDraggedTimeSpanStickerDuration;
    NvsTimelineTimeSpan* selectedTimeSpanItem;
    bool changingTimelinePosFromScrollingClipReel;
    UIView *musicBackgroundColorView;
    UIView *musicBackground;
    UIView *coverView;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (instancetype)init
{
    self = [super init];
    if (self)
        [self initInternal];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
        [self initInternal];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
        [self initInternal];
    
    return self;
}

- (void)initInternal {
    [self setBackgroundColor:[UIColor blackColor]];
    CGFloat width = self.bounds.size.width;
    pointsPerMicrosecond = width/20/1000000;
    CGRect frame = self.bounds;
    sequenceView = [[NvsMultiThumbnailSequenceView alloc] initWithFrame:frame];
    sequenceView.clipsToBounds = YES;
    sequenceView.thumbnailAspectRatio = 0.5;
    sequenceView.pointsPerMicrosecond = pointsPerMicrosecond;
    sequenceView.startPadding = 0;
    sequenceView.endPadding = 0;
    [self addSubview:sequenceView];
    maskTrimIn = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, frame.size.height)];
    maskTrimIn.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.5];
    maskTrimIn.hidden = YES;
    [self addSubview:maskTrimIn];
    maskTrimOut = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, frame.size.height)];
    maskTrimOut.backgroundColor = maskTrimIn.backgroundColor;
    maskTrimOut.hidden = YES;
    [self addSubview:maskTrimOut];
    coverView = [[UIView alloc] initWithFrame:self.bounds];
    coverView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#BFBD10E0"];
    [self addSubview:coverView];
    coverView.hidden = YES;
    timeAxisArea = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 2 - 15, -3 * SCREENSCALE, 30, self.height + 6*SCREENSCALE)];
    [self addSubview:timeAxisArea];
    timeAxis = [[UIImageView alloc] initWithFrame:CGRectMake(timeAxisArea.width / 2, 0, 6, timeAxisArea.height)];
    timeAxis.image = NvImageNamed(@"NvSliderBar");

    [timeAxisArea addSubview:timeAxis];
    UIPanGestureRecognizer *timeAxisPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTimeAxisPan:)];
    [timeAxisArea addGestureRecognizer:timeAxisPan];
    self.timelineDuration = 0;
    timeSpanItemArray = [NSMutableArray array];
    _canOverlapTimeSpan = false;
    _caneditTimeSpan = false;
    minDraggedTimeSpanDuration = 3000000;
    minDraggedTimeSpanStickerDuration = 14 / pointsPerMicrosecond;
    selectedTimeSpanItem = nil;
    _timelinePosition = 0;
    changingTimelinePosFromScrollingClipReel = false;
    sequenceView.delegate = self;
}

- (void)showCoverView:(BOOL)isShow {
    coverView.hidden = !isShow;
}

- (void)handleTimeAxisPan:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self];
        float xPos = timeAxisArea.centerX + translation.x;
        if (xPos < 0)
            xPos = 0;
        if (xPos > self.width - 3)
            xPos = self.width - 3;
        timeAxisArea.centerX = xPos;
        [gesture setTranslation:CGPointZero inView:self];
        
        BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor:dragTimeAxis:)];
        if (isResponds)
            [self.delegate timelineEditor:self dragTimeAxis:(int64_t)floor(xPos / self.width * _timelineDuration + 0.5)];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditorDragTimeAxisEnded)];
        if (isResponds) {
            [self.delegate timelineEditorDragTimeAxisEnded];
        }
    }
}

- (void)setTimelinePosition:(int64_t)timelinePosition {
    _timelinePosition = timelinePosition;
    if (!changingTimelinePosFromScrollingClipReel)
        sequenceView.contentOffset = CGPointMake(_timelinePosition * pointsPerMicrosecond, sequenceView.contentOffset.y);
}

- (void)initTimelineEditor:(NSArray*) timelineEditorInfos timelineDuration:(int64_t)timelineDuration {
    if (timelineEditorInfos == nil)
        return;
    NSMutableArray* descArray = [NSMutableArray array];
    for (int i=0; i<timelineEditorInfos.count; i++) {
        NvTimelineEditorInfo* info = (NvTimelineEditorInfo*)timelineEditorInfos[i];
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
    if (_isMusic) {
        if (!musicBackground) {
            musicBackgroundColorView = [[UIView alloc] init];
            [sequenceView addSubview:musicBackgroundColorView];
            musicBackground = [[UIView alloc] init];
            [sequenceView addSubview:musicBackground];
        }
        CGFloat startX = [sequenceView mapXFromTimelinePos:0];
        CGFloat endX = [sequenceView mapXFromTimelinePos:_timelineDuration];
        musicBackgroundColorView.frame = CGRectMake(startX, 2.5, endX - startX, sequenceView.frame.size.height - 5);
        musicBackgroundColorView.backgroundColor = [UIColor colorWithRed:32.0 / 255 green:32.0 / 255 blue:32.0 / 255 alpha:1];
        musicBackground.frame = CGRectMake(startX + 15, 0, endX - startX - 30, sequenceView.frame.size.height);
    } else {
        if (musicBackground) {
            [musicBackgroundColorView removeFromSuperview];
            [musicBackground removeFromSuperview];
        }
        musicBackgroundColorView = nil;
        musicBackground = nil;
    }
}

- (NvsTimelineTimeSpan *)addTimeSpan:(int64_t)inPoint outPoint:(int64_t)outPoint {
    [self deleteAllTimeSpan];
    if (inPoint >= outPoint)
        return nil;
    
    // Create time span Item
    NvsTimelineTimeSpan* timeSpanItem = [self createTimeSpanItem];
    if (timeSpanItem == nil)
        return nil;
//    bool add = true;
//    if (outPoint <= [sequenceView mapTimelinePosFromX:0])
//        add = false;
//    if (inPoint >= [sequenceView mapTimelinePosFromX:sequenceView.bounds.size.width])
//        add = false;
//    if (add)
        [sequenceView addSubview:timeSpanItem];
    
    timeSpanItem.inPoint = inPoint;
    timeSpanItem.outPoint = outPoint;
    selectedTimeSpanItem = timeSpanItem;
    
    return timeSpanItem;
}


- (NvsTimelineTimeSpan *)getSelectedTimeSpan {
    
    return selectedTimeSpanItem;
}

- (void)scaleSequence:(double)scaleFactor withAnchor:(CGFloat)anchorX {
    [sequenceView scale:scaleFactor withAnchor:anchorX];
    pointsPerMicrosecond = sequenceView.pointsPerMicrosecond;
    selectedTimeSpanItem.pointsPerMicrosecond = sequenceView.pointsPerMicrosecond;
    minDraggedTimeSpanStickerDuration = 14 / pointsPerMicrosecond;
    
    if (_isMusic) {
        CGFloat startX = [sequenceView mapXFromTimelinePos:0] + sequenceView.contentOffset.x;
        CGFloat endX = [sequenceView mapXFromTimelinePos:_timelineDuration] + sequenceView.contentOffset.x;
        musicBackgroundColorView.frame = CGRectMake(startX, 2.5, endX - startX, sequenceView.frame.size.height - 5);
        musicBackgroundColorView.backgroundColor = [UIColor colorWithRed:32.0 / 255 green:32.0 / 255 blue:32.0 / 255 alpha:1];
        musicBackground.frame = CGRectMake(startX + 15, 0, endX - startX - 30, sequenceView.frame.size.height);
    }
    
    [self updateMaskTrimInOut];
}

- (float)getSequenceViewXPos {
    return sequenceView.contentOffset.x;
}

- (void)setSequenceViewEnabled:(BOOL)enabled {
    sequenceView.scrollEnabled = enabled;
}

- (void)hideTimeruler {
    timeAxisArea.hidden = YES;
}

- (double)getPointsPerMicrosecond {
    return sequenceView.pointsPerMicrosecond;
}

- (void)setPointsPerMicrosecond:(double)ppms {
    pointsPerMicrosecond = ppms;
    sequenceView.pointsPerMicrosecond = pointsPerMicrosecond;
    selectedTimeSpanItem.pointsPerMicrosecond = sequenceView.pointsPerMicrosecond;
    minDraggedTimeSpanStickerDuration = 14 / pointsPerMicrosecond;
}

- (void)setSequenceViewBounces:(BOOL)bounces {
    sequenceView.bounces = NO;
}

- (void) deleteAllTimeSpan
{
    if (selectedTimeSpanItem.superview != nil)
        [selectedTimeSpanItem removeFromSuperview];
    selectedTimeSpanItem = nil;

}

// Find the first time span object whose in point >= timestamp and return its index in the array
// return array.length if we can't find one
- (NSUInteger) findTimeSpanLowerBound:(int64_t)timestamp
{
    NSUInteger len = timeSpanItemArray.count;
    if (len == 0)
        return 0;
    
    if (timestamp <= ((NvsTimelineTimeSpan*)timeSpanItemArray[0]).inPoint)
        return 0;
    else if (timestamp > ((NvsTimelineTimeSpan*)timeSpanItemArray[len - 1]).inPoint)
        return len;
    
    // Use binaray search
    NSUInteger lowestIdx = 0, highestIdx = len - 1, i = 0;
    while (lowestIdx <= highestIdx) {
        i = floor((lowestIdx + highestIdx) / 2);
        int64_t t = ((NvsTimelineTimeSpan*)timeSpanItemArray[i]).inPoint;
        if (t == timestamp) {
            while (i > 0 && ((NvsTimelineTimeSpan*)timeSpanItemArray[i - 1]).inPoint == timestamp)
                --i;
            
            return i;
        } else if (t < timestamp) {
            lowestIdx = i + 1;
        } else {
            highestIdx = i - 1;
        }
    }
    
    if (((NvsTimelineTimeSpan*)timeSpanItemArray[i]).inPoint < timestamp)
        return i + 1;
    else
        return i;
}

- (NvsTimelineTimeSpan*) createTimeSpanItem
{
    NvsTimelineTimeSpan* timeSpan = [[NvsTimelineTimeSpan alloc] init];
    timeSpan.editable = _caneditTimeSpan;
    timeSpan.padding = sequenceView.startPadding;
    timeSpan.pointsPerMicrosecond = pointsPerMicrosecond;
    timeSpan.delegate = self;
    return timeSpan;
}

// Return an time span item array which contain the current timeline position
- (NSArray*) spanItemHitTest
{
    NSMutableArray *result = [NSMutableArray array];
    NvsTimelineTimeSpan* timeSpanItem = nil;
    
    if (_canOverlapTimeSpan) {
        for (int i = 0; i < timeSpanItemArray.count; ++i) {
            if (_timelinePosition >= ((NvsTimelineTimeSpan*)timeSpanItemArray[i]).inPoint) {
                bool sel = false;
                if (i == timeSpanItemArray.count-1) {
                    if (_timelinePosition <= ((NvsTimelineTimeSpan*)timeSpanItemArray[i]).outPoint)
                        sel = true;
                } else {
                    if (_timelinePosition < ((NvsTimelineTimeSpan*)timeSpanItemArray[i]).outPoint)
                        sel = true;
                }
                if (sel)
                    [result addObject:(NvsTimelineTimeSpan*)timeSpanItemArray[i]];
            }
        }
        return result;
    }
    
    NSUInteger idx = [self findTimeSpanLowerBound:_timelinePosition];
    if (idx != timeSpanItemArray.count) {
        if (_timelinePosition == ((NvsTimelineTimeSpan*)timeSpanItemArray[idx]).inPoint) {
            [result addObject:(NvsTimelineTimeSpan*)timeSpanItemArray[idx]];
        } else if (idx > 0) {
            timeSpanItem = (NvsTimelineTimeSpan*)timeSpanItemArray[idx - 1];
            if (_timelinePosition >= timeSpanItem.inPoint && _timelinePosition < timeSpanItem.outPoint)
                [result addObject:timeSpanItem];
        }
    } else if (timeSpanItemArray.count != 0) {
        timeSpanItem = (NvsTimelineTimeSpan*)timeSpanItemArray[timeSpanItemArray.count - 1];
        if (_timelinePosition >= timeSpanItem.inPoint && _timelinePosition < timeSpanItem.outPoint)
            [result addObject:timeSpanItem];
    }
    
    return result;
}

#pragma mark - timeSpan handles

- (void)timeSpan:(id)timeSpan dragHandleStarted:(UIView*)timeSpanItem isLeftHandle:(bool)isLeftHandle
{
    NvsTimelineTimeSpan *item = (NvsTimelineTimeSpan *)timeSpan;
    int64_t timestamp;
    if (isLeftHandle)
        timestamp = item.inPoint;
    else
        timestamp = item.outPoint;
    if (timestamp < 0)
        timestamp = 0;
    if (timestamp > self.timelineDuration)
        timestamp = self.timelineDuration-1;
    
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor:dragHandleStarted:isInPoint:)];
    if (isResponds)
        [self.delegate timelineEditor:self dragHandleStarted:timestamp isInPoint:isLeftHandle];
}

- (void)timeSpan:(id)timeSpan draggingHandle:(UIView*)timeSpanItem isLeftHandle:(bool)isLeftHandle xOffset:(double)xOffset
{
    NvsTimelineTimeSpan *item = (NvsTimelineTimeSpan *)timeSpan;
    NSUInteger idx;
    if (isLeftHandle) {
        int64_t newInPoint = floor(item.inPoint + xOffset / pointsPerMicrosecond);
        newInPoint = fmax(newInPoint, 0);
        newInPoint = fmin(newInPoint, item.outPoint - 1);
        
        if (item.outPoint - newInPoint < minDraggedTimeSpanDuration)
            newInPoint = item.outPoint - minDraggedTimeSpanDuration;
        
        if (!_canOverlapTimeSpan) {
            idx = [timeSpanItemArray indexOfObject:timeSpanItem];
            if (idx > 0)
                newInPoint = fmax(newInPoint, ((NvsTimelineTimeSpan*)timeSpanItemArray[idx - 1]).outPoint);
        }
        if (newInPoint < 0)
            newInPoint = 0;
        if (newInPoint > self.timelineDuration)
            newInPoint = self.timelineDuration-1;
        item.inPoint = newInPoint;
        
        BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor:draggingHandle:isInPoint:)];
        if (isResponds)
            [self.delegate timelineEditor:self draggingHandle:newInPoint isInPoint:true];
    } else {
        int64_t newOutPoint = floor(item.outPoint + xOffset / pointsPerMicrosecond);
        newOutPoint = fmax(newOutPoint, item.inPoint + 1);
        newOutPoint = fmin(newOutPoint, self.timelineDuration);
        
        if (newOutPoint - item.inPoint < minDraggedTimeSpanDuration)
            newOutPoint = item.inPoint + minDraggedTimeSpanDuration;
        
        if (!_canOverlapTimeSpan) {
            idx = [timeSpanItemArray indexOfObject:timeSpanItem];
            if ([timeSpanItemArray containsObject:timeSpanItem] && idx < timeSpanItemArray.count - 1)
                newOutPoint = fmin(newOutPoint, ((NvsTimelineTimeSpan*)timeSpanItemArray[idx + 1]).inPoint);
        }
        if (newOutPoint < 0)
            newOutPoint = 0;
        if (newOutPoint > self.timelineDuration)
            newOutPoint = self.timelineDuration-1;
        item.outPoint = newOutPoint;
        
        BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor:draggingHandle:isInPoint:)];
        if (isResponds)
            [self.delegate timelineEditor:self draggingHandle:newOutPoint isInPoint:false];
    }
    
    [self updateMaskTrimInOut];
}

- (void)timeSpan:(id)timeSpan dragHandleEnded:(UIView*)timeSpanItem isLeftHandle:(bool)isLeftHandle
{
    NvsTimelineTimeSpan *item = (NvsTimelineTimeSpan *)timeSpan;
    if (isLeftHandle)
        _timelinePosition = item.inPoint;
    else
        _timelinePosition = item.outPoint - 1;
    
    int64_t timestamp;
    if (isLeftHandle)
        timestamp = item.inPoint;
    else
        timestamp = item.outPoint;
    if (timestamp < 0)
        timestamp = 0;
    if (timestamp > self.timelineDuration)
        timestamp = self.timelineDuration-1;
    
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor:dragHandleEnded:isInPoint:)];
    if (isResponds)
        [self.delegate timelineEditor:self dragHandleEnded:timestamp isInPoint:isLeftHandle];
}

#pragma mark - scroll delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateMaskTrimInOut];

    if (!scrollView.dragging)
        return;
    changingTimelinePosFromScrollingClipReel = true;
    _timelinePosition = floor(sequenceView.contentOffset.x / pointsPerMicrosecond);
    if (_timelinePosition < 0)
        _timelinePosition = 0;
    if (_timelinePosition > self.timelineDuration)
        _timelinePosition = self.timelineDuration-1;
    changingTimelinePosFromScrollingClipReel = false;
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor: dragScrollingTimeline:)];
    if (isResponds)
        [self.delegate timelineEditor:self dragScrollingTimeline:_timelinePosition];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate)
        return;
    
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor: dragScrollTimelineEnded:)];
    if (isResponds)
        [self.delegate timelineEditor:self dragScrollTimelineEnded:_timelinePosition];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor: dragScrollTimelineEnded:)];
    if (isResponds)
        [self.delegate timelineEditor:self dragScrollTimelineEnded:_timelinePosition];
}

- (void)updateMaskTrimInOut {
//    if (selectedTimeSpanItem) {
//        maskTrimIn.frame = CGRectMake(-sequenceView.contentOffset.x, 0, selectedTimeSpanItem.x, self.height);
//        maskTrimOut.frame = CGRectMake(selectedTimeSpanItem.x + selectedTimeSpanItem.width - sequenceView.contentOffset.x, 0, [sequenceView mapXFromTimelinePos:_timelineDuration] + sequenceView.contentOffset.x - selectedTimeSpanItem.x - selectedTimeSpanItem.width, self.height);
//        maskTrimIn.hidden = NO;
//        maskTrimOut.hidden = NO;
//    }
}

- (CGFloat)getTimelineEditorWidth{
    return  sequenceView.contentSize.width;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    sequenceView.frame = self.bounds;
    sequenceView.startPadding = 0;
    sequenceView.endPadding = 0;
    timeAxisArea.frame = CGRectMake(-15, -3 * SCREENSCALE, 30, 31*SCREENSCALE);
    
    for (NvsTimelineTimeSpan* timeSpan in timeSpanItemArray) {
        timeSpan.padding = sequenceView.startPadding;
        [timeSpan updateFrame];
    }
}

- (void)setProgressValue:(float)value {
    float xPos = floor(self.width * value + 0.5);
    if (xPos < 0)
        xPos = 0;
    if (xPos > self.width - 3)
        xPos = self.width - 3;
    timeAxisArea.centerX = xPos;
}

@end
