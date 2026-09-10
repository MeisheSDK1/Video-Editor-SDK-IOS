//
//  LoopCollectionViewCell.h
//  ScrollViewLoop
//
//  Created by 刘东旭 on 2019/9/25.
//  Copyright © 2019 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvLoopViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoopCollectionViewCell : UICollectionViewCell

- (void)setModel:(NvLoopViewModel *)model;

@end

NS_ASSUME_NONNULL_END
