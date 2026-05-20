//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Dec 29. 2016
//   Author:        Meishe video team
//================================================================================

/*! \file NvsCommonDef.h
 * */
#pragma once

#include <stdint.h>

#define NVS_EXPORT  __attribute__((visibility("default")))

/*! \if ENGLISH
*   \brief Audio sampling format
*   \else
*   \brief 音频采样格式
*   \endif
*/
typedef enum {
    NvsAudSmpFmt_None = -1,//!< \if ENGLISH None \else 无 \endif
    NvsAudSmpFmt_U8,       //!< \if ENGLISH unsigned 8 bit \else unsigned 8 bit \endif
    NvsAudSmpFmt_S16,      //!< \if ENGLISH signed 16 bit \else signed 16 bit \endif
    NvsAudSmpFmt_S32,      //!< \if ENGLISH signed 32 bit \else signed 32 bit \endif
    NvsAudSmpFmt_FLT,      //!< \if ENGLISH single precision float \else 单精度浮点数 \endif
    NvsAudSmpFmt_DBL,      //!< \if ENGLISH double precision float \else 双精度浮点数 \endif

    NvsAudSmpFmt_U8P,      //!< \if ENGLISH unsigned 8 bit,planer \else unsigned 8 bit 平面格式 \endif
    NvsAudSmpFmt_S16P,     //!< \if ENGLISH signed 16 bit,planer \else signed 16 bit 平面格式 \endif
    NvsAudSmpFmt_S32P,     //!< \if ENGLISH signed 32 bit,planer \else signed 32 bit 平面格式 \endif
    NvsAudSmpFmt_FLTP,     //!< \if ENGLISH single precision float,planar \else 单精度浮点数 平面格式\endif
    NvsAudSmpFmt_DBLP,     //!< \if ENGLISH double precision float,olanar \else 双精度浮点数 平面格式\endif

    NvsAudSmpFmt_Count
} NvsAudioSampleFormat;

/*! \if ENGLISH
*   \brief File type
*   \else
*   \brief 文件类型
*   \endif
*/
typedef enum {
    NvsAVFileType_Unknown = -1,      //!< \if ENGLISH Unknown \else 未知 \endif
    NvsAVFileType_AudioVideo = 0,    //!< \if ENGLISH Video \else 视频 \endif
    NvsAVFileType_Audio,             //!< \if ENGLISH Audio \else 音频 \endif
    NvsAVFileType_Image              //!< \if ENGLISH Image \else 图片 \endif
} NvsAVFileType;

/*! \if ENGLISH
*   \brief Video rotation
*   \else
*   \brief 视频旋转角度
*   \endif
*/
typedef enum
{
    NvsVideoRotation_0 = 0,
    NvsVideoRotation_90,
    NvsVideoRotation_180,
    NvsVideoRotation_270
} NvsVideoRotation;

/*! \if ENGLISH
*   \brief Video codec type
*   \else
*   \brief 视频编码类型
*   \endif
*/
typedef enum
{
    NvsVideoCodecType_Unknown = 0,
    NvsVideoCodecType_H264,
    NvsVideoCodecType_H265,
    NvsVideoCodecType_MPEG4,
    NvsVideoCodecType_VP8,
    NvsVideoCodecType_VP9,
    NvsVideoCodecType_WMV,
    NvsVideoCodecType_MPEG1,
    NvsVideoCodecType_MPEG2,
    NvsVideoCodecType_MJPEG,
    NvsVideoCodecType_AV1,
    NvsVideoCodecType_ProRes

} NvsVideoCodecType;

/*! \if ENGLISH
*   \brief Color Transfer Characteristic
*   \else
*   \brief 颜色转换曲线
*   \endif
*/
typedef enum
{
    NvsVideoColorTransfer_SDR_VIDEO = 0,  //SMPTE 170M transfer characteristic curve used by BT.601/BT.709/BT.2020. This is the curve used by most non-HDR video content.
    NvsVideoColorTransfer_ST2084, //SMPTE ST 2084 transfer function. This is used by some HDR video content
    NvsVideoColorTransfer_HLG //ARIB STD-B67 hybrid-log-gamma transfer function. This is used by some HDR video content.
} NvsVideoColorTransfer;

