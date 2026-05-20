//
//  NvMaskViewController.m
//  SDKDemo
//
//  Created by ms on 2021/3/4.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvMaskViewController.h"
#import "NvMaskMenuItem.h"
#import "NvMaskAssetCell.h"
#import "NvSelectedMaskView.h"
#import "NvMaskMenuBottonView.h"
#import "NvTimelineUtils.h"
#import "NVHeader.h"
#import "SDKDemo-Swift.h"
#import "NvTimelineUtils.h"
#import "NvCaptionDialogViewController.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import <Masonry/Masonry.h>
#import <NvBaseCommon/NvToast.h>
@interface NvMaskViewController ()<NvLiveWindowPanelViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource,NvCaptionDialogViewControllerDelegate, NvMaskRectViewDelegate>
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NvSelectedMaskView *selectMaskView;
@property (nonatomic, strong) NvMaskMenuBottonView *bottomView;
@property (nonatomic, strong) NvEditDataModel *currentAsset;
@property (nonatomic, strong) NvMaskModel *currentMaskModel;
@property (nonatomic, strong) NvsVideoClip *currentClip;
@property (nonatomic, assign) unsigned int currentClipIndex;
@property (nonatomic, strong) NvMaskAssetCell *currentCell;
/// 是否选中clip
@property (nonatomic, assign) BOOL isSelectedClip;

@property (nonatomic, strong) NvMaskRectView *rectMaskView;
//中间clip素材界面数组
// Intermediate clip interface array
@property (nonatomic, strong) NSMutableArray *collectData;

@property (nonatomic, strong) UIButton *topControlBtn;
@end
static NSString *const NvMaskAssetCellID = @"NvMaskAssetCell";
@implementation NvMaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NvLocalString(@"Mask", @"蒙版");
    [self initTimeline];
    self.liveWindowPanel.isAnimationPlayback = NO;
    self.liveWindowPanel.delegate = self;
    self.liveWindowPanel.dontNeedSeekCtl = YES;
    [self initData];
    [self initCollectionViewData];
    [self initSubviews];

    self.currentAsset = self.editDataArray[0];
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    self.currentClip = [videoTrack getClipWithIndex:0];
    
    [self initMask];
    [self.liveWindowPanel hiddenVolumeButton];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
}

/**
 初始化设置蒙版
 Initialization settings mask
 */
-(void)initMask{
    
    NvEditDataModel *editDataModel = self.editDataArray[0];
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    NvsVideoClip *clip = [videoTrack getClipWithIndex:0];
    clip.maskModel = editDataModel.maskInfoModel;
    
    CGSize assetSize = CGSizeZero;
    if (editDataModel.isImage) {
        assetSize = [NvTimelineUtils getAVFileSize:editDataModel.localIdentifier];
    }else{
        assetSize = [NvTimelineUtils getAVFileSize:editDataModel.videoPath];
    }
    CGSize cropSize = [clip clipSizeWithCrop];
    if(!CGSizeEqualToSize(cropSize, CGSizeZero)){
        assetSize = cropSize;
    }
    [NvMaskHelper prepareMaskRegionPointsWithMaskModel:editDataModel.maskInfoModel assetResolution:assetSize];
    [clip setMaskWithMaskModel:editDataModel.maskInfoModel resolution:assetSize];
    [clip setImageMotionMode:NvsStreamingEngineImageClipMotionMode_LetterBoxZoomIn];
    [clip setImageMotionAnimationEnabled:NO];
    [self.rectMaskView loadMaskModelWithVideoClip:clip  liveWindow:self.liveWindowPanel.liveWindow timelineResolution:self.timeline.videoRes assetResolution:assetSize transformModel:[NvTransformModel new]];

}

