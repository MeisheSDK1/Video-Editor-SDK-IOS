//
//  NvMimoAlbumSelectService.m
//  AFNetworking
//
//  Created by meishe20241218 on 2025/6/27.
//

#import "NvMimoAlbumSelectService.h"
#import "NVMimoDefineConfig.h"
#import "NvPreviewViewController.h"
#import "NvMimoSizeViewController.h"
#import "NvMimoToast.h"
#import "NvMimoTimelineUtils.h"
#import "NvMimoEditTailoringViewController.h"
#import "NvMimoToast.h"
#import "NvMimoUtils.h"
#import <NvBaseCommon/NVDefineConfig.h>

@interface NvMimoAlbumSelectService ()

//底部collectionView dataSource（多轨视频在多个model中）
// Bottom collectionView dataSource (multi-track video in multiple models)
@property (nonatomic, strong) NSMutableArray <NvShotModel *> *videoArr;
//selected resource
//选中的资源
@property (nonatomic, strong) NSMutableArray *selectClipAssets;
// user-selectable shot data array (does not include empty shot, empty shot means the corresponding source field is not empty, multiple tracks are in the same model)
//用户可选镜头数据数组（不包含空镜头，空镜头即对应source字段不为空，多轨视频在同一个model中）
@property (nonatomic, strong) NSMutableArray <NvShotModel *> *clipArr;
// Bottom collectionView to process cell index
//底部collectionView 待处理cell index
@property (nonatomic, assign) NSInteger targetIndex;
@property (nonatomic, strong) NvAlbumViewController *albumViewController;
@property (nonatomic, assign) NvMimoEditMode editMode;
@end

@implementation NvMimoAlbumSelectService

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selectClipAssets = [NSMutableArray array];
        self.targetIndex = 0;
    }
    return self;
}

- (void)setThemeModel:(NvThemeModel *)themeModel {
    _themeModel = [themeModel copy];    
    self.clipArr = [NSMutableArray array];
    [self.clipArr removeAllObjects];
    self.videoArr = [NSMutableArray array];
    for(int i=0; i<_themeModel.shotInfos.count;i++) {
        NvShotModel *shotModel = _themeModel.shotInfos[i];
        if (shotModel.source.length <=0) {
            [self.clipArr addObject:shotModel];
            [self.videoArr addObject:shotModel];
            if (shotModel.subTrackFilter.count >0) {
                for (int j=0; j<shotModel.subTrackFilter.count; j++) {
                    NvShotModel *trackModel = [shotModel copy];
                    trackModel.track = j+1;
                    [self.videoArr addObject:trackModel];
                }
            }
        }
    }
    self.albumCustomView.videoArr = self.videoArr;
    [self.albumCustomView reloadData];
}

- (void)clearCache {
    [self.videoArr removeAllObjects];
    [self.selectClipAssets removeAllObjects];
    [self.clipArr removeAllObjects];
    [self.albumCustomView.videoArr removeAllObjects];
    _targetIndex = 0;
    self.isReplaceMode = NO;
    _currentShotModel = nil;
    self.dirPath = nil;
    _themeModel = nil;
    _firstCreatTimeline = YES;
}

