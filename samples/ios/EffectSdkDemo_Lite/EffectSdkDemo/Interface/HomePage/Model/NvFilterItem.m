//
//  StickerItem.m
//  Caption
//
//  Created by meishe01 on 2017/8/23.
//  Copyright © 2017年 NewAuto video team. All rights reserved.
//

#import "NvFilterItem.h"

 
@implementation NvFilterItem

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic{
    self.displayName = [dic objectForKey:@"name"];
    self.cover = [dic objectForKey:@"imageCover"];
    self.package = [dic objectForKey:@"fxFileName"];
    return YES;
}

-(UIImage *)coverImageObject{
    NSString* path = [[NSBundle mainBundle] bundlePath];
    path = [path stringByAppendingPathComponent:self.cover];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

@end

