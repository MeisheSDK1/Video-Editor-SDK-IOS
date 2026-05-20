//
//  NvAssetManager.m
//  SDKDemo
//
//  Created by dx on 2018/6/8.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvAssetManager.h"
#import "NvHttpRequest.h"
#import "NvUtils.h"
#import "NvSDKUtils.h"
#import <SSZipArchive/SSZipArchive.h>
#import <NvBaseCommon/NSString+NvPath.h>
#define NV_CDN_URL              @"http://omxuaeaki.bkt.clouddn.com"
#define NV_DOMAIN_URL           NV_HOST

@interface NvAssetManager() <NvHttpRequestDelegate, NvsAssetPackageManagerDelegate>

@property (nonatomic, strong) NvsStreamingContext *streamingContext;

@end

@implementation NvUserAssetInfo

@end

@implementation NvCustomStickerInfo

@end

@implementation NvAssetManager {
    NvHttpRequest *networkManager;
    NSString *assetDownloadDirPathTheme;
    NSString *assetDownloadDirPathFilter;
    NSString *assetDownloadDirPathFilterInAnimation;
    NSString *assetDownloadDirPathCaption;
    NSString *assetDownloadDirPathCaptionRenderer;
    NSString *assetDownloadDirPathCaptionContext;
    NSString *assetDownloadDirPathCaptionAnimation;
    NSString *assetDownloadDirPathCaptionInAnimation;
    NSString *assetDownloadDirPathCaptionOutAnimation;
    NSString *assetDownloadDirPathCompoundCaption;
    NSString *assetDownloadDirPathAnimatedSticker;
    NSString *assetDownloadDirPathStickerAnimation;
    NSString *assetDownloadDirPathStickerInAnimation;
    NSString *assetDownloadDirPathStickerOutAnimation;
    NSString *assetDownloadDirPathTransition;
    NSString *assetDownloadDirPathCaptureScene;
    NSString *assetDownloadDirPathFont;
    NSString *assetDownloadDirPathParticle;
    NSString *assetDownloadDirPathFaceSticker;
    NSString *assetDownloadDirPathCustomAnimatedSticker;
    NSString *assetDownloadDirPathFace1Sticker;
    NSString *assetDownloadDirPathSuperzoom;
    NSString *assetDownloadDirPathARScene;
    NSString *assetDownloadDirPathAnimationIn;
    NSString *assetDownloadDirPathAnimationOut;
    NSString *assetDownloadDirPathAnimationCombine;
    NSString *assetDownloadDirPathMakeup;
    BOOL isLocalAssetSearchedTheme;
    BOOL isLocalAssetSearchedFilter;
    BOOL isLocalAssetSearchedCaption;
    BOOL isLocalAssetSearchedCaptionRenderer;
    BOOL isLocalAssetSearchedCaptionContext;
    BOOL isLocalAssetSearchedCaptionAnimation;
    BOOL isLocalAssetSearchedCaptionInAnimation;
    BOOL isLocalAssetSearchedCaptionOutAnimation;
    BOOL isLocalAssetSearchedCompoundCaption;
    BOOL isLocalAssetSearchedAnimatedSticker;
    BOOL isLocalAssetSearchedStickerAnimation;
    BOOL isLocalAssetSearchedStickerInAnimation;
    BOOL isLocalAssetSearchedStickerOutAnimation;
    BOOL isLocalAssetSearchedTransition;
    BOOL isLocalAssetSearchedCaptureScene;
    BOOL isLocalAssetSearchedFont;
    BOOL isLocalAssetSearchedParticle;
    BOOL isLocalAssetSearchedFaceSticker;
    BOOL isLocalAssetSearchedCustomAnimatedSticker;
    BOOL isLocalAssetSearchedFace1Sticker;
    BOOL isLocalAssetSearchedSuperzoom;
    BOOL isLocalAssetSearchedARScene;
    BOOL isLocalAssetSearchedAnimationIn;
    BOOL isLocalAssetSearchedAnimationOut;
    BOOL isLocalAssetSearchedAnimationCombine;
    BOOL isLocalAssetSearchedMakeup;
}

static NvAssetManager *sharedInstance = nil;
+ (NvAssetManager *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[NvAssetManager alloc] init];
        sharedInstance.hashTable = [NSHashTable weakObjectsHashTable];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    self.assetDict = NSMutableDictionary.new;
    self.maxConcurrentAssetDownloadNum = 10;
    self.downloadingAssetsCounter = 0;
    self.pendingAssetsToDownload = NSMutableArray.new;
    assetDownloadDirPathTheme = [NvSDKUtils getAssetDownloadPath:ASSET_THEME];
    assetDownloadDirPathFilter = [NvSDKUtils getAssetDownloadPath:ASSET_FILTER];
    assetDownloadDirPathCaption = [NvSDKUtils getAssetDownloadPath:ASSET_CAPTION_STYLE];
    assetDownloadDirPathCaptionRenderer = [NvSDKUtils getAssetDownloadPath:ASSET_CAPTION_RENDERER];
    assetDownloadDirPathCaptionContext = [NvSDKUtils getAssetDownloadPath:ASSET_CAPTION_CONTEXT];
    assetDownloadDirPathCaptionAnimation = [NvSDKUtils getAssetDownloadPath:ASSET_CAPTION_ANIMATION];
    assetDownloadDirPathCaptionInAnimation = [NvSDKUtils getAssetDownloadPath:ASSET_CAPTION_INANIMATION];
    assetDownloadDirPathCaptionOutAnimation = [NvSDKUtils getAssetDownloadPath:ASSET_CAPTION_OUTANIMATION];
    assetDownloadDirPathCompoundCaption = [NvSDKUtils getAssetDownloadPath:ASSET_COMPOUND_CAPTION];
    assetDownloadDirPathAnimatedSticker = [NvSDKUtils getAssetDownloadPath:ASSET_ANIMATED_STICKER];
    assetDownloadDirPathTransition = [NvSDKUtils getAssetDownloadPath:ASSET_VIDEO_TRANSITION];
    assetDownloadDirPathCaptureScene = [NvSDKUtils getAssetDownloadPath:ASSET_CAPTURE_SCENE];
    assetDownloadDirPathFont = [NvSDKUtils getAssetDownloadPath:ASSET_FONT];
    assetDownloadDirPathParticle = [NvSDKUtils getAssetDownloadPath:ASSET_PARTICLE];
    assetDownloadDirPathFaceSticker = [NvSDKUtils getAssetDownloadPath:ASSET_FACE_STICKER];
    assetDownloadDirPathCustomAnimatedSticker = [NvSDKUtils getAssetDownloadPath:ASSET_CUSTOM_ANIMATED_STICKER];
    assetDownloadDirPathFace1Sticker = [NvSDKUtils getAssetDownloadPath:ASSET_FACE1_STICKER];
    assetDownloadDirPathSuperzoom = [NvSDKUtils getAssetDownloadPath:ASSET_SUPERZOOM];
    assetDownloadDirPathARScene = [NvSDKUtils getAssetDownloadPath:ASSET_ARSCENE];
    assetDownloadDirPathAnimationIn = [NvSDKUtils getAssetDownloadPath:ASSET_ANIMATION_IN];
    assetDownloadDirPathAnimationOut = [NvSDKUtils getAssetDownloadPath:ASSET_ANIMATION_OUT];
    assetDownloadDirPathAnimationCombine = [NvSDKUtils getAssetDownloadPath:ASSET_ANIMATION_COMBINE];
    assetDownloadDirPathStickerAnimation = [NvSDKUtils getAssetDownloadPath:ASSET_STICKER_ANIMATION];
    assetDownloadDirPathStickerInAnimation = [NvSDKUtils getAssetDownloadPath:ASSET_STICKER_INANIMATION];
    assetDownloadDirPathStickerOutAnimation = [NvSDKUtils getAssetDownloadPath:ASSET_STICKER_OUTANIMATION];
    assetDownloadDirPathMakeup = [NvSDKUtils getAssetDownloadPath:ASSET_MAKEUP];
    self.streamingContext = [NvsStreamingContext sharedInstance];
    self.streamingContext.assetPackageManager.delegate = self;
    self.remoteAssetsOrderedList = NSMutableDictionary.new;
    self.customStickerDict = NSMutableDictionary.new;
    self.isSyncInstallAsset = YES;
    [self initCustomStickersFromUserDefaults];
    
    return self;
}
- (void)downloadRemoteAssetsInfoForCapture:(AssetType)assetType categoryId:(int)categoryId page:(int)page pageSize:(int)pageSize kind:(int)kind
                       ratioFlag:(int)ratioFlag
                           ratio:(int)ratio
                      sdkVerskon:(NSString *)sdkVerskon{
    networkManager = [NvHttpRequest sharedInstance];
    [networkManager checkNetwork:self];
    [networkManager getAssetListForCaptureScene:assetType categoryId:categoryId page:page pageSize:pageSize kind:kind ratioFlag:ratioFlag ratio:ratio sdkVerskon:sdkVerskon  withDelegate:self];
}

- (void)downloadRemoteAssetsInfo:(AssetType)assetType categoryId:(int)categoryId page:(int)page pageSize:(int)pageSize kind:(int)kind modular:(NvAssetModular)modular ratioFlag:(int)ratioFlag ratio:(int)ratio sdkVerskon:(NSString *)sdkVerskon{
    networkManager = [NvHttpRequest sharedInstance];
    [networkManager checkNetwork:self];
    [networkManager getAssetList:assetType categoryId:categoryId page:page pageSize:pageSize kind:kind modular:modular ratioFlag:ratioFlag ratio:ratio sdkVerskon:sdkVerskon  withDelegate:self];
}

