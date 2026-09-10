//
//  NvAlbumBottomSelectedCell.h
//  NvAlbum
//
//  Created by meishe20241218 on 2025/6/26.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface NvAlbumBottomSelectedCell : UICollectionViewCell
- (void)renderCellWithAsset:(PHAsset *)asset;
@end

NS_ASSUME_NONNULL_END
