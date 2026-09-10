//
//  NvsFaceDetector.h
//  NvAISdk
//
//  Created by 美摄 on 2022/1/21.
//

#import <Foundation/Foundation.h>
#import "NvsAICommon.h"

NS_ASSUME_NONNULL_BEGIN


typedef struct NvsFace{
    NvsAIRect rect;
    float faceScore;
    float landmarkScore;
    NvsAIPointF points_array[106];
    size_t id;
    bool extra_points;
    NvsAIPointF extra_points_array[134];
    bool angles;
    float pitch;
    float yaw;
    float roll;
}NvsFace;

typedef struct NvsFaceOption {
    int detect_interpreter_thread_num; //interpreter internal, max=4
    int landmark_interpreter_thread_num; //interpreter internal, max=4
    int track_interpreter_thread_num;
    NvsDetectMode detect_mode;
    bool detect240;
}NvsFaceOption;

@interface NvsFaceDetector : NSObject

- (instancetype)init NS_UNAVAILABLE;

/*! \if ENGLISH
 *  \brief create NvsFaceDetector.
 *  \param modelPath face detect model file path
 *  \return Returns BOOL value. YES indicates that the license verification is successful, and NO indicates that the verification fails.
 *  \else
 *  \brief 新建 NvsFaceDetector。
 *  \param modelPath 人脸检测 模型 文件路径
 *  \return 返回实例化对象。
 *  \endif
 */
+ (NvsFaceDetector* _Nullable)createFaceDetectorWithModelPath:(NSString *)modelPath
                                                        error:(NSError * _Nullable * _Nullable)outError;

/*! \if ENGLISH
 *  \brief create NvsFaceDetector.
 *  \param modelPath face detect model file path
 *  \param option   option for NvsFaceDetector
 *  \return Returns BOOL value. YES indicates that the license verification is successful, and NO indicates that the verification fails.
 *  \else
 *  \brief 新建 NvsFaceDetector。
 *  \param modelPath 人脸检测 模型 文件路径
 *  \param option   配置参数
 *  \return 返回实例化对象。
 *  \endif
 */
+ (NvsFaceDetector* _Nullable)createFaceDetectorWithModelPath:(NSString *)modelPath
                                                       option:(NvsFaceOption)option
                                                        error:(NSError * _Nullable * _Nullable)outError;

//NvsFace face;
//[value getValue:&face];
-(NSArray<NSValue*>* _Nullable)detectBuffer:(NvsImageBuffer)imageBuffer
                                     rotate:(NvcVideoRotation)rotate
                                      error:(NSError * _Nullable * _Nullable)outError;

// this func only detect bbox without landmark, so in result only rect is useful
-(NSArray<NSValue*>* _Nullable)detectBoxWithBuffer:(NvsImageBuffer)imageBuffer
                                            rotate:(NvcVideoRotation)rotate
                                             error:(NSError * _Nullable * _Nullable)outError;

///
-(void)setMaxFaceCount:(int)maxFaceCount;
-(void)setMinFaceWidth:(int)minFaceWidth;
-(void)setMinFaceHeight:(int)minFaceHeight;
-(void)setDetectInterval:(int)interval;
-(void)setForceDetectInterval:(int)interval;
-(void)setFaceConfidenceThreshold:(float)threshold;
-(void)setValidRollRange:(float)a b:(float)b;
-(void)setValidYawRange:(float)a b:(float)b;
-(void)setValidPitchRange:(float)a b:(float)b;
-(void)setEyeCloseDistanceRatioThreshold:(float)threshold;
-(void)setEyeCloseValidPitchRange:(float)a b:(float)b;
-(void)setTrackFailedResetFace:(bool)trackFailedResetFace;

@end

NS_ASSUME_NONNULL_END

