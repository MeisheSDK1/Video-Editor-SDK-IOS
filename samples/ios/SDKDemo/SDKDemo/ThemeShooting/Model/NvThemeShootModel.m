//
//  NvThemeShootModel.m
//  SDKDemo
//
//  Created by ms on 2020/8/3.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvThemeShootModel.h"
#import "YYModel.h"

@implementation NvAlertModel

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvAlertModel *model = [self yy_modelCopy];
    return model;
}

@end

@implementation NvThemeShootModel

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvThemeShootModel *model = [self yy_modelCopy];
    return model;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.packageInfoModel = [NvPackageInfoModel yy_modelWithJSON:dic[@"packageInfo"]];
    self.isDownload = NO;
    return YES;
}
@end

@implementation NvPackageInfoModel

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvPackageInfoModel *model = [self yy_modelCopy];
    
    if (self.shotInfos.count > 0) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        
        for (int i = 0; i < self.shotInfos.count; i++) {
            [mutableArray addObject:self.shotInfos[i].copy];
        }
        model.shotInfos = mutableArray;
    }
    return model;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    ///可以在这里处理一些数据逻辑，如NSDate格式的转换
    ///You can handle some data logic here, such as conversion of NSDate format
    self.musicDuration = self.musicDuration * 1000;
    self.musicFadingTime = self.musicFadingTime * 1000;
    self.titleFilterDuration = self.titleFilterDuration * 1000;
    self.titleCaptionDuration = self.titleCaptionDuration * 1000;
    self.endingFilterLen = self.endingFilterLen * 1000;
    self.realCaptureVideos = [NSMutableArray array];
    return YES;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"ID":@"id"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"shotInfos":[NvShotInfoModel class]
            };
}

@end

@implementation NvSpeedModel

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvSpeedModel *model = [self yy_modelCopy];
    return model;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    ///可以在这里处理一些数据逻辑，如NSDate格式的转换
    ///You can handle some data logic here, such as conversion of NSDate format
    self.start = self.start * 1000;
    self.end = self.end * 1000;
    return YES;
}

@end

@implementation NvShotInfoModel

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvShotInfoModel *model = [self yy_modelCopy];
    
    if (self.alertInfo.count > 0) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        
        for (int i = 0; i < self.alertInfo.count; i++) {
            [mutableArray addObject:self.alertInfo[i].copy];
        }
        model.alertInfo = mutableArray;
    }
    
    if (self.speed.count > 0) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        
        for (int i = 0; i < self.speed.count; i++) {
            [mutableArray addObject:self.speed[i].copy];
        }
        model.speed = mutableArray;
    }
    
    return model;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"speed":[NvSpeedModel class],
        @"alertInfo":[NvAlertModel class]
    };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    ///可以在这里处理一些数据逻辑，如NSDate格式的转换
    ///You can handle some data logic here, such as conversion of NSDate format
    self.duration = self.duration * 1000;
    return YES;
}

@end
