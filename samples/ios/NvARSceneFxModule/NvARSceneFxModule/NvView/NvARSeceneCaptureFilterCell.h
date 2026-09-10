//
//  NvARSeceneCaptureFilterCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvBaseModel.h"

@class MSSoundModel;
@class MSStickerModel;
@class MSCaptionModel;
@class MSMusiclyricModel;
NS_ASSUME_NONNULL_BEGIN

@interface NvARSeceneCaptureFilterCell : UICollectionViewCell

- (void)renderCellWithModel:(NvBaseModel *)model;

- (void)renderCellWithSoundModel:(MSSoundModel *)model;

- (void)renderCellWithStickerModel:(MSStickerModel *)model;

- (void)renderCellWithCaptionModel:(MSCaptionModel *)model;

- (void)renderCellWithMusiclyricModel:(MSMusiclyricModel *)model;

@end

NS_ASSUME_NONNULL_END
