//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2019. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Oct 28. 2019
//   Author:        Meishe video team
//================================================================================

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"

/*! \if ENGLISH
 *   \brief Beat detection class
 *   \else
 *   \brief 音乐节奏检测类
 *   \endif
 */

NS_ASSUME_NONNULL_BEGIN

/*! \if ENGLISH
 *  \brief Beat detection callback interface
 *  \else
 *  \brief 音乐节奏检测回调接口
 *  \endif
 */
@protocol NvsBeatDetectionDelegate <NSObject>

/*! \if ENGLISH
 *  \brief Finish beat detection.
 *  \param rhythmPoints Result of rhythm points
 *  \param beats Result of beat
 *  \param errorType error type
 *  \else
 *  \brief 完成检测
 *  \param rhythmPoints 检测完成后的节奏时间点列表
 *  \param beats 检测完成后的节拍时间点列表
 *  \param errorType 错误类型
 *  \endif
 */
-(void)onFinished:(NSArray<NSNumber*>*)rhythmPoints beats:(NSArray<NSNumber*>*)beats errorType:(int)errorType;

/*! \if ENGLISH
 *  \brief beat detection progress.
 *  \param progress beat detection progress.
 *  \else
 *  \brief 检测进度
 *  \param progress 检测进度
 *  \endif
 */
-(void)onProgress:(float)progress;

@end

NVS_EXPORT @interface NvsBeatDetection : NSObject

@property (nonatomic,weak) id<NvsBeatDetectionDelegate> delegate;

/*! \if ENGLISH
 *  \brief Initializes beat detection instance.
 *  \param flags Flags, zero temporarily
 *  \return Returns a beat detection instance object.
 *  \else
 *  \brief 对音乐节奏检测类的单例实例进行初始化
 *  \param flags 标志字段，目前暂时为0
 *  \return 返回音乐节奏检测类的单例实例对象
 *  \endif
 *  \since 2.14.0
 *  \sa close
 */
+ (instancetype)sharedInstance:(int)flag;

/*! \if ENGLISH
 *  \brief Destroys the beat detection object instance. note: it can be created again after destruction.
 *  \else
 *  \brief 销毁音乐节奏检测类实例。注意: 销毁之后可以再次创建及获取
 *  \endif
 *  \sa sharedInstance
 */
+ (void)close;

/*! \if ENGLISH
 *  \brief Start beat detection
 *  \param inputFilePath input music file path
 *  \param sensitivity min duration between two adjacent beats
 *  \return Return true if suc, otherwise false
 *  \else
 *  \brief 开始检测
 *  \param inputFilePath 输入的音乐文件路径
 *  \param sensitivity 相邻的两个节奏点的最小时间间隔
 *  \return 如果成功返回true，否则为false
 *  \endif
 *  \sa sharedInstance
 *  \sa cancelDetect
 */
- (BOOL)startDetect:(NSString*)inputFilePath sensitivity:(int)sensitivity;

/*! \if ENGLISH
 *  \brief Cancel beat detection
 *  \else
 *  \brief 取消当前检测任务
 *  \endif
 *  \sa startDetect
 */
- (void)cancelDetect;

@end

NS_ASSUME_NONNULL_END
