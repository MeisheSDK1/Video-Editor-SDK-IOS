//
//  NvPhotoAlbumHelper.h
//  NvPhotoAlbumHelper
//
//  Created by 董凌晓 on 2019/9/27.
//  Copyright © 2019 董凌晓. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NvStreamingSdkCore/NvsStreamingContext.h>
#import <NvStreamingSdkCore/NvsTimeline.h>
@interface NvPhotoAlbumHelper : NSObject

/**
自定义context
@param streamingContext context参数
*/
+ (void)setStreamingContext:(NvsStreamingContext *)streamingContext;

/**
 创建照片影集timeline
 @param filePath 特效文件路径
 @param licFile 授权文件路径
 @param resourceDir 资源包路径
 @param replaceFiles 图片路径数组(注：相册图片路径格式为PHAsset:// + 相应PHAsset 的localIdentifier)
 @return timeline
 */
+ (NvsTimeline *)CreatePhotoAlbumTimelineWithFilePath:(NSString *)filePath
                                              licFile:(NSString *)licFile
                                          resourceDir:(NSString *)resourceDir
                                         replaceFiles:(NSArray <NSString *>*)replaceFiles;

/**
创建照片影集timeline
@param filePath 特效文件路径
@param licFile 授权文件路径
@param resourceDir 资源包路径
@param replaceFiles 图片路径数组(注：相册图片路径格式为PHAsset:// + 相应PHAsset 的localIdentifier)
@param captions 字幕内容
@return timeline
*/
+ (NvsTimeline *)CreatePhotoAlbumTimelineWithFilePath:(NSString *)filePath
                                              licFile:(NSString *)licFile
                                          resourceDir:(NSString *)resourceDir
                                         replaceFiles:(NSArray <NSString *>*)replaceFiles
                                             captions:(NSArray <NSString *>*)captions;

/**
创建照片影集timeline
@param filePath 特效文件路径
@param licFile 授权文件路径
@param resourceDir 资源包路径
@param replaceFiles 图片路径数组(注：相册图片路径格式为PHAsset:// + 相应PHAsset 的localIdentifier)
@param captions 字幕内容
@param ignore 是否忽略最大图片数量限制
@return timeline
*/
+ (NvsTimeline *)CreatePhotoAlbumTimelineWithFilePath:(NSString *)filePath
                                              licFile:(NSString *)licFile
                                          resourceDir:(NSString *)resourceDir
                                         replaceFiles:(NSArray <NSString *>*)replaceFiles
                                             captions:(NSArray <NSString *>*)captions
                            ignoreMaxPhotoNumberLimit:(BOOL)ignore;

/**
创建忽略最大图片数量限制并且音频轨道只有一个clip的照片影集timeline
@param filePath 特效文件路径
@param licFile 授权文件路径
@param resourceDir 资源包路径
@param replaceFiles 图片路径数组(注：相册图片路径格式为PHAsset:// + 相应PHAsset 的localIdentifier)
@param captions 字幕内容
@param haveTransition 配属信息（albumExtension.json 文件）中是否包含转场
@return timeline
*/
+ (NvsTimeline *)CreateSingleMusicIgnoreMaxPhotoNumberLimitTimelineWithFilePath:(NSString *)filePath
                                              licFile:(NSString *)licFile
                                          resourceDir:(NSString *)resourceDir
                                         replaceFiles:(NSArray <NSString *>*)replaceFiles
                                                                       captions:(NSArray <NSString *>*)captions
                                         haveTransition:(BOOL)haveTransition;

/**
创建填充模式的照片影集timeline
@param filePath 特效文件路径
@param licFile 授权文件路径
@param resourceDir 资源包路径
@param replaceFiles 图片路径数组(注：相册图片路径格式为PHAsset:// + 相应PHAsset 的localIdentifier)
@param cacheImagePath 图片缓存路径（必写）
@return timeline
*/
+ (NvsTimeline *)CreatePhotoAlbumLetterBoxTimeline:(NSString *)filePath
                                           licFile:(NSString *)licFile
                                       resourceDir:(NSString *)resourceDir
                                   replaceFileList:(NSArray <NSString *>*)replaceFiles
                                    cacheImagePath:(NSString *)cacheImagePath;
                                                
@end