-(void)seekTime{
    [[NvSDKUtils getSDKContext] seekTimeline:self.timeline timestamp:1000 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}
/**
 初始化数据
 Initialization data
 */
-(void)initData{
    self.isSelectedClip = NO;
    self.dataArray = [NSMutableArray array];
    NSArray *names = @[NvLocalString(@"None", @"无"),
                       NvLocalString(@"Line" , @"线性"),
                      NvLocalString(@"Mirror", @"镜面"),
                      NvLocalString(@"Circle", @"圆形"),
                      NvLocalString(@"Rect", @"矩形"),
                      NvLocalString(@"heart", @"心形"),
                      NvLocalString(@"Star", @"星形"),
                      NvLocalString(@"Caption Mask",@"字幕蒙版"),
    ];
    
    NSArray *images = @[@"NvMaskNone",
                        @"NvlineMask",
                           @"NvMirrorMask",
                           @"NvCircleMask",
                           @"NvRectMask",
                           @"NvHeartMask",
                           @"NvStarMask",
                           @"NvCaptionMask",
    ];
    
    
    for (int i = 0; i < names.count; i++) {
        
        NvMaskMenuItem *item = [NvMaskMenuItem new];
        if (i == 0) {
            item.isSelected = YES;
        }else{
            item.isSelected = NO;
        }
        item.name = names[i];
        
        item.image = images[i];
        item.maskType = i;
        [self.dataArray addObject:item];
    }
    
    for (int i = 0; i < self.dataArray.count; i ++) {
        NvMaskMenuItem *item = self.dataArray[i];
        if (i == self.currentAsset.maskInfoModel.maskType) {
            item.isSelected = YES;
        }else{
            item.isSelected = NO;
        }
    }
    
    self.bottomView.dataArray = self.dataArray;
}

- (void)initCollectionViewData {
    self.collectData = [NSMutableArray array];
    for (NvEditDataModel *editModel in self.editDataArray) {
        NvMaskAssetModel *model = [NvMaskAssetModel new];
        model.isSelected = NO;
        model.trimIn = editModel.trimIn;
        model.trimOut = editModel.trimOut;
        model.thumImage = editModel.thumImage;
        [self.collectData addObject:model];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)connectLiveWindow {
    [self.liveWindowPanel connectTimeline:self.timeline];
    [self seekTimeline:self.liveWindowPanel.currentTime];
}

// 定位某一时间戳的图像
- (void)seekTimeline:(int64_t)postion {
    int flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (![[NvSDKUtils getSDKContext] seekTimeline:self.timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag])
        NSLog(@"定位时间线失败！Failed to seek timeline!");
}


-(void)initSubviews{
    [self initCollectionView];
    [self.view addSubview:self.selectMaskView];
    [self.selectMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        if (NV_STATUSBARHEIGHT > 20) {
            make.height.mas_equalTo(140.0 + INDICATOR + 20);
        }else{
            make.height.mas_equalTo(140.0);
        }
    }];
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        if (NV_STATUSBARHEIGHT > 20) {
            make.height.mas_equalTo(160.0 + INDICATOR + 20);
        }else{
            make.height.mas_equalTo(160.0);
        }
    }];
    self.bottomView.hidden = YES;
    
    if(!_rectMaskView) {
        [self.liveWindowPanel layoutSubviews];
        self.rectMaskView = [[NvMaskRectView alloc] initWithFrame:self.liveWindowPanel.liveWindow.frame];
        self.rectMaskView.delegate = self;
        [self.liveWindowPanel addSubview:self.rectMaskView];
        [self.liveWindowPanel bringSubviewToFront:self.liveWindowPanel.controlPanelView];
        self.topControlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.topControlBtn.backgroundColor = [UIColor clearColor];
        self.topControlBtn.frame = self.liveWindowPanel.controlPanelView.frame;
        [self.liveWindowPanel addSubview:self.topControlBtn];
        [self.topControlBtn addTarget:self action:@selector(topControlBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.liveWindowPanel bringSubviewToFront:self.liveWindowPanel.controlPanelView];
    }
}

-(void)topControlBtnClick:(UIButton *)btn{
    self.liveWindowPanel.controlPanelView.hidden = NO;
    [self.liveWindowPanel bringSubviewToFront:self.liveWindowPanel.controlPanelView];
}

//重新创建timeline和数据结构
// Recreate the timeline and data structure
- (void)initTimeline {
    self.timeline = [NvTimelineUtils createTimeline:self.editMode];
    [NvTimelineUtils recreateTimeline:self.timeline];
    NvTimelineData *data = [NvTimelineData sharedInstance];
    
    [NvTimelineUtils resetAnimationFx:self.timeline model:data];
}

