//
//  NvSelectedAnimationCell.h
//  SDKDemo
//
//  Created by ms on 2020/8/25.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvSelectedAnimationModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvSelectedAnimationCell : UICollectionViewCell
- (void)renderCellWithItem:(NvSelectedAnimationModel *)item;
@end

NS_ASSUME_NONNULL_END