// MARK: 处理选中asset逻辑
// Handle the selected asset logic
- (void)processWithSelectedAsset:(NvMimoAlbumAsset *)asset {
   
    //添加对应资源及封面
    //Add resources and covers
    __weak typeof(self)weakSelf = self;
    [[PHImageManager defaultManager] requestImageForAsset:asset.asset targetSize:CGSizeMake(45*SCREANSCALE, 45*SCREANSCALE) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (![info[@"PHImageResultIsDegradedKey"] boolValue]) {
            /*
             * 如果是替换mode，进行替换
             * 否则直接添加
             * If it's replacement mode, do the replacement
             * Otherwise add it directly
             */
            if(self.isReplaceMode){
                NSInteger index =0;
                BOOL isExist = NO;
                for (NvShotModel *model in self.clipArr) {
                    if (model.shot == self.currentShotModel.shot) {
                        index = [self.clipArr indexOfObject:model];
                        isExist = YES;
                    }
                }
                if (isExist) {
                    NvShotModel *model = [weakSelf.videoArr objectAtIndex:index];
                    model.coverImage = result;
                    model.asset = asset;
                    if (asset.asset.mediaType == PHAssetMediaTypeImage) {
                        model.isImage = YES;
                    }else if(asset.asset.mediaType == PHAssetMediaTypeVideo){
                        model.isImage = NO;
                        model.assetDuration = (CGFloat)asset.asset.duration *1000000;
                    }
                    //因为替换后需要重新计算trimOut ，所以这里暂时赋值为0
                    // 0 because we need to recompute trimOut after the replacement
                    model.trimOut = 0;
                    [self.clipArr replaceObjectAtIndex:index withObject:model];
                    
                    for (NvShotModel *shotModel in self.clipArr) {
                        if (shotModel.shot == model.shot) {
                            if (model.track == 0) {
                                shotModel.asset = asset;
                                shotModel.videoPath = asset.asset.localIdentifier;
                            }else{
                                if (shotModel.subTrackFilter.count >= model.track) {
                                    NSInteger index = (NSInteger)model.track -1;
                                    NvSubTrackFilterModel *subModel = shotModel.subTrackFilter[index];
                                    subModel.trackVideoPath = asset.asset.localIdentifier;
                                    subModel.isImage = model.isImage;
                                }
                                
                            }
                        }
                    }
                    
                }
                self.isReplaceMode = NO;
               
            }else{
                [weakSelf.selectClipAssets addObject:asset];
                if (weakSelf.selectClipAssets.count < weakSelf.videoArr.count) {
                    self.targetIndex = weakSelf.selectClipAssets.count;
                }
                NvShotModel *model = [weakSelf.videoArr objectAtIndex:(weakSelf.selectClipAssets.count -1)];
                if (asset.asset.mediaType == PHAssetMediaTypeImage) {
                    model.isImage = YES;
                }else if(asset.asset.mediaType == PHAssetMediaTypeVideo){
                    model.isImage = NO;
                    model.assetDuration = (CGFloat)asset.asset.duration *1000000;
                }
                model.coverImage = result;
                model.asset = asset;
                for (NvShotModel *shotModel in self.clipArr) {
                    if (shotModel.shot == model.shot) {
                        if (model.track == 0) {
                            shotModel.asset = asset;
                            shotModel.videoPath = asset.asset.localIdentifier;
                        }else{
                            if (shotModel.subTrackFilter.count >= model.track) {
                                NSInteger index = (NSInteger)model.track -1;
                                NvSubTrackFilterModel *subModel = shotModel.subTrackFilter[index];
                                subModel.trackVideoPath = asset.asset.localIdentifier;
                                if(asset.asset.mediaType == PHAssetMediaTypeImage){
                                    subModel.isImage = YES;
                                }else if (asset.asset.mediaType == PHAssetMediaTypeVideo){
                                    subModel.assetDuration = (CGFloat)asset.asset.duration *NV_TIME_BASE;
                                    subModel.isImage = NO;
                                    subModel.trimIn = 0;
                                    subModel.trimOut = shotModel.duration;
                                    if(shotModel.duration > subModel.assetDuration){
                                        subModel.trimOut = subModel.assetDuration;
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
            
            weakSelf.albumCustomView.videoArr = self.videoArr;
            [weakSelf.albumCustomView reloadData];
        }
    }];
}

#pragma mark - NvAlbumViewControllerSelectStrategy
- (BOOL)enableNvAlbumViewControllerSelectStrategy:(NvAlbumViewController *)albumViewController {
    if (!self.albumViewController) {
        self.albumViewController = albumViewController;
    }
    return YES;
}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAssetOnSelectStrategy:(PHAsset *)asset {
    if (self.selectClipAssets.count == self.videoArr.count && self.videoArr.count >0 && !self.isReplaceMode) {
        return;
    }
    NvMimoAlbumAsset *albumAsset = [NvMimoAlbumAsset new];
    albumAsset.asset = asset;
    [self processWithSelectedAsset:albumAsset];
}

#pragma mark - NvMimoAlbumCustomBottomViewDelegate
- (void)nvMimoAlbumCustomBottomViewClickFinishButton:(NvMimoAlbumCustomBottomView *)view {
    if (self.selectClipAssets.count < self.clipArr.count) {
        [NvMimoToast showInfoWithMessage:NvLocalStringFromTable([self class], @"Lack of material", @"缺少素材, 请添加素材到可用槽位")];
        return;
    }
    
    if (self.themeModel.supportedAspectRatio.length>0 && [self.themeModel.supportedAspectRatio containsString:@"|"] && self.firstCreatTimeline) {
        
        NvMimoSizeViewController *sizeVC = [NvMimoSizeViewController new];
        sizeVC.supportedAspectRatio = self.themeModel.supportedAspectRatio;
        sizeVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self.albumViewController presentViewController:sizeVC animated:NO completion:NULL];
        __weak typeof(self)weakSelf = self;
        [sizeVC selectSizeTypeBlock:^(NvMimoEditMode type) {
            
            self.editMode = type;
            NvPreviewViewController *vc = [[NvPreviewViewController alloc] initWithThemeModel:self.themeModel shotArr:self.clipArr];
            vc.dirPath = self.dirPath;
            vc.editMode = type;
            vc.selectService = weakSelf;
            weakSelf.firstCreatTimeline = NO;
            [weakSelf.albumViewController.navigationController pushViewController:vc animated:YES];
            
        }];
    }
    else if (!self.firstCreatTimeline) {

        __weak typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NvPreviewViewController *vc = [[NvPreviewViewController alloc] initWithThemeModel:self.themeModel shotArr:self.clipArr];
            vc.dirPath = self.dirPath;
            vc.editMode =  self.editMode;
            vc.selectService = weakSelf;
            weakSelf.firstCreatTimeline = NO;
            [weakSelf.albumViewController.navigationController pushViewController:vc animated:YES];
        });
    }
    else{
        NvPreviewViewController *vc = [[NvPreviewViewController alloc] initWithThemeModel:self.themeModel shotArr:self.clipArr];
        vc.dirPath = self.dirPath;
        self.editMode = self.themeModel.supportedAspectRatio.length>0 ? [NvMimoTimelineUtils editModeWithString:self.themeModel.supportedAspectRatio] : NvEditMode16v9;
        vc.editMode =  self.editMode;
        vc.selectService = self;
        self.firstCreatTimeline = NO;
        [self.albumViewController.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)nvMimoAlbumCustomBottomView:(NvMimoAlbumCustomBottomView *)view selectItemIndex:(NSUInteger)index {
    [NvMimoTimelineUtils arrangeVideoData:self.videoArr dirPath:self.dirPath];
    NvShotModel *model = self.videoArr[index];
    if (model.asset != nil) {
        __weak typeof(self)weakSelf = self;
        NvMimoEditTailoringViewController *vc = [NvMimoEditTailoringViewController new];
        vc.editMode = NvEditMode16v9;
        vc.model = model;
        vc.replaceBlock = ^(NvShotModel *replaceModel) {
            weakSelf.isReplaceMode = YES;
            weakSelf.currentShotModel = replaceModel;
        };
        [self.albumViewController.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - setter
- (void)setTargetIndex:(NSInteger)targetIndex {
    _targetIndex = targetIndex;
    for (NvShotModel *model in self.videoArr) {
        model.selected = NO;
    }
    NvShotModel *model = self.videoArr[targetIndex];
    model.selected = YES;
    self.albumCustomView.targetIndex = targetIndex;
    self.albumCustomView.videoArr = self.videoArr;
    [self.albumCustomView reloadData];
}

- (void)setCurrentShotModel:(NvShotModel *)currentShotModel {
    _currentShotModel = currentShotModel;
    if (self.isReplaceMode) {
        self.targetIndex = [self.clipArr indexOfObject:self.currentShotModel];
    }
}
@end
