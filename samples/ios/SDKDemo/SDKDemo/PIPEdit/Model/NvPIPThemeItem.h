//
//  NvPIPThemeItem.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/16.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NvPIPThemeItem : NSObject

@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *bundleImagePath;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *packageId1;
@property (nonatomic, strong) NSString *packageId2;
@property (nonatomic, assign) BOOL isInstall;

@end
