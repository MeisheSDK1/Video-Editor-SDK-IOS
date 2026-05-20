//
//  NvTransitionViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/6/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvTransitionViewController.h"
#import "NvTransitionCollectionViewCell.h"
#import "NvClipCollectionViewCell.h"
#import "NvClipItem.h"
#import "NvTimelineData.h"
#import "NvTimelineImageUtils.h"
#import "NvTimelineUtils.h"
#import "NvMoreFilterViewController.h"
#import "NvsStreamingContext.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import <NvSDKCommon/NvAssetManager.h>
#import "NvTranDurationView.h"
#import <Masonry/Masonry.h>
#import <NvBaseCommon/UIButton+NvButton.h>
#import <NvBaseCommon/UILabel+NvLabel.h>

@interface NvTransitionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,NvAssetManagerDelegate,NvTranDurationViewDelegate> {
    int64_t outpoint;
    int64_t inPoint;
    NSMutableArray *videoFxArray;
    NSMutableArray *videoFxDisplayArray;
}

@property (nonatomic, strong) UICollectionView *clipCollectionView;
@property (nonatomic, strong) UICollectionView *transitionCollectionView;
@property (nonatomic, strong) NSMutableArray<NvClipItem *> *clipDataSource;
@property (nonatomic, strong) NSMutableArray<NvThransitionModel *> *transitionDataSource;

@property (nonatomic, strong) UIButton *currentTransitionButton;

@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UILabel *moreLabel;

@property (nonatomic, strong) UIButton *okButton;

@property (nonatomic, strong) NvAssetManager *assetManager;
@property (nonatomic, assign) int selectIndex;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) NvTranDurationView *durationView;

@end

