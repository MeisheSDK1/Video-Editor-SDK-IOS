//
//  PhotoPickerCompletionHandler.h
//  Test
//
//  Created by Mac-Mini on 2025/6/24.
//


#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MediaType) {
    MediaTypeAll,
    MediaTypeImage,
    MediaTypeVideo,
    MediaTypeLivePhoto
};

@protocol PhotoPickerDelegate <NSObject>
- (void)photoPicker:(UIViewController *)picker didSelectAssets:(NSArray<PHAsset *> *)assets;
- (void)photoPickerDidCancel:(UIViewController *)picker;
@end

typedef void (^DidFinishPickingBlock)(NSArray<PHAsset *> *assets);
typedef void (^DidCancelBlock)(void);

@interface PhotoPickerCompletionHandler : NSObject
@property (nonatomic, copy) DidFinishPickingBlock didFinishPicking;
@property (nonatomic, copy) DidCancelBlock didCancel;
@end

typedef NS_ENUM(NSInteger, SelectionMode) {
    SelectionModeSingle,
    SelectionModeMultiple
};

@interface PhotoPickerController : UIViewController

@property (nonatomic, weak) id<PhotoPickerDelegate> delegate;
@property (nonatomic, strong) PhotoPickerCompletionHandler *completionHandler;
@property (nonatomic, assign) SelectionMode selectionMode;
@property (nonatomic, assign) NSInteger maxSelectionCount;

@end

@interface PhotoCell : UICollectionViewCell
- (void)configureWithAsset:(PHAsset *)asset;
- (void)setSelected:(BOOL)selected index:(NSInteger)index;
@end

@interface AlbumCell : UITableViewCell
- (void)configureWithCollection:(PHAssetCollection *)collection;
@end

@interface PHAsset (iCloud)
- (void)isAssetInICloudWithCompletion:(void (^)(BOOL isInICloud))completion;
@end

NS_ASSUME_NONNULL_END
