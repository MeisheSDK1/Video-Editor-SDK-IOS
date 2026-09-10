//
//  NvEditAnimationController.m
//  SDKDemo
//
//  Created by ms on 2020/8/24.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvEditAnimationController.h"
#import "NvTimelineUtils.h"
#import "NvAnimationAssetCell.h"
#import "NvAnimationBottomView.h"
#import <NvSDKCommon/NvAssetManager.h>
#import <NvSDKCommon/NvAsset.h>
#import "NvTimelineData.h"
#import "NvTimelineUtils.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvSelectedAnimationModel.h"
#import "NvSelectedAnimationView.h"
#import "NvMoreFilterViewController.h"
#import "NvsVideoClip.h"
#import "NvStreamingSdkCore.h"
@interface NvEditAnimationController ()<NvLiveWindowPanelViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NvAssetManagerDelegate>
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NvAnimationBottomView *bottomView;
@property (nonatomic, strong) NvSelectedAnimationView *selectView;
@property (nonatomic, strong) NvAssetManager *assetManager;
@property (nonatomic, strong) NSMutableArray *inAnimationDataSource;
@property (nonatomic, strong) NSMutableArray *outAnimationDataSource;
@property (nonatomic, strong) NSMutableArray *combineAnimationDataSource;
@property (nonatomic, assign) unsigned int currentClipIndex;
@property (nonatomic, assign) NVAnimationType currentType;
@property (nonatomic, strong) NvEditDataModel *currentAsset;
@property (nonatomic, strong) NvSelectedAnimationModel *currentAnimationModel;
@property (nonatomic, strong) NvAnimationInfoModel *currentApplyAnimationModel;
@property (nonatomic, strong) NvsVideoClip *currentClip;
@property (nonatomic, strong) NvsVideoTrack *currentTrack;
@property (nonatomic, strong) NSMutableArray *animationDataArray;
@property (nonatomic, assign) CGFloat currentValue;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) NvAnimationAssetCell *currentCell;
@property (nonatomic, assign) BOOL isSelectedClip;
/// 动画结束的时码线位置
/// The code line position at the end of the animation
@property (nonatomic, assign) int64_t animationEndPos;
@end

static NSString *const NvAnimationAssetCellID = @"NvAnimationAssetCell";
@implementation NvEditAnimationController{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NvLocalString(@"Animation", @"动画");
    [self initTimeline];
    
    self.liveWindowPanel.isAnimationPlayback = NO;
    self.liveWindowPanel.delegate = self;
    self.liveWindowPanel.dontNeedSeekCtl = YES;
    [self initData];
    [self initSubviews];
    
    [self.liveWindowPanel hiddenVolumeButton];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    
    [self clipLiveWindow];
}


/**
 解决liveWindow白线问题
 Solve the white line problem of livewindow
 */
-(void)clipLiveWindow{
    CGFloat scale = [UIScreen mainScreen].scale;
      if(scale == 3.0){
        CGRect rect = self.liveWindowPanel.liveWindow.bounds;
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
        layer.frame = rect;
        self.liveWindowPanel.liveWindow.layer.mask = layer;
    }
}

/**
 初始化素材数据
 Initialize material data
 */
-(void)initData{
    
    for (NvEditDataModel *asset in self.editDataArray) {
        asset.animationInfoModel.isSelected = NO;
    }
    _currentValue = 0;
    self.currentClipIndex = 0;
    self.isSelectedClip = NO;
    self.currentType = NVAnimationTypeIn;
    self.currentAsset = self.editDataArray[self.currentClipIndex];
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    NvsVideoClip *clip = [videoTrack getClipWithIndex:self.currentClipIndex];
    self.currentClip = clip;
    self.currentTrack = videoTrack;
    self.inAnimationDataSource = [NSMutableArray array];
    self.outAnimationDataSource = [NSMutableArray array];
    self.combineAnimationDataSource = [NSMutableArray array];
    self.animationDataArray = [NSMutableArray array];
    self.currentAnimationModel = [[NvSelectedAnimationModel alloc] init];
    self.streamingContext = [NvSDKUtils getSDKContext];
    
    self.assetManager = [NvAssetManager sharedInstance];
    self.assetManager.delegate = self;
    
    NvSelectedAnimationModel *item1 = [NvSelectedAnimationModel new];
    item1.imageUrl = @"NvsFilterNone";
    item1.name = NvLocalString(@"None", @"无");
    item1.isSelect = YES;
    NvSelectedAnimationModel *item2 = [NvSelectedAnimationModel new];
    item2.imageUrl = @"NvsFilterNone";
    item2.name = NvLocalString(@"None", @"无");
    item2.isSelect = YES;
    NvSelectedAnimationModel *item3 = [NvSelectedAnimationModel new];
    item3.imageUrl = @"NvsFilterNone";
    item3.name = NvLocalString(@"None", @"无");
    item3.isSelect = YES;
    [self.inAnimationDataSource addObject:item1];
    [self.outAnimationDataSource addObject:item2];
    [self.combineAnimationDataSource addObject:item3];
    
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"animation" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_ANIMATION_IN bundlePath:itemPath categoryId:INANIMATIONCATEGORYID];
    NSString *itemPathOut = [[NSBundle mainBundle] pathForResource:@"animationOut" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_ANIMATION_OUT bundlePath:itemPathOut categoryId:OUTANIMATIONCATEGORYID];
    NSString *itemPathCombine = [[NSBundle mainBundle] pathForResource:@"animationCombine" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_ANIMATION_COMBINE bundlePath:itemPathCombine categoryId:COMBINEANIMATIONCATEGORYID];
    [self.assetManager searchLocalAssets:ASSET_ANIMATION_IN categoryId:INANIMATIONCATEGORYID];
    [self.assetManager searchLocalAssets:ASSET_ANIMATION_OUT categoryId:OUTANIMATIONCATEGORYID];
    [self.assetManager searchLocalAssets:ASSET_ANIMATION_COMBINE categoryId:COMBINEANIMATIONCATEGORYID];

    for (int i = 0; i < self.editDataArray.count; i ++) {
        NvEditDataModel *ass = self.editDataArray[i];
        NvAnimationInfoModel *newInfo = [NvAnimationInfoModel new];
        newInfo.index = i;
        newInfo.asset = ass.asset;
        newInfo.thumImage = ass.thumImage;
        NvEditDataModel *editData = self.editDataArray[i];
        NvAnimationInfoModel *model = editData.animationInfoModel;
        if (model && model.asset) {
            newInfo.name = model.name;
            newInfo.packageId = model.packageId;
            newInfo.animationStart = model.animationStart;
            newInfo.animationEnd = model.animationEnd;
            newInfo.animationValue = model.animationValue;
            newInfo.asset = model.asset;
            newInfo.isUsePropertyEffect = model.isUsePropertyEffect;
            newInfo.isPostPackage = model.isPostPackage;
            newInfo.isPostPackage2 = model.isPostPackage2;
            newInfo.packageId2 = model.packageId2;
            newInfo.animationStart2 = model.animationStart2;
            newInfo.animationEnd2 = model.animationEnd2;
            newInfo.animationCategory = model.animationCategory;
        }
        [self.animationDataArray addObject:newInfo];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.assetManager setAssetInfoToUserDefaults:ASSET_ANIMATION_IN];
    [self connectLiveWindow];
    [self getDefaultDataWithID:NVAnimationTypeIn];
    [self getDefaultDataWithID:NVAnimationTypeOut];
    [self getDefaultDataWithID:NVAnimationTypeCombine];
    if (self.currentType == NVAnimationTypeIn) {
        self.selectView.animationDataSource = self.inAnimationDataSource;
    }else if (self.currentType == NVAnimationTypeOut){
        self.selectView.animationDataSource = self.outAnimationDataSource;
    }else if (self.currentType == NVAnimationTypeCombine){
        self.selectView.animationDataSource = self.combineAnimationDataSource;
    }
}

