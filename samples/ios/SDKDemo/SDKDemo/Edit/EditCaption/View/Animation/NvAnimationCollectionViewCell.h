//
//  NvAnimationCollectionViewCell.h
//  SDKDemo
//
//  Created by ms on 2020/7/22.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionAnimationItem.h"

@interface NvAnimationCollectionViewCell : UICollectionViewCell

- (void)renderCellWithItem:(NvCaptionAnimationItem *)item;

@end