-(void)initCollectionView{
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - NV_STATUSBARHEIGHT - NV_NAV_BAR_HEIGHT) collectionViewLayout:self.flowLayout];
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.bounces = YES;
    [self.collectionView registerClass:[NvMaskAssetCell class] forCellWithReuseIdentifier:NvMaskAssetCellID];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0,  0);
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(60.0*SCREENSCALE);
        make.top.mas_equalTo(self.liveWindowPanel.liveWindow.mas_bottom).offset(40*SCREENSCALE);
    }];
    [self.collectionView reloadData];
    
}

- (int64_t)getCurrentTime {
    return [self.streamingContext getTimelineCurrentPosition:self.timeline];
}

#pragma mark - NvMaskRectViewDelegate
-(void)maskModelChangedWithMaskModel:(NvMaskModel *)maskModel{
    [self seekTimeline:[self getCurrentTime]];
}

/**
 点击字幕蒙版回调
 Click subtitle mask callback
 */
-(void)maskTapWithMaskModel:(NvMaskModel *)maskModel{
    if (maskModel.maskType == NvClipMaskTypeText && maskModel.text && ![maskModel.text isEqualToString:@""]) {
        NvCaptionDialogViewController *dialogVC = [NvCaptionDialogViewController new];
        dialogVC.delegate = self;
        dialogVC.isIgnoreEmoij = YES;
        [dialogVC setCaptionText:maskModel.text];
        [dialogVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        //必要配置 Necessary configuration
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        
        [self presentViewController:dialogVC animated:YES completion:NULL];
    }
}

#pragma mark - NvCaptionDialogViewControllerDelegate
- (void)captionDialog:(NvCaptionDialogViewController *)captionDialog clickButtonIndex:(NSInteger)index {
    //编辑模式下修改字幕 Modify subtitles in edit mode
    if (index == 0) {
        NSString* text = [captionDialog getCaptionText];
        NvsVideoClip *clip = self.currentClip;
        CGSize assetSize = CGSizeZero;
        CGSize cropSize = [clip clipSizeWithCrop];
        if(CGSizeEqualToSize(cropSize, CGSizeZero)){
            if (self.currentAsset.isImage) {
                assetSize = [NvTimelineUtils getAVFileSize:self.currentAsset.localIdentifier];
                self.currentClip.imageMotionMode = NvsStreamingEngineImageClipMotionMode_LetterBoxZoomIn;
                self.currentClip.imageMotionAnimationEnabled = NO;
            }else{
                assetSize = [NvTimelineUtils getAVFileSize:self.currentAsset.videoPath];
            }
        }else{
            assetSize = cropSize;
        }
        
        self.currentAsset.maskInfoModel.maskType = NvClipMaskTypeText;
        self.currentAsset.maskInfoModel.text = text;
        
        [NvMaskHelper prepareMaskRegionPointsWithMaskModel:self.currentAsset.maskInfoModel assetResolution:assetSize];
        [self.currentClip setMaskWithMaskModel:self.currentAsset.maskInfoModel resolution:assetSize];
        
        
        [self.rectMaskView loadMaskModelWithVideoClip:self.currentClip liveWindow:self.liveWindowPanel.liveWindow timelineResolution:self.timeline.videoRes assetResolution:assetSize transformModel:[NvTransformModel new]];
        [self seekTimeline:clip.inPoint];
    } else {
        
    }
    [captionDialog dismissViewControllerAnimated:NO completion:NULL];
}


#pragma mark - UICollectionView Delegate

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NvMaskAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NvMaskAssetCellID forIndexPath:indexPath];
    cell.model = self.collectData[indexPath.item];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectData.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.isSelectedClip = YES;
    self.currentClipIndex = (unsigned int)indexPath.item;
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    NvsVideoClip *clip = [videoTrack getClipWithIndex:self.currentClipIndex];
    self.currentClip = clip;
    self.currentAsset = self.editDataArray[indexPath.item];

    for (int i = 0; i<self.collectData.count; i++) {
        NvMaskAssetModel *asset = self.collectData[i];
        if (i == indexPath.item) {
            asset.isSelected = YES;
        }else{
            asset.isSelected  = NO;
        }
    }
    [collectionView reloadData];
    

    uint64_t start, end;
    start = clip.inPoint;
    end = clip.outPoint;
    [self.liveWindowPanel playBackStart:start end:end];
    [collectionView layoutIfNeeded];
    self.currentCell = (NvMaskAssetCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    CGSize assetSize = CGSizeZero;
    CGSize cropSize = [clip clipSizeWithCrop];
    if(CGSizeEqualToSize(cropSize, CGSizeZero)){
        if (self.currentAsset.isImage) {
            assetSize = [NvTimelineUtils getAVFileSize:self.currentAsset.localIdentifier];
        }else{
            assetSize = [NvTimelineUtils getAVFileSize:self.currentAsset.videoPath];
        }
    }else{
        assetSize = cropSize;
    }

    [NvMaskHelper prepareMaskRegionPointsWithMaskModel:self.currentAsset.maskInfoModel assetResolution:assetSize];
    [clip setMaskWithMaskModel:self.currentAsset.maskInfoModel resolution:assetSize];
    
    [self.rectMaskView loadMaskModelWithVideoClip:self.currentClip liveWindow:self.liveWindowPanel.liveWindow timelineResolution:self.timeline.videoRes assetResolution:assetSize transformModel:[NvTransformModel new]];
    
    for (int i = 0; i < self.dataArray.count; i ++) {
        NvMaskMenuItem *model = self.dataArray[i];
        if (i == self.currentAsset.maskInfoModel.maskType) {
            model.isSelected = YES;
        }else{
            model.isSelected = NO;
        }
    }
    self.bottomView.dataArray = self.dataArray;
}

