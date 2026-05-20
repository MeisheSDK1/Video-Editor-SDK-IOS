//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2023. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jan 6 . 2023
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"

typedef enum {
    NvsAudioToneProcessorToneMode_Male = 0,
    NvsAudioToneProcessorToneMode_Female = 1,
    NvsAudioToneProcessorToneMode_Cartoon = 2,
    NvsAudioToneProcessorToneMode_FastCartoon = 3,
    NvsAudioToneProcessorToneMode_Monster = 4,
    NvsAudioToneProcessorToneMode_Custom = 5,
    NvsAudioToneProcessorToneMode_Echo = 6,
    NvsAudioToneProcessorToneMode_Wahwah = 7,
    NvsAudioToneProcessorToneMode_Reverb = 8
} NvsAudioToneProcessorToneMode;

NVS_EXPORT @interface NvsAudioToneProcessor : NSObject

- (instancetype)initWithToneMode:(NvsAudioToneProcessorToneMode)toneMode;

- (void)dealloc;

- (void)processAudioSample:(NvsAudioSampleBuffers *)audioSamples;

- (void)clearRemainSamples;

- (void)setCustomToneModeParamTempoDelta:(float)tempoDelta
                            pictchDelta:(float)pitchDelta
                              rateDelta:(float)rateDelta
                                 speech:(bool)speech;


@end
