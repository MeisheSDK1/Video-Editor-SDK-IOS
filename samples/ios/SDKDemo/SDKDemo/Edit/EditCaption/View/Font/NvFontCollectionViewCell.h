//
//  NvFontCollectionViewCell.h
//  SDKDemo
//
//  Created by Meicam on 2018/6/7.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionFontItem.h"
#import "NvBaseAssetCell.h"

@interface NvFontCollectionViewCell : NvBaseAssetCell

@property (nonatomic, strong) UIColor *selectColor;
- (void)renderCellWithItem:(NvCaptionFontItem *)item;

@end
