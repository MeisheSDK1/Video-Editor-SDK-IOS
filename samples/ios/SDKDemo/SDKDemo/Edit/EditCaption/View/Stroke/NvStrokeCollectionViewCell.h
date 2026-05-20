//
//  NvStrokeCollectionViewCell.h
//  SDKDemo
//
//  Created by Meicam on 2018/6/6.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionStrokeItem.h"

@interface NvStrokeCollectionViewCell : UICollectionViewCell

- (void)renderCellWithItem:(NvCaptionStrokeItem *)item;

@end
