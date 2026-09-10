//
//  NvQuickSplicingController.h
//  AFNetworking
//
//  Created by ms on 2022/1/12.
//

#import "NvEditBaseViewController.h"
#import "NvAlbumItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvQuickSplicingController : NvEditBaseViewController

- (instancetype)initWithAssets:(NSArray <NvAlbumAsset *> *)assets editMode:(NvEditMode)editMode;

@end

NS_ASSUME_NONNULL_END