/*! \if ENGLISH
*   \brief HDR type
*   \else
*   \brief HDR 视频类型
*   \endif
*/
typedef enum
{
    NvsVideoHDRType_None = 0,  //This is used by SDR video content.
    NvsVideoHDRType_HDR10, //SMPTE ST 2084 transfer function. This is used by some HDR video content
    NvsVideoHDRType_HLG, //ARIB STD-B67 hybrid-log-gamma transfer function. This is used by some HDR video content.
    NvsVideoHDRType_HDR10Plus, //This is used by HDR10+ video content, has dynamic meta data.
    NvsVideoHDRType_DolbyVision, //This is used by dolby vision hdr video content, has dynamic meta data.
    NvsVideoHDRType_Vivid //This is used by vivid hdr video content, has dynamic meta data.
} NvsVideoHDRType;

/*! \if ENGLISH
*   \brief The role of the clip in the theme
*   \else
*   \brief 片段在主题中的角色
*   \endif
*/
typedef enum NvsRoleInTheme
{
    NvsRoleInThemeGeneral,   //!< \if ENGLISH General \else 通用 \endif
    NvsRoleInThemeTitle,     //!< \if ENGLISH Title \else 片头 \endif
    NvsRoleInThemeTrailer    //!< \if ENGLISH Trailer \else 片尾 \endif
} NvsRoleInTheme;

/*! \if ENGLISH
*   \brief Text alignment style
*   \else
*   \brief 字幕对齐方式
*   \endif
*/
typedef enum NvsTextAlignment
{
    NvsTextAlignmentLeft = 0,
    NvsTextAlignmentCenter,
    NvsTextAlignmentRight,
    NvsTextAlignmentTop,
    NvsTextAlignmentBottom,
    NvsTextAlignmentVCenter
} NvsTextAlignment;

/*! \if ENGLISH
*   \brief letter spacing type
*   \else
*   \brief 字间距类型
*   \endif
*/
typedef enum NvsLetterSpacingType
{
    NvsLetterSpacingTypePercentage = 0,
    NvsLetterSpacingTypeAbsolute
} NvsLetterSpacingType;

/*! \if ENGLISH
*   \brief Uses the default caption package
*   \else
*   \brief 使用默认的字幕包属性
*   \endif
*/
typedef enum NvsAssetDefaultParam
{
    USE_ASSET_DEFAULT_PARAM = 0,
    NOT_USE_ASSET_DEFAULT_PARAM
} NvsAssetDefaultParam;

/*! \if ENGLISH
*   \brief The type of clip in theme
*   \else
*   \brief 片段在主题中的类型
*   \endif
*/
typedef enum NvsCategory
{
    NvsDefaultCategory,   //!< \if ENGLISH Default type \else 默认类型 \endif
    NvsUserCategory,      //!< \if ENGLISH User-defined type \else 用户自定义类型 \endif
    NvsThemeCategory      //!< \if ENGLISH Theme category \else 主题类型 \endif
} NvsCategory;

/*! \if ENGLISH
*   \brief Video frame pixel format
*   \else
*   \brief 视频帧像素格式
*   \endif
*/
typedef enum NvsVideoFramePixelFormat
{
    NvsPixelFormat_Nv12,  //!< \if ENGLISH YUV  4:2:0   12bpp (Two channels, one channel is a continuous luminance channel, and the other channel is VU component interlaced) \else  YUV  4:2:0   12bpp ( 2通道, 一个通道是连续的亮度通道, 另一通道为VU分量交错 ) \endif
    NvsPixelFormat_YUV420, //!< \if ENGLISH YUV  4:2:0   12bpp (Three channels, one luminance channel, the other two are U component and V component channels, all channels are continuous) \else  YUV  4:2:0   12bpp ( 3通道, 一个亮度通道, 另两个为U分量和V分量通道, 所有通道都是连续的 ) \endif
    NvsPixelFormat_BGRA, //!< \if ENGLISH BGRA \else  BGRA \endif
    NvsPixelFormat_RGBA, //!< \if ENGLISH RGBA \else  RGBA \endif
    NvsPixelFormat_P010  //!< \if ENGLISH YUV  4:2:0   24bpp (2 channels, one channel is a continuous luminance channel, and the other channel is a VU component interlaced, Each channel occupies 16 bits, with the higher 10 bits being valid)， Only used by custom video fx buddy buffer \else  YUV  4:2:0   24bpp ( 2通道, 一个通道是连续的亮度通道, 另一通道为VU分量交错 每个通道占用16位，高10位有效) \endif
} NvsVideoFramePixelFormat;