- (void)downloadRemoteAssetsInfo:(AssetType)assetType categoryId:(int)categoryId keyword:(NSString *)keyword page:(int)page pageSize:(int)pageSize kind:(int)kind modular:(NvAssetModular)modular ratioFlag:(int)ratioFlag ratio:(int)ratio sdkVerskon:(NSString *)sdkVerskon {
    networkManager = [NvHttpRequest sharedInstance];
    [networkManager checkNetwork:self];
    [networkManager getAssetList:assetType categoryId:categoryId keyword:keyword page:page pageSize:pageSize kind:kind modular:modular ratioFlag:ratioFlag ratio:ratio sdkVerskon:sdkVerskon withDelegate:self];
}

#pragma mark - 获取在线素材
///Get online material
- (void)newDownloadRemoteAssetsInfo:(AssetType)assetType categoryId:(int)categoryId categoryList:(NSString *)categorys keyword:(NSString *)keyword page:(int)page pageSize:(int)pageSize kind:(int)kind ratioFlag:(int)ratioFlag ratio:(int)ratio sdkVerskon:(NSString *)sdkVerskon{
    networkManager = [NvHttpRequest sharedInstance];
    [networkManager checkNetwork:self];
    [networkManager newGetAssetList:assetType categoryId:categoryId categoryList:categorys keyword:keyword page:page pageSize:pageSize kind:kind ratioFlag:ratioFlag ratio:ratio sdkVerskon:sdkVerskon withDelegate:self];
}

- (NSArray *)getRemoteAssets:(AssetType)assetType aspectRatio:(AspectRatio)aspectRatio categoryId:(int)categoryId kindId:(int)kindId{
    NSMutableArray *assets = self.remoteAssetsOrderedList[[NSString stringWithFormat:@"%d", assetType]];
    NSMutableArray *array = NSMutableArray.new;
    for (NSString *uuid in assets) {
        NvAsset *asset = [self findAsset:uuid];
        if (aspectRatio == AspectRatio_All && categoryId == NV_CATEGORY_ID_ALL) {
            if (kindId == NV_KIND_ID_ALL || kindId == asset.kind) {
                [array addObject:asset];
            }
            
        } else if (aspectRatio == AspectRatio_All && categoryId != NV_CATEGORY_ID_ALL) {
            
            if (assetType == ASSET_FILTER ) {
                if (asset.category == 2 || asset.category == 1 ){
                    if (kindId == NV_KIND_ID_ALL || kindId == asset.kind) {
                        [array addObject:asset];
                    }
                }
            }else{
                if (asset.category == categoryId ){
                    if (kindId == NV_KIND_ID_ALL || kindId == asset.kind) {
                        [array addObject:asset];
                    }
                }
            }
   
        } else if (aspectRatio != AspectRatio_All && categoryId == NV_CATEGORY_ID_ALL) {
             
        } else {
            if ((asset.aspectRatio & aspectRatio) == aspectRatio && asset.category == categoryId)
                [array addObject:asset];
        }
    }
    return array;
}

#pragma mark - 搜索本地沙盒素材
///Search for local sandbox materials
- (NSArray *)searchLocalMaterialAssets:(AssetType)assetType
                       bundlePath:(NSString *)bundlePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array = [fileManager contentsOfDirectoryAtPath:bundlePath error:nil];
    NSString *key = [NSString stringWithFormat:@"Local%d", assetType];
    
    NSMutableArray *assets = self.assetDict[key];
    if (assets == nil) {
        assets = NSMutableArray.new;
        [self.assetDict setObject:assets forKey:key];
    }
    
    [assets removeAllObjects];
    
    NSArray *suffixArray = @[@".webp",@".png",@".PNG"];
    for (NSString *filename in array) {
        if ([filename containsString:@".webp"] ||
            [filename containsString:@".png"] ||
            [filename containsString:@".json"] ||
            [filename containsString:@".plist"]||
            [filename containsString:@".lic"]){
            continue;
        }
        
        NvAsset *assetInfo = NvAsset.new;
        assetInfo.assetType = assetType;
        assetInfo.uuid = [[filename componentsSeparatedByString:@"."] firstObject];
        assetInfo.isReserved = YES;
        assetInfo.downloadStatus = DownloadStatusFinished;
        assetInfo.bundledLocalDirPath = [bundlePath stringByAppendingPathComponent:filename];
        assetInfo.localDirPath = [bundlePath stringByAppendingPathComponent:filename];
        assetInfo.packagePath = [bundlePath stringByAppendingPathComponent:filename];
        assetInfo.licensePath = [NSString convertFilePathToNewPath:assetInfo.packagePath WithExtension:@"lic"];
        NSString *coverString = @"";
        for (NSString *suffixString in suffixArray) {
            coverString = [bundlePath stringByAppendingPathComponent:[assetInfo.uuid stringByAppendingString:suffixString]];
            if (coverString && [fileManager fileExistsAtPath:coverString]) {
                break;
            }
        }
        
        assetInfo.coverUrl = coverString;
        assetInfo.displayName = @"";
        [assets addObject:assetInfo];
        
        NSMutableString *mutableString = [NSMutableString string];
        NvsAssetPackageManagerError error = [self.streamingContext.assetPackageManager installAssetPackage:assetInfo.packagePath
                                                          license:assetInfo.licensePath
                                                                                                      type:[assetInfo getPackageType]
                                                             sync:YES
                                                   assetPackageId:mutableString];
        if (error == NvsAssetPackageManagerError_AlreadyInstalled) {
            [self.streamingContext.assetPackageManager uninstallAssetPackage:mutableString type:[assetInfo getPackageType]];
            [self.streamingContext.assetPackageManager installAssetPackage:assetInfo.packagePath
                                                              license:assetInfo.licensePath
                                                                                                          type:[assetInfo getPackageType]
                                                                 sync:YES
                                                       assetPackageId:mutableString];
        }
    }
    
    return assets;
}

- (NSArray *)getRemoteAssets:(AssetType)assetType
                 aspectRatio:(AspectRatio)aspectRatio
                  categoryId:(int)categoryId
                      kindId:(int)kindId
                     keyword:(NSString *)keyword {
    NSMutableArray *array = NSMutableArray.new;
    for (NSString *uuid in self.keywordAsset) {
        NvAsset *asset = [self findAsset:uuid];
        [array addObject:asset];
    }
    return array;
}

- (NSArray *)sortAssetByIdx:(NSMutableArray *)assets {
    NSArray *sortedAssets = [assets sortedArrayUsingComparator:^NSComparisonResult(NvAsset *  _Nonnull obj1, NvAsset * _Nonnull obj2) {
        return obj1.idx > obj2.idx;
    }];
    return sortedAssets;
}

- (NSArray *)getUsableAssets:(AssetType)assetType aspectRatio:(AspectRatio)aspectRatio categoryId:(int)categoryId kindId:(int)kindId{
    NSMutableArray *assets = self.assetDict[[NSString stringWithFormat:@"%d", assetType]];
    
    NSArray *sortedAssets = [assets sortedArrayUsingComparator:^NSComparisonResult(NvAsset *  _Nonnull obj1, NvAsset * _Nonnull obj2) {
        NSDictionary *fileAttributes1 = [[NSFileManager defaultManager] attributesOfItemAtPath:[obj1 isReserved] ? obj1.bundledLocalDirPath : obj1.localDirPath
                                                                                         error:nil];
        
        NSDictionary *fileAttributes2 = [[NSFileManager defaultManager] attributesOfItemAtPath:[obj2 isReserved] ? obj2.bundledLocalDirPath : obj2.localDirPath
                                                                                         error:nil];
        NSDate *date1 = [fileAttributes1 objectForKey:NSFileCreationDate] ;
        NSDate *date2 = [fileAttributes2 objectForKey:NSFileCreationDate] ;
        if (date1 == nil)
            return YES;
        if (date2 == nil)
            return NO;
        return [date2 compare:date1];
    }];
    NSMutableArray *array = NSMutableArray.new;
    for (NvAsset *asset in sortedAssets) {
        if (aspectRatio == AspectRatio_All && categoryId == NV_CATEGORY_ID_ALL) {
            if ([asset isUsable])
                if (kindId == NV_KIND_ID_ALL || kindId == asset.kind) {
                    [array addObject:asset];
                }
        } else if (aspectRatio == AspectRatio_All && categoryId != NV_CATEGORY_ID_ALL) {
            if (assetType == ASSET_ANIMATION_IN || assetType == ASSET_ANIMATION_OUT || assetType == ASSET_ANIMATION_COMBINE) {
                if ([asset isUsable])
                    [array addObject:asset];
            }else{
                if (asset.category == categoryId && [asset isUsable])
                    if (kindId == NV_KIND_ID_ALL || kindId == asset.kind) {
                        [array addObject:asset];
                    }
            }
            
        } else if (aspectRatio != AspectRatio_All && categoryId == NV_CATEGORY_ID_ALL) {
            if (assetType == ASSET_ANIMATED_STICKER) {
                if ([asset isUsable]){
                    [array addObject:asset];
                }
            }else{
                if ((asset.aspectRatio & aspectRatio) == aspectRatio && [asset isUsable]){
                    [array addObject:asset];
                }
            }
        } else {
            if ((asset.aspectRatio & aspectRatio) == aspectRatio && asset.category == categoryId && [asset isUsable])
                [array addObject:asset];
        }
    }
    
    return array;
}

