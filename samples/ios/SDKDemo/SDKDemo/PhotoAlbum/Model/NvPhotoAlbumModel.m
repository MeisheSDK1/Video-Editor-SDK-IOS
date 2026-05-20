//
//  NvPhotoAlbumModel.m
//  SDKDemo
//
//  Created by MS on 2019/9/26.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvPhotoAlbumModel.h"
#import "YYModel.h"
#import <NvSDKCommon/NvUtils.h>

@implementation NvPhotoAlbumInfoModel

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [self yy_modelCopy];
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    if ([self.photosAlbumName containsString:@"|"]) {
        NSArray * albumNameArr = [self.photosAlbumName componentsSeparatedByString:@"|"] ;
        if ([NvUtils currentLanguagesIsChinese]) {
            self.photosAlbumName = albumNameArr[0];
        }else{
            self.photosAlbumName = albumNameArr[1];
        }
    }
    
    if ([self.photosAlbumTips containsString:@"|"]) {
        NSArray * albumTipsArr = [self.photosAlbumTips componentsSeparatedByString:@"|"] ;
        if ([NvUtils currentLanguagesIsChinese]) {
            self.photosAlbumTips = albumTipsArr[0];
        }else{
            self.photosAlbumTips = albumTipsArr[1];
        }
    }

    return YES;
}
@end

@implementation NvPhotoAlbumModel

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [self yy_modelCopy];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"assetId":@"id",
             @"packageUrl":@"zipUrl"};
}

//+ (NSDictionary *)modelContainerPropertyGenericClass {
//    return @{@"packageInfo" : [NvPhotoAlbumInfoModel class]};
//}
@end
