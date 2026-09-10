//
//  NvListCategoryModel.m
//  SDKDemo
//
//  Created by ms20180425 on 2022/3/17.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvListCategoryModel.h"
#import <objc/runtime.h>

@implementation NvListCategoryModel

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NvListCategoryModel *model = [self yy_modelCopy];
    return model;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    NvListCategoryModel *model = [NvListCategoryModel new];
    model.materialType = self.materialType;
    model.category = self.category;
    model.categoryList = self.categoryList;
    model.kindID = self.kindID;
    model.displayName = self.displayName;
    model.displayNameZhCn = self.displayNameZhCn;
    model.selectedNoCover = self.selectedNoCover;
    model.selectedCover = self.selectedCover;
    return model;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"kindID" : @"id"};
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    unsigned int count = 0;
    Ivar *ivarLists = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        const char* name = ivar_getName(ivarLists[i]);
        NSString* strName = [NSString stringWithUTF8String:name];
        [aCoder encodeObject:[self valueForKey:strName] forKey:strName];
    }
    free(ivarLists);
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        unsigned int count = 0;
        Ivar *ivarLists = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; i++) {
            const char* name = ivar_getName(ivarLists[i]);
            NSString* strName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            id value = [aDecoder decodeObjectForKey:strName];
            if (value) {
                [self setValue:value forKey:strName];
            }
        }
        free(ivarLists);
    }
    return self;
}

@end
