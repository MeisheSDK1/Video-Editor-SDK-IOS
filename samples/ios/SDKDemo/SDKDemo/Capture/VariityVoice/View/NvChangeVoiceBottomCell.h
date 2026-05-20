//
//  NvChangeVoiceBottomCell.h
//  SDKDemo
//
//  Created by ms on 2021/3/10.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvVoiceBottomModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvChangeVoiceBottomCell : UICollectionViewCell

/// 音效模型数据 Sound model data
@property (nonatomic, copy) NvVoiceBottomModel *bottomModel;
@end

NS_ASSUME_NONNULL_END
