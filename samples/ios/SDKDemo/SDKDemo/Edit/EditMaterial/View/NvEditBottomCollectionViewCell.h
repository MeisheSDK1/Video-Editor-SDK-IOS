//
//  NvEditBottomCollectionViewCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/12.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvEditCorrectColorItem.h"
#import "NVHeader.h"
@interface NvEditBottomCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) NSDictionary *dict;
@property (nonatomic, strong) NvEditCorrectColorItem *model;

@end
