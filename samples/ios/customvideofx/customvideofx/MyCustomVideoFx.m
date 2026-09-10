//
//  MyCustomVideoFx.m
//  customvideofx
//
//  Created by xuewen on 8/2/17.
//  Copyright © 2017 cdv. All rights reserved.
//

#import "MyCustomVideoFx.h"
#import "NvsCustomVideoFx.h"

#import <OpenGLES/ES2/gl.h>

@interface MyCustomVideoFx ()

@end

@implementation MyCustomVideoFx {
    int _shaderProgram;
    int _program_attrLoc_pos;
    int _program_attrLoc_texCoord;
    int _program_uniformLoc_saturation;
    NSString * _VERTEX_SHADER;
    NSString * _FRAGMENT_SHADER;
    
    Byte * _verticesBuffer;
    float _verticesData[16];
    float _saturationGain;
}

- (instancetype)init{
    if (self = [super init]) {
        //TODO...
        _shaderProgram = 0;
        _program_attrLoc_pos = -1;
        _program_attrLoc_texCoord = -1;
        _program_uniformLoc_saturation = -1;
        
        _VERTEX_SHADER = @"attribute highp vec2 posAttr;\n"
                            @"attribute highp vec2 texCoordAttr;\n"
                            @"varying highp vec2 texCoord;\n"
                            @"void main()\n"
                            @"{\n"
                            @"    texCoord = texCoordAttr;\n"
                            @"    gl_Position = vec4(posAttr, 0, 1);\n"
                            @"}\n";
        _FRAGMENT_SHADER = @"uniform sampler2D sampler;\n"
                            @"uniform lowp float saturation;\n"
                            @"varying highp vec2 texCoord;\n"
                            @"void main()\n"
                            @"{\n"
                            @"    lowp vec4 color = texture2D(sampler, texCoord);\n"
                            @"    lowp float minRGB = min(color.r, min(color.g, color.b));\n"
                            @"    lowp float maxRGB = max(color.r, max(color.g, color.b));\n"
                            @"    lowp vec3 lightness = vec3((minRGB + maxRGB) / 2.0);\n"
                            @"    gl_FragColor = vec4(mix(lightness, color.rgb, saturation), color.a);\n"
                            @"}\n";
        _verticesBuffer = (Byte*)malloc(4*4*4);
    }
    return self;
}

- (void)setSaturationGain:(float)saturationGain
{
    // Note: The JAVA language guarantees atomicity for float member variables, so setting m_saturationGain does not require any synchronization
    // 注意：JAVA语言可以保证对float类型成员变量的原子性，因此在这里设置m_saturationGain无需任何同步机制
    _saturationGain = fmax(fmin(saturationGain, [self getMaxSaturationGain]), [self getMinSaturationGain]);
}

- (float) getSaturationGain
{
    return _saturationGain;
}

- (float) getMinSaturationGain
{
    return 0.0f;
}

- (float) getMaxSaturationGain
{
    return 2.0f;
}

/*
* The SDK calls this method for custom video effects to allow the user to initialize some resources
* This method will be called at most once during the lifetime of your custom video effect. If the effect is never actually used, the method will not be called.
* This method is called from the special effects rendering thread of the Beautiful Photography SDK engine, and the current thread has an EGL Context bound.
*/
/*
 *  美摄SDK对自定义视频特效调用此方法以便让用户初始化一些资源
 *  这个方法在自定义视频特效的生命周期里最多只会被调用一次。如果该特效从未被真正使用过，则这个方法将不会被调用。
 *  这个方法是在美摄SDK引擎的特效渲染线程里调用，并且当前线程已经绑定了一个EGL Context。
 */
- (void)didInit {
    
}

/*
* The SDK calls this method for custom video effects to allow the user to clean up assets
* This method will only be called at most once during the lifetime of the custom video effect, and it will always be called after onInit. If onInit is not called, the method will not be called.
* This method is called from the special effects rendering thread of the Beautiful Photography SDK engine, and the current thread has an EGL Context bound.
*/
/*
 *  美摄SDK对自定义视频特效调用此方法以便让用户清理资源
 *  这个方法在自定义视频特效的生命周期里最多只会被调用一次，而且一定会在onInit之后调用，如果onInit没有被调用则也不会调用该方法。
 *  这个方法是在美摄SDK引擎的特效渲染线程里调用，并且当前线程已经绑定了一个EGL Context。
 */
- (void)didCleanup {
    // Clean up global resources
    // 清理全局资源
    if (_shaderProgram != 0) {
        glDeleteProgram(_shaderProgram);
        _shaderProgram = 0;
    }
    
    free(_verticesBuffer);
    _verticesBuffer = NULL;
}

