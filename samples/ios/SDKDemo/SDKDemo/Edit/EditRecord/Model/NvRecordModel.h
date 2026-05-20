//
//  NvRecordModel.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/8/8.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NvRecordModel : NSObject

@property (nonatomic, assign) int64_t inpoint;
@property (nonatomic, assign) int64_t trimIn;
@property (nonatomic, assign) int64_t outpoint;
@property (nonatomic, assign) float volume;
@property (nonatomic, strong) NSString *builtInFxName;
@property (nonatomic, strong) NSString *recordingPath;
@property (nonatomic, assign) int audioNoiseSuppressionLevel;
@end
