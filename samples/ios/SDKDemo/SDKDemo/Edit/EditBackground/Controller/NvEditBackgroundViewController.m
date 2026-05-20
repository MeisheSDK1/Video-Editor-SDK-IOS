//
//  NvEditBackgroundViewController.m
//  SDKDemo
//
//  Created by MS on 2020/10/21.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvEditBackgroundViewController.h"
#import "NvTimelineUtils.h"
#import "NvBackgroundAssetCell.h"
#import "NvEditBGBottomView.h"
#import "NvEditBGColorView.h"
#import "NvEditBGColorModel.h"
#import "NvEditBGStyleView.h"
#import "NvEditBGStyleModel.h"
#import "NvEditBGBlurView.h"
#import "NvEditBGBlurModel.h"
#import "YYModel.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvLineRectView.h"
#import "NvAlbumViewController.h"
#import <Masonry/Masonry.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvBaseCommon/NvToast.h>
@interface NvEditBackgroundViewController ()<NvLiveWindowPanelViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource,NvEditBGBottomViewDelegate,NvEditBGColorViewDelegate,NvEditBGStyleViewDelegate,NvEditBGBlurViewDelegate,NvLineRectViewDelegate,NvAlbumViewControllerDelegate>
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) unsigned int currentClipIndex;
@property (nonatomic, strong) NvEditDataModel *currentAsset;
@property (nonatomic, strong) NvsVideoClip *currentClip;
@property (nonatomic, strong) NvBackgroundAssetCell *currentCell;
/// 是否选中clip
@property (nonatomic, assign) BOOL isSelectedClip;
@property (nonatomic, strong) NvEditBGBottomView *bottomView;
///画布颜色界面
///Canvas color interface
@property (nonatomic, strong) NvEditBGColorView *colorView;
///画布样式界面
///Canvas style interface
@property (nonatomic, strong) NvEditBGStyleView *styleView;
///模糊界面
///Fuzzy interface
@property (nonatomic, strong) NvEditBGBlurView *blurView;
@property (nonatomic, weak) NvAlbumViewController *albumViewController;
@property (nonatomic, strong) NSMutableArray *styleArr;
@property (nonatomic, strong) NSMutableArray*colorArr;
@property (nonatomic, strong) NSMutableArray *blurArr;
@property (nonatomic, strong) NvLineRectView *rectView;
///当前使用的effectModel
///effectModel currently in use
@property (nonatomic, strong) NvPropertyBackgroundEffectModel *currentEffectModel;
///是否处于旋转吸附角度范围内
///Whether it is within the range of rotational adsorption Angle
@property (nonatomic, assign) BOOL inSensitiveRRange;
///吸附范围内实时旋转角度
///Real time rotation Angle within adsorption range
@property (nonatomic, assign) float totalRotation;
@end

@implementation NvEditBackgroundViewController
{
   dispatch_group_t _group;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NvLocalString(@"Background" ,@"背景");
    self.styleArr = [NSMutableArray array];
    [self preProcessData];
    self.inSensitiveRRange = NO;
    [self initTimeline];
    
    self.liveWindowPanel.isAnimationPlayback = NO;
    self.liveWindowPanel.delegate = self;
    self.liveWindowPanel.dontNeedSeekCtl = YES;
    [self initSubviews];
    
    [self.liveWindowPanel hiddenVolumeButton];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self connectLiveWindow];

}

- (void)preProcessData {
    for(NvEditDataModel *model in self.editDataArray){
        model.backgroundEffectModel.isSelected = NO;
        model.backgroundEffectModel.isUsePropertyEffect = YES;
    }
    if (self.editDataArray.count > 0) {
        NvEditDataModel *firstModel = self.editDataArray[0];
        firstModel.backgroundEffectModel.isSelected = YES;
        self.isSelectedClip = YES;
    }
    
}

///重新创建timeline和数据结构
///Re-create the timeline and data structure
- (void)initTimeline {
    self.timeline = [NvTimelineUtils createTimeline:self.editMode];
    [NvTimelineUtils recreateTimeline:self.timeline];
}

