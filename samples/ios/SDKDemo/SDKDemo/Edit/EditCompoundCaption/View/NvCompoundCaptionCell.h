//
//  NvCompoundCaptionCell.h
//  SDKDemo
//
//  Created by MS on 2019/5/16.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionStyleItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvCompoundCaptionCell : UICollectionViewCell

- (void)renderCellWithItem:(NvCaptionStyleItem *)item;
@end

NS_ASSUME_NONNULL_END
