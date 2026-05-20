//
//  NvEditClipStickerViewController.m
//  SDKDemo
//
//  Created by ms on 2021/8/26.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvEditClipStickerViewController.h"
#import <NvSDKCommon/NvUtils.h>
#import <NvSDKCommon/NvLiveWindowPanelView.h>
#import "NvAlbumViewController.h"
#import "NvAssetCollectionViewCell.h"
#import "NvAssetCellModel.h"
#import <NvSDKCommon/NvAssetManager.h>
#import "NvsCTimelineEditor.h"
#import "NvsVideoTrack.h"
#import "NvsVideoClip.h"
#import "NvTimelineData.h"
#import "NvTimelineUtils.h"
#import "NvClipAnimationStickerUtils.h"
#import "NvRectView.h"
#import "NvTimeLabelView.h"
#import "NvMoreFilterViewController.h"
#import "NvStickerModel.h"
#import "NvsClipAnimatedSticker.h"
#import "NvCustomStickerShapeViewController.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvCafCreator.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NvEditKeyFrameView.h"
#import "NvEditClipStickerKeyFrameView.h"
#import "NvGraphicBtn.h"
#import "NvClipStickerAnimationController.h"

#define NV_DEFAULT_STICKER_DURATION 5000000

@interface NvEditClipStickerViewController ()
<UICollectionViewDelegate,
UICollectionViewDataSource,
NvsCTimelineEditorDelegate,
NvRectViewDelegate,
NvTimeLabelViewDelegate,
NvsStreamingContextDelegate,
NvLiveWindowPanelViewDelegate,
NvCafCreatorDelegate,
NvEditClipStickerKeyFrameViewDelegate>

@property (nonatomic, strong) NvLiveWindowPanelView *liveWindowPanel;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;

@property (nonatomic, strong) UIView *modifyPanelView;
@property (nonatomic, strong) UIView *selectPanelView;
@property (nonatomic, strong) UICollectionView *currentView;
@property (nonatomic, strong) UICollectionView *allCollectionView;
@property (nonatomic, strong) UICollectionView *customCollectionView;
@property (nonatomic, strong) NSMutableArray *allStickerArray;
@property (nonatomic, strong) NSMutableArray *customStickerArray;
@property (nonatomic, strong) NSMutableArray *currentStickerArray;
@property (nonatomic, strong) NvAssetManager *assetManager;
@property (nonatomic, strong) NvsCTimelineEditor *timelineEditor;
@property (nonatomic, strong) UIButton *allBtn;
@property (nonatomic, strong) UIButton *customBtn;
@property (nonatomic, strong) UIButton *finishButton;
@property (nonatomic, strong) UIView *allHintView;
@property (nonatomic, strong) UIView *customHintView;
@property (nonatomic, strong) NvRectView *boundingView;
@property (nonatomic, strong) NvTimeLabelView *timeLabel;
@property (nonatomic, strong) NvButton *playBtn;
@property (nonatomic, assign) int64_t inPoint;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;


/// 关键帧按钮
/// Keyframe button
@property (nonatomic, strong) NvGraphicBtn *keyFrameButton;
/// 一键清除当前贴纸的所有关键帧
/// Clear all key frames of the current sticker with one click
@property (nonatomic, strong) NvGraphicBtn *removeKeyBtn;

///动画按钮
///Animation button
@property (nonatomic, strong) NvGraphicBtn *animationButton;
///当前是否是添加操作
///Whether the operation is an add operation
@property (nonatomic, assign) BOOL isAddState;

@property (nonatomic, strong) NSMutableArray <NvStickerModel *> *timeSpanArray;
@property (nonatomic, strong) NSMutableArray <NvStickerInfoModel *> *stickerInfoArray;
@property (nonatomic, strong) NvsClipAnimatedSticker *currentSticker;

@property (nonatomic, strong) NvStickerInfoModel *currentStickerInfoModel;
///当前编辑关键帧贴纸
///Current edit keyframe sticker
@property (nonatomic, strong) NvStickerInfoModel *currentKeyFrameStickerModel;
@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) NvCafCreator *cafCreator;
@property (nonatomic, strong) NSString *cafFileString;
@property (nonatomic, strong) NSString *cafUuidString;
@property (nonatomic, strong) NSString *cafGifString;
@property (nonatomic, assign) BOOL sameSate;
@property (nonatomic, strong) NvsTimeline *timeline;
///视频操作的片段对象
///A fragment object for a video operation
@property (nonatomic, strong) NvsVideoClip *videoClip;

/// 关键帧视图
/// Keyframe view
@property (nonatomic, strong) NvEditClipStickerKeyFrameView *keyFrameView;
/// 如果贴纸有关键帧，移动的时候编辑框，需要加一帧，删除一帧这样的方式来获取正确的边框
/// If the sticker has a keyframe, edit the box while moving, add a frame, delete a frame and so on to get the correct border
@property (nonatomic, assign) BOOL accordingBorder;
/// 当前贴纸的帧对象
/// Frame object of the current sticker
@property (nonatomic, strong) NvKeyFrameStickerModel *keyFrameModel;
/// 贴纸的删除关键字
/// The removal keyword of the sticker
@property (nonatomic, strong) NSArray *keyFrameStringArray;

@property (nonatomic, assign) BOOL isChange;
@property (nonatomic, assign) CGFloat scaleForSeek;

@end

@implementation NvEditClipStickerViewController {
    NvTimelineData *timelineData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.streamingContext = [NvSDKUtils getSDKContext];
    self.allStickerArray = NSMutableArray.new;
    self.customStickerArray = NSMutableArray.new;
    self.keyFrameStringArray = @[@"Sticker TransX",@"Sticker TransY",@"Sticker Scale",@"Sticker RotZ"];
    self.view.backgroundColor = UIColorFromRGB(0x242728);
    
    [self initTimeline];
    [self addSubViews];
    
    self.assetManager = [NvAssetManager sharedInstance];
    [self.assetManager searchLocalAssets:ASSET_ANIMATED_STICKER];
    NSString *itemPath = [[[NSBundle mainBundle] pathForResource:@"sticker" ofType:@"bundle"] stringByAppendingPathComponent:@"normal"];
    [self.assetManager searchReservedAssets:ASSET_ANIMATED_STICKER bundlePath:itemPath];
    self.currentView = self.allCollectionView;
    self.currentStickerArray = self.allStickerArray;
    self.inPoint = 0;
}
/**
 添加视图，初始化数据
 Add view and initialize data
 */
