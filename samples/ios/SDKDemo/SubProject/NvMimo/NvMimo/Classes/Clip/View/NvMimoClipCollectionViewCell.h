//
//  NvClipCollectionViewCell.h
//  NvMimoDemo
//
//  Created by MS on 2019/8/12.
//  Copyright © 2019 MS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvMimoListModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvMimoClipCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) NvMimoListModel *model;
@end

NS_ASSUME_NONNULL_END
