//
//  NvRangeSequenceView.m
//  SDKDemo
//
//  Created by Mac-Mini on 2025/5/7.
//  Copyright © 2025 meishe. All rights reserved.
//

#import "NvRangeSequenceView.h"
#import "NvRangeCoverView.h"
#import <NvStreamingSdkCore/NvStreamingSdkCore.h>


@interface NvRangeSequenceView ()<UIScrollViewDelegate, NvRangeCoverViewDelegate>

@property (nonatomic, strong) NvRangeCoverView *coverView;
@property (nonatomic, assign) float minSpace;

@end

@implementation NvRangeSequenceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.sequenceView = [[NvsMultiThumbnailSequenceView alloc] initWithFrame:self.bounds];
        self.sequenceView.pointsPerMicrosecond = self.width/6/1000000;
        self.sequenceView.thumbnailAspectRatio = 1.0;
        self.sequenceView.startPadding = self.width / 4;
        self.sequenceView.endPadding = self.width / 4;
        self.sequenceView.delegate = self;
        self.sequenceView.bounces = false;
        [self addSubview:self.sequenceView];
        if (self.minValue <= 0) {
            self.minValue = 1000000;
        }
        self.minSpace = self.sequenceView.pointsPerMicrosecond * self.minValue;
        CGFloat barWidth = 15.0;
        self.coverView = [[NvRangeCoverView alloc] initWithFrame:CGRectMake(self.width / 4 - barWidth, 0, self.width / 2 + barWidth * 2, frame.size.height)];
        self.coverView.delegate = self;
        [self addSubview:self.coverView];
        
    }
    return self;
}

- (void)setVideoTrack:(NvsVideoTrack *)videoTrack {
    _videoTrack = videoTrack;
    [self updateSequenceView];
}

- (void)setMinValue:(int64_t)minValue {
    _minValue = minValue;
    _minSpace = self.sequenceView.pointsPerMicrosecond * minValue;
}

- (void)updateSequenceView {
    NvsVideoTrack *videoTrack = self.videoTrack;
    NSMutableArray *descArray = [NSMutableArray array];
    for (int i=0; i<[videoTrack clipCount]; i++) {
        NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
        NvsThumbnailSequenceDesc* desc = [[NvsThumbnailSequenceDesc alloc] init];
        desc.mediaFilePath = clip.filePath;
        desc.inPoint = clip.inPoint;
        desc.outPoint = clip.outPoint;
        desc.trimIn = clip.trimIn;
        desc.trimOut = clip.trimOut;
        if (clip.videoType == NvsVideoClipType_Image) {
            desc.stillImageHint = true;
        }
        [descArray addObject:desc];
    }
    self.sequenceView.descArray = descArray;
}

- (int64_t)getLeftValue {
    CGPoint left = [self convertPoint:CGPointMake(self.coverView.leftSliderView.right, self.coverView.leftSliderView.centerY) fromView:self.coverView];
    int64_t time = [self.sequenceView mapTimelinePosFromX: left.x];
    if (time < 0) {
        //浮点型运算有偏差做容错处理
        //Fault tolerant processing for floating point operation with deviation
        time = 0;
    }
    return time;
}

- (int64_t)getRightValue {
    CGPoint right = [self convertPoint:CGPointMake(self.coverView.rightSliderView.left, self.coverView.rightSliderView.centerY) fromView:self.coverView];
    int64_t time = [self.sequenceView mapTimelinePosFromX: right.x];
    if (time < 0) {
        //浮点型运算有偏差做容错处理
        //Fault tolerant processing for floating point operation with deviation
        time = 0;
    }
    if (time > self.videoTrack.duration) {
        time = self.videoTrack.duration;
    }
    return time;
}

- (void)didPlaybackTimelinePosition:(int64_t)position {
    CGFloat x = [self.sequenceView mapXFromTimelinePos:position];
    CGPoint p = [self.coverView convertPoint:CGPointMake(x, 0) fromView:self];
    self.coverView.timeAxis.center = CGPointMake(p.x, self.coverView.timeAxis.center.y);
}

#pragma mark - NvRangeCoverViewDelegate
- (float)getMinspace {
    return self.minSpace;
}

- (void)onRangeCoverView:(nonnull UIView *)rangeCoverView didLeftOffset:(int64_t)leftValue isTouchUp:(BOOL)isTouchUp {
    int64_t time = [self getLeftValue];
    if (time < 0) {
        //浮点型运算有偏差做容错处理
        //Fault tolerant processing for floating point operation with deviation
        time = 0;
    }
    [self didPlaybackTimelinePosition:time];
    BOOL isResponds = [self.delegate respondsToSelector:@selector(onRangeSequenceView:didLeftChange:isTouchUp:)];
    if (isResponds) {
        [self.delegate onRangeSequenceView:self didLeftChange:time isTouchUp:isTouchUp];
    }
}

- (void)onRangeCoverView:(nonnull UIView *)rangeCoverView didRightOffset:(int64_t)rightValue isTouchUp:(BOOL)isTouchUp {
    int64_t time = [self getRightValue];
    if (time < 0) {
        //浮点型运算有偏差做容错处理
        //Fault tolerant processing for floating point operation with deviation
        time = 0;
    }
    [self didPlaybackTimelinePosition:time];
    BOOL isResponds = [self.delegate respondsToSelector:@selector(onRangeSequenceView:didRightChange:isTouchUp:)];
    if (isResponds) {
        [self.delegate onRangeSequenceView:self didRightChange:time isTouchUp:isTouchUp];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int64_t time = [self getLeftValue];
    if (time < 0) {
        //浮点型运算有偏差做容错处理
        //Fault tolerant processing for floating point operation with deviation
        time = 0;
    }
    [self didPlaybackTimelinePosition:time];
    BOOL isResponds = [self.delegate respondsToSelector:@selector(onRangeSequenceView:didLeftChange:isTouchUp:)];
    if (isResponds) {
        [self.delegate onRangeSequenceView:self didLeftChange:time isTouchUp:NO];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate)
        return;
    
    int64_t time = [self getLeftValue];
    if (time < 0) {
        //浮点型运算有偏差做容错处理
        //Fault tolerant processing for floating point operation with deviation
        time = 0;
    }
    [self didPlaybackTimelinePosition:time];
    BOOL isResponds = [self.delegate respondsToSelector:@selector(onRangeSequenceView:didLeftChange:isTouchUp:)];
    if (isResponds) {
        [self.delegate onRangeSequenceView:self didLeftChange:time isTouchUp:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int64_t time = [self getLeftValue];
    if (time < 0) {
        //浮点型运算有偏差做容错处理
        //Fault tolerant processing for floating point operation with deviation
        time = 0;
    }
    [self didPlaybackTimelinePosition:time];
    BOOL isResponds = [self.delegate respondsToSelector:@selector(onRangeSequenceView:didLeftChange:isTouchUp:)];
    if (isResponds) {
        [self.delegate onRangeSequenceView:self didLeftChange:time isTouchUp:YES];
    }
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    CGPoint p = [self convertPoint:point toView:self.coverView];
    CGPoint p1 = [self convertPoint:point toView:self.sequenceView];
    if (CGRectContainsPoint(self.coverView.leftSliderView.frame, p)) {
        return self.coverView.leftSliderView;
    }
    if (CGRectContainsPoint(self.coverView.rightSliderView.frame, p)) {
        return self.coverView.rightSliderView;
    }
    if (CGRectContainsPoint(self.sequenceView.bounds, p1)) {
        return self.sequenceView;
    }
    return view;
}

@end
