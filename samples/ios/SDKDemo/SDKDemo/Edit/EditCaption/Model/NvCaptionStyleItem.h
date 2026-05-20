//
//  NvCaptionStyleItem.h
//  SDKDemo
//
//  Created by Meicam on 2018/6/5.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NvCaptionStyleItem : NSObject

@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *packageId;
@property (nonatomic, copy) NSString *packagePath;
@property (nonatomic, assign) BOOL isAdjusted;
@end