/*
* The SDK calls this method for custom video effects in order to do some resource preprocessing
* This method is called multiple times during the lifetime of the custom video effect and is always called after onInit, typically before each playback timeline.
* Normally you need to do things like build the shader program inside this function.
* This method is called from the special effects rendering thread of the Beautiful Photography SDK engine, and the current thread has an EGL Context bound.
*/
/*
 *  美摄SDK对自定义视频特效调用此方法以便让进行一些资源预处理
 *  这个方法在自定义视频特效的生命周期里会被多次调用，而且一定会在onInit之后调用，一般来讲是在每次播放时间线之前调用。
 *  一般来讲用户需要在此函数里面进行诸如构建shader program的工作。
 *  这个方法是在美摄SDK引擎的特效渲染线程里调用，并且当前线程已经绑定了一个EGL Context。
 */
- (void)didPreloadResources {
    // We can avoid stuttering by building the shader program during prefetching
    // But this example captures a custom video effect, so there is no prefetching.
    // We can take advantage of prefetching to build a shader program if we apply it to a timeline related custom video effect
    // 通过在预取资源过程中构建shader program可以避免卡顿
    // 但是本示例程序展示的是一个采集自定义视频特效，因此没有预取的过程。
    // 如果将其应用在时间线相关的自定义视频特效则可充分利用预取来构建shader program
    [self prepareShaderProgram];
}

/*!
* \brief The SDK calls this method on custom video effects to apply the effect to the input video frame
*
* The user implements the method to process the input video frame and write the result to the output video frame to render the effect.
* This method is called from the special effects rendering thread of the Beautiful Photography SDK engine, and the current thread has an EGL Context bound.
* The current thread already has an FBO bound, you just need to bind the color buffer, depth buffer... OK
* Note: Be sure to reset the OpenGL ES context state to the default state after rendering, such as when the user renders glEnable(GL_BLEND),
* Always call glDisable(GL_BLEND) after rendering, as blend is turned off by default. About the default state of OpenGL ES context
* please refer to https://www.khronos.org/opengles/
* Warning: If the OpenGL ES context is not reset to its default state after rendering, it may cause errors in subsequent effects rendering!
*
* \param renderContext effect renders the context object
* \param renderHelper interface, be careful not to save this interface, only use it in didRender!
*/
/*!
 *  \brief 美摄SDK对自定义视频特效调用此方法以便对输入视频帧进行特效处理
 *
 *  用户实现这个方法对输入视频帧进行处理并将结果写入到输出视频帧中去以便完成特效渲染。
 *  这个方法是在美摄SDK引擎的特效渲染线程里调用，并且当前线程已经绑定了一个EGL Context。
 *  当前线程已经绑定了一个FBO，用户只需在相应的attachment point上面绑定color buffer, depth buffer...即可
 *  注意：请务必在渲染完成后，将OpenGL ES context的状态复位到默认状态，比如用户渲染过程中调用了glEnable(GL_BLEND),
 *  则渲染完成后一定要调用glDisable(GL_BLEND),因为默认状态下blend是关闭的。关于OpenGL ES context的默认状态
 *  请参考https://www.khronos.org/opengles/
 *  警告：如果渲染完成后，没有将OpenGL ES context的状态复位到默认状态，则可能导致后续特效渲染发生错误！
 *
 *  \param renderContext 特效渲染上下文对象
 *  \param renderHelper 特效渲染辅助方法接口，注意用户不要保存这个接口，只能在didRender里面使用它！
 */
