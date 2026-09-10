//
//  NvPhotoAlbumModel.h
//  SDKDemo
//
//  Created by MS on 2019/9/26.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NvPhotoAlbumInfoModel : NSObject <NSCopying>
@property (nonatomic, copy) NSString *photosAlbumName;
@property (nonatomic, copy) NSString *photosAlbumTips;
@property (nonatomic, copy) NSString *photosAlbumCoverImage;
@property (nonatomic, copy) NSString *photosAlbumCoverVideo;
@property (nonatomic, copy) NSString *photosAlbumReplaceName;
@property (nonatomic, copy) NSString *photosAlbumReplaceMin;
@property (nonatomic, copy) NSString *photosAlbumReplaceMax;
@property (nonatomic, copy) NSString *photosAlbumWidth;
@property (nonatomic, copy) NSString *photosAlbumHeight;
@property (nonatomic, copy) NSString *videoFileName;
@property (nonatomic, copy) NSString *audioFileName;
@property (nonatomic, copy) NSString *xmlFileName;
@property (nonatomic, copy) NSString *ratio;
@end

@interface NvPhotoAlbumModel : NSObject <NSCopying>
@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, copy) NSString *assetId;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *packageUrl;
@property (nonatomic, copy) NSString *packageInfo;
///本地路径，网络资源的话此字段为空
///Local path, network resource this field is empty
@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, assign) BOOL isLocalAsset;
@end

NS_ASSUME_NONNULL_END
