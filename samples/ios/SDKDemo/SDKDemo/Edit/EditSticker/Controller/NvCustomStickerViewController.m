//
//  NvCustomStickerFilterViewController.m
//  SDKDemo
//
//  Created by dx on 2018/6/21.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvCustomStickerViewController.h"
#import "NvCustomStickerCVCell.h"
#import "NvAssetCellModel.h"
#import "NvDragView.h"
#import <NvSDKCommon/NvAssetManager.h>
#import "NvMoreFilterViewController.h"
#import "NvsStreamingContext.h"
#import "NvsVideoTrack.h"
#import "NvEditStickerViewController.h"
#import "NvEditClipStickerViewController.h"
#import "NvsVideoClip.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import <Masonry/Masonry.h>

@interface NvCustomStickerViewController () <UICollectionViewDelegate, UICollectionViewDataSource, NvsStreamingContextDelegate>
///图片展示视图
///Picture display view
@property (nonatomic, strong) UIImageView *photoView;
///动效视图
///Dynamic view
@property (nonatomic, strong) UIView *animationPanelView;
@property (nonatomic, strong) UICollectionView *animationCollectionView;
@property (nonatomic, strong) NSMutableArray *customStickerArray;
///完成按钮
///Finish button
@property (nonatomic, strong) UIButton *finishButton;
///拖拽框
///Drag frame
@property (nonatomic, strong) NvDragView *dragView;
@property (nonatomic, strong) NvAssetManager *assetManager;
@property (nonatomic, strong) NvsStreamingContext *context;
@property (nonatomic, strong) NvsVideoTrack *videoTrack;
@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, strong) NvsLiveWindow *liveWindow;
@property (nonatomic, strong) NSString *tempFile;
@property (nonatomic, strong) NSString *currentTemplateUuid;
@property (nonatomic, strong) NSMutableDictionary *reservedAssetName;
@property (nonatomic, assign) int currentCellIndex;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) UIView *line;

@end

@implementation NvCustomStickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NvLocalString(@"Choose action", @"选择动效");
    [self addSubViews];
    
    self.customStickerArray = [NSMutableArray array];
    
    self.assetManager = [NvAssetManager sharedInstance];
    NSString *itemPath = [[[NSBundle mainBundle] pathForResource:@"sticker" ofType:@"bundle"] stringByAppendingPathComponent:@"custom"];
    [self.assetManager searchReservedAssets:ASSET_CUSTOM_ANIMATED_STICKER bundlePath:itemPath];
    [self.assetManager searchLocalAssets:ASSET_CUSTOM_ANIMATED_STICKER];
    
    [self initLiveWindow];
    [self createTimeline];
    [self createTempImage];
    [self initReservedAssetName];
}
/**
 初始化资源数据
 Initialize resource data
 */
- (void)initReservedAssetName {
    _reservedAssetName = NSMutableDictionary.new;
    [_reservedAssetName setObject:NvLocalString(@"None", @"无效果") forKey:@"E14FEE65-71A0-4717-9D66-3397B6C11223"];
    [_reservedAssetName setObject:NvLocalString(@"Screw in", @"旋入") forKey:@"5D9FA998-7600-492F-9DF4-BC2FA5E869BD"];
}

- (void)initSeplineView {
    float navbarHeight = 64*SCREENSCALE;
    UIView *sepline = [[UIView alloc] initWithFrame:CGRectMake(0, 521*SCREENSCALE - navbarHeight, SCREENWIDTH, SCREENSCALE)];
    sepline.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    [self.view addSubview:sepline];
}

- (void)initLiveWindow {
    self.liveWindow = [[NvsLiveWindow alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH)];
    if ([NvHDRManager isSupportLivewindow]) {
        self.liveWindow.hdrDisplayMode = [NvSDKUtils liveWindowModelSetting];
    }
    [self.view addSubview:self.liveWindow];
    self.liveWindow.hidden = YES;
}
/**
 创建时间线
 Create timeline
 */
- (void)createTimeline {
    self.context = [NvSDKUtils getSDKContext];
    NvsVideoResolution videoEditRes;
    videoEditRes.imageWidth = 720;
    videoEditRes.imageHeight = 720;
    videoEditRes.imagePAR = (NvsRational){1, 1};
    NvsRational videoFps = {25, 1};
    NvsAudioResolution audioEditRes;
    audioEditRes.sampleRate = 48000;
    audioEditRes.channelCount = 2;
    audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
    if ([NvHDRManager isSupportEditing]) {
        self.timeline = [self.context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes bitDepth:[NvSDKUtils resolutionModelSetting] flags:0];
    }else{
        self.timeline = [self.context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes flags:0];
    }
    self.videoTrack = [self.timeline appendVideoTrack];
    [self.context connectTimeline:self.timeline withLiveWindow:self.liveWindow];
    self.context.delegate = self;
    
    NSString *itemPath = [[[NSBundle mainBundle] pathForResource:@"sticker" ofType:@"bundle"] stringByAppendingPathComponent:@"background"];
    NSString *imageFile = [itemPath stringByAppendingPathComponent:@"custom.png"];
    [self.videoTrack addClip:imageFile inPoint:0];
    [self.videoTrack changeOutPoint:0 newOutPoint:8000000];
}

