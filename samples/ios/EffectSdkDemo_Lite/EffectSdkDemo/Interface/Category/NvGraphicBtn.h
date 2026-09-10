//
//  NvGraphicBtn.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/13.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvGraphicBtn : UIButton

@property (nonatomic, readonly) UIImageView *btnImageView;

@property (nonatomic, strong) NSString *selectedString;

@property (nonatomic, strong) UILabel *btnLabel;

+ (instancetype)buttonWithTag:(NSInteger)buttonTag withTitle:(NSString *)title withImageNormal:(NSString *)normal withImageSelected:(NSString *)selected;

@end

