//
//  NvQuickSplicingCollectionViewCell.h
//  AFNetworking
//
//  Created by ms on 2022/1/13.
//

#import <UIKit/UIKit.h>
#import "NvAlbumItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvQuickSplicingCollectionViewCell : UICollectionViewCell
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NvAlbumAsset *asset;

@property (nonatomic, copy)   void (^addAssetBlock)(NSInteger index);

@end

NS_ASSUME_NONNULL_END
