//
//  NvFxCollectionViewCell.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/9/11.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvFilterFxModel.h"
#import "NvBaseAssetCell.h"

@interface NvFilterFxCollectionViewCell : NvBaseAssetCell

@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)renderCellWithModel:(NvFilterFxModel *)model;

@end
