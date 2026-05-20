//
//  NvMaskMenuItem.h
//  SDKDemo
//
//  Created by ms on 2021/3/5.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDKDemo-Swift.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvMaskMenuItem : NSObject
@property (nonatomic, assign) NvClipMaskType maskType;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *image;
@end

NS_ASSUME_NONNULL_END
