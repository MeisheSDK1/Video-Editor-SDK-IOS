//
//  NvsTimelineEditor.m
//  NvsTimelineEditor
//
//  Created by LionLee on 2017/8/29.
//  Copyright © 2017年 CDV. All rights reserved.
//

#import "NvsCTimelineEditor.h"
#import "NvsMultiThumbnailSequenceView.h"
#import <math.h>
#import <NvSDKCommon/NvUtils.h>


@interface NvsCTimelineEditorInfo()
@end

@implementation NvsCTimelineEditorInfo
@end


@interface NvsCTimelineEditor () <NvsCTimelineTimeSpanDelegate, UIScrollViewDelegate>
@property (nonatomic, assign) int64_t timelineDuration;
@property (nonatomic, strong) NSMutableArray *keyFramesArr; //关键帧数组
@end

@implementation NvsCTimelineEditor {
    NvsMultiThumbnailSequenceView* sequenceView;
    UIView* timeAxis;
    NSMutableArray* timeSpanItemArray;
    double pointsPerMicrosecond;
    int64_t minDraggedTimeSpanDuration;
    NvsCTimelineTimeSpan* selectedTimeSpanItem;
    bool changingTimelinePosFromScrollingClipReel;
    int64_t durationForScreenWidth;
    int64_t zoomStep;
    int64_t minDurationForScreenWidth;
    int64_t maxDurationForScreenWidth;
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

#pragma mark - 初始化数据参数
/*
 初始化数据参数
 Initialize data parameters
 
 */
- (void)initInternal {
    [self setBackgroundColor:UIColorFromRGB(0x242728)];
    self.keyFramesArr = [NSMutableArray array];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    durationForScreenWidth = 20*NV_TIME_BASE;
    zoomStep = 2*NV_TIME_BASE;
    minDurationForScreenWidth = 2*NV_TIME_BASE;
    maxDurationForScreenWidth = 60*NV_TIME_BASE;
    pointsPerMicrosecond = width/durationForScreenWidth;
    CGRect frame = self.bounds;
    sequenceView = [[NvsMultiThumbnailSequenceView alloc] initWithFrame:frame];
    sequenceView.thumbnailAspectRatio = 1;//0.5;
    sequenceView.thumbnailImageFillMode = NvsThumbnailFillModeAspectCrop;
    sequenceView.pointsPerMicrosecond = pointsPerMicrosecond;
    sequenceView.startPadding = sequenceView.bounds.size.width / 2;
    sequenceView.endPadding = sequenceView.startPadding;
    [self addSubview:sequenceView];
    timeAxis = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [timeAxis setBackgroundColor:[UIColor nv_colorWithHexARGB:@"#FF4A90E2"]];
   
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
        NvsCTimelineEditorInfo* info = (NvsCTimelineEditorInfo*)timelineEditorInfos[i];
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

- (NvsCTimelineTimeSpan *)addTimeSpan:(int64_t)inPoint outPoint:(int64_t)outPoint {
    if (inPoint >= outPoint)
        return nil;
    
    NSUInteger insertIndex = timeSpanItemArray.count;
    if (!_canOverlapTimeSpan && timeSpanItemArray.count != 0) {
        // Find a proper place to insert this time span object
        insertIndex = [self findTimeSpanLowerBound:inPoint];
        if (insertIndex != timeSpanItemArray.count) {
            if (((NvsCTimelineTimeSpan*)timeSpanItemArray[insertIndex]).inPoint == inPoint) {
                return nil;
            } else if (outPoint > ((NvsCTimelineTimeSpan*)timeSpanItemArray[insertIndex]).inPoint) {
                return nil;
            } else if (insertIndex > 0) {
                if (inPoint < ((NvsCTimelineTimeSpan*)timeSpanItemArray[insertIndex - 1]).outPoint &&
                    outPoint > ((NvsCTimelineTimeSpan*)timeSpanItemArray[insertIndex - 1]).inPoint)
                {
                    return nil;
                }
            }
        } else {
            if (inPoint < ((NvsCTimelineTimeSpan*)timeSpanItemArray[timeSpanItemArray.count - 1]).outPoint &&
                outPoint > ((NvsCTimelineTimeSpan*)timeSpanItemArray[timeSpanItemArray.count - 1]).inPoint)
            {
                return nil;
            }
        }
    }
    
    // Create time span Item
    NvsCTimelineTimeSpan* timeSpanItem = [self createTimeSpanItem];
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

- (void) selectTimeSpan:(NvsCTimelineTimeSpan*)timeSpanItem
{
    if (timeSpanItem == selectedTimeSpanItem){
        return;
    }
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
    for (NvsCTimelineTimeSpan* timeSpan in timeSpanItemArray) {
        if (timeSpan.superview != nil)
            [timeSpan removeFromSuperview];
    }
    [timeSpanItemArray removeAllObjects];
    selectedTimeSpanItem = nil;
}

#pragma mark - 找到第一个在点>= timestamp的time span对象，并返回其在数组中的索引
/*
 找到第一个在点>= timestamp的time span对象，并返回其在数组中的索引
 Find the first time span object whose in point >= timestamp and return its index in the array
 
 @param timestamp 当前的时间点 Current point in time
 
 return 返回NSUInteger值。数组的下标
 Returns the value of NSUInteger. Subscript of array
 */
- (NSUInteger) findTimeSpanLowerBound:(int64_t)timestamp
{
    NSUInteger len = timeSpanItemArray.count;
    if (len == 0)
        return 0;
    
    if (timestamp <= ((NvsCTimelineTimeSpan*)timeSpanItemArray[0]).inPoint)
        return 0;
    else if (timestamp > ((NvsCTimelineTimeSpan*)timeSpanItemArray[len - 1]).inPoint)
        return len;
    
    // Use binaray search
    NSUInteger lowestIdx = 0, highestIdx = len - 1, i = 0;
    while (lowestIdx <= highestIdx) {
        i = floor((lowestIdx + highestIdx) / 2);
        int64_t t = ((NvsCTimelineTimeSpan*)timeSpanItemArray[i]).inPoint;
        if (t == timestamp) {
            while (i > 0 && ((NvsCTimelineTimeSpan*)timeSpanItemArray[i - 1]).inPoint == timestamp)
                --i;
            
            return i;
        } else if (t < timestamp) {
            lowestIdx = i + 1;
        } else {
            highestIdx = i - 1;
        }
    }
    
    if (((NvsCTimelineTimeSpan*)timeSpanItemArray[i]).inPoint < timestamp)
        return i + 1;
    else
        return i;
}

#pragma mark - 创建TimeSpan控件
/*
 创建TimeSpan控件
 Create TimeSpan control
 
 return 返回NvsCTimelineTimeSpan值。TimeSpan控件。
 return returns the value of NvsCTimelineTimeSpan. TimeSpan control.
 */
- (NvsCTimelineTimeSpan*) createTimeSpanItem
{
    NvsCTimelineTimeSpan* timeSpan = [[NvsCTimelineTimeSpan alloc] init];
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
    NvsCTimelineTimeSpan* newSelectedTimeSpan = nil;
    // NOTE: we don't select any time span item if there are multiple item
    // under the current timeline Position
    if (itemArray.count == 1)
        newSelectedTimeSpan = itemArray[0];
        
    [self selectTimeSpan:newSelectedTimeSpan];
}

#pragma mark - 返回一个包含当前时间轴位置的时间跨度项数组
/*
 返回一个包含当前时间轴位置的时间跨度项数组
 Return an time span item array which contain the current timeline position
 */
- (NSArray*) spanItemHitTest
{
    NSMutableArray *result = [NSMutableArray array];
    NvsCTimelineTimeSpan* timeSpanItem = nil;
    
    if (_canOverlapTimeSpan) {
        for (int i = 0; i < timeSpanItemArray.count; ++i) {
            if (_timelinePosition >= ((NvsCTimelineTimeSpan*)timeSpanItemArray[i]).inPoint) {
                bool sel = false;
                if (i == timeSpanItemArray.count-1) {
                    if (_timelinePosition <= ((NvsCTimelineTimeSpan*)timeSpanItemArray[i]).outPoint)
                        sel = true;
                } else {
                    if (_timelinePosition < ((NvsCTimelineTimeSpan*)timeSpanItemArray[i]).outPoint)
                        sel = true;
                }
                if (sel)
                    [result addObject:(NvsCTimelineTimeSpan*)timeSpanItemArray[i]];
            }
        }
        return result;
    }
    
    NSUInteger idx = [self findTimeSpanLowerBound:_timelinePosition];
    if (idx != timeSpanItemArray.count) {
        if (_timelinePosition == ((NvsCTimelineTimeSpan*)timeSpanItemArray[idx]).inPoint) {
            [result addObject:(NvsCTimelineTimeSpan*)timeSpanItemArray[idx]];
        } else if (idx > 0) {
            timeSpanItem = (NvsCTimelineTimeSpan*)timeSpanItemArray[idx - 1];
            if (_timelinePosition >= timeSpanItem.inPoint && _timelinePosition < timeSpanItem.outPoint)
                [result addObject:timeSpanItem];
        }
    } else if (timeSpanItemArray.count != 0) {
        timeSpanItem = (NvsCTimelineTimeSpan*)timeSpanItemArray[timeSpanItemArray.count - 1];
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
        timestamp = ((NvsCTimelineTimeSpan*)timeSpanItem).inPoint;
    else
        timestamp = ((NvsCTimelineTimeSpan*)timeSpanItem).outPoint;
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
        int64_t newInPoint = floor(((NvsCTimelineTimeSpan*)timeSpanItem).inPoint + xOffset / pointsPerMicrosecond);
        newInPoint = fmax(newInPoint, 0);
        newInPoint = fmin(newInPoint, ((NvsCTimelineTimeSpan*)timeSpanItem).outPoint - 1);
                
        if (((NvsCTimelineTimeSpan*)timeSpanItem).outPoint - newInPoint < minDraggedTimeSpanDuration)
            newInPoint = ((NvsCTimelineTimeSpan*)timeSpanItem).outPoint - minDraggedTimeSpanDuration;
        
        if (!_canOverlapTimeSpan) {
            idx = [timeSpanItemArray indexOfObject:timeSpanItem];
            if (idx > 0)
                newInPoint = fmax(newInPoint, ((NvsCTimelineTimeSpan*)timeSpanItemArray[idx - 1]).outPoint);
        }
        if (newInPoint < 0)
            newInPoint = 0;
        if (newInPoint > self.timelineDuration)
            newInPoint = self.timelineDuration-1;
        ((NvsCTimelineTimeSpan*)timeSpanItem).inPoint = newInPoint;
        BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor:draggingHandle:isInPoint:)];
        if (isResponds)
            [self.delegate timelineEditor:self draggingHandle:newInPoint isInPoint:true];
    } else {
        int64_t newOutPoint = floor(((NvsCTimelineTimeSpan*)timeSpanItem).outPoint + xOffset / pointsPerMicrosecond);
        newOutPoint = fmax(newOutPoint, ((NvsCTimelineTimeSpan*)timeSpanItem).inPoint + 1);
        newOutPoint = fmin(newOutPoint, self.timelineDuration);
        
        if (newOutPoint - ((NvsCTimelineTimeSpan*)timeSpanItem).inPoint < minDraggedTimeSpanDuration)
            newOutPoint = ((NvsCTimelineTimeSpan*)timeSpanItem).inPoint + minDraggedTimeSpanDuration;
        
        if (!_canOverlapTimeSpan) {
            idx = [timeSpanItemArray indexOfObject:timeSpanItem];
            if ([timeSpanItemArray containsObject:timeSpanItem] && idx < timeSpanItemArray.count - 1)
                newOutPoint = fmin(newOutPoint, ((NvsCTimelineTimeSpan*)timeSpanItemArray[idx + 1]).inPoint);
        }
        if (newOutPoint < 0)
            newOutPoint = 0;
        if (newOutPoint > self.timelineDuration)
            newOutPoint = self.timelineDuration-1;
        ((NvsCTimelineTimeSpan*)timeSpanItem).outPoint = newOutPoint;
        BOOL isResponds = [self.delegate respondsToSelector:@selector(timelineEditor:draggingHandle:isInPoint:)];
        if (isResponds)
            [self.delegate timelineEditor:self draggingHandle:newOutPoint isInPoint:false];
    }
}

- (void)timeSpan:(id)timeSpan dragHandleEnded:(UIView*)timeSpanItem isLeftHandle:(bool)isLeftHandle
{
    if (isLeftHandle)
        _timelinePosition = ((NvsCTimelineTimeSpan*)timeSpanItem).inPoint;
    else
        _timelinePosition = ((NvsCTimelineTimeSpan*)timeSpanItem).outPoint - 1;

    int64_t timestamp;
    if (isLeftHandle)
        timestamp = ((NvsCTimelineTimeSpan*)timeSpanItem).inPoint;
    else
        timestamp = ((NvsCTimelineTimeSpan*)timeSpanItem).outPoint;
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
    for (NvsCTimelineTimeSpan* timeSpan in timeSpanItemArray) {
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
    for (NvsCTimelineTimeSpan* timeSpan in timeSpanItemArray) {
        timeSpan.padding = sequenceView.startPadding;
        [timeSpan updateFrame];
    }
}

- (void)zoomIn {
    float anchorX = [sequenceView mapXFromTimelinePos:self.timelinePosition];
    [sequenceView scale:1.1 withAnchor:anchorX];
    pointsPerMicrosecond = sequenceView.pointsPerMicrosecond;
    [self resetKeyFramesImageView];
    [self resetTimespan];
    
}

- (void)zoomOut {
    float anchorX = [sequenceView mapXFromTimelinePos:self.timelinePosition];
    [sequenceView scale:.9 withAnchor:anchorX];
    pointsPerMicrosecond = sequenceView.pointsPerMicrosecond;
    [self resetKeyFramesImageView];
    [self resetTimespan];
    
}

- (CGFloat)getTimelineEditorWidth{
    return sequenceView.contentSize.width;
}

#pragma mark - 重置关键帧数据
/*
 重置关键帧数据
 Reset keyframe data
 */
- (void)resetKeyFramesImageView {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0;i<self.keyFramesArr.count; i++) {
        CGFloat tempPos = [self.keyFramesArr[i] longLongValue] * pointsPerMicrosecond + sequenceView.startPadding;
        [tempArray addObject:[NSNumber numberWithFloat:tempPos]];
    }
    
    [self configArray:tempArray];
}

- (BOOL)isInKeyframeView:(int64_t)keyTime time:(int64_t)time {
    if (fabs(keyTime - time)* pointsPerMicrosecond <= 7.0 && keyTime != time) {
        return YES;
    }
    return NO;
}

#pragma mark - 重置关键帧数据
/*
 重置关键帧数据
 Reset keyframe data
 */
- (void)resetTimespan {
    for (NvsCTimelineTimeSpan *timespan in timeSpanItemArray) {
        timespan.pointsPerMicrosecond = pointsPerMicrosecond;
    }
    
    for (int i = 0; i < sequenceView.subviews.count; i++) {
        if ([sequenceView.subviews[i] isKindOfClass:NvsCTimelineTimeSpan.class]) {
            [sequenceView.subviews[i] updateFrame];
        }
    }

    [self layoutIfNeeded];
}

- (void)configKeyFrames:(NSMutableArray *)array withSpanInPoint:(int64_t)inPoint withOutPoint:(int64_t)outPoint{
    [self selectTimeSpan:inPoint outPoint:outPoint];
    [self configKeyFrames:array];
}

- (void)configKeyFrames:(NSMutableArray *)array {
    self.keyFramesArr = [NSMutableArray arrayWithArray:array];
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0;i<array.count; i++) {
        CGFloat tempPos = [array[i] longLongValue] * pointsPerMicrosecond + sequenceView.startPadding;
        [tempArray addObject:[NSNumber numberWithFloat:tempPos]];
    }
    
    [self configArray:tempArray];
}
#pragma mark - 根据关键帧数组配置
/*
 根据关键帧数组配置
 According to the key frame array configuration
 */
