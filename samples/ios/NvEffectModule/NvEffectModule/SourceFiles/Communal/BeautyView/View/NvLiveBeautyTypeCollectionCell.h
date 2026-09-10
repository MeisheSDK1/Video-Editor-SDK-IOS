//
//  NvLiveBeautyTypeCollectionCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/10/20.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NvLiveBeautyTypeModel;

@interface NvLiveBeautyTypeCollectionCell : UICollectionViewCell

- (void)renderCellWithModel:(NvLiveBeautyTypeModel *)model;

@end
