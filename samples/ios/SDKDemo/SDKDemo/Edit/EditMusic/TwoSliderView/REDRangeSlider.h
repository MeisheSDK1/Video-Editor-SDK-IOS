//
//  REDRangeSlider.h
//
//
//  Created by Red Davis on 24/10/2012.
//  Copyright (c) 2013 Red Davis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol REDRangeSliderDelegate <NSObject>
- (void)leftPan:(CGFloat)left;
- (void)rightPan:(CGFloat)right;

@end

@interface REDRangeSlider : UIControl


@property (assign, nonatomic) CGFloat minValue;
@property (assign, nonatomic) CGFloat maxValue;
@property (assign, nonatomic) CGFloat leftValue;
@property (assign, nonatomic) CGFloat rightValue;

@property (strong, nonatomic) UIImage *handleImage;
@property (strong, nonatomic) UIImage *leftHandleImage;
@property (strong, nonatomic) UIImage *rightHandleImage;
@property (strong, nonatomic) UIImageView *leftHandle;
@property (strong, nonatomic) UIImageView *rightHandle;
@property (nonatomic, strong) UILabel *trimInLabel;
@property (nonatomic, strong) UILabel *trimOutLabel;

@property (strong, nonatomic) UIImage *handleHighlightedImage;
@property (strong, nonatomic) UIImage *leftHandleHighlightedImage;
@property (strong, nonatomic) UIImage *rightHandleHighlightedImage;

@property (strong, nonatomic) UIImage *trackBackgroundImage;
@property (strong, nonatomic) UIImage *trackFillImage;

@property (assign, nonatomic) CGFloat stepValue;
@property (assign, nonatomic) CGFloat minimumSpacing;

@property (assign, nonatomic) BOOL didSetupUI;

@property (weak, nonatomic) id<REDRangeSliderDelegate> delegate;

- (void)setupUI;

- (UIImage *)createImageWithColor:(NSString *)string;

@end
