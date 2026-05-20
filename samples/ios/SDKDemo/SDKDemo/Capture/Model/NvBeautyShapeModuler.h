//
//  NvBeautyShapeModuler.h
//  SDKDemo
//
//  Created by 美摄 on 2022/4/15.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvBeautyShapeModuler : NSObject

+ (NvBeautyShapeModuler *)sharedInstance;

/// 获取degree 名字 Get the degree name
- (NSString *)getDegreeNameOfFxName:(NSString *)fxName;
@end

NS_ASSUME_NONNULL_END
