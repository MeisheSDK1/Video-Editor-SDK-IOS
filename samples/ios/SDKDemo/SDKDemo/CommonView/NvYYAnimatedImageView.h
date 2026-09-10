//
//  NvYYAnimatedImageView.h
//  SDKDemo
//
//  Created by meishe01 on 2024/4/19.
//  Copyright © 2024 meishe. All rights reserved.
//

#import <YYImage/YYImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvYYAnimatedImageView : YYAnimatedImageView

/// 设置图片路径/名称(默认有占位图)
@property (nonatomic, copy) NSString * NVImagePath;

/// 设置图片
/// - Parameters:
///   - imagePath: 图片路径/名称
///   - placeHolder: 占位图
- (void)nv_configImagePath:(NSString * _Nullable)imagePath placeHolder:(NSString * _Nullable)placeHolder;

@end

NS_ASSUME_NONNULL_END
