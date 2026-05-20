//
//  NvsTimelineEditor.h
//  NvsTimelineEditor
//
//  Created by LionLee on 2017/8/29.
//  Copyright © 2017年 CDV. All rights reserved.
//

#ifndef NvsTimelineEditor_h
#define NvsTimelineEditor_h


#pragma once

#import <UIKit/UIKit.h>
#import "NvsTimelineTimeSpan.h"


@interface NvsTimelineEditorInfo : NSObject

@property (nonatomic, strong) NSString* mediaFilePath;
@property (nonatomic, assign) int64_t inPoint;
@property (nonatomic, assign) int64_t outPoint;
@property (nonatomic, assign) int64_t trimIn;
@property (nonatomic, assign) int64_t trimOut;
@property (nonatomic, assign) bool stillImageHint;

@end

@protocol NvsTimelineEditorDelegate <NSObject>

@optional

- (void)timelineEditor:(id)timelineEditor dragHandleStarted:(int64_t)timestamp isInPoint:(bool)isInPoint;

- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint;

- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)timestamp isInPoint:(bool)isInPoint;

- (void)timelineEditor:(id)timelineEditor dragScrollingTimeline:(int64_t)timestamp;

- (void)timelineEditor:(id)timelineEditor dragScrollTimelineEnded:(int64_t)timestamp;
@end


@interface NvsTimelineEditor : UIView

@property (nonatomic, weak) id <NvsTimelineEditorDelegate> delegate;
@property (nonatomic, assign) bool canOverlapTimeSpan;
@property (nonatomic, assign) bool caneditTimeSpan;
@property (nonatomic, assign) int64_t timelinePosition;


- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

- (void) initTimelineEditor:(NSArray*) timelineEditorInfos timelineDuration:(int64_t)timelineDuration;
- (NvsTimelineTimeSpan*) addTimeSpan:(int64_t)inPoint outPoint:(int64_t)outPoint;
- (void) deleteSelectedTimeSpan;
- (void) deleteAllTimeSpan;
- (void) selectTimeSpan:(NvsTimelineTimeSpan*)timeSpan;
- (void) updateSelectedItem;


@end


#endif /* NvsTimelineEditor_h */
