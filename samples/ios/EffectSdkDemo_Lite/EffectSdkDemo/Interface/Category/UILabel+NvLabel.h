//
//  UILabel+NvLabel.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/28.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (NvLabel)

+ (instancetype)nv_labelWithText:(NSString *)text fontSize:(float)fontSize textColor:(UIColor *)textColor;

@end
