//
//  NvsPSTimelineEditor.m
//  NvsPSTimelineEditor
//
//  Created by LionLee on 2017/8/29.
//  Copyright © 2017年 CDV. All rights reserved.
//

#import "NvsPSTimelineEditor.h"
#import "NvsMultiThumbnailSequenceView.h"
#import <math.h>
#import "NvUtils.h"

@interface NvsPSTimelineEditorInfo()
@end

@implementation NvsPSTimelineEditorInfo
@end


@interface NvsPSTimelineEditor () <NvsPSTimelineTimeSpanDelegate, UIScrollViewDelegate>
@property (nonatomic, assign) int64_t timelineDuration;

@end

@implementation NvsPSTimelineEditor {
    NvsMultiThumbnailSequenceView* sequenceView;
    UIImageView* timeAxis;
    UIImageView* timeAxis1;
    UIView *viewBack;
    NSMutableArray* timeSpanItemArray;
    double pointsPerMicrosecond;
    int64_t minDraggedTimeSpanDuration;
    NvsPSTimelineTimeSpan* selectedTimeSpanItem;
    bool changingTimelinePosFromScrollingClipReel;
    UIView *leftMask;
    UIView *rightMask;
    int64_t segmentation;
    int64_t ooooooo;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        
    }
    
    return self;
}

- (void)initInternal:(int64_t)time {
    CGRect frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, 64 * SCREENSCALE);
    pointsPerMicrosecond = frame.size.width/time;
    sequenceView = [[NvsMultiThumbnailSequenceView alloc] initWithFrame:frame];
    sequenceView.thumbnailAspectRatio = 0.5;
    sequenceView.pointsPerMicrosecond = pointsPerMicrosecond;
    sequenceView.startPadding = 0;
    sequenceView.endPadding = 350 * SCREENSCALE;
    [self addSubview:sequenceView];
    if (self.type == 0) {
        
    }else{
        sequenceView.scrollEnabled = NO;
        timeAxis = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2-2, -3, 4, frame.size.height+6)];
        timeAxis.userInteractionEnabled = YES;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [timeAxis addGestureRecognizer:pan];
        [self addSubview:timeAxis];

        viewBack = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30 * SCREENSCALE, 65 *SCREENSCALE)];
        UIPanGestureRecognizer *pan1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        viewBack.backgroundColor = UIColor.clearColor;
        [viewBack addGestureRecognizer:pan1];
        [self addSubview:viewBack];
        
        timeAxis1 = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2-2, -3, 4, frame.size.height+6)];
        timeAxis1.userInteractionEnabled = YES;
        UITapGestureRecognizer *Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tap:)];
        [timeAxis1 addGestureRecognizer:Tap];
        timeAxis1.image = NvImageNamed(@"NvTailoring_on1");
        [self addSubview:timeAxis1];
    }

    self.timelineDuration = 0;
    timeSpanItemArray = [NSMutableArray array];
    _canOverlapTimeSpan = false;
    _caneditTimeSpan = false;
    minDraggedTimeSpanDuration = 30 * SCREENSCALE / pointsPerMicrosecond;
    selectedTimeSpanItem = nil;
    _timelinePosition = 0;
    changingTimelinePosFromScrollingClipReel = false;
    sequenceView.delegate = self;
    
    leftMask = [[UIView alloc]init];
    leftMask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self addSubview:leftMask];
    
    rightMask = [[UIView alloc]init];
    rightMask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self addSubview:rightMask];
}

