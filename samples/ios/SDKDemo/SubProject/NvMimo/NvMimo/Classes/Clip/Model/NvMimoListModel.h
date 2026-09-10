//
//  NvMimoListModel.h
//  NvMimoDemo
//
//  Created by MS on 2020/7/28.
//  Copyright © 2020 MS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvThemeModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvMimoListModel : NSObject
@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, copy) NSString *assetId;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *packageUrl;
@property (nonatomic, strong) NvThemeModel *packageInfo;
/// local path, network resource This field is empty
@property (nonatomic, copy) NSString *localPath;  //本地路径，网络资源的话此字段为空
@property (nonatomic, assign) BOOL isLocalAsset;
@property (nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
