//
//  NvEditAdjustRectView.h
//  SDKDemo
//
//  Created by MS on 2020/12/3.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvEditAdjustRectView : UIView
@property (nonatomic, assign) double aspectRatio;

- (void)drawChartsWithPoints:(NSArray *)points scale:(double)scale;

- (void)setLineScale:(double)scale;
@end

NS_ASSUME_NONNULL_END