@implementation NvTransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.transitionDataSource = [NSMutableArray array];
    // Do any additional setup after loading the view.
    self.title = NvLocalString(@"Transition", @"转场");
    [self.liveWindowPanel hiddenVolumeButton];
    videoFxArray =[NSMutableArray arrayWithObjects:
                   @"Fade",
                   @"Turning",
                   @"Swap",
                   @"Stretch In",
                   @"Page Curl",
                   @"Lens Flare",
                   @"Star",
                   @"Dip To Black",
                   @"Dip To White",
                   @"Push To Right",
                   @"Push To Top",
                   @"Upper Left Into",
                   nil];
    videoFxDisplayArray = [NSMutableArray arrayWithObjects:
                           NvLocalString(@"Fade", @"淡出"),
                           NvLocalString(@"Turning", @"旋转"),
                           NvLocalString(@"Swap", @"交换"),
                           NvLocalString(@"Stretch In", @"伸展"),
                           NvLocalString(@"Page Curl", @"页面卷曲"),
                           NvLocalString(@"Lens Flare", @"镜头光晕"),
                           NvLocalString(@"Star", @"星星"),
                           NvLocalString(@"Dip To Black", @"浸入黑色"),
                           NvLocalString(@"Dip To White", @"浸入白色"),
                           NvLocalString(@"Push To Right", @"向右推"),
                           NvLocalString(@"Push To Top", @"向上推"),
                           NvLocalString(@"Upper Left Into",@"左上进入"),
                           nil];
    ///初始化转场列表
    ///Initializes the transition list
    [self initTransitionList];
    ///初始化列表数据
    ///Initializes the list data
    [self initDataFormTimeline];
    
    self.okButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvcheck - material")];
    [self.view addSubview:self.okButton];
    
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(25*SCREENSCALEHEIGHT));
        make.height.equalTo(@(20*SCREENSCALEHEIGHT));
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALEHEIGHT);
        } else {
            make.bottom.equalTo(@(-15*SCREENSCALEHEIGHT));
        }
    }];
    __weak typeof(self)weakSelf = self;
    [self.okButton nv_BtnClickHandler:^{
        NSMutableArray *order = [[NvTimelineData sharedInstance] dataOrder];
        [order removeObject:@"Transition"];
        [order addObject:@"Transition"];
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
    
    self.assetManager = [NvAssetManager sharedInstance];
    [self.assetManager searchLocalAssets:ASSET_VIDEO_TRANSITION];
    ///选中一个转场
    ///Select a transition
    NvTransitionInfoModel *transitionInfoModel = [[NvTimelineData sharedInstance] transitionDataArray].firstObject;
    [self selectTransition:transitionInfoModel];
    
    self.moreButton = [UIButton nv_buttonWithTitle:@"" textColor:nil fontSize:-1 image:NvImageNamed(@"NvsFilterMore")];
    [self.view addSubview:self.moreButton];
    
    [self.moreButton nv_BtnClickHandler:^{
        NvMoreFilterViewController *vc = [[NvMoreFilterViewController alloc]init];
        vc.editModel = weakSelf.editMode;
        vc.type = ASSET_VIDEO_TRANSITION;
        vc.isCapture = NO;
        vc.categoryId = NV_CATEGORY_ID_ALL;
        vc.kind = NV_KIND_ID_ALL;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    self.moreLabel = [UILabel nv_labelWithText:NvLocalString(@"More", @"更多") fontSize:10*SCREENSCALE textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"]];
    [self.view addSubview:self.moreLabel];
    
    UICollectionViewFlowLayout *transitionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    transitionFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    transitionFlowLayout.itemSize = CGSizeMake(44*SCREENSCALE, 71*SCREENSCALE);
    transitionFlowLayout.minimumInteritemSpacing = 8*SCREENSCALE;
    self.transitionCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:transitionFlowLayout];
    self.transitionCollectionView.showsHorizontalScrollIndicator = NO;
    self.transitionCollectionView.delegate = self;
    self.transitionCollectionView.dataSource = self;
    self.transitionCollectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    [self.view addSubview:self.transitionCollectionView];
    [self.transitionCollectionView registerClass:[NvTransitionCollectionViewCell class] forCellWithReuseIdentifier:@"NvTransitionCollectionViewCell"];
    
    [self.moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.line.mas_top).offset(-20*SCREENSCALE);
        make.left.equalTo(@(8*SCREENSCALE));
        make.width.equalTo(@(44*SCREENSCALE));
    }];
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(8*SCREENSCALE));
        make.bottom.equalTo(self.moreLabel.mas_top).offset(-6*SCREENSCALE);
        make.width.equalTo(@(44*SCREENSCALE));
        make.height.equalTo(@(44*SCREENSCALE));
    }];
    [self.transitionCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.moreButton.mas_right).offset(8*SCREENSCALE);
        make.bottom.equalTo(self.moreLabel.mas_bottom).offset(10*SCREENSCALE);
        make.right.equalTo(@(-8*SCREENSCALE));
        make.height.offset(79 * SCREENSCALE);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(100*SCREENSCALE, 42*SCREENSCALE);
    flowLayout.minimumInteritemSpacing = 5*SCREENSCALE;
    self.clipCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.clipCollectionView.showsHorizontalScrollIndicator = NO;
    self.clipCollectionView.delegate = self;
    self.clipCollectionView.dataSource = self;
    self.clipCollectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    [self.view addSubview:self.clipCollectionView];
    [self.clipCollectionView registerClass:[NvClipCollectionViewCell class] forCellWithReuseIdentifier:@"NvClipCollectionViewCell"];
    
    [self.clipCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(8*SCREENSCALE);
        make.bottom.equalTo(self.transitionCollectionView.mas_top).offset(-8*SCREENSCALE);
        make.right.equalTo(@(-8*SCREENSCALE));
        make.height.equalTo(@(56*SCREENSCALE));
    }];
    
    self.durationView = [[NvTranDurationView alloc]init];
    self.durationView.delegate = self;
    self.durationView.hidden = YES;
    [self.view addSubview:self.durationView];
    [self.durationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.liveWindowPanel.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ///初始化转场列表
    ///Initializes the transition list
    [self initTransitionList];
    ///初始化列表数据
    ///Initializes the list data
    [self initDataFormTimeline];
    ///选中一个转场
    ///Select a transition
    NvTransitionInfoModel *transitionInfoModel = [[NvTimelineData sharedInstance] transitionDataArray][self.selectIndex];
    [self selectTransition:transitionInfoModel];
}

- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