- (void)configArray:(NSMutableArray *)array{
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i < sequenceView.subviews.count; i++) {
        UIImageView *imageView = [self viewWithTag:2000+i];
        if (imageView) {
            [tempArray addObject:imageView];
        }
    }
    
    for (UIImageView *imageView in tempArray) {
        [imageView removeFromSuperview];
    }
    
    for (int i = 0; i < array.count; i++) {
        NSNumber *number = array[i];
        UIImageView *pointView = [[UIImageView alloc]initWithFrame:CGRectMake(number.floatValue-7, (self.frame.size.height - 14)/2.0, 14, 14)];
        pointView.tag = 2000+i;
        pointView.image = NvImageNamed(@"nv_edit_keyframe_indicator");
        [sequenceView addSubview:pointView];
        [sequenceView bringSubviewToFront:pointView];
    }
}

- (void)configSelectKeyFrames:(NSInteger)keyFramesTag{
    for (int i = 0; i < sequenceView.subviews.count; i++) {
        UIImageView *imageView = [self viewWithTag:2000+i];
        if (i == keyFramesTag) {
            imageView.image = NvImageNamed(@"nv_edit_keyframe_indicator_selected");
        }else{
            imageView.image = NvImageNamed(@"nv_edit_keyframe_indicator");
        }
    }
}

