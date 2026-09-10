//
//  NvCorrectionModel.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/10/10.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NvCorrectionModel : NSObject

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) BOOL select;
@property (nonatomic, strong) NSString *typeString;

@end
