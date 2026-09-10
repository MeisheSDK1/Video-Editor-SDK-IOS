//
//  NvEditBaseViewController.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import "NvLiveWindowPanelView.h"
#import "NvsStreamingContext.h"

//包含了livewindow并且根据model做了宽高的适配
@interface NvEditBaseViewController : NvBaseViewController

@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, assign) NvEditMode editMode;
@property (nonatomic, strong) NvLiveWindowPanelView *liveWindowPanel;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;

- (void)seekTimeline;
- (void)seekTimelineWithoutFlag;
- (void)seekTimeline:(int64_t)postion;
- (void)seekTimelineWithoutFlag:(int64_t)postion;
@end
