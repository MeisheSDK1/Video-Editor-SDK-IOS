//
//  PhotoThemeCell.h
//  ThemeShooting
//
//  Created by ms on 2020/7/15.
//  Copyright © 2020 ms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvThemeShootModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoThemeCell : UICollectionViewCell

@property (nonatomic, strong) NvThemeShootModel *model;
@property (nonatomic) void(^downLoadBlock)(NvThemeShootModel*, PhotoThemeCell *);
@property (nonatomic, strong) UIImageView *downLoadImageView;
@end

NS_ASSUME_NONNULL_END
