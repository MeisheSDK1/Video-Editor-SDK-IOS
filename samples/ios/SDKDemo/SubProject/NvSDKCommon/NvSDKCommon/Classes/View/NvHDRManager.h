//
//  NvHDRManager.h
//  SDKDemo
//
//  Created by ms on 2021/7/28.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsStreamingContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvHDRManager : NSObject
+(void)setSDRToHDRColorGain;
+(int)getEngineHdrCaps;
+(void)setUpEngineHdrCaps;
+(BOOL)isSupportEditing;
+(BOOL)isSupportExporter;
+(BOOL)isSupportLivewindow;
@end

NS_ASSUME_NONNULL_END