- (NSArray *)getReservedAssets:(AssetType)assetType aspectRatio:(AspectRatio)aspectRatio categoryId:(int)categoryId kindId:(int)kindId{
    NSMutableArray *assets = self.assetDict[[NSString stringWithFormat:@"%d", assetType]];
    NSMutableArray *array = NSMutableArray.new;
    for (NvAsset *asset in assets) {
        if (aspectRatio == AspectRatio_All && categoryId == NV_CATEGORY_ID_ALL) {
            if ([asset isUsable] && [asset isReserved])
                [array addObject:asset];
        } else if (aspectRatio == AspectRatio_All && categoryId != NV_CATEGORY_ID_ALL) {
            if (asset.category == categoryId && asset.kind == kindId && [asset isUsable] && [asset isReserved])
                [array addObject:asset];
        } else if (aspectRatio != AspectRatio_All && categoryId == NV_CATEGORY_ID_ALL) {
            if ((asset.aspectRatio & aspectRatio) == aspectRatio && [asset isUsable] && [asset isReserved])
                [array addObject:asset];
        } else {
            if ((asset.aspectRatio & aspectRatio) == aspectRatio && asset.category == categoryId && [asset isUsable] && [asset isReserved])
                [array addObject:asset];
        }
    }
    return array;
}

- (DownloadStatus)getAssetDownloadStatus:(NSString *)uuid {
    NvAsset *asset = [self findAsset:uuid];
    if (asset == nil)
        return DownloadStatusNone;
    return asset.downloadStatus;
}

- (int)getAssetDownloadProgress:(NSString *)uuid {
    NvAsset *asset = [self findAsset:uuid];
    if (asset == nil)
        return 0;
    return (int)(asset.downloadProgress*100 +.5f);
}

- (NvAsset *)getAsset:(NSString *)uuid {
    return [self findAsset:uuid];
}

- (BOOL)downloadAsset:(NSString *)uuid {
    NvAsset *asset = [self findAsset:uuid];
    if (asset == nil) {
        NSLog(@"Invalid asset uuid %@", uuid);
        return NO;
    }
    if (![asset hasRemoteAsset]) {
        NSLog(@"Asset '%@' doesn't have a remote url!", uuid);
        return NO;
    }
    switch (asset.downloadStatus) {
        case DownloadStatusNone:
        case DownloadStatusFinished:
        case DownloadStatusFailed:
            break;
        case DownloadStatusPending:
            NSLog(@"Asset '%@' has already in pending download state!", uuid);
            return NO;
        case DownloadStatusInProgress:
            NSLog(@"Asset '%@' is being downloaded right now!", uuid);
            return NO;
        case DownloadStatusDecompressing:
            NSLog(@"Asset '%@' is being uncompressed right now!", uuid);
            return NO;
        default:
            NSLog(@"Invalid status for Asset '%@'!", uuid);
            return NO;
    }
    
    [self.pendingAssetsToDownload addObject:uuid];
    asset.downloadStatus = DownloadStatusPending;
    [self downloadPendingAsset];
    
    return YES;
}

- (void)downloadPendingAsset {
    while (self.downloadingAssetsCounter < self.maxConcurrentAssetDownloadNum && _pendingAssetsToDownload.count) {
        NSString *uuid = [_pendingAssetsToDownload lastObject];
        [_pendingAssetsToDownload removeLastObject];
        if (![self startDownloadAsset:uuid]) {
            NvAsset *asset = [self findAsset:uuid];
            asset.downloadStatus = DownloadStatusFailed;
            if ([self.delegate respondsToSelector:@selector(onDonwloadAssetFailed:)]) {
                [self.delegate onDonwloadAssetFailed:uuid];
            }
            
            if (self.hashTable && self.hashTable.allObjects.count > 0) {
                for (id delegateVC in self.hashTable.allObjects) {
                    if (delegateVC && [delegateVC respondsToSelector:@selector(onDonwloadAssetFailed:)]) {
                        [delegateVC onDonwloadAssetFailed:uuid];
                    }
                }
            }
        }
    }
}

- (NSString *)getAssetDownloadDirPath:(AssetType)assetType {
    switch (assetType) {
        case ASSET_THEME:
            return assetDownloadDirPathTheme;
        case ASSET_FILTER:
            return assetDownloadDirPathFilter;
        case ASSET_CAPTION_STYLE:
            return assetDownloadDirPathCaption;
        case ASSET_CAPTION_RENDERER:
            return assetDownloadDirPathCaptionRenderer;
        case ASSET_CAPTION_CONTEXT:
            return assetDownloadDirPathCaptionContext;
        case ASSET_CAPTION_ANIMATION:
            return assetDownloadDirPathCaptionAnimation;
        case ASSET_CAPTION_INANIMATION:
            return assetDownloadDirPathCaptionInAnimation;
        case ASSET_CAPTION_OUTANIMATION:
            return assetDownloadDirPathCaptionOutAnimation;
        case ASSET_COMPOUND_CAPTION:
            return assetDownloadDirPathCompoundCaption;
        case ASSET_ANIMATED_STICKER:
            return assetDownloadDirPathAnimatedSticker;
        case ASSET_VIDEO_TRANSITION:
            return assetDownloadDirPathTransition;
        case ASSET_CAPTURE_SCENE:
            return assetDownloadDirPathCaptureScene;
        case ASSET_FONT:
            return assetDownloadDirPathFont;
        case ASSET_PARTICLE:
            return assetDownloadDirPathParticle;
        case ASSET_FACE_STICKER:
            return assetDownloadDirPathFaceSticker;
        case ASSET_CUSTOM_ANIMATED_STICKER:
            return assetDownloadDirPathCustomAnimatedSticker;
        case ASSET_FACE1_STICKER:
            return assetDownloadDirPathFace1Sticker;
        case ASSET_SUPERZOOM:
            return assetDownloadDirPathSuperzoom;
        case ASSET_ARSCENE:
            return assetDownloadDirPathARScene;
        case ASSET_ANIMATION_IN:
            return assetDownloadDirPathAnimationIn;
        case ASSET_ANIMATION_OUT:
            return assetDownloadDirPathAnimationOut;
        case ASSET_ANIMATION_COMBINE:
            return assetDownloadDirPathAnimationCombine;
        case ASSET_STICKER_ANIMATION:
            return assetDownloadDirPathStickerAnimation;
        case ASSET_STICKER_INANIMATION:
            return assetDownloadDirPathStickerInAnimation;
        case ASSET_STICKER_OUTANIMATION:
            return assetDownloadDirPathStickerOutAnimation;
        case ASSET_MAKEUP:
            return assetDownloadDirPathMakeup;
        default:
            break;
    }
    return @"";
}

- (BOOL)getIsLocalAssetSearched:(AssetType)assetType {
    switch (assetType) {
        case ASSET_THEME:
            return isLocalAssetSearchedTheme;
        case ASSET_FILTER:
            return isLocalAssetSearchedFilter;
        case ASSET_CAPTION_STYLE:
            return isLocalAssetSearchedCaption;
        case ASSET_CAPTION_RENDERER:
            return isLocalAssetSearchedCaptionRenderer;
        case ASSET_CAPTION_CONTEXT:
            return isLocalAssetSearchedCaptionContext;
        case ASSET_CAPTION_ANIMATION:
            return isLocalAssetSearchedCaptionAnimation;
        case ASSET_CAPTION_INANIMATION:
            return isLocalAssetSearchedCaptionInAnimation;
        case ASSET_CAPTION_OUTANIMATION:
            return isLocalAssetSearchedCaptionOutAnimation;
        case ASSET_COMPOUND_CAPTION:
            return isLocalAssetSearchedCompoundCaption;
        case ASSET_ANIMATED_STICKER:
            return isLocalAssetSearchedAnimatedSticker;
        case ASSET_VIDEO_TRANSITION:
            return isLocalAssetSearchedTransition;
        case ASSET_CAPTURE_SCENE:
            return isLocalAssetSearchedCaptureScene;
        case ASSET_FONT:
            return isLocalAssetSearchedFont;
        case ASSET_PARTICLE:
            return isLocalAssetSearchedParticle;
        case ASSET_FACE_STICKER:
            return isLocalAssetSearchedFaceSticker;
        case ASSET_CUSTOM_ANIMATED_STICKER:
            return isLocalAssetSearchedCustomAnimatedSticker;
        case ASSET_FACE1_STICKER:
            return isLocalAssetSearchedFace1Sticker;
        case ASSET_SUPERZOOM:
            return isLocalAssetSearchedSuperzoom;
        case ASSET_ARSCENE:
            return isLocalAssetSearchedARScene;
        case ASSET_ANIMATION_IN:
            return isLocalAssetSearchedAnimationIn;
        case ASSET_ANIMATION_OUT:
            return isLocalAssetSearchedAnimationOut;
        case ASSET_ANIMATION_COMBINE:
            return isLocalAssetSearchedAnimationCombine;
        case ASSET_STICKER_ANIMATION:
            return isLocalAssetSearchedStickerAnimation;
        case ASSET_STICKER_INANIMATION:
            return isLocalAssetSearchedStickerInAnimation;
        case ASSET_STICKER_OUTANIMATION:
            return isLocalAssetSearchedStickerOutAnimation;
        
        default:
            break;
    }
    return NO;
}

