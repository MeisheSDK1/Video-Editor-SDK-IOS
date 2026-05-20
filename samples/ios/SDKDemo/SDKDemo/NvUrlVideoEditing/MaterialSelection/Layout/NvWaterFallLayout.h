//
//  NvWaterFallLayout.h
//  jinyun
//
//  Created by rongwf on 2021/8/3.
//  Copyright © 2021 美摄. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NvWaterFallLayout;

NS_ASSUME_NONNULL_BEGIN

@protocol NvWaterFallLayoutDataSoure <NSObject>

@required
//返回每个item高度
- (CGFloat)waterFallLayout:(NvWaterFallLayout *)waterFallLayout heightForItemAtIndex:(NSUInteger)index width:(CGFloat)width;

@optional
// 返回瀑布流显示的列数
- (NSUInteger)columnCountOfWaterFallLayout:(NvWaterFallLayout *)waterFallLayout;
// 返回行间距
- (CGFloat)rowMarginOfWaterFallLayout:(NvWaterFallLayout *)waterFallLayout;
// 返回列间距
- (CGFloat)columnMarginOfWaterFallLayout:(NvWaterFallLayout *)waterFallLayout;
// 返回边缘间距
- (UIEdgeInsets)edgeInsetsOfWaterFallLayout:(NvWaterFallLayout *)waterFallLayout;


@end

@interface NvWaterFallLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id<NvWaterFallLayoutDataSoure>dataSource;

@end

NS_ASSUME_NONNULL_END
