//
//  NvAlbumUtils.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/24.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
//@import UIKit;
NS_ASSUME_NONNULL_BEGIN
@interface NvAlbumUtils : NSObject

#define OpenWebmTestData 0
#define WebmDirectory [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/NvWebmData"]

+ (NSString *_Nullable)convertTimecode:(int64_t)time;
+ (NSString *_Nullable)convertTimecodePrecision:(int64_t)time;
+ (NSString *_Nullable)convertTimecodePrecisional:(int64_t)time;

+ (UIFont*_Nonnull)fontWithSize:(float)size;
+ (UIFont*_Nonnull)regularFontWithSize:(float)size;
+ (UIFont*_Nonnull)boldFontWithSize:(float)size;
+ (UIFont*_Nonnull)mediumFontWithSize:(float)size;
+ (NSMutableArray *)rgbWithColor:(UIColor *)color;
+ (NSString *)hexStringWithColor:(UIColor *)color;
+ (NSArray *)captionColors;
+ (NSArray *)rgbColors;
+ (NSArray *)rgbBgColors;

+ (NSString *_Nullable)currentDateAndTime;
// Random hexadecimal color value
+ (NSString *_Nullable)randomColor;//随机一个16进制的颜色值

+ (BOOL)isStringEmpty:(NSString *_Nullable)string;

+ (nullable UIViewController *)findViewController:(nullable UIView *)sourceView;


/**
 * 输出唯一标志符，用于标志添加的素材。说明：SDK的素材自身有一个package id,但是为了区分编辑时添加多个相同的素材，需要用到唯一标志符。
 * Outputs a unique identifier to identify added assets. Note: SDK assets themselves have a package id, but a unique identifier is used to distinguish when editing multiple assets that are the same.
 */
+ (nullable NSString *)uuidString;

/**
 * 输出带格式的时间。例如：time = 1000000us, 输出为00:01.0
 * Output with formatted time. For example: time = 1000000us, the output is 00:01.0
 */
+ (nullable NSString *)getFormattedTime:(int64_t)time;

/**
 * 警告对话框
 * Alert dialog box
 */
+ (void)alertMessage:(nullable UIViewController *)viewController
               title:(nullable NSString*)title
             message:(nullable NSString*)message
     firstButtonText:(nullable NSString*)firstButtonText
        firstHandler:(void (^ __nonnull)(UIAlertAction *_Nonnull action))firstHandler
    secondButtonText:(nullable NSString*)secondButtonText
       secondHandler:(void (^ __nullable)(UIAlertAction *_Nullable action))secondHandler;

/**
 获取手机类型
 @return 手机类型的字符串例如@"iPhone 6"
 Get the phone type
 @return String for the phone such as @"iPhone 6"
 */
+ (NSString*_Nullable)iphoneType;

+ (BOOL)currentLanguagesIsChinese;

//为滤镜、美妆等cell生成基于特定颜色数组中的随机颜色
// Generate random colors based on a specific color array for filter, beauty, etc
+ (NSString *)randomColorInColorArr:(NSArray *)colorArr;

//手机震动
// Phone vibrates
+ (void)impactFeedback;

//浮点数取余
// Modulo float
+ (double)truncatingRemainder:(double)value remainder:(double)remainder;

//保留小数点后几位
// Keep a few decimal places
+ (double)convertValue:(CGFloat)value pointNum:(NSInteger)pointNum;

/// 拷贝GIF文件到指定目录
/// @param asset GIF PHAsset对象
/// @param dirPath 目标文件夹路径
/// Copy the GIF to the specified directory
/// @param asset GIF PHAsset object
/// @param dirPath The destination folder path
+ (NSString *)copyGifFileWithAsset:(PHAsset *)asset dirPath:(NSString *)dirPath;

//根据颜色生成image
// Generate image from color
+ (UIImage *)createImageColor:(UIColor *)color size:(CGSize)size;

//检查素材是否是livePhoto
// check if the asset is livePhoto
+ (BOOL)checkIsLivePhoto:(PHAsset *)asset;

//把无符号整数转为格式字符串
//convert unsigned int value to formated string
+ (NSString *)convertIntegerToFormatString:(NSUInteger)number;
@end
NS_ASSUME_NONNULL_END