- (void)dealloc {
    NSFileManager *fileManager = NSFileManager.new;
    if ([fileManager fileExistsAtPath:self.tempFile]) {
        [fileManager removeItemAtPath:self.tempFile error:nil];
    }
}

- (void)createTempImage {
    NSString *tempPath = [NvUtils getTempPath];
    self.uuid = [NvUtils uuidString];
    self.tempFile = [tempPath stringByAppendingPathComponent:[self.uuid stringByAppendingString:@".png"]];
    [UIImagePNGRepresentation(self.image) writeToFile:self.tempFile atomically:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateCustomStickers];
    [self.animationCollectionView reloadData];
}

- (void)updateCustomStickers {
    NSArray *array = [self.assetManager getUsableAssets:ASSET_CUSTOM_ANIMATED_STICKER aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    if (array.count > self.customStickerArray.count) {
        for (NvAssetCellModel *item in self.customStickerArray) {
            item.selected = NO;
        }
    }
    for (NvAsset *asset in array) {
        if ([self isAssetExist:asset.uuid])
            continue;
        NvAssetCellModel *assetModel = NvAssetCellModel.new;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            assetModel.displayName = asset.isReserved ? _reservedAssetName[asset.uuid] : asset.displayNamezhCN;
        }else{
            assetModel.displayName = asset.isReserved ? _reservedAssetName[asset.uuid] : asset.displayName;
        }
        assetModel.cover = asset.coverUrl;
        assetModel.size = [NvSDKUtils getAssetPackageSizeString:asset.packageSize];
        assetModel.draw = [NvSDKUtils getAssetAspectRatioString:asset.aspectRatio];
        assetModel.package = asset.uuid;
        [self.customStickerArray insertObject:assetModel atIndex:0];
    }
    [self selectIndex:0];
}

- (BOOL)isAssetExist:(NSString *)uuid {
    for (NvAssetCellModel *item in self.customStickerArray) {
        if ([item.package isEqualToString:uuid])
            return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addSubViews {
    [self initFinishButton];
    
    self.animationPanelView = [[UIView alloc] initWithFrame:CGRectMake(0, 465*SCREENSCALE, SCREENWIDTH, 80*SCREENSCALE)];
    
    UIButton *moreB = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreB setImage:NvImageNamed(@"NvsFilterMore") forState:UIControlStateNormal];
    moreB.frame = CGRectMake(13 * SCREENSCALE, 10*SCREENSCALE, 35 * SCREENSCALE, 25 * SCREENSCALE);
    [moreB addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *moreL = [[UILabel alloc]initWithFrame:CGRectMake(15 * SCREENSCALE, 55 * SCREENSCALE, 30 * SCREENSCALE, 21 * SCREENSCALE)];
    moreL.text = NvLocalString(@"More", @"更多");
    moreL.textColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    moreL.font = [NvUtils fontWithSize:12];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(49*SCREENSCALE, 75*SCREENSCALE);
    layout.minimumLineSpacing = 20*SCREENSCALE;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.animationCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(88 * SCREENSCALE, 3*SCREENSCALE, SCREENWIDTH - 88 * SCREENSCALE, 75*SCREENSCALE) collectionViewLayout:layout];
    self.animationCollectionView.delegate = self;
    self.animationCollectionView.dataSource = self;
    self.animationCollectionView.backgroundColor = [UIColor clearColor];
    self.animationCollectionView.showsHorizontalScrollIndicator = NO;
    [self.animationCollectionView registerClass:[NvCustomStickerCVCell class] forCellWithReuseIdentifier:@"NvCustomStickerCVCell"];
    
    [self.animationPanelView addSubview:moreB];
    [self.animationPanelView addSubview:moreL];
    [self.animationPanelView addSubview:self.animationCollectionView];
    
    [self.view addSubview:self.animationPanelView];
    
    [self.animationPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.bottom.equalTo(self.line.mas_top).offset(-15*SCREENSCALE);
        make.height.equalTo(@(80*SCREENSCALE));
    }];

    [self initPhotoView];
}

- (void)initFinishButton {
    self.finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.finishButton setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [self.finishButton addTarget:self action:@selector(finishButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.finishButton.frame = CGRectMake(175*SCREENSCALE, 568*SCREENSCALE, 25*SCREENSCALE, 20*SCREENSCALE);
    [self.view addSubview:self.finishButton];
    [self.finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-12 * SCREENSCALE - INDICATOR);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.offset(25 * SCREENSCALE);
        make.height.offset(20 * SCREENSCALE);
    }];
    self.line = [UIView new];
    self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.view addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(self.finishButton.mas_top).offset(-12*SCREENSCALE);
    }];
}