///初始化dataSource数据
///Initialize the dataSource data
- (void)initDataFormTimeline {
    ///初始化clip列表
    ///Initializes the list of clips
    self.clipDataSource = [NSMutableArray array];
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    for (int i = 0; i < videoTrack.clipCount; i++) {
        NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
        NvClipItem *item = [NvClipItem new];
        if (i == 0) {
            item.isSelect = YES;
        }
        item.isImage = (clip.videoType == NvsVideoClipType_Image);
        if (item.isImage) {
            item.isPhotoAlbum = [clip.filePath containsString:@"Documents"] ? NO : YES;
            item.localIdentifier = clip.filePath;
        } else {
            item.videoPath = clip.filePath;
        }
        
        item.trimIn = clip.trimIn;
        item.trimOut = clip.trimOut;
        if (i == videoTrack.clipCount - 1) {
            item.isLast = YES;
            item.transitionImageUrl = nil;
        } else {
            NvTransitionInfoModel *transitionInfoModel = [[NvTimelineData sharedInstance] transitionDataArray][i];
            NvsVideoTransition *tt = [videoTrack getTransitionWithSourceClipIndex:i];
            NSLog(@"bultinName:%@",tt.bultinVideoTransitionName);
            NSLog(@"PackageId:%@",tt.videoTransitionPackageId);
            NSString *ttName;
            if (tt.videoTransitionType == NvsVideoTransitionType_Builtin) {
                ttName = tt.bultinVideoTransitionName;
                transitionInfoModel.packageId = nil;
                transitionInfoModel.builtinName = ttName;
            } else {
                ttName = tt.videoTransitionPackageId;
                transitionInfoModel.packageId = ttName;
                transitionInfoModel.builtinName = nil;
            }
            if (ttName && ![videoFxArray containsObject:ttName] && ![self containPackageId:ttName]) {
                transitionInfoModel.builtinName = nil;
                transitionInfoModel.packageId = @"theme";
                if (![videoFxArray containsObject:@"theme"]) {
                    [videoFxArray insertObject:@"theme" atIndex:0];
                    [videoFxDisplayArray insertObject:NvLocalString(@"ThemeTrasition", @"主题转场") atIndex:0];
                    
                    NvThransitionModel *themeitem = [NvThransitionModel new];
                    themeitem.coverName = [NvSDKUtils getTransitionsCoverName:videoFxArray.firstObject];
                    themeitem.displayName = videoFxDisplayArray.firstObject;
                    if ([videoFxArray.firstObject isEqualToString:@"theme"]) {
                        themeitem.packageId = @"theme";
                    }
                    [_transitionDataSource addObject:themeitem];
                }
            }
            item.isLast = NO;
            if ([transitionInfoModel.packageId isEqualToString:@"theme"]) {
                item.transitionImageUrl = @"NvEditTheme";
            } else {
                if (transitionInfoModel.builtinName.length != 0) {
                    item.transitionImageUrl = [NvSDKUtils getTransitionsCoverName:transitionInfoModel.builtinName];
                }else{
                    item.transitionImageUrl = transitionInfoModel.imageUrl;
                }
            }
        }
        [self.clipDataSource addObject:item];
    }
    
    [self.clipCollectionView reloadData];
}

