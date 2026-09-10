//
//  NvLiveARSceneUtils.h
//  NvTest
//
//  Created by ms20180425 on 2022/8/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvLiveARSceneUtils : NSObject

/**
 获取手机类型
 Get the phone type
 @return 手机类型的字符串例如@"iPhone 6" Phone type as a string such as @"iPhone 6"
 */
+ (NSString *_Nullable)iphoneType;

+ (UIImage *_Nullable)imageNamed:(NSString *_Nullable)name;

+ (BOOL)currentLanguagesIsChanese;

// 根据手机机型判断是否支持Gan 美颜
// Determine whether the phone model supports Gan beauty features
+ (BOOL)enableGanBeauty;
@end

NS_ASSUME_NONNULL_END
