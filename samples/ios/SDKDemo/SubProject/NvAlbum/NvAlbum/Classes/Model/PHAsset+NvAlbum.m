//
//  PHAsset+NvAlbum.m
//  NvAlbum
//
//  Created by meishe20241218 on 2025/6/19.
//

#import "PHAsset+NvAlbum.h"
#import <objc/runtime.h>
static const void *kIsShowLayer = @"kIsShowLayer";
static const void *kMaskRect = @"kMaskRect";
static const void *kIndexPath = @"kIndexPath";
static const void *kIsSelected= @"kIsSelected";
static const void *kIsLivePhoto = @"kIsLivePhoto";
static const void *kNumber = @"kNumber";
static const void *kAlbumVideoPath = @"kAlbumVideoPath";
static const void *kTrimIn = @"kTrimIn";
static const void *kTrimOut = @"kTrimOut";

@implementation PHAsset (NvAlbum)
- (void)setIsShowLayer:(BOOL)isShowLayer {
    objc_setAssociatedObject(self, kIsShowLayer, [NSNumber numberWithBool:isShowLayer], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isShowLayer {
    return [objc_getAssociatedObject(self, kIsShowLayer) boolValue];
}

- (void)setNumber:(NSInteger)number {
    objc_setAssociatedObject(self, kNumber, [NSNumber numberWithInteger:number], OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)number {
    return [objc_getAssociatedObject(self, kNumber) integerValue];
}

- (void)setIsLivePhoto:(BOOL)isLivePhoto {
    objc_setAssociatedObject(self, kIsLivePhoto, [NSNumber numberWithBool:isLivePhoto], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isLivePhoto {
    return [objc_getAssociatedObject(self, kIsLivePhoto) boolValue];
}

- (void)setAlbumVideoPath:(NSString *)albumVideoPath {
    objc_setAssociatedObject(self, kAlbumVideoPath, albumVideoPath, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)albumVideoPath {
    return objc_getAssociatedObject(self, kAlbumVideoPath);
}

@end
