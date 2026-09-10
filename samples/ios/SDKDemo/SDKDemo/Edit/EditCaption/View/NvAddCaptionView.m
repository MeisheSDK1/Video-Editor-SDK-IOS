//
//  NvAddCaptionView.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/31.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvAddCaptionView.h"
#import "NvEditCaptionViewController.h"
#import "NvsVideoTrack.h"
#import "NvsVideoClip.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvGraphicBtn.h"
#import "NvTimelineUtils.h"

@interface NvAddCaptionView ()<NvsCTimelineEditorDelegate>

@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) NvGraphicBtn *addCaptionButton;
@property (nonatomic, strong) NvGraphicBtn *addNewCaptionButton;
@property (nonatomic, strong) UIView *sequenceView;
@property (nonatomic, strong) NvButton *minusButton;
@property (nonatomic, strong) NvButton *addButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *line;

@end

@implementation NvAddCaptionView

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.okButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvcheck - material")];
        [self addSubview:self.okButton];
        __weak typeof(self)weakSelf = self;
        [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.equalTo(@(25*SCREENSCALEHEIGHT));
            make.height.equalTo(@(20*SCREENSCALE));
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(@(-15*SCREENSCALE));
            }
        }];
        
        [self.okButton nv_BtnClickHandler:^{
            if ([weakSelf.delegate respondsToSelector:@selector(nvAddCaptionViewdidAddOkClick)]) {
                [weakSelf.delegate nvAddCaptionViewdidAddOkClick];
            }
        }];
        self.addCaptionButton = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"normalCaption", @"普通字幕") withImageNormal:@"NvTimelineCaption" withImageSelected:@"NvTimelineCaption"];
        [self.addCaptionButton setCustomImageSize:CGSizeMake(22*SCREENSCALE, 22*SCREENSCALE) offset:7.5*SCREENSCALE];
        [self.addCaptionButton setCustomFontSize:10];
        [self.addCaptionButton setAlpha:0.8];
        [self addSubview:self.addCaptionButton];
        [self.addCaptionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(88*SCREENSCALE);;
            make.width.equalTo(@(64*SCREENSCALE));
            make.height.equalTo(@(43*SCREENSCALE));
            make.bottom.equalTo(self.okButton.mas_top).offset(-22*SCREENSCALE);
        }];

        [self.addCaptionButton nv_BtnClickHandler:^{
            if ([weakSelf.delegate respondsToSelector:@selector(nvAddCaptionViewdidAddCaptionClick:)]) {
                [weakSelf.delegate nvAddCaptionViewdidAddCaptionClick:0];
            }
        }];
        
        self.addNewCaptionButton = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"modularCaption", @"拼装字幕") withImageNormal:@"NvTimelineNewCaption" withImageSelected:@"NvTimelineNewCaption"];
        [self.addNewCaptionButton setCustomImageSize:CGSizeMake(22*SCREENSCALE, 22*SCREENSCALE) offset:7.5*SCREENSCALE];
        [self.addNewCaptionButton setCustomFontSize:10];
        [self.addNewCaptionButton setAlpha:0.8];
        [self addSubview:self.addNewCaptionButton];
        [self.addNewCaptionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-(88*SCREENSCALE));
            make.width.equalTo(@(64*SCREENSCALE));
            make.height.equalTo(@(43*SCREENSCALE));
            make.bottom.equalTo(self.okButton.mas_top).offset(-22*SCREENSCALE);
        }];
        
        [self.addNewCaptionButton nv_BtnClickHandler:^{
            if ([weakSelf.delegate respondsToSelector:@selector(nvAddCaptionViewdidAddCaptionClick:)]) {
                [weakSelf.delegate nvAddCaptionViewdidAddCaptionClick:1];
            }
        }];
        
        self.sequenceView = [UIView new];
        [self addSubview:self.sequenceView];
        self.sequenceView.backgroundColor = [UIColor whiteColor];
        [self.sequenceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(49*SCREENSCALE));
            make.left.right.equalTo(@0);
            make.bottom.equalTo(self.addCaptionButton.mas_top).offset(-26*SCREENSCALE);
        }];
        [self layoutIfNeeded];
        self.timelineEditor = [[NvsCTimelineEditor alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.sequenceView.height)];
        self.timelineEditor.caneditTimeSpan = YES;
        self.timelineEditor.canOverlapTimeSpan = YES;
        [self.sequenceView addSubview:self.timelineEditor];
        
        self.playButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"NvPlayback")];
        [self.playButton setImage:NvImageNamed(@"NvPause") forState:UIControlStateSelected];
        self.playButton.frame = CGRectMake(0, 0, self.sequenceView.height, self.sequenceView.height);
        self.playButton.backgroundColor = UIColorFromRGB(0x242728);
        [self.sequenceView addSubview:self.playButton];

        [self.playButton nv_BtnClickHandler:^{
            weakSelf.playButton.selected = !weakSelf.playButton.selected;
            if (weakSelf.playButton.selected) {
                [NvTimelineUtils playbackTimeline:weakSelf.timeline startTime:[[NvsStreamingContext sharedInstance] getTimelineCurrentPosition:weakSelf.timeline] endTime:weakSelf.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
            } else {
                [[NvsStreamingContext sharedInstance] stop];
            }
        }];
        
        self.minusButton = [NvButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvminus")];
        [self addSubview:self.minusButton];
        self.addButton = [NvButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvadd")];
        [self addSubview:self.addButton];
        self.timeLabel = [UILabel nv_labelWithText:@"00:00.0/00:00.0" fontSize:10 textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"]];
        [self addSubview:self.timeLabel];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.sequenceView.mas_top).offset(-16*SCREENSCALEHEIGHT);
            make.centerX.equalTo(self);
            make.width.mas_equalTo(83*SCREENSCALE);
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
            [weakSelf.delegate captionTimelineEditorZoomOut];
        }];
        
        [self.addButton nv_BtnClickHandler:^{
            [weakSelf.delegate captionTimelineEditorZoomIn];
        }];
        
        self.line = [UIView new];
        self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
        [self addSubview:self.line];
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.height.equalTo(@1);
            make.bottom.equalTo(self.okButton.mas_top).offset(-12*SCREENSCALE);
        }];
        
        self.styleButton = [UIButton nv_buttonWithTitle:NvLocalString(@"Style", @"样式") textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"] fontSize:10];
        self.styleButton.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        [self addSubview:self.styleButton];
        [self.styleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-13*SCREENSCALE));
            make.centerY.equalTo(self.addButton);
            make.width.equalTo(@(39*SCREENSCALE));
            make.height.equalTo(@(17*SCREENSCALE));
        }];
        self.styleButton.layer.cornerRadius = 17/2.0*SCREENSCALE;
        self.styleButton.layer.masksToBounds = YES;
        [self.styleButton nv_BtnClickHandler:^{
            if ([weakSelf.delegate respondsToSelector:@selector(nvAddCaptionViewdidAddStyleClick)]) {
                [weakSelf.delegate nvAddCaptionViewdidAddStyleClick];
            }
        }];

        self.keyframeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.keyframeButton.showsTouchWhenHighlighted = NO;
        self.keyframeButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
        self.keyframeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.keyframeButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.keyframeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [self addSubview:self.keyframeButton];
        [self.keyframeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(12 * SCREENSCALE));
            make.centerY.equalTo(self.styleButton);
            make.height.equalTo(self.styleButton);
            make.right.equalTo(self.minusButton.mas_left).offset(-10);
        }];
        [self.keyframeButton nv_BtnClickHandler:^{
            if ([weakSelf.keyframeButton.titleLabel.text isEqualToString:NvLocalString(@"Curve adjustment", @"曲线调节")]) {
                if ([weakSelf.delegate respondsToSelector:@selector(nvAddCaptionCurveAdjustmentClick)]) {
                    [weakSelf.delegate nvAddCaptionCurveAdjustmentClick];
                }
            }else{
                if ([weakSelf.delegate respondsToSelector:@selector(nvAddCaptionViewdidAddKeyFrameClick)]) {
                    [weakSelf.delegate nvAddCaptionViewdidAddKeyFrameClick];
                }
            }

        }];
    }
    return self;
}
- (void)setKeyframeState:(BOOL)hasKeyframe {
    self.keyframeButton.enabled = YES;
    self.keyframeButton.alpha = 1;
    if (hasKeyframe) {
        [self.keyframeButton setTitle:NvLocalString(@"EditKeyFrame", @"编辑关键帧") forState:UIControlStateNormal];
        [self.keyframeButton setImage:[UIImage imageNamed:@"NvEditKeyFrame"] forState:UIControlStateNormal];
        [self.keyframeButton setImage:[UIImage imageNamed:@"NvEditKeyFrame"] forState:UIControlStateHighlighted];
        [self.keyframeButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#FFA54B"] forState:UIControlStateNormal];
    }else {
        [self.keyframeButton setTitle:NvLocalString(@"KeyFrame", @"关键帧") forState:UIControlStateNormal];
        [self.keyframeButton setImage:[UIImage imageNamed:@"NvKeyFrame"] forState:UIControlStateNormal];
        [self.keyframeButton setImage:[UIImage imageNamed:@"NvKeyFrame"] forState:UIControlStateHighlighted];
        [self.keyframeButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#FFFFFF"] forState:UIControlStateNormal];
    }
}

- (void)setKeyframeAddCurve {
    [self.keyframeButton setTitle:NvLocalString(@"Curve adjustment", @"曲线调节") forState:UIControlStateNormal];
    [self.keyframeButton setImage:[UIImage imageNamed:@"curve_adjustment"] forState:UIControlStateNormal];
    [self.keyframeButton setImage:[UIImage imageNamed:@"curve_adjustment"] forState:UIControlStateHighlighted];
    [self.keyframeButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#FFFFFF"] forState:UIControlStateNormal];
    self.keyframeButton.hidden = NO;
}


- (void)setTimeline:(NvsTimeline *)timeline {
    _timeline = timeline;
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    NSMutableArray *clipPath = [NSMutableArray array];
    for (int i = 0; i < videoTrack.clipCount; i++) {
        NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
        NvsCTimelineEditorInfo *info = [[NvsCTimelineEditorInfo alloc] init];
        info.mediaFilePath = clip.filePath;
        info.inPoint = clip.inPoint;
        info.outPoint = clip.outPoint;
        info.trimIn = clip.trimIn;
        info.trimOut = clip.trimOut;
        info.stillImageHint = false;
        [clipPath addObject:info];
    }
    
    [self.timelineEditor initTimelineEditor:clipPath timelineDuration:self.timeline.duration];
    self.timelineEditor.delegate = self;
}

- (void)setcurrentTime:(int64_t)time {
    self.timeLabel.text= [NSString stringWithFormat:@"%@/%@",[NvUtils convertTimecodePrecision:time],[NvUtils convertTimecodePrecision:self.timeline.duration]];
}

- (void)playStopCallBack {
    self.playButton.selected = NO;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(SCREENWIDTH, SCREENHEIGHT-NV_STATUSBARHEIGHT-44-SCREENWIDTH);
}

- (void)timelineEditor:(id)timelineEditor dragHandleStarted:(int64_t)timestamp isInPoint:(bool)isInPoint {
    
}

- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint {
    if ([self.delegate respondsToSelector:@selector(timelineEditor:draggingHandle:isInPoint:)]) {
        [self.delegate timelineEditor:timelineEditor draggingHandle:timestamp isInPoint:isInPoint];
    }
}

- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)timestamp isInPoint:(bool)isInPoint {
    if ([self.delegate respondsToSelector:@selector(timelineEditor:dragHandleEnded:isInPoint:)]) {
        [self.delegate timelineEditor:timelineEditor dragHandleEnded:timestamp isInPoint:isInPoint];
    }
}

- (void)timelineEditor:(id)timelineEditor dragScrollingTimeline:(int64_t)timestamp {
    [self.delegate dragTimelineEditor:timestamp];
}

- (void)timelineEditor:(id)timelineEditor dragScrollTimelineEnded:(int64_t)timestamp {
    if ([self.delegate respondsToSelector:@selector(dragScrollTimelineEnded:)]) {
        [self.delegate dragScrollTimelineEnded:timestamp];
    }
}

- (void)timelineEditor:(id)timelineEditor handlePan:(int64_t)timestamp {
    
}

@end
