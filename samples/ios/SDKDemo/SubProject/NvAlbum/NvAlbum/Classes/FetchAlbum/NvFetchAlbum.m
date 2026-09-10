//
//  NvFetchAlbum.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvFetchAlbum.h"
#import "NvAlbumItem.h"
#import "NvAlbumUtils.h"

@import Photos;

@interface NvFetchAlbum ()

@property (nonatomic, strong) NSMutableArray<NvAlbumItem *> *assetDataSource;
@property (nonatomic, strong) NSMutableArray<NvAlbumItem *> *imageDataSource;
@property (nonatomic, strong) NSMutableArray<NvAlbumItem *> *videoDataSource;
@property (nonatomic, strong) NSMutableArray<NvAlbumItem *> *liveDataSource;

@end

@implementation NvFetchAlbum

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

// MARK: 查询PHAsset数据
// Query the PHAsset data
- (void)loadAssetWithType:(NvAlbumAssetType)type complete:(void(^)(NSMutableArray <NvAlbumItem *>*dataSource))complete {
    // 获得相机时刻
    // Get the camera moment
    self.assetDataSource = [NSMutableArray array];
    __weak typeof(self)weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchMomentsWithOptions:nil];
            for (int i = (int)collections.count-1; i>=0; i--) {
                PHAssetCollection *collectionList = collections[i];
                NvAlbumItem *item = [NvAlbumItem new];
                item.startDate = collectionList.startDate;
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
                PHFetchResult<PHAsset *> *phAsset = [PHAsset fetchAssetsInAssetCollection:collectionList options:options];
                NSMutableArray *assetArray = [NSMutableArray array];
                [phAsset enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (type == NvAlbumAssetAll) {
                        NvAlbumAsset *albumAsset = [NvAlbumAsset new];
                        albumAsset.asset = obj;
                        [assetArray insertObject:albumAsset atIndex:0];
                    } else if (type == NvAlbumAssetAllVideo) {
                        if (obj.mediaType == PHAssetMediaTypeVideo) {
                            NvAlbumAsset *albumAsset = [NvAlbumAsset new];
                            albumAsset.asset = obj;
                            [assetArray insertObject:albumAsset atIndex:0];
                        }
                    } else if (type == NvAlbumAssetAllImage) {
                        if (obj.mediaType == PHAssetMediaTypeImage) {
                            NvAlbumAsset *albumAsset = [NvAlbumAsset new];
                            albumAsset.asset = obj;
                            [assetArray insertObject:albumAsset atIndex:0];
                        }
                    }
                    
                }];
                
                item.collectionList = assetArray;
                //此时如果数组不大于0证明此项section里没有数据(可能在图片模式下和视频模式下没有数据)
                //If the array is not greater than 0, then there is no data in this section (maybe no data in image mode and video mode).
                if (item.collectionList.count > 0) {
                    [weakSelf.assetDataSource addObject:item];
                }
            }
            complete(weakSelf.assetDataSource);
        }
    }];
}

- (void)loadAssetcomplete:(void(^)(NSMutableArray <NvAlbumItem *>*dataSource, NSMutableArray <NvAlbumItem *>*videoDataSource, NSMutableArray <NvAlbumItem *>*imageDataSource))complete {
    // 获得相机时刻
    // Get the camera moment
    self.assetDataSource = [NSMutableArray array];
    self.imageDataSource = [NSMutableArray array];
    self.videoDataSource = [NSMutableArray array];
    __weak typeof(self)weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchMomentsWithOptions:nil];
            for (int i = (int)collections.count-1; i>=0; i--) {
                PHAssetCollection *collectionList = collections[i];
                
                NvAlbumItem *allItem = [NvAlbumItem new];
                NvAlbumItem *videoItem = [NvAlbumItem new];
                NvAlbumItem *imageItem = [NvAlbumItem new];
                allItem.startDate = collectionList.startDate;
                videoItem.startDate = collectionList.startDate;
                imageItem.startDate = collectionList.startDate;
                
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                PHFetchResult<PHAsset *> *phAsset = [PHAsset fetchAssetsInAssetCollection:collectionList options:options];
                
                NSMutableArray *assetArray = [NSMutableArray array];
                NSMutableArray *videoArray = [NSMutableArray array];
                NSMutableArray *imageArray = [NSMutableArray array];
                
                [phAsset enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.localIdentifier) {
                        if (obj.mediaType == PHAssetMediaTypeVideo) {
                            NvAlbumAsset *albumAsset = [NvAlbumAsset new];
                            albumAsset.asset = obj;
                            [assetArray addObject:albumAsset];
                            [videoArray addObject:albumAsset];
                        } else if (obj.mediaType == PHAssetMediaTypeImage) {
                            NvAlbumAsset *albumAsset = [NvAlbumAsset new];
                            albumAsset.asset = obj;
                            [assetArray addObject:albumAsset];
                            [imageArray addObject:albumAsset];
                        }
                    }
                }];
                
                allItem.collectionList = assetArray;
                //此时如果数组不大于0证明此项section里没有数据(可能在图片模式下和视频模式下没有数据)
                // If the array is not greater than 0, then there is no data in this section (maybe no data in image mode and video mode).
                if (allItem.collectionList.count > 0) {
                    [weakSelf.assetDataSource addObject:allItem];
                }
                
                videoItem.collectionList = videoArray;
                //此时如果数组不大于0证明此项section里没有数据(可能在图片模式下和视频模式下没有数据)
                // If the array is not greater than 0, then there is no data in this section (maybe no data in image mode and video mode).
                if (videoItem.collectionList.count > 0) {
                    [weakSelf.videoDataSource addObject:videoItem];
                }
                
                imageItem.collectionList = imageArray;
                //此时如果数组不大于0证明此项section里没有数据(可能在图片模式下和视频模式下没有数据)
                // If the array is not greater than 0, then there is no data in this section (maybe no data in image mode and video mode).
                if (imageItem.collectionList.count > 0) {
                    [weakSelf.imageDataSource addObject:imageItem];
                }
            }
            complete(weakSelf.assetDataSource,weakSelf.videoDataSource,weakSelf.imageDataSource);
        }
    }];
}