- (void)addSubViews {
    self.liveWindowPanel = [[NvLiveWindowPanelView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width)];
    _liveWindowPanel.editMode = self.editMode;
    _liveWindowPanel.delegate = self;
    _liveWindowPanel.forceHiddenControlPanel = YES;
    [self.view addSubview:_liveWindowPanel];
    [_liveWindowPanel connectTimeline:_timeline];
    [self seekTimeline:0];
    [_liveWindowPanel addTapScreenPause];
    
    self.modifyPanelView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT - 214*SCREENSCALE, SCREENWIDTH, 214*SCREENSCALE)];
    [self.view addSubview:self.modifyPanelView];
    [self.modifyPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.and.left.and.right.equalTo(self.view);
        make.height.equalTo(@(214*SCREENSCALE + INDICATOR));
    }];
    
    self.timeLabel = [[NvTimeLabelView alloc] initWithFrame:CGRectMake(0, 5*SCREENSCALE, SCREENWIDTH, 40*SCREENSCALE)];
    self.timeLabel.duration = self.timeline.duration;
    self.timeLabel.currentPos = 0;
    self.timeLabel.delegate = self;
    [self.modifyPanelView addSubview:self.timeLabel];
    [self.timeLabel updateLabel];
    
    self.timelineEditor = [[NvsCTimelineEditor alloc] initWithFrame:CGRectMake(0*SCREENSCALE, 40*SCREENSCALE, [UIScreen mainScreen].bounds.size.width, 49*SCREENSCALE)];
    self.timelineEditor.caneditTimeSpan = YES;
    self.timelineEditor.canOverlapTimeSpan = YES;
    
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
    
    [self.modifyPanelView addSubview:self.timelineEditor];
    
    self.playBtn = [[NvButton alloc] init];
    [self.playBtn setImage:[UIImage imageNamed:@"NvPlayback"] forState:UIControlStateNormal];
    [self.modifyPanelView addSubview:self.playBtn];
    [self.playBtn addTarget:self action:@selector(onPlayClicked) forControlEvents:UIControlEventTouchUpInside];
    self.playBtn.backgroundColor = UIColorFromRGB(0x242728);
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(KScale6s(40));
        make.size.mas_equalTo(CGSizeMake(KScale6s(40), KScale6s(49)));
    }];
    
    ///添加按钮
    ///Add button
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:@"NvEditpreviewAdd"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onAddStickerClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.modifyPanelView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(KScale6s(110));
        make.size.mas_equalTo(CGSizeMake(KScale6s(45), KScale6s(45)));
    }];
    ///清除关键帧按钮
    ///Clear key frame button
    self.removeKeyBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Delete key frame", @"清除关键帧") withImageNormal:@"nv_delete" withImageSelected:@"nv_delete"];
    [self.removeKeyBtn setCustomImageSize:CGSizeMake(22*SCREENSCALE, 22*SCREENSCALE) offset:0*SCREENSCALE];
    [self.removeKeyBtn setCustomFontSize:11];
    self.removeKeyBtn.btnLabel.numberOfLines = 2;
    [self.removeKeyBtn setAlpha:1.0];
    [self.removeKeyBtn addTarget:self action:@selector(removeKeyBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.modifyPanelView addSubview:self.removeKeyBtn];
    [self.removeKeyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(button);
        make.left.mas_equalTo(KScale6s(15));
        make.size.mas_equalTo(CGSizeMake(KScale6s(60), KScale6s(40)));
    }];
    
    self.animationButton = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"Animation", @"动画") withImageNormal:@"stickersAnimation" withImageSelected:@"stickersAnimation"];
    [self.animationButton setCustomImageSize:CGSizeMake(22*SCREENSCALE, 22*SCREENSCALE) offset:0*SCREENSCALE];
    [self.animationButton setCustomFontSize:11];
    self.animationButton.btnLabel.numberOfLines = 2;
    [self.animationButton setAlpha:1.0];
    [self.modifyPanelView addSubview:self.animationButton];
    self.animationButton.frame = CGRectMake(SCREENWIDTH/2 + 50*SCREENSCALE, 112.5*SCREENSCALE, 30*SCREENSCALE, 30*SCREENSCALE);
    [self.animationButton addTarget:self action:@selector(animationButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.animationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(button);
        make.left.equalTo(button.mas_right).offset(KScale6s(15));
        make.size.mas_equalTo(CGSizeMake(KScale6s(60), KScale6s(40)));
    }];
    
    ///关键帧按钮
    ///Keyframe button
    self.keyFrameButton = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"KeyFrame", @"关键帧") withImageNormal:@"NvKeyFrame" withImageSelected:@"NvEditKeyFrame"];
    [self.keyFrameButton setCustomImageSize:CGSizeMake(22*SCREENSCALE, 22*SCREENSCALE) offset:0*SCREENSCALE];
    [self.keyFrameButton setCustomFontSize:11];
    self.keyFrameButton.btnLabel.numberOfLines = 2;
    [self.keyFrameButton setAlpha:1.0];
    [self.modifyPanelView addSubview:self.keyFrameButton];
    [self.keyFrameButton addTarget:self action:@selector(keyFrameButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.keyFrameButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(button);
        make.right.equalTo(button.mas_left).offset(-KScale6s(15));
        make.size.mas_equalTo(CGSizeMake(KScale6s(60), KScale6s(40)));
    }];
    [self keyFrameButtonHidden:YES withState:YES];
    
    self.finishButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH/2 - 12*SCREENSCALE, 179*SCREENSCALE, 25*SCREENSCALE, 20*SCREENSCALE)];
    [self.finishButton setImage:[UIImage imageNamed:@"Nvcheck - material"] forState:UIControlStateNormal];
    [self.modifyPanelView addSubview:self.finishButton];
    
    [self.finishButton addTarget:self action:@selector(onFinishAddSticker) forControlEvents:UIControlEventTouchUpInside];
    
    self.selectPanelView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.selectPanelView];
    [self.selectPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-INDICATOR);
        make.height.equalTo(@(214*SCREENSCALE));
    }];
    self.selectPanelView.hidden = YES;
    
    [self initCategoryTabView];
    
    [self.view layoutIfNeeded];
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH/2 - 12*SCREENSCALE, self.selectPanelView.height -35*SCREENSCALE - INDICATOR, 25*SCREENSCALE, 20*SCREENSCALE)];
    [button1 setImage:[UIImage imageNamed:@"Nvcheck - material"] forState:UIControlStateNormal];
    [self.selectPanelView addSubview:button1];
    
    [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.selectPanelView.mas_bottom).offset(-15*SCREENSCALE);
        make.centerX.equalTo(self.selectPanelView);
        make.width.equalTo(@(25*SCREENSCALE));
        make.height.equalTo(@(20*SCREENSCALE));
    }];
    
    [button1 addTarget:self action:@selector(onFinishSelectSticker) forControlEvents:UIControlEventTouchUpInside];
    
    self.line = [UIView new];
    self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.view addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(button1.mas_top).offset(-12*SCREENSCALE);
    }];
    
    [self.view layoutIfNeeded];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(85*SCREENSCALE, 85*SCREENSCALE);
    layout.minimumLineSpacing = 20*SCREENSCALE;
    layout.minimumInteritemSpacing = 32*SCREENSCALE;
    self.allCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.allBtn.bottom+10, SCREENWIDTH, 128*SCREENSCALE) collectionViewLayout:layout];
    self.allCollectionView.delegate = self;
    self.allCollectionView.dataSource = self;
    self.allCollectionView.backgroundColor = [UIColor clearColor];
    self.allCollectionView.showsHorizontalScrollIndicator = NO;
    [self.selectPanelView addSubview:self.allCollectionView];
    [self.allCollectionView registerClass:[NvAssetCollectionViewCell class] forCellWithReuseIdentifier:@"NvAssetCollectionViewCell"];
    
    [self initCustomCollectionView];
    
    [self initBoundingView];
    [self initTimespan];
}

/**
 添加动画贴纸
 Add animation stickers
 */
-(void)animationButtonClick:(UIButton *)btn{
    NvClipStickerAnimationController *VC = [[NvClipStickerAnimationController alloc] init];
    VC.timeline = self.timeline;
    VC.editMode = self.editMode;
    VC.currentSticker = self.currentSticker;
    VC.currentStickerInfoModel = self.currentStickerInfoModel;
    [self.navigationController pushViewController:VC animated:YES];
}
/**
 初始化字幕选中框
 Initialize caption check box
 */
- (void)initBoundingView {
    self.boundingView = [[NvRectView alloc] initWithFrame:CGRectZero type:NV_ANIMATED_STICKER];
    self.boundingView.layer.masksToBounds = YES;
    [self.liveWindowPanel.liveWindow addSubview:self.boundingView];
    [self.boundingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    self.boundingView.delegate = self;
    self.boundingView.backgroundColor = [UIColor clearColor];
    self.boundingView.hidden = YES;
}

- (NSMutableArray *)getClipTimelineFilter:(NvEditDataModel *)clipInfo {
    NSUInteger index = [[NvTimelineData sharedInstance].editDataArray indexOfObject:clipInfo];
    NSMutableArray *filters = [[NvTimelineData sharedInstance] videoFxDataArray];
    NSMutableArray *clipFilters = NSMutableArray.new;
    if (filters.count > index) {
        NvTimeFilterInfoModel *filterModel = filters[index];
        NvTimeFilterInfoModel *clipFilter = [filterModel copy];
        clipFilter.inPoint = 0;
        clipFilter.outPoint = self.timeline.duration;
        [clipFilters addObject:clipFilter];
    } else {
        
    }
    return clipFilters;
}
/**
 创建时间线，添加贴纸数据
 Create timeline, add sticker data
 */
- (void)initTimeline {
    self.timeline = [NvTimelineUtils createTimeline:_editMode];
    [NvTimelineUtils recreateTimeline:self.timeline];
    
    [NvTimelineUtils resetEditData:self.timeline editDataArray:[NSArray arrayWithObject:_model]];
    [NvTimelineUtils resetVideoFx:self.timeline videoFxDataArray:[self getClipTimelineFilter:_model]];
    
    self.videoClip = [[self.timeline getVideoTrackByIndex:0] getClipWithIndex:0];
    [NvTimelineUtils removeClipCropAndTransformFx:self.videoClip];
    
    timelineData = [NvTimelineData sharedInstance];
    self.timeSpanArray = [NSMutableArray array];
    self.stickerInfoArray = [[NSMutableArray alloc] initWithArray:self.model.stickerDataArray copyItems:YES];

    [NvTimelineUtils resetClipSticker:self.videoClip stickerDataArray:self.stickerInfoArray];
}

- (void)initTitleView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 64*SCREENSCALE)];
    view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH/2 - 19*SCREENSCALE,
                                                               18*SCREENSCALE, SCREENWIDTH, 64*SCREENSCALE)];
    label.text = NvLocalString(@"Sticker", @"贴纸");
    label.textColor = [UIColor whiteColor];
    [view addSubview:label];
}