- (void)initTransitionList {
    if (_transitionDataSource) {
        [_transitionDataSource removeAllObjects];
    }
    self.assetManager = [NvAssetManager sharedInstance];
    self.assetManager.delegate = self;
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"transition" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_VIDEO_TRANSITION bundlePath:itemPath];
    [self.assetManager searchLocalAssets:ASSET_VIDEO_TRANSITION];
    
    AspectRatio ratio;
    switch (self.editMode) {
        case NvEditMode16v9:
            ratio = AspectRatio_16v9;
            break;
        case NvEditMode1v1:
            ratio = AspectRatio_1v1;
            break;
        case NvEditMode9v16:
            ratio = AspectRatio_9v16;
            break;
        case NvEditMode3v4:
            ratio = AspectRatio_3v4;
            break;
        case NvEditMode4v3:
            ratio = AspectRatio_4v3;
            break;
        default:
            ratio = AspectRatio_All;
            break;
    }
    
    NvThransitionModel *item = [NvThransitionModel new];
    item.coverName = [NvSDKUtils getTransitionsCoverName:NvLocalString(@"None", nil)];
    item.displayName = NvLocalString(@"None", nil) ;
    item.builtinName = nil;
    [self.transitionDataSource addObject:item];
    
    NSArray *array = [self.assetManager getUsableAssets:ASSET_VIDEO_TRANSITION aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    for (NvAsset *asset in array) {
        NvThransitionModel *item = [NvThransitionModel new];
        item.coverName = asset.coverUrl;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.displayName = asset.displayNamezhCN;
        }else{
            item.displayName = asset.displayName;
        }
        item.packageId = asset.uuid;
        if([asset.uuid containsString:@"AAE4308A-9910-4F7F-9AEE-60A5A8165A0F"]){
            item.displayName = NvLocalString(@"Signal interference", nil);
        }else if([asset.uuid containsString:@"C94516F7-0380-430E-AADC-83D9ED386790"]){
            item.displayName = NvLocalString(@"Fuzzy amplification", nil);
        }
        [self.transitionDataSource addObject:item];
    }
    
    for (int i = 0; i < videoFxArray.count; i++) {
        NvThransitionModel *item = [NvThransitionModel new];
        item.coverName = [NvSDKUtils getTransitionsCoverName:videoFxArray[i]];
        item.displayName = videoFxDisplayArray[i];
        if ([videoFxArray[i] isEqualToString:@"theme"]) {
            item.packageId = @"theme";
        } else {
            item.builtinName = videoFxArray[i];
        }
        [self.transitionDataSource addObject:item];
    }
    
    NSString *jsonPath = [[[NSBundle mainBundle] pathForResource:@"transition" ofType:@"bundle"] stringByAppendingPathComponent:@"transition.json"];
    NSString *jsontext = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
    NSData *data =[jsontext dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *arrayInfo =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    for (int i = 0; i < self.transitionDataSource.count; i++) {
        NvThransitionModel *item = self.transitionDataSource[i];
        if (!item.displayName || [item.displayName isEqualToString:@""]) {
            item.displayName = [self getDisplayNameWithPackageId:item.packageId arrayInfo:arrayInfo];
        }
    }
}

- (BOOL)containPackageId:(NSString *)packageId {
    __block BOOL isContain = NO;
    [_transitionDataSource enumerateObjectsUsingBlock:^(NvThransitionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.packageId isEqualToString:packageId]) {
            isContain = YES;
            *stop = YES;
        }
    }];
    return isContain;
}

- (void)selectTransition:(NvTransitionInfoModel *)transitionInfoModel {
    NSString *name;
    if (transitionInfoModel.builtinName.length>0) {
        name = transitionInfoModel.builtinName;
    } else if (transitionInfoModel.packageId.length > 0) {
        name = transitionInfoModel.packageId;
    }
    
    [self.transitionDataSource enumerateObjectsUsingBlock:^(NvThransitionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ((transitionInfoModel.builtinName && [transitionInfoModel.builtinName isEqualToString:obj.builtinName]) || (transitionInfoModel.packageId && [transitionInfoModel.packageId isEqualToString:obj.packageId])) {
            obj.selected = YES;
        } else if (!transitionInfoModel.builtinName&&!transitionInfoModel.packageId) {
            if ([obj.displayName isEqualToString:NvLocalString(@"None", nil)]) {
                obj.selected = YES;
            } else {
                obj.selected = NO;
            }
        } else {
            obj.selected = NO;
        }
    }];
    
    for (int i = 0; i < videoFxArray.count; i++) {
        NvThransitionModel *item = [NvThransitionModel new];
        item.coverName = [NvSDKUtils getTransitionsCoverName:videoFxArray[i]];
        item.displayName = videoFxDisplayArray[i];
        if ([videoFxArray[i] isEqualToString:@"theme"]) {
            item.packageId = @"theme";
            if ([transitionInfoModel.packageId isEqualToString:item.packageId]) {
                item.selected = YES;
            }
        } else {
            item.builtinName = videoFxArray[i];
        }
        if (transitionInfoModel.builtinName.length != 0) {
            if ([transitionInfoModel.builtinName isEqualToString:item.builtinName]) {
                item.selected = YES;
            }
        }
    }
    [self.transitionCollectionView reloadData];
}

- (NSString *)getDisplayNameWithPackageId:(NSString *)packageId arrayInfo:(NSArray *)arrayInfo {
    NSString *name;
    for (int i = 0; i < arrayInfo.count; i++) {
        NSDictionary *obj = arrayInfo[i];
        NSString *pkid = [obj objectForKey:@"packageId"];
        if ([pkid isEqualToString:packageId]) {
            name = [obj objectForKey:@"name"];
            break;
        }
    }
    return name;
}

