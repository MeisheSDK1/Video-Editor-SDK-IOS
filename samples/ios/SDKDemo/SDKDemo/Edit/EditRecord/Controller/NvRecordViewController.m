//
//  NvRecordViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/8/6.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvRecordViewController.h"
#import "NvTimelineUtils.h"
#import "NvTimelineData.h"
#import "NVHeader.h"
#import "NvRecord.h"
#import "NvVoiceTypeView.h"
#import "NvSequenceViewCtl.h"
#import "NvsAudioClip.h"
#import "NvsAudioFx.h"
#import "NvRecordModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NvSystemVolume.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvsTimelineAnimatedSticker.h"
#import <CQMenuTabView.h>
#import "NvDubNoiseSuppressionView.h"

typedef enum : NSUInteger {
    NvRecordingStart,//准备录制 Ready to record
    NvRecordingStop,//录制过程中 During recording
    NvRecordingDelete,//准备删除 Ready to delete
} NvRecordingStatus;

@interface NvRecordViewController ()<NvLiveWindowPanelViewDelegate, NvsStreamingContextDelegate, NvSequenceViewCtlDelegate, NvDubNoiseSuppressionViewDelegate> {
    float left,right,musicLeft,musicRight,themeLeft,themeRight;
    NvSystemVolume *volumeView;
}

@property (nonatomic, strong) NvButton *minusButton;
@property (nonatomic, strong) NvButton *addButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *styleButton;
@property (nonatomic, strong) UIButton *okButton;
///配音数据
///Dubbing data
@property (nonatomic, strong) NvDubbingModel *dubbingModel;
///录音对象
///Recording object
@property (nonatomic, strong) NvRecord *record;
@property (nonatomic, strong) UIButton *addRecordButton;
@property (nonatomic, assign) NvRecordingStatus status;
@property (nonatomic, strong) NSMutableArray *recordingPathInfoArray;
@property (nonatomic, strong) UISlider *volumSlider;
@property (nonatomic, strong) NvVoiceTypeView *voiceTypeView;
@property (nonatomic, strong) NvSequenceViewCtl *sequenceView;
@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, assign) int64_t currentPosition;
@property (nonatomic, strong) NvsAudioTrack *audioTrack;
@property (nonatomic, strong) NvsAudioClip *clip;
///当前录音数据对象
///Current recording data object
@property (nonatomic, strong) NvRecordModel *model;
///是否是手动播放，还是录制播放
///Whether it is played manually or recorded
@property (nonatomic, assign) BOOL isManualPlay;
///当前录音过程中需要移除的clip
///clip to be removed during recording
@property (nonatomic, strong) NSMutableArray *needRemoveClip;
@property (nonatomic, assign) BOOL granted;
///是否是特效模式
///Effect mode or not
@property (nonatomic, assign) BOOL isFxModel;
///fx当前的时间
///fx Indicates the current time
@property (nonatomic, assign) int64_t fxPosition;
///系统声音
///System sound
@property (nonatomic) float volume;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) NSMutableArray *stickersVolumeArray;
@property (nonatomic, strong) CQMenuTabView *tabView;
@property (nonatomic, strong) NvDubNoiseSuppressionView *noiseSuppressionView;
@property (nonatomic, assign) NSInteger selectedIndicator;
@end

@implementation NvRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NvLocalString(@"Dubbing", @"配音");
    self.recordingPathInfoArray = [NSMutableArray array];
    self.stickersVolumeArray = [NSMutableArray array];
    [self initTimeline];
    
    self.needRemoveClip = [NSMutableArray array];
    [self initSubViews];
    [self.liveWindowPanel setForceHiddenControlPanel:YES];
    [self.liveWindowPanel addTapScreenPause];
    self.liveWindowPanel.delegate = self;
    self.record = [NvRecord new];
    self.timeLabel.text= [NSString stringWithFormat:@"%@/%@",[NvUtils convertTimecodePrecision:self.currentPosition],[NvUtils convertTimecodePrecision:self.timeline.duration]];
    [self setSequenceDefaultData];
    [self showFxVolume];
    AVAudioSession *session =[AVAudioSession sharedInstance];
    self.granted = YES;
    [session requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            [NvToast showInfoWithMessage:NvLocalString(@"Recording.permission", @"录音权限被禁止")];
            self->_granted = granted;
            return ;
        }
    }];
}
///MARK: 返回按钮
///Back button
- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

