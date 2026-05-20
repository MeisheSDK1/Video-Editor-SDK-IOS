//
//  NvMimoUtils.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/24.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIColor+NvColor.h>
#import "NVMimoDefineConfig.h"

typedef NS_ENUM(NSInteger, UIBorderSideType) {
    UIBorderSideTypeAll    = 0,
    UIBorderSideTypeTop    = 1 << 0,
    UIBorderSideTypeBottom = 1 << 1,
    UIBorderSideTypeLeft   = 1 << 2,
    UIBorderSideTypeRight  = 1 << 3,
};

//@import UIKit;
NS_ASSUME_NONNULL_BEGIN
@interface NvMimoUtils : NSObject

+ (NSString *_Nullable)convertTimecode:(int64_t)time;
+ (NSString *_Nullable)convertTimecodePrecision:(int64_t)time;

+ (UIImage *_Nullable)imageWithName:(NSString *_Nullable)name withScale:(float)scale;
+ (UIImage *_Nullable)imageWithName:(NSString *_Nullable)name;
+ (UIFont*_Nullable)fontWithSize:(float)size;
+ (UIFont*)regularFontWithSize:(float)size;
+ (UIFont*)boldFontWithSize:(float)size;
+ (NSMutableArray *)rgbWithColor:(UIColor *)color;
+ (NSString *)hexStringWithColor:(UIColor *)color;
+ (NSArray *)captionColors;

+ (NSString *_Nullable)currentDateAndTime;

+ (NSString *_Nullable)randomColor;

+ (int)recordResolutionSetting;
+ (int)compileResolutionSetting;
+ (BOOL)backgroudBlurFilledSetting;
+ (int64_t)compileBitrateSetting;
+ (BOOL)isStringEmpty:(NSString *_Nullable)string;

+ (nullable UIViewController *)findViewController:(nullable UIView *)sourceView;
/**
 * 获取用于保存临时文件的路径。
 * Gets the path to save the temporary file.
 */
+ (nullable NSString *)getTempPath;
/**
 * 获取用于生成自定义贴纸的图片在APP的保存路径。
 * Get the path in the APP where the image used to generate the custom sticker will be saved.
 */
+ (nullable NSString *)getCustomAnimatedStickerPicPath;

+ (nullable NSString *)getWatermarkPath;

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
 Get the phone type
 @return 手机类型的字符串例如@"iPhone 6"
 */
+ (NSString*_Nullable)iphoneType;

/**
 设置view指定位置的边框
 Sets the border at the specified position of the view
 @param originalView   原view
 @param color          边框颜色
 @param borderWidth    边框宽度
 @param borderType     边框类型 例子: UIBorderSideTypeTop|UIBorderSideTypeBottom
 @return  view
 */
+ (UIView *_Nullable)borderForView:(UIView *_Nullable)originalView color:(UIColor *_Nullable)color borderWidth:(CGFloat)borderWidth borderType:(UIBorderSideType)borderType;

+ (NSString *)colorStringInARGBModeWithRGB:(NvsColor )color;
+ (BOOL)currentLanguagesIsChinese;
@end
NS_ASSUME_NONNULL_END
