//
//  NvBoomerang.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/12/19.
//  Copyright © 2018 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsTimeline.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvBoomerang : NSObject

+ (NvsTimeline *)createTimeline:(NSString *)videoSourcePath;

@end

NS_ASSUME_NONNULL_END