///MARK:给Sequence设置默认数据
///MARK: Set default data to the Sequence
- (void)setSequenceDefaultData {
    for (int i = 0; i < self.dubbingModel.dubbingInfoModels.count; i++) {
        NvDubbingInfoModel *modelInfo = self.dubbingModel.dubbingInfoModels[i];
        NvRecordModel *model = [NvRecordModel new];
        model.recordingPath = modelInfo.dubbingFilePath;
        model.inpoint = modelInfo.inPoint;
        model.trimIn = modelInfo.trimIn;
        model.outpoint = modelInfo.inPoint + modelInfo.duration - modelInfo.trimIn;
        model.volume = modelInfo.volume;
        model.builtInFxName = modelInfo.builtInFxName;
        model.audioNoiseSuppressionLevel = modelInfo.audioNoiseSuppressionLevel;
        [self.recordingPathInfoArray addObject:model];
    }
    [self.sequenceView updateSpanItems:self.recordingPathInfoArray];
}

- (void)showFxVolume {
    self.clip = [self.audioTrack getClipWithTimelinePosition:self.currentPosition];
    if (self.clip) {
        self.status = NvRecordingDelete;
    } else {
        self.status = NvRecordingStart;
    }
    
    ///是否显示特效按钮
    ///Whether to display the effects button
    self.styleButton.hidden = !self.clip;
    self.volumSlider.hidden = !self.clip;
    self.model = [self getModelWithClip:self.clip];
    if (self.clip) {
        float left;
        [self.clip getVolumeGain:&left rightVolumeGain:&left];
        self.volumSlider.value = left;
    }
}

///MARK:重新创建timeline和数据结构
///MARK: Re-create timeline and data structures
- (void)initTimeline {
    self.timeline = [NvTimelineUtils createTimeline:self.editMode];
    [NvTimelineUtils recreateTimeline:self.timeline];
    NvTimelineData *data = [NvTimelineData sharedInstance];
    self.dubbingModel = [data.dubbingModel copy];
    [NvTimelineUtils resetDubbingTrack:self.timeline dubbingModel:self.dubbingModel];
    self.audioTrack = [self.timeline getAudioTrackByIndex:NV_DUBBING_SOUND_TRACK];
}

- (void)setStatus:(NvRecordingStatus)status {
    _status = status;
    if (status == NvRecordingStart) {
        [self.addRecordButton setImage:NvImageNamed(@"NvRecordingStart") forState:UIControlStateNormal];
    } else if (status == NvRecordingStop) {
        [self.addRecordButton setImage:NvImageNamed(@"NvRecordingStop") forState:UIControlStateNormal];
    } else {
        [self.addRecordButton setImage:NvImageNamed(@"deleteRecord") forState:UIControlStateNormal];
    }
}
///MARK:更改音量
///MARK: Change the volume
- (void)volumChanged:(UISlider *)slider {
    self.model.volume = slider.value;
    NvsAudioClip *clip = [self.audioTrack getClipWithTimelinePosition:self.currentPosition];
    [clip setVolumeGain:slider.value rightVolumeGain:slider.value];
}

- (void)fxClick {
    self.isFxModel = YES;
    self.fxPosition = self.currentPosition;
    NvsAudioClip *clip = [self.audioTrack getClipWithTimelinePosition:self.currentPosition];
    NvsAudioFx *fx = (NvsAudioFx *)[clip getAttachment:@"nv_audioFx"];
    NSString *name = fx.bultinAudioFxName;
    for (NvVoiceItem *item in self.voiceTypeView.dataSource) {
        if ((item.builtinName == nil && name == nil) || [item.builtinName isEqualToString:name]) {
            item.isSelect = YES;
        } else {
            item.isSelect = NO;
        }
    }
    self.voiceTypeView.dataSource = self.voiceTypeView.dataSource;
}
///MARK:保存默认音量数据并设置当前音量为0
///MARK: Save the default volume data and set the current volume to 0
- (void)saveOriginVideoVolume {
    [self.stickersVolumeArray removeAllObjects];
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    [videoTrack getVolumeGain:&left rightVolumeGain:&right];
    [videoTrack setVolumeGain:0 rightVolumeGain:0];
    NvsAudioTrack *audioTrack = [self.timeline getAudioTrackByIndex:NV_MUSIC_SOUND_TRACK];
    [audioTrack getVolumeGain:&musicLeft rightVolumeGain:&musicRight];
    [audioTrack setVolumeGain:0 rightVolumeGain:0];
    [self.timeline getThemeMusicVolumeGain:&themeLeft rightVolumeGain:&themeRight];
    [self.timeline setThemeMusicVolumeGain:0 rightVolumeGain:0];
    NvsTimelineAnimatedSticker *sticker = [self.timeline getFirstAnimatedSticker];
    float stickerLeft = 0;
    float stickerRight = 0;
    NSArray *tempArray;
    while (sticker) {
        [sticker getVolumeGain:&stickerLeft rightVolumeGain:&stickerRight];
        [sticker setVolumeGain:0 rightVolumeGain:0];
        tempArray = @[@(stickerLeft),@(stickerRight)];
        [self.stickersVolumeArray addObject:tempArray];
        sticker = [self.timeline getNextAnimatedSticker:sticker];
    }
}

