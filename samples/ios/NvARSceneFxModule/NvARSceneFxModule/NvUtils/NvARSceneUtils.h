//
//  NvARSceneUtils.h
//  NvTest
//
//  Created by ms20180425 on 2022/8/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvARSceneUtils : NSObject

/**
 获取手机类型
 Get the phone type
 @return 手机类型的字符串例如@"iPhone 6" Phone type as a string such as @"iPhone 6"
 */
+ (NSString*_Nullable)iphoneType;

+ (UIImage *_Nullable)imageWithName:(NSString *_Nullable)name;


+ (BOOL)currentLanguagesIsChanese ;
@end

NS_ASSUME_NONNULL_END
