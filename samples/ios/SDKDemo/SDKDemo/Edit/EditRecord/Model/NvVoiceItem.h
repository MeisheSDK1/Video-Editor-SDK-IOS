//
//  NvVoiceItem.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/8/7.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NvVoiceItem : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *builtinName;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, assign) BOOL isSelect;

@end
