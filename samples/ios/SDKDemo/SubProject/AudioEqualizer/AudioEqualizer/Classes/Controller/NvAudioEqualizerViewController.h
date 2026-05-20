//
//  NvAudioEqualizerViewController.h
//  SDKDemo
//
//  Created by MS on 2021/6/23.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvEditBaseViewController.h"
#import "NvAlbumItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvAudioEqualizerViewController : NvEditBaseViewController
///所选视频素材
///the selected video assets from album
@property (nonatomic, strong) NSMutableArray <NvAlbumAsset *> *selectAssets;
@end

NS_ASSUME_NONNULL_END