- (void)removeAllKeyFramesSelectState{
    for (int i = 0; i < sequenceView.subviews.count; i++) {
        UIImageView *imageView = [self viewWithTag:2000+i];
        imageView.image = NvImageNamed(@"nv_edit_keyframe_indicator");
    }
}

- (void)selectTimeSpan:(int64_t)inPoint outPoint:(int64_t)outPoint {
    for (NvsCTimelineTimeSpan* timeSpan in timeSpanItemArray) {
        if (timeSpan.inPoint == inPoint && timeSpan.outPoint == outPoint) {
            timeSpan.selected = YES;
            [self selectTimeSpan:timeSpan];
            return;
        }
    }
}

- (void)deleteTimeSpan:(int64_t)inPoint outPoint:(int64_t)outPoint {
    for (NvsCTimelineTimeSpan* timeSpan in timeSpanItemArray) {
        if (timeSpan.inPoint == inPoint && timeSpan.outPoint == outPoint) {
            [self selectTimeSpan:timeSpan];
            [self deleteSelectedTimeSpan];
            return;
        }
    }
}

- (void)clearTimeSpanSelection {
    for (NvsCTimelineTimeSpan* timeSpan in timeSpanItemArray) {
        timeSpan.selected = NO;
    }
}

- (bool)isInTimespan:(int64_t)position {
    for (NvsCTimelineTimeSpan* timeSpan in timeSpanItemArray) {
        if (timeSpan.inPoint <= position && timeSpan.outPoint >= position) {
            return YES;
        }
    }
    return NO;
}

- (void)selectTimeSpanByPosition:(int64_t)position {
    for (NvsCTimelineTimeSpan* timeSpan in timeSpanItemArray) {
        if (timeSpan.inPoint <= position && timeSpan.outPoint >= position) {
            timeSpan.selected = YES;
            [self selectTimeSpan:timeSpan];
            return;
        }
    }
}

- (void)removeAllKeyFrameImageViews {
    NSInteger count = sequenceView.subviews.count;
    for (int i = 0; i < count; i++) {
        UIImageView *imageView = [self viewWithTag:2000+i];
        [imageView removeFromSuperview];
    }
}
@end