- (void)setIsLocalAssetSearched:(AssetType)assetType isSearched:(BOOL)isSearched {
    switch (assetType) {
        case ASSET_THEME:
            isLocalAssetSearchedTheme = isSearched;
            return;
        case ASSET_FILTER:
            isLocalAssetSearchedFilter = isSearched;
            return;
        case ASSET_CAPTION_STYLE:
            isLocalAssetSearchedCaption = isSearched;
            return;
        case ASSET_CAPTION_RENDERER:
            isLocalAssetSearchedCaptionRenderer = isSearched;
            return;
        case ASSET_CAPTION_CONTEXT:
            isLocalAssetSearchedCaptionContext = isSearched;
            return;
        case ASSET_CAPTION_ANIMATION:
            isLocalAssetSearchedCaptionAnimation = isSearched;
            return;
        case ASSET_CAPTION_INANIMATION:
            isLocalAssetSearchedCaptionInAnimation = isSearched;
            return;
        case ASSET_CAPTION_OUTANIMATION:
            isLocalAssetSearchedCaptionOutAnimation = isSearched;
            return;
        case ASSET_COMPOUND_CAPTION:
            isLocalAssetSearchedCompoundCaption = isSearched;
            return;
        case ASSET_ANIMATED_STICKER:
            isLocalAssetSearchedAnimatedSticker = isSearched;
            return;
        case ASSET_VIDEO_TRANSITION:
            isLocalAssetSearchedTransition = isSearched;
            return;
        case ASSET_CAPTURE_SCENE:
            isLocalAssetSearchedCaptureScene = isSearched;
            return;
        case ASSET_FONT:
            isLocalAssetSearchedFont = isSearched;
            return;
        case ASSET_PARTICLE:
            isLocalAssetSearchedParticle = isSearched;
            return;
        case ASSET_FACE_STICKER:
            isLocalAssetSearchedFaceSticker = isSearched;
            return;
        case ASSET_CUSTOM_ANIMATED_STICKER:
            isLocalAssetSearchedCustomAnimatedSticker = isSearched;
            return;
        case ASSET_FACE1_STICKER:
            isLocalAssetSearchedFace1Sticker = isSearched;
            return;
        case ASSET_SUPERZOOM:
            isLocalAssetSearchedSuperzoom = isSearched;
            return;
        case ASSET_ARSCENE:
            isLocalAssetSearchedARScene = isSearched;
            return;
        case ASSET_ANIMATION_IN:
            isLocalAssetSearchedAnimationIn = isSearched;
            return;
        case ASSET_ANIMATION_OUT:
            isLocalAssetSearchedAnimationOut = isSearched;
            return;
        case ASSET_ANIMATION_COMBINE:
            isLocalAssetSearchedAnimationCombine = isSearched;
            return;
        case ASSET_STICKER_ANIMATION:
            isLocalAssetSearchedStickerAnimation = isSearched;
            return;
        case ASSET_STICKER_INANIMATION:
            isLocalAssetSearchedStickerInAnimation = isSearched;
            return;
        case ASSET_STICKER_OUTANIMATION:
            isLocalAssetSearchedStickerOutAnimation = isSearched;
            return;
        default:
            break;
    }
}

- (BOOL)startDownloadAsset:(NSString *)uuid {
    NvAsset *asset = [self findAsset:uuid];
    if (asset == nil) {
        NSLog(@"Invalid asset uuid %@", uuid);
        return NO;
    }
    if (![asset hasRemoteAsset]) {
        NSLog(@"Asset '%@' doesn't have a remote url!", uuid);
        return NO;
    }
    
    NSAssert(asset.downloadStatus == DownloadStatusPending, @"download asset failed!");
    AssetType type = asset.assetType;
    
    NSString *assetDownloadDirPath = [self getAssetDownloadDirPath:type];
    if ([NvUtils isStringEmpty:assetDownloadDirPath])
        return NO;
    
    NvHttpRequest *httpRequest = [NvHttpRequest sharedInstance];
    asset.downloadTask = [httpRequest downloadAsset:asset.zipUrl
                   destFileDir:assetDownloadDirPath
                  withDelegate:self
                    downloadID:asset.uuid];
    
    _downloadingAssetsCounter++;
    asset.downloadProgress = 0;
    asset.downloadStatus = DownloadStatusInProgress;
    
    return YES;
}

- (BOOL)cancelAssetDownload:(NSString *)uuid {
    NvAsset *asset = [self findAsset:uuid];
    if (asset == nil) {
        NSLog(@"Invalid asset uuid %@", uuid);
        return NO;
    }
    switch (asset.downloadStatus) {
        case DownloadStatusPending:
            [_pendingAssetsToDownload removeObject:uuid];
            asset.downloadStatus = DownloadStatusNone;
            break;
        case DownloadStatusInProgress:
            [asset.downloadTask cancel];
            asset.downloadStatus = DownloadStatusNone;
            break;
        case DownloadStatusFailed:
            [asset.downloadTask cancel];
            asset.downloadStatus = DownloadStatusNone;
            break;
        case DownloadStatusDecompressingFailed:
            [asset.downloadTask cancel];
            asset.downloadStatus = DownloadStatusNone;
            break;
        default:
            NSLog(@"You can't cancel downloading asset '%@' while it is not in any of the download states!", uuid);
            return NO;
    }
    return YES;
}

- (NvAsset *)findAsset:(NSString *)uuid {
    for (NSString *key in self.assetDict) {
        for (NvAsset *asset in self.assetDict[key]) {
            asset.assetType = key.intValue;
            if ([asset.uuid isEqualToString:uuid]) {
                return asset;
            }
        }
    }
    return nil;
}

- (void)searchLocalAssets:(AssetType)assetType {
    [self searchLocalAssets:assetType categoryId:1];
}

- (void)searchLocalAssets:(AssetType)assetType categoryId:(int)categoryId {
    if ([self getIsLocalAssetSearched:assetType])
        return;
    
    NSString *dirPath = [self getAssetDownloadDirPath:assetType];
    [self setAssetInPath:assetType dirPath:dirPath isReserved:NO categoryId:categoryId];
    
    [self setIsLocalAssetSearched:assetType isSearched:YES];
}


- (void)searchReservedAssets:(AssetType)assetType bundlePath:(NSString *)bundlePath {
    [self setAssetInPath:assetType dirPath:bundlePath isReserved:YES];
}

- (void)searchReservedAssets:(AssetType)assetType bundlePath:(NSString *)bundlePath categoryId:(int)categoryId {
    [self setAssetInPath:assetType dirPath:bundlePath isReserved:YES categoryId:(int)categoryId];
}

- (void)setAssetInPath:(AssetType)assetType dirPath:(NSString *)dirPath isReserved:(BOOL)isReserved {
    [self setAssetInPath:assetType dirPath:dirPath isReserved:isReserved categoryId:1];
}

