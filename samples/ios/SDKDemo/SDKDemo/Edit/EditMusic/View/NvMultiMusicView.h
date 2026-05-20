//
//  NvMultiMusicView.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/9/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsTimeline.h"
#import "NvTimelineUtils.h"
#import "NvsCTimelineEditor.h"

@protocol NvMultiMusicViewDelegate <NSObject>

- (void)onPlayClicked;
- (void)onAddMusicClicked;
- (void)onDeleteMusicClicked;
- (void)onFinishAddMusic;
- (void)updateMusicInfo:(int64_t)timestamp isInPoint:(bool)isInPoint with:(NvsCTimelineEditor *)editor;
- (void)onFadeBtnClicked:(BOOL)isFade;
- (void)onVolumeChanged:(float)volume;
@end

@interface NvMultiMusicView : UIView

@property (weak, nonatomic) id<NvMultiMusicViewDelegate> delegate;
@property (nonatomic, assign) NvEditMode editMode;
- (void)setupLiveWindow:(NvsTimeline *)timeline;
- (void)setupSequenceView:(NSMutableArray *)descArray;
- (void)updateTimelineEditor:(int64_t)pos;
- (void)addTimespan:(int64_t)inPoint outPoint:(int64_t)outPoint;
- (void)deleteAllmusic;

- (void)addMusicFade;
@end
