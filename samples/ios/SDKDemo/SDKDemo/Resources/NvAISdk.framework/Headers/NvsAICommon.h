//
//  NvsAICommon.h
//  NvsAIContext
//
//  Created by 董凌晓 on 2021/8/5.
//

#ifndef NvsAICommon_h
#define NvsAICommon_h
#include <sys/types.h>
#define NVS_IMAGE_BUFFER_MAX_POINTER     4

typedef enum {
    NvcVideoRotation_0 = 0,
    NvcVideoRotation_90,
    NvcVideoRotation_180,
    NvcVideoRotation_270
} NvcVideoRotation;

typedef enum {
    NvcPixelFormat_YUV420P = 0,     // planar YUV 4:2:0, 12bpp, (1 Cr & Cb sample per 2x2 Y samples)
    NvcPixelFormat_NV12,        // planar YUV 4:2:0, 12bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
    NvcPixelFormat_ARGB8,       // packed ARGB 8:8:8:8, 32bpp, ARGBARGB...
    NvcPixelFormat_RGBA8,       // packed RGBA 8:8:8:8, 32bpp, RGBARGBA...
    NvcPixelFormat_BGRA8,       // packed BGRA 8:8:8:8, 32bpp, BGRABGRA...
} NvcPixelFormat;

typedef enum {
    NvcYuvColorspaceInvalid = -1,
    NvcYuvColorspaceRec709 = 0,
    NvcYuvColorspaceRec601,
    NvcYuvColorspaceRec2020
}NvcYuvColorspace;

typedef enum {
    NvcYuvVideoRangeInvalid = -1,
    NvcYuvVideoRange = 0,
    NvcYuvFullRange
}NvcYuvRange;

typedef struct NvsImageBuffer {
    void *data[NVS_IMAGE_BUFFER_MAX_POINTER];
    int pitch[NVS_IMAGE_BUFFER_MAX_POINTER];
    int width;
    int height;
    NvcPixelFormat kPixelFormat;
    NvcYuvColorspace colorspace;
    NvcYuvRange yuvRange;
}NvsImageBuffer;

/*! \if ENGLISH
 *  \brief error type
 *  \else
 *  \错误类型
 *  \endif
*/
typedef enum {
    NvsAIErrorCode_No_Error = 0,
    NvsAIErrorCode_Model_Init_Error,       //模型初始化失败
    NvsAIErrorCode_Input_Image_Error,      //输入图像错误
    NvsAIErrorCode_Model_Inference_Error,  //模型推理失败
    NvsAIErrorCode_Out_Of_Memory,          //内存错误
    NvsAIErrorCode_Not_Authorised,         //功能授权失败
} NvsAIErrorCode;


typedef struct NvsAIRect {
    int left;
    int top;
    int right;
    int bottom;
}NvsAIRect;

typedef struct NvsAIPointF {
    float fX;
    float fY;
}NvsAIPointF;

typedef enum {
    NvsDetectMode_video,
    NvsDetectMode_image,
    NvsDetectMode_semiimage,
}NvsDetectMode;

typedef enum {
    NvsForwardType_Forward_CPU,
    NvsForwardType_Forward_GPU,// cuda
}NvsForwardType;

typedef struct NvsModelInitOption {
    int thread_num;
    NvsForwardType forward_type;
}NvsModelInitOption;

#endif /* NvsAICommon_h */
