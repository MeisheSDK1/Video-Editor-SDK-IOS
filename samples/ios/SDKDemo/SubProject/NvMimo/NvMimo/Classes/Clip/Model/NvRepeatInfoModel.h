//
//  NvRepeatInfoModel.h
//  NvMimoDemo
//
//  Created by MS on 2019/12/18.
//  Copyright © 2019 MS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvRepeatInfoModel : NSObject
///The Chinese here are interpreting the variable names without translation
@property (nonatomic, assign) CGFloat normalTrimIn;   //正放入点（单位：us）
@property (nonatomic, assign) CGFloat reverseTrimIn;  //倒放入点（单位：us）
@property (nonatomic, assign) CGFloat repeatDuration; //倒放视频单次时长（单位：us）
@property (nonatomic, assign) CGFloat count;          //重复次数
@end

NS_ASSUME_NONNULL_END