- (void)initCategoryTabView {
    UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(0, 40*SCREENSCALE, SCREENWIDTH, 1)];
    sepLine.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.selectPanelView addSubview:sepLine];
    
    UIView *tabview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40*SCREENSCALE)];
    [self.selectPanelView addSubview:tabview];
    
    UIButton *downloadBtn = [[UIButton alloc] initWithFrame:CGRectMake(13*SCREENSCALE, 10*SCREENSCALE, 30*SCREENSCALE, 21*SCREENSCALE)];
    [downloadBtn setImage:[UIImage imageNamed:@"NvsFilterMore"] forState:UIControlStateNormal];
    [tabview addSubview:downloadBtn];
    
    self.allBtn = [[UIButton alloc] initWithFrame:CGRectMake(69*SCREENSCALE, 10*SCREENSCALE, 40*SCREENSCALE, 21*SCREENSCALE)];
    [self.allBtn setTitle:NvLocalString(@"All", @"全部") forState:UIControlStateNormal];
    [self.allBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#909293"] forState:UIControlStateNormal];
    [self.allBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4090e2"] forState:UIControlStateSelected];
    self.allBtn.selected = YES;
    self.allBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [tabview addSubview:self.allBtn];
    
    self.allHintView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.allBtn.frame) -10, 40*SCREENSCALE, CGRectGetWidth(self.allBtn.frame) + 20, 1)];
    self.allHintView.backgroundColor =  [UIColor nv_colorWithHexRGB:@"#4090e2"];
    [tabview addSubview:self.allHintView];
    
    self.customBtn = [[UIButton alloc] initWithFrame:CGRectMake(126*SCREENSCALE, 10*SCREENSCALE, 55*SCREENSCALE, 21*SCREENSCALE)];
    [self.customBtn setTitle:NvLocalString(@"Custom", @"自定义") forState:UIControlStateNormal];
    [self.customBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#909293"] forState:UIControlStateNormal];
    [self.customBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#4090e2"] forState:UIControlStateSelected];
    self.customBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:style};
    CGSize maxSize = CGSizeMake(MAXFLOAT, 21 * SCREENSCALE);
    CGSize size = [NvLocalString(@"Custom", @"自定义") boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:nil].size;
    self.customBtn.frame = CGRectMake(126*SCREENSCALE, 10*SCREENSCALE, size.width, 21*SCREENSCALE);
    self.customBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [tabview addSubview:self.customBtn];
    
    self.customHintView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.customBtn.frame) - 10, 40*SCREENSCALE, CGRectGetWidth(self.customBtn.frame) + 20, 1)];
    self.customHintView.backgroundColor =  [UIColor nv_colorWithHexRGB:@"#4090e2"];
    [tabview addSubview:self.customHintView];
    self.customHintView.hidden = YES;
    
    [downloadBtn addTarget:self action:@selector(onDownloadClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.allBtn addTarget:self action:@selector(onAllClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.customBtn addTarget:self action:@selector(onCustomClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initCustomCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(85*SCREENSCALE, 85*SCREENSCALE);
    layout.minimumLineSpacing = 20*SCREENSCALE;
    layout.minimumInteritemSpacing = 32*SCREENSCALE;
    self.customCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.allCollectionView.top, SCREENWIDTH - 60 * SCREENSCALE, 128*SCREENSCALE) collectionViewLayout:layout];
    self.customCollectionView.delegate = self;
    self.customCollectionView.dataSource = self;
    self.customCollectionView.backgroundColor = [UIColor clearColor];
    self.customCollectionView.showsHorizontalScrollIndicator = NO;
    [self.selectPanelView addSubview:self.customCollectionView];
    [self.customCollectionView registerClass:[NvAssetCollectionViewCell class] forCellWithReuseIdentifier:@"NvAssetCollectionViewCell"];
    self.customCollectionView.hidden = YES;
}


- (void)initTimespan {
    [self seekTimeline:0];
    
    NvsClipAnimatedSticker *nextSticker = [self.videoClip getFirstAnimatedSticker];
    self.currentSticker = nextSticker;
    do {
        NvsCTimelineTimeSpan *timeSpan = [self.timelineEditor addTimeSpan:nextSticker.inPoint outPoint:nextSticker.outPoint];
        [self.timelineEditor selectTimeSpan:timeSpan];
        ///存储一个infoModel对象用于使timelineEditor高亮
        ///Stores an infoModel object for highlighting the timelineEditor
        NvStickerModel *infoModel = [NvStickerModel new];
        infoModel.currentClipSticker = nextSticker;
        infoModel.infoModel =  [self getStickerInfoModel:nextSticker];
        infoModel.timeSpan = timeSpan;
        if (nextSticker) {
            [self.timeSpanArray addObject:infoModel];
        }
        
        nextSticker = [self.videoClip getNextAnimatedSticker:nextSticker];
    } while (nextSticker);
    
    self.currentSticker = [[self.videoClip getAnimatedStickersByClipTimePosition:0] firstObject];
    if (self.currentSticker) {
        NvStickerModel *infoModel =  [self getCurrentTimeSpan:self.currentSticker];
        self.currentStickerInfoModel = infoModel.infoModel;
        [self.timelineEditor selectTimeSpan:infoModel.timeSpan];
        if ([self underShowKeyFrameViewState]) {
            self.boundingView.hidden = YES;
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.boundingView.hidden = NO;
            });
        }
        if (infoModel.infoModel.keyFramesArray.count > 0) {
            [self keyFrameButtonHidden:NO withState:YES];
            [self getCurrentPosBorder:0];
        }else{
            [self keyFrameButtonHidden:NO withState:NO];
            [self showBoundingView];
        }
    } else {
        [self keyFrameButtonHidden:YES withState:YES];
        self.boundingView.hidden = YES;
        [self.timelineEditor selectTimeSpan:nil];
    }
}

- (void)initReservedAsset:(NvAsset *)asset {
    if ([asset isReserved]) {
        if ([asset.uuid isEqualToString:@"0B2CA496-5DEB-4CAC-B01F-942B2C0B7580"]) {
            asset.category = ANIMATED_STICKER_SILENT;
        }
        if ([asset.uuid isEqualToString:@"39A21E74-00C6-48F9-96B0-485114B6F8F5"]) {
            asset.category = ANIMATED_STICKER_SILENT;
        }
        if ([asset.uuid isEqualToString:@"56A1D1CB-1CCA-40ED-B978-0ABA66021231"]) {
            asset.category = ANIMATED_STICKER_SOUND;
        }
    }
}

- (void)onFinishSelectSticker {
    self.isAddState = NO;
    self.sameSate = NO;
    [self.liveWindowPanel addTapScreenPause];
    self.selectPanelView.hidden = YES;
    self.modifyPanelView.hidden = NO;
    [self clearSelectState];
    [self playbackTimeline:self.inPoint];
    
    self.currentSticker = [[self.videoClip getAnimatedStickersByClipTimePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]] lastObject];
    if (self.currentSticker) {
        NvStickerInfoModel *infoModel = [self getStickerInfoModel:self.currentSticker];
        self.currentStickerInfoModel = infoModel;
        self.keyFrameView.sticker = self.currentSticker;
        self.keyFrameView.model = infoModel;
        if (infoModel.keyFramesArray.count > 0) {
            [self keyFrameButtonHidden:NO withState:YES];
        }else{
            [self keyFrameButtonHidden:NO withState:NO];
        }
    }else{
        [self keyFrameButtonHidden:YES withState:YES];
    }
}

- (void)onDownloadClicked {
    NvMoreFilterViewController *vc = [[NvMoreFilterViewController alloc]init];
    vc.editModel = self.editMode;
    vc.type = ASSET_ANIMATED_STICKER;
    vc.categoryId = 1;
    vc.kind = NV_KIND_ID_ALL;
    vc.isCapture = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onAllClicked {
    self.customCollectionView.hidden = YES;
    self.allCollectionView.hidden = NO;
    self.currentView = self.allCollectionView;
    [self updateAllStickers];
    [self.allCollectionView reloadData];
    self.allBtn.selected = YES;
    self.customBtn.selected = NO;
    self.allHintView.hidden = NO;
    self.customHintView.hidden = YES;
    self.sameSate = NO;
    self.customBtn.userInteractionEnabled = YES;
    self.allBtn.userInteractionEnabled = NO;
}

- (void)onCustomClicked {
    self.allCollectionView.hidden = YES;
    self.customCollectionView.hidden = NO;
    self.currentView = self.customCollectionView;
    [self updateCustomStickers];
    [self.customCollectionView reloadData];
    self.allBtn.selected = NO;
    self.customBtn.selected = YES;
    self.allHintView.hidden = YES;
    self.customHintView.hidden = NO;
    self.sameSate = NO;
    self.customBtn.userInteractionEnabled = NO;
    self.allBtn.userInteractionEnabled = YES;
}

- (void)onAddStickerClicked {
    self.isAddState = YES;
    [self.liveWindowPanel removeTapScreenPause];
    self.modifyPanelView.hidden = YES;
    self.selectPanelView.hidden = NO;
    
    self.currentSticker = nil;
    self.boundingView.hidden = YES;
    
    [self.allCollectionView reloadData];
    [self.customCollectionView reloadData];
    
    self.inPoint = [_streamingContext getTimelineCurrentPosition:_timeline];
}

#pragma mark 关键帧按钮方法 Keyframe button method
- (void)keyFrameButtonClicked:(UIButton *)button {
    self.currentKeyFrameStickerModel = self.currentStickerInfoModel;
    if (!self.keyFrameView) {
        self.keyFrameView = [[NvEditClipStickerKeyFrameView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT - 104*SCREENSCALE-INDICATOR, SCREENWIDTH, 104*SCREENSCALE+INDICATOR)];
        self.keyFrameView.delegate = self;
        [self.view addSubview:self.keyFrameView];
        CGFloat bottomHeight = 0;
        if (INDICATOR != 0) {
            bottomHeight = 20;
        }
        [self.keyFrameView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-bottomHeight);
            make.height.offset(104*SCREENSCALE+INDICATOR);
        }];
    }
    
    NvStickerModel *modelInfo = [self getCurrentTimeSpan:self.currentSticker];
    self.currentStickerInfoModel = modelInfo.infoModel;
    
    self.keyFrameView.hidden = NO;
    self.keyFrameView.sticker = self.currentSticker;
    self.keyFrameView.model = self.currentStickerInfoModel;
    [self.keyFrameView configTime:[self.streamingContext getTimelineCurrentPosition:self.timeline] withEnd:YES];
    [self.timelineEditor configKeyFrames:[self numberArray:self.currentStickerInfoModel.keyFramesArray] withSpanInPoint:self.currentStickerInfoModel.inPoint withOutPoint:self.currentStickerInfoModel.outPoint];
    NSLog(@"%@",self.currentSticker.getAnimatedStickerPackageId);
    NSLog(@"%@",self.currentStickerInfoModel.packageId);
}

#pragma mark 一键清除当前贴纸关键帧
///One key to clear the current sticker key frame
- (void)removeKeyBtnClicked:(UIButton *)button {
    
    NVWeakSelf
    [UIAlertController presentAlertFromVC:self
                                    title:NvLocalString(@"Are you sure you want to delete keyframes？" , @"确定要删除关键帧？")
                                  message:nil
                        buttonTitleColors:@[UIColor.systemBlueColor,UIColor.systemRedColor]
                        cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"album.cancel",@"NvAlbum",[NSBundle bundleForClass:self.class],nil)
                         otherButtonTitle:NSLocalizedStringFromTableInBundle(@"album.ok",@"NvAlbum",[NSBundle bundleForClass:self.class],nil)
                       cancelButtonAction:nil
                        otherButtonAction:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf removeAllKeyFrame];
    }];

}
/**
 删除当前贴纸所有的关键帧
 Delete all keyframes of the current sticker
 */
