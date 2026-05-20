//
//  NvFetchAlbum.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvAlbumItem.h"

typedef NS_ENUM(NSUInteger, NvAlbumAssetType) {
    NvAlbumAssetAll,
    NvAlbumAssetAllVideo,
    NvAlbumAssetAllImage,
};

typedef NS_ENUM(NSUInteger, NvAlbumFetchType) {
    NvAlbumFetchTypeAll = 0,
    NvAlbumFetchTypeVideo,
    NvAlbumFetchTypeImage,
    NvAlbumFetchTypeLivePhoto,
};

@interface NvFetchAlbum : NSObject

- (void)loadAssetWithType:(NvAlbumAssetType)type complete:(void(^)(NSMutableArray <NvAlbumItem *>*dataSource))complete;
- (void)loadAssetcomplete:(void(^)(NSMutableArray <NvAlbumItem *>*dataSource, NSMutableArray <NvAlbumItem *>*videoDataSource, NSMutableArray <NvAlbumItem *>*imageDataSource))complete;

- (void)fetchAlbum:(NvAlbumFetchType)type assetCollection:(PHAssetCollection *)assetCollection complete:(void(^)(NvAlbumFetchType type, NSMutableArray <PHAsset *>*fetchedArray))complete;

- (void)fetchAlbumCollections:(void(^)(NSMutableArray<PHAssetCollection *> *albumCollections))complete;
@end
