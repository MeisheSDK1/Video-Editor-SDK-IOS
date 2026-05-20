//
//  NvHumanDetectorWrap.h
//  NvAIDetect
//
//  Created by Mac-Mini on 2023/7/20.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import "NvsAICommon.h"

NS_ASSUME_NONNULL_BEGIN
@class NvsUniversalBox;

@protocol NvHumanDetectorWrapDelegate <NSObject>

- (void)humanDelect:(NSMutableArray<NvsUniversalBox *>*)list width:(NSUInteger)width height:(NSUInteger)height;
- (void)humanBodyTrack:(NvsUniversalBox *)trackBox;
- (void)humanLossBodyTrack:(nullable NvsUniversalBox *)trackBox;

@end

@interface NvHumanDetectorWrap : NSObject

@property (nonatomic, weak) id<NvHumanDetectorWrapDelegate> delegate;

/*! \if ENGLISH
 *  \brief create NvsHumanDetector.
 *  \param modelPath human detect model file path
 *  \return Returns NvsHumanDetector instance.
 *  \else
 *  \brief 初始化 NvsHumanDetector 对象。
 *  \param modelPath 人体检测 模型 文件路径
 *  \return 返回实例化对象。
 *  \endif
 */
+ (NvHumanDetectorWrap* _Nullable)createHumanDetectorWithModelPath:(NSString *)modelPath
                                                        error:(NSError * _Nullable * _Nullable)outError;
/*! \if ENGLISH
 *  \brief detect human info
 *  \param pixelBuffer Image
 *  \param rotate The mobile device rotation Angle
 *  \param outError error feedback information
 *  \else
 *  \brief 检测人体信息。
 *  \param pixelBuffer 图像
 *  \param rotate 手机设备旋转角度
 *  \param outError 出错时反馈的信息
 *  \endif
 */
- (void)detect:(CVPixelBufferRef)pixelBuffer rotate:(NvcVideoRotation)rotate error:(NSError **)outError;

- (void)setSelectBodyBox:(CGPoint)point width:(NSUInteger)width height:(NSUInteger)height needMirror:(BOOL)needMirror;

@property (atomic, assign) float diou;
@property (atomic, assign) float boxScore;
@property (atomic, assign) float compareTrackFeature;

@end

NS_ASSUME_NONNULL_END
