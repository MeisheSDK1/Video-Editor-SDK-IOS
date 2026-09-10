//
//  NvAlbumBottomSelectView.h
//  NvAlbum
//
//  Created by meishe20241218 on 2025/6/26.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN
@class NvAlbumBottomSelectView;
@protocol NvAlbumBottomSelectViewDelegate <NSObject>
- (void)nvAlbumBottomSelectView:(NvAlbumBottomSelectView *)view selectItem:(NSUInteger)index;
@end

@interface NvAlbumBottomSelectView : UIView
@property (nonatomic, weak) id <NvAlbumBottomSelectViewDelegate>delegate;
@property (nonatomic, strong) NSMutableArray <PHAsset *>*assetDataSource;

- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