///设置转场
///Set up a transition
- (void)setTransitionWithId:(NvThransitionModel *)transitionItem{
    if (!_isSelected) {
        NvClipItem *item = self.clipDataSource[0];
        item.isSelect = YES;
        [self.clipCollectionView reloadData];
    }
    NvTransitionInfoModel *info = [[NvTimelineData sharedInstance] transitionDataArray][self.selectIndex];
    info.packageId = transitionItem.packageId;
    info.builtinName = transitionItem.builtinName;
    info.imageUrl = transitionItem.coverName;

    [[NvTimelineData sharedInstance] transitionDataArray][self.selectIndex].imageUrl = transitionItem.coverName;
    [NvTimelineUtils resetTransition:self.timeline transitionDataArray:[[NvTimelineData sharedInstance] transitionDataArray]];
    [NvTimelineUtils resetAnimationFx:self.timeline model:[NvTimelineData sharedInstance]];
    NvClipItem *item = self.clipDataSource[self.selectIndex];
    if ([transitionItem.displayName isEqualToString:NvLocalString(@"None", nil)]) {
        item.transitionImageUrl = transitionItem.coverName;
    }else{
        if (transitionItem.builtinName.length != 0) {
            item.transitionImageUrl = [self getTransitionImageUrl:transitionItem.builtinName];
        }else{
            item.transitionImageUrl = [self getTransitionImageUrl:transitionItem.packageId];
        }
    }
    
    [self.clipCollectionView reloadData];
    
    outpoint = [self getTimeForSelectTransitionIndex:self.selectIndex];
    int64_t start,end;
    if (outpoint - NV_TIME_BASE <= 0) {
        start = 0;
    } else {
        start = outpoint - NV_TIME_BASE;
    }
    if (outpoint + NV_TIME_BASE >= self.timeline.duration) {
        end = self.timeline.duration;
    } else {
        end = outpoint + NV_TIME_BASE;
    }
    [self seekTimeline:start];
    
    [self.liveWindowPanel playBackStart:start end:end];
}

- (NSString *)getTransitionImageUrl:(NSString *)packageId {
    for (NvThransitionModel *item in self.transitionDataSource) {
        if ([item.packageId isEqualToString:packageId]) {
            return item.coverName;
        }
        if ([item.builtinName isEqualToString:packageId]) {
            return item.coverName;
        }
    }
    return nil;
}

- (int64_t)getTimeForSelectTransitionIndex:(NSInteger)index {
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    NvsVideoClip *clip = [videoTrack getClipWithIndex:(unsigned int)index];
    return clip.outPoint;
}

- (NvsVideoTransition *)getTransitionFromIndex:(NSInteger)index {
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    if (videoTrack == nil)
        return nil;
    return [videoTrack getTransitionWithSourceClipIndex:(unsigned int)index];
}

