//
//  NvAlbumCategoryCell.h
//  NvAlbum
//
//  Created by meishe20241218 on 2025/6/25.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface NvAlbumCategoryCell : UICollectionViewCell

- (void)renderCellWithAsset:(PHAssetCollection *)assetCollection;

- (void)setSelectCount:(NSUInteger)selectCount;
@end

NS_ASSUME_NONNULL_END