///MARK: 重新设置音量
///MARK: Reset the volume
- (void)resetOriginVideoVolume {
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    [videoTrack setVolumeGain:left rightVolumeGain:right];
    NvsAudioTrack *audioTrack = [self.timeline getAudioTrackByIndex:NV_MUSIC_SOUND_TRACK];
    [audioTrack setVolumeGain:musicLeft rightVolumeGain:musicRight];
    [self.timeline setThemeMusicVolumeGain:themeLeft rightVolumeGain:themeRight];
    NvsTimelineAnimatedSticker *sticker = [self.timeline getFirstAnimatedSticker];
    int i = 0;
    while (sticker) {
        [sticker setVolumeGain:[self.stickersVolumeArray[i][0] floatValue] rightVolumeGain:[self.stickersVolumeArray[i][1] floatValue]];
        sticker = [self.timeline getNextAnimatedSticker:sticker];
        i++;
    }
}
///MARK: 开始录制包含UI变化
///MARK: Start recording with UI changes
- (void)startRecording {
    [self.liveWindowPanel removeTapScreenPause];
    self.status = NvRecordingStop;
    [self.streamingContext stop];
    self.addButton.userInteractionEnabled = NO;
    self.minusButton.userInteractionEnabled = NO;
    self.addRecordButton.userInteractionEnabled = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.addRecordButton.userInteractionEnabled = YES;
    });
    self.isManualPlay = NO;
    [self saveOriginVideoVolume];
    [self.liveWindowPanel playbackBtnClicked];
    [self.sequenceView setSequenceViewScrollEnabled:NO];
    NSString *recordingPath = [self.record startRecord];
    ///静音
    ///mute
    volumeView = [NvSystemVolume instence];
    [self.view addSubview:volumeView];
    self.volume = volumeView.volume;
    if ([recordingPath isEqualToString:@""]) {
        [self.liveWindowPanel addTapScreenPause];
        [NvToast showInfoWithMessage:NvLocalString(@"RecordingAgain", @"录制失败,请重试")];
        ///恢复音量
        ///Restore volume
        volumeView.volume = self.volume;
        [volumeView removeFromSuperview];
        volumeView = nil;
        [self.liveWindowPanel playbackBtnClicked];
        [self.sequenceView setSequenceViewScrollEnabled:YES];
        self.status = NvRecordingStart;
        [self.record stopRecord];
        self.addButton.userInteractionEnabled = YES;
        self.minusButton.userInteractionEnabled = YES;
        self.addRecordButton.userInteractionEnabled = YES;
        return;
    }
    [self.sequenceView startRecording:self.currentPosition];
    self.model = [NvRecordModel new];
    self.model.recordingPath = recordingPath;
    self.model.inpoint = self.currentPosition;
    self.volumSlider.hidden = YES;
    self.playButton.userInteractionEnabled = NO;
}
///MARK: 结束录制包含UI变化
///MARK: End recording includes UI changes
- (void)stopRecording {
    [self.liveWindowPanel addTapScreenPause];
    self.status = NvRecordingStart;
    [self.record stopRecord];
    ///恢复音量
    ///Restore volume
    volumeView.volume = self.volume;
    [volumeView removeFromSuperview];
    volumeView = nil;
    self.addButton.userInteractionEnabled = YES;
    self.minusButton.userInteractionEnabled = YES;
    self.addRecordButton.userInteractionEnabled = YES;
    [self resetOriginVideoVolume];
    [self.sequenceView stopRecording];
    [self.liveWindowPanel playbackBtnClicked];
    [self.sequenceView setSequenceViewScrollEnabled:YES];
    self.model.outpoint = self.currentPosition;
    
    for (int i = 0; i < self.recordingPathInfoArray.count; i++) {
        NvRecordModel *model = self.recordingPathInfoArray[i];
        if (model.inpoint >= self.model.inpoint && self.model.outpoint >=model.inpoint && model.outpoint>=self.model.outpoint) {
            ///覆盖一半需要裁剪trimin
            ///Covering half requires clipping the trimin
            model.trimIn = self.model.outpoint - model.inpoint;
            model.inpoint = self.model.outpoint;
        } else if (model.inpoint >= self.model.inpoint && model.outpoint <= self.model.outpoint) {
            ///直接删除
            ///Direct delete
            [self.recordingPathInfoArray removeObject:model];
            i--;
        }
    }
    
    [self.recordingPathInfoArray addObject:self.model];
    self.playButton.userInteractionEnabled = YES;

    NvsAudioClip *clip = [self.audioTrack addClip:self.model.recordingPath inPoint:self.model.inpoint trimIn:0 trimOut:self.model.outpoint - self.model.inpoint];
    [clip setVolumeGain:self.model.volume rightVolumeGain:self.model.volume];
    ///刷新sequenceView
    ///Refresh the sequenceView
    [self.sequenceView updateSpanItems:self.recordingPathInfoArray];
    
    ///停止录音时，如果当前有录音则要显示删除按钮
    ///When you stop recording, the Delete button will be displayed if there is currently recording
    NvsAudioTrack *audioTrack = [self.timeline getAudioTrackByIndex:NV_DUBBING_SOUND_TRACK];
    self.clip = [audioTrack getClipWithTimelinePosition:self.currentPosition];
    self.model = [self getModelWithClip:self.clip];
    
    ///是否显示特效按钮
    ///Whether to display the effects button
    self.styleButton.hidden = !self.clip;
    self.volumSlider.hidden = !self.clip;
    
    if (self.clip) {
        float left;
        [self.clip getVolumeGain:&left rightVolumeGain:&left];
        self.volumSlider.value = left;
    }
    
    ///滑动时不响应录音
    ///Swiping does not respond to recording
    if (self.clip) {
        self.status = NvRecordingDelete;
    } else {
        self.status = NvRecordingStart;
    }
}
///MARK: 删除录制
///MARK: Delete the recording
- (void)deleteRecording {
    self.status = NvRecordingStart;
    [self.audioTrack removeClip:self.clip.index keepSpace:YES];
    ///删除数据
    ///Delete data
    for (NvRecordModel *model in self.recordingPathInfoArray) {
        if (model.inpoint <= self.currentPosition && model.outpoint >= self.currentPosition) {
            [self.recordingPathInfoArray removeObject:model];
            [self.sequenceView removeSpanItem:self.currentPosition];
            break;
        }
    }
    ///刷新sequenceView
    ///Refresh the sequenceView
    [self.sequenceView updateSpanItems:self.recordingPathInfoArray];
    self.clip = [self.audioTrack getClipWithTimelinePosition:self.currentPosition];
    ///是否显示特效按钮
    ///Whether to display the effects button
    self.styleButton.hidden = !self.clip;
    self.volumSlider.hidden = !self.clip;
}

