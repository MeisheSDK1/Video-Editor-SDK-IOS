//
//  NSString+NvPath.h
//  NvSDKCommon
//
//  Created by meishe01 on 2024/3/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (NvPath)

/// 将文件path路径修改为想要的扩展名路径(会去掉版本如.1.videofx->.lic)
/// - Parameters:
///   - originalPath: 原路径
///   - extension: 新路径后缀扩展名
+(NSString *)convertFilePathToNewPath:(NSString *)originalPath WithExtension:(NSString *)extension;


@end

NS_ASSUME_NONNULL_END
