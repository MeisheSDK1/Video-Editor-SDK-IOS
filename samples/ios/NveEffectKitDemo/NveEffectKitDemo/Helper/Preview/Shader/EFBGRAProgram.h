//
//  EFBGRAProgram.h
//  EffectSdkDemo
//
//  Created by 美摄 on 2021/11/9.
//  Copyright © 2021 美摄. All rights reserved.
//

#import "EFGLProgram.h"

NS_ASSUME_NONNULL_BEGIN

@interface EFBGRAProgram : EFGLProgram
@property(assign, nonatomic) GLint displayPositionAttribute;
@property(assign, nonatomic) GLint displayTextureCoordinateAttribute;
@property(assign, nonatomic) GLint displayInputTextureUniform;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
