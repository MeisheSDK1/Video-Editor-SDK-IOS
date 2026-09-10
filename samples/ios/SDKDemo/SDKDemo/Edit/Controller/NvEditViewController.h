//
//  NvEditViewController.h
//  SDKDemo
//
//  Created by meishe01 on 2018/5/25.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import "NvAlbumItem.h"

@class NvMusicInfoModel;
@interface NvEditViewController : NvBaseViewController

@property (nonatomic, strong) NSMutableArray <NvAlbumAsset *> *selectAssets;
@property (nonatomic, assign) NvEditMode editMode;
@property (nonatomic, strong) NSMutableArray *selectPath;
@property (nonatomic, strong) NSMutableArray *urlPath;
@property (nonatomic, strong) NvMusicInfoModel *musicInfo;
@property (nonatomic, assign) BOOL isFromAlbum;
@end
