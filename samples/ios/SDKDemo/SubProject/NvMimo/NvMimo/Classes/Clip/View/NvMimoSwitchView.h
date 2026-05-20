//
//  NvSwitchView.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/25.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVMimoDefineConfig.h"

@interface NvMimoSwitchView : UIButton

@property (nonatomic, strong) UIView *sliderView;

- (instancetype)initWithFrame:(CGRect)frame withType:(NSInteger )type withState:(BOOL)state;

- (void)switchSelected:(BOOL)selected;

@end
