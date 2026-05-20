//
//  NvCompoundColorCell.h
//  SDKDemo
//
//  Created by ms on 2021/6/30.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionColorItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvCompoundColorCell : UICollectionViewCell
- (void)renderCellWithItem:(NvCaptionColorItem *)item;
@end

NS_ASSUME_NONNULL_END
