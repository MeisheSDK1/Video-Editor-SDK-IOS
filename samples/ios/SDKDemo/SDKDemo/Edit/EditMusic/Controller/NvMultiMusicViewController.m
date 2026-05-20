//
//  NvMultiMusicViewController.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/9/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMultiMusicViewController.h"
#import "NvMultiMusicView.h"
#import "NvTimelineUtils.h"
#import "NvSelectMusicViewController.h"
#import "NvUrlVideoMaterialVC.h"

@interface NvMultiMusicViewController ()<NvMultiMusicViewDelegate, NvSelectMusicViewControllerDelegate, NvsStreamingContextDelegate, NvUrlVideoMaterialVCDelegate>

@end

@implementation NvMultiMusicViewController {
    NvMultiMusicView *contentView;
    NvsStreamingContext *context;
    NvsTimeline *timeline;
    int64_t inPoint;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    contentView = [[NvMultiMusicView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-44 - NV_STATUSBARHEIGHT)];
    contentView.editMode = self.editMode;
    [self.view addSubview:contentView];
    
    context = [NvsStreamingContext sharedInstance];
    timeline = [NvTimelineUtils createTimeline:self.editMode];
    [NvTimelineUtils recreateTimeline:timeline];
    
    [contentView setupLiveWindow:timeline];
    [contentView setupSequenceView:[NvTimelineUtils getThumbnailSequenceDescArray:timeline]];
    contentView.delegate = self;
    
    [NvTimelineUtils seekTimeline:timeline timestamp:0 flags:NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}

#pragma mark NvMultiMusicViewDelegate
- (void)onAddMusicClicked {
    [NvTimelineUtils seekTimeline:timeline timestamp:[context getTimelineCurrentPosition:timeline] flags:NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"urlEdit"] boolValue]) {
        NvUrlVideoMaterialVC *vc = [[NvUrlVideoMaterialVC alloc] init];
        vc.isMusicEdit = true;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NvSelectMusicViewController *vc = NvSelectMusicViewController.new;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)onDeleteMusicClicked {
    
    NSMutableArray *musicDataArray = [[NvTimelineData sharedInstance] musicDataArray];
    for (NvMusicInfoModel *musicInfo in musicDataArray) {
        int64_t curPos = [context getTimelineCurrentPosition:timeline];
        if (curPos >= musicInfo.inPoint && curPos <= musicInfo.outPoint) {
            [musicDataArray removeObject:musicInfo];
            break;
        }
    }
    [[NvTimelineData sharedInstance] setMusicDataArray:musicDataArray];
    [NvTimelineUtils resetMusicTrack:timeline musicDataArray:[[NvTimelineData sharedInstance] musicDataArray]];
}

