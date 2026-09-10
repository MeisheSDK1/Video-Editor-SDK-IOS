//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2021. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Apr 09. 2021
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <UIKit/UIView.h>
#import "NvsWaveformDataGenerator.h"

NVS_EXPORT @interface NvsWaveformView : UIView<NvsWaveformDataGeneratorDelegate>
@property (nonatomic) NSString* audioFilePath;
@property (nonatomic) int64_t trimIn;
@property (nonatomic) int64_t trimOut;
@property (nonatomic) UIColor* waveformColor;
@property (nonatomic) Boolean singleChannelMode;

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;


@end