/// MARK: UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.clipCollectionView) {
        return self.clipDataSource.count;
    } else {
        return self.transitionDataSource.count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.clipCollectionView) {
        NvClipItem *item = self.clipDataSource[indexPath.item];
        NvClipCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvClipCollectionViewCell" forIndexPath:indexPath];
        [cell renderCellWithClipItem:item];
        [cell.transitionButton addTarget:self action:@selector(transitionClipButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.transitionButton.tag = 1000 + indexPath.item;
        if (item.isSelect) {
            self.currentTransitionButton = nil;
            self.currentTransitionButton = cell.transitionButton;
        }
        return cell;
    } else {
        NvTransitionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvTransitionCollectionViewCell" forIndexPath:indexPath];
        [cell renderCellWithModel:self.transitionDataSource[indexPath.item]];
        return cell;
    }
}

- (void)transitionClipButtonClick:(UIButton *)sender {
    _isSelected = YES;
    self.selectIndex = (int)(sender.tag - 1000);
    for (NvClipItem *item in self.clipDataSource) {
        item.isSelect = NO;
    }
    ///选中框
    ///Check box
    NvClipItem *item = self.clipDataSource[self.selectIndex];
    item.isSelect = YES;
    [self.clipCollectionView reloadData];
    self.currentTransitionButton = nil;
    self.currentTransitionButton = sender;
}

- (void)transitionButtonClick:(UIButton *)sender{
    _isSelected = YES;
    self.selectIndex = (int)(sender.tag - 1000);
    for (NvClipItem *item in self.clipDataSource) {
        item.isSelect = NO;
    }
    ///选中框
    ///Check box
    NvClipItem *item = self.clipDataSource[self.selectIndex];
    item.isSelect = YES;
    [self.clipCollectionView reloadData];
    
    outpoint = [self getTimeForSelectTransitionIndex:self.selectIndex];
    NvsVideoTransition *transition = [self getTransitionFromIndex:self.selectIndex];
    
    int64_t start,end;
    if (outpoint - NV_TIME_BASE <= 0) {
        start = 0;
    } else {
        start = outpoint - NV_TIME_BASE;
    }
    if (outpoint + NV_TIME_BASE >= self.timeline.duration) {
        end = self.timeline.duration;
    } else {
        end = outpoint + NV_TIME_BASE;
    }
    [self seekTimeline:start];
    
    NvTransitionInfoModel *info = [[NvTimelineData sharedInstance] transitionDataArray][self.selectIndex];
    for (NvThransitionModel *item in self.transitionDataSource) {
        if ([info.builtinName isEqualToString:item.builtinName]) {
            item.selected = YES;
        } else if ([info.packageId isEqualToString:item.packageId]) {
            item.selected = YES;
        } else {
            item.selected = NO;
        }
    }
    [self.transitionCollectionView reloadData];

    [self.liveWindowPanel playBackStart:start end:end];
    
    if (![item.name isEqualToString:NvLocalString(@"None", nil)]) {
        NSLog(@"%lld",transition.getVideoTransitionDuration);
        NSLog(@"%f",(float)transition.getVideoTransitionDuration/NV_TIME_BASE);
        self.durationView.hidden = NO;
        [self.durationView updateValue:(float)transition.getVideoTransitionDuration/NV_TIME_BASE];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.clipCollectionView) {
        NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
        inPoint = [videoTrack getClipWithIndex:(unsigned int)indexPath.row].inPoint;
        [self seekTimeline:inPoint];
        [self.liveWindowPanel playBackStart:self.liveWindowPanel.currentTime end:self.timeline.duration];
        
    } else {
        NvThransitionModel *item = self.transitionDataSource[indexPath.row];
        if (item.selected && item.displayName != NvLocalString(@"None", nil)) {
            /// 已经选中,跳转到转场时长编辑界面
            ///Selected, go to the transition duration editing screen
            [self transitionButtonClick:self.currentTransitionButton];
        }
        for (NvThransitionModel *item in self.transitionDataSource) {
            item.selected = NO;
        }
        item.selected = YES;
        [self.transitionCollectionView reloadData];

        [self setTransitionWithId:item];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.clipCollectionView) {
        if (indexPath.row == self.clipDataSource.count-1) {
            return CGSizeMake(72*SCREENSCALE, 42*SCREENSCALE);
        } else {
            return CGSizeMake(100*SCREENSCALE, 42*SCREENSCALE);
        }
    } else {
        return CGSizeMake(44*SCREENSCALE, 70*SCREENSCALE);
    }
}

#pragma mark NvTranDurationViewDelegate
- (void)updateValue:(CGFloat)value withState:(UIControlEvents)state{
    value = value * NV_TIME_BASE;
    outpoint = [self getTimeForSelectTransitionIndex:self.selectIndex];
    
    int64_t start,end;
    if (outpoint - value <= 0) {
        start = 0;
    } else {
        start = outpoint - value;
    }
    
    if (outpoint + value >= self.timeline.duration) {
        end = self.timeline.duration;
    } else {
        end = outpoint + value;
    }
    
    [self.liveWindowPanel playBackStart:start end:end];
}

- (void)saveValue:(CGFloat)value withSave:(BOOL)save{
    if (save) {
        value = value * NV_TIME_BASE;
        NvsVideoTransition *transition = [self getTransitionFromIndex:self.selectIndex];
        [transition setVideoTransitionDuration:value withMatchMode:NvsVideoTransitionDurationMatchMode_Stretch];
        NvTransitionInfoModel *info = [[NvTimelineData sharedInstance] transitionDataArray][self.selectIndex];
        info.duration = value;
        
        [NvTimelineUtils resetAnimationFxFollowTransition:self.timeline transitionIndex:self.selectIndex transitionDuration:value];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