- (NvRecordModel *)getModelWithClip:(NvsAudioClip *)clip {
    for (int i = 0; i < self.recordingPathInfoArray.count; i++) {
        NvRecordModel *model = self.recordingPathInfoArray[i];
        if (model.inpoint == clip.inPoint && model.outpoint == clip.outPoint) {
            return model;
        }
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
///MARK: 初始化视图
///MARK: initializes the view
- (void)initSubViews {
    self.volumSlider = [[UISlider alloc] initWithFrame:CGRectMake(SCREENWIDTH-125*SCREENSCALE, self.liveWindowPanel.centerY, 191*SCREENSCALE, 20*SCREENSCALE)];
    self.volumSlider.value = 1;
    self.volumSlider.maximumValue = 4;
    [self.volumSlider setThumbImage:NvImageNamed(@"NvSliderHandle") forState:UIControlStateNormal];
    [self.view addSubview:self.volumSlider];
    self.volumSlider.transform = CGAffineTransformRotate(self.volumSlider.transform, -M_PI_2);
    [self.volumSlider addTarget:self action:@selector(volumChanged:) forControlEvents:UIControlEventValueChanged];
    self.volumSlider.hidden = YES;
    
    self.okButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvcheck - material")];
    [self.view addSubview:self.okButton];
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(25*SCREENSCALEHEIGHT));
        make.height.equalTo(@(20*SCREENSCALEHEIGHT));
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALEHEIGHT);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(@(-15*SCREENSCALEHEIGHT));
        }
    }];
    
    ///MARK: 确定按钮
    ///MARK: OK button
    __weak typeof(self)weakSelf = self;
    [self.okButton nv_BtnClickHandler:^{
        ///如果正在录制则停止
        ///Stop if you are recording
        if (weakSelf.record.isRecording) {
            [weakSelf.record stopRecord];
            [weakSelf.liveWindowPanel playbackBtnClicked];
            [weakSelf.sequenceView stopRecording];
            weakSelf.model.outpoint = weakSelf.currentPosition;
            [weakSelf.recordingPathInfoArray addObject:weakSelf.model];
        }
        
        [weakSelf.streamingContext removeTimeline:weakSelf.timeline];
        NSMutableArray *order = [[NvTimelineData sharedInstance] dataOrder];
        [order removeObject:@"Dubbing"];
        [order addObject:@"Dubbing"];
        NvDubbingModel *md = [NvDubbingModel new];
        NSMutableArray *dubArray = [NSMutableArray array];
        for (NvRecordModel *model in weakSelf.recordingPathInfoArray) {
            NvDubbingInfoModel *modelInfo = [NvDubbingInfoModel new];
            modelInfo.dubbingFilePath = model.recordingPath;
            modelInfo.volume = model.volume;
            modelInfo.speed = 1;
            modelInfo.inPoint = model.inpoint;
            modelInfo.trimIn = model.trimIn;
            modelInfo.duration = model.outpoint - model.inpoint + model.trimIn;
            modelInfo.builtInFxName = model.builtInFxName;
            modelInfo.audioNoiseSuppressionLevel = model.audioNoiseSuppressionLevel;
            [dubArray addObject:modelInfo];
        }
        md.dubbingInfoModels = dubArray;
        md.volume = weakSelf.dubbingModel?weakSelf.dubbingModel.volume:1;
        if (dubArray.count == 0) {
            md = nil;
        }
        [[NvTimelineData sharedInstance] setDubbingModel:md];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    self.line = [UIView new];
    self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.view addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(self.okButton.mas_top).offset(-12*SCREENSCALE);
    }];
    
    self.addRecordButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"NvRecordingStart")];
    [self.view addSubview:self.addRecordButton];
    [self.addRecordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.height.equalTo(@(40*SCREENSCALE));
        make.bottom.equalTo(self.okButton.mas_top).offset(-26*SCREENSCALE);
    }];
    
    [self.addRecordButton nv_BtnClickHandler:^{
        if (weakSelf.status == NvRecordingStart) {
            if (weakSelf.granted == NO) {
                return ;
            }
            [weakSelf startRecording];
        } else if (weakSelf.status == NvRecordingStop) {
            [weakSelf stopRecording];
        } else {
            [weakSelf deleteRecording];
        }
    }];
    
    UIView *sequenceView = [UIView new];
    [self.view addSubview:sequenceView];
    sequenceView.backgroundColor = [UIColor clearColor];
    [sequenceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(49*SCREENSCALE));
        make.left.right.equalTo(@0);
        make.bottom.equalTo(self.addRecordButton.mas_top).offset(-26*SCREENSCALE);
    }];
    [self.view layoutIfNeeded];

    self.sequenceView = [[NvSequenceViewCtl alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, sequenceView.height)];
    self.sequenceView.delegate = self;
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    NSMutableArray *clipPath = [NSMutableArray array];
    for (int i = 0; i < videoTrack.clipCount; i++) {
        NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
        NvsThumbnailSequenceDesc *info = [[NvsThumbnailSequenceDesc alloc] init];
        info.mediaFilePath = clip.filePath;
        info.inPoint = clip.inPoint;
        info.outPoint = clip.outPoint;
        info.trimIn = clip.trimIn;
        info.trimOut = clip.trimOut;
        info.stillImageHint = false;
        [clipPath addObject:info];
    }
    
    [self.sequenceView initSequenceViewCtl:clipPath duration:self.timeline.duration];
    
    [sequenceView addSubview:self.sequenceView];
    
    self.playButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"NvPlayback")];
    [self.playButton setImage:NvImageNamed(@"NvPause") forState:UIControlStateSelected];
    self.playButton.frame = CGRectMake(0, 0, self.sequenceView.height, self.sequenceView.height);
    self.playButton.backgroundColor = self.view.backgroundColor;
    [self.sequenceView addSubview:self.playButton];
    
    [self.playButton nv_BtnClickHandler:^{
        weakSelf.playButton.selected = !weakSelf.playButton.selected;
        if (weakSelf.playButton.selected) {
            weakSelf.isManualPlay = YES;
            [NvTimelineUtils playbackTimeline:weakSelf.timeline startTime:[[NvsStreamingContext sharedInstance] getTimelineCurrentPosition:weakSelf.timeline] endTime:weakSelf.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
        } else {
            [[NvsStreamingContext sharedInstance] stop];
        }
    }];
    
    self.minusButton = [NvButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvminus")];
    [self.view addSubview:self.minusButton];
    self.addButton = [NvButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvadd")];
    [self.view addSubview:self.addButton];
    self.timeLabel = [UILabel nv_labelWithText:@"00:00.0/00:00.0" fontSize:10 textColor:[UIColor nv_colorWithHexRGB:@"#FFFFFF"]];
    [self.view addSubview:self.timeLabel];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(sequenceView.mas_top).offset(-16*SCREENSCALEHEIGHT);
        make.centerX.equalTo(self.view);
    }];
    [self.minusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.timeLabel.mas_left).offset(-19*SCREENSCALE);
        make.height.width.equalTo(@(12*SCREENSCALEHEIGHT));
        make.centerY.equalTo(self.timeLabel);
    }];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLabel.mas_right).offset(19*SCREENSCALE);
        make.height.width.equalTo(@(12*SCREENSCALEHEIGHT));
        make.centerY.equalTo(self.timeLabel);
    }];
    
    [self.minusButton nv_BtnClickHandler:^{
        [weakSelf.sequenceView scaleSequenceView:0.8];
    }];
    
    [self.addButton nv_BtnClickHandler:^{
        [weakSelf.sequenceView scaleSequenceView:1.2];
    }];
    
    self.styleButton = [UIButton nv_buttonWithTitle:NvLocalString(@"Sound processing", @"声音处理") textColor:[UIColor whiteColor] fontSize:10];
    self.styleButton.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    [self.view addSubview:self.styleButton];
    [self.styleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-13*SCREENSCALE));
        make.centerY.equalTo(self.addButton);
        make.width.equalTo(@(50*SCREENSCALE));
        make.height.equalTo(@(17*SCREENSCALE));
    }];
    self.styleButton.layer.cornerRadius = 17/2.0*SCREENSCALE;
    self.styleButton.layer.masksToBounds = YES;
    [self.styleButton nv_BtnClickHandler:^{
        [weakSelf sequenceViewHidden:YES];
        weakSelf.tabView.hidden = NO;
        [weakSelf selectTab:weakSelf.tabView.cursorIndex];
    }];
    
    [self addTabView];
}