- (void)removeAllKeyFrame{
    for (NSString *string in self.keyFrameStringArray) {
        [self.currentSticker removeAllKeyframe:string];
    }
    [self.currentStickerInfoModel.keyFramesArray removeAllObjects];
    
    [self keyFrameButtonHidden:NO withState:NO];
    
    [self.currentSticker translateAnimatedSticker:CGPointZero];
    [self.currentSticker setScale:1];
    [self.currentSticker setRotationZ:0];
    
    [self seekTimeline:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
    [self showBoundingView];
    
    if (!self.keyFrameView.hidden && self.keyFrameView) {
        [self.timelineEditor configKeyFrames:[@[] mutableCopy] withSpanInPoint:self.currentStickerInfoModel.inPoint withOutPoint:self.currentStickerInfoModel.outPoint];
    }
}

- (void)keyFrameButtonHidden:(BOOL)hidden withState:(BOOL)have{
    self.keyFrameButton.hidden = hidden;
    self.animationButton.hidden = hidden;
    self.removeKeyBtn.hidden = self.currentStickerInfoModel.keyFramesArray.count > 0?NO:YES;
    self.keyFrameButton.selected = have;
    if (have) {
        
        self.keyFrameButton.btnLabel.text = NvLocalString(@"EditKeyFrame", @"编辑关键帧");
        self.keyFrameButton.btnLabel.textColor = [UIColor nv_colorWithHexString:@"F2A95D"];
    }else{
        
        self.keyFrameButton.btnLabel.text = NvLocalString(@"KeyFrame", @"关键帧");
        self.keyFrameButton.btnLabel.textColor = UIColor.whiteColor;
    }
}

- (void)onFinishAddSticker {
    [NvTimelineUtils removeTimeline:self.timeline];
    self.model.stickerDataArray = self.stickerInfoArray;
    NSMutableArray *order = [[NvTimelineData sharedInstance] dataOrder];
    [order removeObject:@"Sticker"];
    [order addObject:@"Sticker"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)seekTimeline:(int64_t)postion {
    int flags = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (self.isChange) {
        flags = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing;
        self.scaleForSeek = self.timeline.duration / 1000000 /  [self.timelineEditor getTimelineEditorWidth] / UIScreen.mainScreen.scale;
        [self.streamingContext setTimeline:_timeline scaleForSeek:self.scaleForSeek];
    }
    if (![_streamingContext seekTimeline:_timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flags])
        NSLog(@"定位时间线失败！Failed to seek timeline!");
}

- (void)seekTimelineWithoutFlag:(int64_t)postion {
    int flags = NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (self.isChange) {
        flags = NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame | NvsStreamingEngineSeekFlag_AllowFastScrubbing;
        self.scaleForSeek = self.timeline.duration / 1000000 /  [self.timelineEditor getTimelineEditorWidth] / UIScreen.mainScreen.scale;
        [self.streamingContext setTimeline:_timeline scaleForSeek:self.scaleForSeek];
    }
    if (![_streamingContext seekTimeline:_timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flags])
        NSLog(@"定位时间线失败！Failed to seek timeline!");
}

- (void)onPlayClicked {
    int64_t curPos = [_streamingContext getTimelineCurrentPosition:self.timeline];
    if ([_streamingContext getStreamingEngineState] != NvsStreamingEngineState_Playback) {
        [NvTimelineUtils playbackTimeline:self.timeline startTime:curPos endTime:-1 flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
    } else {
        [_streamingContext stop];
    }
}

- (NvStickerInfoModel *)getStickerInfoModel:(NvsClipAnimatedSticker *) nextSticker {
    return (NvStickerInfoModel *)[nextSticker getAttachment:@"stickerInfoModel"];
}

- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.currentView == self.allCollectionView) {
        [self updateAllStickers];
        [self.allCollectionView reloadData];
    } else {
        [self updateCustomStickers];
        [self.customCollectionView reloadData];
    }
    _streamingContext.delegate = self;
    
    [self connectLiveWindow];
}

- (void)connectLiveWindow {
    [self.liveWindowPanel connectTimeline:self.timeline];
    [self seekTimeline:self.liveWindowPanel.currentTime];
}


- (void)updateAllStickers {
    NSString *selectedUUID = nil;
    BOOL isPlay = NO;
    for (NvAssetCellModel *asset in self.allStickerArray) {
        if (asset.selected) {
            selectedUUID = asset.package;
            isPlay = asset.isPlay;
        }
    }
    
    [self.allStickerArray removeAllObjects];
    NSArray *array = [self.assetManager getUsableAssets:ASSET_ANIMATED_STICKER aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    for (NvAsset *asset in array) {
        [self initReservedAsset:asset];
        NvAssetCellModel *assetModel = NvAssetCellModel.new;
        assetModel.displayName = asset.displayName;
        assetModel.cover = asset.coverUrl;
        assetModel.size = [NvSDKUtils getAssetPackageSizeString:asset.packageSize];
        assetModel.draw = [NvSDKUtils getAssetAspectRatioString:asset.aspectRatio];
        assetModel.package = asset.uuid;
        assetModel.categoryId = asset.category;
        if ([assetModel.package isEqualToString:selectedUUID]) {
            assetModel.selected = YES;
            assetModel.isPlay = isPlay;
        }
        [self.allStickerArray addObject:assetModel];
    }
}

- (void)updateCustomStickers {
    NSMutableDictionary *customStickers = self.assetManager.customStickerDict;
    for (NSString *key in customStickers) {
        if ([self isCustomStickerExist:key])
            continue;
        NvCustomStickerInfo *info = customStickers[key];
        NvAssetCellModel *assetModel = NvAssetCellModel.new;
        assetModel.displayName = @"";
        assetModel.cover = info.imagePath;
        assetModel.package = info.uuid;
        assetModel.templateId = info.templateUuid;
        if (info.tempImage) {
            assetModel.covergif = info.tempImage;
        }
        [self.customStickerArray insertObject:assetModel atIndex:self.customStickerArray.count];
    }
    [self addNoneSticker];
}

- (BOOL)isAssetExist:(NSString *)uuid {
    for (NvAssetCellModel *item in self.allStickerArray) {
        if ([item.package isEqualToString:uuid])
            return YES;
    }
    return NO;
}

- (BOOL)isCustomStickerExist:(NSString *)uuid {
    for (NvAssetCellModel *item in self.customStickerArray) {
        if ([item.package isEqualToString:uuid])
            return YES;
    }
    return NO;
}

- (void)addNoneSticker {
    for (NvAssetCellModel *item in _customStickerArray) {
        if ([item.cover isEqualToString:@"NvEditWatemarButton"])
            return;
    }
    NvAssetCellModel *item = [NvAssetCellModel new];
    item.builtinName = nil;
    item.package = nil;
    item.selected = NO;
    item.cover = @"NvEditWatemarButton";
    item.displayName = @"";
    [_customStickerArray insertObject:item atIndex:0];
}

- (void)clearSelectState {
    for (NvAssetCellModel *info in self.allStickerArray) {
        info.selected = NO;
    }
    for (NvAssetCellModel *info in self.customStickerArray) {
        info.selected = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)removeSticker {
    [self.timelineEditor deleteTimeSpan:self.currentSticker.inPoint outPoint:self.currentSticker.outPoint];
    [self.videoClip removeAnimatedSticker:self.currentSticker];
    [self.stickerInfoArray removeObject:(NvStickerInfoModel *)[self.currentSticker getAttachment:@"stickerInfoModel"]];
}

- (NvStickerModel *)getCurrentTimeSpan:(NvsClipAnimatedSticker *)currentSticker {
    NvStickerModel *infoModel;
    for (int i = 0; i < self.timeSpanArray.count; i++) {
        infoModel = self.timeSpanArray[i];
        if (infoModel.currentClipSticker == self.currentSticker) {
            return infoModel;
        }
    }
    return infoModel;
}
/**
 添加sticker
 add sticker

 @param stickerInfo 素材信息
 material info
 */
- (void)addSticker:(NvAssetCellModel *)stickerInfo {
    NvStickerInfoModel *info = NvStickerInfoModel.new;
    info.packageId = stickerInfo.templateId != nil ? stickerInfo.templateId : stickerInfo.package;
    info.isCustomSticer = stickerInfo.templateId != nil;
    info.customImagePath = stickerInfo.cover;
    info.inPoint = self.inPoint;
    info.outPoint = info.inPoint + NV_DEFAULT_STICKER_DURATION > _timeline.duration ? _timeline.duration : info.inPoint + NV_DEFAULT_STICKER_DURATION;
    info.isSlient = stickerInfo.categoryId == ANIMATED_STICKER_SILENT;
    self.currentStickerInfoModel = info;
    [self.stickerInfoArray addObject:info];
    
    if (info.isCustomSticer) {
        self.currentSticker = [self.videoClip addCustomAnimatedSticker:info.inPoint duration:info.outPoint - info.inPoint animatedStickerPackageId:info.packageId customImagePath:info.customImagePath];
    } else {
        self.currentSticker = [self.videoClip addAnimatedSticker:info.inPoint duration:info.outPoint - info.inPoint animatedStickerPackageId:info.packageId];
    }
    [self.currentSticker setAbsoluteTimeUsed:true];
    [self.currentSticker setAttachment:info forKey:@"stickerInfoModel"];
    
    NvsCTimelineTimeSpan *timeSpan = [self.timelineEditor addTimeSpan:info.inPoint outPoint:info.outPoint];
    
    NvStickerModel *infoModel = [NvStickerModel new];
    infoModel.currentClipSticker = self.currentSticker;
    infoModel.infoModel = info;
    infoModel.timeSpan = timeSpan;
    if (self.currentSticker) {
        [self.timeSpanArray addObject:infoModel];
    }
    
    float currentVolume;
    [self.currentSticker getVolumeGain:&currentVolume rightVolumeGain:&currentVolume];
    [self.boundingView setVolume:currentVolume > 0];
}

- (void)showBoundingView {
    if (self.currentSticker == nil) {
        self.boundingView.hidden = YES;
        return;
    }
    
    self.boundingView.hidden = NO;
    
    BOOL flip = [self.currentSticker getHorizontalFlip];
    if (flip)
        [self.currentSticker setHorizontalFlip:!flip];
    [self.boundingView setPoints:[NvClipAnimationStickerUtils getStickerBoundingPoints:self.videoClip liveWindow:_liveWindowPanel.liveWindow stickerInfo:[self getStickerInfoModel:self.currentSticker]]];
    
    [self.currentSticker setHorizontalFlip:flip];
    
    
    NvStickerInfoModel *modelInfo = [self getStickerInfoModel:self.currentSticker];
    [self.boundingView hideVoiceButton:modelInfo == nil ? YES : modelInfo.isSlient];
    [self.boundingView setVolume:modelInfo.volume > 0];
}

- (void)playbackTimeline:(int64_t)pos {
    [NvTimelineUtils playbackTimeline:self.timeline startTime:pos endTime:-1 flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}
/**
 根据asset获取图片
 Find out if a material exists

 @param asset 图片资源
 Image resource
 */
- (UIImage *)getImage:(PHAsset *)asset {
    __block UIImage *resultImage;
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    // this one is key
    requestOptions.synchronous = YES;
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:PHImageManagerMaximumSize
                                              contentMode:PHImageContentModeAspectFit
                                                  options:requestOptions
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                resultImage = result;
                                            }
     ];
    return resultImage;
}

# pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.allCollectionView) {
        return self.allStickerArray.count;
    } else {
        return self.customStickerArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.allCollectionView) {
        NvAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvAssetCollectionViewCell" forIndexPath:indexPath];
        [cell renderCellWithItem:_allStickerArray[indexPath.row]];
        return cell;
    } else {
        NvAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvAssetCollectionViewCell" forIndexPath:indexPath];
        [cell renderCellWithItem:_customStickerArray[indexPath.row]];
        return cell;
    }
}

# pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && collectionView == self.customCollectionView) {

        [_streamingContext stop];
        self.currentStickerArray = self.customStickerArray;
        self.currentIndexPath = indexPath;
        
        NvAlbumViewController *vc = [NvAlbumViewController new];
        vc.isOnlyImage = YES;
        vc.mutableSelect = NO;
        vc.delegate = self;
        [vc customSelectAssetButtonText:NvLocalString(@"Start making", @"开始制作贴纸")];
        [self.navigationController pushViewController:vc animated:YES];

        return;
    }
    if (collectionView == self.customCollectionView) {
        self.currentStickerArray = self.customStickerArray;
    } else {
        self.currentStickerArray = self.allStickerArray;
    }
    
    if (self.currentIndexPath != nil && [self.currentIndexPath isEqual:indexPath] && self.sameSate) {
        NvAssetCellModel *stickerInfo = self.currentStickerArray[indexPath.row];
        if (self.streamingContext.getStreamingEngineState != NvsStreamingEngineState_Playback) {
            stickerInfo.isPlay = YES;
            if (![NvTimelineUtils playbackTimeline:self.timeline startTime:self.liveWindowPanel.currentTime endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
                NSLog(@"播放时间线失败！Failed to play timeline!");
                return;
            }
        } else {
            stickerInfo.isPlay = NO;
            [self.streamingContext stop];
        }
        [self.currentView reloadData];
    }else{
        self.currentIndexPath = indexPath;
        ///清除所有选中状态
        ///Clear all selected states
        [self clearSelectState];
        if (self.sameSate) {
            ///先删除之前添加的sticker
            ///Delete the sticker that was added earlier
            [self removeSticker];
        }
        
        
        ///添加sticker
        ///Add sticker
        NvAssetCellModel *stickerInfo = self.currentStickerArray[indexPath.row];
        stickerInfo.selected = YES;
        stickerInfo.isPlay = YES;
        [self addSticker:stickerInfo];

        [self playbackTimeline:[_streamingContext getTimelineCurrentPosition:self.timeline]];
        self.sameSate = YES;
        [self.currentView reloadData];
    }
}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    NvAlbumAsset *assetsGif = assets.firstObject;
    self.cafCreator = [[NvCafCreator alloc]init];
     __weak typeof(self)weakself = self;
    [[PHImageManager defaultManager] requestImageDataForAsset:assetsGif.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([dataUTI isEqualToString:@"com.compuserve.gif"]) {
                [NvToast showLoading];
                
                NSString *tempPath = [NvUtils getTempPath];
                weakself.cafUuidString = [NvUtils uuidString];
                weakself.cafGifString = [tempPath stringByAppendingPathComponent:[weakself.cafUuidString stringByAppendingString:@".gif"]];
                weakself.cafFileString = [tempPath stringByAppendingPathComponent:[weakself.cafUuidString stringByAppendingString:@".caf"]];
                
                [imageData writeToFile:weakself.cafGifString atomically:YES];
                
                SNvRational frameRate = {20,1};
                SNvRational pixelAsprectRatio = {1,1};
                
                weakself.cafCreator.delegate = weakself;
                [weakself.cafCreator convertFilePath:weakself.cafGifString targetCafFilePath:weakself.cafFileString width:300 height:300 format:NvCafImageFormat_PNG frameRate:frameRate pixelAsprectRatio:pixelAsprectRatio loopMode:NvCafLoopMode_Repeat];
                
                
                dispatch_queue_t queue = dispatch_queue_create("cafCreator", DISPATCH_QUEUE_CONCURRENT);
                
                dispatch_async(queue, ^{
                    [weakself.cafCreator start];
                });
            }else{
                NvCustomStickerShapeViewController *vc = NvCustomStickerShapeViewController.new;
                vc.selectedImage = [weakself getImage:assets.firstObject.asset];
                [weakself.navigationController pushViewController:vc animated:YES];
            }
        });
    }];
}

- (void)cafCreator:(NvCafCreator *)creator convertFinished:(BOOL)finished {
    [NvToast dismiss];
    [self.navigationController popViewControllerAnimated:YES];
    if(finished) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:self.cafFileString]) {
            NSString *dir = [NvUtils getCustomAnimatedStickerPicPath];
            NSString *destgifPath = [dir stringByAppendingPathComponent:[self.cafUuidString stringByAppendingString:@".gif"]];
            NSString *destcafPath = [dir stringByAppendingPathComponent:[self.cafUuidString stringByAppendingString:@".caf"]];
            
            [fileManager copyItemAtPath:self.cafFileString toPath:destcafPath error:nil];
            [fileManager copyItemAtPath:self.cafGifString toPath:destgifPath error:nil];
            
            NvCustomStickerInfo *info = NvCustomStickerInfo.new;
            info.uuid = self.cafUuidString;
            info.templateUuid = @"E14FEE65-71A0-4717-9D66-3397B6C11223";
            info.imagePath = destcafPath;
            info.tempImage = destgifPath;
            info.order = (int)_assetManager.customStickerDict.count;
            
            [_assetManager.customStickerDict setObject:info forKey:info.uuid];
            [_assetManager setAssetInfoToUserDefaults:ASSET_ANIMATED_STICKER];
            
            [self updateCustomStickers];
            [self.customCollectionView reloadData];
        }
        NSLog(@"%@", @"caf convert success!");
    } else {
        NSLog(@"%@", @"caf convert failed!");
    }
}

# pragma mark NvRectViewDelegate
- (void)rectView:(NvRectView*)rectView close:(UIButton*)close {
    if ([self underShowKeyFrameViewState]) {
        [NvToast showInfoWithMessage:NvLocalString(@"Stickers cannot be deleted in key frame mode, please exit the change mode and delete", @"关键帧模式下无法删除贴纸，请退出改模式下再删除")];
        return;
    }
    self.sameSate = NO;
    self.currentStickerInfoModel = nil;
    NvStickerModel *modelInfo = [self getCurrentTimeSpan:self.currentSticker];
    [self.timelineEditor selectTimeSpan:modelInfo.timeSpan];
    [self.timelineEditor deleteSelectedTimeSpan];
    
    [self.videoClip removeAnimatedSticker:self.currentSticker];
    [self.stickerInfoArray removeObject:modelInfo.infoModel];
    [self.timeSpanArray removeObject:modelInfo];
    
    [self keyFrameButtonHidden:YES withState:NO];
    self.currentSticker = [[self.videoClip getAnimatedStickersByClipTimePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]] lastObject];
    
    NvStickerModel *modelInfonext = [self getCurrentTimeSpan:self.currentSticker];
    [self.timelineEditor selectTimeSpan:modelInfonext.timeSpan];
    if (self.currentSticker) {
        [self showBoundingView];
    } else {
        self.boundingView.hidden = YES;
    }
    
    [self seekTimeline:[_streamingContext getTimelineCurrentPosition:_timeline]];
    
    if (!self.selectPanelView.hidden) {
        [self clearSelectState];
        [self.allCollectionView reloadData];
        [self.customCollectionView reloadData];
    }
}

