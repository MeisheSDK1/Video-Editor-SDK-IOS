//
//  NveFilterContainer.h
//  NveEffectKit
//
//  Created by meishe on 2023/5/25.
//

#import "NveFilter.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NveFilterContainer : NSObject

/// filter array
/// - Remark: 滤镜集合
@property(nonatomic, readonly) NSArray<NveFilter *> *filters;

- (BOOL)append:(NveFilter *)filter;

- (BOOL)remove:(NveFilter *)filter;

- (void)removeAll;

@end

NS_ASSUME_NONNULL_END
