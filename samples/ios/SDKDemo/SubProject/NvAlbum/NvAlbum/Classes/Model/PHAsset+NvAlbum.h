//
//  PHAsset+NvAlbum.h
//  NvAlbum
//
//  Created by meishe20241218 on 2025/6/19.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHAsset (NvAlbum)
//是否需要展示蒙层
// Whether mask should be shown
@property (nonatomic, assign) BOOL isShowLayer;

//被选择的个数
// The number of selected
@property (nonatomic, assign) NSInteger number;

//是否是动态图
//Is it a livePhoto 
@property (nonatomic, assign) BOOL isLivePhoto;

////从相册缓存到沙盒路径
//// from album cache to sandbox path
@property (nonatomic, copy) NSString *albumVideoPath;

@end

NS_ASSUME_NONNULL_END