- (void)Tap:(UIPanGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:timeAxis1];
    if (point.x > 0 && point.x < timeAxis1.bounds.size.width/2) {
        int64_t dddd = segmentation - 2/pointsPerMicrosecond;
        if (segmentation == self.timelineDuration) {
            dddd = segmentation - 6/pointsPerMicrosecond;
        }
        ooooooo = dddd;
        timeAxis.frame = CGRectMake(dddd * pointsPerMicrosecond, -(90* SCREENSCALE - 64* SCREENSCALE)/2 + 5 * SCREENSCALE, 10* SCREENSCALE, self.bounds.size.height - 10* SCREENSCALE);
        if (timeAxis.frame.origin.x <= 0) {
            timeAxis.frame = CGRectMake(0, -(90* SCREENSCALE - 64* SCREENSCALE)/2* SCREENSCALE + 5 * SCREENSCALE, 10* SCREENSCALE, self.bounds.size.height - 10* SCREENSCALE);
            ooooooo = 0.0;
        }
    }else if(point.x > timeAxis1.bounds.size.width/2 && point.x < timeAxis1.bounds.size.width){
        int64_t dddd = segmentation + 2/pointsPerMicrosecond;
        ooooooo = dddd;
        timeAxis.frame = CGRectMake(dddd * pointsPerMicrosecond, -(90* SCREENSCALE - 64* SCREENSCALE)/2 + 5 * SCREENSCALE, 10* SCREENSCALE, self.bounds.size.height - 10* SCREENSCALE);
        if (timeAxis.frame.origin.x >= sequenceView.frame.size.width - timeAxis.frame.size.width){
            timeAxis.frame = CGRectMake(sequenceView.frame.size.width - timeAxis.frame.size.width, -(90* SCREENSCALE - 64* SCREENSCALE)/2* SCREENSCALE + 5 * SCREENSCALE, 10* SCREENSCALE, self.bounds.size.height - 10* SCREENSCALE);
            ooooooo = self.timelineDuration;
        }
    }
    
    [self.delegate timelineEditor:self handlePan:ooooooo];
    timeAxis1.center = CGPointMake(timeAxis.center.x, timeAxis1.center.y);
    segmentation = ooooooo;
}

- (void)setTimelinePosition:(int64_t)timelinePosition {
    _timelinePosition = timelinePosition;
    if (!changingTimelinePosFromScrollingClipReel){
        segmentation = timelinePosition/2;
        [self initInternal:timelinePosition];
        
    }
}

