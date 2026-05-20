//
//  StickerItem.h
//  Caption
//
//  Created by meishe01 on 2017/8/23.
//  Copyright © 2017年 NewAuto video team. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "NvsTimelineVideoFx.h"
#import "NvStickerCollectionViewCell.h"

@interface NvFilterItem : NSObject<NvStickerModelDelegate>

@property (strong, nonatomic) NSString *builtinName;
@property (strong, nonatomic) NSString *packageId;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *package;
@property (strong, nonatomic) NSString *cover;
@property (assign, nonatomic) BOOL selected;
@property (assign, nonatomic) BOOL longPressed;

@end