- (void)didRender:(struct NvsCustomVideoFxRenderContext *)renderContext
     renderHelper:(NvsCustomVideoFxRenderHelper *)renderHelper
{
    if ([self prepareShaderProgram] == false)
        return;
    
    // The output video frame texture is bound to the color attachment 0 of FBO
    // 将输出视频帧纹理绑定到FBO的color attachment 0
    glBindTexture(GL_TEXTURE_2D, renderContext->outputVideoFrame.texId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, renderContext->outputVideoFrame.texId, 0);
    
    glViewport(0, 0, renderContext->outputVideoFrame.width, renderContext->outputVideoFrame.height);
    
    // NOTE: Clear the color frame buffer, this step is not useful for rendering the result, as it will overwrite the target texture.
    // However, this operation is necessary because mobile Gpus are usually tile based, which is a hinting operation for OpenGL driver.
    // We can tell the OpenGL driver to ignore the original contents of the color frame buffer, reducing memory copy, improving performance, and reducing power consumption
    // NOTE: 将color frame buffer清空，这一步对于渲染结果并无意义，因为后面的渲染过程会将目标纹理整个重写。
    // 但这个操作还是有必要的，因为mobile的GPU一般都是tile based架构，这个操作对于OpenGL driver是一个hinting，
    // 可以告诉OpenGL driver不必理会color frame buffer原来的内容，减少了memory copy，提高性能，降低功耗
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(_shaderProgram);
    // Set the saturation gain
    // Note: JAVA guarantees atomicity for float members, so reading m_saturationGain does not require any synchronization
    // 设定饱和度的增益
    // 注意：JAVA语言可以保证对float类型成员变量的原子性，因此在这里读取m_saturationGain无需任何同步机制
    glUniform1f(_program_uniformLoc_saturation, _saturationGain);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, renderContext->inputVideoFrame.texId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    
    // Fill in vertex data
    // 填写顶点数据
    bool isUpsideDownTexture = renderContext->inputVideoFrame.isUpsideDownTexture;
    _verticesData[0] = -1;
    _verticesData[1] = 1;
    _verticesData[2] = 0;
    _verticesData[3] = isUpsideDownTexture ? 0 : 1;
    _verticesData[4] = -1;
    _verticesData[5] = -1;
    _verticesData[6] = 0;
    _verticesData[7] = isUpsideDownTexture ? 1 : 0;
    _verticesData[8] = 1;
    _verticesData[9] = 1;
    _verticesData[10] = 1;
    _verticesData[11] = isUpsideDownTexture ? 0 : 1;
    _verticesData[12] = 1;
    _verticesData[13] = -1;
    _verticesData[14] = 1;
    _verticesData[15] = isUpsideDownTexture ? 1 : 0;
    
    [self setVerticesBuffer];
    glVertexAttribPointer(_program_attrLoc_pos, 2, GL_FLOAT, false, 4 * 4, _verticesBuffer);
    glVertexAttribPointer(_program_attrLoc_texCoord, 2, GL_FLOAT, false, 4 * 4, _verticesBuffer + 8);
    
    glEnableVertexAttribArray(_program_attrLoc_pos);
    glEnableVertexAttribArray(_program_attrLoc_texCoord);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisableVertexAttribArray(_program_attrLoc_pos);
    glDisableVertexAttribArray(_program_attrLoc_texCoord);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
}

- (void)float2Bytes:(Byte*) bytes_temp float_variable:(float)float_variable
{
    memcpy(bytes_temp, (unsigned char*) (&float_variable), 4);
}

- (void)setVerticesBuffer
{
    for (int i = 0; i < 16; i++) {
        [self float2Bytes:_verticesBuffer + i*4 float_variable:_verticesData[i]];
    }
}

- (bool)prepareShaderProgram {
    if (_shaderProgram != 0)
        return true;
    
    _shaderProgram = [self createProgram:[_VERTEX_SHADER cStringUsingEncoding:NSISOLatin1StringEncoding] fragmentSource:[_FRAGMENT_SHADER cStringUsingEncoding:NSISOLatin1StringEncoding]];
    if (_shaderProgram == 0)
        return false;
    
    _program_attrLoc_pos = glGetAttribLocation(_shaderProgram, "posAttr");
    _program_attrLoc_texCoord = glGetAttribLocation(_shaderProgram, "texCoordAttr");
    _program_uniformLoc_saturation = glGetUniformLocation(_shaderProgram, "saturation");
    
    int samplerUnifromLoc = glGetUniformLocation(_shaderProgram, "sampler");
    glUseProgram(_shaderProgram);
    glUniform1i(samplerUnifromLoc, 0);
    
    return true;
}

- (int)loadShader:(int)shaderType source:(const GLchar *)source
{
    int shader = glCreateShader(shaderType);
    NSString *strShaderType = [[NSString alloc] initWithFormat:@"%d",shaderType];
    [self checkGlError:[@"glCreateShader type=" stringByAppendingString:strShaderType]];
    
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    GLint compiled;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if (compiled == 0) {
        GLint logLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
        glDeleteShader(shader);
        shader = 0;
    }
    return shader;
}

- (int)createProgram:(const GLchar *)vertexSource fragmentSource:(const GLchar *)fragmentSource
{
    int vertexShader = [self loadShader:GL_VERTEX_SHADER source:vertexSource];
    if (vertexShader == 0) {
        return 0;
    }
    int fragShader = [self loadShader:GL_FRAGMENT_SHADER source:fragmentSource];
    if (fragShader == 0) {
        return 0;
    }
    
    int program = glCreateProgram();
    if (program == 0) {
        NSLog(@"Could not create program");
    }
    glAttachShader(program, vertexShader);
    [self checkGlError:@"glAttachShader"];
    glAttachShader(program, fragShader);
    [self checkGlError:@"glAttachShader"];
    glLinkProgram(program);
    
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus != GL_TRUE) {
        GLint logLength;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
        glDeleteProgram(program);
        program = 0;
    }
    glDeleteShader(vertexShader);
    glDeleteShader(fragShader);
    return program;
}

- (void)checkGlError:(NSString *)op
{
    int error;
    while ((error = glGetError()) != GL_NO_ERROR) {
        NSLog(@"%@: glError %d", op, error);
    }
}

@end
