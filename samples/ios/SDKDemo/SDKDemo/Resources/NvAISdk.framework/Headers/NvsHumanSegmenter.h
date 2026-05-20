//
//  NvsHumanSegmenter.h
//  NvsAIContext
//
//  Created by 美摄 on 2022/1/21.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import "NvsAICommon.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct NvsHumanSegmentOption {
    int thread_num ; //should be [1, 4],recommend 2
}NvsHumanSegmentOption;

typedef struct NvsHumanSegmentMask {
    uint8_t * _Nullable mask;
    int pitch;
    int width;
    int height;
}NvsHumanSegmentMask;


/// 背景区域检测
@interface NvsHumanSegmenter : NSObject

- (instancetype)init NS_UNAVAILABLE;

/*! \if ENGLISH
 *  \brief create NvsHumanSegmenter.
 *  \param modelPath humanSegment model file path
 *  \param option   option for NvsHumanSegmenter
 *  \return Returns BOOL value. YES indicates that the license verification is successful, and NO indicates that the verification fails.
 *  \else
 *  \brief 新建 NvsHumanSegmenter。
 *  \param modelPath humanSegment model 文件路径
 *  \param option   配置参数
 *  \return 返回实例化对象。
 *  \endif
*/
+ (NvsHumanSegmenter* _Nullable)createHumanSegmenterWithModelPath:(NSString *)modelPath
                                                           option:(NvsHumanSegmentOption)option
                                                            error:(NSError * _Nullable * _Nullable)outError;


/*! \if ENGLISH
 *  \brief setThreshold.
 *  \param threshold threshold value.(Note: range of value is (0,1.0], default value is 1.0)
 *  \else
 *  \brief 设置阈值。
 *  \param threshold 阈值。(注意，取值范围(0,1.0], 默认值为1.0)
 *  \endif
*/
- (void)setThreshold:(double)threshold;

/*! \if ENGLISH
 *  \brief detect humanSegment with given buffer
 *  \param buffer SDK license file path
 *  \param rotate rotation of buffer
 *  \param scaleResultToOriginSize scale result mask to origin size of buffer whether or not
 *  \param reverse reverse mask area color or not
 *  \param outError   If something goes wrong, *outError is set to a non-nil NSError that describes the failure that occurred. errorCode: NvsAIErrorCode
 *  \return Returns NvsHumanSegmentMask value.
 *  \else
 *  \brief 检测人像分割。
 *  \param buffer SDK授权文件路径
 *  \param rotate buffer 旋转角度
 *  \param scaleResultToOriginSize 是否将返回的mask 缩放到图像原始尺寸
 *  \param reverse 是否反转mask区域颜色
 *  \param outError  如果出错，返回错误信息，错误码：NvsAIErrorCode
 *  \return 返回MASK值。
 *  \endif
*/
- (NvsHumanSegmentMask)detect:(NvsImageBuffer)buffer
                       rotate:(NvcVideoRotation)rotate
      scaleResultToOriginSize:(BOOL)scaleResultToOriginSize
                      reverse:(BOOL)reverse
                        error:(NSError * _Nullable * _Nullable)outError;


@end


// 主体区域检测
@interface NvsMainBodyDetector : NvsHumanSegmenter

- (instancetype)init NS_UNAVAILABLE;

/*! \if ENGLISH
 *  \brief create NvsMainBodyDetector.
 *  \param modelPath humanSegment model file path
 *  \param option   option for NvsHumanSegmenter
 *  \return Returns BOOL value. YES indicates that the license verification is successful, and NO indicates that the verification fails.
 *  \else
 *  \brief 新建 NvsHumanSegmenter。
 *  \param modelPath humanSegment model 文件路径
 *  \param option   配置参数
 *  \return 返回实例化对象。
 *  \endif
 */
+ (NvsMainBodyDetector* _Nullable)createHumanSegmenterWithModelPath:(NSString *)modelPath
                                                             option:(NvsHumanSegmentOption)option
                                                              error:(NSError * _Nullable * _Nullable)outError;

@end



NS_ASSUME_NONNULL_END