- (void)fetchAlbumComplete:(void(^)(NSMutableArray <NvAlbumItem *>*dataSource, NSMutableArray <NvAlbumItem *>*videoDataSource, NSMutableArray <NvAlbumItem *>*imageDataSource, NSMutableArray <NvAlbumItem *>*liveDataSource))complete {
    __weak typeof(self)weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHFetchResult<PHAsset *> *phAsset = [PHAsset fetchAssetsWithOptions:options];
            
            weakSelf.assetDataSource = [NSMutableArray array];
            weakSelf.imageDataSource = [NSMutableArray array];
            weakSelf.videoDataSource = [NSMutableArray array];
            weakSelf.liveDataSource = [NSMutableArray array];
            
            __block NSMutableArray *assetArray = [NSMutableArray array];
            __block NSMutableArray *videoArray = [NSMutableArray array];
            __block NSMutableArray *imageArray = [NSMutableArray array];
            __block NSMutableArray *liveArray = [NSMutableArray array];
            __block PHAsset *objpre = nil;
            
            __block NvAlbumItem *allItem = [NvAlbumItem new];
            __block NvAlbumItem *videoItem = [NvAlbumItem new];
            __block NvAlbumItem *imageItem = [NvAlbumItem new];
            __block NvAlbumItem *liveItem = [NvAlbumItem new];
            
            [phAsset enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BOOL isEqual = [[weakSelf dateToString:objpre.creationDate] isEqualToString:[weakSelf dateToString:obj.creationDate]];
                if (!isEqual) {
                    allItem.collectionList = assetArray;
                    //此时如果数组不大于0证明此项section里没有数据(可能在图片模式下和视频模式下没有数据)
                    //If the array is not greater than 0, then there is no data in this section (maybe no data in image mode and video mode).
                    if (allItem.collectionList.count > 0) {
                        [weakSelf.assetDataSource addObject:allItem];
                    }
                    
                    videoItem.collectionList = videoArray;
                    //此时如果数组不大于0证明此项section里没有数据(可能在图片模式下和视频模式下没有数据)
                    //If the array is not greater than 0, then there is no data in this section (maybe no data in image mode and video mode).
                    if (videoItem.collectionList.count > 0) {
                        [weakSelf.videoDataSource addObject:videoItem];
                    }
                    
                    imageItem.collectionList = imageArray;
                    //此时如果数组不大于0证明此项section里没有数据(可能在图片模式下和视频模式下没有数据)
                    //If the array is not greater than 0, then there is no data in this section (maybe no data in image mode and video mode).
                    if (imageItem.collectionList.count > 0) {
                        [weakSelf.imageDataSource addObject:imageItem];
                    }
                    
                    liveItem.collectionList = liveArray;
                    //此时如果数组不大于0证明此项section里没有数据(可能在图片模式下和视频模式下没有数据)
                    //If the array is not greater than 0, then there is no data in this section (maybe no data in image mode and video mode).
                    if (liveItem.collectionList.count > 0) {
                        [weakSelf.liveDataSource addObject:liveItem];
                    }
                    
                    objpre = obj;
                    assetArray = [NSMutableArray array];
                    videoArray = [NSMutableArray array];
                    imageArray = [NSMutableArray array];
                    liveArray = [NSMutableArray array];
                    
                    allItem = [NvAlbumItem new];
                    videoItem = [NvAlbumItem new];
                    imageItem = [NvAlbumItem new];
                    liveItem = [NvAlbumItem new];
                    
                    allItem.startDate = objpre.creationDate;
                    videoItem.startDate = objpre.creationDate;
                    imageItem.startDate = objpre.creationDate;
                    liveItem.startDate = objpre.creationDate;
                }
                
                if (obj.mediaType == PHAssetMediaTypeVideo) {
                    NvAlbumAsset *albumAsset = [NvAlbumAsset new];
                    albumAsset.asset = obj;
                    [assetArray addObject:albumAsset];
                    [videoArray addObject:albumAsset];
                }  else if (obj.mediaType == PHAssetMediaTypeImage) {
                    NvAlbumAsset *albumAsset = [NvAlbumAsset new];
                    albumAsset.asset = obj;
                    [assetArray addObject:albumAsset];
                    if ([NvAlbumUtils checkIsLivePhoto:obj] == YES) {
                        albumAsset.isLivePhoto = YES;
                        [liveArray addObject:albumAsset];
                    } else {
                        [imageArray addObject:albumAsset];
                    }
                }
            }];
            
            allItem.collectionList = assetArray;
            //此时如果数组不大于0证明此项section里没有数据(可能在图片模式下和视频模式下没有数据)
            // If the array is not greater than 0, then there is no data in this section (maybe no data in image mode and video mode).
            if (allItem.collectionList.count > 0) {
                [weakSelf.assetDataSource addObject:allItem];
            }
            
            videoItem.collectionList = videoArray;
            //此时如果数组不大于0证明此项section里没有数据(可能在图片模式下和视频模式下没有数据)
            // If the array is not greater than 0, then there is no data in this section (maybe no data in image mode and video mode).
            if (videoItem.collectionList.count > 0) {
                [weakSelf.videoDataSource addObject:videoItem];
            }
            
            imageItem.collectionList = imageArray;
            //此时如果数组不大于0证明此项section里没有数据(可能在图片模式下和视频模式下没有数据)
            // If the array is not greater than 0, then there is no data in this section (maybe no data in image mode and video mode).
            if (imageItem.collectionList.count > 0) {
                [weakSelf.imageDataSource addObject:imageItem];
            }
            
            liveItem.collectionList = liveArray;
            if (liveItem.collectionList.count > 0) {
                [weakSelf.liveDataSource addObject:liveItem];
            }
        }
        complete(weakSelf.assetDataSource,weakSelf.videoDataSource,weakSelf.imageDataSource,weakSelf.liveDataSource);
    }];
    
}

