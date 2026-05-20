//
//  EFDataSource.h
//  EffectSdkDemo
//
//  Created by 美摄 on 2021/3/11.
//  Copyright © 2021 美摄. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvStickerModel.h"
#import "NvFilterItem.h"
//#import "NvBeautyTypeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EFDataSource : NSObject

-(NSArray<NvStickerModel*>*)stickerArray;

-(NSMutableArray<NvFilterItem*>*)loadFxArray;

-(NSMutableArray<NvFilterItem*>*)loadCompoundCaptionArray;

-(NSMutableArray<NvFilterItem*>*)loadAnimatedStickerArray;

-(NSMutableArray<NvFilterItem*>*)loadTransitionArray;


@end

NS_ASSUME_NONNULL_END
