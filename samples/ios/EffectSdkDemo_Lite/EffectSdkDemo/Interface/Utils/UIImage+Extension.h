//
//  UIImage+Extension.h
//  jinyun
//
//  Created by 美摄 on 2019/3/21.
//  Copyright © 2019 美摄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Extension)

//+ (UIImage *)imageFromString:(NSString*)string;

/**
 根据颜色生成图片
 
 @param color 颜色
 @param size 图片大小
 @return 图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius size:(CGSize)size;

/**
 根据颜色生成（1，1）图片
 
 @param color 颜色
 @return 图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

#pragma mark -- Circle

- (UIImage *)drawRoundedRectImage:(CGFloat)cornerRadius width:(CGFloat)width height:(CGFloat)height;

- (UIImage *)drawCircleImage;

/// 按照传入的size进行图片裁剪
/// @param size 大小
- (UIImage *)modifyImageSize:(CGSize)size;

/// 根据传入的size，对原图进行缩放
/// @param size 大小
- (UIImage*)scaleImageSize:(CGSize)size;


@end

NS_ASSUME_NONNULL_END
