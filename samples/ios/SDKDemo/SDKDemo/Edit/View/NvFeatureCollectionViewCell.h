//
//  NvFeatureCollectionViewCell.h
//  SDKDemo
//
//  Created by meishe01 on 2018/6/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvFeatureItem.h"

@interface NvFeatureCollectionViewCell : UICollectionViewCell

- (void)renderCellWithItem:(NvFeatureItem *)item;

@end