- (void)setAssetInPath:(AssetType)assetType dirPath:(NSString *)dirPath isReserved:(BOOL)isReserved categoryId:(int)categoryId {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array = [fileManager contentsOfDirectoryAtPath:dirPath error:nil];
    NSMutableArray *assets = self.assetDict[[NSString stringWithFormat:@"%d", assetType]];
    if (assets == nil) {
        assets = NSMutableArray.new;
        [self.assetDict setObject:assets forKey:[NSString stringWithFormat:@"%d", assetType]];
    }
    for (NSString *filename in array) {
        
        if ([filename containsString:@".webp"] ||
            [filename containsString:@".png"] ||
            [filename containsString:@".json"] ||
            [filename containsString:@".plist"]||
            [filename containsString:@".lic"]) continue;
        
        NvAsset *assetInfo = NvAsset.new;
        assetInfo.assetType = assetType;
        assetInfo.uuid = [[filename componentsSeparatedByString:@"."] firstObject];
        assetInfo.isReserved = isReserved;
        assetInfo.downloadStatus = DownloadStatusDecompressing;
        if (isReserved) {
            assetInfo.bundledLocalDirPath = [dirPath stringByAppendingPathComponent:filename];
            assetInfo.packagePath = assetInfo.bundledLocalDirPath;
            assetInfo.licensePath = [NSString convertFilePathToNewPath:assetInfo.packagePath WithExtension:@"lic"];
        } else {
            assetInfo.localDirPath = [dirPath stringByAppendingPathComponent:filename];
            assetInfo.packagePath = assetInfo.localDirPath;
            assetInfo.licensePath = [NSString convertFilePathToNewPath:assetInfo.packagePath WithExtension:@"lic"];
        }
        NSString *assetDownloadDirPath = [self getAssetDownloadDirPath:assetType];
        NSArray *filesArr = [fileManager contentsOfDirectoryAtPath:assetDownloadDirPath error:nil];
        NvAsset *foundAsset = [self findAsset:assetInfo.uuid];
        if (filesArr.count > 0) {
            
            for (NSString *filesName in filesArr) {
                
                if ( [filesName containsString:@"png"] ||
                    [filesName containsString:@"json"] ||
                    [filesName containsString:@".plist"] ||
                    [filesName containsString:@"jpeg"] ||
                    [filesName containsString:@"jpg"] ||
                    [filesName containsString:@"webp"]) {
                    continue;
                }
                if ([filesName containsString:assetInfo.uuid]) {
                    NSArray *bundleArr = [[dirPath stringByAppendingPathComponent:filename] componentsSeparatedByString:@"."];
                    NSArray *localArr = [filesName componentsSeparatedByString:@"."];
                    NSInteger localVersion = 0;
                    NSInteger bundleVersion = 0;
                    if (localArr.count > 2) {
                        localVersion = [localArr[1] integerValue];
                    }
                    if (bundleArr.count>3) {
                        bundleVersion = [bundleArr[2] integerValue];
                    }
                    if (localVersion > bundleVersion) {
                        NSString *assetPath = [assetDownloadDirPath stringByAppendingPathComponent:filesName];
                        if (isReserved) {
                            assetInfo.bundledLocalDirPath = assetPath;
                            if (foundAsset) {
                                foundAsset.bundledLocalDirPath = assetPath;
                            }
                            assetInfo.packagePath = assetPath;
                        }else{
                            assetInfo.localDirPath = assetPath;
                            if (foundAsset) {
                                foundAsset.localDirPath = assetPath;
                            }
                            assetInfo.packagePath = assetPath;
                        }
                    }
                    break;
                }
            }
        }
        [self installAsset:assetInfo];
        
        if (!isReserved) {
            NvUserAssetInfo *userAssetInfo = [self getAssetInfoFromUserDefaults:assetType uuid:assetInfo.uuid];
            if (userAssetInfo) {
                assetInfo.coverUrl = userAssetInfo.coverUrl;
                assetInfo.coverUrl2 = [NSURL URLWithString:userAssetInfo.coverUrl2];
                assetInfo.idx = userAssetInfo.idx;
                assetInfo.displayName = userAssetInfo.name;
                assetInfo.category = userAssetInfo.categoryId;
                assetInfo.kind = userAssetInfo.kind;
                assetInfo.aspectRatio = userAssetInfo.aspectRatio;
                assetInfo.packageSize = userAssetInfo.remotePackageSize;
                assetInfo.displayNamezhCN = userAssetInfo.displayNamezhCN;
                assetInfo.isAdjusted = userAssetInfo.isAdjusted;
                assetInfo.packagePath = userAssetInfo.packagePath;
                assetInfo.licensePath = userAssetInfo.licensePath;
            }
        } else {
            NSString *suffix = @".png";
            if (assetInfo.assetType == ASSET_THEME){
                suffix = @".jpg";
            }
            assetInfo.coverUrl = [dirPath stringByAppendingPathComponent:[assetInfo.uuid stringByAppendingString:suffix]];
            NSFileManager *fm = [NSFileManager defaultManager];
            if (![fm fileExistsAtPath:assetInfo.coverUrl]) {
                assetInfo.coverUrl = [dirPath stringByAppendingPathComponent:[assetInfo.uuid stringByAppendingString:@".jpg"]];
            }
            if (![fm fileExistsAtPath:assetInfo.coverUrl]) {
                assetInfo.coverUrl = [dirPath stringByAppendingPathComponent:[assetInfo.uuid stringByAppendingString:@".webp"]];
            }
            assetInfo.displayName = @"";
            NvUserAssetInfo *userAssetInfo = [self getAssetInfoFromUserDefaults:assetType uuid:assetInfo.uuid];
            assetInfo.kind = userAssetInfo.kind;
            if (userAssetInfo.name.length > 0) {
                assetInfo.displayName = userAssetInfo.name;
            }
            if (userAssetInfo.displayNamezhCN.length > 0) {
                assetInfo.displayNamezhCN = userAssetInfo.displayNamezhCN;
            }
            assetInfo.category = categoryId;
            assetInfo.aspectRatio = [self.streamingContext.assetPackageManager getAssetPackageSupportedAspectRatio:assetInfo.uuid type:[assetInfo getPackageType]];
        }

        if (assetInfo.assetType == ASSET_FONT)
            assetInfo.aspectRatio = AspectRatio_All;
        
        NvAsset *asset = [self findAsset:assetInfo.uuid];
        if (asset == nil) {
            [assets addObject:assetInfo];
        } else {
            if (asset.version < assetInfo.version) {
                [asset copyAsset:assetInfo];
            }
        }
    }
}

- (void)installAsset:(NvAsset *)assetInfo {
    if (assetInfo.assetType == ASSET_FACE1_STICKER) {
        NSString *filepath = assetInfo.isReserved ? assetInfo.bundledLocalDirPath : assetInfo.localDirPath;
        assetInfo.downloadStatus = DownloadStatusFinished;
        assetInfo.version = [NvSDKUtils getAssetVersionWithPath:filepath];
        
        if (assetInfo.isReserved) {
            NSString *coverString = [filepath stringByReplacingOccurrencesOfString:@".bundle" withString:@".png"];
            assetInfo.coverUrl = coverString;
        }
    } else if (assetInfo.assetType == ASSET_SUPERZOOM) {
        NSString *filepath = assetInfo.isReserved ? assetInfo.bundledLocalDirPath : assetInfo.localDirPath;
        assetInfo.downloadStatus = DownloadStatusFinished;
        if (assetInfo.isReserved) {
            NSString *coverString = [filepath stringByAppendingString:@".png"];
            assetInfo.coverUrl = coverString;
            NSString *cover2String = [filepath stringByAppendingString:@"2.png"];
            assetInfo.coverUrl2 = [NSURL URLWithString:cover2String];
        }
    } else if (assetInfo.assetType == ASSET_FONT) {
        NSString *filepath = assetInfo.isReserved ? assetInfo.bundledLocalDirPath : assetInfo.localDirPath;
        assetInfo.downloadStatus = DownloadStatusFinished;
        if (assetInfo.isReserved) {
            NSString *coverString = [filepath stringByAppendingString:@".png"];
            assetInfo.coverUrl = coverString;
            NSString *cover2String = [filepath stringByAppendingString:@"2.png"];
            assetInfo.coverUrl2 = [NSURL URLWithString:cover2String];
        }
        assetInfo.aspectRatio = AspectRatio_All;
    } else {
        NSMutableString *packageId = [[NSMutableString alloc] init];
        NSString *packagePath = assetInfo.isReserved ? assetInfo.bundledLocalDirPath : assetInfo.packagePath;
        NSString *licensePath = [NSString convertFilePathToNewPath:packagePath WithExtension:@"lic"];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSAssert([fm fileExistsAtPath:packagePath], [NSString stringWithFormat:@"packagePath: %@ don't exit"],packagePath);
        NSAssert([fm fileExistsAtPath:licensePath], ([NSString stringWithFormat:@"licensePath: %@ don't exit"],licensePath));
#ifdef DEBUG
        NSLog(@"packagePath:%@\nlicensePath:%@",packagePath,licensePath);
#endif
        if (self.isSyncInstallAsset) {
            NvsAssetPackageManagerError error = [self.streamingContext.assetPackageManager installAssetPackage:packagePath
                                                              license:licensePath
                                                                                                          type:[assetInfo getPackageType]
                                                                 sync:YES
                                                       assetPackageId:packageId];
            if (error == NvsAssetPackageManagerError_NoError) {
                assetInfo.downloadStatus = DownloadStatusFinished;
                assetInfo.version = [self.streamingContext.assetPackageManager getAssetPackageVersion:assetInfo.uuid type:[assetInfo getPackageType]];
                assetInfo.aspectRatio = [self.streamingContext.assetPackageManager getAssetPackageSupportedAspectRatio:assetInfo.uuid type:[assetInfo getPackageType]];
            } else if (error == NvsAssetPackageManagerError_AlreadyInstalled) {
                assetInfo.downloadStatus = DownloadStatusFinished;
                assetInfo.version = [self.streamingContext.assetPackageManager getAssetPackageVersion:assetInfo.uuid type:[assetInfo getPackageType]];
                assetInfo.aspectRatio = [self.streamingContext.assetPackageManager getAssetPackageSupportedAspectRatio:assetInfo.uuid type:[assetInfo getPackageType]];
                int bundleVersion = 1;
                int localVersion = 1;
                if (assetInfo.bundledLocalDirPath != nil)  {
                    bundleVersion = [self.streamingContext.assetPackageManager getAssetPackageVersionFromAssetPackageFilePath:assetInfo.bundledLocalDirPath];
                }
                if (assetInfo.localDirPath != nil) {
                    localVersion = [self.streamingContext.assetPackageManager getAssetPackageVersionFromAssetPackageFilePath:assetInfo.localDirPath];
                }
                    
                int version = bundleVersion > localVersion ? bundleVersion : localVersion;
                packagePath = bundleVersion > localVersion ? assetInfo.bundledLocalDirPath : assetInfo .localDirPath;
                if (version > assetInfo.version) {
                    error = [self.streamingContext.assetPackageManager upgradeAssetPackage:packagePath
                                                                      license:licensePath
                                                                         type:[assetInfo getPackageType]
                                                                         sync:YES
                                                               assetPackageId:packageId];
                    if (error == NvsAssetPackageManagerError_NoError) {
                        assetInfo.version = version;
                        assetInfo.aspectRatio = [self.streamingContext.assetPackageManager getAssetPackageSupportedAspectRatio:assetInfo.uuid type:[assetInfo getPackageType]];
                    } else {
                        ;
                    }
                }
            } else {
                assetInfo.downloadStatus = DownloadStatusDecompressingFailed;
            }
        } else {
            if ([self.streamingContext.assetPackageManager getAssetPackageStatus:assetInfo.uuid type:[assetInfo getPackageType]]
                == NvsAssetPackageManagerError_AlreadyInstalled) {
                int version = [self.streamingContext.assetPackageManager getAssetPackageVersionFromAssetPackageFilePath:packagePath];
                if (version > assetInfo.version) {
                    [self.streamingContext.assetPackageManager upgradeAssetPackage:packagePath
                                                                      license:licensePath
                                                                         type:[assetInfo getPackageType]
                                                                         sync:NO
                                                               assetPackageId:packageId];
                }
            } else {
                [self.streamingContext.assetPackageManager installAssetPackage:packagePath
                                                                  license:licensePath
                                                                     type:[assetInfo getPackageType]
                                                                     sync:NO
                                                           assetPackageId:packageId];
            }
        }
    }
}

