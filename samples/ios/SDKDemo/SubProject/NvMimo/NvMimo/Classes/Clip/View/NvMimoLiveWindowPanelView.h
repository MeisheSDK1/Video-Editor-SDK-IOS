//
//  NvLiveWindowPanelView.h
//  SDKDemo
//
//  Created by meishe01 on 2018/5/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsTimeline.h"
#import "NvsStreamingContext.h"
#import "NVHeader.h"
#import "NVMimoDefineConfig.h"

@protocol NvMimoLiveWindowPanelViewDelegate <NSObject>

@optional
- (void)playback;
- (void)volumnClicked;

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position;

- (void)didPlaybackStopped:(NvsTimeline *)timeline;

- (void)didPlaybackEOF:(NvsTimeline *)timeline;

- (void)sliderValueChanged:(float)value;

- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state;

@end

@interface NvMimoLiveWindowPanelView : UIView

@property (nonatomic, weak) id <NvMimoLiveWindowPanelViewDelegate> delegate;
@property (nonatomic, strong) NvsLiveWindow *liveWindow;
@property (nonatomic, strong) UIView *controlPanelView;
@property (nonatomic, assign) NvMimoEditMode editMode;

@property (nonatomic, assign) int64_t currentTime;

@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, assign) BOOL forceHiddenControlPanel;

- (instancetype)initWithFrame:(CGRect)frame isShowCaptionInfo:(BOOL)isShowCaptionInfo ;
- (void)connectTimeline:(NvsTimeline *)timeline;

//设置从这个位置播放
// Set to play from this location
- (void)playAtTime:(int64_t)pos;
//从start播放到end
// Play from start to end
- (void)playBackStart:(int64_t)start end:(int64_t)end;
//调用点击播放按钮的方法
// Call the method that clicks the play button
- (void)playbackBtnClicked;
//显示ControllPanel，并会开启定时器3秒后消失
// Shows the ControllPanel, which will turn on the timer for 3 seconds and then disappear
- (void)showControllPanel;
//隐藏音量按钮
// Hide the volume button
- (void)hiddenVolumeButton;
//点击屏幕暂停
// Tap the screen to pause
- (void)addTapScreenPause;
//移除点击屏幕暂停
// Remove the tap screen pause
- (void)removeTapScreenPause;
//是否是用户自己点击暂停
// Is the user clicking pause
- (BOOL)isUserPause;
@end
