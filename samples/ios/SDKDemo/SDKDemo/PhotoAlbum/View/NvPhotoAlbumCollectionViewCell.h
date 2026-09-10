//
//  NvPhotoAlbumCollectionViewCell.h
//  SDKDemo
//
//  Created by MS on 2019/9/24.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvPhotoAlbumModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol NvPhotoAlbumCollectionViewCellDelegate <NSObject>

- (void)photoAlbumCollectionCell:(UICollectionViewCell *)cell didUpdateModel:(NvPhotoAlbumModel *)model;

@end

@interface NvPhotoAlbumCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) id delegate;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) NvPhotoAlbumModel *model ;
@end

NS_ASSUME_NONNULL_END
