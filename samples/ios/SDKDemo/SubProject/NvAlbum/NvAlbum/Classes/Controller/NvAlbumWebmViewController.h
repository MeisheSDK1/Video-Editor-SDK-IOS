//
//  NvAlbumWebmViewController.h
//  NvAlbum
//
//  Created by MS on 2022/2/16.
//

#import <UIKit/UIKit.h>
#import "NvAlbumItem.h"
NS_ASSUME_NONNULL_BEGIN
@class NvAlbumWebmViewController;

@protocol NvAlbumWebmViewControllerDelegate <NSObject>

- (void)nvAlbumWebmViewController:(NvAlbumWebmViewController *)webmViewController selectAssets:(NSMutableArray <NvAlbumAsset *> *)assets;

@end

@interface NvAlbumWebmViewController : UIViewController
@property (nonatomic, strong) NSString *sourcePath;
@property (nonatomic, assign) id <NvAlbumWebmViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
