//
//  NvBezierSpeedModel.h
//  SDKDemo
//
//  Created by MS on 2020/11/24.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface NvRangeModel : NSObject
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;
@end

@interface NvCurveInfo : NSObject
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, strong) NSMutableArray *chartsArr;
@end

@interface NvBezierSpeedModel : NSObject

@end

NS_ASSUME_NONNULL_END
