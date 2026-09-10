//
//  NvLiveFunctionCollectionCell.h
//  MeicamLive
//
//  Created by ms20180425 on 2020/3/19.
//  Copyright © 2020 ms20180425. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NvLiveFunctionModel;
NS_ASSUME_NONNULL_BEGIN

@interface NvLiveFunctionCollectionCell : UICollectionViewCell

- (void)renderCellWithModel:(NvLiveFunctionModel *)model;

@end

NS_ASSUME_NONNULL_END