/*! \if ENGLISH
*   \brief Video frame pixel format
*   \else
*   \brief 视频帧像素格式
*   \endif
*/
typedef enum NvsGpuVideoFrameFormat
{
    NvsGpuVideoFrameFormat_RGBA8,
    NvsGpuVideoFrameFormat_RGBA16F, //!< \if ENGLISH RGBA format  half float per channel\else  RGBA格式每个通道是半精度浮点（half float） \endif
 } NvsGpuVideoFrameFormat;

/*! \anchor VIDEO_FRAME_YUV_COLOR_MATRIX */
/*!
     *  \if ENGLISH
     *   @name The color matrix for YUV->RGB
     *  \else
     *   @name yuvd到rgb颜色转换矩阵
     *  \endif
     */
//!@{
typedef enum NvsVideoFrameYUVColorMatrix
{
    NvsVideoFrameYUVColorMatrix_Bt601, //!< ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL
    NvsVideoFrameYUVColorMatrix_Bt709, //!< ITU-R BT1361 / IEC 61966-2-4 xvYCC709 / SMPTE RP177 Annex B
    NvsVideoFrameYUVColorMatrix_Bt2020 //!< ITU-R BT2020
} NvsVideoFrameYUVColorMatrix;
//!@}

/*! \anchor VIDEO_FRAME_COLOR_TRANSFER */
/*!
     *  \if ENGLISH
     *   @name Color Transfer Characteristic
     *  \else
     *   @name 颜色转移特性
     *  \endif
     */
//!@{

typedef enum NvsVideoFrameColorTransfer
{
    NvsVideoFrameColorTransfer_sRGB,
    NvsVideoFrameColorTransfer_SMPTE2084, //!< SMPTE ST 2084 for 10-, 12-, 14- and 16-bit systems known as "PQ"
    NvsVideoFrameColorTransfer_ARIB_STD_B67 //!< ARIB STD-B67, known as "Hybrid log-gamma"
} NvsVideoFrameColorTransfer;

//!@}

/*! \anchor VIDEO_FRAME_COLOR_PRIMARIES */
/*!
     *  \if ENGLISH
     *   @name Chromaticity coordinates of the source primaries.
     *  \else
     *   @name 原色
     *  \endif
     */
//!@{
//!
typedef enum NvsVideoFrameColorPrimaries
{
    NvsVideoFrameColorPrimaries_Bt709, //!< RGB color space BT.709 standardized as Rec. ITU-R BT.709-5.
    NvsVideoFrameColorPrimaries_Bt2020, //!< RGB color space BT.2020 standardized as Rec. ITU-R BT.2020-1.
    NvsVideoFrameColorPrimaries_DisplayP3 //!< RGB color space Display P3 based on SMPTE RP 431-2-2007 and IEC 61966-2.1:1999.
} NvsVideoFrameColorPrimaries;

//!@}

/*! \if ENGLISH
*   \brief Video frame pixel format
*   \else
*   \brief 视频帧像素格式
*   \endif
*/
typedef enum NvsVideoResolutionBitDepth
{
    NvsVideoResolutionBitDepth_8Bit,            //!< \if ENGLISH The bit depth of processing pixel is 8bit \else 图像像素的位深度为8Bit  \endif
    NvsVideoResolutionBitDepth_16Bit_Float,     //!< \if ENGLISH The bit depth of processing pixel is half float \else 图像像素的位深度为半精度浮点  \endif
    NvsVideoResolutionBitDepth_Auto             //!< \if ENGLISH The bit depth of processing pixel is adaptive. For example, for videos with HDR in editing, half precision floating point will be used for HDR video processing in SDK \else 图像像素的位深度为自适应，比如在编辑中有HDR的视频，SDK内部处理HDR视频会使用半精度浮点  \endif
} NvsVideoResolutionBitDepth;


