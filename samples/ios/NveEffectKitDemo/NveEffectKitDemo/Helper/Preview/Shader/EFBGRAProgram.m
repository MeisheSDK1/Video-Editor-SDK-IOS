//
//  EFBGRAProgram.m
//  EffectSdkDemo
//
//  Created by 美摄 on 2021/11/9.
//  Copyright © 2021 美摄. All rights reserved.
//

#import "EFBGRAProgram.h"

// Hardcode the vertex shader for standard filters, but this can be overridden
NSString *const kBGRAVertexShaderString = @"\
 attribute vec4 position;\
 attribute vec4 inputTextureCoordinate;\
 "
                                          @"varying vec2 textureCoordinate;\
 void main()\
 {\
     gl_Position = "
                                          @"position;\
     textureCoordinate = inputTextureCoordinate.xy;\
 }\
 ";

NSString *const kBGRAFragmentShaderString = @"\
 varying highp vec2 textureCoordinate;\
 \
 uniform sampler2D "
                                            @"inputImageTexture;\
 \
 void main()\
 {\
     gl_FragColor = "
                                            @"texture2D(inputImageTexture, textureCoordinate);\
 }\
";

@implementation EFBGRAProgram

- (instancetype)init {
    self = [super initWithVertexShaderString:kBGRAVertexShaderString fragmentShaderString:kBGRAFragmentShaderString];
    if (self) {
        if (!self.initialized) {
            [self addAttribute:@"position"];
            [self addAttribute:@"inputTextureCoordinate"];
            if (![self link]) {
                NSString *progLog = [self programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [self fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [self vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        self.displayPositionAttribute = [self attributeIndex:@"position"];
        self.displayTextureCoordinateAttribute = [self attributeIndex:@"inputTextureCoordinate"];
        self.displayInputTextureUniform = [self uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputTexture" for the fragment shader
    }
    return self;
}

- (void)use {
    [super use];
    glEnableVertexAttribArray(self.displayPositionAttribute);
    glEnableVertexAttribArray(self.displayTextureCoordinateAttribute);
}

- (void)unuse {
    glDisableVertexAttribArray(self.displayPositionAttribute);
    glDisableVertexAttribArray(self.displayTextureCoordinateAttribute);
}

@end
