//
//  MyCustomVideoFx.m
//  customvideofx
//
//  Created by xuewen on 8/2/17.
//  Copyright © 2017 cdv. All rights reserved.
//

#import "MyCustomVideoFx2.h"
#import "NvsCustomVideoFx.h"
#import <Accelerate/Accelerate.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES3/glext.h>
#import "PixelBufferTool.h"

@interface MyCustomVideoFx2 ()

@end

@implementation MyCustomVideoFx2

- (instancetype)init{
    if (self = [super init]) {
        //TODO...
    }
    return self;
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
    // renderContext->inputBuddyVideoFrame.planePtr中是原始buffer信息，你需要把这个原始buffer上传到output纹理上，记得考虑大小和角度以及是否镜像。
    {   // 直接将buffer上传
        // 这里是简单改一下宽高，把纹理的宽高赋值给buffer，这样可能上传的数据显示不全，角度不对，只是演示。
        // 如果seek、play是用fullsizeflag，那么这个纹理是和buffer一样大小的。
        CFAbsoluteTime begin = CFAbsoluteTimeGetCurrent();
        renderContext->inputBuddyVideoFrame.frameWidth = renderContext->inputVideoFrame.width;
        renderContext->inputBuddyVideoFrame.frameHeight = renderContext->inputVideoFrame.height;
        [renderHelper uploadHostBufferToOpenGLTexture:&renderContext->inputBuddyVideoFrame textureId:renderContext->outputVideoFrame.texId];
        CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
        NSLog(@"end - begin: %fs",end - begin);
        return;
    }
    {   // 将buffer转换后上传
        // 这里demo简单把图像转换一下，然后上传到output纹理上，因为demo seek默认用了livewindowsize，这里需要处理旋转和缩放(建议GPU处理，比较耗时)
        CFAbsoluteTime begin = CFAbsoluteTimeGetCurrent();
        CVPixelBufferRef inputBuffer = [PixelBufferTool pixelBufferWithVideoFrame:renderContext->inputBuddyVideoFrame];
        CVPixelBufferRef convertBuffer = nil;
        // 转为BGRA
        if (renderContext->inputBuddyVideoFrame.pixelFormat == NvsPixelFormat_Nv12) {
            convertBuffer = [PixelBufferTool create32BGRAPixelBufferFromNV12:inputBuffer];
            CVPixelBufferRelease(inputBuffer);
        } else {
            convertBuffer = inputBuffer;
        }
        // scale
        CVPixelBufferRef scaleBuffer = [PixelBufferTool createPixelBuffer:convertBuffer scale:1.0 * renderContext->inputVideoFrame.proxyScale.num / renderContext->inputVideoFrame.proxyScale.den];
        CVPixelBufferRelease(convertBuffer);
        CVPixelBufferRef outBuffer = scaleBuffer;
        // rotation
        if (renderContext->inputBuddyVideoFrame.displayRotation == 90 || renderContext->inputBuddyVideoFrame.displayRotation == 270) {
            outBuffer = [PixelBufferTool createPixelBuffer:scaleBuffer rotation:-M_PI * renderContext->inputBuddyVideoFrame.displayRotation / 180.0];
            CVPixelBufferRelease(scaleBuffer);
        }
        NvsVideoFrameInfo videoFrame;
        CVPixelBufferLockBaseAddress(outBuffer, kCVPixelBufferLock_ReadOnly);
        [PixelBufferTool fillVideoFrameInfoFromPixelBuffer:outBuffer videoFrameInfo:&videoFrame];
        CVPixelBufferUnlockBaseAddress(outBuffer, kCVPixelBufferLock_ReadOnly);
        
        [renderHelper uploadHostBufferToOpenGLTexture:&videoFrame textureId:renderContext->outputVideoFrame.texId];
        CVPixelBufferRelease(outBuffer);
        CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
        NSLog(@"end - begin: %fs",end - begin);
    }
}

- (bool)needInputBuddyFrame {
    return true;
}

@end
