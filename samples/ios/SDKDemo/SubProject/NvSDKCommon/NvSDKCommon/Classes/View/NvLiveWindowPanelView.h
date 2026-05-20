//
//  NvLiveWindowPanelView.h
//  SDKDemo
//
//  Created by meishe01 on 2018/5/30.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NvStreamingSdkCore/NvsTimeline.h>
#import <NvStreamingSdkCore/NvsStreamingContext.h>
#import <NvBaseCommon/NVDefineConfig.h>

@protocol NvLiveWindowPanelViewDelegate <NSObject>

@optional
- (void)playback;
- (void)volumnClicked;

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position;

- (void)didPlaybackStopped:(NvsTimeline *)timeline;

- (void)didPlaybackEOF:(NvsTimeline *)timeline;

- (void)sliderValueChanged:(float)value;

- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state;

- (void)didTapLiveWindowAtTime:(int64_t)pos;
- (void)didTapLiveWindowStop;

@end

@interface NvLiveWindowPanelView : UIView <NvsStreamingContextDelegate>

@property (nonatomic, weak) id <NvLiveWindowPanelViewDelegate> delegate;
@property (nonatomic, strong) NvsLiveWindow *liveWindow;
@property (nonatomic, strong) UIView *controlPanelView;
@property (nonatomic, assign) NvEditMode editMode;
///不需要代理seek操作
///No proxy seek operation is required
@property (nonatomic, assign) BOOL dontNeedSeekCtl;
@property (nonatomic, assign) int64_t currentTime;

@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, assign) BOOL forceHiddenControlPanel;
@property (nonatomic, assign) BOOL alwaysShowControlPanel;
///只播放其中动画
///Play only the animations
@property (nonatomic, assign) BOOL isAnimationPlayback;
@property (nonatomic, assign) int64_t duration;

- (void)connectTimeline:(NvsTimeline *)timeline;

- (void)seekTimeline:(int64_t)pos;

///设置从这个位置播放
///Set to play from this position
- (void)playAtTime:(int64_t)pos;
///从start播放到end
///Play from start to end
- (void)playBackStart:(int64_t)start end:(int64_t)end;
///调用点击播放按钮的方法
///Invoke the method that clicks the Play button
- (void)playbackBtnClicked;
///显示ControllPanel，并会开启定时器3秒后消失
///Displays ControllPanel and will start timer for 3 seconds before vanishing
- (void)showControllPanel;
///隐藏音量按钮
///Hide volume button
- (void)hiddenVolumeButton;
///点击屏幕暂停
///Click screen pause
- (void)addTapScreenPause;
///移除点击屏幕暂停
///Remove click screen pause
- (void)removeTapScreenPause;
///是否是用户自己点击暂停
///Whether the user clicked pause by themselves
- (BOOL)isUserPause;
@end
