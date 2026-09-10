//
//  NvCaptureBtn.h
//  SDKDemo
//
//  Created by ms on 2020/8/4.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvCaptureBtn : UIView
@property (nonatomic, strong) UILabel *percentageLabel;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UIImageView *completeImage;
-(void)beginRecord;
-(void)stopRecord;

@end

NS_ASSUME_NONNULL_END
