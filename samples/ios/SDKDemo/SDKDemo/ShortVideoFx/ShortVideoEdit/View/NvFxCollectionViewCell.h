//
//  NvFxCollectionViewCell.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/9/11.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvVideoFxItem.h"

@interface NvFxCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)renderCellWithItem:(NvVideoFxItem *)item;

@end