- (void)sequenceViewHidden:(BOOL)hidden {
    self.okButton.hidden = hidden;
    self.line.hidden = hidden;
    self.addRecordButton.hidden = hidden;
    self.sequenceView.hidden = hidden;
    self.playButton.hidden = hidden;
    self.minusButton.hidden = hidden;
    self.addButton.hidden = hidden;
    self.styleButton.hidden = hidden;
    self.timeLabel.hidden = hidden;
}

- (void)addTabView {
    self.tabView = [[CQMenuTabView alloc] init];
    self.tabView.layer.masksToBounds = YES;
    self.tabView.titleFont = [UIFont systemFontOfSize:12*SCREENSCALE];
    self.tabView.normaTitleColor = [UIColor nv_colorWithHexString:@"#707070"];
    self.tabView.didSelctTitleColor = [UIColor nv_colorWithHexString:@"#63ABFF"];
    self.tabView.showCursor = YES;
    self.tabView.normaTitleColor = [UIColor whiteColor];
    self.tabView.cursorStyle = CQTabCursorUnderneath;
    self.tabView.layoutStyle = CQTabWrapContent;
    self.tabView.cursorView.backgroundColor = [UIColor nv_colorWithHexString:@"#63ABFF"];
    self.tabView.cursorWidth = 12*SCREENSCALE;
    self.tabView.speaceWidth = 15.0*SCREENSCALE;
    self.tabView.titles = @[NvLocalString(@"Sound effect", @"音效"),NvLocalString(@"Noise Suppression", @"降噪")];
    __weak typeof(self)weakSelf = self;
    self.tabView.didTapItemAtIndexBlock = ^(UIView *view, NSInteger index) {
        [weakSelf selectTab:index];
    };
    [self.view addSubview:self.tabView];
    [self.tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.addButton.mas_top).offset(30*SCREENSCALE);
        make.left.right.equalTo(@0);
        make.height.mas_equalTo(25*SCREENSCALE);
    }];
    self.tabView.hidden = YES;
}