- (void)connectLiveWindow {
    [self.liveWindowPanel connectTimeline:self.timeline];
    [self seekTimeline:self.liveWindowPanel.currentTime];
}

// 定位某一时间戳的图像
- (void)seekTimeline:(int64_t)postion {
    if (![[NvSDKUtils getSDKContext] seekTimeline:self.timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame])
        NSLog(@"定位时间线失败！Failed to seek timeline!");
}

#pragma mark - 界面布局 Interface layout
-(void)initSubviews{
    self.rectView = [[NvLineRectView alloc] initWithFrame:self.liveWindowPanel.bounds];
    self.rectView.hiddenRectLine = YES;
    [self.liveWindowPanel addSubview:self.rectView];
    [self.liveWindowPanel bringSubviewToFront:self.liveWindowPanel.controlPanelView];
    self.rectView.delegate = self;
    [self.liveWindowPanel setAlwaysShowControlPanel:true];
    
    [self initCollectionView];
    self.bottomView = [[NvEditBGBottomView alloc] init];
    self.bottomView.delegate = self;
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        if (NV_STATUSBARHEIGHT > 20) {
            make.height.mas_equalTo(120.0 + INDICATOR + 20);
        }else{
            make.height.mas_equalTo(120.0);
        }
    }];
    [self initColorView];
    [self configColorView];
    [self initStyleView];
    [self configStyleView];
    [self initBlurView];
    [self configBlurView];
}

-(void)initCollectionView{
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - NV_STATUSBARHEIGHT - NV_NAV_BAR_HEIGHT) collectionViewLayout:self.flowLayout];
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.bounces = YES;
    [self.collectionView registerClass:[NvBackgroundAssetCell class] forCellWithReuseIdentifier:@"NvEditBackgroundCellID"];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0,  0);
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(60.0*SCREENSCALE);
        make.top.mas_equalTo(self.liveWindowPanel.liveWindow.mas_bottom).offset(40*SCREENSCALE);
    }];
    [self.collectionView reloadData];
    
}

- (void)initColorView {
    self.colorView = [[NvEditBGColorView alloc] init];
    self.colorView.delegate = self;
    [self.view addSubview:self.colorView];
    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        if (NV_STATUSBARHEIGHT > 20) {
            make.height.mas_equalTo(130.0 + INDICATOR + 20);
        }else{
            make.height.mas_equalTo(130.0);
        }
    }];
    
}

- (void)configColorView {
    NSString *path = [[[NSBundle mainBundle] pathForResource:@"background" ofType:@"bundle"] stringByAppendingPathComponent:@"colorAxis.json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *dictArr = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSArray *modelArr = [NSArray yy_modelArrayWithClass:[NvEditBGColorModel class] json:dictArr];
    self.colorArr = [NSMutableArray arrayWithArray:modelArr];
    [self.colorView configData:self.colorArr];
    self.colorView.hidden = YES;
}

- (void)initStyleView {
    self.styleView = [[NvEditBGStyleView alloc] init];
    self.styleView.delegate = self;
    [self.view addSubview:self.styleView];
    [self.styleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        if (NV_STATUSBARHEIGHT > 20) {
            make.height.mas_equalTo(130.0*SCREENSCALE + INDICATOR + 20);
        }else{
            make.height.mas_equalTo(130.0*SCREENSCALE);
        }
    }];
}

