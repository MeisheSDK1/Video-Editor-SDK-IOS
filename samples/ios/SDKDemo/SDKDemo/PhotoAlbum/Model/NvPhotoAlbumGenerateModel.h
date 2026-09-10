//
//  NvPhotoAlbumGenerateModel.h
//  SDKDemo
//
//  Created by MS on 2019/9/25.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvPhotoAlbumGenerateModel : NSObject
@property(nonatomic, strong) NSString *filePath;
@property(nonatomic, strong) NSString *licPath;
@property(nonatomic, strong) NSString *basePath;
@property(nonatomic, strong) NSMutableArray *replaceFiles;

@end

NS_ASSUME_NONNULL_END