- (void)rectView:(NvRectView *)rectView toggleVolume:(UIButton *)toggleVolume {
    float currentVolume;
    [self.currentSticker getVolumeGain:&currentVolume rightVolumeGain:&currentVolume];
    [self.currentSticker setVolumeGain:1-currentVolume rightVolumeGain:1-currentVolume];
    NvStickerInfoModel *modelInfo = [self getStickerInfoModel:self.currentSticker];
    modelInfo.volume = 1 - currentVolume;
    
    [self.boundingView setVolume:modelInfo.volume > 0];
}

- (void)rectView:(NvRectView *)rectView horizontalFlip:(UIButton *)horizontalFlip {
    BOOL isFlip = [self.currentSticker getHorizontalFlip];
    isFlip = !isFlip;
    [self.currentSticker setHorizontalFlip:isFlip];
    NvStickerModel *modelInfo = [self getCurrentTimeSpan:self.currentSticker];
    modelInfo.infoModel.isHorizontalFlip = isFlip;
    [self seekTimeline:[_streamingContext getTimelineCurrentPosition:_timeline]];
}

- (CGPoint)getCenterWithArray:(NSArray*)array {
    NSValue *leftTopValue = array[0];
    NSValue *rightBottomValue = array[2];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    return CGPointMake((topLeftCorner.x+rightBottomCorner.x)/2, (topLeftCorner.y+rightBottomCorner.y)/2);
}

- (void)rectView:(NvRectView*)rectView rotate:(float)rotate scale:(float)scale {
    if ([self prohibitOperation]) {
        return;
    }
    NSArray *array = [self.currentSticker getBoundingRectangleVertices];
    CGPoint center = [self getCenterWithArray:array];
    
    [self.currentSticker scaleAnimatedSticker:scale anchor:center];
    [self.currentSticker rotateAnimatedSticker:rotate anchor:center];
    
    [self seekTimeline:[_streamingContext getTimelineCurrentPosition:_timeline]];
    [self showBoundingView];
    
    NvStickerModel *modelInfo = [self getCurrentTimeSpan:self.currentSticker];
    modelInfo.infoModel.rotation = [self.currentSticker getRotationZ];
    modelInfo.infoModel.scale = [self.currentSticker getScale];
    
    if ([self underShowKeyFrameViewState] && self.keyFrameModel) {
        self.keyFrameModel.rotation = [self.currentSticker getRotationZ];
        self.keyFrameModel.scale = [self.currentSticker getScale];
    }
}

- (void)rectView:(NvRectView*)rectView currentPoint:(CGPoint)currentPoint previousPoint:(CGPoint)previousPoint {
    if ([self prohibitOperation]) {
        return;
    }
    CGPoint p1 = [self.liveWindowPanel.liveWindow mapViewToCanonical:currentPoint];
    CGPoint p2 = [self.liveWindowPanel.liveWindow mapViewToCanonical:previousPoint];
    CGPoint newPoint = CGPointMake(p1.x-p2.x, p1.y-p2.y);
    [self.currentSticker translateAnimatedSticker:newPoint];
    [self seekTimeline:[_streamingContext getTimelineCurrentPosition:_timeline]];
    [self showBoundingView];
    
    NvStickerModel *modelInfo = [self getCurrentTimeSpan:self.currentSticker];
    modelInfo.infoModel.translation = [self.currentSticker getTransltion];
    
    if ([self underShowKeyFrameViewState] && self.keyFrameModel) {
        self.keyFrameModel.translation = [self.currentSticker getTransltion];
    }
}

- (void)rectViewtouchBegan:(NvRectView *)rectView{
    if (self.currentSticker && ![self underShowKeyFrameViewState]) {
        NvStickerModel *modelInfo = [self getCurrentTimeSpan:self.currentSticker];
        self.currentStickerInfoModel = modelInfo.infoModel;
        [self getCurrentPosBorder:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
        [self keyFrameButtonHidden:NO withState:self.currentStickerInfoModel.keyFramesArray.count > 0?YES:NO];
    }else{
        self.boundingView.hidden = YES;
    }
    if ([self underShowKeyFrameViewState] && !self.keyFrameView.currentModel) {
        [self.keyFrameView addKey:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
    }else if(self.currentStickerInfoModel.keyFramesArray.count > 0 && (self.keyFrameView.hidden || !self.keyFrameView)){
        [NvToast showInfoWithMessage:NvLocalString(@"Keyframe editing mode has been exited. If you want to change the position of the sticker, please remove the keyframe first, then drag and move", @"已退出关键帧编辑模式，如果想要变化贴纸的位置，请先移除关键帧，再拖拽移动")];
    }
}

- (void)rectView:(NvRectView *)rectView touchBeganPoint:(CGPoint)point {
    if ([self underShowKeyFrameViewState]) {
        
    }else{
        if (!self.isAddState) {
            NvStickerInfoModel *info = [NvClipAnimationStickerUtils getStickerByPoint:self.videoClip timeline:_timeline liveWindow:_liveWindowPanel.liveWindow point:point];
            if (info == nil) {
                return;
            }
            self.currentSticker = [NvClipAnimationStickerUtils findStickerObject:self.videoClip stickerInfo:info];
            
            for (int i = 0; i < self.timeSpanArray.count; i++) {
                NvStickerModel *model = self.timeSpanArray[i];
                if ([model.infoModel.uuid isEqualToString:info.uuid]) {
                    [self.timelineEditor selectTimeSpan:model.timeSpan];
                    break;
                }
            }
            
            [self showBoundingView];
        }
    }
}

- (void)rectView:(NvRectView *)rectView isHidden:(BOOL)isHidden {
    if (!self.isAddState) {
        if (isHidden) {
            [self.liveWindowPanel addTapScreenPause];
        } else {
            [self.liveWindowPanel removeTapScreenPause];
        }
    }
}

- (void)rectView:(NvRectView *)rectView touchUpInside:(CGPoint)point {
    if (self.currentSticker) {
        NSArray *array = [self.currentSticker getBoundingRectangleVertices];
        NSValue *leftTopValue = array[0];
        NSValue *leftBottomValue = array[1];
        NSValue *rightBottomValue = array[2];
        NSValue *rightTopValue = array[3];
        CGPoint topLeftCorner = [leftTopValue CGPointValue];
        CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
        CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
        CGPoint rightTopCorner = [rightTopValue CGPointValue];
        
        topLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:topLeftCorner];
        rightBottomCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightBottomCorner];
        bottomLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:bottomLeftCorner];
        rightTopCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightTopCorner];
        
        CGMutablePathRef pathRef=CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, topLeftCorner.x, topLeftCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, bottomLeftCorner.x, bottomLeftCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, rightBottomCorner.x, rightBottomCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, rightTopCorner.x, rightTopCorner.y);
        CGPathCloseSubpath(pathRef);
        bool isIn = CGPathContainsPoint(pathRef, nil, point, false);
        CGPathRelease(pathRef);
        if(isIn){
            [self.boundingView setPoints:@[[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:topLeftCorner toView:self.boundingView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:bottomLeftCorner toView:self.boundingView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightBottomCorner toView:self.boundingView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightTopCorner toView:self.boundingView]]]];
            
        } else {
            if (self.streamingContext.getStreamingEngineState != NvsStreamingEngineState_Playback) {
                if (!self.isAddState) {
                    if (![NvTimelineUtils playbackTimeline:self.timeline startTime:self.liveWindowPanel.currentTime endTime:self.timeline.duration flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
                        NSLog(@"播放时间线失败！Failed to play timeline!");
                        return;
                    }
                }
            } else {
                [self.streamingContext stop];
            }
        }
    }
}

# pragma mark NvsCTimelineEditorDelegate
- (void)timelineEditor:(id)timelineEditor dragHandleStarted:(int64_t)timestamp isInPoint:(bool)isInPoint {
    self.boundingView.hidden = YES;
}

- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint {
    NvStickerModel *model = [self getCurrentTimeSpan:self.currentSticker];
    self.isChange = YES;
    if (isInPoint) {
        model.infoModel.inPoint = timestamp;
        [self seekTimeline:timestamp];
        self.timeLabel->timeLabel.text= [NSString stringWithFormat:@"%@/%@",[NvUtils convertTimecodePrecision:timestamp],[NvUtils convertTimecodePrecision:self.timeline.duration]];
    } else {
        model.infoModel.outPoint = timestamp;
        [self seekTimelineWithoutFlag:timestamp-10000];
        self.timeLabel->timeLabel.text= [NSString stringWithFormat:@"%@/%@",[NvUtils convertTimecodePrecision:timestamp-10000],[NvUtils convertTimecodePrecision:self.timeline.duration]];
    }
}

- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)timestamp isInPoint:(bool)isInPoint {
    self.isChange = NO;
    [self.timelineEditor setTimelinePosition:timestamp];
    NvStickerModel *modelnext = [self getCurrentTimeSpan:self.currentSticker];
    if (self.currentSticker) {
        [self.timelineEditor selectTimeSpan:modelnext.timeSpan];
    }
    
    if (isInPoint) {
        [self seekTimelineWithoutFlag:timestamp];
        ///删除所有关键帧
        ///Delete all key frames
        for (NSString *string in self.currentStickerInfoModel.keyArray) {
            if (![self.currentSticker removeAllKeyframe:string]) {
                NSLog(@"关键帧删除失败 The keyframe deletion failed. Procedure%@",string);
            }
        }
        
        NSMutableArray *tempArray = [NSMutableArray array];
        for (int i = 0; i < self.currentStickerInfoModel.keyFramesArray.count; i++) {
            NvKeyFrameStickerModel *tempModel = self.currentStickerInfoModel.keyFramesArray[i];
            if (timestamp >= tempModel.time) {
                [tempArray addObject:tempModel];
            }else{
                tempModel.pos = tempModel.time - timestamp;
                [self.currentSticker setCurrentKeyFrameTime:tempModel.pos];
                [self.currentSticker setScale:tempModel.scale];
                [self.currentSticker setRotationZ:tempModel.rotation];
                [self.currentSticker setTranslation:tempModel.translation];
            }
        }
        
        for (NvKeyFrameStickerModel *tempModel in tempArray) {
            [self.currentStickerInfoModel.keyFramesArray removeObject:tempModel];
        }
        
        [self.currentSticker changeInPoint:timestamp];
        
        self.keyFrameView.model.inPoint = timestamp;
        [self seekTimelineWithoutFlag:timestamp];
        if ([self underShowKeyFrameViewState]) {
            [self.timelineEditor configKeyFrames:[self numberArray:self.currentStickerInfoModel.keyFramesArray] withSpanInPoint:timestamp withOutPoint:self.currentSticker.outPoint];
            [self.keyFrameView configTime:timestamp withEnd:YES];
            [self getCurrentPosBorder:timestamp];
        }
    } else {
        [self seekTimelineWithoutFlag:timestamp-10000];
        
        NSMutableArray *tempArray = [NSMutableArray array];
        for (int i = 0; i < self.currentStickerInfoModel.keyFramesArray.count; i++) {
            NvKeyFrameStickerModel *tempModel = self.currentStickerInfoModel.keyFramesArray[i];
            if (timestamp <= tempModel.time) {
                [tempArray addObject:tempModel];
            }
        }
        
        for (NvKeyFrameStickerModel *tempModel in tempArray) {
            for (NSString *string in self.currentStickerInfoModel.keyArray) {
                if (![self.currentSticker removeKeyframeAtTime:string time:tempModel.pos]) {
                    
                }
            }
            [self.currentStickerInfoModel.keyFramesArray removeObject:tempModel];
        }
        
        [self.currentSticker changeOutPoint:timestamp];
        self.keyFrameView.model.outPoint = timestamp;
        
        [self seekTimelineWithoutFlag:timestamp-10000];
        
        if ([self underShowKeyFrameViewState]) {
            [self.timelineEditor configKeyFrames:[self numberArray:self.currentStickerInfoModel.keyFramesArray] withSpanInPoint:self.currentSticker.inPoint withOutPoint:timestamp];
            
            [self.keyFrameView configTime:timestamp withEnd:YES];
            [self getCurrentPosBorder:timestamp];
        }
    }
}

#pragma mark 有关键帧的情况下，获取当前位置边框
///Gets the current position border if there is a keyframe
- (void)getCurrentPosBorder:(int64_t)pos{
    if ([self underShowKeyFrameViewState]) {
        if (!self.keyFrameView.currentModel) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.currentSticker setCurrentKeyFrameTime:pos - self.currentStickerInfoModel.inPoint];
                [self showBoundingView];
                for (NSString *string in self.keyFrameStringArray) {
                    [self.currentSticker removeKeyframeAtTime:string time:pos-self.currentStickerInfoModel.inPoint];
                }
            });
        }
    }else{
        ///判断此时间点是否有关键帧
        ///Determines whether there are keyframes at this point in time
        ///有关键帧的话，获取当前贴纸位置画框
        ///If there is a keyframe, get the current sticker position frame
        ///无关键帧（考虑贴纸处于运动中），通过添加关键帧获取位置画框，然后将新加关键帧删除
        ///No keyframe (considering the sticker is in motion), get the position frame by adding the keyframe, and then delete the new keyframe
        BOOL hasKeyFrame = NO;
        for (NvKeyFrameStickerModel *model in self.currentStickerInfoModel.keyFramesArray) {
            if (model.time == (pos - self.currentStickerInfoModel.inPoint)) {
                hasKeyFrame = YES;
                break;
            }
        }
        if (hasKeyFrame) {
            if (pos == 0) {
                [self.currentSticker setCurrentKeyFrameTime:pos - self.currentStickerInfoModel.inPoint];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showBoundingView];
            });
        }else if (self.currentStickerInfoModel.keyFramesArray.count > 0){
            [self.currentSticker setCurrentKeyFrameTime:pos - self.currentStickerInfoModel.inPoint];
            [self showBoundingView];
            for (NSString *string in self.keyFrameStringArray) {
                [self.currentSticker removeKeyframeAtTime:string time:pos-self.currentStickerInfoModel.inPoint];
            }
        }
        else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showBoundingView];
            });
        }
    }
}

- (void)timelineEditor:(id)timelineEditor dragScrollingTimeline:(int64_t)timestamp {
    self.isChange = YES;
    [self seekTimelineWithoutFlag:timestamp];
    self.liveWindowPanel.currentTime = timestamp;
    self.timeLabel.currentPos = timestamp;
    [self.timeLabel updateLabel];
    
    [self keyFrameButtonHidden:YES withState:YES];
    self.boundingView.hidden = YES;
    if (!self.keyFrameView.hidden) {
        [self.keyFrameView configTime:timestamp withEnd:NO];
    }
}

- (void)timelineEditor:(id)timelineEditor dragScrollTimelineEnded:(int64_t)timestamp {
    self.isChange = NO;
    if ([self underShowKeyFrameViewState]) {
        [self seekTimelineWithoutFlag:timestamp];
        if (timestamp >= self.currentSticker.inPoint && timestamp < self.currentSticker.outPoint) {
            
            
            NvStickerModel *modelInfo = [self getCurrentTimeSpan:self.currentSticker];
            self.currentStickerInfoModel = modelInfo.infoModel;
            
            [self.timelineEditor selectTimeSpan:modelInfo.timeSpan];
            
            if (modelInfo.infoModel.keyFramesArray.count > 0) {
                [self keyFrameButtonHidden:NO withState:YES];
                [self getCurrentPosBorder:timestamp];
            }else{
                [self keyFrameButtonHidden:NO withState:NO];
            }

            self.boundingView.hidden = NO;
            
            [self.keyFrameView configTime:timestamp withEnd:YES];
            
            [self.timelineEditor configKeyFrames:[self numberArray:self.currentStickerInfoModel.keyFramesArray] withSpanInPoint:self.currentStickerInfoModel.inPoint withOutPoint:self.currentStickerInfoModel.outPoint];
            if (self.keyFrameView.currentModel) {
                [self.timelineEditor configSelectKeyFrames:self.keyFrameView.indexPath];
            }
        }else{
            [self.timelineEditor selectTimeSpan:nil];
        }
    }else{
        NvStickerModel *model = [self getCurrentTimeSpan:self.currentSticker];
        [self.timelineEditor selectTimeSpan:model.timeSpan];
        
        self.currentSticker = [[self.videoClip getAnimatedStickersByClipTimePosition:timestamp] lastObject];
        
        if (self.currentSticker) {
            NvStickerModel *modelInfo = [self getCurrentTimeSpan:self.currentSticker];
            self.currentStickerInfoModel = modelInfo.infoModel;
            [self.timelineEditor selectTimeSpan:modelInfo.timeSpan];
            
            if (modelInfo.infoModel.keyFramesArray.count > 0) {
                [self keyFrameButtonHidden:NO withState:YES];
                [self getCurrentPosBorder:timestamp];
            }else{
                [self keyFrameButtonHidden:NO withState:NO];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self showBoundingView];
                });
            }
        } else {
            [self.timelineEditor selectTimeSpan:nil];
            [self keyFrameButtonHidden:YES withState:YES];
        }
        
        [self seekTimelineWithoutFlag:timestamp];

        self.boundingView.hidden = self.currentSticker?NO:YES;
    }
}

#pragma mark 是否可以操作贴纸
///Whether you can operate the sticker
- (BOOL)prohibitOperation{
    if (self.currentStickerInfoModel.keyFramesArray.count > 0 && (self.keyFrameView.hidden || !self.keyFrameView)) {
        return YES;
    }
    return NO;
}

#pragma mark 关键帧视图已经存在，且目前是关键帧模式
///The keyframe view already exists and is currently in keyframe mode

/*
 关键帧面板开启，贴纸的边框要根据当前seek的位置是否有关键帧，隐藏显示边框
 关键帧面板关闭，贴纸的边框要根据当前seek的位置是否有贴纸，隐藏显示边框
 
 When the keyframe panel is opened, the frame of the sticker should be hidden according to whether there is a keyframe in the current seek position
 The keyframe panel is closed, and the frame of the sticker should be hidden according to whether there is a sticker in the current seek position
*/
- (BOOL)underShowKeyFrameViewState {
    return (self.keyFrameView && !self.keyFrameView.hidden);
}

# pragma mark NvTimeLabelViewDelegate
- (void)onZoomInClicked {
    [_timelineEditor zoomIn];
}

- (void)onZoomOutClicked {
    [_timelineEditor zoomOut];
}

#pragma mark NvEditStickerKeyFrameViewDelegate
/**
 添加删除关键帧回调 NvEditStickerKeyFrameViewDelegate
 Add delete keyframe callback NvEditStickerKeyFrameViewDelegate
 */
