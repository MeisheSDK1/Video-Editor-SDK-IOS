//
//  NvsHandDetector.h
//  NvAISdk
//
//  Created by 美摄 on 2022/1/25.
//

#import <Foundation/Foundation.h>
#import "NvsAICommon.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    NvsHandGestureType_fringer  = 0,
    NvsHandGestureType_palm                 = 1,
    NvsHandGestureType_thumb                = 2,
    NvsHandGestureType_heart                = 3,
    NvsHandGestureType_v                   = 4,
    NvsHandGestureType_gun                 = 5,
    NvsHandGestureType_other               = 6,
}NvsHandGestureType;

enum NvsHandDetectErrorCode {
    NvsHandNoError = 0,
    NvsHandInvalidPtrInParam,
    NvsHandInvalidInputTensor,
    NvsHandInvalidOutputTensor,
    NvsHandInvalidOutputTensorType,
    NvsHandInvalidPixelPromat,
    NvsHandDetectFailed,
    NvsHandLandmarkFailed,
    NvsHandCreateDetectInterpreterFailed,
    NvsHandCreateDetectSessionFailed,
    NvsHandDetectRunSessionFailed,
    NvsHandImageConvertFailed,
    NvsHandReadModelFailed,
    NvsHandOutOfMemory,
    NvsHandCreateTrackInterpreterFailed,
    NvsHandCreateTrackSessionFailed,
    NvsHandDetectTrackSessionFailed,
    NvsHandDetectResizeFailed,
    NvsHandNotAuthorised,
    NvsHandModelInitError,
};

typedef struct NvsHand {
    NvsHandGestureType type;
    NvsAIRect rect;
    NvsAIPointF points_array[3];
    float score;
    size_t id;
}NvsHand;

typedef struct NvsHandOption {
    int detect_interpreter_thread_num; //interpreter internal, max=4
    int track_interpreter_thread_num;
    NvsDetectMode detect_mode;
}NvsHandOption;


@interface NvsHandDetector : NSObject

- (instancetype)init NS_UNAVAILABLE;

/*! \if ENGLISH
 *  \brief create NvsHandDetector.
 *  \param modelPath face detect model file path
 *  \return Returns BOOL value. YES indicates that the license verification is successful, and NO indicates that the verification fails.
 *  \else
 *  \brief 新建 NvsHandDetector。
 *  \param modelPath 手势检测 模型 文件路径
 *  \return 返回实例化对象。
 *  \endif
 */
+ (NvsHandDetector* _Nullable)createHandDetectorWithModelPath:(NSString *)modelPath
                                                        error:(NSError * _Nullable * _Nullable)outError;

/*! \if ENGLISH
 *  \brief create NvsHandDetector.
 *  \param modelPath face detect model file path
 *  \param option   option for NvsHandDetector
 *  \return Returns BOOL value. YES indicates that the license verification is successful, and NO indicates that the verification fails.
 *  \else
 *  \brief 新建 NvsHandDetector。
 *  \param modelPath 手势检测 模型 文件路径
 *  \param option   配置参数
 *  \return 返回实例化对象。
 *  \endif
 */
+ (NvsHandDetector* _Nullable)createHandDetectorWithModelPath:(NSString *)modelPath
                                                       option:(NvsHandOption)option
                                                        error:(NSError * _Nullable * _Nullable)outError;

//NvsHand hand;
//[value getValue:&hand];
-(NSArray<NSValue*>* _Nullable)detectBuffer:(NvsImageBuffer)imageBuffer
                                     rotate:(NvcVideoRotation)rotate
                                      error:(NSError * _Nullable * _Nullable)outError;

-(void)setMaxDetectCount:(int)maxDetectCount;

-(void)setDetectInterval:(int)interval;

-(void)setForceDetectInterval:(int)interval;

-(void)setConfidenceThreshold:(float)f;

-(void)setMinPixelSize:(int)s;

@end

NS_ASSUME_NONNULL_END
