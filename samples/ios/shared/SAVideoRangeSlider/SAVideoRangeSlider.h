//
//  SAVideoRangeSlider.h
//
// This code is distributed under the terms and conditions of the MIT license.
//
// Copyright (c) 2013 Andrei Solovjev - http://solovjev.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "SASliderLeft.h"
#import "SASliderRight.h"

@protocol SAVideoRangeSliderDelegate <NSObject>

@optional

- (void)videoRange:(id)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;

- (void)videoRange:(id)videoRange didGestureStateEndedLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;


@end

@interface SAVideoRangeSlider : UIView

@property (nonatomic, weak) id <SAVideoRangeSliderDelegate> delegate;
@property (nonatomic) Float64 durationSeconds;
@property (nonatomic) CGFloat leftPosition;
@property (nonatomic) CGFloat rightPosition;
@property (nonatomic, strong) UIView *topBorder;
@property (nonatomic, strong) UIView *bottomBorder;
@property (nonatomic, strong) NSNumber* maxGap;
@property (nonatomic, strong) NSNumber* minGap;
///最小区间时间以秒为单位
///The minimum interval time is in seconds
@property (nonatomic) CGFloat minSectionTime;
///滑动的是左边还是右边
///Is it sliding left or right
@property (nonatomic, assign) BOOL isLeft;

@end






