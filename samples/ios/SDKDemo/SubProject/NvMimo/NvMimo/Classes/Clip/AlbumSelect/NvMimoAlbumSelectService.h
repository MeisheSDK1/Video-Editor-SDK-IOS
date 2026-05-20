//
//  NvMimoAlbumSelectService.h
//  AFNetworking
//
//  Created by meishe20241218 on 2025/6/27.
//

#import <Foundation/Foundation.h>
#import <NvAlbum/NvAlbumViewController.h>
#import "NvThemeModel.h"
#import "NvMimoAlbumCustomBottomView.h"
NS_ASSUME_NONNULL_BEGIN

@protocol NvMimoAlbumSelectServiceDelegate <NSObject>



@end

@interface NvMimoAlbumSelectService : NSObject <NvAlbumViewControllerSelectStrategy,NvMimoAlbumCustomBottomViewDelegate>
@property (nonatomic, weak) id <NvMimoAlbumSelectServiceDelegate>delegate;
@property (nonatomic, strong) NvMimoAlbumCustomBottomView *albumCustomView;
@property (nonatomic, strong) NvThemeModel *themeModel;
@property (nonatomic, copy) NSString *dirPath;
//当前镜头数据
//current shot data
@property (nonatomic, strong) NvShotModel *currentShotModel;
//Is it replacement material mode
//是否是替换素材模式
@property (nonatomic, assign) BOOL isReplaceMode;
//If this is the first time timeline is created
//是否是第一次创建timeline
@property (nonatomic, assign) BOOL firstCreatTimeline;

//clear the cache
//清除缓存
- (void)clearCache;
@end

NS_ASSUME_NONNULL_END
