//
//  NvCompoundFontFamilyCollectionCell.h
//  SDKDemo
//  字体cell Font cell
//  Created by MS on 2019/5/21.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCompoundCaptionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvCompoundFontFamilyCollectionCell : UICollectionViewCell
@property(nonatomic, strong)NvCompoundCaptionModel *model;
@property (nonatomic, strong) UILabel *titleLabel;
@end

NS_ASSUME_NONNULL_END