- (void)initPhotoView {
    self.photoView = [[UIImageView alloc] init];
    [self.photoView setImage:self.image];
    self.photoView.userInteractionEnabled = YES;
    [self.view addSubview:self.photoView];
    [self setPhotoViewFrame];
}

- (void)setPhotoViewFrame {
    float centerPartHeight = 455*SCREENSCALE;
    if (self.image.size.width < self.image.size.height) {
        float height = SCREENWIDTH;
        float width = self.image.size.width/self.image.size.height*height;
        float x = (SCREENWIDTH - width)/2;
        float y = (centerPartHeight - height)/2;
        self.photoView.frame = CGRectMake(x, y, width, height);
    } else if (self.image.size.width > self.image.size.height) {
        float width = SCREENWIDTH;
        float height = self.image.size.height/self.image.size.width*width;
        float x = 0;
        float y = (centerPartHeight - height)/2;
        self.photoView.frame = CGRectMake(x, y, width, height);
    } else {
        float width = SCREENWIDTH;
        float height = SCREENWIDTH;
        float x = 0;
        float y = (centerPartHeight - height)/2;
        self.photoView.frame = CGRectMake(x, y, width, height);
    }
}

#pragma mark 更多按钮点击 More button click
- (void)moreClick:(UIButton *)sender{
    NvMoreFilterViewController *vc = [[NvMoreFilterViewController alloc]init];
    vc.type = ASSET_CUSTOM_ANIMATED_STICKER;
    vc.categoryId = 20000;
    vc.kind = NV_KIND_ID_ALL;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)finishButtonClicked:(UIButton *)sender{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.tempFile]) {
        NSString *dir = [NvUtils getCustomAnimatedStickerPicPath];
        NSString *destFilePath = [dir stringByAppendingPathComponent:[self.uuid stringByAppendingString:@".png"]];
        [fileManager copyItemAtPath:self.tempFile toPath:destFilePath error:nil];
        
        NvCustomStickerInfo *info = NvCustomStickerInfo.new;
        info.uuid = self.uuid;
        info.templateUuid = self.currentTemplateUuid;
        info.imagePath = destFilePath;
        info.order = (int)_assetManager.customStickerDict.count;
        
        if (![NvUtils isStringEmpty:self.currentTemplateUuid]) {
            [_assetManager.customStickerDict setObject:info forKey:info.uuid];
            [_assetManager setAssetInfoToUserDefaults:ASSET_CUSTOM_ANIMATED_STICKER];
        }
    }
    
    if (self.timeline) {
        [self.context removeTimeline:self.timeline];
    }
    
    int count = (int)self.navigationController.viewControllers.count;
    if (count > 0) {
        for (int i = count-1; i>=0; i--) {
            UIViewController *vc = self.navigationController.viewControllers[i];
            if ([vc isKindOfClass:NvEditStickerViewController.class]) {
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
            if ([vc isKindOfClass:NvEditClipStickerViewController.class]) {
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
            if ([vc isKindOfClass:NSClassFromString(@"NvCaptureViewController")]) {
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
        }
    }
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.customStickerArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvCustomStickerCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvCustomStickerCVCell" forIndexPath:indexPath];
    [cell renderCellWithItem:self.customStickerArray[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self selectIndex:(int)indexPath.row];
    
    [collectionView reloadData];
}

- (void)selectIndex:(int)index {
    self.liveWindow.hidden = NO;
    self.photoView.hidden = YES;
    
    [self removeAllStickers];
    NvAssetCellModel *currentModel = self.customStickerArray[self.currentCellIndex];
    currentModel.selected = NO;
    
    NvAssetCellModel *cellModel = self.customStickerArray[index];
    cellModel.selected = YES;
    self.currentCellIndex = (int)index;
    self.currentTemplateUuid = cellModel.package;
    [self addCustomSticker:cellModel.package];
    [self playbackTimeline:0];
}

- (void)removeAllStickers {
    NvsTimelineAnimatedSticker *sticker = [self.timeline getFirstAnimatedSticker];
    while (sticker) {
        sticker = [self.timeline removeAnimatedSticker:sticker];
    }
}
- (void)addCustomSticker:(NSString *)packageId {
    [self.timeline addCustomAnimatedSticker:0 duration:self.timeline.duration animatedStickerPackageId:packageId customImagePath:self.tempFile];
}

- (void)playbackTimeline:(int64_t)pos {
    [NvTimelineUtils playbackTimeline:self.timeline startTime:pos endTime:-1 flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
}

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {

}

@end
