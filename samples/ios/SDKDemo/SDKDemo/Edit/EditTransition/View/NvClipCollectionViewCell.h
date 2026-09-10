//
//  NvClipCollectionViewCell.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/6/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvClipItem.h"

@interface NvClipCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *transitionButton;

- (void)renderCellWithClipItem:(NvClipItem *)item;

@end
