//
//  NvClipModel.m
//  NvMimoDemo
//
//  Created by MS on 2019/8/12.
//  Copyright © 2019 MS. All rights reserved.
//

#import "NvThemeModel.h"
#import "YYModel.h"

@implementation NvCaptionModel
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvCaptionModel *model = [self yy_modelCopy];
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    return [self yy_modelCopy];
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.duration = self.duration * 1000;
    self.inPoint = self.inPoint * 1000;
    return YES;
}

@end

@implementation NvSubTrackFilterModel

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvShotRepeatModel *model = [self yy_modelCopy];
    return model;
}

@end

@implementation NvShotRepeatModel

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvShotRepeatModel *model = [self yy_modelCopy];
    return model;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    // 可以在这里处理一些数据逻辑，如NSDate格式的转换
    self.start = self.start * 1000;
    self.end = self.end * 1000;
    self.originDuration = self.originDuration * 1000;
    return YES;
}

@end

@implementation NvShotSpeedModel

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvShotSpeedModel *model = [self yy_modelCopy];
    return model;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    // 可以在这里处理一些数据逻辑，如NSDate格式的转换
    self.start = self.start * 1000;
    self.end = self.end * 1000;
    return YES;
}

@end

@implementation NvShotModel
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvShotModel *model = [self yy_modelCopy];
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    return [self yy_modelCopy];
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    // 可以在这里处理一些数据逻辑，如NSDate格式的转换
    self.duration = self.duration * 1000;
    self.transLen = self.transLen * 1000;
    return YES;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"speed" : [NvShotSpeedModel class],
             @"repeat" : [NvShotRepeatModel class],
             @"subTrackFilter" : [NvSubTrackFilterModel class],
             };
}

@end

@implementation  NvShotTranslationModel
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [self yy_modelCopy];
}
@end

@implementation  NvThemeModel
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvThemeModel *model = [[[self class] allocWithZone:zone] init];
    model.isSelected = self.isSelected;
    model.name = [self.name copy];
    model.localPath = [self.localPath copy];
    model.supportedAspectRatio = [self.supportedAspectRatio copy];
    model.music = [self.music copy];
    model.endingFilter = [self.endingFilter copy];
    model.endingWatermark = [self.endingWatermark copy];
    model.timelineFilter = [self.timelineFilter copy];
    model.cover = [self.cover copy];
    model.preview = [self.preview copy];
    model.tag = [self.tag copy];
    model.titleFilter = [self.titleFilter copy];
    model.titleCaption = [self.titleCaption copy];
    model.titleCaptionDuration = self.titleCaptionDuration;
    model.titleFilterDuration = self.titleFilterDuration;
    model.musicDuration = self.musicDuration;
    model.shotsNumber = self.shotsNumber;
    model.endingFilterLen = self.endingFilterLen;
    model.translation = [[NSArray alloc] initWithArray:self.translation copyItems:YES];
    model.tagTranslation = [[NSArray alloc] initWithArray:self.tagTranslation copyItems:YES];
    model.shotInfos = [[NSArray alloc] initWithArray:self.shotInfos copyItems:YES];
    return model;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    // 可以在这里处理一些数据逻辑，如NSDate格式的转换
    self.musicDuration = self.musicDuration *1000;
    self.endingFilterLen = self.endingFilterLen *1000;
    self.titleCaptionDuration = self.titleCaptionDuration *1000;
    self.titleFilterDuration = self.titleFilterDuration *1000;
    return YES;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"translation" : [NvShotTranslationModel class],
             @"tagTranslation" : [NvShotTranslationModel class],
             @"shotInfos" : [NvShotModel class],
             @"captionArr" : [NvCaptionModel class],
            };
}
@end
