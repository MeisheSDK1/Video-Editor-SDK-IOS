//
//  NvThemeShootFilterCVCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2020/8/4.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvThemeShootCVCell.h"

@class NvCaptureFilterModel;

NS_ASSUME_NONNULL_BEGIN

@interface NvThemeShootFilterCVCell : NvThemeShootCVCell

- (void)renderCellWithFilterModel:(NvCaptureFilterModel *)model;

@end

NS_ASSUME_NONNULL_END
