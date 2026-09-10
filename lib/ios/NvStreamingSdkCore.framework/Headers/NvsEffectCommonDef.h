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

/*! \file NvsEffectCommonDef.h
 * */
#pragma once

#include <stdint.h>

#define NVS_EXPORT  __attribute__((visibility("default")))

/*! \if ENGLISH
*   \brief Rational value
*   \else
*   \brief 比例值
*   \endif
*/
typedef struct {
    int num;    //!< \if ENGLISH Numerator \else 分子 \endif
    int den;    //!< \if ENGLISH Denominator \else 分母 \endif
} NvsEffectRational;

/*! \if ENGLISH
*   \brief Video resolution
*   \else
*   \brief 视频解析度
*   \endif
*/
typedef struct {
    unsigned int imageWidth;        //!< \if ENGLISH Image width \else 图像宽度 \endif
    unsigned int imageHeight;       //!< \if ENGLISH Image height \else 图像高度 \endif
    NvsEffectRational imagePAR;     //!< \if ENGLISH Pixel ratio (only 1:1) \else 像素比（仅支持1:1）\endif
} NvsEffectVideoResolution;

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
} NvsEffectColor;

/*! \if ENGLISH
*   \brief 2D coordinate structure
*   \else
*   \brief 二维坐标结构
*   \endif
*/
typedef struct {
    float x, y;
} NvsEffectPosition2D;

/*! \if ENGLISH
*   \brief 3D coordinate structure
*   \else
*   \brief 三维坐标结构
*   \endif
*/
typedef struct {
    float x, y, z;
} NvsEffectPosition3D;

/*! \if ENGLISH
*   \brief Video frame pixel format
*   \else
*   \brief 视频帧像素格式
*   \endif
*/
typedef enum NvsEffectVideoFramePixelFormat
{
    NvsEffectPixelFormat_Nv12,      //!< \if ENGLISH YUV  4:2:0   12bpp (Two channels, one channel is a continuous luminance channel, and the other channel is VU component interlaced) \else  YUV  4:2:0   12bpp ( 2通道, 一个通道是连续的亮度通道, 另一通道为VU分量交错 ) \endif
    NvsEffectPixelFormat_YUV420,    //!< \if ENGLISH YUV  4:2:0   12bpp (Three channels, one luminance channel, the other two are U component and V component channels, all channels are continuous) \else  YUV  4:2:0   12bpp ( 3通道, 一个亮度通道, 另两个为U分量和V分量通道, 所有通道都是连续的 ) \endif
    NvsEffectPixelFormat_BGRA,
    NvsEffectPixelFormat_ARGB2101010,
    NvsEffectPixelFormat_P010     //!< \if ENGLISH YUV  4:2:0   24bpp (2 channels, one channel is a continuous luminance channel, and the other channel is a VU component interlaced, Each channel occupies 16 bits, with the higher 10 bits being valid)， Only used by custom video fx buddy buffer \else  YUV  4:2:0   24bpp ( 2通道, 一个通道是连续的亮度通道, 另一通道为VU分量交错 每个通道占用16位，高10位有效) \endif
 } NvsEffectVideoFramePixelFormat;

/*! \if ENGLISH
*   \brief Video frame pixel format
*   \else
*   \brief 视频帧像素格式
*   \endif
*/
typedef enum NvsEffectGpuVideoFrameFormat
{
    NvsEffectGpuVideoFrameFormat_RGBA8,
    NvsEffectGpuVideoFrameFormat_RGBAF16, //!< \if ENGLISH RGBA format  half float per channel\else  RGBA格式每个通道是半精度浮点（half float） \endif
} NvsEffectGpuVideoFrameFormat;


/*! \anchor VIDEO_FRAME_YUV_COLOR_MATRIX */
/*!
     *  \if ENGLISH
     *   @name The color matrix for YUV->RGB
     *  \else
     *   @name yuvd到rgb颜色转换矩阵
     *  \endif
     */
//!@{
typedef enum NvsEffectVideoFrameYUVColorMatrix
{
    NvsEffectVideoFrameYUVColorMatrix_Bt601, //!< ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL
    NvsEffectVideoFrameYUVColorMatrix_Bt709, //!< ITU-R BT1361 / IEC 61966-2-4 xvYCC709 / SMPTE RP177 Annex B
    NvsEffectVideoFrameYUVColorMatrix_Bt2020 //!< ITU-R BT2020
} NvsEffectVideoFrameYUVColorMatrix;
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

typedef enum NvsEffectVideoFrameColorTransfer
{
    NvsEffectVideoFrameColorTransfer_sRGB,
    NvsEffectVideoFrameColorTransfer_SMPTE2084, //!< SMPTE ST 2084 for 10-, 12-, 14- and 16-bit systems known as "PQ"
    NvsEffectVideoFrameColorTransfer_ARIB_STD_B67 //!< ARIB STD-B67, known as "Hybrid log-gamma"
} NvsEffectVideoFrameColorTransfer;

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
typedef enum NvsEffectVideoFrameColorPrimaries
{
    NvsEffectVideoFrameColorPrimaries_Bt709, //!< RGB color space BT.709 standardized as Rec. ITU-R BT.709-5.
    NvsEffectVideoFrameColorPrimaries_Bt2020, //!< RGB color space BT.2020 standardized as Rec. ITU-R BT.2020-1.
    NvsEffectVideoFrameColorPrimaries_DisplayP3 //!< RGB color space Display P3 based on SMPTE RP 431-2-2007 and IEC 61966-2.1:1999.
} NvsEffectVideoFrameColorPrimaries;

//!@}
//!
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
    NvsEffectVideoFramePixelFormat pixelFormat;     //!< \if ENGLISH The captured image's format \else 获取到图像的格式 \endif
    int64_t frameTimestamp;                         //!< \if ENGLISH The captured image's timestamp (in microseconds) \else 获取到图像的时间戳（单位微秒） \endif
    bool isRec601;                                  //!< \if ENGLISH Whether it is BT.601 \else 是否是BT.601 \endif
    bool isFullRangeYUV;

    int displayRotation;                            //!< \if ENGLISH Shows the angle at which the current image needs to be rotated \else 显示当前图像需要旋转的角度 \endif
    bool flipHorizontally;                          //!< \if ENGLISH Shows whether current image requires horizontal flip or not\else 显示当前图像需要不需要水平翻转 \endif
} NvsEffectVideoFrameInfo;

/*! \if ENGLISH
*   \brief Video frame extra information
*   \else
*   \brief 视频帧扩展信息
*   \endif
*/
typedef struct{
    NvsEffectVideoFrameInfo frameInfo;
    NvsEffectVideoFrameYUVColorMatrix colorMatrix;
    NvsEffectVideoFrameColorTransfer colorTransfer;
    NvsEffectVideoFrameColorPrimaries colorPrimaries;
} NvsEffectVideoFrameInfoExt;

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
} NvsEffectRect;
