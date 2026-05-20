//
//  NvBackgroundAssetCell.h
//  SDKDemo
//
//  Created by ms on 2021/1/7.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvTimelineDataModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvBackgroundAssetCell : UICollectionViewCell

@property (nonatomic, strong)NvEditDataModel *model;
@property (nonatomic, strong) UIImageView *coverImage;
@end

NS_ASSUME_NONNULL_END