/**
 连接liveWindow
 Connect to livewindow
 */
- (void)connectLiveWindow {
    [self.liveWindowPanel connectTimeline:self.timeline];
    [self seekTimeline:self.liveWindowPanel.currentTime];
}


/**
 定位某一时间戳的图像
 Locate the image of a timestamp
 */
- (void)seekTimeline:(int64_t)postion {
    if (![[NvSDKUtils getSDKContext] seekTimeline:self.timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame])
        NSLog(@"定位时间线失败！Failed to seek timeline!");
}


/**
 获取默认数据
 Get default data
 */
- (void)getDefaultDataWithID:(NVAnimationType)animationType {
    AssetType type = ASSET_ANIMATION_IN;
    int categoryId = INANIMATIONCATEGORYID;
    int kindId;
    if (animationType == NVAnimationTypeIn) {
        type = ASSET_ANIMATION_IN;
        categoryId = 3;
        kindId = 1;
    }else if (animationType == NVAnimationTypeOut){
        type = ASSET_ANIMATION_OUT;
        categoryId = 3;
        kindId = 2;
    }else if (animationType == NVAnimationTypeCombine){
        type = ASSET_ANIMATION_COMBINE;
        categoryId = 3;
        kindId = 3;
    }
    
    NSArray *array = [self.assetManager getUsableAssets:type aspectRatio:AspectRatio_All categoryId:0 kindId:0];
    for (NvAsset *asset in array) {
        if (animationType == NVAnimationTypeIn) {
            if ([self isInAnimationExist:asset.uuid]){
                continue;
            }
        }else if (animationType == NVAnimationTypeOut){
            if ([self isOutAnimationExist:asset.uuid]){
                continue;
            }
        }else if (animationType == NVAnimationTypeCombine){
            if ([self isCombineAnimationExist:asset.uuid]){
                continue;
            }
        }
        
        if ([asset isReserved]) {
            NvSelectedAnimationModel *item = [NvSelectedAnimationModel new];
            item.imageUrl = asset.coverUrl;
            [self initReservedAssetName:asset];
            if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
                item.name = asset.displayNamezhCN;
                    }else{
                        item.name = asset.displayName;
                    }
            item.packageId = asset.uuid;
            item.isPostPackage = asset.isPostPackage;
            item.isAdjusted = asset.isAdjusted;
            if (animationType == NVAnimationTypeIn) {
                [self.inAnimationDataSource insertObject:item atIndex:1];
            }else if (animationType == NVAnimationTypeOut){
                [self.outAnimationDataSource insertObject:item atIndex:1];
            }else if (animationType == NVAnimationTypeCombine){
                [self.combineAnimationDataSource insertObject:item atIndex:1];
            }
        }
    }
    for (NvAsset *asset in array) {
        if (animationType == NVAnimationTypeIn) {
            if ([self isInAnimationExist:asset.uuid]){
                continue;
            }
        }else if (animationType == NVAnimationTypeOut){
            if ([self isOutAnimationExist:asset.uuid]){
                continue;
            }
        }else if (animationType == NVAnimationTypeCombine){
            if ([self isCombineAnimationExist:asset.uuid]){
                continue;
            }
        }
        if (![asset isReserved]) {
            NvSelectedAnimationModel *item = [NvSelectedAnimationModel new];
            item.imageUrl = asset.coverUrl;
            [self initReservedAssetName:asset];
            if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
                item.name = asset.displayNamezhCN;
                    }else{
                        item.name = asset.displayName;
                    }
            item.packageId = asset.uuid;
            item.isAdjusted = asset.isAdjusted;
            if (animationType == NVAnimationTypeIn) {
                [self.inAnimationDataSource insertObject:item atIndex:1];
            }else if (animationType == NVAnimationTypeOut){
                [self.outAnimationDataSource insertObject:item atIndex:1];
            }else if (animationType == NVAnimationTypeCombine){
                [self.combineAnimationDataSource insertObject:item atIndex:1];
            }
        }
    }
    
    NSMutableArray *animas = self.animationDataArray;
    if (animas.count == 0 || self.currentClipIndex >=  self.animationDataArray.count) {
        return;
    }
    NvAnimationInfoModel *model = animas[self.currentClipIndex];
    if ((model.packageId && ![model.packageId isEqualToString:@""]) || (model.packageId2 && ![model.packageId2 isEqualToString:@""])) {
        if (animationType == NVAnimationTypeIn) {
            for (NvSelectedAnimationModel *selectedModel in self.inAnimationDataSource) {
                if ([selectedModel.packageId isEqualToString:model.packageId]) {
                    selectedModel.isSelect = YES;
                    _currentValue = model.animationEnd *1.0 / NV_TIME_BASE;
                    NvSelectedAnimationModel *item = self.inAnimationDataSource[0];
                    item.isSelect = NO;
                }
                
            }
        }else if (animationType == NVAnimationTypeOut){
            for (NvSelectedAnimationModel *selectedModel in self.outAnimationDataSource) {
                if ([selectedModel.packageId isEqualToString:model.packageId2]) {
                    selectedModel.isSelect = YES;
                    _currentValue = model.animationEnd *1.0/ NV_TIME_BASE - model.animationStart *1.0 / NV_TIME_BASE;
                    NvSelectedAnimationModel *item = self.outAnimationDataSource[0];
                    item.isSelect = NO;
                }
            }
        }else if (animationType == NVAnimationTypeCombine){
            for (NvSelectedAnimationModel *selectedModel in self.combineAnimationDataSource) {
                if ([selectedModel.packageId isEqualToString:model.packageId]) {
                    selectedModel.isSelect = YES;
                    _currentValue = model.animationEnd *1.0 / NV_TIME_BASE;
                    NvSelectedAnimationModel *item = self.combineAnimationDataSource[0];
                    item.isSelect = NO;
                }
            }
        }
    }
    if (_currentValue != 0) {
        self.selectView.slider.minValue = 0.1;
        self.selectView.slider.maxValue = (self.currentClip.outPoint - self.currentClip.inPoint) * 1.0 / NV_TIME_BASE;
        self.selectView.slider.value = _currentValue;
    }
}