- (void)setAssetInfoToUserDefaults:(AssetType)assetType {
    NSString *assetTypeString = [NSString stringWithFormat:@"%d",assetType];
    NSMutableDictionary *assetInfoDict = NSMutableDictionary.new;
    NSMutableDictionary *assetsDict = NSMutableDictionary.new;
    for (NvAsset *asset in self.assetDict[assetTypeString]) {
        NSMutableDictionary *assetDict = NSMutableDictionary.new;
        [assetDict setObject:asset.displayName == nil ? @"" : asset.displayName forKey:@"name"];
        [assetDict setObject:asset.displayNamezhCN == nil ? @"" : asset.displayNamezhCN forKey:@"displayNamezhCN"];
        
        if ([asset.coverUrl containsString:@"http"]) {
            [assetDict setObject:asset.coverUrl forKey:@"coverUrl"];
        } else {
            NSArray *pathComponents = [asset.coverUrl componentsSeparatedByString:@".app"];
            ///通过.app分割，没有通过获取bundle路经replace，因为怕此时获取当前bundle路经跟以前版本存储不一致
            ///Do not replace the bundle path by getting the bundle path through.app, because the current bundle path is not stored in the same way as the previous version
            [assetDict setObject:asset.coverUrl == nil ? @"" : pathComponents.lastObject forKey:@"coverUrl"];
        }
        [assetDict setObject:asset.coverUrl2 == nil ? @"" : [asset.coverUrl2 absoluteString] forKey:@"coverUrl2"];
        [assetDict setObject:[NSNumber numberWithInt:asset.category] forKey:@"categoryId"];
        [assetDict setObject:[NSNumber numberWithInt:asset.kind] forKey:@"kind"];
        [assetDict setObject:[NSNumber numberWithInt:asset.aspectRatio] forKey:@"aspectRatio"];
        [assetDict setObject:[NSNumber numberWithInt:asset.packageSize] forKey:@"remotePackageSize"];
        [assetDict setObject:[NSNumber numberWithInt:asset.idx] forKey:@"idx"];
        [assetDict setObject:[NSNumber numberWithBool:asset.isAdjusted] forKey:@"isAdjusted"];
        [assetDict setObject:asset.packagePath.length >0?asset.packagePath:@"" forKey:@"packagePath"];
        [assetDict setObject:asset.licensePath.length >0?asset.licensePath:@"" forKey:@"licensePath"];
        if (asset.coverUrl.length != 0) {
            [assetsDict setObject:[NSMutableDictionary dictionaryWithDictionary:assetDict] forKey:asset.uuid];
        }
    }
    [assetInfoDict setObject:[NSDictionary dictionaryWithDictionary:assetsDict] forKey:assetTypeString];
    if (![[NSFileManager defaultManager] fileExistsAtPath:VIDEO_PATH(@"cache")]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:VIDEO_PATH(@"cache") withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (assetInfoDict.count != 0) {
        if ([assetInfoDict writeToFile:[VIDEO_PATH(@"cache") stringByAppendingPathComponent:[assetTypeString stringByAppendingString:@"assetcache.plist"]] atomically:YES]) {
            
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",[NSDate timeIntervalSinceReferenceDate]] forKey:@"存储失败"];
        }
    }
    
    NSMutableDictionary *stickersDict = NSMutableDictionary.new;
    for (NSString *key in self.customStickerDict) {
        NvCustomStickerInfo *info = self.customStickerDict[key];
        NSMutableDictionary *stickerDict = NSMutableDictionary.new;
        [stickerDict setObject:info.templateUuid forKey:@"templateUUID"];
        NSString *imagePath = [info.imagePath componentsSeparatedByString:@"Documents"].lastObject;
        NSString *imagegifPath = [info.tempImage componentsSeparatedByString:@"Documents"].lastObject;
        [stickerDict setObject:imagePath forKey:@"imagePath"];
        if (imagegifPath) {
            [stickerDict setObject:imagegifPath forKey:@"imagegifPath"];
        }
        [stickerDict setObject:[NSNumber numberWithInt: info.order] forKey:@"order"];
        [stickersDict setObject:[NSMutableDictionary dictionaryWithDictionary:stickerDict] forKey:info.uuid];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:VIDEO_PATH(@"cache")]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:VIDEO_PATH(@"cache") withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![stickersDict writeToFile:[VIDEO_PATH(@"cache") stringByAppendingPathComponent:@"customsticks.plist"] atomically:YES]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",[NSDate timeIntervalSinceReferenceDate]] forKey:@"存储失败"];
    }
}

- (NvUserAssetInfo *)getAssetInfoFromUserDefaults:(AssetType)assetType uuid:(NSString *)uuid {
    NSString *assetTypeString = [NSString stringWithFormat:@"%d",assetType];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[VIDEO_PATH(@"cache") stringByAppendingPathComponent:[assetTypeString stringByAppendingString:@"assetcache.plist"]]];
    NSDictionary *assetsDict = dict[[NSString stringWithFormat:@"%d", assetType]];
    for (NSString *key in assetsDict) {
        if ([key isEqualToString:uuid]) {
            NSDictionary *assetDict = assetsDict[key];
            NvUserAssetInfo *assetInfo = NvUserAssetInfo.new;
            assetInfo.name = assetDict[@"name"];
            assetInfo.displayNamezhCN = assetDict[@"displayNamezhCN"];
            NSString *coverUrl = assetDict[@"coverUrl"];
            if ([coverUrl containsString:@"http"]) {
                assetInfo.coverUrl = coverUrl;
            } else {
                if ([coverUrl containsString:@"/"]) {
                    assetInfo.coverUrl = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:coverUrl];
                } else {
                    assetInfo.coverUrl = coverUrl;
                }
            }
            assetInfo.coverUrl2 = assetDict[@"coverUrl2"];
            assetInfo.categoryId = [(NSNumber *)assetDict[@"categoryId"] intValue];
            assetInfo.kind = [(NSNumber *)assetDict[@"kind"] intValue];
            assetInfo.aspectRatio = [(NSNumber *)assetDict[@"aspectRatio"] intValue];
            assetInfo.remotePackageSize = [(NSNumber *)assetDict[@"remotePackageSize"] intValue];
            assetInfo.idx = [(NSNumber *)assetDict[@"idx"] intValue];
            assetInfo.isAdjusted = [(NSNumber *)assetDict[@"isAdjusted"] boolValue];
            assetInfo.packagePath = assetDict[@"packagePath"];
            assetInfo.licensePath = assetDict[@"licensePath"];
            return assetInfo;
        }
    }
    return nil;
}

- (void)initCustomStickersFromUserDefaults {
    NSDictionary *stickersDict = [NSDictionary dictionaryWithContentsOfFile:[VIDEO_PATH(@"cache") stringByAppendingPathComponent:@"customsticks.plist"]];
    for (NSString *key in stickersDict) {
        NSDictionary *stickerDict = stickersDict[key];
        NvCustomStickerInfo *info = NvCustomStickerInfo.new;
        info.uuid = key;
        info.templateUuid = stickerDict[@"templateUUID"];
        info.order = [(NSNumber *)stickerDict[@"order"] intValue];
        NSString *saveImagePath = stickerDict[@"imagePath"];
        NSString *saveImagePath1 = stickerDict[@"imagegifPath"];
        NSString *documentPaht = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *imagePath = [saveImagePath componentsSeparatedByString:@"Documents"].lastObject;
        NSString *imagePath1 = [saveImagePath1 componentsSeparatedByString:@"Documents"].lastObject;
        info.imagePath = [documentPaht stringByAppendingString:imagePath];
        if (imagePath1) {
            info.tempImage = [documentPaht stringByAppendingString:imagePath1];
        }
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:info.imagePath]) {
            [self.customStickerDict setObject:info forKey:key];
        }
    }
}

