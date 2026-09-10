//
//  NveRenderOutput.h
//  NveEffectKit
//
//  Created by meishe on 2023/5/8.
//

#import "NveRenderConfig.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NveRenderError) {
    NveRenderError_noError = 0,
    NveRenderError_unknown = -1,
    NveRenderError_invalidTexture = -2,
    NveRenderError_invalidPixelFormat = -3,
    NveRenderError_inputParam = -4
};

@interface NveRenderOutput : NSObject

@property(nonatomic, assign) NveRenderError errorCode;

@property(nonatomic, strong) NveTexture *texture;

@property(nonatomic, assign) CVPixelBufferRef _Nullable pixelBuffer;

@end

NS_ASSUME_NONNULL_END
