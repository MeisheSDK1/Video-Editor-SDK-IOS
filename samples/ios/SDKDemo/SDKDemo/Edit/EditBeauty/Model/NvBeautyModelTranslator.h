//
//  NvBeautyModelTranslator.h
//  SDKDemo
//
//  Created by Meishe on 2022/11/28.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NvBeautyTypeModel;
@class NvMakeupModel;
@class NvMakeupToolModel;
NS_ASSUME_NONNULL_BEGIN

@interface NvBeautyModelTranslator : NSObject

- (NSMutableArray *)translateBeautyModelWithMakeupEffect:(NvMakeupToolModel *)model referenceArr:(NSArray *)beautyArr;

- (NSMutableArray *)translateShapeModelWithMakeupEffect:(NvMakeupToolModel *)model referenceArr:(NSArray *)shapeArr;

- (NSMutableArray *)translateMicroShapeModelWithMakeupEffect:(NvMakeupToolModel *)model referenceArr:(NSArray *)microShapeArr;
@end

NS_ASSUME_NONNULL_END
