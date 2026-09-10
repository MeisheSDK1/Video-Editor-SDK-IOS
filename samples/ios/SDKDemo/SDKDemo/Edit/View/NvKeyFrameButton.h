//
//  NvKeyFrameButton.h
//  SDKDemo
//
//  Created by MS on 2020/6/6.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvKeyFrameButton : UIButton
@property (nonatomic, strong) UILabel *btnLabel;
@property (nonatomic, strong) UIImageView *btnImageView;
+ (instancetype)buttonWithType:(UIButtonType)buttonType withTitle:(NSString *)title withImageNormal:(NSString *)normal withImageSelected:(NSString *)selected;
@end

