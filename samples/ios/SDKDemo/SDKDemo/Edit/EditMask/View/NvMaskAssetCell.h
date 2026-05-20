//
//  NvMaskAssetCell.h
//  SDKDemo
//
//  Created by ms on 2021/3/5.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface NvMaskAssetModel : NSObject
@property (nonatomic, strong) UIImage *thumImage;
@property(assign, nonatomic) int64_t trimIn;
@property(assign, nonatomic) int64_t trimOut;           
@property (nonatomic, assign) BOOL isSelected;
@end

@interface NvMaskAssetCell : UICollectionViewCell
@property (nonatomic, strong) NvMaskAssetModel *model;
@property (nonatomic, strong) UIImageView *coverImage;
@end

NS_ASSUME_NONNULL_END
