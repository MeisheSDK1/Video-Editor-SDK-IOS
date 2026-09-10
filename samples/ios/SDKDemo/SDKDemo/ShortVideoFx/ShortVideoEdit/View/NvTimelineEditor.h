//
//  NvTimelineEditor.h
//  NvTimelineEditor
//
//  Created by LionLee on 2017/8/29.
//  Copyright © 2017年 CDV. All rights reserved.
//

#ifndef NvTimelineEditor_h
#define NvTimelineEditor_h


#pragma once

#import <UIKit/UIKit.h>
#import "NvsTimelineTimeSpan.h"


@interface NvTimelineEditorInfo : NSObject

@property (nonatomic, strong) NSString* mediaFilePath;
@property (nonatomic, assign) int64_t inPoint;
@property (nonatomic, assign) int64_t outPoint;
@property (nonatomic, assign) int64_t trimIn;
@property (nonatomic, assign) int64_t trimOut;
@property (nonatomic, assign) bool stillImageHint;

@end

@protocol NvTimelineEditorDelegate <NSObject>

@optional

- (void)timelineEditor:(id)timelineEditor dragHandleStarted:(int64_t)timestamp isInPoint:(bool)isInPoint;

- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint;

- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)timestamp isInPoint:(bool)isInPoint;

- (void)timelineEditor:(id)timelineEditor dragScrollingTimeline:(int64_t)timestamp;

- (void)timelineEditor:(id)timelineEditor dragScrollTimelineEnded:(int64_t)timestamp;

- (void)timelineEditor:(id)timelineEditor dragTimeAxis:(int64_t)timestamp;

- (void)timelineEditorDragTimeAxisEnded;
@end


@interface NvTimelineEditor : UIView

@property (nonatomic, weak) id <NvTimelineEditorDelegate> delegate;
@property (nonatomic, assign) bool canOverlapTimeSpan;
@property (nonatomic, assign) bool caneditTimeSpan;
@property (nonatomic, assign) int64_t timelinePosition;
@property (nonatomic, assign) int64_t timelineDuration;
@property (nonatomic, assign) bool isMusic;


- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

- (void) initTimelineEditor:(NSArray*) timelineEditorInfos timelineDuration:(int64_t)timelineDuration;
- (NvsTimelineTimeSpan*) addTimeSpan:(int64_t)inPoint outPoint:(int64_t)outPoint;
- (void) deleteAllTimeSpan;
- (NvsTimelineTimeSpan *)getSelectedTimeSpan;
//- (NvsTimelineTimeSpan *)addClipTimeSpan:(NvTimelineEditorInfo *)clipInfo;
- (void)scaleSequence:(double)scaleFactor withAnchor:(CGFloat)anchorX;
- (float)getSequenceViewXPos;
- (void)setSequenceViewEnabled:(BOOL)enabled;
- (void)hideTimeruler;
- (double)getPointsPerMicrosecond;
- (void)setPointsPerMicrosecond:(double)ppms;
- (void)setSequenceViewBounces:(BOOL)bounces;
- (void)setProgressValue:(float)value;
- (void)showCoverView:(BOOL)isShow;
- (CGFloat)getTimelineEditorWidth;
@end


#endif /* NvTimelineEditor_h */
