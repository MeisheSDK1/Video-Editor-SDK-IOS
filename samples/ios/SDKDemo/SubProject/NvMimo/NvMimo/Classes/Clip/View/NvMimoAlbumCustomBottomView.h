//
//  NvMimoAlbumCustomBottomView.h
//  AFNetworking
//
//  Created by meishe20241218 on 2025/6/27.
//

#import <UIKit/UIKit.h>
#import "NvThemeModel.h"
@class NvMimoAlbumCustomBottomView;
NS_ASSUME_NONNULL_BEGIN
@protocol NvMimoAlbumCustomBottomViewDelegate <NSObject>

- (void)nvMimoAlbumCustomBottomViewClickFinishButton:(NvMimoAlbumCustomBottomView *)view;

- (void)nvMimoAlbumCustomBottomView:(NvMimoAlbumCustomBottomView *)view selectItemIndex:(NSUInteger)index;
@end
@interface NvMimoAlbumCustomBottomView : UIView
@property (nonatomic, weak) id <NvMimoAlbumCustomBottomViewDelegate>delegate;
@property (nonatomic, strong) NSMutableArray <NvShotModel *> *videoArr;
@property (nonatomic, assign) NSInteger targetIndex;

- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
