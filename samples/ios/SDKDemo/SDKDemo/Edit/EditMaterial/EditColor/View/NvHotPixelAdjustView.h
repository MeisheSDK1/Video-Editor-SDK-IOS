//
//  NvHotPixelAdjustView.h
//  SDKDemo
//
//  Created by ms on 2020/11/30.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvHotPixelAdjustView : UIView
@property (nonatomic) void(^colorSelectBlock)(int);
@property (nonatomic) void(^degreeeSlideValueChangeBlock)(CGFloat);
@property (nonatomic) void(^densitySlideValueChangeBlock)(CGFloat);


-(void)reset;

-(void)setWithColorType:(BOOL)isSingle Intensity:(float)intensityValue Density:(float)densityValue;
@end

NS_ASSUME_NONNULL_END
