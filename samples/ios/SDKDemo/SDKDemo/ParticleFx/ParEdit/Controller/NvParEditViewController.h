//
//  NvParEditViewController.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/9/26.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <NvBaseCommon/NvBaseViewController.h>
#import "NVHeader.h"
#import "NvAlbumItem.h"

@interface NvParEditViewController : NvBaseViewController

@property (nonatomic, assign) NvEditMode editMode;
@property (nonatomic, strong) NSMutableArray <NvAlbumAsset *> *selectAssets;
@property (nonatomic, strong) NSMutableArray *installedFinshArray;

@end
