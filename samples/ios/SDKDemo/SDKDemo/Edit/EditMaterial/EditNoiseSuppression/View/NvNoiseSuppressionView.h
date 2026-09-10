//
//  NvNoiseSuppressionView.h
//  SDKDemo
//
//  Created by Meishe on 2022/9/9.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVHeader.h"
#import "NvsTimeline.h"
#import "NvsCTimelineEditor.h"
NS_ASSUME_NONNULL_BEGIN
@class NvNoiseSuppressionView;

@protocol NvNoiseSuppressionViewDelegate <NSObject>

- (void)noiseSuppressionViewdidAddOkClick;
- (void)dragScrollTimelineEnded:(int64_t)timestamp;

- (void)dragTimelineEditor:(int64_t)timestamp;
- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)timestamp isInPoint:(bool)isInPoint;
- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint;
- (void)noiseSuppressionTimelineEditorZoomIn;
- (void)noiseSuppressionTimelineEditorZoomOut;
- (void)noiseSuppressionView:(NvNoiseSuppressionView *)view selectIndex:(NSInteger)index;
@end
@interface NvNoiseSuppressionView : UIView

@property (assign, nonatomic) id <NvNoiseSuppressionViewDelegate>delegate;
@property (strong, nonatomic) NvsTimeline *timeline;
@property (nonatomic, strong) NvsCTimelineEditor *timelineEditor;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, assign) NSInteger selectedIndex;

- (void)setcurrentTime:(int64_t)time;

- (CGFloat)getTimelineEditorWidth;
@end

NS_ASSUME_NONNULL_END