- (void)initTimelineEditor:(NSArray*) timelineEditorInfos timelineDuration:(int64_t)timelineDuration {
    if (timelineEditorInfos == nil)
        return;
    NSMutableArray* descArray = [NSMutableArray array];
    for (int i=0; i<timelineEditorInfos.count; i++) {
        NvsPSTimelineEditorInfo* info = (NvsPSTimelineEditorInfo*)timelineEditorInfos[i];
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

- (NvsPSTimelineTimeSpan *)addTimeSpan:(int64_t)inPoint outPoint:(int64_t)outPoint {
    if (inPoint >= outPoint)
        return nil;
    
    NSUInteger insertIndex = timeSpanItemArray.count;
    if (!_canOverlapTimeSpan && timeSpanItemArray.count != 0) {
        // Find a proper place to insert this time span object
        insertIndex = [self findTimeSpanLowerBound:inPoint];
        if (insertIndex != timeSpanItemArray.count) {
            if (((NvsPSTimelineTimeSpan*)timeSpanItemArray[insertIndex]).inPoint == inPoint) {
                return nil;
            } else if (outPoint > ((NvsPSTimelineTimeSpan*)timeSpanItemArray[insertIndex]).inPoint) {
                return nil;
            } else if (insertIndex > 0) {
                if (inPoint < ((NvsPSTimelineTimeSpan*)timeSpanItemArray[insertIndex - 1]).outPoint &&
                    outPoint > ((NvsPSTimelineTimeSpan*)timeSpanItemArray[insertIndex - 1]).inPoint)
                {
                    return nil;
                }
            }
        } else {
            if (inPoint < ((NvsPSTimelineTimeSpan*)timeSpanItemArray[timeSpanItemArray.count - 1]).outPoint &&
                outPoint > ((NvsPSTimelineTimeSpan*)timeSpanItemArray[timeSpanItemArray.count - 1]).inPoint)
            {
                return nil;
            }
        }
    }
    
    // Create time span Item
    NvsPSTimelineTimeSpan* timeSpanItem = [self createTimeSpanItem];
    if (timeSpanItem == nil)
        return nil;
    bool add = true;
    if (outPoint <= [sequenceView mapTimelinePosFromX:0])
        add = false;
    if (inPoint >= [sequenceView mapTimelinePosFromX:sequenceView.bounds.size.width])
        add = false;
    if (add)
        [self addSubview:timeSpanItem];
    
    timeSpanItem.inPoint = inPoint;
    timeSpanItem.outPoint = outPoint;
    
    // Insert time span
    [timeSpanItemArray insertObject:timeSpanItem atIndex:insertIndex];
    
    [self updateSelectedItem];
    
    return timeSpanItem;
}

- (void) selectTimeSpan:(NvsPSTimelineTimeSpan*)timeSpanItem
{
    if (timeSpanItem == selectedTimeSpanItem)
        return;
    if (selectedTimeSpanItem != nil)
        selectedTimeSpanItem.selected = false;
    if (timeSpanItem != nil)
        timeSpanItem.selected = true;
    selectedTimeSpanItem = timeSpanItem;
}

- (void) deleteSelectedTimeSpan
{
    if (selectedTimeSpanItem == nil)
        return;
    
    NSUInteger idx = [timeSpanItemArray indexOfObject:selectedTimeSpanItem];

    if ([timeSpanItemArray containsObject:selectedTimeSpanItem])
        [timeSpanItemArray removeObjectAtIndex:idx];
    
    if (selectedTimeSpanItem.superview != nil)
        [selectedTimeSpanItem removeFromSuperview];
    selectedTimeSpanItem = nil;
}

- (void) deleteAllTimeSpan
{
    for (NvsPSTimelineTimeSpan* timeSpan in timeSpanItemArray) {
        if (timeSpan.superview != nil)
            [timeSpan removeFromSuperview];
    }
    [timeSpanItemArray removeAllObjects];
    selectedTimeSpanItem = nil;
}

// Find the first time span object whose in point >= timestamp and return its index in the array
// return array.length if we can't find one
- (NSUInteger) findTimeSpanLowerBound:(int64_t)timestamp
{
    NSUInteger len = timeSpanItemArray.count;
    if (len == 0)
        return 0;
    
    if (timestamp <= ((NvsPSTimelineTimeSpan*)timeSpanItemArray[0]).inPoint)
        return 0;
    else if (timestamp > ((NvsPSTimelineTimeSpan*)timeSpanItemArray[len - 1]).inPoint)
        return len;
    
    // Use binaray search
    NSUInteger lowestIdx = 0, highestIdx = len - 1, i = 0;
    while (lowestIdx <= highestIdx) {
        i = floor((lowestIdx + highestIdx) / 2);
        int64_t t = ((NvsPSTimelineTimeSpan*)timeSpanItemArray[i]).inPoint;
        if (t == timestamp) {
            while (i > 0 && ((NvsPSTimelineTimeSpan*)timeSpanItemArray[i - 1]).inPoint == timestamp)
                --i;
            
            return i;
        } else if (t < timestamp) {
            lowestIdx = i + 1;
        } else {
            highestIdx = i - 1;
        }
    }
    
    if (((NvsPSTimelineTimeSpan*)timeSpanItemArray[i]).inPoint < timestamp)
        return i + 1;
    else
        return i;
}

- (NvsPSTimelineTimeSpan*) createTimeSpanItem
{
    NvsPSTimelineTimeSpan* timeSpan = [[NvsPSTimelineTimeSpan alloc] init];
    timeSpan.editable = _caneditTimeSpan;
    timeSpan.padding = sequenceView.startPadding;
    timeSpan.pointsPerMicrosecond = pointsPerMicrosecond;
    timeSpan.delegate = self;
    timeSpan.viewHeight = sequenceView.bounds.size.height;
    return timeSpan;
}

- (void) updateSelectedItem
{
    if (timeSpanItemArray.count == 0) {
        if (selectedTimeSpanItem != nil) {
            selectedTimeSpanItem.selected = false;
            selectedTimeSpanItem = nil;
            return;
        }
    }
    
    NSArray* itemArray = [self spanItemHitTest];
    NvsPSTimelineTimeSpan* newSelectedTimeSpan = nil;
    // NOTE: we don't select any time span item if there are multiple item
    // under the current timeline Position
    if (itemArray.count == 1)
        newSelectedTimeSpan = itemArray[0];
        
    [self selectTimeSpan:newSelectedTimeSpan];
}

// Return an time span item array which contain the current timeline position
- (NSArray*) spanItemHitTest
{
    NSMutableArray *result = [NSMutableArray array];
    NvsPSTimelineTimeSpan* timeSpanItem = nil;
    
    if (_canOverlapTimeSpan) {
        for (int i = 0; i < timeSpanItemArray.count; ++i) {
            if (_timelinePosition >= ((NvsPSTimelineTimeSpan*)timeSpanItemArray[i]).inPoint) {
                bool sel = false;
                if (i == timeSpanItemArray.count-1) {
                    if (_timelinePosition <= ((NvsPSTimelineTimeSpan*)timeSpanItemArray[i]).outPoint)
                        sel = true;
                } else {
                    if (_timelinePosition < ((NvsPSTimelineTimeSpan*)timeSpanItemArray[i]).outPoint)
                        sel = true;
                }
                if (sel)
                    [result addObject:(NvsPSTimelineTimeSpan*)timeSpanItemArray[i]];
            }
        }
        return result;
    }
    
    NSUInteger idx = [self findTimeSpanLowerBound:_timelinePosition];
    if (idx != timeSpanItemArray.count) {
        if (_timelinePosition == ((NvsPSTimelineTimeSpan*)timeSpanItemArray[idx]).inPoint) {
            [result addObject:(NvsPSTimelineTimeSpan*)timeSpanItemArray[idx]];
        } else if (idx > 0) {
            timeSpanItem = (NvsPSTimelineTimeSpan*)timeSpanItemArray[idx - 1];
            if (_timelinePosition >= timeSpanItem.inPoint && _timelinePosition < timeSpanItem.outPoint)
                [result addObject:timeSpanItem];
        }
    } else if (timeSpanItemArray.count != 0) {
        timeSpanItem = (NvsPSTimelineTimeSpan*)timeSpanItemArray[timeSpanItemArray.count - 1];
        if (_timelinePosition >= timeSpanItem.inPoint && _timelinePosition < timeSpanItem.outPoint)
            [result addObject:timeSpanItem];
    }
    
    return result;
}

- (void) updateTrimIn:(CGFloat)trimIn trimOut:(CGFloat)trimOut{
    CGFloat leftWidth = trimIn * pointsPerMicrosecond;
    CGFloat rightWidth = (self.timelineDuration - trimOut) * pointsPerMicrosecond;
    
    leftMask.frame = CGRectMake(0, 0, leftWidth, selectedTimeSpanItem.frame.size.height - 26 * SCREENSCALE);
    rightMask.frame = CGRectMake(leftWidth + self.frame.size.width - leftWidth - rightWidth, 0, rightWidth, selectedTimeSpanItem.frame.size.height - 26 * SCREENSCALE);
}

#pragma mark - timeSpan handles

- (void)timeSpan:(id)timeSpan dragHandleStarted:(UIView*)timeSpanItem isLeftHandle:(bool)isLeftHandle
{
    int64_t timestamp;
    if (isLeftHandle)
        timestamp = ((NvsPSTimelineTimeSpan*)timeSpanItem).inPoint;
    else
        timestamp = ((NvsPSTimelineTimeSpan*)timeSpanItem).outPoint;
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
    leftMask.frame = CGRectMake(0, 0, timeSpanItem.frame.origin.x, timeSpanItem.frame.size.height - 26 * SCREENSCALE);
    rightMask.frame = CGRectMake(timeSpanItem.frame.origin.x + timeSpanItem.frame.size.width, 0, self.frame.size.width - timeSpanItem.frame.origin.x - timeSpanItem.frame.size.width, timeSpanItem.frame.size.height - 26 * SCREENSCALE);
    NSUInteger idx;
    if (isLeftHandle) {
        int64_t newInPoint = floor(((NvsPSTimelineTimeSpan*)timeSpanItem).inPoint + xOffset / pointsPerMicrosecond);
        newInPoint = fmax(newInPoint, 0);
        newInPoint = fmin(newInPoint, ((NvsPSTimelineTimeSpan*)timeSpanItem).outPoint - 1);
                
        if (((NvsPSTimelineTimeSpan*)timeSpanItem).outPoint - newInPoint < minDraggedTimeSpanDuration)
            newInPoint = ((NvsPSTimelineTimeSpan*)timeSpanItem).outPoint - minDraggedTimeSpanDuration;
        
        if (!_canOverlapTimeSpan) {
            idx = [timeSpanItemArray indexOfObject:timeSpanItem];
            if (idx > 0)
                newInPoint = fmax(newInPoint, ((NvsPSTimelineTimeSpan*)timeSpanItemArray[idx - 1]).outPoint);
        }
        if (newInPoint < 0)
            newInPoint = 0;
        if (newInPoint > self.timelineDuration)
            newInPoint = self.timelineDuration-1;
        ((NvsPSTimelineTimeSpan*)timeSpanItem).inPoint = newInPoint;
        BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor:draggingHandle:isInPoint:)];
        if (isResponds)
            [self.delegate timelineEditor:self draggingHandle:newInPoint isInPoint:true];
    } else {
        int64_t newOutPoint = floor(((NvsPSTimelineTimeSpan*)timeSpanItem).outPoint + xOffset / pointsPerMicrosecond);
        newOutPoint = fmax(newOutPoint, ((NvsPSTimelineTimeSpan*)timeSpanItem).inPoint + 1);
        newOutPoint = fmin(newOutPoint, self.timelineDuration);
        
        if (newOutPoint - ((NvsPSTimelineTimeSpan*)timeSpanItem).inPoint < minDraggedTimeSpanDuration)
            newOutPoint = ((NvsPSTimelineTimeSpan*)timeSpanItem).inPoint + minDraggedTimeSpanDuration;
        
        if (!_canOverlapTimeSpan) {
            idx = [timeSpanItemArray indexOfObject:timeSpanItem];
            if ([timeSpanItemArray containsObject:timeSpanItem] && idx < timeSpanItemArray.count - 1)
                newOutPoint = fmin(newOutPoint, ((NvsPSTimelineTimeSpan*)timeSpanItemArray[idx + 1]).inPoint);
        }
        if (newOutPoint < 0)
            newOutPoint = 0;
        if (newOutPoint > self.timelineDuration)
            newOutPoint = self.timelineDuration-1;
        ((NvsPSTimelineTimeSpan*)timeSpanItem).outPoint = newOutPoint;
        BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor:draggingHandle:isInPoint:)];
        if (isResponds)
            [self.delegate timelineEditor:self draggingHandle:newOutPoint isInPoint:false];
    }
}

