//
//  StickerItem.h
//  Caption
//
//  Created by meishe01 on 2017/8/23.
//  Copyright © 2017年 NewAuto video team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsTimelineVideoFx.h"
#import <NvSDKCommon/NvAsset.h>
#import "NvBaseModel.h"

//typedef NS_ENUM (NSInteger,DownloadState){
//    NODownload,
//    DownloadError,
//    Downloading,
//    Finish,
//    Update,
//};
@interface NvAssetCellModel : NSObject

@property (strong, nonatomic) NSString *builtinName;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *package;
@property (strong, nonatomic) NSString *cover;
@property (strong, nonatomic) NSString *coverHighlight;
@property (assign, nonatomic) BOOL selected;
@property (assign, nonatomic) BOOL longPressed;
@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *draw;
@property (assign, nonatomic) DownloadState state;
@property (strong, nonatomic) NSString * packID;
@property (copy, nonatomic) NSString * packPath;
@property (assign, nonatomic) AssetType assetType;
///自定义贴纸模板UUID
///User-defined sticker template UUID
@property (strong, nonatomic) NSString *templateId;
@property (assign, nonatomic) int categoryId;
///是否播放或者暂停
///Whether to play or pause
@property (assign, nonatomic) BOOL isPlay;
@property (assign, nonatomic) int idx;
@property (assign, nonatomic) int progress;
///自定义贴纸gif图的路径，用来显示封面用
///Custom sticker gif map path, used to show the cover with
@property (strong, nonatomic) NSString *covergif;
@end


