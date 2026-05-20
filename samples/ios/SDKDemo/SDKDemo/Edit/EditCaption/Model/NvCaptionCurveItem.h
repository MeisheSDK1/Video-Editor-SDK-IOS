//
//  NvCaptionCurveItem.h
//  SDKDemo
//
//  Created by ms on 2021/5/19.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CurveAnimationType) {
    CurveAnimationType1 = 0,
    CurveAnimationType2,
    CurveAnimationType3,
    CurveAnimationType4,
    CurveAnimationType5,
    CurveAnimationType6,
    CurveAnimationType7,
    CurveAnimationTypeCustom,
};
NS_ASSUME_NONNULL_BEGIN

@interface NvCaptionCurveItem : NSObject
@property (nonatomic, copy) NSString *image;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) CurveAnimationType type;
@end

NS_ASSUME_NONNULL_END
