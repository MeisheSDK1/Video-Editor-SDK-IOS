//
//  NvsHumanDetector.h
//  NvAISdk
//
//  Created by Mac-Mini on 2023/4/26.
//

#import <Foundation/Foundation.h>
#import "NvsAICommon.h"
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvsUniversalBox : NSObject<NSCopying>
@property (nonatomic, assign) int xmin, ymin, xmax, ymax;
@property (nonatomic, assign) float score;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) float tb_diou;
@property (nonatomic, assign) float compare_track_feature;
@property (nonatomic, assign) float boxScore;
@property (nonatomic, strong) NSArray *diff_array;

@end

@protocol NvsHumanDetectorDelegate <NSObject>

- (void)onResult:(CVPixelBufferRef)pixelBuffer flag:(int)flag;
- (void)onResultBox:(NvsUniversalBox*)box flag:(int)flag;

@end

@interface NvsHumanDetector : NSObject
@property (nonatomic, weak) id<NvsHumanDetectorDelegate> delegate;
- (instancetype)init NS_UNAVAILABLE;
/*! \if ENGLISH
 *  \brief create NvsHumanDetector.
 *  \param path human detect model file path
 *  \return Returns NvsHumanDetector instance.
 *  \else
 *  \brief 初始化 NvsHumanDetector 对象。
 *  \param path 人体检测 模型 文件路径
 *  \return 返回实例化对象。
 *  \endif
 */
+ (instancetype)createHumanDetectorWithModelPath:(NSString *)path option:(NvsModelInitOption)option error:(NSError * _Nullable * _Nullable)outError;

/*! \if ENGLISH
 *  \brief The human body information of the image is detected, and the rotation Angle of the mobile device is passed to the mobile phone. If an error occurs, the outError is returned.
 *  \param Image rotate The mobile device rotation Angle outError error feedback information
 *  \return Return Returns information about several human frames.
 *  \else
 *  \brief 检测图像的人体信息，传入手机设备的旋转角度，如果发生错误通过outError返回。
 *  \param imageBuffer 图像 rotate 手机设备旋转角度 outError 出错时反馈的信息
 *  \return 返回返回数个人体框信息。
 *  \endif
 */
- (NSMutableArray <NvsUniversalBox *>*)detect:(NvsImageBuffer)imageBuffer rotate:(NvcVideoRotation)rotate error:(NSError **)outError;

/*! \if ENGLISH
 *  \brief The human body information of the image is detected, and the rotation Angle of the mobile device is passed to the mobile phone. If an error occurs, the outError is returned.
 *  \param Image rotate The mobile device rotation Angle outError error feedback information
 *  \return Return Returns information about several human frames.
 *  \else
 *  \brief 跟踪人像，并返回一个新的人体框信息。
 *  \param imageBuffer 输入图像
 *  \param inbox 输入上一次的人体框信息
 *  \param rotate 手机设备旋转角度
 *  \return 返回返回数个人体框信息。
 *  \endif
 */
- (BOOL)track:(NvsImageBuffer)imageBuffer inbox:(NvsUniversalBox *)inbox outbox:(NvsUniversalBox *)outbox rotate:(NvcVideoRotation)rotate;

/*! \if ENGLISH
 *  \brief After the tracking is lost, the portrait is retrieved
 *  \param imageBuffer Input image
 *  \param inbox Enter the information of the last successful tracking of the human frame
 *  \param rotate Rotation Angle of the mobile device
 *  \return Whether to find success.
 *  \else
 *  \brief 跟踪丢失后，找回人像
 *  \param imageBuffer 输入图像
 *  \param inbox 输入上一次跟踪成功的人体框信息
 *  \param rotate 手机设备旋转角度
 *  \return 是否找回成功。
 *  \endif
 */
- (BOOL)lossFind:(NvsImageBuffer)imageBuffer inbox:(NvsUniversalBox *)inbox rotate:(NvcVideoRotation)rotate;

/**
 以下几个函数客户端不必关心，这几个参数是测试调整参数用的。后期这几个可能会被屏蔽掉
 */
- (BOOL)lossFind:(NvsImageBuffer)imageBuffer inbox:(NvsUniversalBox *)inbox rotate:(NvcVideoRotation)rotate diou:(float)diou boxScore:(float)boxScore compareTrackFeature:(float)compareTrackFeature;
- (unsigned int)getOcclusion;
- (void)setCrossMode:(BOOL)crossMode;
- (void)setTbdiou:(float)tbdiou;
- (void)setTfeature:(float)tfeature;
- (void)setDtcx:(float)dtcx;
- (void)setDtx:(float)dtx;
- (void)setDty:(float)dty;
/**
 以上几个函数客户端不必关心，这几个参数是测试调整参数用的。后期这几个可能会被屏蔽掉
 */

/*! \if ENGLISH
 *  \brief After confirming the loss, the information needs to be reset before the next detection
 *  \else
 *  \brief 确认丢失后，下一次再进行检测之前需要重置信息
 *  \endif
 */
- (void)reset;
@end

NS_ASSUME_NONNULL_END
