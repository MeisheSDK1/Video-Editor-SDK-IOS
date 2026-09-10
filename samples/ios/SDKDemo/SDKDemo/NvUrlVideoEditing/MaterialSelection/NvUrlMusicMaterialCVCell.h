//
//  NvUrlMusicMaterialCVCell.h
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/10.
//  Copyright © 2024 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NvListMediaInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface NvUrlMusicMaterialCVCell : UICollectionViewCell

- (void)renderCellWithItem:(NvListMediaInfoModel *)item;

@end

NS_ASSUME_NONNULL_END
