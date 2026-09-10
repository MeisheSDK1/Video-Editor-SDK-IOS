//
//  EFStickerView.h
//  EffectSdkDemo
//
//  Created by 美摄 on 2019/12/12.
//  Copyright © 2019 美摄. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvStickerCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN
@class EFStickerView;

@protocol EFStickerViewDelegate <NSObject>

@optional

-(void)stickerViewDidDismiss:(EFStickerView*)stickerView;

-(void)didSeletedItem:(id<NvStickerModelDelegate>)item stickerView:(EFStickerView*)stickerView;

@end

@interface EFStickerView : UIView

@property(nonatomic,weak) id<EFStickerViewDelegate> delegate;

@property(nonatomic,strong)NSArray<id<NvStickerModelDelegate>>*stickerArray;

@end

NS_ASSUME_NONNULL_END