-(void)keyFrameView:(NvEditClipStickerKeyFrameView *)keyFrame withState:(NvKeyFrameType)type withModel:(NvKeyFrameStickerModel *)keyModel{
    if (type == NvKeyFrameTypeAdd) {
        self.keyFrameModel = keyModel;
        [self.currentSticker setCurrentKeyFrameTime:keyModel.pos];
        
        if (self.keyFrameModel.translation.x == 0 && self.keyFrameModel.translation.y == 0) {
            if (self.keyFrameModel.rotation == 0 && self.keyFrameModel.scale == 1) {
                NSArray *array = [self.currentSticker getBoundingRectangleVertices];
                CGPoint center = [self getCenterWithArray:array];
                [self.currentSticker translateAnimatedSticker:self.keyFrameModel.translation];
                [self.currentSticker scaleAnimatedSticker:self.keyFrameModel.scale anchor:center];
                [self.currentSticker rotateAnimatedSticker:self.keyFrameModel.rotation anchor:center];
                
                self.keyFrameModel.translation = [self.currentSticker getTransltion];
                self.keyFrameModel.rotation = [self.currentSticker getRotationZ];
                self.keyFrameModel.scale = [self.currentSticker getScale];
            }
        }
        
        [self.timelineEditor configKeyFrames:[self numberArray:self.currentStickerInfoModel.keyFramesArray] withSpanInPoint:self.currentStickerInfoModel.inPoint withOutPoint:self.currentStickerInfoModel.outPoint];
        [self.timelineEditor configSelectKeyFrames:keyFrame.indexPath];
    }else if(type == NvKeyFrameTypeDelete){
        self.keyFrameModel = nil;
        for (NSString *string in self.currentStickerInfoModel.keyArray) {
            if (![self.currentSticker removeKeyframeAtTime:string time:keyFrame.deletePos]) {
                NSLog(@"关键帧删除失败 The keyframe deletion failed. Procedure%@",string);
            }
        }
        [self.timelineEditor configKeyFrames:[self numberArray:self.currentStickerInfoModel.keyFramesArray] withSpanInPoint:self.currentStickerInfoModel.inPoint withOutPoint:self.currentStickerInfoModel.outPoint];
        [keyFrame configTime:keyFrame.deletePos+keyFrame.model.inPoint withEnd:YES];
        [self seekTimeline:keyFrame.deletePos+keyFrame.model.inPoint];
        
        if (self.currentStickerInfoModel.keyFramesArray.count == 0) {
            ///注：退出关键帧模式需要将当前关键帧时间设为-1
            ///Note: To exit keyframe mode, you need to set the current keyframe time to -1
            [self.currentSticker setCurrentKeyFrameTime:-1];
            
            self.currentStickerInfoModel.translation = CGPointZero;
            self.currentStickerInfoModel.rotation = 0;
            self.currentStickerInfoModel.scale = 1;
            [self.currentSticker translateAnimatedSticker:self.currentStickerInfoModel.translation];
            [self.currentSticker setScale:self.currentStickerInfoModel.scale];
            [self.currentSticker setRotationZ:self.currentStickerInfoModel.rotation];
            [self showBoundingView];
            [self seekTimeline:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
        }else{
            [self getCurrentPosBorder:keyFrame.deletePos+keyFrame.model.inPoint];
        }
    }else if (type == NvKeyFrameTypeSelected){
        self.keyFrameModel = keyModel;
        [self.currentSticker setCurrentKeyFrameTime:keyModel.pos];
        [self seekTimeline:keyModel.time];
        [self.timelineEditor setTimelinePosition:keyModel.time];
        [self.timelineEditor configSelectKeyFrames:keyFrame.indexPath];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getCurrentPosBorder:keyModel.time];
            [self showBoundingView];
        });
        
    }else if (type == NvKeyFrameTypeNoSelected){
        self.keyFrameModel = nil;
        [self.timelineEditor removeAllKeyFramesSelectState];
    }
}
/**
 完成按钮点击回调
 Click the finish button to call back
 */
- (void)keyFrameViewFinsh:(NvEditClipStickerKeyFrameView *)keyFrame{
    [self.timelineEditor configKeyFrames:[@[] mutableCopy] withSpanInPoint:self.currentStickerInfoModel.inPoint withOutPoint:self.currentStickerInfoModel.outPoint];
    if (self.currentStickerInfoModel.keyFramesArray.count > 0) {
        [self keyFrameButtonHidden:NO withState:YES];
    }else{
        [self keyFrameButtonHidden:NO withState:NO];
    }
}

# pragma mark NvLiveWindowPanelViewDelegate
- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    _liveWindowPanel.currentTime = position;
    
    [self keyFrameButtonHidden:YES withState:YES];
    self.removeKeyBtn.hidden = YES;
    self.boundingView.hidden = YES;
    
    if ([self underShowKeyFrameViewState]) {
        [self.keyFrameView prohibitOperation];
    }
    
    if (self.selectPanelView.hidden) {
        ///在调节页面
        ///On the adjustment page
        ///清除选中状态
        ///Clear selected state
        [_timelineEditor clearTimeSpanSelection];
        self.timeLabel.currentPos = position;
        [self.timeLabel updateLabel];
        
        [self.timelineEditor setTimelinePosition:position];
        
    } else {
        ///在添加页面
        ///In the add page
        if (position >= self.currentSticker.outPoint) {
            [self seekTimeline:self.currentSticker.inPoint];
            [self.timelineEditor setTimelinePosition:self.currentSticker.inPoint];
            [self.timelineEditor selectTimeSpan:self.currentSticker.inPoint outPoint:self.currentSticker.outPoint];
            _liveWindowPanel.currentTime = self.currentSticker.inPoint;
        }
    }
}

- (void)didPlaybackStopped:(NvsTimeline *)timeline {
    if (self.selectPanelView.hidden) {
        ///在调节页面
        ///On the adjustment page
        if ([self underShowKeyFrameViewState]) {
            if ([self.streamingContext getTimelineCurrentPosition:timeline] > self.currentSticker.inPoint && [self.streamingContext getTimelineCurrentPosition:timeline] < self.currentSticker.outPoint) {
                
                [self.keyFrameView configTime:[self.streamingContext getTimelineCurrentPosition:self.timeline] withEnd:YES];
                
                if (self.currentStickerInfoModel.keyFramesArray.count > 0) {
                    [self keyFrameButtonHidden:NO withState:YES];
                    [self getCurrentPosBorder:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
                }else{
                    [self keyFrameButtonHidden:NO withState:NO];
                }
            }else{
                [self keyFrameButtonHidden:YES withState:NO];
                self.removeKeyBtn.hidden = YES;
            }
        }else{
            int64_t position = [self.streamingContext getTimelineCurrentPosition:self.timeline];
            if(self.currentSticker.inPoint <= position && self.currentSticker.outPoint >= position && self.currentSticker) {
                
            }else{
                self.currentSticker = [[self.videoClip getAnimatedStickersByClipTimePosition:position] lastObject];
            }
            

            self.boundingView.hidden = self.currentSticker?NO:YES;
            
            [self.timelineEditor clearTimeSpanSelection];
            [self.timelineEditor selectTimeSpan:self.currentSticker.inPoint outPoint:self.currentSticker.outPoint];
            
            if (self.currentSticker) {
                if (self.currentStickerInfoModel.keyFramesArray.count > 0) {
                    [self keyFrameButtonHidden:NO withState:YES];
                    [self getCurrentPosBorder:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
                }else{
                    [self keyFrameButtonHidden:NO withState:NO];
                }
            }else{
                [self keyFrameButtonHidden:YES withState:NO];
                self.removeKeyBtn.hidden = YES;
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.currentStickerInfoModel.keyFramesArray.count == 0) {
                    [self showBoundingView];
                }
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self seekTimeline:self.currentSticker.inPoint];
            [self showBoundingView];
        });
    }
}

- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    _liveWindowPanel.currentTime = 0;
    if (self.selectPanelView.hidden) {
        ///在调节页面
        ///On the adjustment page
        self.timeLabel.currentPos = 0;
        [self.timeLabel updateLabel];
        
        [self.timelineEditor setTimelinePosition:self.timeLabel.currentPos];
        [self seekTimeline:0];
        
        self.currentSticker = [[self.videoClip getAnimatedStickersByClipTimePosition:[self.streamingContext getTimelineCurrentPosition:self.timeline]] lastObject];
        [self.timelineEditor clearTimeSpanSelection];
        [self.timelineEditor selectTimeSpan:self.currentSticker.inPoint outPoint:self.currentSticker.outPoint];
        [self showBoundingView];
    } else {
        
    }
}

- (void)sliderValueChanged:(float)value {
    self.timeLabel.currentPos = value*self.timeline.duration;
    [self.timeLabel updateLabel];
    
    [self.timelineEditor setTimelinePosition:self.timeLabel.currentPos];
}

- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state {
    if (self.selectPanelView.hidden) {
        ///在调节页面
        ///On the adjustment page
        if (state != NvsStreamingEngineState_Playback) {
            [self.playBtn setImage:[UIImage imageNamed:@"NvPlayback"] forState:UIControlStateNormal];
        } else {
            [self.playBtn setImage:[UIImage imageNamed:@"NvPause"] forState:UIControlStateNormal];
            self.boundingView.hidden = YES;
            [self.timelineEditor clearTimeSpanSelection];
        }
    } else {
        ///在添加页面
        ///In the add page
        NvAssetCellModel *stickerInfo = self.currentStickerArray[self.currentIndexPath.item];
        if (state != NvsStreamingEngineState_Playback) {
            [self.playBtn setImage:[UIImage imageNamed:@"NvPlayback"] forState:UIControlStateNormal];
            stickerInfo.isPlay = NO;
            
        } else {
            [self.playBtn setImage:[UIImage imageNamed:@"NvPause"] forState:UIControlStateNormal];
            self.boundingView.hidden = YES;
            stickerInfo.isPlay = YES;
        }
        [self.currentView reloadData];
    }
}

#pragma mark - NvsStreamingContextDelegate
- (void)didSeekingTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    if (position == 0) {
        [self getCurrentPosBorder:position];
    }
}

- (NSMutableArray *)numberArray:(NSMutableArray *)array{
    NSMutableArray *timeArr = [NSMutableArray array];
    for (NvKeyFrameStickerModel *model in array) {
        NSNumber *num = [NSNumber numberWithLongLong:model.time];
        [timeArr addObject:num];
    }
    return timeArr;
}
@end

