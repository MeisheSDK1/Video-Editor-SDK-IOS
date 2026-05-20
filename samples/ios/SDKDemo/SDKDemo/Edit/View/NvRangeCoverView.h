//
//  NvRangeCoverView.h
//  SDKDemo
//
//  Created by Mac-Mini on 2025/5/7.
//  Copyright © 2025 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NvRangeCoverViewDelegate <NSObject>

- (void)onRangeCoverView:(UIView *)rangeCoverView didLeftOffset:(int64_t)leftValue isTouchUp:(BOOL)isTouchUp;
- (void)onRangeCoverView:(UIView *)rangeCoverView didRightOffset:(int64_t)rightValue isTouchUp:(BOOL)isTouchUp;
@required
- (float)getMinspace;

@end

@interface NvRangeCoverView : UIView

@property (nonatomic, weak) id<NvRangeCoverViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *leftSliderView;
@property (nonatomic, strong) UIImageView *rightSliderView;
@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) UIView* timeAxis;

@end

NS_ASSUME_NONNULL_END
