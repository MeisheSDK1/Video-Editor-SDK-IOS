//
//  NvAllAssetCell.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvAlbumItem.h"

@protocol NvAllAssetCellDelegate <NSObject>

- (void)cellSwitchValueChanged:(BOOL)on asset:(PHAsset *)asset;

@end

@interface NvAllAssetCell : UICollectionViewCell

@property (nonatomic, weak) id<NvAllAssetCellDelegate> delegate;

// Multi-select, default YES, no number mark for radio
@property (nonatomic, assign) BOOL mutableSelect; //是否多选，默认YES,单选不会有数字标记

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UISwitch *fileSwitch;

- (void)showLayer:(BOOL)isShow withNum:(NSInteger)num;

- (void)renderCellWithAsset:(PHAsset *)asset;

@end
