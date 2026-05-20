//
//  NvVideoFxItem.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/9/18.
//  Copyright © 2018年 meishe. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NvVideoFxItem : NSObject

@property (strong, nonatomic) NSString *builtinName;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *package;
@property (strong, nonatomic) NSString *cover;
@property (assign, nonatomic) BOOL selected;
@property (assign, nonatomic) BOOL isAnimation;
@property (strong, nonatomic) NSString *imagePath;

@end
