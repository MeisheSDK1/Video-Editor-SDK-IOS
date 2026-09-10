//
//  NvCoverMakerViewController.h
//  SDKDemo
//
//  Created by meicam on 2020/10/19.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <NvSDKCommon/NvEditBaseViewController.h>
#import "NvAlbumItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvCoverMakerViewController : NvEditBaseViewController

@property (nonatomic, strong) NSMutableArray <NvAlbumAsset *> *selectAssets;

@end

NS_ASSUME_NONNULL_END
