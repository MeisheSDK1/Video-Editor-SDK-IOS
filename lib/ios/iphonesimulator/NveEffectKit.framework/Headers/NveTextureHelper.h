//
//  NveTextureHelper.h
//  NveEffectKit
//
//  Created by meishe on 2023/5/8.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NveTextureHelper : NSObject

+ (GLuint)createTextureWithWidth:(int32_t)width height:(int32_t)height;

@end

NS_ASSUME_NONNULL_END
