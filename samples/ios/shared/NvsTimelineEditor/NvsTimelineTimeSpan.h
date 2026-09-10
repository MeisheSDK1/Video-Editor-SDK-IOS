//
//  NvsTimelineTimeSpan.h
//  NvsTimelineEditor
//
//  Created by LionLee on 2017/8/29.
//  Copyright © 2017年 CDV. All rights reserved.
//

#ifndef NvsTimelineTimeSpan_h
#define NvsTimelineTimeSpan_h

#pragma once

#import <UIKit/UIKit.h>


@protocol NvsTimelineTimeSpanDelegate <NSObject>

@optional

- (void)timeSpan:(id)timeSpan dragHandleStarted:(UIView*)timeSpanItem isLeftHandle:(bool)isLeftHandle;

- (void)timeSpan:(id)timeSpan draggingHandle:(UIView*)timeSpanItem isLeftHandle:(bool)isLeftHandle xOffset:(double)xOffset;

- (void)timeSpan:(id)timeSpan dragHandleEnded:(UIView*)timeSpanItem isLeftHandle:(bool)isLeftHandle;

@end



@interface NvsTimelineTimeSpan : UIView

@property (nonatomic, weak) id <NvsTimelineTimeSpanDelegate> delegate;
@property (nonatomic, assign) int64_t inPoint;
@property (nonatomic, assign) int64_t outPoint;
@property (nonatomic, assign) double padding;
@property (nonatomic, assign) double pointsPerMicrosecond;
@property (nonatomic, assign) bool selected;
@property (nonatomic, assign) bool editable;


- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)updateFrame;

@end


#endif /* NvsTimelineTimeSpan_h */
