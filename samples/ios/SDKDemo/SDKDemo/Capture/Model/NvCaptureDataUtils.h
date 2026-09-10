//
//  NvCaptureDataUtils.h
//  SDKDemo
//
//  Created by 李勇 on 2022/8/2.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvCaptureDataUtils : NSObject

/// 拍摄数据和编辑不一样
/// 拍摄

+ (NSArray *)getCaptureBeautifulSkinTitleArray:(BOOL)matte;
+ (NSArray *)getCaptureBeautifulSkinCoverArray:(BOOL)matte;
+ (NSArray *)getCaptureBeautifulSkinCoverSelectedArray:(BOOL)matte;
+ (NSArray *)getCaptureBeautifulSkinFxNameArray:(BOOL)matte isContentAI:(BOOL)isContentAI;

/// 编辑

+ (NSArray *)getBeautifulSkinTitleArray:(BOOL)matte;
+ (NSArray *)getBeautifulSkinCoverArray:(BOOL)matte;
+ (NSArray *)getBeautifulSkinCoverSelectedArray:(BOOL)matte;
+ (NSArray *)getBeautifulSkinFxNameArray:(BOOL)matte isContentAI:(BOOL)isContentAI;

+ (NSArray *)getShapeTitleArray:(BOOL)containAI;
+ (NSArray *)getShapeCoverArray:(BOOL)containAI;
+ (NSArray *)getShapeSelectedCoverArray:(BOOL)containAI;
+ (NSArray *)getShapeFxNameArray;
+ (NSArray *)getShapeDegreeNameArray:(BOOL)containAI;
+ (NSMutableArray *)getShapePackagePaths;

+ (NSArray *)getMicroShapeTitleArray;
+ (NSArray *)getMicroShapeCoverArray;
+ (NSArray *)getMicroShapeSelectedCoverArray;
+ (NSArray *)getMicroShapeFxNameArray;
+ (NSArray *)getMicroShapeDegreeNameArray;
+ (NSMutableArray *)getMicroShapePackagePaths;

+ (NSMutableArray *)getShapeTestData;
+ (NSMutableArray *)getMicroShapeTestData;

@end

NS_ASSUME_NONNULL_END
