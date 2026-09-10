//
//  NvBeautyTypeModel.m
//  NvARSceneFxModule
//
//  Created by ms20221114 on 2022/11/23.
//

#import "NvBeautyTypeModel.h"

@implementation NvBeautyTypeModel

- (instancetype)init {
    self = [super init];
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    NvBeautyTypeModel *model = [NvBeautyTypeModel new];
    model.isBeauty = self.isBeauty;
    model.type = self.type;
    model.name = self.name;
    model.selectedCoverImg = self.selectedCoverImg;
    model.selected = self.selected;
    model.value = self.value;
    model.radiusValue = self.radiusValue;
    model.coverImage = self.coverImage;
    model.isOperation = self.isOperation;
    model.fxName = self.fxName;
    model.defaultValue = self.defaultValue;
    model.defaultRadiusValue = self.defaultRadiusValue;
    model.switchSelected = self.switchSelected;
    model.labelColor = self.labelColor;
    model.bgColor = self.bgColor;
    model.textColor = self.textColor;
    model.uuid = self.uuid;
    model.packageUrl = self.packageUrl;
    model.degreeName = self.degreeName;
    model.canReplace = self.canReplace;
    model.open = self.open;
    model.defaultShapePackage = self.defaultShapePackage;
    return model;
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"coverImage" : @[@"coverImage",@"cover"],
        @"fxName" : @[@"fxName",@"className"],
    };
}


@end