/*! \if ENGLISH
 *  \brief Live Window fill mode
 *  \else
 *  \brief Live Window 填充模式
 *  \endif
*/
typedef enum {
    /*! \if ENGLISH
     *  \brief The image is evenly filled and cropped if necessary (default mode).
     *
     *  ![] (PreserveAspectCrop.png)
     *  \else
     *  \brief 图像按比例均匀填充，必要时进行裁剪(默认模式)
     *
     *  ![] (PreserveAspectCrop.png)
     *  \endif
    */
    NvsLiveWindowFillModePreserveAspectCrop = 0,

    /*! \if ENGLISH
     *  \brief The image is evenly scaled to fit the window, without cropping.
     *
     *  ![] (PreserveAspectFit.png)
     *  \else
     *  \brief 图像均匀地缩放来适合窗口，没有裁剪。
     *
     *  ![] (PreserveAspectFit.png)
     *  \endif
    */
    NvsLiveWindowFillModePreserveAspectFit,

    /*! \if ENGLISH
     *  \brief The image is scaled to fit the window.
     *
     *  ![] (Stretch.png)
     *  \else
     *  \brief 图像被缩放来适合窗口
     *
     *  ![] (Stretch.png)
     *  \endif
    */
    NvsLiveWindowFillModeStretch
} NvsLiveWindowFillMode;


/*! \if ENGLISH
 *  \brief Live Window fill mode
 *  \else
 *  \brief Live Window 填充模式
 *  \endif
*/
typedef enum {
    NvsLiveWindowHDRDisplayMode_SDR = 0,                 //!< \if ENGLISH Forced to use SDR display, regardless of whether the device supports HDR display. \else 强制使用SDR的方式进行显示，不进行HDR到SDR转化，不管设备支不支持HDR显示 \endif
    NvsLiveWindowHDRDisplayMode_Device ,                //!< \if ENGLISH If the device supports HDR, use HDR display. \else 如果设备支持HDR，就使用HDR进行显示 \endif
    NvsLiveWindowHDRDisplayMode_TONE_MAP_SDR ,          //!< \if ENGLISH If the device supports HDR, use HDR display, and use NO HDR mode display if it is not supported. \else 如果设备支持HDR，就使用HDR进行显示，如果设备不支持，使用HDR转换为SDR进行显示 \endif
} NvsLiveWindowHDRDisplayMode;

/*! \if ENGLISH
*   \brief Rational value
*   \else
*   \brief 比例值
*   \endif
*/
typedef struct {
    int num;    //!< \if ENGLISH Numerator \else 分子 \endif
    int den;    //!< \if ENGLISH Denominator \else 分母 \endif
} NvsRational;

/*! \if ENGLISH
*   \brief Size
*   \else
*   \brief 尺寸
*   \endif
*/
typedef struct {
    int width;    //!< \if ENGLISH Width \else 宽度 \endif
    int height;   //!< \if ENGLISH Height \else 高度 \endif
} NvsSize;

/*! \if ENGLISH
*   \brief Rectangle
*   \else
*   \brief 矩形
*   \endif
*/
typedef struct {
    float left;   //!< \if ENGLISH Left \else left \endif
    float right;  //!< \if ENGLISH Right \else right \endif
    float bottom; //!< \if ENGLISH Bottom \else bottom \endif
    float top;    //!< \if ENGLISH Top \else top \endif
} NvsRect;

/*! \if ENGLISH
*   \brief Audio resolution
*   \else
*   \brief 音频解析度
*   \endif
*/
typedef struct {
    unsigned int sampleRate;            //!< \if ENGLISH Sampling rate \else 采样率 \endif
    NvsAudioSampleFormat sampleFormat;  //!< \if ENGLISH Sampling format \else 采样格式 \endif
    unsigned int channelCount;          //!< \if ENGLISH Channel count \else 声道数 \endif
} NvsAudioResolution;

/*! \if ENGLISH
*   \brief Video resolution
*   \else
*   \brief 视频解析度
*   \endif
*/
typedef struct {
    unsigned int imageWidth;  //!< \if ENGLISH Image width \else 图像宽度 \endif
    unsigned int imageHeight; //!< \if ENGLISH Image height \else 图像高度 \endif
    NvsRational imagePAR;     //!< \if ENGLISH Pixel ratio (only 1:1) \else 像素比（仅支持1:1）\endif
    NvsVideoResolutionBitDepth bitDepth;   //!< \if ENGLISH Default is 8Bit \else 默认是8Bit \endif
} NvsVideoResolution;

/*! \if ENGLISH
*   \brief Self-defined color.
*
*   In the SDK, attributes r, g, b, a in NvsColor class range [0, 1] instead of [0, 255].
*   \else
*   \brief 自定义颜色类
*
*   SDK中，NvsColor类属性r,g,b,a取值范围是[0,1]，而非[0,255]。
*   \endif
*/
typedef struct {
    float r, g, b, a;
} NvsColor;

