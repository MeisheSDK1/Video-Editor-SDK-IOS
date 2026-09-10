//
//  NvsTimelineEditor.m
//  NvsTimelineEditor
//
//  Created by LionLee on 2017/8/29.
//  Copyright © 2017年 CDV. All rights reserved.
//

#import "NvsTimelineEditor.h"
#import "NvsMultiThumbnailSequenceView.h"
#import <math.h>


@interface NvsTimelineEditorInfo()
@end

@implementation NvsTimelineEditorInfo
@end


@interface NvsTimelineEditor () <NvsTimelineTimeSpanDelegate, UIScrollViewDelegate>
@property (nonatomic, assign) int64_t timelineDuration;

@end

@implementation NvsTimelineEditor {
    NvsMultiThumbnailSequenceView* sequenceView;
    UIView* timeAxis;
    NSMutableArray* timeSpanItemArray;
    double pointsPerMicrosecond;
    int64_t minDraggedTimeSpanDuration;
    NvsTimelineTimeSpan* selectedTimeSpanItem;
    bool changingTimelinePosFromScrollingClipReel;
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
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    pointsPerMicrosecond = width/20/1000000;
    CGRect frame = self.bounds;
    sequenceView = [[NvsMultiThumbnailSequenceView alloc] initWithFrame:frame];
    sequenceView.thumbnailAspectRatio = 0.5;
    sequenceView.pointsPerMicrosecond = pointsPerMicrosecond;
    sequenceView.startPadding = sequenceView.bounds.size.width / 2;
    sequenceView.endPadding = sequenceView.startPadding;
    [self addSubview:sequenceView];
    timeAxis = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width/2-2, -3, 4, frame.size.height+6)];
    [timeAxis setBackgroundColor:[UIColor redColor]];
    [self addSubview:timeAxis];
    self.timelineDuration = 0;
    timeSpanItemArray = [NSMutableArray array];
    _canOverlapTimeSpan = false;
    _caneditTimeSpan = false;
    minDraggedTimeSpanDuration = 1000000;
    selectedTimeSpanItem = nil;
    _timelinePosition = 0;
    changingTimelinePosFromScrollingClipReel = false;
    sequenceView.delegate = self;
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
        NvsTimelineEditorInfo* info = (NvsTimelineEditorInfo*)timelineEditorInfos[i];
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

- (NvsTimelineTimeSpan *)addTimeSpan:(int64_t)inPoint outPoint:(int64_t)outPoint {
    if (inPoint >= outPoint)
        return nil;
    
    NSUInteger insertIndex = timeSpanItemArray.count;
    if (!_canOverlapTimeSpan && timeSpanItemArray.count != 0) {
        // Find a proper place to insert this time span object
        insertIndex = [self findTimeSpanLowerBound:inPoint];
        if (insertIndex != timeSpanItemArray.count) {
            if (((NvsTimelineTimeSpan*)timeSpanItemArray[insertIndex]).inPoint == inPoint) {
                return nil;
            } else if (outPoint > ((NvsTimelineTimeSpan*)timeSpanItemArray[insertIndex]).inPoint) {
                return nil;
            } else if (insertIndex > 0) {
                if (inPoint < ((NvsTimelineTimeSpan*)timeSpanItemArray[insertIndex - 1]).outPoint &&
                    outPoint > ((NvsTimelineTimeSpan*)timeSpanItemArray[insertIndex - 1]).inPoint)
                {
                    return nil;
                }
            }
        } else {
            if (inPoint < ((NvsTimelineTimeSpan*)timeSpanItemArray[timeSpanItemArray.count - 1]).outPoint &&
                outPoint > ((NvsTimelineTimeSpan*)timeSpanItemArray[timeSpanItemArray.count - 1]).inPoint)
            {
                return nil;
            }
        }
    }
    
    // Create time span Item
    NvsTimelineTimeSpan* timeSpanItem = [self createTimeSpanItem];
    if (timeSpanItem == nil)
        return nil;
    bool add = true;
    if (outPoint <= [sequenceView mapTimelinePosFromX:0])
        add = false;
    if (inPoint >= [sequenceView mapTimelinePosFromX:sequenceView.bounds.size.width])
        add = false;
    if (add)
        [sequenceView addSubview:timeSpanItem];
    
    timeSpanItem.inPoint = inPoint;
    timeSpanItem.outPoint = outPoint;
    
    // Insert time span
    [timeSpanItemArray insertObject:timeSpanItem atIndex:insertIndex];
    
    [self updateSelectedItem];
    
    return timeSpanItem;
}

