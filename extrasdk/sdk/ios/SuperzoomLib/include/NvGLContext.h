//
//  NvGLContext.h
//  SDKDemo
//
//  Created by shizhouhu on 2019/1/4.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGL.h>
#import <CoreVideo/CVOpenGLESTextureCache.h>


NS_ASSUME_NONNULL_BEGIN

@interface NvGLContext : NSObject

@property(readonly, retain, nonatomic) EAGLContext *context;
@property(readonly) CVOpenGLESTextureCacheRef coreVideoTextureCache;
@property(nonatomic, assign) int effectTextureId;

+ (NvGLContext *)sharedImageProcessingContext;
+ (void)useImageProcessingContext;
- (void)useAsCurrentContext;
- (void)useSharegroup:(EAGLSharegroup *)sharegroup;
@end

NS_ASSUME_NONNULL_END