- (void)timeSpan:(id)timeSpan dragHandleEnded:(UIView*)timeSpanItem isLeftHandle:(bool)isLeftHandle
{
    leftMask.frame = CGRectMake(0, 0, timeSpanItem.frame.origin.x, timeSpanItem.frame.size.height - 26 * SCREENSCALE);
    rightMask.frame = CGRectMake(timeSpanItem.frame.origin.x + timeSpanItem.frame.size.width, 0, self.frame.size.width - timeSpanItem.frame.origin.x - timeSpanItem.frame.size.width, timeSpanItem.frame.size.height - 26 * SCREENSCALE);
    if (isLeftHandle)
        _timelinePosition = ((NvsPSTimelineTimeSpan*)timeSpanItem).inPoint;
    else
        _timelinePosition = ((NvsPSTimelineTimeSpan*)timeSpanItem).outPoint - 1;

    int64_t timestamp;
    if (isLeftHandle)
        timestamp = ((NvsPSTimelineTimeSpan*)timeSpanItem).inPoint;
    else
        timestamp = ((NvsPSTimelineTimeSpan*)timeSpanItem).outPoint;
    if (timestamp < 0)
        timestamp = 0;
    if (timestamp > self.timelineDuration)
        timestamp = self.timelineDuration-1;
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor:dragHandleEnded:isInPoint:)];
    if (isResponds)
        [self.delegate timelineEditor:self dragHandleEnded:timestamp isInPoint:isLeftHandle];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView:self];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateChanged: {
            int64_t dddd = segmentation + translation.x/pointsPerMicrosecond;
            ooooooo = dddd;
            timeAxis.frame = CGRectMake(dddd * pointsPerMicrosecond, -(90* SCREENSCALE - 64* SCREENSCALE)/2 + 5 * SCREENSCALE, 10* SCREENSCALE, self.bounds.size.height - 10* SCREENSCALE);
            if (timeAxis.frame.origin.x <= 0) {
                timeAxis.frame = CGRectMake(0, -(90* SCREENSCALE - 64* SCREENSCALE)/2 + 5 * SCREENSCALE, 10* SCREENSCALE, self.bounds.size.height - 10* SCREENSCALE);
                ooooooo = 0.0;
            }else if (timeAxis.frame.origin.x >= sequenceView.frame.size.width - timeAxis.frame.size.width){
                timeAxis.frame = CGRectMake(sequenceView.frame.size.width - timeAxis.frame.size.width, -(90* SCREENSCALE - 64* SCREENSCALE)/2 + 5 * SCREENSCALE, 10* SCREENSCALE, self.bounds.size.height - 10* SCREENSCALE);
                ooooooo = self.timelineDuration;
            }
            viewBack.center = timeAxis.center;
            [self.delegate timelineEditor:self handlePan:ooooooo];
            timeAxis1.center = CGPointMake(timeAxis.center.x, timeAxis1.center.y);
            break;
        }
        case UIGestureRecognizerStateEnded:
            segmentation = ooooooo;
            break;
        default: break;
    }
}


