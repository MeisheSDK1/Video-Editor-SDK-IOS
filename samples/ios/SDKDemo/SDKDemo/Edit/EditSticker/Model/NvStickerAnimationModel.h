//
//  NvStickerAnimationModel.h
//  SDKDemo
//
//  Created by ms on 2021/4/20.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NvStickerAnimationModel : NSObject
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *packageId;
@end

