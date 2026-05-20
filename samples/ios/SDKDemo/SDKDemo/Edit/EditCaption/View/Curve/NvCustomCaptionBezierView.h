//
//  NvCustomCaptionBezierView.h
//  SDKDemo
//
//  Created by ms on 2021/5/21.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol NvCustomCaptionBezierViewDelegate

- (void)NvCustomCaptionBezierViewDidFinishedWithControlLeft:(CGPoint)controlLeft ControlRight:(CGPoint)controlRighty;

-(void)dragEnd;
@end

NS_ASSUME_NONNULL_BEGIN
@interface NvCustomCaptionBezierView : UIView

@property (nonatomic, weak)id delegate;

- (void)setupSelectedDefault:(CGPoint)leftPoint with:(CGPoint)rightPoint;

@end

NS_ASSUME_NONNULL_END
