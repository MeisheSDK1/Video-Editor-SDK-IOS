//
//  NvUtils.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/24.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvBaseCommon/NvBaseUtils.h>
#import <NvBaseCommon/UIColor+NvColor.h>
#import <Photos/Photos.h>
#import "NvsCommonDef.h"

NS_ASSUME_NONNULL_BEGIN
@interface NvUtils : NSObject

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
+ (NvsSize)calculateCompileSizeWithTimelineVideoSize:(CGSize)timelineSize compileResolution:(CGFloat)compileResolution;
+ (NvsSize)calculateGrabImageSizeWithTimelineVideoSize:(CGSize)timelineSize compileResolution:(CGFloat)compileResolution;
+ (NSString *_Nullable)currentDateAndTime;
///随机一个16进制的颜色值
///A random hexadecimal color value
+ (NSString *_Nullable)randomColor;

+ (int)recordResolutionSetting;
+ (int)compileResolutionSetting;
+ (BOOL)backgroudBlurFilledSetting;
+ (int64_t)compileBitrateSetting;
+ (BOOL)isStringEmpty:(NSString *_Nullable)string;

+ (nullable UIViewController *)findViewController:(nullable UIView *)sourceView;

+ (BOOL)lowPerformance;


/**
 * 获取用于保存临时文件的路径。
 * Gets the path to save the temporary file.
 */
+ (nullable NSString *)getTempPath;
/**
 * 获取用于生成自定义贴纸的图片在APP的保存路径。
 * Get the image used to generate custom stickers in the APP save path.
 */
+ (nullable NSString *)getCustomAnimatedStickerPicPath;

+ (nullable NSString *)getWatermarkPath;

/**
 * 输出唯一标志符，用于标志添加的素材。说明：SDK的素材自身有一个package id,但是为了区分编辑时添加多个相同的素材，需要用到唯一标志符。
 *
 *Output a unique identifier that identifies the added material. Note: The SDK materials themselves have a package id, but a unique identifier is needed to distinguish between adding multiple of the same materials when editing.
 */
+ (nullable NSString *)uuidString;

/**
 * 输出带格式的时间。例如：time = 1000000us, 输出为00:01.0
 * Output tape format time. For example, if time = 1000000us, the output is 00:01.0
 */
+ (nullable NSString *)getFormattedTime:(int64_t)time;

+(BOOL)isUnSupport4KEdit;
/**
 * 警告对话框
 * Warning dialog box
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
 Get phone type

 @return 手机类型的字符串例如@"iPhone 6"
 Phone type string such as @"iPhone 6"
 */
+ (NSString*_Nullable)iphoneType;

/**
 设置view指定位置的边框
 Sets the border of the view at the specified position
 @param originalView   原view
 Original view
 @param color          边框颜色
 Border color
 @param borderWidth    边框宽度
 Border width
 @param borderType     边框类型 例子: UIBorderSideTypeTop|UIBorderSideTypeBottom
 Frame type example: UIBorderSideTypeTop | UIBorderSideTypeBottom
 @return  view
 */
+ (UIView *_Nullable)borderForView:(UIView *_Nullable)originalView color:(UIColor *_Nullable)color borderWidth:(CGFloat)borderWidth borderType:(UIBorderSideType)borderType;

+ (NSString *)colorStringInRGBModeWithRGB:(NvsColor )color;
+ (NSString *)colorStringInARGBModeWithRGB:(NvsColor )color;
+ (NSString *)colorStringInRGBAModeWithRGB:(NvsColor )color;
+ (BOOL)currentLanguagesIsChinese;

///为滤镜、美妆等cell生成基于特定颜色数组中的随机颜色
///Generates random colors based on a specific color array for filters, makeup, and other cells
+ (NSString *)randomColorInColorArr:(NSArray *)colorArr;

///手机震动
///Mobile phone vibration
+ (void)impactFeedback;

///浮点数取余
///Mod floating-point number
+ (double)truncatingRemainder:(double)value remainder:(double)remainder;

///保留小数点后几位
///Let's keep the decimal places
+ (double)convertValue:(CGFloat)value pointNum:(NSInteger)pointNum;

/// 拷贝GIF文件到指定目录
/// Copy the GIF file to the specified directory
/// @param asset GIF PHAsset对象
/// GIF PHAsset object
/// @param dirPath 目标文件夹路径
/// Destination folder path
+ (NSString *)copyGifFileWithAsset:(PHAsset *)asset dirPath:(NSString *)dirPath;

///根据颜色生成image
///Generate an image based on the color
+ (UIImage *)createImageColor:(UIColor *)color size:(CGSize)size;
+ (UIViewController *)getCurrentVC;

@end
NS_ASSUME_NONNULL_END
