//
//  NvFlipCaptionModel.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvFlipCaptionModel : NSObject <NSCopying>

@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, strong) NSString *timeStr;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *colorString;

@end

NS_ASSUME_NONNULL_END
