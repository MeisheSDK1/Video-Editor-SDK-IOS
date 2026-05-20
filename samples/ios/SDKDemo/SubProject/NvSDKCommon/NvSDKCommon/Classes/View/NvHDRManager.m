//
//  NvHDRManager.m
//  SDKDemo
//
//  Created by ms on 2021/7/28.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvHDRManager.h"
#import <NvSDKCommon/NvSDKUtils.h>

@implementation NvHDRManager

+(void)setSDRToHDRColorGain{
    float value;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ISCHANGESDRTOHDRCOLORGAIN"]) {
        value = [[NSUserDefaults standardUserDefaults] floatForKey:@"SDRTOHDRCOLORGAIN"];
    }else{
        value = 2.0;
    }
    [[NvSDKUtils getSDKContext] setColorGainForSDRToHDR:value];
}

+(int)getEngineHdrCaps{
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"EngineHdrCaps"];
}

+(void)setUpEngineHdrCaps{
    int cap = [[NvsStreamingContext sharedInstance] getEngineHDRCaps];
    [[NSUserDefaults standardUserDefaults] setInteger:cap forKey:@"EngineHdrCaps"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isSupportEditing{
    return [self getEngineHdrCaps] & NvsHDRCapabilityFlagSupportedByEditing;
}

+(BOOL)isSupportExporter{
    return [self getEngineHdrCaps] & NvsHDRCapabilityFlagSupportedByExporter;
}

+(BOOL)isSupportLivewindow{
    return [self getEngineHdrCaps] & NvsHDRCapabilityFlagSupportedByLivewindow;
}
@end
