//
//  NvCaptionCurveView.h
//  SDKDemo
//
//  Created by ms on 2021/5/19.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionCurveItem.h"

NS_ASSUME_NONNULL_BEGIN
@class NvCaptionCurveView;
@protocol NvCaptionCurveViewDelegate

- (void)nvCaptionCurveViewDidFinished:(NvCaptionCurveView *)view;
- (void)nvCaptionCurveViewDidSelectModel:(NvCaptionCurveItem *)item;

@end

@interface NvCaptionCurveView : UIView

@property (nonatomic, weak) id delegate;

- (void)setupSelectedDefault:(CurveAnimationType)type;

@end

NS_ASSUME_NONNULL_END