/*! \if ENGLISH
*   \brief 2D coordinate structure
*   \else
*   \brief 二维坐标结构
*   \endif
*/
typedef struct {
    float x, y;
} NvsPosition2D;

/*! \if ENGLISH
*   \brief 3D coordinate structure
*   \else
*   \brief 三维坐标结构
*   \endif
*/
typedef struct {
    float x, y, z;
} NvsPosition3D;

/*! \if ENGLISH
*   \brief 2D coordinate point structure. The parameter type is double.
*   \else
*   \brief 二维坐标点结构。 参数类型为双精度浮点数。
*   \endif
*/
typedef struct {
    double x;
    double y;
} NvsPointD;

#define NVS_VIDEO_FRAME_MAX_PLANES     4

/*! \if ENGLISH
*   \brief Video frame information
*   \else
*   \brief 视频帧信息
*   \endif
*/
typedef struct{
    int frameWidth;                                 //!< \if ENGLISH The captured image's width (in pixel) \else 获取到图像的宽度(以像素为单位) \endif
    int frameHeight;                                //!< \if ENGLISH The captured image's height (in pixel) \else 获取到图像的高度(以像素为单位) \endif
    int planeRowPitch[NVS_VIDEO_FRAME_MAX_PLANES];  //!< \if ENGLISH The number of bytes per line in the frame of the flat image \else 平面图像每行在Frame中占的字节数 \endif
    void* planePtr[NVS_VIDEO_FRAME_MAX_PLANES];
    NvsVideoFramePixelFormat pixelFormat;           //!< \if ENGLISH The captured image's format \else 获取到图像的格式 \endif
    int64_t frameTimestamp;                         //!< \if ENGLISH The captured image's timestamp (in microseconds) \else 获取到图像的时间戳（单位微秒） \endif
    bool isRec601;                                  //!< \if ENGLISH  Whether color space is BT.601 \else 色彩空间是否是BT.601 \endif
    bool isFullRangeYUV;                            //!< \if ENGLISH  Whether the yuv value range is full range(0-255) \else YUV取值范围是否是fullRange(0-255) \endif

    int displayRotation;                            //!< \if ENGLISH Shows the angle at which the current image needs to be rotated \else 显示当前图像需要旋转的角度 \endif
    bool flipHorizontally;                          //!< \if ENGLISH Shows whether current image requires horizontal flip or not\else 显示当前图像需要不需要水平翻转 \endif
} NvsVideoFrameInfo;

/*! \if ENGLISH
*   \brief Video frame extra information
*   \else
*   \brief 视频帧扩展信息
*   \endif
*/
typedef struct{
    NvsVideoFrameInfo frameInfo;
    NvsVideoFrameYUVColorMatrix colorMatrix;
    NvsVideoFrameColorTransfer colorTransfer;
    NvsVideoFrameColorPrimaries colorPrimaries;
} NvsVideoFrameInfoExt;

#ifndef NV_AUDIO_MAX_CHANNEL_COUNT
    #define NV_AUDIO_MAX_CHANNEL_COUNT 8
#endif

typedef struct{
    void *data[NV_AUDIO_MAX_CHANNEL_COUNT];
    int planeSizeInBytes;   // For planar audio: size in bytes of each plane(channel)
                            // For packed audio: size in bytes of total samples
    int sampleRate;                     //!< \if ENGLISH audio sample rate \else 音频采样率 \endif
    int channelCount;                   //!< \if ENGLISH audio channel count \else 音频数据通道数 \endif
    NvsAudioSampleFormat sampleFormat;  //!< \if ENGLISH audio sample fromat \else 音频数据格式 \endif
    int actualSampleCount;              //!< \if ENGLISH actual audio sample count in audioBuffer \else 在audioBuffer中的有效采样数量 \endif
    int64_t timeStamp;                  //!< \if ENGLISH the timestamp of the audio sample buffer in microseconds \else 音频数据的时间戳（单位微秒） \endif
} NvsAudioSampleBuffers;

/*!
 *	\if ENGLISH
 *  \brief Audio sample info from capturing
 *	\else
 *  \brief 回调的采集音频信息
 *	\endif
 */
typedef struct{
    int sampleRate;              //!< \if ENGLISH audio sample rate \else 采样率 \endif
} NvsCapturedAudioSampleInfo;