- (void)selectTab:(NSInteger)index {
    float yValue = self.tabView.bottom;
    self.selectedIndicator = index;
    if (index == 0) {
        self.noiseSuppressionView.hidden = YES;
        [self.voiceTypeView removeFromSuperview];
        self.voiceTypeView = [NvVoiceTypeView new];
        self.voiceTypeView.delegate = self;
        [self.view addSubview:self.voiceTypeView];
        [self.voiceTypeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(@0);
            make.top.equalTo(@(yValue+10*SCREENSCALE));
        }];
        [self fxClick];
    }else {
        [self.voiceTypeView removeFromSuperview];
        if (!self.noiseSuppressionView) {
            self.noiseSuppressionView = [NvDubNoiseSuppressionView new];
            self.noiseSuppressionView.delegate = self;
            [self.view addSubview:self.noiseSuppressionView];
            [self.noiseSuppressionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(@0);
                make.top.equalTo(@(yValue+10*SCREENSCALE));
            }];
        }
        if (self.model.audioNoiseSuppressionLevel>0) {
            self.noiseSuppressionView.selectedIndex = self.model.audioNoiseSuppressionLevel;
        }
        self.noiseSuppressionView.hidden = NO;
    }
}

#pragma mark - NvVoiceTypeViewDelegate
- (void)voiceTypeView:(NvVoiceTypeView *)voiceTypeView didSelectItem:(NvVoiceItem *)item {
    NvsAudioFx *audioFx = (NvsAudioFx *)[self.clip getAttachment:@"nv_audioFx"];
    if (audioFx) {
        [self.clip removeFx:audioFx.index];
    }
    audioFx = [self.clip appendFx:item.builtinName];
    [self.clip setAttachment:audioFx forKey:(NSString *)@"nv_audioFx"];
    [NvTimelineUtils playbackTimeline:self.timeline startTime:self.clip.inPoint endTime:self.clip.outPoint flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
    self.model.builtInFxName = item.builtinName;
}

- (void)voiceTypeView:(NvVoiceTypeView *)voiceTypeView okClick:(UIButton *)button {
    self.isFxModel = NO;
    [self seekTimeline:self.fxPosition];
    self.sequenceView.timelinePosition = self.fxPosition;
    [self.voiceTypeView removeFromSuperview];
    self.voiceTypeView = nil;
    self.tabView.hidden = YES;
    self.noiseSuppressionView.hidden = YES;
    [self sequenceViewHidden:NO];
    [self.streamingContext stop];
}
#pragma mark - NvSequenceViewCtlDelegate
- (void)sequenceViewCtl:(id)sequenceViewCtl scroll:(int64_t)timestamp {
    self.isChange = YES;
    self.scaleForSeek = self.timeline.duration / 1000000 /  [self.sequenceView getTimelineEditorWidth] / UIScreen.mainScreen.scale;
    [self seekTimeline:timestamp];
    self.playButton.selected = NO;
    self.currentPosition = timestamp;
    self.timeLabel.text= [NSString stringWithFormat:@"%@/%@",[NvUtils convertTimecodePrecision:timestamp],[NvUtils convertTimecodePrecision:self.timeline.duration]];
    
    self.clip = [self.audioTrack getClipWithTimelinePosition:timestamp];
    self.model = [self getModelWithClip:self.clip];
    ///是否显示特效按钮
    ///Whether to display the effects button
    if (!self.tabView.hidden) {
        self.styleButton.hidden = YES;
    } else {
        self.styleButton.hidden = !self.clip;
    }
    
    self.volumSlider.hidden = !self.clip;
    
    if (self.clip) {
        float left;
        [self.clip getVolumeGain:&left rightVolumeGain:&left];
        self.volumSlider.value = left;
    }
    
    ///滑动时不响应录音
    ///Swiping does not respond to recording
    self.addRecordButton.userInteractionEnabled = NO;
    if (self.clip) {
        self.status = NvRecordingDelete;
    } else {
        self.status = NvRecordingStart;
    }
}

- (void)sequenceViewCtl:(id)sequenceViewCtl scrollEnded:(int64_t)timestamp {
    self.addRecordButton.userInteractionEnabled = YES;
    self.isChange = NO;
}

#pragma mark - NvDubNoiseSuppressionViewDelegate
- (void)noiseSuppressionViewdidAddOkClick {
    self.isFxModel = NO;
    self.noiseSuppressionView.hidden = YES;
    self.tabView.hidden = YES;
    [self sequenceViewHidden:NO];
    [self seekTimeline:self.fxPosition];
    self.sequenceView.timelinePosition = self.fxPosition;
}

- (void)noiseSuppressionView:(NvDubNoiseSuppressionView *)view selectIndex:(NSInteger)index {
    if (index == 0) {
        NvsAudioFx *audioNoiseSuppressionFx = (NvsAudioFx *)[self.clip getAttachment:@"Audio Noise Suppression"];
        if(audioNoiseSuppressionFx){
            [self.clip removeFx:audioNoiseSuppressionFx.index];
        }
    }else {
        NvsAudioFx *audioNoiseSuppressionFx;
        for (int i=0; i<self.clip.fxCount; i++) {
            NvsAudioFx * audioFx = [self.clip getFxWithIndex:i];
            if ([audioFx.bultinAudioFxName isEqualToString:@"Audio Noise Suppression"]) {
                audioNoiseSuppressionFx = audioFx;
                break;
            }
        }
        if (!audioNoiseSuppressionFx) {
            audioNoiseSuppressionFx = [self.clip appendFx:@"Audio Noise Suppression"];
        }
        [audioNoiseSuppressionFx setIntVal:@"Level" val:(int)index];
        [self.clip setAttachment:audioNoiseSuppressionFx forKey:@"Audio Noise Suppression"];
    }
    self.model.audioNoiseSuppressionLevel = (int)index;
    [self.liveWindowPanel playBackStart:self.clip.inPoint end:self.clip.outPoint];
}

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    self.sequenceView.timelinePosition = position;
    self.playButton.selected = YES;
    self.timeLabel.text= [NSString stringWithFormat:@"%@/%@",[NvUtils convertTimecodePrecision:position],[NvUtils convertTimecodePrecision:self.timeline.duration]];
    self.currentPosition = position;
    self.clip = [self.audioTrack getClipWithTimelinePosition:self.currentPosition];
    ///如果是手动点击的播放
    ///If it is manually clicked to play
    if (self.isManualPlay && self.selectedIndicator == 0) {
        if (self.clip) {
            self.status = NvRecordingDelete;
        } else {
            self.status = NvRecordingStart;
        }
        
        ///是否显示特效按钮
        ///Whether to display the effects button
        if (!self.tabView.hidden) {
            self.styleButton.hidden = YES;
        } else {
            self.styleButton.hidden = !self.clip;
        }
        
        self.volumSlider.hidden = !self.clip;
        self.model = [self getModelWithClip:self.clip];
        if (self.clip) {
            float left;
            [self.clip getVolumeGain:&left rightVolumeGain:&left];
            self.volumSlider.value = left;
        }
    }
    if (self.selectedIndicator == 1 && self.styleButton.hidden == YES) {
        self.noiseSuppressionView.hidden = !self.clip;
    }
}