- (void)configStyleView {
    [self.styleArr removeAllObjects];
    NvEditBGStyleModel *addModel = [NvEditBGStyleModel new];
    addModel.cover = @"Nv_edit_bg_style_add";
    [self.styleArr addObject:addModel];
    NvEditBGStyleModel *noneModel = [NvEditBGStyleModel new];
    noneModel.cover = @"Nv_edit_bg_style_none";
    noneModel.packagePath = @"";
    [self.styleArr addObject:noneModel];
    
    NSString *dirPath = [[[NSBundle mainBundle] pathForResource:@"background" ofType:@"bundle"] stringByAppendingPathComponent:@"backgroundImage"];
    NSString *path = [dirPath stringByAppendingPathComponent:@"info.json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *dictArr = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSArray *modelArray = [NSArray yy_modelArrayWithClass:[NvEditBGStyleModel class] json:dictArr];

    for (NvEditBGStyleModel *model in modelArray) {
        model.cover = [dirPath stringByAppendingPathComponent:model.cover];
        model.packagePath = model.cover;
        [self.styleArr addObject:model];
    }
    
    
    NSString *backgroundPath = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_BACKGROUNDSTYLE];
    NSFileManager *manager = [NSFileManager defaultManager];

    if (![manager fileExistsAtPath:backgroundPath isDirectory:nil]) {
        [manager createDirectoryAtPath:backgroundPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:backgroundPath];
    for (NSString *path in enumerator.allObjects) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", backgroundPath, path];
        NvEditBGStyleModel *model = [NvEditBGStyleModel new];
        model.cover = filePath;
        model.packagePath = model.cover;
        [self.styleArr insertObject:model atIndex:2];
    }
    [self.styleView configData:self.styleArr];
    self.styleView.hidden = YES;
}

- (void)initBlurView {
    self.blurView = [[NvEditBGBlurView alloc] init];
    self.blurView.delegate = self;
    [self.view addSubview:self.blurView];
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        if (NV_STATUSBARHEIGHT > 20) {
            make.height.mas_equalTo(130.0 + INDICATOR + 20);
        }else{
            make.height.mas_equalTo(130.0);
        }
    }];
}

- (void)configBlurView {
    ///模糊支持最大值目前为128
    ///The maximum value of fuzzy support is currently 128
    self.blurArr = [NSMutableArray array];
    NvEditBGBlurModel *item = [NvEditBGBlurModel new];
    item.name = @"";
    item.imageName = @"NvBlurNone";
    item.radius = 0;
    [self.blurArr addObject:item];
    NvEditBGBlurModel *item1 = [NvEditBGBlurModel new];
    item1.name = @"Fast Blur";
    item1.imageName = @"NvBlur1";
    item1.radius = 120;
    [self.blurArr addObject:item1];
    NvEditBGBlurModel *item2 = [NvEditBGBlurModel new];
    item2.name = @"Fast Blur";
    item2.imageName = @"NvBlur2";
    item2.radius = 160;
    [self.blurArr addObject:item2];
    NvEditBGBlurModel *item3 = [NvEditBGBlurModel new];
    item3.name = @"Fast Blur";
    item3.imageName = @"NvBlur3";
    item3.radius = 200;
    [self.blurArr addObject:item3];
    NvEditBGBlurModel *item4 = [NvEditBGBlurModel new];
    item4.name = @"Fast Blur";
    item4.imageName = @"NvBlur4";
    item4.radius = 240;
    [self.blurArr addObject:item4];
    [self.blurView configData:self.blurArr];
    self.blurView.hidden = YES;
}

#pragma mark - 获取attachment Obtain attachment
- (NvPropertyBackgroundEffectModel *)getInitialPropertyAttachmentModel:(NvsVideoClip *)clip {
    NvPropertyBackgroundEffectModel *effectModel = [self getPropertyAttachmentModel:clip];
    effectModel.colorR = 0;
    effectModel.colorG = 0;
    effectModel.colorB = 0;
    effectModel.colorA = 0;
    effectModel.imageFile = @"";
    effectModel.radius = 0;
    return effectModel;
}

- (NvPropertyBackgroundEffectModel *)getPropertyAttachmentModel:(NvsVideoClip *)clip {
    NvPropertyBackgroundEffectModel *model = (NvPropertyBackgroundEffectModel *)[clip getAttachment:CLIP_PROPERTY_BACKGROUND_ATTACHMENT];
    if (!model) {
        model = [NvPropertyBackgroundEffectModel new];
    }
    return model;
}

