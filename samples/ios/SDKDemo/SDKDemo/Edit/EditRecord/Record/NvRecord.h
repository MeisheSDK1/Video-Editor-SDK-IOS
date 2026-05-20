//
//  NvRecord.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/8/7.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface NvRecord : NSObject

@property (nonatomic, assign) BOOL isRecording;

- (instancetype)init;

- (NSString *)startRecord;
- (void)stopRecord;

@end