- (void)addRemoteAssetData:(NSArray *)resultsArray assetType:(AssetType)assetType {
    
    NSMutableArray *assets = self.assetDict[[NSString stringWithFormat:@"%d", assetType]];
    if (assets == nil) {
        assets = NSMutableArray.new;
    }
    for (NSDictionary *dict in resultsArray) {
        NvAsset *assetInfo = NvAsset.new;
        assetInfo.assetType = assetType;
        if ([dict objectForKey:@"zipUrl"])
            assetInfo.zipUrl = [dict objectForKey:@"zipUrl"];
        if ([dict objectForKey:@"category"])
            assetInfo.category = [[dict objectForKey:@"category"] intValue];
        if ([dict objectForKey:@"categoryInfo"]){
            assetInfo.categoryInfo.displayName = dict[@"categoryInfo"][@"displayName"];
            assetInfo.categoryInfo.displayNameZhCn = dict[@"categoryInfo"][@"displayNameZhCn"];
            assetInfo.categoryInfo.ID = [dict[@"categoryInfo"][@"id"] integerValue];
            assetInfo.categoryInfo.type = [dict[@"categoryInfo"][@"type"] integerValue];
        }
        if ([dict objectForKey:@"typeInfo"]){
            assetInfo.typeInfo.displayName = dict[@"typeInfo"][@"displayName"];
            assetInfo.typeInfo.displayNameZhCn = dict[@"typeInfo"][@"displayNameZhCn"];
            assetInfo.typeInfo.ID = [dict[@"typeInfo"][@"id"] integerValue];
            assetInfo.typeInfo.displayState = [dict[@"typeInfo"][@"displayState"] integerValue];
        }
        if ([dict objectForKey:@"costQuota"])
            assetInfo.costQuota = [[dict objectForKey:@"costQuota"] intValue];
        if ([dict objectForKey:@"coverUrl"])
            assetInfo.coverUrl = [dict objectForKey:@"coverUrl"];
            assetInfo.coverUrl2 = [NSURL URLWithString:assetInfo.coverUrl];
        if ([dict objectForKey:@"kind"])
            assetInfo.kind = [[dict objectForKey:@"kind"] intValue];
        if ([dict objectForKey:@"customDisplayName"])
            assetInfo.customDisplayName = [dict objectForKey:@"customDisplayName"];
        if ([dict objectForKey:@"description"])
            assetInfo.desc = [dict objectForKey:@"description"];
        if ([dict objectForKey:@"displayName"])
            assetInfo.displayName = [dict objectForKey:@"displayName"];
        if ([dict objectForKey:@"displayNameZhCn"])
            assetInfo.displayNameZhCn = [dict objectForKey:@"displayNameZhCn"];
        if ([dict objectForKey:@"displayNamezhCN"])
            assetInfo.displayNamezhCN = [dict objectForKey:@"displayNamezhCN"];
        if ([dict objectForKey:@"infoUrl"])
            assetInfo.infoUrl = [dict objectForKey:@"infoUrl"];
        if ([dict objectForKey:@"infoJson"])
            assetInfo.infoJson = [dict objectForKey:@"infoJson"];
        if ([dict objectForKey:@"id"])
            assetInfo.uuid = [dict objectForKey:@"id"];
        if ([dict objectForKey:@"minAppVersion"])
            assetInfo.minAppVersion = [dict objectForKey:@"minAppVersion"];
        if ([dict objectForKey:@"packageUrl"])
            assetInfo.packageUrl = [dict objectForKey:@"packageUrl"];
        if ([dict objectForKey:@"previewVideoUrl"])
            assetInfo.previewVideoUrl = [dict objectForKey:@"previewVideoUrl"];
        if ([dict objectForKey:@"rate"])
            assetInfo.rate = [[dict objectForKey:@"rate"] integerValue];
        if ([dict objectForKey:@"packageSize"])
            assetInfo.packageSize = [[dict objectForKey:@"packageSize"] intValue];
        if ([dict objectForKey:@"ratioFlag"])
            assetInfo.ratioFlag = [[dict objectForKey:@"ratioFlag"] integerValue];
        if ([dict objectForKey:@"sizeLevel"])
            assetInfo.sizeLevel = [[dict objectForKey:@"sizeLevel"] integerValue];
        if ([dict objectForKey:@"supportedAspectRatio"])
            assetInfo.supportedAspectRatio = [[dict objectForKey:@"supportedAspectRatio"] integerValue];
            assetInfo.remoteAspectRatio = assetInfo.supportedAspectRatio;
        if ([dict objectForKey:@"type"])
            assetInfo.type = [[dict objectForKey:@"type"] integerValue];
        if ([dict objectForKey:@"version"])
            assetInfo.version = [[dict objectForKey:@"version"] intValue];
            assetInfo.remoteVersion = assetInfo.version;
        if ([dict objectForKey:@"isPostPackage"])
            assetInfo.isPostPackage = [[dict objectForKey:@"isPostPackage"] boolValue];
        

        if ([dict objectForKey:@"tags"])
            assetInfo.tags = [dict objectForKey:@"tags"];
        if ([dict objectForKey:@"coverUrl2"])
            assetInfo.coverUrl2 = [NSURL URLWithString:[[dict objectForKey:@"coverUrl2"] stringByReplacingOccurrencesOfString:NV_DOMAIN_URL withString:NV_CDN_URL]];
        if ([dict objectForKey:@"supportedAspectRatio"]){
                     assetInfo.aspectRatio = [[dict objectForKey:@"supportedAspectRatio"] intValue];
            assetInfo.remoteAspectRatio = assetInfo.aspectRatio;
        }
        
        if ([dict objectForKey:@"name"])
            assetInfo.displayName = [dict objectForKey:@"name"];
        if ([dict objectForKey:@"idx"])
            assetInfo.idx = [[dict objectForKey:@"idx"] intValue];
        if ([dict objectForKey:@"isAdjusted"])
            assetInfo.isAdjusted = [[dict objectForKey:@"isAdjusted"] boolValue];
        
        if ([dict objectForKey:@"suitablePlatform"]){
            assetInfo.suitablePlatform = [[dict objectForKey:@"suitablePlatform"] intValue];
        }
        
        if(assetInfo.isAdjusted) {
            NSLog(@"=======%@",assetInfo.displayNamezhCN);
        }
        
        NvAsset *asset = [self findAsset:assetInfo.uuid];
        if (asset == nil) {
            [assets addObject:assetInfo];
        } else {
            asset.category = assetInfo.category;
            asset.kind = assetInfo.kind;
            asset.displayName = assetInfo.displayName;
            asset.displayNameZhCn = assetInfo.displayNameZhCn;
            asset.displayNamezhCN = assetInfo.displayNamezhCN;
            asset.coverUrl = assetInfo.coverUrl;
            asset.coverUrl2 = assetInfo.coverUrl2;
            asset.remoteAspectRatio = assetInfo.aspectRatio;
            asset.packageSize = assetInfo.packageSize;
            asset.remoteVersion = assetInfo.remoteVersion;
            asset.idx = assetInfo.idx;
            asset.packageUrl = assetInfo.packageUrl;
            asset.isAdjusted = assetInfo.isAdjusted;
            asset.zipUrl = assetInfo.zipUrl;
            
            if (asset.localDirPath.length > 0){
                int tempVersion = [self.streamingContext.assetPackageManager getAssetPackageVersionFromAssetPackageFilePath:asset.localDirPath];
                NSString *fileName = [asset.localDirPath stringByDeletingPathExtension];
                NSString *suffix    = [asset.localDirPath pathExtension];
                
                NSString *suffix_1 = [fileName pathExtension];
                if (tempVersion < asset.version && asset.version > 0){
                    if (suffix_1.length > 0){
                        NSString *fileName_1 = [fileName stringByDeletingPathExtension];
                        asset.localDirPath = [fileName_1 stringByAppendingFormat:@".%@.%@",@(asset.version),suffix];
                    }else{
                        asset.localDirPath = [fileName stringByAppendingFormat:@".%@.%@",@(asset.version),suffix];
                    }
                }
            }
        }
    }
    [self.assetDict setObject:assets forKey:[NSString stringWithFormat:@"%d", assetType]];
}

- (void)addRemoteAssetOrderedList:(NSArray *)resultsArray assetType:(AssetType)assetType {
    NSMutableArray *assets = self.remoteAssetsOrderedList[[NSString stringWithFormat:@"%d", assetType]];
    if (assets == nil) {
        assets = NSMutableArray.new;
    }
    for (NSDictionary *dict in resultsArray) {
        NSString *uuid = [dict objectForKey:@"id"];
        if (![self isUuidExistInRemoteOrderedList:assetType uuid:uuid]) {
            [assets addObject:uuid];
        }
    }
    [self.remoteAssetsOrderedList setObject:assets forKey:[NSString stringWithFormat:@"%d", assetType]];
}

- (AssetType)getCaptionType:(int)categoryId {
    AssetType type;
    switch (categoryId) {
        case 1:
        {
            type = ASSET_CAPTION_RENDERER;
        }
            
            break;
            
        case 2:
        {
            type = ASSET_CAPTION_CONTEXT;
        }
            
            break;
            
        case 3:
        {
            type = ASSET_CAPTION_INANIMATION;
        }
            
            break;
            
        case 4:
        {
            type = ASSET_CAPTION_OUTANIMATION;
        }
            
            break;
            
        case 5:
        {
            type = ASSET_CAPTION_ANIMATION;
        }

            break;
            
        default:
        {
            type = ASSET_CAPTION_STYLE;
        }
            break;
    }
    return type;
}

- (BOOL)isUuidExistInRemoteOrderedList:(AssetType)assetType uuid:(NSString *)uuid {
    NSMutableArray *assets = self.remoteAssetsOrderedList[[NSString stringWithFormat:@"%d", assetType]];
    if (assets == nil)
        return NO;
    
    for (NSString *assetId in assets) {
        if ([uuid isEqualToString:assetId])
            return YES;
    }
    return NO;
}

#pragma mark NvHttpRequestDelegate

- (void)onGetAssetListSuccess:(NSArray *)resultsArray assetType:(AssetType)assetType hasNext:(BOOL)hasNext {
    [self addRemoteAssetData:resultsArray assetType:assetType];
    [self addRemoteAssetOrderedList:resultsArray assetType:assetType];
    
    if (self.hashTable && self.hashTable.allObjects.count > 0) {
        for (id delegateVC in self.hashTable.allObjects) {
            if (delegateVC && [delegateVC respondsToSelector:@selector(onRemoteAssetsChanged:)]) {
                [delegateVC onRemoteAssetsChanged:hasNext];
            }
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(onRemoteAssetsChanged:)]) {
            [self.delegate onRemoteAssetsChanged:hasNext];
        }
    }
}