#pragma mark - scroll delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self selectTimeSpan:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (NvsPSTimelineTimeSpan* timeSpan in timeSpanItemArray) {
        bool add = true;
        if (timeSpan.outPoint <= [sequenceView mapTimelinePosFromX:0])
            add = false;
        if (timeSpan.inPoint >= [sequenceView mapTimelinePosFromX:sequenceView.bounds.size.width])
            add = false;
        if (add) {
            if (timeSpan.superview == nil)
                [sequenceView addSubview:timeSpan];
        } else {
            if (timeSpan.superview != nil)
                [timeSpan removeFromSuperview];
        }
        if (timeSpan.superview != nil)
            [timeSpan updateFrame];
    }
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
    [self updateSelectedItem];
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor: dragScrollTimelineEnded:)];
    if (isResponds)
        [self.delegate timelineEditor:self dragScrollTimelineEnded:_timelinePosition];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateSelectedItem];
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor: dragScrollTimelineEnded:)];
    if (isResponds)
        [self.delegate timelineEditor:self dragScrollTimelineEnded:_timelinePosition];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    sequenceView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, 64 * SCREENSCALE);;
    sequenceView.startPadding = 0;
    sequenceView.endPadding = 350 * SCREENSCALE;
    if (self.type == 0) {
        
    }else{
        UIImageView *timeAxisBack = [[UIImageView alloc]initWithFrame:CGRectMake(-4, 5, 15, self.bounds.size.height - 21* SCREENSCALE)];
        timeAxisBack.image = NvImageNamed(@"NvtimeLine");
        [timeAxis addSubview:timeAxisBack];
        
        timeAxis.frame = CGRectMake(0, -8* SCREENSCALE, 10* SCREENSCALE, self.bounds.size.height - 10* SCREENSCALE);
        timeAxis.center = sequenceView.center;
        timeAxis1.frame = CGRectMake(0, 0, 80 * SCREENSCALE, 20* SCREENSCALE);
        timeAxis1.center = CGPointMake(timeAxis.center.x, timeAxis.frame.size.height + 10* SCREENSCALE);
    }
    
    for (NvsPSTimelineTimeSpan* timeSpan in timeSpanItemArray) {
        timeSpan.padding = sequenceView.startPadding;
        [timeSpan updateFrame];
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
