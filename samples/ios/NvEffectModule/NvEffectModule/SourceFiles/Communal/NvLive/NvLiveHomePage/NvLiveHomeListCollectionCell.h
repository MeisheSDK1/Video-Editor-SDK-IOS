//
//  NvLiveHomeListCollectionCell.h
//  MeicamLive
//
//  Created by ms20180425 on 2020/3/16.
//  Copyright © 2020 ms20180425. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvLiveHomeListCollectionCell : UICollectionViewCell

- (void)renderCellWithModel:(NvLiveModel *)model;

@end

NS_ASSUME_NONNULL_END
