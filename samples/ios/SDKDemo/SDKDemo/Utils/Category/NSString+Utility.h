//
//  NSString+Utility.h
//  SDKDemo
//
//  Created by meishe01 on 2024/4/19.
//  Copyright © 2024 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Utility)

/// 判断字符串是否为空
- (BOOL)nv_isEmpty;
/// 判断字符串是否不为空
- (BOOL)nv_isNotEmpty;
/// 判断字符串是否是url
- (BOOL)nv_isValidURL;
/// 去除字符串首尾的空格和换行符
- (NSString *)nv_trimWhitespace;
/// 去除字符串中所有的空格和换行符
- (NSString *)nv_removeAllWhitespaces;
///判断路径文件是否存在
- (BOOL)nv_fileExists;

@end

NS_ASSUME_NONNULL_END