- (void) selectTimeSpan:(NvsTimelineTimeSpan*)timeSpanItem
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
    for (NvsTimelineTimeSpan* timeSpan in timeSpanItemArray) {
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
    NvsTimelineTimeSpan* newSelectedTimeSpan = nil;
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
    int64_t timestamp;
    if (isLeftHandle)
        timestamp = ((NvsTimelineTimeSpan*)timeSpanItem).inPoint;
    else
        timestamp = ((NvsTimelineTimeSpan*)timeSpanItem).outPoint;
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
    NSUInteger idx;
    if (isLeftHandle) {
        int64_t newInPoint = floor(((NvsTimelineTimeSpan*)timeSpanItem).inPoint + xOffset / pointsPerMicrosecond);
        newInPoint = fmax(newInPoint, 0);
        newInPoint = fmin(newInPoint, ((NvsTimelineTimeSpan*)timeSpanItem).outPoint - 1);
                
        if (((NvsTimelineTimeSpan*)timeSpanItem).outPoint - newInPoint < minDraggedTimeSpanDuration)
            newInPoint = ((NvsTimelineTimeSpan*)timeSpanItem).outPoint - minDraggedTimeSpanDuration;
        
        if (!_canOverlapTimeSpan) {
            idx = [timeSpanItemArray indexOfObject:timeSpanItem];
            if (idx > 0)
                newInPoint = fmax(newInPoint, ((NvsTimelineTimeSpan*)timeSpanItemArray[idx - 1]).outPoint);
        }
        if (newInPoint < 0)
            newInPoint = 0;
        if (newInPoint > self.timelineDuration)
            newInPoint = self.timelineDuration-1;
        ((NvsTimelineTimeSpan*)timeSpanItem).inPoint = newInPoint;
        BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor:draggingHandle:isInPoint:)];
        if (isResponds)
            [self.delegate timelineEditor:self draggingHandle:newInPoint isInPoint:true];
    } else {
        int64_t newOutPoint = floor(((NvsTimelineTimeSpan*)timeSpanItem).outPoint + xOffset / pointsPerMicrosecond);
        newOutPoint = fmax(newOutPoint, ((NvsTimelineTimeSpan*)timeSpanItem).inPoint + 1);
        newOutPoint = fmin(newOutPoint, self.timelineDuration);
        
        if (newOutPoint - ((NvsTimelineTimeSpan*)timeSpanItem).inPoint < minDraggedTimeSpanDuration)
            newOutPoint = ((NvsTimelineTimeSpan*)timeSpanItem).inPoint + minDraggedTimeSpanDuration;
        
        if (!_canOverlapTimeSpan) {
            idx = [timeSpanItemArray indexOfObject:timeSpanItem];
            if ([timeSpanItemArray containsObject:timeSpanItem] && idx < timeSpanItemArray.count - 1)
                newOutPoint = fmin(newOutPoint, ((NvsTimelineTimeSpan*)timeSpanItemArray[idx + 1]).inPoint);
        }
        if (newOutPoint < 0)
            newOutPoint = 0;
        if (newOutPoint > self.timelineDuration)
            newOutPoint = self.timelineDuration-1;
        ((NvsTimelineTimeSpan*)timeSpanItem).outPoint = newOutPoint;
        BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor:draggingHandle:isInPoint:)];
        if (isResponds)
            [self.delegate timelineEditor:self draggingHandle:newOutPoint isInPoint:false];
    }
}

- (void)timeSpan:(id)timeSpan dragHandleEnded:(UIView*)timeSpanItem isLeftHandle:(bool)isLeftHandle
{
    if (isLeftHandle)
        _timelinePosition = ((NvsTimelineTimeSpan*)timeSpanItem).inPoint;
    else
        _timelinePosition = ((NvsTimelineTimeSpan*)timeSpanItem).outPoint - 1;

    int64_t timestamp;
    if (isLeftHandle)
        timestamp = ((NvsTimelineTimeSpan*)timeSpanItem).inPoint;
    else
        timestamp = ((NvsTimelineTimeSpan*)timeSpanItem).outPoint;
    if (timestamp < 0)
        timestamp = 0;
    if (timestamp > self.timelineDuration)
        timestamp = self.timelineDuration-1;
    BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor:dragHandleEnded:isInPoint:)];
    if (isResponds)
        [self.delegate timelineEditor:self dragHandleEnded:timestamp isInPoint:isLeftHandle];
}


#pragma mark - scroll delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self selectTimeSpan:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (NvsTimelineTimeSpan* timeSpan in timeSpanItemArray) {
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
    sequenceView.frame = self.bounds;
    sequenceView.startPadding = sequenceView.bounds.size.width / 2;
    sequenceView.endPadding = sequenceView.startPadding;
    timeAxis.frame = CGRectMake(self.bounds.size.width/2-2, -3, 4, self.bounds.size.height+6);
    for (NvsTimelineTimeSpan* timeSpan in timeSpanItemArray) {
        timeSpan.padding = sequenceView.startPadding;
        [timeSpan updateFrame];
    }
}

@end
