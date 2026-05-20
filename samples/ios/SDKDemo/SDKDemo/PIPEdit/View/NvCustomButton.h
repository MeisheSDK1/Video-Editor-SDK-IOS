//
//  NvCustomButton.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/12.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvCustomButton : UIButton

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) float fontSize;
@property (nonatomic, assign) bool fontSizeAdjustsToFitWidth;
@property (nonatomic, assign) float verticalSpace;

@end
