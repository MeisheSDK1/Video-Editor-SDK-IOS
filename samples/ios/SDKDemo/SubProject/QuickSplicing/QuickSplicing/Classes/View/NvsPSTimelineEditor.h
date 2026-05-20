//
//  NvsPSTimelineEditor.h
//  NvsPSTimelineEditor
//
//  Created by LionLee on 2017/8/29.
//  Copyright © 2017年 CDV. All rights reserved.
//

#ifndef NvsPSTimelineEditor_h
#define NvsPSTimelineEditor_h


#pragma once

#import <UIKit/UIKit.h>
#import "NvsPSTimelineTimeSpan.h"


@interface NvsPSTimelineEditorInfo : NSObject

@property (nonatomic, strong) NSString* mediaFilePath;
@property (nonatomic, assign) int64_t inPoint;
@property (nonatomic, assign) int64_t outPoint;
@property (nonatomic, assign) int64_t trimIn;
@property (nonatomic, assign) int64_t trimOut;
@property (nonatomic, assign) bool stillImageHint;

@end

@protocol NvsPSTimelineEditorDelegate <NSObject>

@optional

- (void)timelineEditor:(id)timelineEditor dragHandleStarted:(int64_t)timestamp isInPoint:(bool)isInPoint;

- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint;

- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)timestamp isInPoint:(bool)isInPoint;

- (void)timelineEditor:(id)timelineEditor dragScrollingTimeline:(int64_t)timestamp;

- (void)timelineEditor:(id)timelineEditor dragScrollTimelineEnded:(int64_t)timestamp;

- (void)timelineEditor:(id)timelineEditor handlePan:(int64_t)timestamp;

@end


@interface NvsPSTimelineEditor : UIView

@property (nonatomic, weak) id <NvsPSTimelineEditorDelegate> delegate;
@property (nonatomic, assign) bool canOverlapTimeSpan;
@property (nonatomic, assign) bool caneditTimeSpan;
@property (nonatomic, assign) int64_t timelinePosition;
@property (nonatomic, assign) NSUInteger type;

//- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
//- (instancetype)initWithCoder:(NSCoder *)aDecoder;

- (void) initTimelineEditor:(NSArray*) timelineEditorInfos timelineDuration:(int64_t)timelineDuration;
- (NvsPSTimelineTimeSpan*) addTimeSpan:(int64_t)inPoint outPoint:(int64_t)outPoint;
- (void) deleteSelectedTimeSpan;
- (void) deleteAllTimeSpan;
- (void) selectTimeSpan:(NvsPSTimelineTimeSpan*)timeSpan;
- (void) updateSelectedItem;

- (void) updateTrimIn:(CGFloat)trimIn trimOut:(CGFloat)trimOut;

@end


#endif /* NvsPSTimelineEditor_h */