#pragma mark 查找数组中是否存在该数据，选择性添加到数组中
/**
 查找是否存在某个素材
 Find out if a material exists

 @param uuid 素材id
 material id
 */
- (BOOL)isInAnimationExist:(NSString *)uuid {
    for (NvSelectedAnimationModel *item in self.inAnimationDataSource) {
        if ([item.packageId isEqualToString:uuid])
            return YES;
    }
    return NO;
}
- (BOOL)isOutAnimationExist:(NSString *)uuid {
    for (NvSelectedAnimationModel *item in self.outAnimationDataSource) {
        if ([item.packageId isEqualToString:uuid])
            return YES;
    }
    return NO;
}
- (BOOL)isCombineAnimationExist:(NSString *)uuid {
    for (NvSelectedAnimationModel *item in self.combineAnimationDataSource) {
        if ([item.packageId isEqualToString:uuid])
            return YES;
    }
    return NO;
}

/**
 配置素材信息
 Configure material information

 @param asset 素材模型
 material information
 */
- (void)initReservedAssetName:(NvAsset *)asset {
    if ([asset isReserved]) {
        if ([asset.uuid isEqualToString:@"9A0A2A81-A897-4253-B176-9FA04E5C0405"]) {
            asset.displayName = NvLocalString(@"Zoom1", @"动感缩小");
        }
        if ([asset.uuid isEqualToString:@"37154A36-8816-492B-B1F5-F8122660C686"]) {
            asset.displayName = NvLocalString(@"Slide left", @"向左滑动");
        }
        if ([asset.uuid isEqualToString:@"8316FA69-7A8B-4AB8-BC70-A6CFB51277FE"]) {
            asset.displayName = NvLocalString(@"Spin-fall", @"旋转降落");
        }
        if ([asset.uuid isEqualToString:@"042861FA-5408-443B-9F75-459216A8624F"]) {
            asset.displayName = NvLocalString(@"Puzzle2", @"碎块滑动");
        }
        if ([asset.uuid isEqualToString:@"5DE5DF47-2A85-418D-BCDE-073918CFDD0C"]) {
            asset.displayName = NvLocalString(@"Zoom In", @"缩小");
        }
        if ([asset.uuid isEqualToString:@"497F0F77-34B2-4872-9B7F-6C0EA543D946"]) {
            asset.displayName = NvLocalString(@"Zoom Out", @"放大");
        }
    }
}

-(void)initSubviews{
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - NV_STATUSBARHEIGHT - NV_NAV_BAR_HEIGHT) collectionViewLayout:self.flowLayout];
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.bounces = YES;
    [self.collectionView registerClass:[NvAnimationAssetCell class] forCellWithReuseIdentifier:NvAnimationAssetCellID];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0,  0);
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(60.0*SCREENSCALE);
        make.top.mas_equalTo(self.liveWindowPanel.liveWindow.mas_bottom).offset(40*SCREENSCALE);
    }];
    [self.collectionView reloadData];
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        if (NV_STATUSBARHEIGHT > 20) {
            make.height.mas_equalTo(120.0 + INDICATOR + 20);
        }else{
            make.height.mas_equalTo(120.0);
        }
    }];
}


/**
 重新创建timeline和数据结构
 Recreate timeline and data structure
 */
- (void)initTimeline {
    self.timeline = [NvTimelineUtils createTimeline:self.editMode];
    [NvTimelineUtils recreateTimeline:self.timeline];
    NvTimelineData *data = [NvTimelineData sharedInstance];
    
    [NvTimelineUtils resetAnimationFx:self.timeline model:data];
}