- (void)didPlaybackStopped:(NvsTimeline *)timeline {
    self.playButton.selected = NO;
    self.clip = [self.audioTrack getClipWithTimelinePosition:self.currentPosition];
    self.styleButton.hidden = !self.clip;
    if (!self.tabView.hidden) {
        self.styleButton.hidden = YES;
    }
}

- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    if (self.isFxModel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self seekTimeline:self.fxPosition];
            self.sequenceView.timelinePosition = self.fxPosition;
        });
        return;
    }
    if (self.record.isRecording) {
        [self stopRecording];
    }
    
    self.sequenceView.timelinePosition = 0;
    [self seekTimeline:0];
    self.playButton.selected = NO;
    self.timeLabel.text= [NSString stringWithFormat:@"%@/%@",[NvUtils convertTimecodePrecision:0],[NvUtils convertTimecodePrecision:self.timeline.duration]];
    self.currentPosition = 0;
    self.clip = [self.audioTrack getClipWithTimelinePosition:self.currentPosition];

    if (self.clip) {
        self.status = NvRecordingDelete;
    } else {
        self.status = NvRecordingStart;
    }
    ///是否显示特效按钮
    ///Whether to display the effects button
    if (!self.tabView.hidden) {
        self.styleButton.hidden = YES;
    } else {
        self.styleButton.hidden = !self.clip;
    }
    
    self.volumSlider.hidden = !self.clip;
    
    if (self.clip) {
        float left;
        [self.clip getVolumeGain:&left rightVolumeGain:&left];
        self.volumSlider.value = left;
    }
}

@end
