//
//  NvStyleCollectionViewCell.h
//  SDKDemo
//
//  Created by Meicam on 2018/6/5.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionStyleItem.h"
#import "YYWebImage.h"

@interface NvStyleCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) YYAnimatedImageView *imageView;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UIImageView *noneImageView;
@property (nonatomic, strong) UILabel *nameLabel;

- (void)renderCellWithItem:(NvCaptionStyleItem *)item;

@end
