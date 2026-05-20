//
//  NvPhotoAlbumFlowLayout.h
//  SDKDemo
//
//  Created by MS on 2019/9/24.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol NvPhotoAlbumCollectionViewFlowLayoutDelegate <NSObject>

- (void)collectioViewScrollToIndex:(NSInteger)index;
@end

@interface NvPhotoAlbumFlowLayout : UICollectionViewFlowLayout

@property (nonatomic,assign) id<NvPhotoAlbumCollectionViewFlowLayoutDelegate>delegate;
@property (nonatomic,assign) BOOL needAlpha;
@property (nonatomic, assign) CGPoint targetPoint;
@end

NS_ASSUME_NONNULL_END