- (NvEditDataModel *)currentEditDataModel {
    NvTimelineData *timelineData = [NvTimelineData sharedInstance];
    NvEditDataModel *editModel = timelineData.editDataArray[self.currentClipIndex];
    return editModel;
}

#pragma mark - 保存数据 Save data
- (void)saveTimelineData {
    NSArray *clipDataArr = [NvTimelineData sharedInstance].editDataArray;
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    for (int i=0; i<clipDataArr.count; i++) {
        NvEditDataModel *model = clipDataArr[i];
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NvPropertyBackgroundEffectModel *effectModel = (NvPropertyBackgroundEffectModel *)[clip getAttachment:CLIP_PROPERTY_BACKGROUND_ATTACHMENT];
        model.backgroundEffectModel = effectModel;
    }
}

#pragma mark - 应用全部片段 Apply all fragments
- (void)applyEffectOnAllClip:(NvBackgroundFxCategory)targetCategory {
    NvsVideoClip *currentClip = [NvTimelineUtils getCurrentClip:self.streamingContext timeline:self.timeline];
    NvPropertyBackgroundEffectModel *effectModel = (NvPropertyBackgroundEffectModel *)[currentClip getAttachment:CLIP_PROPERTY_BACKGROUND_ATTACHMENT];
    if (!effectModel || effectModel.backgroundCategory != targetCategory) {
        effectModel = [NvPropertyBackgroundEffectModel new];
    }
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    for (int i=0; i<track.clipCount; i++) {
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NvPropertyBackgroundEffectModel *itemModel = (NvPropertyBackgroundEffectModel *)[clip getAttachment:CLIP_PROPERTY_BACKGROUND_ATTACHMENT];
        itemModel.isUseBackgroudEffect = effectModel.isUseBackgroudEffect;
        if (!itemModel) {
            itemModel = [NvPropertyBackgroundEffectModel new];
        }
        itemModel.backgroundCategory = targetCategory;
        if (targetCategory == NvBackgroundFxColor) {
            itemModel.colorR = effectModel.colorR;
            itemModel.colorG = effectModel.colorG;
            itemModel.colorB = effectModel.colorB;
            itemModel.colorA = effectModel.colorA;
            itemModel.radius = 0;
            [NvTimelineUtils resetPropertyBackgroundEffect:clip model:itemModel];

        }else if (targetCategory == NvBackgroundFxStyle) {
            itemModel.colorR = 0;
            itemModel.colorG = 0;
            itemModel.colorB = 0;
            itemModel.colorA = 0;
            itemModel.radius = 0;
            itemModel.imageFile = effectModel.imageFile;
            [NvTimelineUtils resetPropertyBackgroundEffect:clip model:itemModel];
            
        }else if (targetCategory == NvBackgroundFxBlur) {
            itemModel.colorR = 0;
            itemModel.colorG = 0;
            itemModel.colorB = 0;
            itemModel.colorA = 0;
            itemModel.imageFile = @"";
            itemModel.radius = effectModel.radius;
            [NvTimelineUtils resetPropertyBackgroundEffect:clip model:itemModel];
        }

    }
    [self seekTimeline];
}



