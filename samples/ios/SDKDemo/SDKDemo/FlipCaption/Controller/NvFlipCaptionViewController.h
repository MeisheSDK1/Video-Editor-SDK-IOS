//
//  NvFlipCaptionViewController.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import <NvSDKCommon/NvEditBaseViewController.h>
#import "NvAlbumItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvFlipCaptionViewController : NvEditBaseViewController

@property (nonatomic, strong) NSMutableArray <NvAlbumAsset *>*assets;

@end

NS_ASSUME_NONNULL_END
