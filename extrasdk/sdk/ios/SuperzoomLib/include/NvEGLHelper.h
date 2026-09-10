//
//  NvEGLHelper.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/12/28.
//  Copyright © 2018 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

typedef NS_ENUM(NSUInteger, NvImageRotationMode) {
    kNvImageNoRotation,
    kNvImageRotateLeft,
    kNvImageRotateRight,
    kNvImageFlipVertical,
    kNvImageFlipHorizonal,
    kNvImageRotateRightFlipVertical,
    kNvImageRotateRightFlipHorizontal,
    kNvImageRotate180
};

NS_ASSUME_NONNULL_BEGIN

@interface NvEGLHelper : NSObject

+ (int)createDefaultShaderProgram;

+ (int)createProgram:(const GLchar *)vertexSource
      fragmentSource:(const GLchar *)fragmentSource;

+ (void)bindFrameBuffer:(int)textureId
            frameBuffer:(int)frameBuffer
                  width:(int)width
                 height:(int)height;

+ (void)checkGlError:(NSString *)op;

+ (const GLfloat *)textureCoordinatesForRotation:(NvImageRotationMode)rotationMode;
+ (GLfloat *)getVerticesArray:(int)texWidth texHeight:(int)texHeight displayWidth:(int)displayWidth displayHeight:(int)displayHeight;
@end

NS_ASSUME_NONNULL_END
