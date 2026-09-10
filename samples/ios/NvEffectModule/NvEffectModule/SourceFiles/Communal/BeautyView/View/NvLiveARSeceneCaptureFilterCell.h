//
//  NvLiveARSeceneCaptureFilterCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NvLiveBaseModel;
@class MSSoundModel;
@class MSStickerModel;
@class MSCaptionModel;
@class MSMusiclyricModel;
NS_ASSUME_NONNULL_BEGIN

@interface NvLiveARSeceneCaptureFilterCell : UICollectionViewCell

- (void)renderCellWithModel:(NvLiveBaseModel *)model;

@end

NS_ASSUME_NONNULL_END
