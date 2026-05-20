//
//  NvShortVideoBeautyView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/9.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NvShortVideoBeautyView <NSObject>

/**
 @param type type 0为磨皮，1为大眼，2为瘦脸
 type 0 means "Beauty Strength", 1 means "Eye Size Warp Degree", 2 means "Face Size Warp Degree"
 */
- (void)slider:(int)type valueChanged:(float)value;

@end

@interface NvShortVideoBeautyView : UIView

@property (nonatomic, weak)id delegate;

@property (nonatomic, assign) BOOL containtAR;

/// 设置磨皮，大眼，瘦脸
/// set the values of strength,eyeEnlarging and cheekThinning
/// @param strength 磨皮
/// @param eyeEnlarging 大眼
/// @param cheekThinning 瘦脸
- (void)setStrength:(float)strength eyeEnlarging:(float)eyeEnlarging cheekThinning:(float)cheekThinning;

@end

NS_ASSUME_NONNULL_END