#pragma mark - UICollectionView Delegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NvAnimationAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NvAnimationAssetCellID forIndexPath:indexPath];
    cell.model = self.editDataArray[indexPath.item];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.editDataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.isSelectedClip = YES;
    self.currentClipIndex = (unsigned int)indexPath.item;
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    NvsVideoClip *clip = [videoTrack getClipWithIndex:self.currentClipIndex];
    self.currentTrack = videoTrack;
    self.currentClip = clip;
    self.currentAsset = self.editDataArray[indexPath.item];
    _currentValue = 0;
    self.selectView.slider.hidden = YES;
    self.selectView.slider.valueLabel.alpha = 1.0;
    self.selectView.timeLabel.hidden = YES;
    if (self.currentType == NVAnimationTypeIn) {
        for (NvSelectedAnimationModel *selectedModel in self.inAnimationDataSource) {
            selectedModel.isSelect = NO;
        }
    }else if (self.currentType == NVAnimationTypeOut){
        for (NvSelectedAnimationModel *selectedModel in self.outAnimationDataSource) {
            selectedModel.isSelect = NO;
        }
    }else if (self.currentType == NVAnimationTypeCombine){
        for (NvSelectedAnimationModel *selectedModel in self.combineAnimationDataSource) {
            selectedModel.isSelect = NO;
        }
    }
    
    
    for (int i = 0; i<self.editDataArray.count; i++) {
        NvEditDataModel *asset = self.editDataArray[i];
        if (i == indexPath.item) {
            asset.animationInfoModel.isSelected = YES;
        }else{
            asset.animationInfoModel.isSelected  = NO;
        }
    }
    [collectionView reloadData];
    
    if (!self.selectView.hidden) {
        CGFloat duration = (self.currentClip.outPoint - self.currentClip.inPoint) * 1.0 / NV_TIME_BASE;
        CGFloat ratio =  (CGFloat)self.currentValue*1.0 / (CGFloat)(duration*1.0);

        NSMutableArray *animas = self.animationDataArray;
        if (animas.count == 0 || self.currentClipIndex >=  animas.count) {
            return;
        }
        NvAnimationInfoModel *model = animas[self.currentClipIndex];
        if ((model.packageId && ![model.packageId isEqualToString:@""]) || (model.packageId2 && ![model.packageId2 isEqualToString:@""])) {
            if (self.currentType == NVAnimationTypeIn) {
                for (NvSelectedAnimationModel *selectedModel in self.inAnimationDataSource) {
                    
                    if ([selectedModel.packageId isEqualToString:model.packageId]) {
                        selectedModel.isSelect = YES;
                        self.currentValue = model.animationEnd *1.0 / NV_TIME_BASE;
                        self.animationEndPos = model.animationEnd;
                        duration = (self.currentClip.outPoint - self.currentClip.inPoint) * 1.0 / NV_TIME_BASE;
                        ratio =  (CGFloat)self.currentValue*1.0 / (CGFloat)(duration*1.0);
                        self.selectView.slider.hidden = NO;
                        self.selectView.timeLabel.hidden = NO;
                        self.selectView.slider.minValue = 0.1;
                        self.selectView.slider.maxValue = duration;
                        self.selectView.slider.value = self.currentValue;
                        self.currentCell.maskView.frame = CGRectMake(0, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                        self.currentAsset.animationInfoModel.maskRect = CGRectMake(0, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                    }else{
                        selectedModel.isSelect = NO;
                    }
                }
            }else if (self.currentType == NVAnimationTypeOut){
                for (NvSelectedAnimationModel *selectedModel in self.outAnimationDataSource) {
                    if ([selectedModel.packageId isEqualToString:model.packageId2]) {
                        selectedModel.isSelect = YES;
                        self.currentValue = model.animationEnd2 *1.0/ NV_TIME_BASE - model.animationStart2 *1.0 / NV_TIME_BASE;
                        self.animationEndPos = model.animationEnd2;
                        duration = (self.currentClip.outPoint - self.currentClip.inPoint) * 1.0 / NV_TIME_BASE;
                        ratio =  (CGFloat)self.currentValue*1.0 / (CGFloat)(duration*1.0);
                        self.selectView.slider.hidden = NO;
                        self.selectView.slider.minValue = 0.1;
                        self.selectView.slider.maxValue = duration;
                        self.selectView.slider.value = self.currentValue;
                        self.currentCell.maskView.frame = CGRectMake(77.0*SCREENSCALE-77.0*SCREENSCALE*ratio, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                        self.currentAsset.animationInfoModel.maskRect = CGRectMake(0, 0, 77.0*SCREENSCALE-77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                    }else{
                        selectedModel.isSelect = NO;
                    }
                }
            }else if (self.currentType == NVAnimationTypeCombine){
                for (NvSelectedAnimationModel *selectedModel in self.combineAnimationDataSource) {
                    if ([selectedModel.packageId isEqualToString:model.packageId]) {
                        selectedModel.isSelect = YES;
                        self.currentValue = model.animationEnd *1.0/ NV_TIME_BASE;
                        self.animationEndPos = model.animationEnd;
                        duration = (self.currentClip.outPoint - self.currentClip.inPoint) * 1.0 / NV_TIME_BASE;
                        ratio =  (CGFloat)self.currentValue*1.0 / (CGFloat)(duration*1.0);
                        self.selectView.slider.hidden = NO;
                        self.selectView.slider.minValue = 0.1;
                        self.selectView.slider.maxValue = duration;
                        self.selectView.slider.value = self.currentValue;
                        self.currentCell.maskView.frame = CGRectMake(0, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                        self.currentAsset.animationInfoModel.maskRect = CGRectMake(0, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                    }else{
                        selectedModel.isSelect = NO;
                    }
                }
            }
        }
        if (self.currentType == NVAnimationTypeIn) {
            self.selectView.animationDataSource = self.inAnimationDataSource;
        }else if (self.currentType == NVAnimationTypeOut){
            self.selectView.animationDataSource = self.outAnimationDataSource;
        }else if (self.currentType == NVAnimationTypeCombine){
            self.selectView.animationDataSource = self.combineAnimationDataSource;
        }
    }

    uint64_t start, end;
    start = clip.inPoint;
    end = clip.outPoint;
    [self.liveWindowPanel playBackStart:start end:end];
    [collectionView layoutIfNeeded];
    self.currentCell = (NvAnimationAssetCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
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

-(UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc]init];
        _maskView.backgroundColor = [UIColor nv_colorWithHexString:@"#63ABFF" alpha:0.5];
        _maskView.frame = CGRectMake(0, 0, 0, 50.0*SCREENSCALE);
    }
    return _maskView;
}

/**
 动画分类视图
 Animation category view
 */
-(NvAnimationBottomView *)bottomView{
    if (!_bottomView) {
        __weak typeof(self)weakSelf = self;
        _bottomView = [[NvAnimationBottomView alloc] init];
        _bottomView.selectAnimationTypeBlock = ^(NVAnimationType type) {
            
            if (!weakSelf.isSelectedClip) {
                [NvToast showInfoWithMessage:NvLocalString(@"Please select a video clip to add animation first", @"请先选择添加动画的视频片段")];
                return;
            }
            
            weakSelf.currentType = type;
            weakSelf.selectView.hidden = NO;
            weakSelf.selectView.slider.hidden = YES;
            weakSelf.selectView.timeLabel.hidden = YES;
            weakSelf.bottomView.hidden = YES;
            weakSelf.liveWindowPanel.isAnimationPlayback = YES;

            CGFloat duration = (weakSelf.currentClip.outPoint - weakSelf.currentClip.inPoint) * 1.0 / NV_TIME_BASE;
            CGFloat ratio =  (CGFloat)weakSelf.currentValue*1.0 / (CGFloat)(duration*1.0);

            NSMutableArray *animas = weakSelf.animationDataArray;
            if (animas.count == 0 || weakSelf.currentClipIndex >=  animas.count) {
                return;
            }
            NvAnimationInfoModel *model = animas[weakSelf.currentClipIndex];
            if ((model.packageId && ![model.packageId isEqualToString:@""]) || (model.packageId2 && ![model.packageId2 isEqualToString:@""])) {
                if (weakSelf.currentType == NVAnimationTypeIn) {
                    for (NvSelectedAnimationModel *selectedModel in weakSelf.inAnimationDataSource) {
                        
                        if ([selectedModel.packageId isEqualToString:model.packageId]) {
                            selectedModel.isSelect = YES;
                            weakSelf.currentValue = model.animationEnd *1.0 / NV_TIME_BASE;
                            weakSelf.animationEndPos = model.animationEnd;
                            duration = (weakSelf.currentClip.outPoint - weakSelf.currentClip.inPoint) * 1.0 / NV_TIME_BASE;
                            ratio =  (CGFloat)weakSelf.currentValue*1.0 / (CGFloat)(duration*1.0);
                            weakSelf.selectView.slider.hidden = NO;
                            weakSelf.selectView.timeLabel.hidden = NO;
                            weakSelf.selectView.slider.minValue = 0.1;
                            weakSelf.selectView.slider.maxValue = duration;
                            weakSelf.selectView.slider.value = weakSelf.currentValue;
                            weakSelf.currentCell.maskView.frame = CGRectMake(0, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                            weakSelf.currentAsset.animationInfoModel.maskRect = CGRectMake(0, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                        }else{
                            selectedModel.isSelect = NO;
                        }
                    }
                }else if (weakSelf.currentType == NVAnimationTypeOut){
                    for (NvSelectedAnimationModel *selectedModel in weakSelf.outAnimationDataSource) {
                        if ([selectedModel.packageId isEqualToString:model.packageId2]) {
                            selectedModel.isSelect = YES;
                            weakSelf.currentValue = model.animationEnd *1.0/ NV_TIME_BASE - model.animationStart *1.0 / NV_TIME_BASE;
                            weakSelf.animationEndPos = model.animationEnd;
                            duration = (weakSelf.currentClip.outPoint - weakSelf.currentClip.inPoint) * 1.0 / NV_TIME_BASE;
                            ratio =  (CGFloat)weakSelf.currentValue*1.0 / (CGFloat)(duration*1.0);
                            weakSelf.selectView.slider.hidden = NO;
                            weakSelf.selectView.slider.minValue = 0.1;
                            weakSelf.selectView.slider.maxValue = duration;
                            weakSelf.selectView.slider.value = weakSelf.currentValue;
                            weakSelf.currentCell.maskView.frame = CGRectMake(77.0*SCREENSCALE-77.0*SCREENSCALE*ratio, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                            weakSelf.currentAsset.animationInfoModel.maskRect = CGRectMake(77.0*SCREENSCALE-77.0*SCREENSCALE*ratio, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                        }else{
                            selectedModel.isSelect = NO;
                        }
                    }
                }else if (weakSelf.currentType == NVAnimationTypeCombine){
                    for (NvSelectedAnimationModel *selectedModel in weakSelf.combineAnimationDataSource) {
                        if ([selectedModel.packageId isEqualToString:model.packageId]) {
                            selectedModel.isSelect = YES;
                            weakSelf.currentValue = model.animationEnd *1.0/ NV_TIME_BASE;
                            weakSelf.animationEndPos = model.animationEnd;
                            duration = (weakSelf.currentClip.outPoint - weakSelf.currentClip.inPoint) * 1.0 / NV_TIME_BASE;
                            ratio =  (CGFloat)weakSelf.currentValue*1.0 / (CGFloat)(duration*1.0);
                            weakSelf.selectView.slider.hidden = NO;
                            weakSelf.selectView.slider.minValue = 0.1;
                            weakSelf.selectView.slider.maxValue = duration;
                            weakSelf.selectView.slider.value = weakSelf.currentValue;
                            weakSelf.currentCell.maskView.frame = CGRectMake(0, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                            weakSelf.currentAsset.animationInfoModel.maskRect = CGRectMake(0, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                        }else{
                            selectedModel.isSelect = NO;
                        }
                    }
                }
            }
            if (type == NVAnimationTypeIn) {
                weakSelf.selectView.animationDataSource = weakSelf.inAnimationDataSource;
            }else if (type == NVAnimationTypeOut){
                weakSelf.selectView.animationDataSource = weakSelf.outAnimationDataSource;
            }else if (type == NVAnimationTypeCombine){
                weakSelf.selectView.animationDataSource = weakSelf.combineAnimationDataSource;
            }
        };
        _bottomView.okBtnClick = ^{
            
            [weakSelf saveTimelineData];
            [weakSelf.streamingContext removeTimeline:weakSelf.timeline];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
    }
    return _bottomView;
}

- (void)saveTimelineData {
    NSArray *clipDataArr = [NvTimelineData sharedInstance].editDataArray;
    for (int i=0; i<clipDataArr.count; i++) {
        NvEditDataModel *model = clipDataArr[i];
        model.animationInfoModel = self.animationDataArray[i];
    }
}


/**
 具体动画视图
 Concrete animation view
 */
-(NvSelectedAnimationView *)selectView{
    if (!_selectView) {
        __weak typeof(self)weakSelf = self;
        _selectView = [[NvSelectedAnimationView alloc] init];
        [self.view addSubview:_selectView];
        [_selectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            if (NV_STATUSBARHEIGHT > 20) {
                make.height.mas_equalTo(200.0 + INDICATOR + 20);
            }else{
                make.height.mas_equalTo(200.0);
            }
        }];
        _selectView.selectAnimation = ^(NvSelectedAnimationModel * model) {
            
            CGFloat minValue = 0.0, maxValue = 0.0, value = 0.0, begin = 0.0, end = 0.0;
            CGFloat duration = (weakSelf.currentClip.outPoint - weakSelf.currentClip.inPoint) * 1.0 / NV_TIME_BASE;
            
            if ([model.name isEqualToString:NvLocalString(@"None", @"无")]) {
                weakSelf.currentValue = 0.0;
            }
            model.animationType = weakSelf.currentType;
            if (weakSelf.currentType == NVAnimationTypeIn) {
                minValue = 0.1;
                maxValue =  duration;
                if (weakSelf.currentValue < duration && weakSelf.currentValue != 0) {
                    value = weakSelf.currentValue;
                }else{
                    value = 0.5;
                }
                begin = 0;
                end = value;
            }else if (weakSelf.currentType == NVAnimationTypeOut){
                minValue = 0.1;
                maxValue = duration;
                if (weakSelf.currentValue < duration && weakSelf.currentValue != 0) {
                    value = weakSelf.currentValue;
                }else{
                    value = 0.5;
                }
                begin = duration - value;
                end = duration;
            }else if (weakSelf.currentType == NVAnimationTypeCombine){
                minValue = 0.1;
                maxValue = duration;
                if (weakSelf.currentValue < duration && weakSelf.currentValue != 0) {
                    value = weakSelf.currentValue;
                }else{
                    value = duration;
                }
                begin = 0;
                end = value;
            }
            if (maxValue<=minValue) {
                if ([model.imageUrl containsString:@"NvsFilterNone"]==false) {
                    [NvToast showInfoWithMessage:NvLocalString(@"The minimum duration is 0.1 seconds", @"最小时间为0.1秒")];
                }
                
                return;
            }
            weakSelf.selectView.slider.minValue = minValue;
            weakSelf.selectView.slider.maxValue = maxValue;
            
            weakSelf.selectView.slider.value = value;
            
            weakSelf.currentAnimationModel = model;
            weakSelf.currentAnimationModel.begin = begin * NV_TIME_BASE *1.0;
            weakSelf.currentAnimationModel.end = end * NV_TIME_BASE *1.0;
            
            
            [weakSelf resetVideoFx:weakSelf.currentClip];
            if (weakSelf.currentType == NVAnimationTypeIn || weakSelf.currentType == NVAnimationTypeCombine) {
                if ([model.name isEqualToString:NvLocalString(@"None", @"无")]) {
                    [weakSelf.liveWindowPanel playBackStart:weakSelf.currentClip.inPoint end:weakSelf.currentClip.outPoint];
                    weakSelf.animationEndPos = weakSelf.currentClip.outPoint;
                }else {

                    [weakSelf.liveWindowPanel playBackStart:(weakSelf.currentClipIndex == 0? weakSelf.currentClip.inPoint : weakSelf.currentClip.inPoint - 0.5 * NV_TIME_BASE) end:weakSelf.currentClipIndex == 0 ?weakSelf.currentClip.inPoint + value * NV_TIME_BASE *1.0 :  weakSelf.currentClip.inPoint + value * NV_TIME_BASE *1.0 - 0.5 * NV_TIME_BASE];

                    weakSelf.animationEndPos = weakSelf.currentClip.inPoint + value * NV_TIME_BASE *1.0;
                }
            }else if (weakSelf.currentType == NVAnimationTypeOut){
                if ([model.name isEqualToString:NvLocalString(@"None", @"无")]) {
                    [weakSelf.liveWindowPanel playBackStart:weakSelf.currentClip.inPoint end:weakSelf.currentClip.outPoint];
                    weakSelf.animationEndPos = weakSelf.currentClip.outPoint;
                }else {
                    [weakSelf.liveWindowPanel playBackStart:(weakSelf.currentClip.inPoint + ((duration-value-0.5)* NV_TIME_BASE *1.0)) end: weakSelf.currentClip.outPoint];
                    weakSelf.animationEndPos = weakSelf.currentClip.outPoint;
                }
            }
            
            
            NvAnimationInfoModel *an = weakSelf.animationDataArray[weakSelf.currentClipIndex];
            an.name = model.name;
            
            if (weakSelf.currentType == NVAnimationTypeOut) {
                an.packageId2 = model.packageId;
                an.isPostPackage2 = model.isPostPackage;
                an.animationStart2 = begin * NV_TIME_BASE*1.0;
                an.animationEnd2 = end * NV_TIME_BASE*1.0;
                if (weakSelf.currentType == NVAnimationTypeCombine) {
                    an.packageId = @"";
                    an.animationStart = 0;
                    an.animationEnd = 0;
                }
            } else {
                an.packageId = model.packageId;
                an.isPostPackage = model.isPostPackage;
                an.animationStart = begin * NV_TIME_BASE*1.0;
                an.animationEnd = end * NV_TIME_BASE*1.0;
                if (weakSelf.currentType == NVAnimationTypeCombine) {
                    an.packageId2 = @"";
                    an.animationStart2 = 0;
                    an.animationEnd2 = 0;
                }
            }
            an.animationCategory = (NvAnimationCategory)model.animationType;
            CGFloat ratio = value*1.0 / duration;
            if ([model.name isEqualToString:NvLocalString(@"None", @"无")]) {
                an.isUsePropertyEffect = NO;
                weakSelf.currentCell.maskView.frame = CGRectMake(0, 0, 0, 50.0*SCREENSCALE);
                weakSelf.currentAsset.animationInfoModel.maskRect = CGRectMake(0, 0, 0, 50.0*SCREENSCALE);
            }else{
                an.isUsePropertyEffect = YES;
                if (weakSelf.currentType == NVAnimationTypeIn || weakSelf.currentType == NVAnimationTypeCombine) {
                    weakSelf.currentCell.maskView.frame = CGRectMake(0, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                    weakSelf.currentAsset.animationInfoModel.maskRect = CGRectMake(0, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                }else if (weakSelf.currentType == NVAnimationTypeOut){
                    weakSelf.currentCell.maskView.frame = CGRectMake(77.0*SCREENSCALE-77.0*SCREENSCALE*ratio, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                    weakSelf.currentAsset.animationInfoModel.maskRect = CGRectMake(77.0*SCREENSCALE-77.0*SCREENSCALE*ratio, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                }
            }
            
            
            
        };
        _selectView.moreBtnClick = ^{
            NvMoreFilterViewController *vc = [[NvMoreFilterViewController alloc]init];
            vc.editModel = weakSelf.editMode;
            if (weakSelf.currentType == NVAnimationTypeIn) {
                vc.type = ASSET_ANIMATION_IN;
                vc.categoryId = 3;
                vc.kind = 1;
            }else if (weakSelf.currentType == NVAnimationTypeOut){
                vc.type = ASSET_ANIMATION_OUT;
                vc.categoryId = 3;
                vc.kind = 2;
            }else if (weakSelf.currentType == NVAnimationTypeCombine){
                vc.type = ASSET_ANIMATION_COMBINE;
                vc.categoryId = 3
                
                ;
                vc.kind = 3;
            }
            
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
        _selectView.okBtnClick = ^{
            weakSelf.selectView.hidden = YES;
            weakSelf.bottomView.hidden = NO;
            weakSelf.animationEndPos = weakSelf.timeline.duration;
            weakSelf.liveWindowPanel.isAnimationPlayback = NO;
        };
        _selectView.valueChangeBLock = ^(NvSelectedAnimationView * _Nonnull view , CGFloat value) {
            
            CGFloat begin = 0.0 , end = 0.0;
            CGFloat duration = (weakSelf.currentClip.outPoint - weakSelf.currentClip.inPoint) * 1.0 / NV_TIME_BASE;
            if (weakSelf.currentType == NVAnimationTypeIn) {
                begin = 0;
                end = value;
                NvAnimationInfoModel *an = weakSelf.animationDataArray[weakSelf.currentClipIndex];
                an.animationStart = begin * NV_TIME_BASE*1.0;
                an.animationEnd = end * NV_TIME_BASE*1.0;
            }else if (weakSelf.currentType == NVAnimationTypeOut){
                begin = duration - value;
                end = duration ;
                NvAnimationInfoModel *an = weakSelf.animationDataArray[weakSelf.currentClipIndex];
                an.animationStart2 = begin * NV_TIME_BASE*1.0;
                an.animationEnd2 = end * NV_TIME_BASE*1.0;
            }else if (weakSelf.currentType == NVAnimationTypeCombine){
                begin = 0;
                end = value;
                NvAnimationInfoModel *an = weakSelf.animationDataArray[weakSelf.currentClipIndex];
                an.animationStart = begin * NV_TIME_BASE*1.0;
                an.animationEnd = end * NV_TIME_BASE*1.0;
            }
            weakSelf.currentValue = value;
            weakSelf.currentAnimationModel.begin = begin * NV_TIME_BASE*1.0;
            weakSelf.currentAnimationModel.end = end * NV_TIME_BASE*1.0;
            [weakSelf resetVideoFx:weakSelf.currentClip];
            
            CGFloat ratio = value*1.0 / duration;
            if ([weakSelf.currentAnimationModel.name isEqualToString:NvLocalString(@"None", @"无")]) {
                weakSelf.currentCell.maskView.frame = CGRectMake(0, 0, 0, 50.0*SCREENSCALE);
                weakSelf.currentAsset.animationInfoModel.maskRect = CGRectMake(0, 0, 0, 50.0*SCREENSCALE);
            }else{
                if (weakSelf.currentType == NVAnimationTypeIn || weakSelf.currentType == NVAnimationTypeCombine) {
                    weakSelf.currentCell.maskView.frame = CGRectMake(0, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                    weakSelf.currentAsset.animationInfoModel.maskRect = CGRectMake(0, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                }else if (weakSelf.currentType == NVAnimationTypeOut){
                    weakSelf.currentCell.maskView.frame = CGRectMake(77.0*SCREENSCALE-77.0*SCREENSCALE*ratio, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                    weakSelf.currentAsset.animationInfoModel.maskRect = CGRectMake(77.0*SCREENSCALE-77.0*SCREENSCALE*ratio, 0, 77.0*SCREENSCALE*ratio, 50.0*SCREENSCALE);
                }
            }
            
            
            
            
        };
        _selectView.valueChangeEndBLock = ^{
            if (weakSelf.currentType == NVAnimationTypeIn || weakSelf.currentType == NVAnimationTypeCombine) {
                [weakSelf.liveWindowPanel playBackStart:(weakSelf.currentClipIndex == 0? weakSelf.currentClip.inPoint : weakSelf.currentClip.inPoint - 0.5 * NV_TIME_BASE) end:  weakSelf.currentClip.outPoint - 0.5 * NV_TIME_BASE];
            }else if (weakSelf.currentType == NVAnimationTypeOut){
                [weakSelf.liveWindowPanel playBackStart:(weakSelf.currentClip.inPoint + weakSelf.currentAnimationModel.begin - 0.5 * NV_TIME_BASE > 0 ? weakSelf.currentClip.inPoint + weakSelf.currentAnimationModel.begin - 0.5 * NV_TIME_BASE : weakSelf.currentClip.inPoint + weakSelf.currentAnimationModel.begin) end:weakSelf.currentClip.outPoint - 0.5 * NV_TIME_BASE];
            }
        };
        self.selectView.hidden = YES;
        self.liveWindowPanel.isAnimationPlayback = NO;
    }
    return _selectView;
}
/**
 为片段添加动画特效
 Add animation effects to clips

 @param clip 素材片段
 Material fragment
 effect ID
 */
- (void)resetVideoFx:(NvsVideoClip *)clip {

    if (![clip isPropertyVideoFxEnabled]) {
        [clip enablePropertyVideoFx:YES];
    }
    if (self.currentApplyAnimationModel == nil) {
        self.currentApplyAnimationModel = [NvAnimationInfoModel new];
        self.currentApplyAnimationModel.isUsePropertyEffect = YES;
    }
    if (_currentAnimationModel.packageId.length>0) {
        if (_currentAnimationModel.animationType == NVAnimationTypeCombine) {
            self.currentApplyAnimationModel.animationCategory = NvAnimationCategoryCombine;
            self.currentApplyAnimationModel.isPostPackage = _currentAnimationModel.isPostPackage;
            self.currentApplyAnimationModel.packageId = _currentAnimationModel.packageId;
            self.currentApplyAnimationModel.animationStart = _currentAnimationModel.begin;
            self.currentApplyAnimationModel.animationEnd = _currentAnimationModel.end;
            self.currentApplyAnimationModel.packageId2 = @"";
            self.currentApplyAnimationModel.animationEnd2 = 0;
            self.currentApplyAnimationModel.animationStart2 = 0;
            self.currentApplyAnimationModel.isPostPackage2 = NO;
        }
        else if (_currentAnimationModel.animationType == NVAnimationTypeOut) {
            if (self.currentApplyAnimationModel.animationCategory == NvAnimationCategoryCombine) {
                self.currentApplyAnimationModel.packageId = @"";
                self.currentApplyAnimationModel.animationEnd = 0;
                self.currentApplyAnimationModel.animationStart = 0;
                self.currentApplyAnimationModel.isPostPackage = NO;
            }
            
            self.currentApplyAnimationModel.packageId2 = _currentAnimationModel.packageId;
            self.currentApplyAnimationModel.animationEnd2 = _currentAnimationModel.end;
            self.currentApplyAnimationModel.animationStart2 = _currentAnimationModel.begin;
            self.currentApplyAnimationModel.isPostPackage2 = _currentAnimationModel.isPostPackage;
            self.currentApplyAnimationModel.animationCategory = NvAnimationCategoryOut;
        } else if (_currentAnimationModel.animationType == NVAnimationTypeIn) {
            if (self.currentApplyAnimationModel.animationCategory == NvAnimationCategoryCombine) {
                self.currentApplyAnimationModel.packageId2 = @"";
                self.currentApplyAnimationModel.animationEnd2 = 0;
                self.currentApplyAnimationModel.animationStart2 = 0;
                self.currentApplyAnimationModel.isPostPackage2 = NO;
            }
            
            self.currentApplyAnimationModel.packageId = _currentAnimationModel.packageId;
            self.currentApplyAnimationModel.animationEnd = _currentAnimationModel.end;
            self.currentApplyAnimationModel.animationStart = _currentAnimationModel.begin;
            self.currentApplyAnimationModel.isPostPackage = _currentAnimationModel.isPostPackage;
            self.currentApplyAnimationModel.animationCategory = NvAnimationCategoryIn;
        }
    } else {
        if (_currentAnimationModel.animationType == NVAnimationTypeCombine && self.currentApplyAnimationModel.animationCategory == NvAnimationCategoryCombine) {
            self.currentApplyAnimationModel.packageId = @"";
            self.currentApplyAnimationModel.animationEnd = 0;
            self.currentApplyAnimationModel.animationStart = 0;
            self.currentApplyAnimationModel.isPostPackage = NO;
            self.currentApplyAnimationModel.packageId2 = @"";
            self.currentApplyAnimationModel.animationEnd2 = 0;
            self.currentApplyAnimationModel.animationStart2 = 0;
            self.currentApplyAnimationModel.isPostPackage2 = NO;
        } else if (_currentAnimationModel.animationType != NVAnimationTypeCombine && self.currentApplyAnimationModel.animationCategory != NvAnimationCategoryCombine) {
            if(_currentAnimationModel.animationType == NVAnimationTypeIn) {
                self.currentApplyAnimationModel.packageId = _currentAnimationModel.packageId;
                self.currentApplyAnimationModel.animationEnd = _currentAnimationModel.end;
                self.currentApplyAnimationModel.animationStart = _currentAnimationModel.begin;
                self.currentApplyAnimationModel.isPostPackage = _currentAnimationModel.isPostPackage;
                self.currentApplyAnimationModel.animationCategory = NvAnimationCategoryIn;
            } else if (_currentAnimationModel.animationType == NVAnimationTypeOut) {
                self.currentApplyAnimationModel.packageId2 = _currentAnimationModel.packageId;
                self.currentApplyAnimationModel.animationEnd2 = _currentAnimationModel.end;
                self.currentApplyAnimationModel.animationStart2 = _currentAnimationModel.begin;
                self.currentApplyAnimationModel.isPostPackage2 = _currentAnimationModel.isPostPackage;
                self.currentApplyAnimationModel.animationCategory = NvAnimationCategoryOut;
            }
        }
    }
    [NvTimelineUtils setAnimationFx:self.currentTrack clip:clip model:self.currentApplyAnimationModel];
   
}

/**
 点击livewindow播放视频
 Click live window to play the video

 @param pos 时间点
 time
 */
- (void)didTapLiveWindowAtTime:(int64_t)pos {
    self.animationEndPos = self.timeline.duration;
    [self.liveWindowPanel playBackStart:pos end:self.timeline.duration];
}

#pragma mark NvAssetManagerDelegate
/**
 获取素材列表成功回调
 Get material list successfully callback
 */
- (void)onRemoteAssetsChanged:(BOOL)hasNext {
    AssetType type = ASSET_ANIMATION_IN;
    if (self.currentType == NVAnimationTypeIn) {
        type = ASSET_ANIMATION_IN;
    }else if (self.currentType == NVAnimationTypeOut){
        type = ASSET_ANIMATION_OUT;
    }else if (self.currentType == NVAnimationTypeCombine){
        type = ASSET_ANIMATION_COMBINE;
    }
    NSArray *array = [self.assetManager getRemoteAssets:type aspectRatio:AspectRatio_All categoryId:0 kindId:0];
    for (NvAsset *asset in array) {
        if ([self isInAnimationExist:asset.uuid]){
            continue;
        }
        NvSelectedAnimationModel *item = [NvSelectedAnimationModel new];
        item.imageUrl = asset.coverUrl;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.name = asset.displayNamezhCN;
        }else{
            item.name = asset.displayName;
        }
        item.packageId = asset.uuid;
        item.isAdjusted = asset.isAdjusted;
        [self.inAnimationDataSource insertObject:item atIndex:1];
    }
    
    [self.collectionView reloadData];
}


/**
 下载在线素材完成执行该回调
 Download the online material to complete the callback
 */
- (void)onDonwloadAssetSuccess:(NSString *)uuid {
    AspectRatio ratio = [NvSDKUtils convertRatio:self.editMode];
    AssetType type = ASSET_ANIMATION_IN;
    if (self.currentType == NVAnimationTypeIn) {
        type = ASSET_ANIMATION_IN;
    }else if (self.currentType == NVAnimationTypeOut){
        type = ASSET_ANIMATION_OUT;
    }else if (self.currentType == NVAnimationTypeCombine){
        type = ASSET_ANIMATION_COMBINE;
    }
    NSArray *array = [self.assetManager getUsableAssets:type aspectRatio:ratio categoryId:0 kindId:0];
    for (NvAsset *asset in array) {
        if ([self isInAnimationExist:asset.uuid])
            if ([asset isReserved]) {
                NvSelectedAnimationModel *item = [NvSelectedAnimationModel new];
                item.imageUrl = asset.coverUrl;
                [self initReservedAssetName:asset];
                if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
                    item.name = asset.displayNamezhCN;
                        }else{
                            item.name = asset.displayName;
                        }
                item.packageId = asset.uuid;
                item.isAdjusted = asset.isAdjusted;
                [self.inAnimationDataSource insertObject:item atIndex:1];
            }
    }
    for (NvAsset *asset in array) {
        if ([self isInAnimationExist:asset.uuid]){
            continue;
        }
        if (![asset isReserved]) {
            NvSelectedAnimationModel *item = [NvSelectedAnimationModel new];
            item.imageUrl = asset.coverUrl;
            [self initReservedAssetName:asset];
            if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
                item.name = asset.displayNamezhCN;
                    }else{
                        item.name = asset.displayName;
                    }
            item.packageId = asset.uuid;
            item.isAdjusted = asset.isAdjusted;
            [self.inAnimationDataSource insertObject:item atIndex:1];
        }
    }
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.collectionView reloadData];
    });
}

/**
 点击视图反应
 Click View response
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.selectView.hidden) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    CGFloat startY = self.collectionView.frame.origin.y + self.collectionView.frame.size.height;
    CGFloat endY = self.bottomView.frame.origin.y;
    
    if (startY < point.y && point.y < endY) {
        self.isSelectedClip = NO;
        [self.editDataArray enumerateObjectsUsingBlock:^(NvEditDataModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.animationInfoModel.isSelected = NO;
        }];
        [self.collectionView reloadData];
        [self.liveWindowPanel playBackStart:[self.streamingContext getTimelineCurrentPosition:self.timeline] end:self.timeline.duration];
    }
}

@end