- (void)fetchAlbum:(NvAlbumFetchType)type assetCollection:(PHAssetCollection *)assetCollection complete:(void(^)(NvAlbumFetchType type, NSMutableArray <PHAsset *>*fetchedArray))complete {
    __weak typeof(self)weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            weakSelf.assetDataSource = [NSMutableArray array];
            if (type == NvAlbumFetchTypeImage) {
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d AND NOT ((mediaSubtypes & %d) != 0)",PHAssetMediaTypeImage,PHAssetMediaSubtypePhotoLive];
            }
            else if (type == NvAlbumFetchTypeLivePhoto) {
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d AND (mediaSubtypes & %d) != 0", PHAssetMediaTypeImage,PHAssetMediaSubtypePhotoLive];
            }
            else if (type == NvAlbumFetchTypeVideo) {
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeVideo];
            }
            PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            complete(type,fetchResult);
        }
    }];
}

- (NSString *)dateToString:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateString = [dateFormatter stringFromDate:date];
    return currentDateString;
}

- (void)fetchAlbumCollections:(void(^)(NSMutableArray<PHAssetCollection *> *albumCollections))complete {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            PHFetchResult<PHAssetCollection *> *smartFthResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
            PHFetchResult<PHAssetCollection *> *userFthResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
            NSMutableArray *fetchResult = [NSMutableArray array];
            [smartFthResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:obj options:nil];
                if(result.count > 0) {
                    [fetchResult addObject:obj];
                }
                
            }];
            [userFthResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:obj options:nil];
                if(result.count > 0) {
                    [fetchResult addObject:obj];
                }
            }];
            complete(fetchResult);
        }
    }];
}
@end
