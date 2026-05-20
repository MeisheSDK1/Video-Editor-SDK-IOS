//
//  NvEditClipLiveWindow.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/8/7.
//  Copyright © 2018年 meishe. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "NVHeader.h"
#import "NvsLiveWindow.h"
#import "NvsVideoClip.h"
#import "NvsTimeline.h"
#import "NvsStreamingContext.h"
//#import "NvMimoTimelineDataModel.h"
#import "NvThemeModel.h"

@protocol NvMimoEditClipLiveWindowDelegate

@optional
- (void)playback;
- (void)volumnClicked;

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position;

- (void)didPlaybackStopped:(NvsTimeline *)timeline;

- (void)didPlaybackEOF:(NvsTimeline *)timeline;

- (void)sliderValueChanged:(float)value;

- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state;
@end

@interface NvMimoEditClipLiveWindow : UIView
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NvsLiveWindow *liveWindow;
@property (nonatomic, assign) NvMimoEditMode editMode;
@property (nonatomic, strong) NvShotModel *model;
@property (nonatomic, strong, readonly) UISlider *progressSlider;
@property (nonatomic, assign) BOOL isPause;

- (void)connectTimeline:(NvsTimeline *)timeline;

- (void)setPlayRangeIn:(int64_t)rangeIn rangeOut:(int64_t)rangeOut;

- (void)play;

- (void)pause;

- (void)seekTimeline:(int64_t)pos;

- (void)updateUI:(int64_t)timestamp;
@end
