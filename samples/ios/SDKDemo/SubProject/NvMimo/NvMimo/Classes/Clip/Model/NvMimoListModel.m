//
//  NvMimoListModel.m
//  NvMimoDemo
//
//  Created by MS on 2020/7/28.
//  Copyright © 2020 MS. All rights reserved.
//

#import "NvMimoListModel.h"
#import "YYModel.h"

@implementation NvMimoListModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"assetId":@"id"};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    if (!dic[@"packageInfo"]) return NO;
    NSDictionary *dic1 = [NSJSONSerialization JSONObjectWithData:[dic[@"packageInfo"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    _packageInfo = [NvThemeModel yy_modelWithJSON:dic1];
    return YES;
}

@end
