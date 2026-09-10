//
//  NvEditBaseViewController.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import "NvLiveWindowPanelView.h"
#import <NvStreamingSdkCore/NvsStreamingContext.h>

///包含了livewindow并且根据model做了宽高的适配
///Includes the livewindow and ADAPTS the width and height according to the model
@interface NvEditBaseViewController : NvBaseViewController

@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, assign) NvEditMode editMode;
@property (nonatomic, strong) NvLiveWindowPanelView *liveWindowPanel;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, assign) BOOL isChange;
@property (nonatomic, assign) CGFloat scaleForSeek;
- (void)seekTimeline;
- (void)seekTimelineWithoutFlag;
- (void)seekTimeline:(int64_t)postion;
- (void)seekTimelineWithoutFlag:(int64_t)postion;
@end
