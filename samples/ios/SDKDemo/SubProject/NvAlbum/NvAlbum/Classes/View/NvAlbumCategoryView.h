//
//  NvAlbumCategoryView.h
//  NvAlbum
//
//  Created by meishe20241218 on 2025/6/25.
//

#import <UIKit/UIKit.h>
@class NvAlbumCategoryView;
NS_ASSUME_NONNULL_BEGIN
@protocol NvAlbumCategoryViewDelegate <NSObject>

- (void)nvAlbumCategoryView:(NvAlbumCategoryView *)albumView didSelectCellAtIndex:(NSUInteger)index;

@end
@interface NvAlbumCategoryView : UIView
@property (nonatomic, weak) id <NvAlbumCategoryViewDelegate>delegate;
@property (nonatomic, strong) NSArray *assetDataSource;
@property (nonatomic, assign) NSUInteger selectCount;
@end

NS_ASSUME_NONNULL_END
