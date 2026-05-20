//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2017. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jun 13. 2017
//   Author:        Meishe video team
//================================================================================
#pragma once

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
#import <CoreVideo/CVPixelBuffer.h>
#import "NvsCommonDef.h"

/*! \if ENGLISH
 *  \brief The mode of the video frame receiver
 *  \else
 *  \brief 视频帧接收器模式
 *  \endif
*/
typedef enum
{
    NvsVideoFrameReceiverMode_Texture,       //!< \if ENGLISH The mode of the texture ID. \else 纹理ID模式 \endif
    NvsVideoFrameReceiverMode_CVPixelBuffer  //!< \if ENGLISH The mode of the CVPixelBuffer object.\else CVPixelBuffer对象模式 \endif
} NvsVideoFrameReceiverMode;


@class NvsVideoFrameReceiver;

@protocol NvsVideoFrameReceiverDelegate <NSObject>
@optional

/*! \if ENGLISH
 *  \brief Notifies the receiver that a video frame has been rendered.
 *  If the receiver wants to obtain the permission to use the video frame, it needs to return YES, otherwise the permission which use the video frame will not obtained.
 *  After obtaining the usage permission, users can use the OpenGL ES texture ID of the video frame to draw in users' own EAGLContext. Certainly,it's based on that the EAGLContext must be in the same EAGLSharegroup as the EAGLContext of MeiShe SDK.
 *  The receiver must call reclaimVideoFrame after ensuring that the texture is no longer used, so that Meishe SDK can recycle it, otherwise a leak will occur!
 *  Also, if the texture has been drawn by the receiver, please call glFlush() before calling reclaimVideoFrame to ensure synchronization of the texture usage.
 *  Note: This callback function is called in other threads of the engine, not the main thread!
 *  \param receiver The NvsVideoFrameReceiver object corresponding to the callback interface
 *  \param videoFrameTextureId The OpenGL ES texture ID for video frames
 *  \param videoSize The size of the video frame (in pixels)
 *  \param timelinePos The timestamp of the video frame (in microseconds)
 *  \return Returns the BOOL value. YES means that the receiver has obtained the permission to use the video frame. NO means the permission which use the video frame will not obtained.
 *  \else
 *  \brief 通知接收者一个视频帧已经渲染完成
 *  如果接收者想要获取该视频帧的使用权则需要返回YES，否则并不获取视频帧的使用权。获取使用权后则
 *  可以使用该视频帧的OpenGL ES纹理ID在自己的EAGLContext之中进行绘制，当然前提是该
 *  EAGLContext必须与美摄引擎的EAGLContext处于同一个EAGLSharegroup中。接收者在确保不再使用
 *  这个纹理之后一定要调用reclaimVideoFrame让美摄SDK回收这个纹理，否则会出现泄漏！另外，如果
 *  在接收者已经使用了该纹理进行了绘制，那么调用reclaimVideoFrame之前请调用glFlush()来确保
 *  对纹理使用的同步。
 *  注意：这个回调函数是在引擎的某个线程调用的，并非主线程！
 *  \param receiver 该回调接口对应的NvsVideoFrameReceiver对象
 *  \param videoFrameTextureId 视频帧的OpenGL ES纹理ID
 *  \param videoSize 视频帧的尺寸，单位为像素
 *  \param timelinePos 视频帧的时间戳，单位为微秒
 *  \return 返回BOOL值，为YES表示接收者获取了该视频帧的使用权，如果为NO表示接收者未获取该视频帧的使用权
 *  \endif
*/
- (BOOL)didVideoFrameReceived:(NvsVideoFrameReceiver *)receiver
          videoFrameTextureId:(unsigned int)videoFrameTextureId
                    videoSize:(CGSize)videoSize
                  timelinePos:(int64_t)timelinePos;

/*! \if ENGLISH
 *  \brief Notifies the receiver that a video frame has been rendered.
 *
 *  Note: This callback function is called in other threads of the engine, not the main thread!
 *  \param receiver The NvsVideoFrameReceiver object corresponding to the callback interface
 *  \param pixelBuffer The CVPixelBuffer object for video frames
 *  \param videoSize The size of the video frame (in pixels)
 *  \param timelinePos The timestamp of the video frame (in microseconds)
 *  \else
 *  \brief 通知接收者一个视频帧已经渲染完成
 *
 *  注意：这个回调函数是在引擎的某个线程调用的，并非主线程！
 *  \param receiver 该回调接口对应的NvsVideoFrameReceiver对象
 *  \param pixelBuffer 视频帧的CVPixelBuffer对象
 *  \param videoSize 视频帧的尺寸，单位为像素
 *  \param timelinePos 视频帧的时间戳，单位为微秒
 *  \endif
*/
- (void)didVideoFrameReceived:(NvsVideoFrameReceiver *)receiver
                  pixelBuffer:(CVPixelBufferRef)pixelBuffer
                    videoSize:(CGSize)videoSize
                  timelinePos:(int64_t)timelinePos;

@end


/*! \if ENGLISH
 *  \brief The receiver of the video frame.
 *
 *  The video frame rendered by the operation of positioning or playing the timeline will pass.
 *  \warning In the NvsVideoFrameReceiver class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 视频帧接收器
 *
 *  对时间线进行定位或者播放的操作所渲染出来的视频帧会通过。
 *  \warning NvsVideoFrameReceiver类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsVideoFrameReceiver : NSObject

@property (nonatomic, readonly) NvsVideoFrameReceiverMode mode;
@property (nonatomic, weak) id<NvsVideoFrameReceiverDelegate> delegate;

@property (nonatomic, strong, readonly) NSLock *lock;


- (instancetype)init;

- (instancetype)initWithMode:(NvsVideoFrameReceiverMode)type;

/*! \if ENGLISH
 *  \brief Reclaims a video frame that has acquired usage permission.
 *  \param videoFrameTextureId The OpenGL ES texture ID of the video frame to be recycled.
 *  \else
 *  \brief 回收一个已经获取到使用权的视频帧
 *  \param videoFrameTextureId 待回收的视频帧的OpenGL ES纹理ID
 *  \endif
*/
- (void)reclaimVideoFrame:(unsigned int)videoFrameTextureId;

@end

