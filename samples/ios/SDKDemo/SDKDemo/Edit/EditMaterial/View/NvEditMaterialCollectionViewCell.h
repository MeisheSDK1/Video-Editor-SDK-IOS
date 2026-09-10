//
//  NvEditMaterialCollectionViewCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/11.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvTimelineDataModel.h"
@class NvEditMaterialCollectionViewCell;

@protocol NvEditMaterialCollectionViewCellDelegate

- (void)addClipForIndex:(NSInteger)index;

@end

@interface NvEditMaterialCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id delegate;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) UIImageView *leftView;

@property (nonatomic, strong) UIImageView *rightView;

@property (nonatomic, strong) UIButton *leftBtn;

@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, strong) UIImage *coverImage;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) NvEditDataModel *model;

- (void)setAddButtonHidden:(Boolean)hidden;

@end
