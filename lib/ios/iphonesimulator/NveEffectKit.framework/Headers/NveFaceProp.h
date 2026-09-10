//
//  NveFaceProp.h
//  NveEffectKit
//
//  Created by meishe on 2023/6/1.
//

#import "NveItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NveFaceProp : NveItem

// packageId
@property(nonatomic, readonly) NSString *packageId;

+ (instancetype _Nullable)propWithPackageId:(NSString *)packageId;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
