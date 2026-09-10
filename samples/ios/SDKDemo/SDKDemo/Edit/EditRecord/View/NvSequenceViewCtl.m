//
//  NvSequenceViewCtl.m
//  SDKDemo
//
//  Created by meishe01 on 2018/8/8.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvSequenceViewCtl.h"
#import "NvsAVFileInfo.h"
#import "NvsStreamingContext.h"
#import <NvSDKCommon/NvUtils.h>
#import "UIView+Dimension.h"
#import "UIColor+NvColor.h"

@implementation NvSpanItem

@end

@interface NvSequenceViewCtl () <UIScrollViewDelegate>

@end

@implementation NvSequenceViewCtl {
    NvsMultiThumbnailSequenceView *sequenceView;
    UIView *timeAxis;
    NSMutableArray *spanItemArray;
    int64_t timelineDuration;
    BOOL isRecording;
    NvSpanItem *recordingSpanItem;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
        [self initInternal:frame];
    return self;
}

- (void)initInternal:(CGRect)frame {
    [self setBackgroundColor:[UIColor clearColor]];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    _timelinePosition = 0;
    spanItemArray = [NSMutableArray array];
    
    sequenceView = [[NvsMultiThumbnailSequenceView alloc] initWithFrame:self.bounds];
    sequenceView.thumbnailAspectRatio = 0.5;
    sequenceView.pointsPerMicrosecond = width / 20 / NV_TIME_BASE;
    sequenceView.startPadding = frame.size.width / 2;
    sequenceView.endPadding = sequenceView.startPadding;
    sequenceView.delegate = self;
    [self addSubview:sequenceView];
    
    recordingSpanItem = [[NvSpanItem alloc] initWithFrame:CGRectMake(0, 0, 0, sequenceView.height)];
    recordingSpanItem.backgroundColor = [UIColor nv_colorWithHexARGB:@"#994A90E2"];
    [sequenceView addSubview:recordingSpanItem];
    recordingSpanItem.hidden = YES;
    
    timeAxis = [[UIView alloc] initWithFrame:CGRectMake((self.width - 5) / 2, -7 * SCREENSCALE, 5, frame.size.height + 14 * SCREENSCALE)];
    timeAxis.backgroundColor = [UIColor nv_colorWithHexARGB:@"#FF4A90E2"];
    [self addSubview:timeAxis];
}

- (void)initSequenceViewCtl:(NSArray<NvsThumbnailSequenceDesc *> *)descArray duration:(int64_t)duration {
    sequenceView.descArray = descArray;
    timelineDuration = duration;
}

- (void)updateSpanItems:(NSArray<NvRecordModel *> *)dataArray {
    [self deleteAllSpanItems];
    for (NvRecordModel *data in dataArray) {
        if (data.inpoint>=timelineDuration) {
            break;
        }
        if (data.inpoint<timelineDuration && data.outpoint>timelineDuration) {
            CGFloat x = sequenceView.startPadding + data.inpoint * sequenceView.pointsPerMicrosecond;
            CGFloat width = (timelineDuration - data.inpoint) * sequenceView.pointsPerMicrosecond;
            NvSpanItem *item = [[NvSpanItem alloc] initWithFrame:CGRectMake(x, 0, width, sequenceView.height)];
            item.backgroundColor = [UIColor nv_colorWithHexARGB:@"#994A90E2"];
            item.inPoint = data.inpoint;
            item.outPoint = timelineDuration;
            [sequenceView addSubview:item];
            [spanItemArray addObject:item];
            break;
        }
        CGFloat x = sequenceView.startPadding + data.inpoint * sequenceView.pointsPerMicrosecond;
        CGFloat width = (data.outpoint - data.inpoint) * sequenceView.pointsPerMicrosecond;
        NvSpanItem *item = [[NvSpanItem alloc] initWithFrame:CGRectMake(x, 0, width, sequenceView.height)];
        item.backgroundColor = [UIColor nv_colorWithHexARGB:@"#994A90E2"];
        item.inPoint = data.inpoint;
        item.outPoint = data.outpoint;
        [sequenceView addSubview:item];
        [spanItemArray addObject:item];
    }
    recordingSpanItem.hidden = YES;
}

- (void)removeSpanItem:(int64_t)timestamp {
    for (NvSpanItem *spanItem in spanItemArray) {
        if (spanItem.inPoint <= timestamp && spanItem.outPoint > timestamp) {
            if (spanItem.superview) {
                [spanItem removeFromSuperview];
            }
            [spanItemArray removeObject:spanItem];
            break;
        }
    }
}

- (void)setTimelinePosition:(int64_t)timelinePosition {
    _timelinePosition = timelinePosition;
    sequenceView.contentOffset = CGPointMake(_timelinePosition * sequenceView.pointsPerMicrosecond, sequenceView.contentOffset.y);
    if (isRecording) {
        recordingSpanItem.width = sequenceView.startPadding + _timelinePosition * sequenceView.pointsPerMicrosecond - recordingSpanItem.frame.origin.x;
    }
}

- (void)setSequenceViewScrollEnabled:(BOOL)enabled {
    sequenceView.scrollEnabled = enabled;
}

- (void)scaleSequenceView:(double)scaleFactor {
    [sequenceView scale:scaleFactor withAnchor:[sequenceView mapXFromTimelinePos:_timelinePosition]];
    [self updateSpanItemsFrame];
}

- (void)startRecording:(int64_t)timestamp {
    isRecording = YES;
    recordingSpanItem.frame = CGRectMake(sequenceView.startPadding + timestamp * sequenceView.pointsPerMicrosecond, 0, 0, sequenceView.height);
    recordingSpanItem.hidden = NO;
}

- (void)stopRecording {
    isRecording = NO;
}

- (void)updateSpanItemsFrame {
    for (NvSpanItem *spanItem in spanItemArray) {
        CGFloat x = sequenceView.startPadding + spanItem.inPoint * sequenceView.pointsPerMicrosecond;
        CGFloat width = (spanItem.outPoint - spanItem.inPoint) * sequenceView.pointsPerMicrosecond;
        spanItem.frame = CGRectMake(x, 0, width, sequenceView.height);
    }
}

- (void)deleteAllSpanItems {
    for (NvSpanItem *spanItem in spanItemArray) {
        if (spanItem.superview) {
            [spanItem removeFromSuperview];
        }
    }
    [spanItemArray removeAllObjects];
}


- (CGFloat)getTimelineEditorWidth{
    return sequenceView.contentSize.width;
}

#pragma mark - scroll delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!scrollView.dragging)
        return;

    _timelinePosition = floor(sequenceView.contentOffset.x / sequenceView.pointsPerMicrosecond);
    if (_timelinePosition < 0)
        _timelinePosition = 0;
    if (_timelinePosition > timelineDuration)
        _timelinePosition = timelineDuration - 1;
    
    if ([self.delegate respondsToSelector:@selector(sequenceViewCtl: scroll:)]) {
        [self.delegate sequenceViewCtl:self scroll:_timelinePosition];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate)
        return;
    
    if ([self.delegate respondsToSelector:@selector(sequenceViewCtl: scrollEnded:)]) {
        [self.delegate sequenceViewCtl:self scrollEnded:_timelinePosition];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(sequenceViewCtl: scrollEnded:)]) {
        [self.delegate sequenceViewCtl:self scrollEnded:_timelinePosition];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
