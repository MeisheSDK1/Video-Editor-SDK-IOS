//
//  NvCaptionThemeItem.h
//  SDKDemo
//
//  Created by Meicam on 2018/6/28.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NvCaptionThemeItem : NSObject

@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *packageId;
@property (nonatomic, assign) BOOL isInstall;

@end
