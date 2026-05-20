//
//  NvMimoConvert.h
//  NvMimoDemo
//
//  Created by MS on 2019/12/17.
//  Copyright © 2019 MS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface NvMimoConvert : NSObject
- (void)startConvertWithOriginFilePath:(NSString *)originPath trimIn:(int64_t)trimIn trimOut:(int64_t)trimOut ;
- (void)finishBlock:(void(^)(BOOL isFinish, NSString *outputPath))finishBlock;

- (void)cancel;
- (void)stop ;
@end

NS_ASSUME_NONNULL_END
