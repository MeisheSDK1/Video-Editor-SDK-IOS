//
//  NvPackagingTemplateViewController.h
//  SDKDemo
//
//  Created by ms20180425 on 2021/6/25.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvEditBaseViewController.h"
#import "NvAlbumItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvPackagingTemplateViewController : NvEditBaseViewController

@property (nonatomic, strong) NSMutableArray <NvAlbumAsset *> *selectAssets;

@end

NS_ASSUME_NONNULL_END
