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
#import "NvThemeModel.h"

@interface NvsMimoTimelineEditorInfo : NSObject

@property (nonatomic, strong) NSString* mediaFilePath;
@property (nonatomic, assign) int64_t inPoint;
@property (nonatomic, assign) int64_t outPoint;
@property (nonatomic, assign) int64_t trimIn;
@property (nonatomic, assign) int64_t trimOut;
@property (nonatomic, assign) bool stillImageHint;

@end

@protocol NvsMimoTimelineEditorDelegate <NSObject>

@optional

/**
 截取片段
 Take a snippet
 @param timelineEditor 本身
 @param trimIn 起点时间（微秒）
 @param trimOut 终点时间（微秒）
 */
- (void)timelineEditor:(id)timelineEditor trimIn:(CGFloat)trimIn trimOut:(CGFloat)trimOut;

- (void)timelineEditorDidEndScroll:(id)timelineEditor;
@end


@interface NvsMimoTimelineEditor : UIView

@property (nonatomic, weak) id <NvsMimoTimelineEditorDelegate> delegate;
@property (nonatomic, assign) bool canOverlapTimeSpan;
@property (nonatomic, assign) bool caneditTimeSpan;
@property (nonatomic, assign) int64_t timelinePosition;
@property (nonatomic, assign) int64_t targetDuration;
@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, strong) NvShotModel *model;

- (instancetype)initWithFrame:(CGRect)frame;
- (void) initTimelineEditor:(NSArray*) timelineEditorInfos timelineDuration:(int64_t)timelineDuration;
- (CGFloat)getTimelineEditorWidth;
@end


#endif /* NvsTimelineEditor_h */
