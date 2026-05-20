//
//  NvsPSTimelineTimeSpan.h
//  NvsTimelineEditor
//
//  Created by LionLee on 2017/8/29.
//  Copyright © 2017年 CDV. All rights reserved.
//

#ifndef NvsPSTimelineTimeSpan_h
#define NvsPSTimelineTimeSpan_h

#pragma once

#import <UIKit/UIKit.h>


@protocol NvsPSTimelineTimeSpanDelegate <NSObject>

@optional

- (void)timeSpan:(id)timeSpan dragHandleStarted:(UIView*)timeSpanItem isLeftHandle:(bool)isLeftHandle;

- (void)timeSpan:(id)timeSpan draggingHandle:(UIView*)timeSpanItem isLeftHandle:(bool)isLeftHandle xOffset:(double)xOffset;

- (void)timeSpan:(id)timeSpan dragHandleEnded:(UIView*)timeSpanItem isLeftHandle:(bool)isLeftHandle;

@end



@interface NvsPSTimelineTimeSpan : UIView

@property (nonatomic, weak) id <NvsPSTimelineTimeSpanDelegate> delegate;
@property (nonatomic, assign) int64_t inPoint;
@property (nonatomic, assign) int64_t outPoint;
@property (nonatomic, assign) double padding;
@property (nonatomic, assign) double pointsPerMicrosecond;
@property (nonatomic, assign) double pitchMoved;
@property (nonatomic, assign) bool selected;
@property (nonatomic, assign) bool editable;
@property (nonatomic, assign) CGFloat viewHeight;

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)updateFrame;

@end


#endif /* NvsPSTimelineTimeSpan_h */