#pragma mark - UICollectionView Delegate

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NvBackgroundAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvEditBackgroundCellID" forIndexPath:indexPath];
    cell.model = self.editDataArray[indexPath.item];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.editDataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.isSelectedClip = YES;
    self.currentClipIndex = (unsigned int)indexPath.item;
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    NvsVideoClip *clip = [videoTrack getClipWithIndex:self.currentClipIndex];
    self.currentClip = clip;
    self.currentAsset = self.editDataArray[indexPath.item];
    
    for (int i = 0; i<self.editDataArray.count; i++) {
        NvEditDataModel *asset = self.editDataArray[i];
        if (i == indexPath.item) {
            asset.backgroundEffectModel.isSelected = YES;
        }else{
            asset.backgroundEffectModel.isSelected = NO;
        }
    }
    [collectionView reloadData];
    
    for (NvEditBGColorModel *colorModel in self.colorArr) {
        colorModel.isSelect = NO;
    }
    [self.colorView configData:self.colorArr];
    
    uint64_t start, end;
    start = clip.inPoint;
    end = clip.outPoint;
    [self.liveWindowPanel playBackStart:start end:end];
    [collectionView layoutIfNeeded];
    self.currentCell = (NvBackgroundAssetCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark - NvLiveWindowPanelViewDelegate
- (void)playback {
    if (!self.isSelectedClip) {
        return;
    }
    for (int i=0; i<self.editDataArray.count; i++) {
        NvEditDataModel *model = self.editDataArray[i];
        if (model.backgroundEffectModel.isSelected) {
            if (!self.currentClip) {
                self.currentClipIndex = i;
                NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
                self.currentClip = [videoTrack getClipWithIndex:self.currentClipIndex];
            }
            uint64_t start, end;
            start = self.currentClip.inPoint;
            end = self.currentClip.outPoint;
            [self.streamingContext stop];
            [self.liveWindowPanel playBackStart:start end:end];
            break;
        }
    }
}

#pragma mark - NvEditBGBottomViewDelegate
- (void)nvEditBGBottomView:(NvEditBGBottomView *)editBGView applyButtonClicked:(UIButton *)button {
    [self saveTimelineData];
    [self.streamingContext removeTimeline:self.timeline];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nvEditBGBottomView:(NvEditBGBottomView *)editBGView canvasCategory:(NvEditCanvasCategory)canvasCategory {
    if(!self.isSelectedClip){
        [NvToast showInfoWithMessage:NvLocalString(@"Please select a video clip to add background first", @"请先选择添加背景的视频片段")];
        return;
    }
    self.bottomView.hidden = YES;
    NvsVideoClip *clip = [NvTimelineUtils getCurrentClip:self.streamingContext timeline:self.timeline];
    NvPropertyBackgroundEffectModel *model = (NvPropertyBackgroundEffectModel *)[clip getAttachment:CLIP_PROPERTY_BACKGROUND_ATTACHMENT];
    if (!model) {
        model = [NvPropertyBackgroundEffectModel new];
    }
    switch (canvasCategory) {
        case NvEditCanvasCategoryColor:
        {
            self.colorView.hidden = NO;
        }
            break;
        
        case NvEditCanvasCategoryBlur:{
            self.blurView.hidden = NO;
        }
            break;
        case NvEditCanvasCategoryStyle:{
            self.styleView.hidden = NO;
        }
        default:{
            
        }
            break;
    }
}

#pragma mark - NvEditBGColorViewDelegate
- (void)nvEditBGColorView:(NvEditBGColorView *)colorView applyButtonClicked:(UIButton *)button {
    for (NvEditBGColorModel *colorModel in self.colorArr) {
        colorModel.isSelect = NO;
    }
    [self.colorView configData:self.colorArr];
    self.bottomView.hidden = NO;
    self.colorView.hidden = YES;
}

- (void)nvEditBGColorView:(NvEditBGColorView *)colorView selectModel:(NvEditBGColorModel *)model {
    NvsVideoClip *clip = [NvTimelineUtils getCurrentClip:self.streamingContext timeline:self.timeline];
    
    NvPropertyBackgroundEffectModel *effectModel = [self getInitialPropertyAttachmentModel:clip];
    effectModel.colorR = model.r;
    effectModel.colorG = model.g;
    effectModel.colorB = model.b;
    effectModel.colorA = 1;
    effectModel.imageFile = model.colorImgPath;
    effectModel.backgroundCategory = NvBackgroundFxColor;
    effectModel.isUseBackgroudEffect = true;
    effectModel.isUsePropertyEffect = YES;
    [NvTimelineUtils resetPropertyBackgroundEffect:clip model:effectModel];
    [self seekTimeline];
    
    for (NvEditBGColorModel *colorModel in self.colorArr) {
        colorModel.isSelect = NO;
    }
    model.isSelect = YES;
    [self.colorView configData:self.colorArr];
    NvPropertyBackgroundEffectModel *backgroundModel = (NvPropertyBackgroundEffectModel *)[clip getAttachment:CLIP_PROPERTY_BACKGROUND_ATTACHMENT];
    backgroundModel.backgroundCategory = NvBackgroundFxColor;
}

- (void)nvEditBGColorViewApplyAll:(NvEditBGColorView *)colorView {
    NvBackgroundFxCategory targetCategory = NvBackgroundFxColor;
    [self applyEffectOnAllClip:targetCategory];
}

#pragma mark - NvEditBGStyleViewDelegate
- (void)nvEditBGStyleView:(NvEditBGColorView *)styleView applyButtonClicked:(UIButton *)button {
    for (NvEditBGStyleModel *model in self.styleArr) {
        model.isSelected = NO;
    }
    [self.styleView configData:self.styleArr];
    self.bottomView.hidden = NO;
    self.styleView.hidden = YES;
}

- (void)nvEditBGStyleView:(NvEditBGStyleView *)styleView selectModel:(NvEditBGStyleModel *)model {
    if ([model.cover isEqualToString:@"Nv_edit_bg_style_add"]) {
        NvAlbumViewController *vc = [NvAlbumViewController new];
        vc.delegate = self;
        vc.mutableSelect = YES;
        vc.minSelectCount = 1;
        vc.maxSelectCount = 1;
        vc.hiddenSelectAll = YES;
        vc.alwaysShowCustomBottom = NO;
        vc.isOnlyImage = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        NvsVideoClip *clip = [NvTimelineUtils getCurrentClip:self.streamingContext timeline:self.timeline];
        NvPropertyBackgroundEffectModel *effectModel = [self getInitialPropertyAttachmentModel:clip];
        effectModel.imageFile = model.packagePath;
        effectModel.isUseBackgroudEffect = false;
        effectModel.backgroundCategory = NvBackgroundFxStyle;
        effectModel.isUsePropertyEffect = YES;
        [NvTimelineUtils resetPropertyBackgroundEffect:clip model:effectModel];
        [self seekTimeline];
        
        for (NvEditBGStyleModel *styleModel in self.styleArr) {
            styleModel.isSelected = NO;
        }
        model.isSelected = YES;
        [self.styleView configData:self.styleArr];
        NvPropertyBackgroundEffectModel *backgroundModel = (NvPropertyBackgroundEffectModel *)[clip getAttachment:CLIP_PROPERTY_BACKGROUND_ATTACHMENT];
        backgroundModel.backgroundCategory = NvBackgroundFxStyle;
    }
}

- (void)nvEditBGStyleViewApplyAll:(NvEditBGStyleView *)styleView {
    NvBackgroundFxCategory targetCategory = NvBackgroundFxStyle;
    [self applyEffectOnAllClip:targetCategory];
}

#pragma mark - NvEditBGBlurViewDelegate
- (void)nvEditBGBlurView:(NvEditBGBlurView *)blurView applyButtonClicked:(UIButton *)button {
    for(NvEditBGBlurModel *blurModel in self.blurArr) {
        blurModel.isSelected = NO;
    }
    [self.blurView configData:self.blurArr];
    self.bottomView.hidden = NO;
    self.blurView.hidden = YES;
}

- (void)nvEditBGBlurView:(NvEditBGBlurView *)blurView selectModel:(NvEditBGBlurModel *)model {
    NvsVideoClip *clip = [NvTimelineUtils getCurrentClip:self.streamingContext timeline:self.timeline];
    NvPropertyBackgroundEffectModel *effectModel = [self getInitialPropertyAttachmentModel:clip];
    effectModel.radius = model.radius;
    effectModel.imageFile = @"";
    effectModel.backgroundCategory = NvBackgroundFxBlur;
    effectModel.isUseBackgroudEffect = true;
    effectModel.backgroundCategory = NvBackgroundFxBlur;
    effectModel.isUsePropertyEffect = YES;
    [NvTimelineUtils resetPropertyBackgroundEffect:clip model:effectModel];

    [self seekTimeline];
    
    for(NvEditBGBlurModel *blurModel in self.blurArr) {
        blurModel.isSelected = NO;
    }
    model.isSelected = YES;
    [self.blurView configData:self.blurArr];
    NvPropertyBackgroundEffectModel *backgroundModel = (NvPropertyBackgroundEffectModel *)[clip getAttachment:CLIP_PROPERTY_BACKGROUND_ATTACHMENT];
    backgroundModel.backgroundCategory = NvBackgroundFxBlur;
}

- (void)nvEditBGBlurViewApplyAll:(NvEditBGBlurView *)blurView {
    NvBackgroundFxCategory targetCategory = NvBackgroundFxBlur;
    [self applyEffectOnAllClip:targetCategory];
}
#pragma mark - NvLineRectViewDelegate
///某个点是否包含贴纸或字幕
///Whether a point contains stickers or subtitles
- (BOOL)containObjectForPoint:(CGPoint)point {
    return true;
}

///手指按住的两个点是否是一个字幕或贴纸对象
///Whether a point contains stickers or subtitles
- (BOOL)containSameObjectForPoint:(CGPoint)point otherPoint:(CGPoint)otherPoint {
    return true;
}

///手势缩放
///Gesture zoom
- (void)gestureRectViewPinchScale:(float)scale {
    NvsVideoClip *clip = [NvTimelineUtils getCurrentClip:self.streamingContext timeline:self.timeline];
    NvPropertyBackgroundEffectModel *model = [self getPropertyAttachmentModel:clip];
    
    float scaleValue = model.scaleX;
    float finalValue= scaleValue * scale;
    model.scaleX = finalValue;
    model.scaleY = finalValue;
    model.isUseBackgroudEffect = true;
    [NvTimelineUtils resetPropertyTransformEffect:clip backgroundModel:model];
    [self seekTimeline];
    
}

///手势旋转
///Gesture rotation
- (void)gestureRectViewRotation:(float)rotation {
    NvsVideoClip *clip = [NvTimelineUtils getCurrentClip:self.streamingContext timeline:self.timeline];
    NvPropertyBackgroundEffectModel *model = [self getPropertyAttachmentModel:clip];
    
    float rotate = model.rotation;
    float r= rotation + rotate;

    double c = [NvUtils truncatingRemainder:r remainder:180.0];
    double d = [NvUtils truncatingRemainder:r remainder:90.0];
    if (self.inSensitiveRRange) {
        self.totalRotation += rotation;
        if (fabsf(self.totalRotation) > 10) {
            self.inSensitiveRRange = NO;
            r += self.totalRotation;
        }else{
            return;
        }
    }else{
        if (c < 10.0 || c > 170) {
            self.totalRotation = 0;
            self.inSensitiveRRange = YES;
            if (c < 10.0) {
                r -= c;
            }else if (c > 170) {
                r += 180 - c;
            }
        }else if (d < 10.0 || d > 80) {
            self.totalRotation = 0;
            self.inSensitiveRRange = YES;
            if (d < 10.0) {
                r -= d;
            }else if (d > 80) {
                r += 90 - d;
            }
        }
    }
    model.rotation = r;
    model.isUseBackgroudEffect = true;
    [NvTimelineUtils resetPropertyTransformEffect:clip backgroundModel:model];
    if (self.inSensitiveRRange) {
        [NvUtils impactFeedback];
    }
    [self seekTimeline];
}

///手势平移
///Gesture translation
- (void)lineRectView:(NvLineRectView *)lineRectView currentPoint:(CGPoint)currentPoint previousPoint:(CGPoint)previousPoint {
    NvsVideoClip *clip = [NvTimelineUtils getCurrentClip:self.streamingContext timeline:self.timeline];
    NvPropertyBackgroundEffectModel *model = [self getPropertyAttachmentModel:clip];
    model.isUsePropertyEffect = YES;
    CGPoint p1 = [self.liveWindowPanel.liveWindow mapViewToCanonical:currentPoint];
    CGPoint p2 = [self.liveWindowPanel.liveWindow mapViewToCanonical:previousPoint];
    float transX = model.transformX + (p1.x-p2.x);
    float transY = model.transformY + (p1.y-p2.y);
    model.transformX = transX;
    model.transformY = transY;
    model.isUseBackgroudEffect = true;
    [NvTimelineUtils resetPropertyTransformEffect:clip backgroundModel:model];
    [self seekTimeline];
}

#pragma mark 相册回调 Album callback
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    NSString *backgroundPath = [NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_BACKGROUNDSTYLE];
    if (![[NSFileManager defaultManager] fileExistsAtPath:backgroundPath isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:backgroundPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    if (assets.count == 1) {
        NvAlbumAsset *asset = assets[0];
        [self copyImageMaterialWithLocalIdentifier:asset.asset.localIdentifier destinationPath:backgroundPath];
    }
    __weak typeof(self)weakSelf = self;
    dispatch_group_notify(self->_group, dispatch_get_main_queue(), ^{
        [weakSelf.styleView configData:weakSelf.styleArr];
        for (NvEditBGStyleModel *styleModel in weakSelf.styleArr) {
            if (styleModel.isSelected) {
                [self nvEditBGStyleView:self.styleView selectModel:styleModel];
                break;
            }
        }
        NvEditBackgroundViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
        [self.navigationController popToViewController:vc animated:YES];
    });
    
}

/// 拷贝图片到指定目录
/// Copy the image to the specified directory
- (void)copyImageMaterialWithLocalIdentifier:(NSString *)localIdentifier destinationPath:(NSString *)destinationPath {
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
    if (result.count>0) {
        if (!self->_group) {
            self->_group = dispatch_group_create();
        }
        __weak typeof(self)weakSelf = self;
        __strong typeof(self) strongSelf = weakSelf;
        dispatch_group_enter(self->_group);
        PHAsset *targetAsset = result.firstObject;
        [[PHImageManager defaultManager] requestImageDataForAsset:targetAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            NSString *imagePath =[[destinationPath stringByAppendingPathComponent:[localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"_"]] stringByAppendingPathExtension:@"png"];
            BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
            if (isExist) {
                for (NvEditBGStyleModel *styleModel in weakSelf.styleArr) {
                    if ([styleModel.cover isEqualToString:imagePath]) {
                       styleModel.isSelected = YES;
                    }else{
                       styleModel.isSelected = NO;
                    }
                    
                }
            }else{
                BOOL result = [imageData writeToFile:imagePath atomically:YES];
                if (result) {
                    for (NvEditBGStyleModel *styleModel in weakSelf.styleArr) {
                        styleModel.isSelected = NO;
                    }
                    NvEditBGStyleModel *newModel = [NvEditBGStyleModel new];
                    newModel.cover = imagePath;
                    newModel.packagePath = imagePath;
                    newModel.isSelected = YES;
                    [weakSelf.styleArr insertObject:newModel atIndex:2];
                }else{
                    NSLog(@"保存图片失败 Failed to save picture%@",localIdentifier);
                }
            }
            
            dispatch_group_leave(strongSelf->_group);
        }];
    }
}

///点击空白处方法
///Click the blank space method
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(self.bottomView.hidden){
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    CGFloat startY = self.collectionView.frame.origin.y + self.collectionView.frame.size.height;
    CGFloat endY = self.bottomView.frame.origin.y;
    if (startY < point.y && point.y < endY) {
        self.isSelectedClip = NO;
        [self.editDataArray enumerateObjectsUsingBlock:^(NvEditDataModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.backgroundEffectModel.isSelected = NO;
        }];
        [self.collectionView reloadData];
        [self.liveWindowPanel playBackStart:[self.streamingContext getTimelineCurrentPosition:self.timeline] end:self.timeline.duration];
    }
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

@end