#pragma mark - Lazy Load

-(UICollectionViewFlowLayout *)flowLayout{
    if (_flowLayout == nil){
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = CGSizeMake(77.0*SCREENSCALE, 50.0*SCREENSCALE);
        _flowLayout.minimumInteritemSpacing = 5 * SCREENSCALE;
        _flowLayout.minimumLineSpacing = 5 * SCREENSCALE;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}


-(NvSelectedMaskView *)selectMaskView{
    __weak typeof(self)weakSelf = self;
    if (!_selectMaskView) {
        _selectMaskView = [[NvSelectedMaskView alloc] init];
        _selectMaskView.okBtnClick = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
            
            weakSelf.currentAsset.maskInfoModel = weakSelf.currentClip.maskModel;
        };
        _selectMaskView.addMaskBtnClick = ^{
            
            if (!weakSelf.isSelectedClip) {
                [NvToast showInfoWithMessage:NvLocalString(@"Please select a video clip to add mask first", @"请先选择添加蒙版的视频片段")];
                return;
            }
            weakSelf.bottomView.hidden = NO;
            
        };
    }
    return _selectMaskView;
}

/**
 添加蒙版视图
 Add mask view
 */
-(NvMaskMenuBottonView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[NvMaskMenuBottonView alloc] init];
        __weak typeof(self)weakSelf = self;
        _bottomView.selectItemClick = ^(NvClipMaskType type) {
            
            if (type == NvClipMaskTypeText) {
                NvCaptionDialogViewController *dialogVC = [NvCaptionDialogViewController new];
                dialogVC.delegate = weakSelf;
                dialogVC.isIgnoreEmoij = YES;
                [dialogVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
                //必要配置 Necessary configuration
                weakSelf.modalPresentationStyle = UIModalPresentationCurrentContext;
                weakSelf.providesPresentationContextTransitionStyle = YES;
                weakSelf.definesPresentationContext = YES;
                [weakSelf presentViewController:dialogVC animated:YES completion:NULL];
                return;
            }
            
            NvsVideoTrack *videoTrack = [weakSelf.timeline getVideoTrackByIndex:0];
            NvsVideoClip *clip = [videoTrack getClipWithIndex:weakSelf.currentClipIndex];
            
            CGSize assetSize = CGSizeZero;
            CGSize cropSize = [clip clipSizeWithCrop];
            if(CGSizeEqualToSize(cropSize, CGSizeZero)){
                if (weakSelf.currentAsset.isImage) {
                    assetSize = [NvTimelineUtils getAVFileSize:weakSelf.currentAsset.localIdentifier];
                }else{
                    assetSize = [NvTimelineUtils getAVFileSize:weakSelf.currentAsset.videoPath];
                }
            }else{
                assetSize = cropSize;
            }
            weakSelf.currentAsset.maskInfoModel.maskType = type;
            
            [clip setImageMotionMode:NvsStreamingEngineImageClipMotionMode_LetterBoxZoomIn];
            [clip setImageMotionAnimationEnabled:NO];
            
            [NvMaskHelper prepareMaskRegionPointsWithMaskModel:weakSelf.currentAsset.maskInfoModel assetResolution:assetSize];
            [clip setMaskWithMaskModel:weakSelf.currentAsset.maskInfoModel resolution:assetSize];
            
            
            [weakSelf.rectMaskView loadMaskModelWithVideoClip:weakSelf.currentClip liveWindow:weakSelf.liveWindowPanel.liveWindow timelineResolution:weakSelf.timeline.videoRes assetResolution:assetSize transformModel:[NvTransformModel new]];
            
            [[NvSDKUtils getSDKContext] seekTimeline:weakSelf.timeline timestamp:clip.inPoint videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
        };
        _bottomView.okBtnClick = ^{
            weakSelf.bottomView.hidden = YES;
            weakSelf.currentAsset.maskInfoModel = weakSelf.currentClip.maskModel;
        };
        _bottomView.flipBtnClick = ^{
            NvsVideoTrack *videoTrack = [weakSelf.timeline getVideoTrackByIndex:0];
            NvsVideoClip *clip = [videoTrack getClipWithIndex:weakSelf.currentClipIndex];
            CGSize assetSize = CGSizeZero;
            CGSize cropSize = [clip clipSizeWithCrop];
            if(CGSizeEqualToSize(cropSize, CGSizeZero)){
                if (weakSelf.currentAsset.isImage) {
                    assetSize = [NvTimelineUtils getAVFileSize:weakSelf.currentAsset.localIdentifier];
                }else{
                    assetSize = [NvTimelineUtils getAVFileSize:weakSelf.currentAsset.videoPath];
                }
            }else{
                assetSize = cropSize;
            }
            weakSelf.currentAsset.maskInfoModel.inverseRegion = !weakSelf.currentAsset.maskInfoModel.inverseRegion;
            [NvMaskHelper prepareMaskRegionPointsWithMaskModel:weakSelf.currentAsset.maskInfoModel assetResolution:assetSize];
            [clip setMaskWithMaskModel:weakSelf.currentAsset.maskInfoModel resolution:assetSize];
            [weakSelf.rectMaskView loadMaskModelWithVideoClip:weakSelf.currentClip liveWindow:weakSelf.liveWindowPanel.liveWindow timelineResolution:weakSelf.timeline.videoRes assetResolution:assetSize transformModel:[NvTransformModel new]];
            [[NvSDKUtils getSDKContext] seekTimeline:weakSelf.timeline timestamp:clip.inPoint videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
        };
        
        
    }
    return _bottomView;
}

- (void)didTapLiveWindowAtTime:(int64_t)pos {

    [self.liveWindowPanel playBackStart:pos end:self.timeline.duration];
}

/**
 点击视图响应
 Click View response
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    CGFloat startY = self.collectionView.frame.origin.y + self.collectionView.frame.size.height;
    CGFloat endY = self.bottomView.frame.origin.y;
    
    if (startY < point.y && point.y < endY) {
        [self.editDataArray enumerateObjectsUsingBlock:^(NvEditDataModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.animationInfoModel.isSelected = NO;
        }];
        [self.collectionView reloadData];
        [self.liveWindowPanel playBackStart:[self.streamingContext getTimelineCurrentPosition:self.timeline] end:self.timeline.duration];
    }
}

@end