- (void)onGetAssetListFailed:(NSError *)error assetType:(AssetType) assetType {
    if (self.hashTable && self.hashTable.allObjects.count > 0) {
        for (id delegateVC in self.hashTable.allObjects) {
            if (delegateVC && [delegateVC respondsToSelector:@selector(onGetRemoteAssetsFailed)]) {
                [delegateVC onGetRemoteAssetsFailed];
            }
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(onGetRemoteAssetsFailed)]) {
            [self.delegate onGetRemoteAssetsFailed];
        }
    }
}

- (void)onGetAssetListSuccess:(NSArray *)resultsArray assetType:(AssetType)assetType keyword:(NSString *)keyword hasNext:(BOOL)hasNext {
    if (!_keywordAsset) {
        _keywordAsset = [NSMutableArray array];
    }
    [self.keywordAsset removeAllObjects];
    for (NSDictionary *dict in resultsArray) {
        NSString *uuid = [dict objectForKey:@"id"];
        [self.keywordAsset addObject:uuid];
    }
    [self addRemoteAssetData:resultsArray assetType:assetType];
    [self addRemoteAssetOrderedList:resultsArray assetType:assetType];
    
    if (self.hashTable && self.hashTable.allObjects.count > 0) {
        for (id delegateVC in self.hashTable.allObjects) {
            if (delegateVC && [delegateVC respondsToSelector:@selector(onRemoteAssetsChanged:)]) {
                [delegateVC onRemoteAssetsChanged:hasNext];
            }
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(onRemoteAssetsChanged:)]) {
            [self.delegate onRemoteAssetsChanged:hasNext];
        }
    }
}

- (void)onGetAssetListFailed:(NSError *)error assetType:(AssetType)assetType keyword:(NSString *)keyword {
    if (self.hashTable && self.hashTable.allObjects.count > 0) {
        for (id delegateVC in self.hashTable.allObjects) {
            if (delegateVC && [delegateVC respondsToSelector:@selector(onGetRemoteAssetsFailed)]) {
                [delegateVC onGetRemoteAssetsFailed];
            }
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(onGetRemoteAssetsFailed)]) {
            [self.delegate onGetRemoteAssetsFailed];
        }
    }
}

- (void)onCheckNetworkState:(BOOL)isNetAvailable {
    if ([self.delegate respondsToSelector:@selector(onCheckNetworkState:)]){
        [self.delegate onCheckNetworkState:isNetAvailable];
    }
}

- (void)onDonwloadAssetProgress:(int32_t)progress downloadID:(NSString*)downloadID{
    if (self.hashTable && self.hashTable.allObjects.count > 0) {
        for (id delegateVC in self.hashTable.allObjects) {
            if (delegateVC && [delegateVC respondsToSelector:@selector(onDownloadAssetProgress:progress:)]) {
                [delegateVC onDownloadAssetProgress:downloadID progress:progress];
            }
        }
    }
    if ([self.delegate respondsToSelector:@selector(onDownloadAssetProgress:progress:)]) {
        [self.delegate onDownloadAssetProgress:downloadID progress:progress];
    }
}
- (void)onDonwloadAssetSuccess:(BOOL)isSuccess downloadFilePath:(NSString*)downloadFilePath downloadID:(NSString*)downloadID{
    _downloadingAssetsCounter--;
    NvAsset *asset = [self findAsset:downloadID];
    asset.downloadProgress = 1;
    asset.downloadStatus = DownloadStatusDecompressing;
    downloadFilePath = [downloadFilePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    asset.localDirPath = downloadFilePath;
    NSString *unzipDir = downloadFilePath.stringByDeletingPathExtension;
    BOOL unzipSuccess = [SSZipArchive unzipFileAtPath:downloadFilePath toDestination:unzipDir];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:downloadFilePath error:nil];
    if (!unzipSuccess) {
        if ([self.delegate respondsToSelector:@selector(onDonwloadAssetFailed:)]) {
            [self.delegate onDonwloadAssetFailed:downloadID];
        }
        return;
    }
    NSString *assetDir = downloadFilePath.stringByDeletingLastPathComponent;
    NSString *infoPath = [unzipDir stringByAppendingPathComponent:@"info.json"];
    if ([fm fileExistsAtPath:infoPath]) {
        NSData *data = [NSData dataWithContentsOfFile:infoPath];
        NSDictionary *infoDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:nil];
        NSString *packageFileName = infoDic[@"packageFileName"];
        NSString *licenseFileName = [((NSString *)infoDic[@"uuid"]) stringByAppendingString:@".lic"];
        asset.packagePath = [assetDir stringByAppendingPathComponent:packageFileName];
        NSString *unzipPackagePath = [unzipDir stringByAppendingPathComponent:packageFileName];
        [fm moveItemAtPath:unzipPackagePath toPath:asset.packagePath error:nil];
        asset.licensePath = [assetDir stringByAppendingPathComponent:licenseFileName];
        NSString *unzipLicensePath = [unzipDir stringByAppendingPathComponent:licenseFileName];
        [fm moveItemAtPath:unzipLicensePath toPath:asset.licensePath error:nil];
        [fm removeItemAtPath:unzipDir error:nil];
    } else {
        if ([self.delegate respondsToSelector:@selector(onDonwloadAssetFailed:)]) {
            [self.delegate onDonwloadAssetFailed:downloadID];
        }
        return;
    }
    
    [self installAsset:asset];
    
    if (self.hashTable && self.hashTable.allObjects.count > 0) {
        for (id delegateVC in self.hashTable.allObjects) {
            if (delegateVC && [delegateVC respondsToSelector:@selector(onDonwloadAssetSuccess:withPath:)]) {
                [delegateVC onDonwloadAssetSuccess:downloadID withPath:downloadFilePath];
            }
        }
    }
    if ([self.delegate respondsToSelector:@selector(onDonwloadAssetSuccess:)]) {
        [self.delegate onDonwloadAssetSuccess:downloadID];
    }
    [self setAssetInfoToUserDefaults:asset.assetType];
    [self downloadPendingAsset];
}
- (void)onDonwloadAssetFailed:(NSError *) error downloadFilePath:(NSString*)downloadFilePath downloadID:(NSString*)downloadID{
    _downloadingAssetsCounter--;
    [self cancelAssetDownload:downloadID];
    [self downloadPendingAsset];
    if ([self.delegate respondsToSelector:@selector(onDonwloadAssetFailed:)]) {
        [self.delegate onDonwloadAssetFailed:downloadID];
    }
    
    if (self.hashTable && self.hashTable.allObjects.count > 0) {
        for (id delegateVC in self.hashTable.allObjects) {
            if (delegateVC && [delegateVC respondsToSelector:@selector(onDonwloadAssetFailed:)]) {
                [delegateVC onDonwloadAssetFailed:downloadID];
            }
        }
    }
}

- (void)didFinishAssetPackageInstallation:(NSString *)assetPackageId filePath:(NSString *)assetPackageFilePath type:(NvsAssetPackageType)assetPackageType error:(NvsAssetPackageManagerError)error {
    if (error == NvsAssetPackageManagerError_NoError || error == NvsAssetPackageManagerError_AlreadyInstalled) {
        NvAsset *asset = [self findAsset:assetPackageId];
        asset.downloadStatus = DownloadStatusFinished;
        asset.version = [self.streamingContext.assetPackageManager getAssetPackageVersion:assetPackageId type:assetPackageType];
        asset.aspectRatio = [self.streamingContext.assetPackageManager getAssetPackageSupportedAspectRatio:asset.uuid type:[asset getPackageType]];
    } else {
        NvAsset *asset = [self findAsset:assetPackageId];
        asset.downloadStatus = DownloadStatusDecompressingFailed;
    }
    if ([self.delegate respondsToSelector:@selector(onFinishAssetPackageInstallation:)]) {
        [self.delegate onFinishAssetPackageInstallation:assetPackageId];
    }
}

- (void)didFinishAssetPackageUpgrading:(NSString *)assetPackageId filePath:(NSString *)assetPackageFilePath type:(NvsAssetPackageType)assetPackageType error:(NvsAssetPackageManagerError)error {
    if (error == NvsAssetPackageManagerError_NoError || error == NvsAssetPackageManagerError_AlreadyInstalled) {
        NvAsset *asset = [self findAsset:assetPackageId];
        asset.downloadStatus = DownloadStatusFinished;
        asset.version = [self.streamingContext.assetPackageManager getAssetPackageVersion:assetPackageId type:assetPackageType];
        asset.aspectRatio = [self.streamingContext.assetPackageManager getAssetPackageSupportedAspectRatio:asset.uuid type:[asset getPackageType]];
    } else {
        NvAsset *asset = [self findAsset:assetPackageId];
        asset.downloadStatus = DownloadStatusDecompressingFailed;
    }
    if ([self.delegate respondsToSelector:@selector(onFinishAssetPackageUpgrading:)]) {
        [self.delegate onFinishAssetPackageUpgrading:assetPackageId];
    }
}

- (NvsStreamingContext *)streamingContext {
    return [NvsStreamingContext sharedInstance];
}

@end

