//
//  NvBottomMenuCell.h
//  SDKDemo
//
//  Created by ms on 2021/3/5.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVHeader.h"
#import "NvMaskMenuItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvBottomMenuCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) NvMaskMenuItem *model;

@end


NS_ASSUME_NONNULL_END
