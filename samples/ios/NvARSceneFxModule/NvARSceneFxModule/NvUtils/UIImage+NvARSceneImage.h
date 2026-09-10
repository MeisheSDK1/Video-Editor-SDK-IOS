//
//  UIImage+NvARSceneImage.h
//  NvTest
//
//  Created by ms20180425 on 2022/8/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (NvARSceneImage)

- (UIImage *)drawRoundedRectImage:(CGFloat)cornerRadius width:(CGFloat)width height:(CGFloat)height;

/// 按照传入的size进行图片裁剪
/// Crop the image according to the passed size
/// @param size 大小
- (UIImage *)modifyImageSize:(CGSize)size;

/// 根据传入的size，对原图进行缩放
/// The original image is scaled according to the size passed in
/// @param size 大小
- (UIImage*)scaleImageSize:(CGSize)size;


@end

NS_ASSUME_NONNULL_END
