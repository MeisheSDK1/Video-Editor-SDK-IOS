//
//  NvInitArScence.h
//  SDKDemo
//
//  Created by ms on 2021/12/16.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

static BOOL isInitArFaceSuccess = NO;

typedef enum{
    NvFaceMode_106 = 0,
    NvFaceMode_240 = 1,
}NvFaceMode;

NS_ASSUME_NONNULL_BEGIN

@interface NvInitArScence : NSObject

+(BOOL)getInitArFace;

+ (void)initARFace:(NvFaceMode)model;

+ (void)closeDetect;

+ (BOOL)isHighVersionPhone;
@end

NS_ASSUME_NONNULL_END
