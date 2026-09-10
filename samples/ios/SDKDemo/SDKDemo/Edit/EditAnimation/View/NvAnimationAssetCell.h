//
//  NvAnimationAssetCell.h
//  SDKDemo
//
//  Created by ms on 2020/8/24.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvTimelineDataModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvAnimationAssetCell : UICollectionViewCell

@property (nonatomic, strong)NvEditDataModel *model;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIImageView *coverImage;
@end

NS_ASSUME_NONNULL_END