- (void)onPlayClicked {
    int64_t curPos = [context getTimelineCurrentPosition:timeline];
    if ([context getStreamingEngineState] != NvsStreamingEngineState_Playback) {
        [NvTimelineUtils playbackTimeline:timeline startTime:curPos endTime:timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
    } else {
        [context stop];
    }
}
- (void)updateMusicInfo:(int64_t)timestamp isInPoint:(bool)isInPoint with:(NvsCTimelineEditor *)editor{
    ///isInPoint为true是裁入点，false是裁出点
    ///isInPoint if true is the crop point, false is the crop point
    NSMutableArray *musicDataArray = [[NvTimelineData sharedInstance] musicDataArray];
    int64_t curPos = [context getTimelineCurrentPosition:timeline];
    for (NvMusicInfoModel *musicInfo in musicDataArray) {
        if (curPos >= musicInfo.inPoint && curPos <= musicInfo.outPoint) {
            if (isInPoint){
                musicInfo.inPoint = timestamp;
                if (timestamp > curPos) {
                    [editor selectTimeSpan:nil];
                }
            }else{
                musicInfo.outPoint = timestamp;
                if (timestamp < curPos) {
                    [editor selectTimeSpan:nil];
                }
            }
            break;
        }
    }
    [NvTimelineUtils resetMusicTrack:timeline musicDataArray:[[NvTimelineData sharedInstance] musicDataArray]];
}

- (void)onFadeBtnClicked:(BOOL)isFade {
    NSMutableArray *musicDataArray = [[NvTimelineData sharedInstance] musicDataArray];
    for (NvMusicInfoModel *musicInfo in musicDataArray) {
        int64_t curPos = [context getTimelineCurrentPosition:timeline];
        if (curPos >= musicInfo.inPoint && curPos <= musicInfo.outPoint) {
            musicInfo.isFade = isFade;
            break;
        }
    }
    [NvTimelineUtils resetMusicTrack:timeline musicDataArray:[[NvTimelineData sharedInstance] musicDataArray]];
}

- (void)onFinishAddMusic {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onVolumeChanged:(float)volume {
    NSMutableArray *musicDataArray = [[NvTimelineData sharedInstance] musicDataArray];
    for (NvMusicInfoModel *musicInfo in musicDataArray) {
        int64_t curPos = [context getTimelineCurrentPosition:timeline];
        if (curPos >= musicInfo.inPoint && curPos <= musicInfo.outPoint) {
            musicInfo.volume = volume;
            break;
        }
    }
    [NvTimelineUtils resetMusicTrack:timeline musicDataArray:[[NvTimelineData sharedInstance] musicDataArray]];
}

#pragma mark NvSelectMusicViewControllerDelegate
- (void)selectMusicViewController:(NvSelectMusicViewController *)selectMusicViewController withItem:(NvEditSelectMusicItem *)item trimIn:(float)trimIn trimOut:(float)trimOut {
    
    NvMusicInfoModel *musicInfo = [NvMusicInfoModel new];
    musicInfo.musicPath = item.musicPath;
    musicInfo.inPoint = [context getTimelineCurrentPosition:timeline];
    musicInfo.trimIn = trimIn*NV_TIME_BASE;
    musicInfo.trimOut = trimOut*NV_TIME_BASE;
    ///如果超过时间线长度，裁剪
    ///If time line length is exceeded, crop
    if (musicInfo.inPoint + musicInfo.trimOut - musicInfo.trimIn > timeline.duration) {
        musicInfo.trimOut = musicInfo.trimIn + timeline.duration - musicInfo.inPoint;
    }
    musicInfo.outPoint = musicInfo.inPoint + musicInfo.trimOut - musicInfo.trimIn;
    ///如果裁剪长度覆盖了另一个片段，裁剪
    ///If the cropping length covers another segment, crop
    
    ///在循环中查找最近的音乐在时间线上的裁入点，然后赋值
    ///Find the most recent music crop point in the timeline in the loop and assign a value
    int64_t temporary = musicInfo.outPoint;
    
    for (NvMusicInfoModel *info in [[NvTimelineData sharedInstance] musicDataArray]) {
        if (musicInfo.outPoint >= info.inPoint && musicInfo.inPoint <= info.inPoint) {
            if (info.inPoint < temporary) {
                temporary = info.inPoint;
            }
            continue;
        }
    }
    if (temporary != musicInfo.outPoint) {
        musicInfo.outPoint = temporary - 1;
        musicInfo.trimOut = musicInfo.trimIn + musicInfo.outPoint - musicInfo.inPoint;
    }
    
    musicInfo.musicName = item.musicName;
    musicInfo.volume = 1;

    [[[NvTimelineData sharedInstance] musicDataArray] addObject:musicInfo];
    [NvTimelineUtils resetMusicTrack:timeline musicDataArray:[[NvTimelineData sharedInstance] musicDataArray]];
    [contentView addMusicFade];
    [contentView addTimespan:musicInfo.inPoint outPoint:musicInfo.outPoint];
}

- (void)selectNoneMusic {
    [contentView deleteAllmusic];
    NSMutableArray *musicDataArray = [[NvTimelineData sharedInstance] musicDataArray];
    [musicDataArray removeAllObjects];
    [[NvTimelineData sharedInstance] setMusicDataArray:musicDataArray];
    [NvTimelineUtils resetMusicTrack:timeline musicDataArray:[[NvTimelineData sharedInstance] musicDataArray]];
    
}

#pragma mark - NvUrlVideoMaterialVCDelegate
- (void)selectMusicItem:(NvListMediaInfoModel *)item trimIn:(float)trimIn trimOut:(float)trimOut{
    NvMusicInfoModel *musicInfo = [NvMusicInfoModel new];
    musicInfo.musicPath = item.url;
    musicInfo.inPoint = [context getTimelineCurrentPosition:timeline];
    musicInfo.trimIn = trimIn*NV_TIME_BASE;
    musicInfo.trimOut = trimOut*NV_TIME_BASE;
    ///如果超过时间线长度，裁剪
    ///If time line length is exceeded, crop
    if (musicInfo.inPoint + musicInfo.trimOut - musicInfo.trimIn > timeline.duration) {
        musicInfo.trimOut = musicInfo.trimIn + timeline.duration - musicInfo.inPoint;
    }
    musicInfo.outPoint = musicInfo.inPoint + musicInfo.trimOut - musicInfo.trimIn;
    ///如果裁剪长度覆盖了另一个片段，裁剪
    ///If the cropping length covers another segment, crop
    
    ///在循环中查找最近的音乐在时间线上的裁入点，然后赋值
    ///Find the most recent music crop point in the timeline in the loop and assign a value
    int64_t temporary = musicInfo.outPoint;
    
    for (NvMusicInfoModel *info in [[NvTimelineData sharedInstance] musicDataArray]) {
        if (musicInfo.outPoint >= info.inPoint && musicInfo.inPoint <= info.inPoint) {
            if (info.inPoint < temporary) {
                temporary = info.inPoint;
            }
            continue;
        }
    }
    if (temporary != musicInfo.outPoint) {
        musicInfo.outPoint = temporary - 1;
        musicInfo.trimOut = musicInfo.trimIn + musicInfo.outPoint - musicInfo.inPoint;
    }
    
    musicInfo.musicName = item.displayName;
    musicInfo.volume = 1;

    [[[NvTimelineData sharedInstance] musicDataArray] addObject:musicInfo];
    [NvTimelineUtils resetMusicTrack:timeline musicDataArray:[[NvTimelineData sharedInstance] musicDataArray]];
    [contentView addMusicFade];
    [contentView addTimespan:musicInfo.inPoint outPoint:musicInfo.outPoint];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
