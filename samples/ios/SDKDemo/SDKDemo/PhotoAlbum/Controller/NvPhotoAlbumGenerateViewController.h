//
//  NvPhotoAlbumGenerateViewController.h
//  SDKDemo
//
//  Created by MS on 2019/9/24.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import "NvPhotoAlbumGenerateModel.h"
#import "NvPhotoAlbumModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvPhotoAlbumGenerateViewController : NvBaseViewController

//选中图片id
//the selected photos
@property(nonatomic, strong) NSMutableArray *files;

//模版本地文件路径（lastComponent 是uuid）
//the template path
@property(nonatomic, copy) NSString *localPath;

@end

NS_ASSUME_NONNULL_END
