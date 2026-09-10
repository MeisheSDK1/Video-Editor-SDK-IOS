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
#import "NvTimelineDataModel.h"

@protocol NvEditClipLiveWindowDelegate

@optional
- (void)playback;
- (void)volumnClicked;

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position;

- (void)didPlaybackStopped:(NvsTimeline *)timeline;

- (void)didPlaybackEOF:(NvsTimeline *)timeline;

- (void)sliderValueChanged:(float)value;

- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state;
@end

@interface NvEditClipLiveWindow : UIView
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NvsLiveWindow *liveWindow;
@property (nonatomic, assign) NvEditMode editMode;
@property (nonatomic, strong, readonly) UISlider *progressSlider;
@property (nonatomic, assign) BOOL isPause;
//链接timeline Link timeline
- (void)connectTimeline:(NvsTimeline *)timeline;
//设置播放时间范围 Set the play time range
- (void)setPlayRangeIn:(int64_t)rangeIn rangeOut:(int64_t)rangeOut;
//播放 play
- (void)play;
//暂停 pause
- (void)pause;
//定位到某一帧画面 Locate a frame
- (void)seekTimeline:(int64_t)pos;

- (void)playbackTimeline:(int64_t)timestamp;

- (void)updateUI:(int64_t)timestamp;
@end
